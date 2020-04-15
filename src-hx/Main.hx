import tool.TsProgramTools;
import Log.LogLevel;
import haxe.DynamicAccess;
import haxe.io.Path;
import hxargs.Args.ArgHandler;
import js.Node;
import js.node.Fs;
import typescript.Ts;
import typescript.ts.CompilerOptions;
import typescript.ts.ModuleResolutionKind;
import typescript.ts.ResolvedModuleFull;

using StringTools;
using tool.StringTools;

@:nullSafety
class Main {

	static public final dts2hxPackageJson = Macro.getLocalPackageJson();
	static public final log = new Log();

	static function main() {
		Console.warnPrefix = '<b,yellow>> Warning:</b> ';
		Console.errorPrefix = '<b,red>> Error:</b> ';

		var userArgs = Node.process.argv.slice(2);

		var cliOptions = {
			cwd: null,
			outputPath: 'dts2hx-output',
			tsConfigFilePath: null,
			tsCompilerOptions: [],
			moduleNames: new Array<String>(),
			moduleSearchPath: '.',
			allDependencies: false,
			noOutput: false,
			locationComments: false,
			logLevel: Warning,
		}

		var help: Bool = false;
		var noColor: Bool = false;
		var silent: Bool = false;
		var defaultValueFormatting = 'yellow';

		var argHandler: ArgHandler;
		argHandler = hxargs.Args.generate([
			@doc('Set output directory for generated externs (default <$defaultValueFormatting>"${cliOptions.outputPath}"</>)')
			['--output', '-o'] => (path: String) -> {
				cliOptions.outputPath = path;
			},

			@doc('Path to use when searching for modules')
			['--moduleSearchPath', '-p'] => (path: String) -> {
				cliOptions.moduleSearchPath = path;
			},

			@doc('Convert all dependencies referenced in package.json (that have type definitions)')
			['--all'] => () -> {
				cliOptions.allDependencies = true;
			},

			@doc('Set path to tsconfig file to use when processing the .d.ts files')
			'--tsconfig' => (path: String) -> {
				cliOptions.tsConfigFilePath = path;
			},

			@doc('Set ts compiler option `--target`, takes precedent over options provided by --tsconfig (default <$defaultValueFormatting>"ES6"</>)')
			'--target' => (scriptTarget: String) -> {
				cliOptions.tsCompilerOptions.push('--target');
				cliOptions.tsCompilerOptions.push(scriptTarget);
			},

			@doc('Set ts compiler option `--moduleResolution`, takes precedent over options provided by --tsconfig (default <$defaultValueFormatting>"Node"</>)')
			'--moduleResolution' => (kind: String) -> {
				cliOptions.tsCompilerOptions.push('--moduleResolution');
				cliOptions.tsCompilerOptions.push(kind);
			},

			@doc('Enables printing the corresponding source file and line number for each declaration')
			'--sourceLocation' => () -> {
				cliOptions.locationComments = true;
			},

			@doc('Runs conversion but doesn\'t generate files')
			'--noOutput' => () -> {
				cliOptions.noOutput = true;
			},

			@doc('Disable terminal colors')
			'--noColor' => () -> noColor = true,
			// hidden alias
			'--no-color' => () -> noColor = true,

			@doc('Show this help')
			'--help' => () -> help = true,

			@doc('Disable command-line output')
			'--silent' => () -> silent = true,

			@doc('Print all logs')
			'--verbose' => () -> {
				cliOptions.logLevel = All;
			},

			@doc('Module name')
			_ => (arg: String) -> {
				if (arg.charAt(0) == '-') {
					throw 'Unknown argument "$arg"';
				}
				cliOptions.moduleNames.push(arg);
			}
		]);

		if (userArgs.length == 0) {
			printDoc(argHandler);
			Node.process.exit(1);
			return;
		} else {
			try argHandler.parse(userArgs) catch (e: String) {
				Console.error(e);
				Console.print('\n');
				printDoc(argHandler);
				Node.process.exit(1);
			}
		}

		if (silent) {
			Console.printIntercept = (s, o) -> false;
			haxe.Log.trace = (v, ?info) -> {};
		}

		if (noColor) {
			Console.formatMode = Disabled;
		}

		// apply bool flags
		if (help) {
			printDoc(argHandler);
			Node.process.exit(0);
			return;
		}

		log.setPrintLogLevel(cliOptions.logLevel);

		var defaultCompilerOptions = Ts.getDefaultCompilerOptions();
		defaultCompilerOptions.target = ES2015; // default to ES6 for lib types
		defaultCompilerOptions.types = []; // disable automatic node_modules/@types inclusion
		defaultCompilerOptions.moduleResolution = ModuleResolutionKind.NodeJs;

		var compilerOptions = defaultCompilerOptions;

		// add options from --tsconfig
		if (cliOptions.tsConfigFilePath != null) {
			var readResult = Ts.readConfigFile(cliOptions.tsConfigFilePath, (path) -> Ts.sys.readFile(path, 'utf8'));
			if (readResult.config != null) {
				var compilerOptionsObj = Reflect.field(readResult.config, 'compilerOptions');
				var result = Ts.convertCompilerOptionsFromJson(compilerOptionsObj, Node.process.cwd(), cliOptions.tsConfigFilePath);
				log.diagnostics(result.errors);

				compilerOptions = extend(compilerOptions, result.options);
			} else {
				if (readResult.error != null) {
					log.diagnostics([readResult.error]);
				}
			}
		}

		// add user-supplied typescript compiler options
		if (cliOptions.tsCompilerOptions.length > 0) {
			var result = Ts.parseCommandLine(cliOptions.tsCompilerOptions);
			log.diagnostics(result.errors);
			compilerOptions = extend(compilerOptions, result.options);
		}

		var host = Ts.createCompilerHost(compilerOptions);

		// add package.json dependencies to list of modules
		if (cliOptions.allDependencies) {
			try {
				var packageJson = host.readFile('package.json');
				if (packageJson == null) {
					var absPath = haxe.io.Path.join([host.getCurrentDirectory(), 'package.json']);
					throw '<b>"${absPath}"</> does not exist; could not determine dependencies';
				}

				var packageObj = haxe.Json.parse(packageJson);
				var dependencies: DynamicAccess<String> = packageObj.dependencies != null ? packageObj.dependencies : {};
				var devDependencies: DynamicAccess<String> = packageObj.devDependencies != null ? packageObj.devDependencies : {};
				var allDependencies = dependencies.keys().concat(devDependencies.keys());

				// check if module has typescript
				for (moduleName in allDependencies) {
					var result = Ts.resolveModuleName(moduleName, cliOptions.moduleSearchPath + '/.', compilerOptions, host);
					if (result.resolvedModule != null) {
						switch result.resolvedModule.extension {
							case Dts, Ts, Tsx: // maybe we should limit to just Dts
								cliOptions.moduleNames.push(moduleName);
							case Js, Json, Jsx, TsBuildInfo:
						}
						continue;
					}
					log.warn('No type definitions found for <b>"${moduleName}"</b>');
				}
			} catch (e: String) {
				log.error(e);
			}
		}

		// add modules from cli options
		var moduleQueue = new ds.OnceOnlyQueue<String>();
		for (moduleName in cliOptions.moduleNames) {
			moduleQueue.tryEnqueue(moduleName);
		}
		
		// add modules from compilerOptions
		for (moduleName in Ts.getAutomaticTypeDirectiveNames(compilerOptions, host)) {
			moduleQueue.tryEnqueue(moduleName);
		}

		while (true) {
			var moduleName = moduleQueue.dequeue();
			if (moduleName == null) break; // finished queue
			try {
				var moduleDependencies = convertTsModule(moduleName, cliOptions.moduleSearchPath, compilerOptions, cliOptions.locationComments, cliOptions.outputPath, cliOptions.noOutput).moduleDependencies;
				if (moduleDependencies.length > 0) {
					log.log('<magenta>Module <b>$moduleName</> depends on <b>$moduleDependencies</></>');
				}
				for (moduleDependency in moduleDependencies) {
					moduleQueue.tryEnqueue(moduleDependency);
				}
			} catch (e: Any) {
				log.error(e);
				Node.process.exit(1);
			}
		}
	}

	static public function convertTsModule(moduleName: String, moduleSearchPath: String, compilerOptions: CompilerOptions, locationComments: Bool, outputPath: String, noOutput: Bool) {
		var host = Ts.createCompilerHost(compilerOptions);
		
		var resolvedModule: ResolvedModuleFull;
		var result = Ts.resolveModuleName(moduleName, moduleSearchPath + '/.', compilerOptions, host);
		resolvedModule = if (result.resolvedModule != null) {
			result.resolvedModule;
		} else {
			var failedLookupLocations: Array<String> = Reflect.field(result, 'failedLookupLocations'); // @internal field
			throw 'Failed to find typescript for module <b>"${moduleName}"</b>. Searched the following paths:<dim>\n\t${failedLookupLocations.join('\n\t')}</>';
		}

		// if the user references a module by a direct path, like ./example/test and there's no associated package information, we assume they don't want library wrapper
		var generateLibraryWrapper = !(TsProgramTools.isDirectPathReferenceModule(moduleName) && (resolvedModule.packageId == null));

		// moduleId is what you'd need to pass into require() to get the module

		// commented out: previously I used package name, which I expect may not always match the moduleId used in require()
		// var moduleId = if (result.resolvedModule.packageId != null && result.resolvedModule.packageId.name != null) {
		// 	result.resolvedModule.packageId.name;
		// } else {
		// 	var relPath: String = untyped Ts.convertToRelativePath(result.resolvedModule.resolvedFileName, host.getCurrentDirectory(), fileName -> host.getCanonicalFileName(fileName));
		// 	relPath;
		// }

		var converter = new ConverterContext(moduleName, resolvedModule.resolvedFileName, compilerOptions, locationComments, log);

		if (!noOutput) {
			// save modules to files
			var printer = new haxe.macro.Printer();

			var outputLibraryPath = generateLibraryWrapper ? Path.join([outputPath, generateLibraryName(converter.entryPointModuleId)]) : outputPath;

			for (_ => haxeModule in converter.generatedModules) {
				var filePath = Path.join([outputLibraryPath].concat(haxeModule.pack).concat(['${haxeModule.name}.hx']));
				var moduleHaxeStr = printer.printTypeDefinition(haxeModule);

				for (subType in haxeModule.subTypes) {
					moduleHaxeStr += '\n\n' + printer.printTypeDefinition(subType);
				}

				touchDirectoryPath(Path.directory(filePath));
				Fs.writeFileSync(filePath, moduleHaxeStr);
			}

			touchDirectoryPath(outputLibraryPath);

			if (generateLibraryWrapper) {
				var packageJson = getModulePackageJson(moduleName, moduleSearchPath, resolvedModule);
				// write a readme
				var readmeStr = generateReadme(moduleName, moduleSearchPath, converter, resolvedModule, packageJson);
				Fs.writeFileSync(Path.join([outputLibraryPath, 'README.md']), readmeStr);

				// write haxelib.json
				var haxelibJsonStr = generateHaxelibJson(moduleName, moduleSearchPath, converter, resolvedModule, packageJson);
				Fs.writeFileSync(Path.join([outputLibraryPath, 'haxelib.json']), haxelibJsonStr);
			}
		}

		return converter;
	}

	static function generateReadme(inputModuleName: String, moduleSearchPath: String, converter: ConverterContext, resolvedModule: ResolvedModuleFull, modulePackageJson: Null<Dynamic<Dynamic>>): String {
		var dts2hxRepoUrl = dts2hxPackageJson.repository.url;
		var dts2hxRef = dts2hxRepoUrl != null ? '[dts2hx]($dts2hxRepoUrl)' : 'dts2hx';
		var typesModuleVersion: Null<String> = resolvedModule.packageId != null ? resolvedModule.packageId.version : null;
		var typesModuleName = resolvedModule.packageId != null ? resolvedModule.packageId.name : inputModuleName;
		var typesModuleUrl = if (modulePackageJson != null) {
			if (modulePackageJson.homepage != null) modulePackageJson.homepage;
			else if (modulePackageJson.bugs != null && modulePackageJson.bugs.url != null) modulePackageJson.bugs.url;
			else null;
		} else null;

		var typesModuleIdMarkdown = '${typesModuleName}${typesModuleVersion != null ? ' v$typesModuleVersion' : ''}';
		if (typesModuleUrl != null) {
			typesModuleIdMarkdown = '[$typesModuleIdMarkdown]($typesModuleUrl)';
		}

		var sections = new Array<String>();
		sections.push('# Haxe Externs for ${converter.entryPointModuleId}');

		sections.push('
			Generated from **$typesModuleIdMarkdown** by **$dts2hxRef ${dts2hxPackageJson.version}** using **TypeScript ${typescript.Ts.version}** with arguments:

				dts2hx ${Node.process.argv.slice(2).join(' ')}
		');

		if (converter.moduleDependencies.length > 0) {
			sections.push(
				[
					'## Dependencies'
				].concat(
					converter.moduleDependencies.map(s -> '- ${s}')
				).join('\n')
			);
		}

		if (modulePackageJson != null) {
			try if (modulePackageJson.contributors != null && modulePackageJson.contributors.length > 0) {
				sections .push(
					[
						'## Contributors to ${typesModuleName}'
					].concat(
						(modulePackageJson.contributors: Array<Dynamic<String>>).map(c -> c.url != null ? '- [${c.name}](${c.url})' : c.name)
					).join('\n')
				);
			} catch (e: Any) null;
		}

		return sections.map(s -> s.removeIndentation().trim()).join('\n\n');
	}

	static function generateHaxelibJson(inputModuleName: String, moduleSearchPath: String, converter: ConverterContext, resolvedModule: ResolvedModuleFull, modulePackageJson: Null<Dynamic<Dynamic>>): String {
		var moduleVersion: Null<String> = resolvedModule.packageId != null ? resolvedModule.packageId.version : null;
		var haxelib: Dynamic = {
			name: generateLibraryName(converter.entryPointModuleId),
			tags: [converter.entryPointModuleId, "externs", "typescript", "javascript", "dts2hx"],
			description: 'Externs for ${converter.entryPointModuleId}${moduleVersion != null ? ' v$moduleVersion' : ''} automatically generated by dts2hx',
			contributors: ["haxiomic"],
			dependencies: { }
		}
		if (moduleVersion != null) {
			haxelib.version = moduleVersion;
		}
		// add dependencies
		for (moduleDependency in converter.moduleDependencies) {
			Reflect.setField(haxelib.dependencies, generateLibraryName(moduleDependency), "");
		}
		return haxe.Json.stringify(haxelib, null, '\t');
	}

	static function generateLibraryName(moduleName: String) {
		// could add '-externs' maybe
		return moduleName;
	}

	static function getModulePackageJson(moduleName: String, moduleSearchPath: String, resolvedModule: ResolvedModuleFull): Null<Dynamic<Dynamic>> {
		var typesModuleName = resolvedModule.packageId != null ? resolvedModule.packageId.name : moduleName;
		return try {
			var packageJsonPath = js.Syntax.code('require.resolve({0}, {paths: [{1}]})', '$typesModuleName/package.json', moduleSearchPath);
			haxe.Json.parse(Fs.readFileSync(packageJsonPath, { encoding: "utf8" }));
		} catch (e: Any) null;
	}

	static function extend<T>(base: T, extendWidth: T): T {
		var extended = {};
		for (field in Reflect.fields(base)) {
			Reflect.setField(extended, field, Reflect.field(base, field));
		}
		for (field in Reflect.fields(extendWidth)) {
			Reflect.setField(extended, field, Reflect.field(extendWidth, field));
		}
		return cast extended;
	}

	static function printDoc(argHandler: ArgHandler) {
		Console.printlnFormatted('<b>dts2hx</b> <b>${dts2hxPackageJson.version}</> using <b>TypeScript ${typescript.Ts.version}</>');
		Console.println('TypeScript definition to haxe extern converter');
		Console.println('');
		Console.printlnFormatted('<b>Usage:</b>');
		Console.printlnFormatted('\tdts2hx <i,cyan>{moduleName}</> <i,cyan>{options}</>');
		Console.println('');

		Console.printlnFormatted('<b>Examples:</b>');
		Console.printlnFormatted('\tdts2hx three');
		Console.printlnFormatted('\tdts2hx --all -o .haxelib');
		Console.printlnFormatted('\tdts2hx ./src/index --verbose');
		Console.println('');

		Console.printFormatted('<bright_white,b>Options:</>\n');

		var usageStringMaxLength = 0;

		var formattedOptions = [];

		for (item in argHandler.options) {
			if (item.doc == null) continue;

			var usageString = '<light_white>${item.flags.join(', ')}</>';

			if (item.args.length > 0) {
				usageString += ' <i,cyan>' + item.args.map(a -> '{${a.opt?'?':''}${a.name}}').join(', ') + '</>';
			}
			
			var unformattedLength = Console.stripFormatting(usageString).length;

			formattedOptions.push({
				usageString: usageString,
				unformattedLength: unformattedLength,
				doc: item.doc,
			});

			usageStringMaxLength = Std.int(Math.max(usageStringMaxLength, unformattedLength));
		}

		var lines = formattedOptions.map(f -> {
			var rPadding = [for (i in 0...(usageStringMaxLength - f.unformattedLength)) ' '].join('');
			'${f.usageString}$rPadding ${f.doc}';
		});

		Console.printFormatted(lines.join('\n') + '\n');
	}

	/**
		Ensures directory structure exists for a given path
		(Same behavior as mkdir -p)
		@throws Any
	**/
	static public function touchDirectoryPath(path: String) {
		var directories = Path.normalize(path).split('/');
		var currentDirectories = [];
		for (directory in directories) {
			currentDirectories.push(directory);
			var currentPath = currentDirectories.join('/');
			if (currentPath == '/') continue;
			if (Fs.existsSync(currentPath) && Fs.statSync(currentPath).isDirectory()) continue;
			if (!Fs.existsSync(currentPath)) {
				Fs.mkdirSync(currentPath);
			} else {
				throw 'Could not create directory $currentPath because a file already exists at this path';
			}
		}
	}

}
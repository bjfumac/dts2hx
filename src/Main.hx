import js.node.ChildProcess;
import Log.LogLevel;
import StdLibMacro.TypeMap;
import haxe.DynamicAccess;
import haxe.io.Path;
import hxargs.Args.ArgHandler;
import js.Node;
import js.node.Fs;
import tool.FileTools;
import tool.TsProgramTools;
import typescript.Ts;
import typescript.ts.CompilerOptions;
import typescript.ts.ModuleResolutionKind;
import typescript.ts.ResolvedModuleFull;

using Lambda;
using StringTools;
using tool.StringTools;

@:nullSafety
class Main {

	static public final dts2hxPackageJson = Macro.getJson('package.json');
	static final defaultStdLibTypeMap: TypeMap = Macro.getJson('src/typemap/4.0.5-stdlib.json');

	static function main() {
		Console.warnPrefix = '<b,yellow>> Warning:</b> ';
		Console.errorPrefix = '<b,red>> Error:</b> ';

		var userArgs = Node.process.argv.slice(2);

		var cliOptions = {
			cwd: null,
			outputPath: 'externs',
			tsConfigFilePath: null,
			tsCompilerOptions: [],
			moduleNames: new Array<String>(),
			moduleSearchPath: '.',
			allDependencies: false,
			noOutput: false,
			locationComments: false,
			libWrapper: true,
			logLevel: Error,
			stdLibMode: StdLibMode.DefaultTypeMap,
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

			@doc('Use system haxe version when mapping types to the haxe standard library. By default, standard library types for haxe ${defaultStdLibTypeMap.haxeVersion} are used')
			'--useSystemHaxe' => () -> {
				cliOptions.stdLibMode = SystemHaxe;
			},

			@doc('Disables mapping types to the haxe standard library – this means externs will be generated for built-in types')
			'--noStdLib' => () -> {
				cliOptions.stdLibMode = None;
			},

			@doc('Disables wrapping the generated externs in a haxelib-style library. Use this option if you intend to use the externs via a class-path rather than as a library')
			'--noLibWrap' => () -> {
				cliOptions.libWrapper = false;
			},

			@doc('Runs conversion but doesn\'t save files')
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

			@doc('Disable printing warnings')
			'--noWarn' => () -> {
				cliOptions.logLevel = Error;
			},

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

		Log.setPrintLogLevel(cliOptions.logLevel);

		var defaultCompilerOptions = Ts.getDefaultCompilerOptions();
		defaultCompilerOptions.target = ES2015; // default to ES6 for lib types
		defaultCompilerOptions.types = []; // disable automatic node_modules/@types inclusion
		defaultCompilerOptions.moduleResolution = ModuleResolutionKind.NodeJs;
		// we set `strictNullChecks` to true by default so that
		// `number | null` is typed as `Union<number, null>` and not just `number`
		defaultCompilerOptions.strictNullChecks = true;

		var compilerOptions = defaultCompilerOptions;

		// add options from --tsconfig
		if (cliOptions.tsConfigFilePath != null) {
			var readResult = Ts.readConfigFile(cliOptions.tsConfigFilePath, (path) -> Ts.sys.readFile(path, 'utf8'));
			if (readResult.config != null) {
				var compilerOptionsObj = Reflect.field(readResult.config, 'compilerOptions');
				var result = Ts.convertCompilerOptionsFromJson(compilerOptionsObj, Node.process.cwd(), cliOptions.tsConfigFilePath);
				Log.diagnostics(result.errors);

				compilerOptions = extend(compilerOptions, result.options);
			} else {
				if (readResult.error != null) {
					Log.diagnostics([readResult.error]);
				}
			}
		}

		// add user-supplied typescript compiler options
		if (cliOptions.tsCompilerOptions.length > 0) {
			var result = Ts.parseCommandLine(cliOptions.tsCompilerOptions);
			Log.diagnostics(result.errors);
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
					Log.warn('No type definitions found for <b>"${moduleName}"</b>');
				}
			} catch (e: String) {
				Log.error(e);
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

		// get std lib type map
		var stdLibTypeMap = switch cliOptions.stdLibMode {
			case None: null;
			case DefaultTypeMap: defaultStdLibTypeMap;
			case SystemHaxe:
				// generate standard library type map using the system version of haxe
				try {
					var str = ChildProcess.execSync('haxe --version');
					Console.log('Using standard library of system haxe version <b>$str</>');
					var haxeSrcPath = Path.join([Node.__dirname, '../', 'src']);
					var stdLibJsonStr = ChildProcess.execSync('haxe --macro "StdLibMacro.getMap(true)" --js not-real.js --no-output', {
						cwd: haxeSrcPath
					});
					haxe.Json.parse(stdLibJsonStr);
				} catch (e: Any) {
					// error code
					Log.error('Failed to generate standard library type map (using <b>${defaultStdLibTypeMap.haxeVersion}</> instead): $e');
					defaultStdLibTypeMap;
				}
		}

		if (moduleQueue.empty()) {
			Log.error('No modules queued');
		}

		while (true) {
			var moduleName = moduleQueue.dequeue();
			if (moduleName == null) break; // finished queue

			var converterContext = convertTsModule(moduleName, cliOptions.moduleSearchPath, compilerOptions, stdLibTypeMap, cliOptions.libWrapper, cliOptions.locationComments, cliOptions.outputPath, cliOptions.noOutput);
			if (converterContext == null) continue;
			
			var moduleDependencies = converterContext.moduleDependencies;
			if (moduleDependencies.length > 0) {
				Log.log('<magenta>Module <b>$moduleName</> depends on <b>$moduleDependencies</></>');
			}
			for (moduleDependency in moduleDependencies) {
				moduleQueue.tryEnqueue(moduleDependency.normalizedModuleName);
			}
		}
	}

	static public function convertTsModule(moduleName: String, moduleSearchPath: String, compilerOptions: CompilerOptions, stdLibTypeMap: Null<TypeMap>, libWrapper: Bool, locationComments: Bool, outputPath: String, noOutput: Bool): Null<ConverterContext> {
		var converter = try {
			new ConverterContext(moduleName, moduleSearchPath, compilerOptions, stdLibTypeMap, locationComments);
		} catch (e: Any) {
			Log.error(e);
			return null;
		}

		// if the user references a module by a direct path, like ./example/test and there's no associated package information, we assume they don't want library wrapper
		var generateLibraryWrapper = libWrapper && !(TsProgramTools.isDirectPathReferenceModule(moduleName) && (converter.packageName == null));

		if (!noOutput) {
			// save modules to files
			var printer = new Printer();

			// var outputDirectoryName = resolvedModule.pac
			var libraryName = converter.packageName != null ? converter.packageName : converter.normalizedInputModuleName;
			var outputLibraryPath = generateLibraryWrapper ? Path.join([outputPath, libraryName]) : outputPath;

			for (_ => haxeModule in converter.generatedModules) {

				// skip empty @valueModuleOnly classes
				var skipModule = if (haxeModule.meta != null) {
					var isValueModuleOnly = haxeModule.meta.find(m -> m.name == 'valueModuleOnly') != null;
					isValueModuleOnly && haxeModule.fields.length == 0;
				} else false;

				if (skipModule) continue;

				var filePath = Path.join([outputLibraryPath].concat(haxeModule.pack).concat(['${haxeModule.name}.hx']));
				var printPackage = true;
				var moduleHaxeStr = printer.printTypeDefinition(haxeModule, printPackage);

				FileTools.touchDirectoryPath(Path.directory(filePath));
				Fs.writeFileSync(filePath, moduleHaxeStr);
			}

			FileTools.touchDirectoryPath(outputLibraryPath);

			if (generateLibraryWrapper) {
				var packageJson = getModulePackageJson(moduleName, moduleSearchPath, converter.entryPointModule);
				// write a readme
				var readmeStr = generateReadme(moduleName, moduleSearchPath, converter, packageJson, stdLibTypeMap);
				Fs.writeFileSync(Path.join([outputLibraryPath, 'README.md']), readmeStr);

				// write haxelib.json
				var haxelibJsonStr = generateHaxelibJson(moduleName, moduleSearchPath, converter, packageJson);
				Fs.writeFileSync(Path.join([outputLibraryPath, 'haxelib.json']), haxelibJsonStr);
			}

			Console.success('<green>Saved externs for <b>$moduleName</> into <b>$outputLibraryPath/</></>');
		}

		return converter;
	}

	static function generateReadme(inputModuleName: String, moduleSearchPath: String, converter: ConverterContext, modulePackageJson: Null<Dynamic<Dynamic>>, stdLibTypeMap: Null<TypeMap>): String {
		var resolvedModule: ResolvedModuleFull = converter.entryPointModule;
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
		sections.push('# Haxe Externs for ${converter.packageName != null ? converter.packageName : converter.normalizedInputModuleName}');

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

	static function generateHaxelibJson(inputModuleName: String, moduleSearchPath: String, converter: ConverterContext, modulePackageJson: Null<Dynamic<Dynamic>>): String {
		var resolvedModule: ResolvedModuleFull = converter.entryPointModule;
		var moduleName = converter.packageName != null ? converter.packageName : converter.normalizedInputModuleName;
		var moduleVersion: Null<String> = resolvedModule.packageId != null ? resolvedModule.packageId.version : null;
		var haxelib: Dynamic = {
			name: moduleName,
			tags: [moduleName, "externs", "typescript", "javascript", "dts2hx"],
			description: 'Externs for ${moduleName}${moduleVersion != null ? ' v$moduleVersion' : ''} automatically generated by dts2hx',
			contributors: ["haxiomic"],
			dependencies: { }
		}
		if (moduleVersion != null) {
			haxelib.version = moduleVersion;
		}
		// add dependencies
		for (moduleDependency in converter.moduleDependencies) {
			var dependencyVersion = moduleDependency.packageInfo.version;
			Reflect.setField(haxelib.dependencies, moduleDependency.normalizedModuleName, dependencyVersion != null ? dependencyVersion : '');
		}
		return haxe.Json.stringify(haxelib, null, '\t');
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
		Console.printlnFormatted('<b>dts2hx</b> <b>${dts2hxPackageJson.version}</> <red>alpha</> using <b>TypeScript ${typescript.Ts.version}</>');
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

			var usageString = '${item.flags.join(', ')}';

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

}

enum StdLibMode {
	None;
	DefaultTypeMap;
	SystemHaxe;
}
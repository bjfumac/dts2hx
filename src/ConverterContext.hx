import ds.OnlyOnceSymbolQueue;
import haxe.ds.ReadOnlyArray;
import haxe.macro.Expr;
import tool.TsSyntaxTools;
import typescript.Ts;
import typescript.ts.CompilerHost;
import typescript.ts.CompilerOptions;
import typescript.ts.ExpressionWithTypeArguments;
import typescript.ts.GenericType;
import typescript.ts.InterfaceType;
import typescript.ts.Node;
import typescript.ts.NodeBuilderFlags;
import typescript.ts.NumberLiteralType;
import typescript.ts.ObjectFlags;
import typescript.ts.ObjectType;
import typescript.ts.ParameterDeclaration;
import typescript.ts.Program;
import typescript.ts.Signature;
import typescript.ts.SourceFile;
import typescript.ts.Symbol;
import typescript.ts.SymbolFlags;
import typescript.ts.SyntaxKind;
import typescript.ts.TupleType;
import typescript.ts.TupleTypeReference;
import typescript.ts.TypeAliasDeclaration;
import typescript.ts.TypeChecker;
import typescript.ts.TypeFlags;
import typescript.ts.TypeNode;
import typescript.ts.TypeParameter;
import typescript.ts.TypeParameterDeclaration;
import typescript.ts.TypeReference;
import typescript.ts.UnionType;

using Lambda;
using StringTools;
using TsInternal;
using tool.HaxeTools;
using tool.SymbolAccessTools;
using tool.TsProgramTools;
using tool.TsSymbolTools;
using tool.TsTypeTools;

private typedef TsType = typescript.ts.Type;

@:expose
@:nullSafety
class ConverterContext {
	
	/**
		Normalized entry-point module id (without prefix @types/).
		This is the value to use in `require()` to load the module at runtime.
		It may be a path, for example `./modules/example`
	**/
	public final entryPointModuleId: String;
	
	/**
		Map of package-paths to HaxeModules
	**/
	public final generatedModules = new Map<String, HaxeModule>();

	/**
		An array of normalized module ids (paths or names) that this module depends on.
		These dependencies will also need to be converted
	**/
	public final moduleDependencies: ReadOnlyArray<String>;

	public final tc: TypeChecker;
	public final host: CompilerHost;
	public final program: Program;

	/**
		Symbol access map is filled during an initial pass over the program.
		The access path for key-symbols such as types, are stored so we can retrieve them later when we have a type-reference
	**/
	public final symbolAccessMap: SymbolAccessMap;

	/**
		Using the symbol access map, a type-path is generated for every symbol in the program (including symbols in other modules and in the lib files).
		This is done upfront to ensure deterministic handling of module name deduplication
		If getting a reference to a symbol, use `getReferencedHaxeTypePath` instead
	**/
	final haxeTypePathMap: HaxeTypePathMap;

	/**
		Unique list of symbols to convert
		When a type is referenced during conversion, if it is inaccessible (and therefore not converted in the first pass), add it to this queue to be converted
	**/
	final declarationSymbolQueue = new OnceOnlySymbolQueue();

	final locationComments: Bool;

	final shortenTypePaths = true;

	public function new(moduleName: String, entryPointFilePath: String, compilerOptions: CompilerOptions, locationComments: Bool) {
		// this will be used as the argument to require()
		this.locationComments = locationComments;

		this.host = Ts.createCompilerHost(compilerOptions);
		this.program = Ts.createProgram([entryPointFilePath], compilerOptions, host);
		this.tc = program.getTypeChecker();

		this.entryPointModuleId = inline normalizeModuleName(moduleName);
		Log.log('<green>Converting module: <b>$entryPointModuleId</b>');

		Log.diagnostics(program.getAllDiagnostics());

		var entryPointSourceFile = program.getSourceFile(entryPointFilePath);

		if (entryPointSourceFile == null) {
			throw 'Failed to get entry-point source file';
		}

		var defaultLibSourceFiles = program.getSourceFiles().filter(s -> s.hasNoDefaultLib);

		// list of the module entry points source files, for the currently module and its referenced modules
		var dependencyRootSourceFiles: Array<SourceFile> = [];
		var dependencyModuleNames = new Array<String>();
		moduleDependencies = dependencyModuleNames;

		// set `moduleName` on source files with a known module
		// `sourceFile.moduleName` is not populated after binding, so let's populate it to help aliasing
		entryPointSourceFile.moduleName = this.entryPointModuleId;
		var moduleReferences = program.resolveAllTypeReferenceDirectives(host);
		for (moduleReference in moduleReferences) {
			if (moduleReference.resolvedTypeReferenceDirective != null) {
				var resolvedFileName = moduleReference.resolvedTypeReferenceDirective.resolvedFileName;
				var packageInfo = moduleReference.resolvedTypeReferenceDirective.packageId;
				var moduleName = packageInfo != null ? packageInfo.name : null;
				if (moduleName == null) {
					Log.warn('Referenced module does not have a moduleName in packageInfo <b>${resolvedFileName}</>');
				}
				var sourceFile = resolvedFileName != null ? program.getSourceFile(resolvedFileName) : null;
				if (sourceFile != null) {
					sourceFile.moduleName = moduleName != null ? inline normalizeModuleName(moduleName) : null;
					dependencyRootSourceFiles.push(sourceFile);
					if (moduleName != null) {
						dependencyModuleNames.push(moduleName);
					}
				} else {
					Log.error('Internal error: failed get source file for file <b>"$resolvedFileName"</> (module: <b>"$moduleName"</>)');
				}
			} else {
				Log.error('Failed to find referenced module <b>${moduleReference.failedLookupLocations[0]}</b>');
			}
		}

		// populate symbol access map
		var accessRoots = [cast entryPointSourceFile].concat(defaultLibSourceFiles).concat(dependencyRootSourceFiles);
		symbolAccessMap = new SymbolAccessMap(entryPointModuleId, program, accessRoots);

		// generate a haxe type-path for all type or module-class (ValueModule) symbols in the program
		haxeTypePathMap = new HaxeTypePathMap(entryPointModuleId, program, symbolAccessMap);

		// convert symbols for just this module
		program.walkReferencedSourceFiles(entryPointSourceFile, (sourceFile) -> {
			for (symbol in program.getExposedSymbolsOfSourceFile(sourceFile)) {
				TsSymbolTools.walkDeclarationSymbols(symbol, tc, (symbol, _) -> {
					declarationSymbolQueue.tryEnqueue(symbol);
				});
			}
		});

		// convert declaration symbols (types and module variables)
		// declarationSymbolQueue grows as types are referenced during conversion
		while (!declarationSymbolQueue.empty()) {
			var symbol: Symbol = cast declarationSymbolQueue.dequeue();

			// `Alias` here does not mean type-alias, instead it means export-alias (like `export {Type}`)
			// aliases are accounted for with SymbolAccess and don't need to handled here
			// NamespaceModules are just package and are handled in HaxeTypePathMap
			var handled = symbol.flags & (SymbolFlags.Alias | SymbolFlags.NamespaceModule) != 0;

			// symbol has type-declaration
			if (symbol.flags & (SymbolFlags.Type | SymbolFlags.ValueModule) != 0) {
				for (access in symbolAccessMap.getAccess(symbol)) {
					getHaxeModuleFromDeclarationSymbol(symbol, access);
				}
				handled = true;
			}
			
			if (symbol.flags & (SymbolFlags.Variable | SymbolFlags.Function) != 0) {
				for (access in symbolAccessMap.getAccess(symbol)) {
					/*
					var fullSymbolChain = access.getFullSymbolChain();
					var parent = fullSymbolChain[fullSymbolChain.length - 2];
					if (parent != null) {
						var hxModule = getHaxeModuleFromDeclarationSymbol(parent, access);
						var moduleField = fieldFromSymbol(symbol, access, null);
						if (moduleField.access != null) {
							moduleField.access.push(AStatic);
						} else {
							moduleField.access = [AStatic];
						}
						hxModule.fields.push(moduleField);
					} else {
						Log.warn('Module field without a parent', symbol);
					}
					*/
				}
				handled = true;
			}

			if (!handled) {
				Log.error('Unhandled symbol in declarationSymbol queue', symbol);
			}
		} 
	}

	/**
		Returns a TypePath for a given symbol.
		The symbol must have flags Type or ValueModule.
		This also queues this symbol's type to be converted if it isn't already
	**/
	public function getReferencedHaxeTypePath(symbol: Symbol, accessContext: SymbolAccess): TypePath {
		var hxTypePath = haxeTypePathMap.getTypePath(symbol, accessContext);
		if (!hxTypePath.isExistingStdLibType) {
			declarationSymbolQueue.tryEnqueue(symbol);
		}
		// if accessContext symbol has the same package as the target symbol, we can shorten the type path by removing the pack
		var noPack = if (shortenTypePaths) {
		var accessSymbolChain = accessContext.extractSymbolChain();
			var lastAccessSymbol = accessSymbolChain[accessSymbolChain.length - 1];
			if (lastAccessSymbol != null) {
				var contextTypePath = haxeTypePathMap.getTypePath(lastAccessSymbol, accessContext);
				contextTypePath.pack.join('.') == hxTypePath.pack.join('.'); // same package context
			} else false;
		} else false;
		return {
			name: hxTypePath.name,
			pack: noPack ? [] : hxTypePath.pack,
		}
	}

	/**
		Symbol must have flags Type | ValueModule
	**/
	function getHaxeModuleFromDeclarationSymbol(symbol: Symbol, access: SymbolAccess): HaxeModule {
		// Log.log('getHaxeModuleFromDeclarationSymbol() <yellow>${access.toString()}</>', symbol);
		var typePath = haxeTypePathMap.getTypePath(symbol, access);
		var moduleKey = getHaxeModuleKey(typePath.pack, typePath.name);
		var pos = TsSymbolTools.getPosition(symbol);

		// type symbols are mutually exclusive so we can return after converting the first match
		var existingModule = generatedModules.get(moduleKey);

		if (existingModule != null) {
			return existingModule;
		}

		var hxModule: HaxeModule = if (symbol.flags & (SymbolFlags.Class | SymbolFlags.Interface) != 0) {
			// Class | Interface | Enum | EnumMember | TypeLiteral | TypeParameter | TypeAlias
			// symbol can have multiple interface declarations so this should not be treated as the main source of information
			// but it might be helpful if node-building is required to provide hints
			
			var classOrInterfaceDeclaration: Null<Node> = cast symbol.getDeclarationsArray().filter(node -> Ts.isInterfaceDeclaration(node) || Ts.isClassDeclaration(node))[0];
			if (classOrInterfaceDeclaration == null) {
				Log.warn('Class|Interface symbol did not have a Class or Interface declaration', symbol);
			}

			var isClassAndInterface = (symbol.flags & SymbolFlags.Interface != 0) && (symbol.flags & SymbolFlags.Class != 0);

			// if it's a class and interface symbol, we use class
			var isInterface = symbol.flags & SymbolFlags.Interface != 0 && !isClassAndInterface;

			var meta = new Array<MetadataEntry>();

			if (!isInterface) {
				meta.push(access.toAccessMetadata());
			}

			if (isClassAndInterface) {
				// in typescript this symbol can be used as a class or an interface
				// we have no way of representing this in haxe yet
				// we add metadata to mark the class which we might be able to use in the future
				// @! maybe we can use an abstract for this
				meta.push({name: ':interface', pos: pos});
				Log.warn('Symbol is both class and an interface, this combination is not fully supported', symbol);
			}

			// class members
			var declaredType: InterfaceType = cast tc.getDeclaredTypeOfSymbol(symbol);
			// validate cast
			if (!declaredType.isClassOrInterface()) {
				Log.error('Internal error: Expected type to be a class or interface type', symbol, declaredType);
			}

			function generateFields(
				constructorSignatures: Array<Signature>,
				callSignatures: Array<Signature>,
				constructSignatures: Array<Signature>,
				indexSignatures: Array<Signature>,
				classMembers: Array<Symbol>
			) {
				var fields = new Array<Field>();
				if (constructorSignatures.length > 0) {
					fields.push(newFieldFromSignatures(constructorSignatures, access, classOrInterfaceDeclaration));
				}

				var callFieldName = symbol.getFreeMemberName(selfCallFunctionName);
				if (callSignatures.length > 0) {
					// Log.log('\t<red>callSignatures <b>${callSignatures.length}</></>', callSignatures[0].declaration);
					fields.push(functionFieldFromCallSignatures(callFieldName, callSignatures, access, classOrInterfaceDeclaration));
				}

				if (symbol.flags & SymbolFlags.Function != 0) {
					Log.warn('todo: handle callable class type 2', symbol);
				}

				if (constructSignatures.length > 0) {
					// this is different from a _constructor_ declaration
					Log.error('Construct signatures are not yet supported', symbol);
				}

				if (indexSignatures.length > 0) {
					// this is different from a _constructor_ declaration
					Log.error('Index signatures are not yet supported', symbol);
				}

				// class-fields
				for (classMember in classMembers) {
					// Log.log('\t<green>classMember</>', classMember);
					fields.push(fieldFromSymbol(classMember, access, classOrInterfaceDeclaration));
				}
				return fields;
			}

			// extends {types}
			var heritageClauses = symbol.getHeritageClauses();
			var extendsTypes = new Array<TypePath>();
			var implementsTypes = new Array<TypePath>();
			for (heritageClause in heritageClauses) {
				var hxTypes = (cast heritageClause.types: Array<ExpressionWithTypeArguments>).map(e -> complexTypeFromTypeNode(e, access, heritageClause.parent)).deduplicateTypes();
				var typePaths = hxTypes.map(t -> switch t {
					case TPath(p): p;
					default: {name: 'Any', pack: []};
				});
				switch heritageClause.token {
					case SyntaxKind.ExtendsKeyword:
						extendsTypes = extendsTypes.concat(typePaths);
					case SyntaxKind.ImplementsKeyword:
						implementsTypes = implementsTypes.concat(typePaths);
					default:
				}
			}

			var kind: TypeDefKind = if (isClassAndInterface) {
				// class + interface is a special case that we cannot trivially handle in haxe
				TDClass(null, implementsTypes, false, false);
			} else if (isInterface) {
				TDClass(null, extendsTypes, isInterface, false);
			} else {
				TDClass(extendsTypes[0], implementsTypes, false, false);
			}

			var fields = if (isClassAndInterface) {
				// class + interface is a special case that we cannot trivially handle in haxe
				// we don't support extends in this case so instead we use all fields of the type
				var indexDeclarations = new Array<typescript.ts.IndexSignatureDeclaration>();
				var numberInfo = tc.getIndexInfoOfType(declaredType, typescript.ts.IndexKind.Number);
				var stringInfo = tc.getIndexInfoOfType(declaredType, typescript.ts.IndexKind.String);
				if (numberInfo != null && numberInfo.declaration != null) indexDeclarations.push(numberInfo.declaration);
				if (stringInfo != null && stringInfo.declaration != null) indexDeclarations.push(stringInfo.declaration);
				generateFields(
					symbol.getConstructorSignatures(tc),
					tc.getSignaturesOfType(declaredType, Call),
					tc.getSignaturesOfType(declaredType, Construct),
					indexDeclarations.map(d -> cast tc.getSignatureFromDeclaration(d)),
					tc.getPropertiesOfType(declaredType).filter(s -> s.isField())
				);
			} else {
				generateFields(
					symbol.getConstructorSignatures(tc),
					symbol.getCallSignatures(tc),
					symbol.getConstructSignatures(tc),
					symbol.getIndexSignatures(tc),
					symbol.getClassMembers()
				);
			}
			
			{
				pack: typePath.pack,
				name: typePath.name,
				fields: fields,
				kind: kind,
				params: typeParamDeclFromTypeDeclarationSymbol(symbol, access, classOrInterfaceDeclaration),
				isExtern: true,
				doc: getDoc(symbol),
				meta: meta,
				pos: pos,
				subTypes: [],
				tsSymbol: symbol,
				tsSymbolAccess: access,
			}
		} else if (symbol.flags & SymbolFlags.Enum != 0) {
			// a ConstEnum does not exist at runtime
			var isCompileTimeEnum = symbol.flags & SymbolFlags.ConstEnum != 0;

			var hxEnumType = complexTypeFromEnumSymbol(symbol);

			var enumMembers = tc.getExportsOfModule(symbol).filter(s -> s.flags & SymbolFlags.EnumMember != 0);
			var hxEnumFields: Array<Field> = enumMembers.map(s -> {
				var safeName = HaxeTools.toSafeIdent(s.name);
				var nameChanged = s.name != safeName;
				return ({
					name: safeName,
					pos: TsSymbolTools.getPosition(s),
					kind: FVar(null, isCompileTimeEnum ? HaxeTools.primitiveValueToExpr(tc.getConstantValue(cast s.valueDeclaration)) : null),
					doc: getDoc(s),
					meta: nameChanged ? [{name: ':native', params: [s.name.toStringExpr(pos)], pos: pos}] : [],
				}: Field);
			});

			{
				pack: typePath.pack,
				name: typePath.name,
				kind: TDAbstract(hxEnumType, [hxEnumType], [hxEnumType]),
				params: [],
				isExtern: true,
				fields: hxEnumFields,
				doc: getDoc(symbol),
				meta: (isCompileTimeEnum ? [] : [access.toAccessMetadata()]).concat([{name: ':enum', pos: pos}]),
				pos: pos,
				subTypes: [],
				tsSymbol: symbol,
				tsSymbolAccess: access,
			}
		} else if (symbol.flags & SymbolFlags.TypeAlias != 0) {
			var typeAliasDeclaration: Null<TypeAliasDeclaration> = cast symbol.getDeclarationsArray().filter(node -> node.kind == SyntaxKind.TypeAliasDeclaration)[0];
			if (typeAliasDeclaration == null) {
				Log.warn('TypeAlias symbol did not have a TypeAliasDeclaration', symbol);
			}

			var tsType = tc.getDeclaredTypeOfSymbol(symbol);
			var hxAliasType = complexTypeFromTsType(tsType, access, typeAliasDeclaration);

			// if this symbol is also a ValueModule then it needs to have fields
			// to enable this, we create a pseudo typedef with an abstract
			var hxTypeDef: HaxeModule = if (symbol.flags & SymbolFlags.ValueModule != 0) {
				pack: typePath.pack,
				name: typePath.name,
				fields: [],
				kind: TDAbstract(hxAliasType, [hxAliasType], [hxAliasType]),
				params: typeParamDeclFromTypeDeclarationSymbol(symbol, access, typeAliasDeclaration), // is there a case where an enum can have a TypeParameter?
				doc: getDoc(symbol),
				isExtern: true,
				meta: [access.toAccessMetadata(), {name: ':forward', pos: pos}, {name: ':forwardStatics', pos: pos}],
				pos: pos,
				subTypes: [],
				tsSymbol: symbol,
				tsSymbolAccess: access,
			} else {
				pack: typePath.pack,
				name: typePath.name,
				fields: [],
				kind: TDAlias(hxAliasType),
				params: typeParamDeclFromTypeDeclarationSymbol(symbol, access, typeAliasDeclaration),
				doc: getDoc(symbol),
				pos: pos,
				subTypes: [],
				tsSymbol: symbol,
				tsSymbolAccess: access,
			}
			hxTypeDef;
		} else if (symbol.flags & SymbolFlags.ValueModule != 0 && symbol.flags & SymbolFlags.Type == 0) {
			// ValueModule-only symbol
			{
				pack: typePath.pack,
				name: typePath.name,
				fields: [],
				kind: TDClass(null, [], false, false),
				params: [],
				isExtern: true,
				doc: getDoc(symbol),
				meta: [access.toAccessMetadata()],
				pos: pos,
				subTypes: [],
				tsSymbol: symbol,
				tsSymbolAccess: access,
			}
		} else {
			Log.error('getHaxeModuleFromDeclarationSymbol(): Unhandled symbol, no flags were recognized', symbol);
			{
				pack: typePath.pack,
				name: typePath.name,
				fields: [],
				kind: TDAlias(macro :Dynamic),
				doc: getDoc(symbol),
				pos: pos,
				subTypes: [],
				tsSymbol: symbol,
				tsSymbolAccess: access,
			}
		}

		// add static fields, including module-member fields
		for (export in symbol.getExports().filter(s -> s.isField())) {
			// Log.log('\t<magenta,b>Export</>', export);
			var field = fieldFromSymbol(export, access, null);
			var access = if (field.access != null) {
				field.access;
			} else {
				field.access = [];
			}
			access.push(AStatic);
			hxModule.fields.push(field);
		}

		var isValueModuleOnlySymbol = symbol.flags & SymbolFlags.ValueModule != 0 && symbol.flags & SymbolFlags.Type == 0;
		var isEmptyValueModuleClass = isValueModuleOnlySymbol && hxModule.fields.length == 0;

		// don't save ValueModule classes with no fields
		if (!isEmptyValueModuleClass) {
			saveHaxeModule(hxModule);
		}

		return hxModule;
	}
	
	/**
		Haxe doesn't support tuple-types so we generate a support type as required
	**/
	function getSupportTupleType(elementTypes: Array<ComplexType>): ComplexType {
		if (elementTypes.length == 0) {
			return macro :Array<Any>;
		}
		var baseType = HaxeTools.commonType(elementTypes);
		var typePath = {
			pack: ['js', 'lib'],
			name: 'Tuple${elementTypes.length}',
			params: [TPType(baseType)].concat(elementTypes.map(t -> TPType(t)))
		};

		var existingModule = generatedModules.get(getHaxeModuleKey(typePath.pack, typePath.name));

		if (existingModule == null) {
			// generate fields
			var fields = new Array<Field>();

			for (i in 0...elementTypes.length) {
				var name = 'element$i';
				var type = TPath({
					name: 'T$i',
					pack: [],
				});
				var get = 'get_$name';
				var set = 'set_$name';
				var indexExpr = HaxeTools.toIntExpr(i);
				fields = fields.concat((macro class {
					public var $name(get, set): $type;
					inline function $get(): $type return cast this[$indexExpr];
					inline function $set(v: $type): $type return cast this[$indexExpr] = cast v;
				}).fields);
			}

			var abstractType = macro :Array<Base>;

			var tupleTypeDefinition: HaxeModule = {
				pack: typePath.pack,
				name: typePath.name,
				kind: TDAbstract(abstractType, [abstractType], [abstractType]),
				params: [{name: 'Base'}].concat([for (i in 0...elementTypes.length) { name: 'T$i', }]),
				fields: fields,
				isExtern: true,
				doc: tool.StringTools.removeIndentation('
					Automatically generated tuple type implementation
					Generated by dts2hx v${Main.dts2hxPackageJson.version}
				').trim(),
				meta: [{name: ':forward', pos: null}, {name: ':forwardStatics', pos: null}],
				pos: null,
				subTypes: [],
				tsSymbol: null,
				tsSymbolAccess: null,
			}

			saveHaxeModule(tupleTypeDefinition);
		}

		return TPath(typePath);
	}

	function getSupportUnionType(types: Array<ComplexType>): ComplexType {
		if (types.length == 0) {
			Log.error('getSupportUnionType(): no types provided');
			debug();
			return macro :Any;
		}
		// here we could generate an advanced union type like we do for tuple but let's save that for another day
		// instead, generate an EitherType stack
		function getEitherUnion(types: Array<ComplexType>): ComplexType {
			return if (types.length == 1) {
				types[0];
			} else {
				TPath({
					name: 'EitherType',
					pack: ['haxe', 'extern'],
					params: [TPType(types[0]), TPType(getEitherUnion(types.slice(1)))],
				});
			}
		}

		return getEitherUnion(types);
	}

	function getGlobalHaxeModule(access: SymbolAccess): HaxeModule {
		throw 'todo';
	}

	/**
		A key that uniquely identifies a haxe module in a haxe project
		Lower case string to represent module file case-insensitive collisions
		`a.b.C` -> `a/b/c`
	**/
	function getHaxeModuleKey(pack: Array<String>, name: String) {
		return pack.concat([name]).map(s -> s.toLowerCase()).join('/');
	}

	function saveHaxeModule(module: HaxeModule) {
		var path = getHaxeModuleKey(module.pack, module.name);

		var existingModule = generatedModules.get(path);
		if (existingModule != null) {
			Log.warn('<b>saveHaxeModule():</> Module <b>"$path"</> has already been generated once and will be overwritten');
			// Log.warn('\t Existing module <yellow,b>${existingModule.tsSymbolAccess.toString()}</>', existingModule.tsSymbol);
			// Log.warn('\t Overwriting module <yellow,b>${access.toString()}</>', symbol);
			// Log.warn('\t All access ' + symbolAccessMap.getAccess(symbol).map(s -> s.toString()));
		}

		if (generatedModules.exists(path)) {
			debug();
		}

		generatedModules.set(path, module);
	}

	function getDoc(symbol: Symbol) {
		var sourceLocationInfo = [];

		if (locationComments) {
			var node = if (symbol.valueDeclaration != null) {
				symbol.valueDeclaration;
			} else {
				symbol.getDeclarationsArray()[0];
			}

			if (node != null) {
				var sourceFile = node.getSourceFile();
				if (sourceFile != null) {
					var start = node.getStart();
					var lineAndCharacter = sourceFile.getLineAndCharacterOfPosition(start);
					var line = lineAndCharacter.line;
					var character = lineAndCharacter.line;
					sourceLocationInfo.push('${cwdRelativeFilePath(sourceFile.fileName)}:${line + 1}${character > 0 ? ':${character + 1}' : ''}');
				}
			}
		}

		return symbol.getDocumentationComment(tc)
			.map(s -> s.text.trim())
			.concat(sourceLocationInfo)
			.join('\n\n');
	}

	/**
		`accessContext` is the symbol access path for the symbol that contains this type reference
		This is required because if we're in a Global access context, type references should prefer global access (and modular context should prefer modular access).
		For example, in node.js there's a type `EventEmitter` that has both global (`NodeJS.EventEmitter` and modular access `require("event").EventEmitter`)
		If `EventEmitter` is referenced by another globally accessible type, then this method should return the global haxe type, and same logic for modular
	**/
	function complexTypeFromTypeNode(node: TypeNode, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		var type = tc.getTypeFromTypeNode(node);
		if (untyped type.intrinsicName == 'error') {
			debug();
			Log.error('Internal error: Error getting type from type node', node);
		}
		return complexTypeFromTsType(type, accessContext, enclosingDeclaration);
	}
	
	var _currentTypeStack: Array<TsType> = [];
	function complexTypeFromTsType(type: TsType, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		if (_currentTypeStack.indexOf(type) != -1) {
			Log.log('Breaking recursive type conversion with :Any', type);
			return macro :Any;
		}

		_currentTypeStack.push(type);
		// Log.log('complexTypeFromTsType <b>${_currentTypeStack.length}</>');
		// for (t in _currentTypeStack) {
		// 	Log.log('\t<dim,i>${untyped t.id}</>', t);
		// }

		// handle fundamental type flags
		var complexType = if (type.flags & (TypeFlags.Any) != 0) {
			macro :Any;
		} else if (type.flags & TypeFlags.Unknown != 0) {
			// we can't really represent `unknown` in haxe at the moment
			macro :Any;
		} else if (type.flags & (TypeFlags.String) != 0) {
			macro :String;
		} else if (type.flags & (TypeFlags.Number) != 0) {
			macro :Float;
		} else if (type.flags & (TypeFlags.Boolean) != 0) {
			macro :Bool;
		} else if (type.flags & (TypeFlags.VoidLike | TypeFlags.Never) != 0) {
			macro :Void;
		} else if (type.flags & (TypeFlags.Union) != 0) {
			complexTypeFromUnionType(cast type, accessContext, enclosingDeclaration);
		}
		// @! it would be nice to use an enum-generating support type so we can preserve values of literals, but for now we can use the literal's type
		else if (type.flags & (TypeFlags.StringLiteral) != 0) {
			macro :String;
		} else if (type.flags & (TypeFlags.NumberLiteral) != 0) {
			var numberLiteral: NumberLiteralType = cast type;
			var value: Float = cast numberLiteral.value;
			var isInt = Std.int(value) == value;
			isInt ? macro :Int : macro :Float;
		} else if (type.flags & (TypeFlags.BooleanLiteral) != 0) {
			macro :Bool;
		} else if (type.flags & (TypeFlags.TypeParameter) != 0) {
			complexTypeFromTypeParameter(cast type, accessContext, enclosingDeclaration);
		} else if (type.flags & (TypeFlags.Object) != 0) {
			complexTypeFromObjectType(cast type, accessContext, enclosingDeclaration);
		} else {
			// @! todo:
			// Enum            = 1 << 5,
			// BigInt          = 1 << 6,
			// EnumLiteral     = 1 << 10,  // Always combined with StringLiteral, NumberLiteral, or Union
			// BigIntLiteral   = 1 << 11,
			// ESSymbol        = 1 << 12,  // Type of symbol primitive introduced in ES6
			// UniqueESSymbol  = 1 << 13,  // unique symbol
			// Intersection    = 1 << 21,  // Intersection (T & U)
			// Index           = 1 << 22,  // keyof T
			// IndexedAccess   = 1 << 23,  // T[K]
			// Conditional     = 1 << 24,  // T extends U ? X : Y
			// Substitution    = 1 << 25,  // Type parameter substitution
			// NonPrimitive    = 1 << 26,  // intrinsic object type

			Log.error('Could not convert type', type);
			macro :Any;
		}

		_currentTypeStack.pop();

		return complexType;
	}

	function complexTypeFromUnionType(unionType: UnionType, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		// if union has null, undefined filter out and consider type as nullable
		var typesWithoutNullable = unionType.types.filter(t -> t.flags & (TypeFlags.Null | TypeFlags.Undefined) == 0);
		var nullable = typesWithoutNullable.length != unionType.types.length;
		// convert union's TsTypes to haxe ComplexTypes
		var hxTypes = typesWithoutNullable.map(t -> complexTypeFromTsType(t, accessContext, enclosingDeclaration)).deduplicateTypes();
		// if union is of length 1, no need for support type
		var unionType = switch hxTypes.length {
			case 0: macro :Any;
			case 1: hxTypes[0];
			default: getSupportUnionType(hxTypes);
		}
		return nullable ? macro :Null<$unionType> : macro :$unionType;
	}

	function complexTypeFromTypeParameter(typeParameter: TypeParameter, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		return if (typeParameter.symbol != null) {
			// there's also a variation `IndexedAccessType` that's not currently handled
			// `: this` seems to need special handling
			var isThisType: Bool = untyped typeParameter.isThisType;
			var constraint: Null<TsType> = untyped typeParameter.constraint;
			if (isThisType && constraint != null) {
				complexTypeFromTsType(constraint, accessContext, enclosingDeclaration);
			} else {
				TPath({
					name: typeParameter.symbol.name.toSafeTypeName(),
					pack: [],
				});
			}
		} else {
			Log.error('Internal error: Failed to determine type parameter name, using `T`', typeParameter);
			macro :T;
		}
	}

	function complexTypeFromObjectType(objectType: ObjectType, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		// @! todo:
		// Mapped           = 1 << 5,  // Mapped
		// Instantiated     = 1 << 6,  // Instantiated anonymous or mapped type
		// ObjectLiteral    = 1 << 7,  // Originates in an object literal
		// EvolvingArray    = 1 << 8,  // Evolving array type
		// ObjectLiteralPatternWithComputedProperties = 1 << 9,  // Object literal pattern with computed properties
		// ContainsSpread   = 1 << 10, // Object literal contains spread operation
		// ReverseMapped    = 1 << 11, // Object contains a property from a reverse-mapped type
		// JsxAttributes    = 1 << 12, // Jsx attributes type
		// MarkerType       = 1 << 13, // Marker type used for variance probing
		// JSLiteral        = 1 << 14, // Object type declared in JS - disables errors on read/write of nonexisting members
		// FreshLiteral     = 1 << 15, // Fresh object literal
		// ArrayLiteral     = 1 << 16, // Originates in an array literal
		// ObjectRestType   = 1 << 17, // Originates in object rest declaration

		return if ((objectType.objectFlags & ObjectFlags.Reference) != 0) {
			complexTypeFromTypeReference(cast objectType, accessContext, enclosingDeclaration);
		} else if (objectType.objectFlags & ObjectFlags.ClassOrInterface != 0) {
			complexTypeFromInterfaceType(cast objectType, accessContext, enclosingDeclaration);
		} else if (objectType.objectFlags & ObjectFlags.Anonymous != 0) {
			/** 
				In typescript, function types have the object flag 'Anonymous' because they're actually represented as the call signatures of anons
				```typescript
				let f: (a: number): string
				// is actually represented as
				let f: { (a: number): string }
				```
			**/

			var typeFields = tc.getPropertiesOfType(objectType).filter(s -> s.isField());
			var callSignatures = objectType.getCallSignatures();
			var constructSignatures = objectType.getConstructSignatures();

			if (objectType.getConstructSignatures().length > 0) {
				Log.warn('Type has construct signature but this is currently unhandled', objectType);
			}

			// for the special case of a single call signature and no props we can return a function type
			if (callSignatures.length == 1 && constructSignatures.length == 0 && typeFields.length == 0) {
				complexTypeFromCallSignature(objectType.getCallSignatures()[0], accessContext, enclosingDeclaration);
			} else {
				var fields = new Array<Field>();

				/**
					When a type has multiple signatures we can use a trick: wrap them in an object and adding @:selfCall
					For example:
					var x: {
						@:selfCall
						@:overload(function (a: Int): Void {})
						function call(): Void;
					}
					Then to use overloads, you can do, `x.call(3)` and this compiles to `x(3)`
				**/
				if (callSignatures.length > 0) {
					var callFieldName = TsTypeTools.getFreePropertyName(tc, objectType, selfCallFunctionName);
					fields.push(functionFieldFromCallSignatures(callFieldName, callSignatures, accessContext, enclosingDeclaration));
				}

				// add properties
				fields = fields.concat(typeFields.map(p -> fieldFromSymbol(p, accessContext, enclosingDeclaration)));

				TAnonymous(fields);
			}
		} else {
			Log.error('Could not convert object type <b>${objectType.getObjectFlagsInfo()}</b> ${objectType.objectFlags}', objectType);
			// debug();
			macro :Any;
		}
	}

	function functionFieldFromCallSignatures(fieldName: String, callSignatures: Array<Signature>, accessContext: SymbolAccess, ?enclosingDeclaration: Node): Field {
		var field = functionFieldFromSignatures(fieldName, callSignatures, accessContext, enclosingDeclaration);
		var metas = if (field.meta != null) field.meta else {
			field.meta = [];
		}
		metas.push({ name: ':selfCall', pos: null });
		return field;
	}

	function functionFieldFromSignatures(fieldName: String, signatures: Array<Signature>, accessContext: SymbolAccess, ?enclosingDeclaration: Node): Field {
		var baseSignature = signatures[0];
		var overloadSignatures = signatures.slice(1);
		var overloadMetas = overloadSignatures.map(signature -> {
			var fun = functionFromSignature(signature, accessContext, enclosingDeclaration);
			fun.expr = macro {};
			return ({
				name: ':overload',
				params: [{
					expr: EFunction(FAnonymous, fun),
					pos: null,
				}],
				pos: null,
			}: MetadataEntry);
		});
		return {
			name: fieldName,
			meta: overloadMetas,
			kind: FFun(functionFromSignature(baseSignature, accessContext, enclosingDeclaration)),
			pos: null,
		};
	}

	function newFieldFromSignatures(signatures: Array<Signature>, accessContext: SymbolAccess, ?enclosingDeclaration: Node): Field {
		var field = functionFieldFromSignatures('new', signatures, accessContext, enclosingDeclaration);
		// remove return type and type parameters?
		switch field.kind {
			case FFun(fun):
				fun.ret = null;
				fun.params = null;
			default:
		}
		return field;
	}

	function complexTypeFromCallSignature(callSignature: Signature, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		// haxe doesn't support type-parameters on function types, e.g.
		// `let fun: <T>(a: T) -> void`
		// so we must replace instances of T with Any, but only when it's a local type parameter
		var params = callSignature.getTypeParameters();
		var tsTypeParams: Array<TypeParameter> = params != null ? params : [];
		inline function isLocalTypeParam(type: TsType) {
			return tsTypeParams.indexOf(type) != -1;
		}

		var hxParameters: Array<ComplexType> = callSignature.parameters.map(s -> {
			var tsType = tc.getTypeAtLocation(s.valueDeclaration);

			var hxType = if (isLocalTypeParam(tsType)) {
				macro : Any;
			} else {
				complexTypeFromTsType(tsType, accessContext, enclosingDeclaration);
			}

			return TNamed(s.name.toSafeIdent(), hxType);
		});

		var tsRet = tc.getReturnTypeOfSignature(callSignature);

		var hxRet = if (isLocalTypeParam(tsRet)) {
			macro : Any;
		} else {
			complexTypeFromTsType(tc.getReturnTypeOfSignature(callSignature), accessContext, enclosingDeclaration);
		}

		// callSignature.typeParameters
		return TFunction(hxParameters, hxRet);
	}

	function complexTypeFromTypeReference(typeReference: TypeReference, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		// determine reference sub-type
		return if ((typeReference.objectFlags & ObjectFlags.ClassOrInterface) != 0) {
			complexTypeFromGenericType(cast typeReference, accessContext, enclosingDeclaration);
		} else if ((typeReference.target.objectFlags & ObjectFlags.Tuple != 0)) {
			// it's a TupleTypeReference if its target is a Tuple
			complexTypeFromTupleTypeReference(cast typeReference, accessContext, enclosingDeclaration);
		} else {
			if (typeReference.target == cast typeReference) { // avoid direct cycles
				// this can happen with TupleReferences and GenericTypes but we shouldn't get this 
				Log.error('Internal error: recursive type reference');
				return macro :Any;
			}
			
			var hxTarget = complexTypeFromTsType(cast typeReference.target, accessContext, enclosingDeclaration);

			var hxTypeArguments = if (typeReference.typeArguments != null) {
				typeReference.typeArguments.map(arg -> TPType(complexTypeFromTsType(arg, accessContext, enclosingDeclaration)));
			} else [];

			// replace type parameters with type arguments
			switch hxTarget {
				case TPath(p):
					var argumentCount = hxTypeArguments.length;
					var paramCount = p.params != null ? p.params.length : 0;
					if (paramCount != argumentCount) {
						Log.warn('TypeReference has <b>$argumentCount</> arguments but target has <b>$paramCount</> parameters', typeReference);
					}
					p.params = hxTypeArguments;
				default: Log.error('Internal error: Expected TPath from TypeReference', typeReference);
			}
			hxTarget;
		}
	}

	function complexTypeFromTupleTypeReference(tupleTypeReference: TupleTypeReference, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		var hxElementTypes = tupleTypeReference.typeArguments.map(t -> complexTypeFromTsType(t, accessContext, enclosingDeclaration));
		return getSupportTupleType(hxElementTypes);
	}

	/**
		While a GenericType could include the full type definition because the return is ComplexType we just return a TPath()
	**/
	function complexTypeFromGenericType(genericType: GenericType & TypeReference, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		// sub-type of GenericType
		return if (genericType.objectFlags & ObjectFlags.Tuple != 0) {
			complexTypeFromTupleType(cast genericType, accessContext, enclosingDeclaration);
		} else {
			complexTypeFromInterfaceType(genericType, accessContext, enclosingDeclaration);
		}
	}

	function complexTypeFromTupleType(tupleType: TupleType, accessContext: SymbolAccess, ?enclosingDeclaration: Node) {
		Log.warn('Todo: TupleType', tupleType);
		// need an example where this path is hit
		debug();
		return macro :Array<Any>;
	}

	function complexTypeFromInterfaceType(classOrInterfaceType: InterfaceType, accessContext: SymbolAccess, ?enclosingDeclaration: Node): ComplexType {
		return if (classOrInterfaceType.symbol != null) {
			var hxTypePath = getReferencedHaxeTypePath(classOrInterfaceType.symbol, accessContext);
			hxTypePath.params = if (classOrInterfaceType.typeParameters != null) {
				classOrInterfaceType.typeParameters.map(t -> TPType(complexTypeFromTypeParameter(t, accessContext, enclosingDeclaration)));
			} else null;
			TPath(hxTypePath);
		} else {
			Log.error('Internal error: no symbol for ClassOrInterface type', classOrInterfaceType);
			debug();
			macro :Any;
		}
	}

	function complexTypeFromEnumSymbol(symbol: Symbol): ComplexType {
		var hxEnumTypeName: Null<String> = null;
		// determine underlying type of enum by iterating its members
		var enumMembers = tc.getExportsOfModule(symbol).filter(s -> s.flags & SymbolFlags.EnumMember != 0);
		for (member in enumMembers) {
			var enumMemberNode = member.valueDeclaration;
			var runtimeValue = tc.getConstantValue(cast enumMemberNode);
			var hxMemberTypeName = switch js.Syntax.typeof(cast runtimeValue) {
				// enums are implicitly ints by default
				case 'undefined': 'Int';
				case 'number': 
					Math.floor(cast runtimeValue) == runtimeValue ? 'Int' : 'Float';
				case 'string': 'String';
				default: 'Any';
			}

			// compare this member type with the currently set hxEnumType
			// and handle Int -> Float cast
			if (hxEnumTypeName != hxMemberTypeName) {
				hxEnumTypeName = switch [hxEnumTypeName, hxMemberTypeName] {
					case [null, _]: hxMemberTypeName;
					case ['Int', 'Float']: 'Float';
					case ['Float', 'Int']: 'Float';
					default: 'Any';
				}
			}
		}

		return if (hxEnumTypeName != null) {
			TPath({pack: [], name: cast hxEnumTypeName});
		} else {
			TPath({pack: [], name: 'Any'});
		}
	}

	/**
		Valid symbol flags
		- `Property`
		- `Method`
	**/
	function fieldFromSymbol(symbol: Symbol, accessContext: SymbolAccess, ?enclosingDeclaration: Node): Field {
		var pos = symbol.getPosition();
		var meta = new Array<MetadataEntry>();
		var safeName = symbol.name.toSafeIdent();
		var nameChanged = safeName != symbol.name;

		if (nameChanged) {
			meta.push({name: ':native', pos: pos, params: [HaxeTools.toStringExpr(symbol.name, pos)]});
		}

		if (symbol.flags & SymbolFlags.Optional != 0) {
			meta.push({name: ':optional', pos: pos});
		}

		var userDoc = getDoc(symbol);
		var docParts = userDoc != '' ? [userDoc] : [];

		// add errors to field docs
		function onError(message) {
			Log.error('fieldFromSymbol(): ' + message, symbol);
			docParts.push('@DTS2HX-ERROR: ${Console.stripFormatting(message)}');
		}
		
		var kind = if (symbol.flags & SymbolFlags.Prototype != 0) {
			// Prototype symbol should be filtered out of properties before converting to hx fields
			Log.error('Internal error: Prototype symbol should not be converted to a field', symbol);
			debug();
			FVar(macro :Any, null);

		} else if (symbol.flags & (SymbolFlags.Property | SymbolFlags.Variable) != 0) {
			if (symbol.valueDeclaration == null) {
				Log.error('Missing valueDeclaration for Property | Variable symbol', symbol);
				debug();
			} else {
				// variable field
				switch symbol.valueDeclaration.kind {
					case VariableDeclaration, PropertySignature, PropertyDeclaration:
					default: 
						onError('Unhandled declaration kind <b>${TsSyntaxTools.getSyntaxKindName(symbol.valueDeclaration.kind)}</>');
				}
			}


			var type = tc.getTypeAtLocation(symbol.valueDeclaration);
			var hxType = complexTypeFromTsType(type, accessContext, enclosingDeclaration);
			FVar(hxType, null);

		} else if (symbol.flags & (SymbolFlags.Method | SymbolFlags.Function) != 0) {
			// function field
			var baseDeclaration = symbol.valueDeclaration;
			var overloadDeclarations = symbol.declarations.filter(d -> d != baseDeclaration && switch d.kind {
				case MethodSignature, MethodDeclaration, FunctionDeclaration: true;
				case ModuleDeclaration: false;
				default:
					onError('Unhandled declaration kind <b>${TsSyntaxTools.getSyntaxKindName(d.kind)}</>');
					false;
			});

			for (overloadDeclaration in overloadDeclarations) {
				var signature = tc.getSignatureFromDeclaration(cast overloadDeclaration);
				if (signature == null) {
					onError('Signature was null');
					continue;
				}
				var fun = functionFromSignature(signature, accessContext, enclosingDeclaration);
				// overloads require an empty expression
				fun.expr = macro {};
				meta.push({
					name: ':overload',
					pos: pos,
					params: [{
						expr: EFunction(FAnonymous, fun),
						pos: pos,
					}]
				});
			}

			var signature = tc.getSignatureFromDeclaration(cast baseDeclaration);
			if (signature != null) {
				// haxe use overload metadata to handle multiple declarations
				FFun(functionFromSignature(signature, accessContext, enclosingDeclaration));
			} else {
				onError('Signature was null');
				FFun({
					args: [],
					ret: macro :Any,
					params: [],
					expr: null,
				});
			}

		} else {

			onError('Unhandled symbol flags');
			var type = tc.getTypeOfSymbolAtLocation(symbol, symbol.valueDeclaration);
			debug();
			FVar(macro :Any, null);

		}

		return {
			name: safeName,
			meta: meta,
			pos: pos,
			kind: kind,
			doc: docParts.join('\n\n'),
		};
	}

	function functionFromSignature(signature: Signature, accessContext: SymbolAccess, ?enclosingDeclaration: Node): Function {
		var hxTypeParams = if (signature.typeParameters != null) signature.typeParameters.map(t -> typeParamDeclFromTsTypeParameter(t, accessContext, enclosingDeclaration)) else [];

		var hxParameters = if (signature.parameters != null ) signature.parameters.map(s -> {
			var parameterDeclaration: ParameterDeclaration = cast s.valueDeclaration;
			var tsType = tc.getTypeAtLocation(parameterDeclaration);
			var hxType = complexTypeFromTsType(tsType, accessContext, enclosingDeclaration);
			var isOptional = tc.isOptionalParameter(parameterDeclaration);
			if (isOptional) {
				hxType = HaxeTools.unwrapNull(hxType);
			}
			// I don't think d.ts files allow default values for parameters but we'll keep this here anyway
			var value = HaxeTools.primitiveValueToExpr(tc.getConstantValue(parameterDeclaration));
			return ({
				name: s.name.toSafeIdent(),
				type: hxType,
				opt: isOptional,
				value: value
			}: FunctionArg);
		}) else [];

		var hxRet = complexTypeFromTsType(tc.getReturnTypeOfSignature(signature), accessContext, enclosingDeclaration);

		return {
			args: hxParameters,
			ret: hxRet,
			params: hxTypeParams,
			expr: null,
		}
	}

	/**
		Given a symbol with type-parameter declarations, e.g. `class X<T extends number>`, return the haxe type-parameter declaration equivalent
		Symbol must declare a `Class`, `Interface` or `TypeAlias`
	**/
	function typeParamDeclFromTypeDeclarationSymbol(symbol: Symbol, accessContext: SymbolAccess, ?enclosingDeclaration: Node): Array<TypeParamDecl> {
		var tsTypeParameterDeclarations = new Array<TypeParameterDeclaration>();
		if (symbol.flags & (SymbolFlags.Class | SymbolFlags.Interface | SymbolFlags.TypeAlias) == 0) {
			Log.error('Internal error: typeParamDeclFromTypeDeclarationSymbol() unexpected symbol flags; expected Class, Interface or TypeAlias', symbol);
		}

		for (declaration in symbol.declarations) {
			// find the first declaration with more than 0 type parameters
			// here we make the assumption that all declarations have the same type parameters
			
			var declarationTypeParameters = Ts.getEffectiveTypeParameterDeclarations(cast declaration);

			// validate the assumption that all declarations have the same type-parameters
			if (tsTypeParameterDeclarations.length > 0 && declarationTypeParameters.length > 0) {
				if (tsTypeParameterDeclarations.length != declarationTypeParameters.length) {
					Log.warn('Symbol declarations have varying number of type-parameters; this is not expected', symbol);
				}
			}

			if (declarationTypeParameters.length > 0) {
				tsTypeParameterDeclarations = declarationTypeParameters;
			}
		}

		return [for (t in tsTypeParameterDeclarations) {
			name: TsSyntaxTools.typeParameterDeclarationName(t),
			constraints: t.constraint != null ? [complexTypeFromTypeNode(t.constraint, accessContext, enclosingDeclaration)] : []
		}];
	}

	function typeParamDeclFromTsTypeParameter(typeParameter: TypeParameter, accessContext: SymbolAccess, ?enclosingDeclaration: Node): TypeParamDecl {
		// for some reason typeParameter.getConstraint() has issues
		// in the following class field `parse<X extends Example>(a: T): void;`, the constraint `Example` is reported as having typeArguments when it doesn't
		var typeParamNode: Null<TypeParameterDeclaration> = cast typeParameter.symbol.declarations.find(d -> d.kind == TypeParameter);
		var hxConstraint = if (typeParamNode != null && typeParamNode.constraint != null ) {
			complexTypeFromTypeNode(typeParamNode.constraint, accessContext, enclosingDeclaration);
		} else null;
		return {
			name: typeParameter.symbol.name.toSafeTypeName(),
			constraints: hxConstraint != null ? [hxConstraint] : null,
		}
	}

	/**
		Remove @types prefix, convert backslashes to forward slashes and make path relative to cwd.
		Examples:
		- `@types/lib` -> `lib` 
		- `.\modules\example` -> `./modules/example`
		- `/Users/X/modules/example/` -> `./modules/example`
	**/
	function normalizeModuleName(moduleName: String) {
		// make absolute paths into paths relative to the cwd
		if (TsProgramTools.isDirectPathReferenceModule(moduleName)) {
			moduleName = cwdRelativeFilePath(moduleName);
		}

		// replace backslashes with forward slashes to normalize for windows paths
		moduleName.replace('\\', '/');
		var moduleNameParts = moduleName.split('/');
		// remove @types prefix
		if (moduleNameParts[0] == '@types' && moduleNameParts.length > 1) {
			moduleNameParts.shift();
		}
		return moduleNameParts.join('/');
	}

	inline function cwdRelativeFilePath(path: String): String {
		return TsInternal.convertToRelativePath(path, host.getCurrentDirectory(), host.getCanonicalFileName);
	}

	/**
		NodeBuilding generally causes problems so be very careful if you need to use this
	**/
	static final defaultNodeBuilderFlags =
		NodeBuilderFlags.NoTruncation | // truncation prevents expanding deeply nested nodes, we always want to expand completely
		NodeBuilderFlags.WriteArrayAsGenericType // Write Array<T> instead T[]
	;

	static final selfCallFunctionName = 'call';

}

typedef ConvertedTypeDefinition = TypeDefinition & {
	tsSymbol: Null<Symbol>,
	tsSymbolAccess: Null<SymbolAccess>,
}

typedef HaxeModule = ConvertedTypeDefinition & {
	subTypes: Array<ConvertedTypeDefinition>,
}

/**
	Notes
	-----

	**Documentation Links**
	- [TypeScript AST Viewer](https://ts-ast-viewer.com/)
	- [Architectural-Overview](https://github.com/microsoft/TypeScript/wiki/Architectural-Overview)
	- [Using the type checker](https://github.com/microsoft/TypeScript/wiki/Using-the-Compiler-API#using-the-type-checker)
	- [Language Specification](https://github.com/microsoft/TypeScript/blob/master/doc/spec.md)
	- [Compiler Internals Book](https://basarat.gitbooks.io/typescript/docs/compiler/overview.html)
	- See [src/compiler/utilities.ts](https://github.com/microsoft/TypeScript/blob/d6c05a135840dc3045ec8f3bbec1da5ffabb6593/src/compiler/utilities.ts) for compiler API use examples
	- See [src/compiler/vistorPublic.ts](https://github.com/microsoft/TypeScript/blob/master/src/compiler/visitorPublic.ts) for an example of fully enumerating the AST

	**Declaration**
	Declarations can assign a name to a *type*, *value* and *namespace*. A single name may have be used for all of these

	**Modules** vs **Namespaces** and **"External Modules"**
	- The form `declare module Name` is deprecated and equivalent to `declare namespace Name`. This creates an ambient namespace
	- The correct use of `declare module` is with quotes: `declare module "name"`. This declares an **external** (ES6 module)
	- "In TypeScript, just as in ECMAScript 2015, any file containing a top-level import or export is considered a module. Conversely, a file without any top-level import or export declarations is treated as a script whose contents are available in the global scope (and therefore to modules as well)." https://www.typescriptlang.org/docs/handbook/modules.html
	- https://stackoverflow.com/questions/41932585/what-is-the-difference-between-declare-namespace-and-declare-module
	- See https://stackoverflow.com/questions/32531405/why-does-importing-a-node-module-break-my-internal-typescript-namespaces-in-atom

	**Symbols**
	In the typescript compiler, declarations are grouped into Symbols. A Symbol can have 3 kinds of declaration, as a Type, a Variable/Function and a Module.
	For example, the following declarations are grouped into one symbol with the name 'Example'
	```typescript
	// Symbol Example with 3 declarations
	declare const Example: string;    // Value named X
	declare type Example = number;  // Type named X
	declare namespace Example {     // Namespace named X  
				type Y = string;  
	}

	// Symbol X, with 4 declarations
	declare interface X { field1: number; } // interfaces merge
	declare interface X { field2: number; }
	declare class X { constructor() {} }
	declare namespace X { const field3: number; }
	// use X as a class, interface and value-module
	class Y extends X implements X {
		field1: number = 1;
		field2: number = X.field3;
	}
	```

	See https://github.com/microsoft/TypeScript/blob/master/doc/spec.md#23-declarations

	**SymbolAccess**
	The reason we track symbol access rather than always using the sourceFile of the symbol's declaration in is because doing so can lead to runtime errors in some cases
	For example, the following typescript program fails at both runtime and compiletime:

	```typescript
	// import via module root
	import * as THREE from 'three';
	console.log(new THREE.Quaternion(1,2,3,4));
	// import via source file that the symbol is defined in
	import { Quaternion } from './node_modules/three/src/math/Quaternion';
	// ^ import { _Math } from './Math.js'; SyntaxError: Unexpected token {
	console.log(new Quaternion(1,2,3,4));
	```

	The failure is because THREE.Quaternion is accessed from the bundled es5 javascript, whereas the source file Quaternion.js. Moreover, if we have require('three') alongside require('three/src/math/quaternion') then we have two implementations of Quaternion

	On the other hand, it's possible that importing from the individual source files (rather than module) could lead to smaller bundled code because unused code isn't imported.
	I may add an option for this in the future.

	**SymbolFlags**
	https://github.com/microsoft/TypeScript/blob/0ae938b718bae3367bff26369adac1ecef56f212/src/compiler/types.ts#L4007
	```typescript
	enum SymbolFlags {
		None                    = 0,
		FunctionScopedVariable  = 1 << 0,   // Variable (var) or parameter
		BlockScopedVariable     = 1 << 1,   // A block-scoped variable (let or const)
		Property                = 1 << 2,   // Property or enum member
		EnumMember              = 1 << 3,   // Enum member
		Function                = 1 << 4,   // Function
		Class                   = 1 << 5,   // Class
		Interface               = 1 << 6,   // Interface
		ConstEnum               = 1 << 7,   // Const enum
		RegularEnum             = 1 << 8,   // Enum
		ValueModule             = 1 << 9,   // Instantiated module
		NamespaceModule         = 1 << 10,  // Uninstantiated module
		TypeLiteral             = 1 << 11,  // Type Literal or mapped type
		ObjectLiteral           = 1 << 12,  // Object Literal
		Method                  = 1 << 13,  // Method
		Constructor             = 1 << 14,  // Constructor
		GetAccessor             = 1 << 15,  // Get accessor
		SetAccessor             = 1 << 16,  // Set accessor
		Signature               = 1 << 17,  // Call, construct, or index signature
		TypeParameter           = 1 << 18,  // Type parameter
		TypeAlias               = 1 << 19,  // Type alias
		ExportValue             = 1 << 20,  // Exported value marker (see comment in declareModuleMember in binder)
		Alias                   = 1 << 21,  // An alias for another symbol (see comment in isAliasSymbolDeclaration in checker)
		Prototype               = 1 << 22,  // Prototype property (no source representation)
		ExportStar              = 1 << 23,  // Export * declaration
		Optional                = 1 << 24,  // Optional property
		Transient               = 1 << 25,  // Transient symbol (created during type check)
		Assignment              = 1 << 26,  // Assignment treated as declaration (eg `this.prop = 1`)
		ModuleExports           = 1 << 27,  // Symbol for CommonJS `module` of `module.exports`

		Enum = RegularEnum | ConstEnum,
		Variable = FunctionScopedVariable | BlockScopedVariable,
		Value = Variable | Property | EnumMember | ObjectLiteral | Function | Class | Enum | ValueModule | Method | GetAccessor | SetAccessor,
		Type = Class | Interface | Enum | EnumMember | TypeLiteral | TypeParameter | TypeAlias,
		Namespace = ValueModule | NamespaceModule | Enum,
		Module = ValueModule | NamespaceModule,
		Accessor = GetAccessor | SetAccessor,

		ModuleMember = Variable | Function | Class | Interface | Enum | Module | TypeAlias | Alias,

		ExportHasLocal = Function | Class | Enum | ValueModule,

		BlockScoped = BlockScopedVariable | Class | Enum,

		PropertyOrAccessor = Property | Accessor,

		ClassMember = Method | Accessor | Property,

		// @internal
		ExportSupportsDefaultModifier = Class | Function | Interface,

		// @internal
		ExportDoesNotSupportDefaultModifier = ~ExportSupportsDefaultModifier,

		// @internal
		// The set of things we consider semantically classifiable.  Used to speed up the LS during
		// classification.
		Classifiable = Class | Enum | TypeAlias | Interface | TypeParameter | Module | Alias,

		// @internal
		LateBindingContainer = Class | Interface | TypeLiteral | ObjectLiteral | Function,
	}
	```

	**Alias Symbols**
	An 'alias symbol' is different from a TypeAlias and is created by one of the following declarations:
	```typescript
	import <symbol> = ...
	import <symbol> from ...
	import * as <symbol> from ...
	import { x as <symbol> } from ...
	export { x as <symbol> } from ...
	export * as ns <symbol> from ...
	export = <EntityNameExpression>
	export default <EntityNameExpression>
	module.exports = <EntityNameExpression>
	{<Identifier>}
	{name: <EntityNameExpression>}
	```
	
	For a discussion on the different types of exports and imports
	https://github.com/microsoft/TypeScript/issues/7185#issuecomment-421632656

	**Type Flags**
	```typescript
	export const enum TypeFlags {
        Any             = 1 << 0,
        Unknown         = 1 << 1,
        String          = 1 << 2,
        Number          = 1 << 3,
        Boolean         = 1 << 4,
        Enum            = 1 << 5,
        BigInt          = 1 << 6,
        StringLiteral   = 1 << 7,
        NumberLiteral   = 1 << 8,
        BooleanLiteral  = 1 << 9,
        EnumLiteral     = 1 << 10,  // Always combined with StringLiteral, NumberLiteral, or Union
        BigIntLiteral   = 1 << 11,
        ESSymbol        = 1 << 12,  // Type of symbol primitive introduced in ES6
        UniqueESSymbol  = 1 << 13,  // unique symbol
        Void            = 1 << 14,
        Undefined       = 1 << 15,
        Null            = 1 << 16,
        Never           = 1 << 17,  // Never type
        TypeParameter   = 1 << 18,  // Type parameter
        Object          = 1 << 19,  // Object type
        Union           = 1 << 20,  // Union (T | U)
        Intersection    = 1 << 21,  // Intersection (T & U)
        Index           = 1 << 22,  // keyof T
        IndexedAccess   = 1 << 23,  // T[K]
        Conditional     = 1 << 24,  // T extends U ? X : Y
        Substitution    = 1 << 25,  // Type parameter substitution
        NonPrimitive    = 1 << 26,  // intrinsic object type

        // @internal
        AnyOrUnknown = Any | Unknown,
        // @internal
        Nullable = Undefined | Null,
        Literal = StringLiteral | NumberLiteral | BigIntLiteral | BooleanLiteral,
        Unit = Literal | UniqueESSymbol | Nullable,
        StringOrNumberLiteral = StringLiteral | NumberLiteral,
        // @internal
        StringOrNumberLiteralOrUnique = StringLiteral | NumberLiteral | UniqueESSymbol,
        // @internal
        DefinitelyFalsy = StringLiteral | NumberLiteral | BigIntLiteral | BooleanLiteral | Void | Undefined | Null,
        PossiblyFalsy = DefinitelyFalsy | String | Number | BigInt | Boolean,
        // @internal
        Intrinsic = Any | Unknown | String | Number | BigInt | Boolean | BooleanLiteral | ESSymbol | Void | Undefined | Null | Never | NonPrimitive,
        // @internal
        Primitive = String | Number | BigInt | Boolean | Enum | EnumLiteral | ESSymbol | Void | Undefined | Null | Literal | UniqueESSymbol,
        StringLike = String | StringLiteral,
        NumberLike = Number | NumberLiteral | Enum,
        BigIntLike = BigInt | BigIntLiteral,
        BooleanLike = Boolean | BooleanLiteral,
        EnumLike = Enum | EnumLiteral,
        ESSymbolLike = ESSymbol | UniqueESSymbol,
        VoidLike = Void | Undefined,
        // @internal
        DisjointDomains = NonPrimitive | StringLike | NumberLike | BigIntLike | BooleanLike | ESSymbolLike | VoidLike | Null,
        UnionOrIntersection = Union | Intersection,
        StructuredType = Object | Union | Intersection,
        TypeVariable = TypeParameter | IndexedAccess,
        InstantiableNonPrimitive = TypeVariable | Conditional | Substitution,
        InstantiablePrimitive = Index,
        Instantiable = InstantiableNonPrimitive | InstantiablePrimitive,
        StructuredOrInstantiable = StructuredType | Instantiable,
        // @internal
        ObjectFlagsType = Any | Nullable | Never | Object | Union | Intersection,
        // @internal
        Simplifiable = IndexedAccess | Conditional,
        // @internal
        Substructure = Object | Union | Intersection | Index | IndexedAccess | Conditional | Substitution,
        // 'Narrowable' types are types where narrowing actually narrows.
        // This *should* be every type other than null, undefined, void, and never
        Narrowable = Any | Unknown | StructuredOrInstantiable | StringLike | NumberLike | BigIntLike | BooleanLike | ESSymbol | UniqueESSymbol | NonPrimitive,
        NotUnionOrUnit = Any | Unknown | ESSymbol | Object | NonPrimitive,
        // @internal
        NotPrimitiveUnion = Any | Unknown | Enum | Void | Never | StructuredOrInstantiable,
        // The following flags are aggregated during union and intersection type construction
        // @internal
        IncludesMask = Any | Unknown | Primitive | Never | Object | Union | Intersection | NonPrimitive,
        // The following flags are used for different purposes during union and intersection type construction
        // @internal
        IncludesStructuredOrInstantiable = TypeParameter,
        // @internal
        IncludesNonWideningType = Index,
        // @internal
        IncludesWildcard = IndexedAccess,
        // @internal
        IncludesEmptyObject = Conditional,
    }
	```

	**TypeNode Kinds**
	- `AnyKeyword` | `UnknownKeyword` | `NumberKeyword` | `BigIntKeyword` | `ObjectKeyword` | `BooleanKeyword` | `StringKeyword` | `SymbolKeyword` | `ThisKeyword` | `VoidKeyword` | `UndefinedKeyword` | `NullKeyword` | `NeverKeyword`
	- `TypeReference`
	- `FunctionType`
	- `ConstructorType`
	- `ImportType`
	- `ThisType`
	- `TypePredicate`
	- `TypeQuery`
	- `TypeLiteral`
	- `ArrayType`
	- `TupleType`
	- `OptionalType`
	- `RestType`
	- `UnionType`
	- `IntersectionType`
	- `ConditionalType`
	- `InferType`
	- `ParenthesizedType`
	- `TypeOperator`
	- `IndexedAccessType`
	- `MappedType`
	- `LiteralType`
	- `StringLiteral`
	- `TrueKeyword`
	- `FalseKeyword`
**/
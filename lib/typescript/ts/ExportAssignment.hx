package typescript.ts;


/**
This is either an `export =` or an `export default` declaration.
Unless `isExportEquals` is set, this node was parsed as an `export default`.

Generated from: test-definitions/typescript/typescript-extended.d.ts:1545:5
**/

typedef ExportAssignment = typescript.ts.DeclarationStatement & {
	@:optional
	var isExportEquals: Bool;
	var expression: typescript.ts.Expression;
}


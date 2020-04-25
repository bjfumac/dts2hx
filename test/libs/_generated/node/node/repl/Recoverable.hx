package node.repl;
/**
	Indicates a recoverable error that a `REPLServer` can use to support multi-line input.
**/
@:jsRequire("repl", "Recoverable") extern class Recoverable extends js.lib.SyntaxError {
	function new(err:js.lib.Error);
	var err : js.lib.Error;
}
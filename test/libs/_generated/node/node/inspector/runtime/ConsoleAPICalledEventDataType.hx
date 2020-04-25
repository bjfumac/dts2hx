package node.inspector.runtime;
extern interface ConsoleAPICalledEventDataType {
	/**
		Type of the call.
	**/
	var type : String;
	/**
		Call arguments.
	**/
	var args : std.Array<RemoteObject>;
	/**
		Identifier of the context where the call was made.
	**/
	var executionContextId : Float;
	/**
		Call timestamp.
	**/
	var timestamp : Float;
	/**
		Stack trace captured when the call was made.
	**/
	@:optional
	var stackTrace : Null<StackTrace>;
	/**
		Console context descriptor for calls on non-default console context (not console.*):
		'anonymous#unique-logger-id' for call on unnamed context, 'name#unique-logger-id' for call
		on named context.
	**/
	@:optional
	var context : Null<String>;
}
package node.child_process;

typedef SpawnSyncReturns<T> = {
	var pid : Float;
	var output : Array<String>;
	var stdout : T;
	var stderr : T;
	var status : Float;
	var signal : String;
	@:optional
	var error : js.lib.Error;
};
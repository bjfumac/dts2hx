package global.nodejs;
@:native("NodeJS.Immediate") extern class Immediate {
	function ref():Void;
	function unref():Void;
	var _onImmediate : ts.lib.IFunction;
}
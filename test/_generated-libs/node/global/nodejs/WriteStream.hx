package global.nodejs;
extern typedef WriteStream = {
	final writableHighWaterMark : Float;
	final writableLength : Float;
	@:optional
	var columns : Float;
	@:optional
	var rows : Float;
	function _write(chunk:Any, encoding:String, callback:(?err:ts.lib.IError) -> Void):Void;
	function _destroy(err:Null<ts.lib.IError>, callback:(?err:ts.lib.IError) -> Void):Void;
	function _final(callback:(?err:ts.lib.IError) -> Void):Void;
	function setDefaultEncoding(encoding:String):WriteStream;
	function cork():Void;
	function uncork():Void;
	function destroy(?error:ts.lib.IError):Void;
	@:optional
	var isTTY : Bool;
	var readable : Bool;
	function read(?size:Float):haxe.extern.EitherType<String, global.IBuffer>;
	function setEncoding(encoding:String):WriteStream;
	function pause():WriteStream;
	function resume():WriteStream;
	function isPaused():Bool;
	function pipe<T>(destination:T, ?options:{ @:optional var end : Bool; }):T;
	function unpipe(?destination:WritableStream):WriteStream;
	@:overload(function(chunk:global.IBuffer):Void { })
	function unshift(chunk:String):Void;
	function wrap(oldStream:ReadableStream):WriteStream;
	function addListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):WriteStream;
	function on(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):WriteStream;
	function once(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):WriteStream;
	function removeListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):WriteStream;
	function off(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):WriteStream;
	function removeAllListeners(?event:haxe.extern.EitherType<String, js.lib.Symbol>):WriteStream;
	function setMaxListeners(n:Float):WriteStream;
	function getMaxListeners():Float;
	function listeners(event:haxe.extern.EitherType<String, js.lib.Symbol>):std.Array<ts.lib.IFunction>;
	function rawListeners(event:haxe.extern.EitherType<String, js.lib.Symbol>):std.Array<ts.lib.IFunction>;
	function emit(event:haxe.extern.EitherType<String, js.lib.Symbol>, args:std.Array<Any>):Bool;
	function listenerCount(type:haxe.extern.EitherType<String, js.lib.Symbol>):Float;
	function prependListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):WriteStream;
	function prependOnceListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):WriteStream;
	function eventNames():std.Array<haxe.extern.EitherType<String, js.lib.Symbol>>;
	var writable : Bool;
	@:overload(function(str:String, ?encoding:String, ?cb:(?err:ts.lib.IError) -> Void):Bool { })
	function write(buffer:haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, ts.lib.IUint8Array>>, ?cb:(?err:ts.lib.IError) -> Void):Bool;
	@:overload(function(data:haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, ts.lib.IUint8Array>>, ?cb:() -> Void):Void { })
	@:overload(function(str:String, ?encoding:String, ?cb:() -> Void):Void { })
	function end(?cb:() -> Void):Void;
};
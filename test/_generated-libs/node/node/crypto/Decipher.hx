package node.crypto;
extern typedef Decipher = {
	@:overload(function(data:String, input_encoding:String):global.IBuffer { })
	@:overload(function(data:haxe.extern.EitherType<global.IBuffer, haxe.extern.EitherType<js.lib.IUint8Array, haxe.extern.EitherType<js.lib.IUint8ClampedArray, haxe.extern.EitherType<js.lib.IUint16Array, haxe.extern.EitherType<js.lib.IUint32Array, haxe.extern.EitherType<js.lib.IInt8Array, haxe.extern.EitherType<js.lib.IInt16Array, haxe.extern.EitherType<js.lib.IInt32Array, haxe.extern.EitherType<js.lib.IFloat32Array, haxe.extern.EitherType<js.lib.IFloat64Array, js.lib.IDataView>>>>>>>>>>, input_encoding:Void, output_encoding:String):String { })
	@:overload(function(data:String, input_encoding:Null<String>, output_encoding:String):String { })
	function update(data:haxe.extern.EitherType<global.IBuffer, haxe.extern.EitherType<js.lib.IUint8Array, haxe.extern.EitherType<js.lib.IUint8ClampedArray, haxe.extern.EitherType<js.lib.IUint16Array, haxe.extern.EitherType<js.lib.IUint32Array, haxe.extern.EitherType<js.lib.IInt8Array, haxe.extern.EitherType<js.lib.IInt16Array, haxe.extern.EitherType<js.lib.IInt32Array, haxe.extern.EitherType<js.lib.IFloat32Array, haxe.extern.EitherType<js.lib.IFloat64Array, js.lib.IDataView>>>>>>>>>>):global.IBuffer;
	@:native("final")
	@:overload(function(output_encoding:String):String { })
	function final_():global.IBuffer;
	function setAutoPadding(?auto_padding:Bool):Decipher;
	var readable : Bool;
	function read(?size:Float):haxe.extern.EitherType<String, global.IBuffer>;
	function setEncoding(encoding:String):Decipher;
	function pause():Decipher;
	function resume():Decipher;
	function isPaused():Bool;
	function pipe<T:(global.nodejs.WritableStream)>(destination:T, ?options:{ @:optional var end : Bool; }):T;
	function unpipe(?destination:global.nodejs.WritableStream):Decipher;
	@:overload(function(chunk:global.IBuffer):Void { })
	function unshift(chunk:String):Void;
	function wrap(oldStream:global.nodejs.ReadableStream):Decipher;
	function addListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):Decipher;
	function on(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):Decipher;
	function once(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):Decipher;
	function removeListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):Decipher;
	function off(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):Decipher;
	function removeAllListeners(?event:haxe.extern.EitherType<String, js.lib.Symbol>):Decipher;
	function setMaxListeners(n:Float):Decipher;
	function getMaxListeners():Float;
	function listeners(event:haxe.extern.EitherType<String, js.lib.Symbol>):std.Array<js.lib.IFunction>;
	function rawListeners(event:haxe.extern.EitherType<String, js.lib.Symbol>):std.Array<js.lib.IFunction>;
	function emit(event:haxe.extern.EitherType<String, js.lib.Symbol>, args:std.Array<Any>):Bool;
	function listenerCount(type:haxe.extern.EitherType<String, js.lib.Symbol>):Float;
	function prependListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):Decipher;
	function prependOnceListener(event:haxe.extern.EitherType<String, js.lib.Symbol>, listener:(args:std.Array<Any>) -> Void):Decipher;
	function eventNames():std.Array<haxe.extern.EitherType<String, js.lib.Symbol>>;
	var writable : Bool;
	@:overload(function(str:String, ?encoding:String, ?cb:(?err:js.lib.IError) -> Void):Bool { })
	function write(buffer:haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, js.lib.IUint8Array>>, ?cb:(?err:js.lib.IError) -> Void):Bool;
	@:overload(function(data:haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, js.lib.IUint8Array>>, ?cb:() -> Void):Void { })
	@:overload(function(str:String, ?encoding:String, ?cb:() -> Void):Void { })
	function end(?cb:() -> Void):Void;
};
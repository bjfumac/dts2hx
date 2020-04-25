package node.crypto;
extern interface Signer extends global.nodejs.WritableStream {
	@:overload(function(data:String, input_encoding:String):Signer { })
	function update(data:haxe.extern.EitherType<String, haxe.extern.EitherType<global.Buffer, haxe.extern.EitherType<js.lib.Uint8Array, haxe.extern.EitherType<js.lib.Uint8ClampedArray, haxe.extern.EitherType<js.lib.Uint16Array, haxe.extern.EitherType<js.lib.Uint32Array, haxe.extern.EitherType<js.lib.Int8Array, haxe.extern.EitherType<js.lib.Int16Array, haxe.extern.EitherType<js.lib.Int32Array, haxe.extern.EitherType<js.lib.Float32Array, haxe.extern.EitherType<js.lib.Float64Array, js.lib.DataView>>>>>>>>>>>):Signer;
	@:overload(function(private_key:haxe.extern.EitherType<String, haxe.extern.EitherType<global.Buffer, haxe.extern.EitherType<KeyObject, SignPrivateKeyInput>>>, output_format:String):String { })
	function sign(private_key:haxe.extern.EitherType<String, haxe.extern.EitherType<global.Buffer, haxe.extern.EitherType<KeyObject, SignPrivateKeyInput>>>):global.Buffer;
}
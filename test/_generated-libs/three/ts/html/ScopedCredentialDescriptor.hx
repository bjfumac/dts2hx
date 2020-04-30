package ts.html;
extern typedef ScopedCredentialDescriptor = {
	var id : Null<haxe.extern.EitherType<ts.lib.IInt8Array, haxe.extern.EitherType<ts.lib.IUint8Array, haxe.extern.EitherType<ts.lib.IUint8ClampedArray, haxe.extern.EitherType<ts.lib.IInt16Array, haxe.extern.EitherType<ts.lib.IUint16Array, haxe.extern.EitherType<ts.lib.IInt32Array, haxe.extern.EitherType<ts.lib.IUint32Array, haxe.extern.EitherType<ts.lib.IFloat32Array, haxe.extern.EitherType<ts.lib.IFloat64Array, haxe.extern.EitherType<ts.lib.IArrayBuffer, ts.lib.IDataView>>>>>>>>>>>;
	@:optional
	var transports : std.Array<String>;
	var type : String;
};
package ts.html;
extern typedef AesGcmParams = {
	@:optional
	var additionalData : haxe.extern.EitherType<ts.lib.IInt8Array, haxe.extern.EitherType<ts.lib.IUint8Array, haxe.extern.EitherType<ts.lib.IUint8ClampedArray, haxe.extern.EitherType<ts.lib.IInt16Array, haxe.extern.EitherType<ts.lib.IUint16Array, haxe.extern.EitherType<ts.lib.IInt32Array, haxe.extern.EitherType<ts.lib.IUint32Array, haxe.extern.EitherType<ts.lib.IFloat32Array, haxe.extern.EitherType<ts.lib.IFloat64Array, haxe.extern.EitherType<ts.lib.IArrayBuffer, ts.lib.IDataView>>>>>>>>>>;
	var iv : haxe.extern.EitherType<ts.lib.IInt8Array, haxe.extern.EitherType<ts.lib.IUint8Array, haxe.extern.EitherType<ts.lib.IUint8ClampedArray, haxe.extern.EitherType<ts.lib.IInt16Array, haxe.extern.EitherType<ts.lib.IUint16Array, haxe.extern.EitherType<ts.lib.IInt32Array, haxe.extern.EitherType<ts.lib.IUint32Array, haxe.extern.EitherType<ts.lib.IFloat32Array, haxe.extern.EitherType<ts.lib.IFloat64Array, haxe.extern.EitherType<ts.lib.IArrayBuffer, ts.lib.IDataView>>>>>>>>>>;
	@:optional
	var tagLength : Float;
	var name : String;
};
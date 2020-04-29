package js.lib;
extern typedef IWebAuthentication = {
	function getAssertion(assertionChallenge:Null<haxe.extern.EitherType<IInt8Array, haxe.extern.EitherType<IUint8Array, haxe.extern.EitherType<IUint8ClampedArray, haxe.extern.EitherType<IInt16Array, haxe.extern.EitherType<IUint16Array, haxe.extern.EitherType<IInt32Array, haxe.extern.EitherType<IUint32Array, haxe.extern.EitherType<IFloat32Array, haxe.extern.EitherType<IFloat64Array, haxe.extern.EitherType<IArrayBuffer, IDataView>>>>>>>>>>>, ?options:js.html.AssertionOptions):IPromise<js.html.IWebAuthnAssertion>;
	@:overload(function(accountInformation:js.html.Account, cryptoParameters:Iterable<js.html.ScopedCredentialParameters>, attestationChallenge:Null<haxe.extern.EitherType<IInt8Array, haxe.extern.EitherType<IUint8Array, haxe.extern.EitherType<IUint8ClampedArray, haxe.extern.EitherType<IInt16Array, haxe.extern.EitherType<IUint16Array, haxe.extern.EitherType<IInt32Array, haxe.extern.EitherType<IUint32Array, haxe.extern.EitherType<IFloat32Array, haxe.extern.EitherType<IFloat64Array, haxe.extern.EitherType<IArrayBuffer, IDataView>>>>>>>>>>>, ?options:js.html.ScopedCredentialOptions):IPromise<js.html.IScopedCredentialInfo> { })
	function makeCredential(accountInformation:js.html.Account, cryptoParameters:std.Array<js.html.ScopedCredentialParameters>, attestationChallenge:Null<haxe.extern.EitherType<IInt8Array, haxe.extern.EitherType<IUint8Array, haxe.extern.EitherType<IUint8ClampedArray, haxe.extern.EitherType<IInt16Array, haxe.extern.EitherType<IUint16Array, haxe.extern.EitherType<IInt32Array, haxe.extern.EitherType<IUint32Array, haxe.extern.EitherType<IFloat32Array, haxe.extern.EitherType<IFloat64Array, haxe.extern.EitherType<IArrayBuffer, IDataView>>>>>>>>>>>, ?options:js.html.ScopedCredentialOptions):IPromise<js.html.IScopedCredentialInfo>;
};
package node.https;
typedef ServerOptions = {
	@:optional
	var pfx : haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, std.Array<haxe.extern.EitherType<String, haxe.extern.EitherType<ts.lib.IObject, global.IBuffer>>>>>;
	@:optional
	var key : haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, std.Array<haxe.extern.EitherType<ts.lib.IObject, global.IBuffer>>>>;
	@:optional
	var passphrase : String;
	@:optional
	var cert : haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, std.Array<haxe.extern.EitherType<String, global.IBuffer>>>>;
	@:optional
	var ca : haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, std.Array<haxe.extern.EitherType<String, global.IBuffer>>>>;
	@:optional
	var ciphers : String;
	@:optional
	var honorCipherOrder : Bool;
	@:optional
	var ecdhCurve : String;
	@:optional
	var clientCertEngine : String;
	@:optional
	var crl : haxe.extern.EitherType<String, haxe.extern.EitherType<global.IBuffer, std.Array<haxe.extern.EitherType<String, global.IBuffer>>>>;
	@:optional
	var dhparam : haxe.extern.EitherType<String, global.IBuffer>;
	@:optional
	var secureOptions : Float;
	@:optional
	var secureProtocol : String;
	@:optional
	var sessionIdContext : String;
	/**
		Optionally set the maximum TLS version to allow. One
		of `TLSv1.2'`, `'TLSv1.1'`, or `'TLSv1'`. Cannot be specified along with the
		`secureProtocol` option, use one or the other.  **Default:** `'TLSv1.2'`.
	**/
	@:optional
	var maxVersion : String;
	/**
		Optionally set the minimum TLS version to allow. One
		of `TLSv1.2'`, `'TLSv1.1'`, or `'TLSv1'`. Cannot be specified along with the
		`secureProtocol` option, use one or the other.  It is not recommended to use
		less than TLSv1.2, but it may be required for interoperability.
		**Default:** `'TLSv1.2'`, unless changed using CLI options. Using
		`--tls-v1.0` changes the default to `'TLSv1'`. Using `--tls-v1.1` changes
		the default to `'TLSv1.1'`.
	**/
	@:optional
	var minVersion : String;
	@:optional
	var handshakeTimeout : Float;
	@:optional
	var requestCert : Bool;
	@:optional
	var rejectUnauthorized : Bool;
	@:optional
	var NPNProtocols : haxe.extern.EitherType<std.Array<String>, haxe.extern.EitherType<global.IBuffer, haxe.extern.EitherType<ts.lib.IUint8Array, haxe.extern.EitherType<std.Array<ts.lib.IUint8Array>, std.Array<global.IBuffer>>>>>;
	@:optional
	var ALPNProtocols : haxe.extern.EitherType<std.Array<String>, haxe.extern.EitherType<global.IBuffer, haxe.extern.EitherType<ts.lib.IUint8Array, haxe.extern.EitherType<std.Array<ts.lib.IUint8Array>, std.Array<global.IBuffer>>>>>;
	@:optional
	var SNICallback : (servername:String, cb:(err:Null<ts.lib.IError>, ctx:node.tls.SecureContext) -> Void) -> Void;
	@:optional
	var sessionTimeout : Float;
	@:optional
	var ticketKeys : global.IBuffer;
	@:optional
	var IncomingMessage : {
		function finished(stream:haxe.extern.EitherType<global.nodejs.WritableStream, haxe.extern.EitherType<global.nodejs.ReadableStream, global.nodejs.ReadWriteStream>>, callback:(?err:global.nodejs.ErrnoException) -> Void):() -> Void;
		@:overload(function<T>(stream1:global.nodejs.ReadableStream, stream2:global.nodejs.ReadWriteStream, stream3:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T { })
		@:overload(function<T>(stream1:global.nodejs.ReadableStream, stream2:global.nodejs.ReadWriteStream, stream3:global.nodejs.ReadWriteStream, stream4:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T { })
		@:overload(function<T>(stream1:global.nodejs.ReadableStream, stream2:global.nodejs.ReadWriteStream, stream3:global.nodejs.ReadWriteStream, stream4:global.nodejs.ReadWriteStream, stream5:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T { })
		@:overload(function(streams:std.Array<haxe.extern.EitherType<global.nodejs.WritableStream, haxe.extern.EitherType<global.nodejs.ReadableStream, global.nodejs.ReadWriteStream>>>, ?callback:(err:global.nodejs.ErrnoException) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:haxe.extern.EitherType<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:std.Array<haxe.extern.EitherType<global.nodejs.WritableStream, haxe.extern.EitherType<global.nodejs.ReadWriteStream, (err:global.nodejs.ErrnoException) -> Void>>>):global.nodejs.WritableStream { })
		function pipeline<T>(stream1:global.nodejs.ReadableStream, stream2:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T;
		function listenerCount(emitter:node.events.EventEmitter, event:haxe.extern.EitherType<String, js.lib.Symbol>):Float;
		var defaultMaxListeners : Float;
	};
	@:optional
	var ServerResponse : {
		function finished(stream:haxe.extern.EitherType<global.nodejs.WritableStream, haxe.extern.EitherType<global.nodejs.ReadableStream, global.nodejs.ReadWriteStream>>, callback:(?err:global.nodejs.ErrnoException) -> Void):() -> Void;
		@:overload(function<T>(stream1:global.nodejs.ReadableStream, stream2:global.nodejs.ReadWriteStream, stream3:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T { })
		@:overload(function<T>(stream1:global.nodejs.ReadableStream, stream2:global.nodejs.ReadWriteStream, stream3:global.nodejs.ReadWriteStream, stream4:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T { })
		@:overload(function<T>(stream1:global.nodejs.ReadableStream, stream2:global.nodejs.ReadWriteStream, stream3:global.nodejs.ReadWriteStream, stream4:global.nodejs.ReadWriteStream, stream5:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T { })
		@:overload(function(streams:std.Array<haxe.extern.EitherType<global.nodejs.WritableStream, haxe.extern.EitherType<global.nodejs.ReadableStream, global.nodejs.ReadWriteStream>>>, ?callback:(err:global.nodejs.ErrnoException) -> Void):global.nodejs.WritableStream { })
		@:overload(function(stream1:global.nodejs.ReadableStream, stream2:haxe.extern.EitherType<global.nodejs.WritableStream, global.nodejs.ReadWriteStream>, streams:std.Array<haxe.extern.EitherType<global.nodejs.WritableStream, haxe.extern.EitherType<global.nodejs.ReadWriteStream, (err:global.nodejs.ErrnoException) -> Void>>>):global.nodejs.WritableStream { })
		function pipeline<T>(stream1:global.nodejs.ReadableStream, stream2:T, ?callback:(err:global.nodejs.ErrnoException) -> Void):T;
		function listenerCount(emitter:node.events.EventEmitter, event:haxe.extern.EitherType<String, js.lib.Symbol>):Float;
		var defaultMaxListeners : Float;
	};
};
package node;
@:jsRequire("http") extern class Http {
	@:overload(function(options:node.http.ServerOptions, ?requestListener:(req:node.http.IncomingMessage, res:node.http.ServerResponse) -> Void):node.http.Server { })
	static function createServer(?requestListener:(req:node.http.IncomingMessage, res:node.http.ServerResponse) -> Void):node.http.Server;
	@:overload(function(url:haxe.extern.EitherType<String, node.url.URL>, options:node.http.RequestOptions, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest { })
	static function request(options:haxe.extern.EitherType<String, haxe.extern.EitherType<node.url.URL, node.http.RequestOptions>>, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest;
	@:overload(function(url:haxe.extern.EitherType<String, node.url.URL>, options:node.http.RequestOptions, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest { })
	static function get(options:haxe.extern.EitherType<String, haxe.extern.EitherType<node.url.URL, node.http.RequestOptions>>, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest;
	static var METHODS : std.Array<String>;
	static var STATUS_CODES : { };
	static var globalAgent : node.http.Agent;
	/**
		Read-only property specifying the maximum allowed size of HTTP headers in bytes.
		Defaults to 8KB. Configurable using the [`--max-http-header-size`][] CLI option.
	**/
	static var maxHeaderSize : Float;
}
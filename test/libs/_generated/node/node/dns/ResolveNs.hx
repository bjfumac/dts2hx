package node.dns;
@:jsRequire("dns", "resolveNs") extern class ResolveNs {
	static function __promisify__(hostname:String):js.lib.Promise<std.Array<String>>;
}
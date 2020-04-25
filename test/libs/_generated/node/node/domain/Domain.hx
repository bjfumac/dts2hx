package node.domain;
@:jsRequire("domain", "Domain") extern class Domain extends node.events.EventEmitter implements global.nodejs.Domain {
	function run<T>(fn:(args:std.Array<Any>) -> T, args:std.Array<Any>):T;
	function add(emitter:haxe.extern.EitherType<node.events.EventEmitter, global.nodejs.Timer>):Void;
	function remove(emitter:haxe.extern.EitherType<node.events.EventEmitter, global.nodejs.Timer>):Void;
	function bind<T:(js.lib.Function)>(cb:T):T;
	function intercept<T:(js.lib.Function)>(cb:T):T;
	var members : std.Array<haxe.extern.EitherType<node.events.EventEmitter, global.nodejs.Timer>>;
	function enter():Void;
	function exit():Void;
}
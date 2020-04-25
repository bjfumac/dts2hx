package global.nodejs;
extern interface Domain extends Events {
	function run<T>(fn:(args:std.Array<Any>) -> T, args:std.Array<Any>):T;
	function add(emitter:haxe.extern.EitherType<EventEmitter, Timer>):Void;
	function remove(emitter:haxe.extern.EitherType<EventEmitter, Timer>):Void;
	function bind<T:(js.lib.Function)>(cb:T):T;
	function intercept<T:(js.lib.Function)>(cb:T):T;
	function addListener(event:String, listener:(args:std.Array<Any>) -> Void):Domain;
	function on(event:String, listener:(args:std.Array<Any>) -> Void):Domain;
	function once(event:String, listener:(args:std.Array<Any>) -> Void):Domain;
	function removeListener(event:String, listener:(args:std.Array<Any>) -> Void):Domain;
	function removeAllListeners(?event:String):Domain;
}
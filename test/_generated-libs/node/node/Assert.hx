package node;
@:jsRequire("assert") @valueModuleOnly extern class Assert {
	@:overload(function(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>, ?operator_:String, ?stackStartFn:ts.lib.IFunction):Any { })
	static function fail(?message:haxe.extern.EitherType<String, ts.lib.IError>):Any;
	static function ok(value:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function equal(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function notEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function deepEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function notDeepEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function strictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function notStrictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function deepStrictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function notDeepStrictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	@:overload(function(block:() -> Any, error:haxe.extern.EitherType<ts.lib.IObject, haxe.extern.EitherType<ts.lib.IFunction, haxe.extern.EitherType<ts.lib.IRegExp, ts.lib.IError>>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void { })
	static function throws(block:() -> Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	@:overload(function(block:() -> Any, error:haxe.extern.EitherType<ts.lib.IFunction, ts.lib.IRegExp>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void { })
	static function doesNotThrow(block:() -> Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
	static function ifError(value:Any):Void;
	@:overload(function(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, error:haxe.extern.EitherType<ts.lib.IObject, haxe.extern.EitherType<ts.lib.IFunction, haxe.extern.EitherType<ts.lib.IRegExp, ts.lib.IError>>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void> { })
	static function rejects(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void>;
	@:overload(function(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, error:haxe.extern.EitherType<ts.lib.IFunction, ts.lib.IRegExp>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void> { })
	static function doesNotReject(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void>;
	static var strict : {
		@:selfCall
		function call(value:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		@:overload(function(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>, ?operator_:String, ?stackStartFn:ts.lib.IFunction):Any { })
		function fail(?message:haxe.extern.EitherType<String, ts.lib.IError>):Any;
		function ok(value:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function equal(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function notEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function deepEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function notDeepEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function strictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function notStrictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function deepStrictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function notDeepStrictEqual(actual:Any, expected:Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		@:overload(function(block:() -> Any, error:haxe.extern.EitherType<ts.lib.IObject, haxe.extern.EitherType<ts.lib.IFunction, haxe.extern.EitherType<ts.lib.IRegExp, ts.lib.IError>>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void { })
		function throws(block:() -> Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		@:overload(function(block:() -> Any, error:haxe.extern.EitherType<ts.lib.IFunction, ts.lib.IRegExp>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void { })
		function doesNotThrow(block:() -> Any, ?message:haxe.extern.EitherType<String, ts.lib.IError>):Void;
		function ifError(value:Any):Void;
		@:overload(function(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, error:haxe.extern.EitherType<ts.lib.IObject, haxe.extern.EitherType<ts.lib.IFunction, haxe.extern.EitherType<ts.lib.IRegExp, ts.lib.IError>>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void> { })
		function rejects(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void>;
		@:overload(function(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, error:haxe.extern.EitherType<ts.lib.IFunction, ts.lib.IRegExp>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void> { })
		function doesNotReject(block:haxe.extern.EitherType<ts.lib.IPromise<Any>, () -> ts.lib.IPromise<Any>>, ?message:haxe.extern.EitherType<String, ts.lib.IError>):ts.lib.IPromise<Void>;
		var strict : Any;
	};
}
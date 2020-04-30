package three;
@:jsRequire("three", "PropertyBinding") extern class PropertyBinding {
	function new(rootNode:Any, path:String, ?parsedPath:Any);
	var path : String;
	var parsedPath : Any;
	var node : Any;
	var rootNode : Any;
	function getValue(targetArray:Any, offset:Float):Any;
	function setValue(sourceArray:Any, offset:Float):Void;
	function bind():Void;
	function unbind():Void;
	var BindingType : { };
	var Versioning : { };
	var GetterByBindingType : std.Array<ts.lib.IFunction>;
	var SetterByBindingTypeAndVersioning : std.Array<std.Array<ts.lib.IFunction>>;
	static function create(root:Any, path:Any, ?parsedPath:Any):haxe.extern.EitherType<PropertyBinding, three.propertybinding.Composite>;
	static function parseTrackName(trackName:String):Any;
	static function findNode(root:Any, nodeName:String):Any;
}
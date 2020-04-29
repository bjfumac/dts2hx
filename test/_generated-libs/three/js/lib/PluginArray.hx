package js.lib;
/**
	Used to store a list of Plugin objects describing the available plugins; it's returned by the window.navigator.plugins property. The PluginArray is not a JavaScript array, but has the length property and supports accessing individual items using bracket notation (plugins[2]), as well as via item(index) and namedItem("name") methods.
**/
@:native("PluginArray") @tsInterface extern class PluginArray {
	function new();
	final length : Float;
	function item(index:Float):Null<Plugin>;
	function namedItem(name:String):Null<Plugin>;
	function refresh(?reload:Bool):Void;
	static var prototype : PluginArray;
}
package node.util;

@:jsRequire("util", "TextEncoder") extern class TextEncoder {
	function new();
	final encoding : String;
	function encode(?input:String):js.lib.Uint8Array;
	static var prototype : TextEncoder;
}
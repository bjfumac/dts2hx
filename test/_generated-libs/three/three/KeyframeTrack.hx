package three;
@:jsRequire("three", "KeyframeTrack") extern class KeyframeTrack {
	function new(name:String, times:std.Array<Any>, values:std.Array<Any>, ?interpolation:InterpolationModes);
	var name : String;
	var times : std.Array<Any>;
	var values : std.Array<Any>;
	var ValueTypeName : String;
	var TimeBufferType : ts.lib.IFloat32Array;
	var ValueBufferType : ts.lib.IFloat32Array;
	var DefaultInterpolation : InterpolationModes;
	function InterpolantFactoryMethodDiscrete(result:Any):DiscreteInterpolant;
	function InterpolantFactoryMethodLinear(result:Any):LinearInterpolant;
	function InterpolantFactoryMethodSmooth(result:Any):CubicInterpolant;
	function setInterpolation(interpolation:InterpolationModes):Void;
	function getInterpolation():InterpolationModes;
	function getValuesize():Float;
	function shift(timeOffset:Float):KeyframeTrack;
	function scale(timeScale:Float):KeyframeTrack;
	function trim(startTime:Float, endTime:Float):KeyframeTrack;
	function validate():Bool;
	function optimize():KeyframeTrack;
	static function parse(json:Any):KeyframeTrack;
	static function toJSON(track:KeyframeTrack):Any;
}
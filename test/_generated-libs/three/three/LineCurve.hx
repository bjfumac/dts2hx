package three;
@:jsRequire("three", "LineCurve") extern class LineCurve {
	function new(v1:Vector2, v2:Vector2);
	var v1 : Vector2;
	var v2 : Vector2;
	/**
		This value determines the amount of divisions when calculating the cumulative segment lengths of a curve via .getLengths.
		To ensure precision when using methods like .getSpacedPoints, it is recommended to increase .arcLengthDivisions if the curve is very large.
		Default is 200.
	**/
	var arcLengthDivisions : Float;
	/**
		Returns a vector for point t of the curve where t is between 0 and 1
		getPoint(t: number): T;
	**/
	function getPoint(t:Float, ?optionalTarget:Vector2):Vector2;
	/**
		Returns a vector for point at relative position in curve according to arc length
		getPointAt(u: number): T;
	**/
	function getPointAt(u:Float, ?optionalTarget:Vector2):Vector2;
	/**
		Get sequence of points using getPoint( t )
		getPoints(divisions?: number): T[];
	**/
	function getPoints(?divisions:Float):std.Array<Vector2>;
	/**
		Get sequence of equi-spaced points using getPointAt( u )
		getSpacedPoints(divisions?: number): T[];
	**/
	function getSpacedPoints(?divisions:Float):std.Array<Vector2>;
	/**
		Get total curve arc length
	**/
	function getLength():Float;
	/**
		Get list of cumulative segment lengths
	**/
	function getLengths(?divisions:Float):std.Array<Float>;
	/**
		Update the cumlative segment distance cache
	**/
	function updateArcLengths():Void;
	/**
		Given u ( 0 .. 1 ), get a t to find p. This gives you points which are equi distance
	**/
	function getUtoTmapping(u:Float, distance:Float):Float;
	/**
		Returns a unit vector tangent at t. If the subclassed curve do not implement its tangent derivation, 2 points a small delta apart will be used to find its gradient which seems to give a reasonable approximation
		getTangent(t: number): T;
	**/
	function getTangent(t:Float):Vector2;
	/**
		Returns tangent at equidistance point u on the curve
		getTangentAt(u: number): T;
	**/
	function getTangentAt(u:Float):Vector2;
}
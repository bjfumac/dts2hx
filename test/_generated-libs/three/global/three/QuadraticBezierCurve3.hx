package global.three;

@:native("THREE.QuadraticBezierCurve3") extern class QuadraticBezierCurve3 extends Curve<Vector3> {
	function new(v0:Vector3, v1:Vector3, v2:Vector3);
	var v0 : Vector3;
	var v1 : Vector3;
	var v2 : Vector3;
	/**
		Returns a vector for point t of the curve where t is between 0 and 1
		getPoint(t: number): T;
	**/
	function getPoint(t:Float):Vector3;
	static var prototype : QuadraticBezierCurve3;
}
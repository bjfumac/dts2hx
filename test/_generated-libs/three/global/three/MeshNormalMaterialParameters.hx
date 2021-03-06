package global.three;

typedef MeshNormalMaterialParameters = {
	@:optional
	var bumpMap : Texture;
	@:optional
	var bumpScale : Float;
	@:optional
	var normalMap : Texture;
	@:optional
	var normalMapType : NormalMapTypes;
	@:optional
	var normalScale : Vector2;
	@:optional
	var displacementMap : Texture;
	@:optional
	var displacementScale : Float;
	@:optional
	var displacementBias : Float;
	@:optional
	var wireframe : Bool;
	@:optional
	var wireframeLinewidth : Float;
	@:optional
	var skinning : Bool;
	@:optional
	var morphTargets : Bool;
	@:optional
	var morphNormals : Bool;
	@:optional
	var alphaTest : Float;
	@:optional
	var blendDst : BlendingDstFactor;
	@:optional
	var blendDstAlpha : Float;
	@:optional
	var blendEquation : BlendingEquation;
	@:optional
	var blendEquationAlpha : Float;
	@:optional
	var blending : Blending;
	@:optional
	var blendSrc : ts.AnyOf2<BlendingDstFactor, BlendingSrcFactor>;
	@:optional
	var blendSrcAlpha : Float;
	@:optional
	var clipIntersection : Bool;
	@:optional
	var clippingPlanes : Array<Plane>;
	@:optional
	var clipShadows : Bool;
	@:optional
	var colorWrite : Bool;
	@:optional
	var depthFunc : DepthModes;
	@:optional
	var depthTest : Bool;
	@:optional
	var depthWrite : Bool;
	@:optional
	var fog : Bool;
	@:optional
	var lights : Bool;
	@:optional
	var name : String;
	@:optional
	var opacity : Float;
	@:optional
	var overdraw : Float;
	@:optional
	var polygonOffset : Bool;
	@:optional
	var polygonOffsetFactor : Float;
	@:optional
	var polygonOffsetUnits : Float;
	@:optional
	var precision : String;
	@:optional
	var premultipliedAlpha : Bool;
	@:optional
	var dithering : Bool;
	@:optional
	var flatShading : Bool;
	@:optional
	var side : Side;
	@:optional
	var shadowSide : Side;
	@:optional
	var transparent : Bool;
	@:optional
	var vertexColors : Colors;
	@:optional
	var vertexTangents : Bool;
	@:optional
	var visible : Bool;
	@:optional
	var stencilWrite : Bool;
	@:optional
	var stencilFunc : StencilFunc;
	@:optional
	var stencilRef : Float;
	@:optional
	var stencilMask : Float;
	@:optional
	var stencilFail : StencilOp;
	@:optional
	var stencilZFail : StencilOp;
	@:optional
	var stencilZPass : StencilOp;
};
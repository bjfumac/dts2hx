package three.src;

@:jsRequire("three/src/constants") @valueModuleOnly extern class Constants {
	static final REVISION : String;
	static final CullFaceNone : three.CullFace;
	static final CullFaceBack : three.CullFace;
	static final CullFaceFront : three.CullFace;
	static final CullFaceFrontBack : three.CullFace;
	static final FrontFaceDirectionCW : three.FrontFaceDirection;
	static final FrontFaceDirectionCCW : three.FrontFaceDirection;
	static final BasicShadowMap : three.ShadowMapType;
	static final PCFShadowMap : three.ShadowMapType;
	static final PCFSoftShadowMap : three.ShadowMapType;
	static final FrontSide : three.Side;
	static final BackSide : three.Side;
	static final DoubleSide : three.Side;
	static final FlatShading : three.Shading;
	static final SmoothShading : three.Shading;
	static final NoColors : three.Colors;
	static final FaceColors : three.Colors;
	static final VertexColors : three.Colors;
	static final NoBlending : three.Blending;
	static final NormalBlending : three.Blending;
	static final AdditiveBlending : three.Blending;
	static final SubtractiveBlending : three.Blending;
	static final MultiplyBlending : three.Blending;
	static final CustomBlending : three.Blending;
	static final AddEquation : three.BlendingEquation;
	static final SubtractEquation : three.BlendingEquation;
	static final ReverseSubtractEquation : three.BlendingEquation;
	static final MinEquation : three.BlendingEquation;
	static final MaxEquation : three.BlendingEquation;
	static final ZeroFactor : three.BlendingDstFactor;
	static final OneFactor : three.BlendingDstFactor;
	static final SrcColorFactor : three.BlendingDstFactor;
	static final OneMinusSrcColorFactor : three.BlendingDstFactor;
	static final SrcAlphaFactor : three.BlendingDstFactor;
	static final OneMinusSrcAlphaFactor : three.BlendingDstFactor;
	static final DstAlphaFactor : three.BlendingDstFactor;
	static final OneMinusDstAlphaFactor : three.BlendingDstFactor;
	static final DstColorFactor : three.BlendingDstFactor;
	static final OneMinusDstColorFactor : three.BlendingDstFactor;
	static final SrcAlphaSaturateFactor : three.BlendingSrcFactor;
	static final NeverDepth : three.DepthModes;
	static final AlwaysDepth : three.DepthModes;
	static final LessDepth : three.DepthModes;
	static final LessEqualDepth : three.DepthModes;
	static final EqualDepth : three.DepthModes;
	static final GreaterEqualDepth : three.DepthModes;
	static final GreaterDepth : three.DepthModes;
	static final NotEqualDepth : three.DepthModes;
	static final MultiplyOperation : three.Combine;
	static final MixOperation : three.Combine;
	static final AddOperation : three.Combine;
	static final NoToneMapping : three.ToneMapping;
	static final LinearToneMapping : three.ToneMapping;
	static final ReinhardToneMapping : three.ToneMapping;
	static final Uncharted2ToneMapping : three.ToneMapping;
	static final CineonToneMapping : three.ToneMapping;
	static final UVMapping : three.Mapping;
	static final CubeReflectionMapping : three.Mapping;
	static final CubeRefractionMapping : three.Mapping;
	static final EquirectangularReflectionMapping : three.Mapping;
	static final EquirectangularRefractionMapping : three.Mapping;
	static final SphericalReflectionMapping : three.Mapping;
	static final CubeUVReflectionMapping : three.Mapping;
	static final CubeUVRefractionMapping : three.Mapping;
	static final RepeatWrapping : three.Wrapping;
	static final ClampToEdgeWrapping : three.Wrapping;
	static final MirroredRepeatWrapping : three.Wrapping;
	static final NearestFilter : three.TextureFilter;
	static final NearestMipmapNearestFilter : three.TextureFilter;
	static final NearestMipMapNearestFilter : three.TextureFilter;
	static final NearestMipmapLinearFilter : three.TextureFilter;
	static final NearestMipMapLinearFilter : three.TextureFilter;
	static final LinearFilter : three.TextureFilter;
	static final LinearMipmapNearestFilter : three.TextureFilter;
	static final LinearMipMapNearestFilter : three.TextureFilter;
	static final LinearMipmapLinearFilter : three.TextureFilter;
	static final LinearMipMapLinearFilter : three.TextureFilter;
	static final UnsignedByteType : three.TextureDataType;
	static final ByteType : three.TextureDataType;
	static final ShortType : three.TextureDataType;
	static final UnsignedShortType : three.TextureDataType;
	static final IntType : three.TextureDataType;
	static final UnsignedIntType : three.TextureDataType;
	static final FloatType : three.TextureDataType;
	static final HalfFloatType : three.TextureDataType;
	static final UnsignedShort4444Type : three.PixelType;
	static final UnsignedShort5551Type : three.PixelType;
	static final UnsignedShort565Type : three.PixelType;
	static final UnsignedInt248Type : three.PixelType;
	static final AlphaFormat : three.PixelFormat;
	static final RGBFormat : three.PixelFormat;
	static final RGBAFormat : three.PixelFormat;
	static final LuminanceFormat : three.PixelFormat;
	static final LuminanceAlphaFormat : three.PixelFormat;
	static final RGBEFormat : three.PixelFormat;
	static final DepthFormat : three.PixelFormat;
	static final DepthStencilFormat : three.PixelFormat;
	static final RedFormat : three.PixelFormat;
	static final RGB_S3TC_DXT1_Format : three.CompressedPixelFormat;
	static final RGBA_S3TC_DXT1_Format : three.CompressedPixelFormat;
	static final RGBA_S3TC_DXT3_Format : three.CompressedPixelFormat;
	static final RGBA_S3TC_DXT5_Format : three.CompressedPixelFormat;
	static final RGB_PVRTC_4BPPV1_Format : three.CompressedPixelFormat;
	static final RGB_PVRTC_2BPPV1_Format : three.CompressedPixelFormat;
	static final RGBA_PVRTC_4BPPV1_Format : three.CompressedPixelFormat;
	static final RGBA_PVRTC_2BPPV1_Format : three.CompressedPixelFormat;
	static final RGB_ETC1_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_4x4_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_5x4_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_5x5_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_6x5_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_6x6_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_8x5_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_8x6_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_8x8_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_10x5_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_10x6_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_10x8_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_10x10_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_12x10_Format : three.CompressedPixelFormat;
	static final RGBA_ASTC_12x12_Format : three.CompressedPixelFormat;
	static final LoopOnce : three.AnimationActionLoopStyles;
	static final LoopRepeat : three.AnimationActionLoopStyles;
	static final LoopPingPong : three.AnimationActionLoopStyles;
	static final InterpolateDiscrete : three.InterpolationModes;
	static final InterpolateLinear : three.InterpolationModes;
	static final InterpolateSmooth : three.InterpolationModes;
	static final ZeroCurvatureEnding : three.InterpolationEndingModes;
	static final ZeroSlopeEnding : three.InterpolationEndingModes;
	static final WrapAroundEnding : three.InterpolationEndingModes;
	static final TrianglesDrawMode : three.TrianglesDrawModes;
	static final TriangleStripDrawMode : three.TrianglesDrawModes;
	static final TriangleFanDrawMode : three.TrianglesDrawModes;
	static final LinearEncoding : three.TextureEncoding;
	static final sRGBEncoding : three.TextureEncoding;
	static final GammaEncoding : three.TextureEncoding;
	static final RGBEEncoding : three.TextureEncoding;
	static final LogLuvEncoding : three.TextureEncoding;
	static final RGBM7Encoding : three.TextureEncoding;
	static final RGBM16Encoding : three.TextureEncoding;
	static final RGBDEncoding : three.TextureEncoding;
	static final BasicDepthPacking : three.DepthPackingStrategies;
	static final RGBADepthPacking : three.DepthPackingStrategies;
	static final TangentSpaceNormalMap : three.NormalMapTypes;
	static final ObjectSpaceNormalMap : three.NormalMapTypes;
	static final ZeroStencilOp : three.StencilOp;
	static final KeepStencilOp : three.StencilOp;
	static final ReplaceStencilOp : three.StencilOp;
	static final IncrementStencilOp : three.StencilOp;
	static final DecrementStencilOp : three.StencilOp;
	static final IncrementWrapStencilOp : three.StencilOp;
	static final DecrementWrapStencilOp : three.StencilOp;
	static final InvertStencilOp : three.StencilOp;
	static final NeverStencilFunc : three.StencilFunc;
	static final LessStencilFunc : three.StencilFunc;
	static final EqualStencilFunc : three.StencilFunc;
	static final LessEqualStencilFunc : three.StencilFunc;
	static final GreaterStencilFunc : three.StencilFunc;
	static final NotEqualStencilFunc : three.StencilFunc;
	static final GreaterEqualStencilFunc : three.StencilFunc;
	static final AlwaysStencilFunc : three.StencilFunc;
}
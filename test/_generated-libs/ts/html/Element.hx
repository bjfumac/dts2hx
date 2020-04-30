package ts.html;
/**
	Element is the most general base class from which all objects in a Document inherit. It only has methods and properties common to all kinds of elements. More specific classes inherit from Element.
**/
@:native("Element") extern class Element {
	function new();
	final assignedSlot : Null<IHTMLSlotElement>;
	final attributes : ts.lib.INamedNodeMap;
	/**
		Allows for manipulation of element's class content attribute as a set of whitespace-separated tokens through a DOMTokenList object.
	**/
	final classList : ts.lib.IDOMTokenList;
	/**
		Returns the value of element's class content attribute. Can be set to change it.
	**/
	var className : String;
	final clientHeight : Float;
	final clientLeft : Float;
	final clientTop : Float;
	final clientWidth : Float;
	/**
		Returns the value of element's id content attribute. Can be set to change it.
	**/
	var id : String;
	/**
		Returns the local name.
	**/
	final localName : String;
	/**
		Returns the namespace.
	**/
	final namespaceURI : Null<String>;
	var onfullscreenchange : Null<(ev:IEvent) -> Any>;
	var onfullscreenerror : Null<(ev:IEvent) -> Any>;
	var outerHTML : String;
	/**
		Returns the namespace prefix.
	**/
	final prefix : Null<String>;
	final scrollHeight : Float;
	var scrollLeft : Float;
	var scrollTop : Float;
	final scrollWidth : Float;
	/**
		Returns element's shadow root, if any, and if shadow root's mode is "open", and null otherwise.
	**/
	final shadowRoot : Null<IShadowRoot>;
	/**
		Returns the value of element's slot content attribute. Can be set to change it.
	**/
	var slot : String;
	/**
		Returns the HTML-uppercased qualified name.
	**/
	final tagName : String;
	/**
		Creates a shadow root for element and returns it.
	**/
	function attachShadow(init:ShadowRootInit):IShadowRoot;
	/**
		Returns the first (starting at element) inclusive ancestor that matches selectors, and null otherwise.
	**/
	@:overload(function<K>(selector:K):Null<haxe.extern.EitherType<ISVGScriptElement, haxe.extern.EitherType<ISVGSymbolElement, haxe.extern.EitherType<ISVGAElement, haxe.extern.EitherType<ISVGStyleElement, haxe.extern.EitherType<ISVGTitleElement, haxe.extern.EitherType<ISVGCircleElement, haxe.extern.EitherType<ISVGClipPathElement, haxe.extern.EitherType<ISVGDefsElement, haxe.extern.EitherType<ISVGDescElement, haxe.extern.EitherType<ISVGEllipseElement, haxe.extern.EitherType<ISVGFEBlendElement, haxe.extern.EitherType<ISVGFEColorMatrixElement, haxe.extern.EitherType<ISVGFEComponentTransferElement, haxe.extern.EitherType<ISVGFECompositeElement, haxe.extern.EitherType<ISVGFEConvolveMatrixElement, haxe.extern.EitherType<ISVGFEDiffuseLightingElement, haxe.extern.EitherType<ISVGFEDisplacementMapElement, haxe.extern.EitherType<ISVGFEDistantLightElement, haxe.extern.EitherType<ISVGFEFloodElement, haxe.extern.EitherType<ISVGFEFuncAElement, haxe.extern.EitherType<ISVGFEFuncBElement, haxe.extern.EitherType<ISVGFEFuncGElement, haxe.extern.EitherType<ISVGFEFuncRElement, haxe.extern.EitherType<ISVGFEGaussianBlurElement, haxe.extern.EitherType<ISVGFEImageElement, haxe.extern.EitherType<ISVGFEMergeElement, haxe.extern.EitherType<ISVGFEMergeNodeElement, haxe.extern.EitherType<ISVGFEMorphologyElement, haxe.extern.EitherType<ISVGFEOffsetElement, haxe.extern.EitherType<ISVGFEPointLightElement, haxe.extern.EitherType<ISVGFESpecularLightingElement, haxe.extern.EitherType<ISVGFESpotLightElement, haxe.extern.EitherType<ISVGFETileElement, haxe.extern.EitherType<ISVGFETurbulenceElement, haxe.extern.EitherType<ISVGFilterElement, haxe.extern.EitherType<ISVGForeignObjectElement, haxe.extern.EitherType<ISVGGElement, haxe.extern.EitherType<ISVGImageElement, haxe.extern.EitherType<ISVGLineElement, haxe.extern.EitherType<ISVGLinearGradientElement, haxe.extern.EitherType<ISVGMarkerElement, haxe.extern.EitherType<ISVGMaskElement, haxe.extern.EitherType<ISVGMetadataElement, haxe.extern.EitherType<ISVGPathElement, haxe.extern.EitherType<ISVGPatternElement, haxe.extern.EitherType<ISVGPolygonElement, haxe.extern.EitherType<ISVGPolylineElement, haxe.extern.EitherType<ISVGRadialGradientElement, haxe.extern.EitherType<ISVGRectElement, haxe.extern.EitherType<ISVGStopElement, haxe.extern.EitherType<ISVGSVGElement, haxe.extern.EitherType<ISVGSwitchElement, haxe.extern.EitherType<ISVGTextElement, haxe.extern.EitherType<ISVGTextPathElement, haxe.extern.EitherType<ISVGTSpanElement, haxe.extern.EitherType<ISVGUseElement, ISVGViewElement>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> { })
	@:overload(function<E>(selector:String):Null<E> { })
	function closest<K>(selector:K):Null<haxe.extern.EitherType<IHTMLAnchorElement, haxe.extern.EitherType<IHTMLElement, haxe.extern.EitherType<IHTMLAppletElement, haxe.extern.EitherType<IHTMLScriptElement, haxe.extern.EitherType<IHTMLEmbedElement, haxe.extern.EitherType<ts.lib.IHTMLFormElement, haxe.extern.EitherType<IHTMLHeadElement, haxe.extern.EitherType<IHTMLImageElement, haxe.extern.EitherType<IHTMLAreaElement, haxe.extern.EitherType<IHTMLPreElement, haxe.extern.EitherType<IHTMLObjectElement, haxe.extern.EitherType<IHTMLAudioElement, haxe.extern.EitherType<IHTMLBaseElement, haxe.extern.EitherType<IHTMLBaseFontElement, haxe.extern.EitherType<IHTMLQuoteElement, haxe.extern.EitherType<IHTMLBodyElement, haxe.extern.EitherType<IHTMLBRElement, haxe.extern.EitherType<IHTMLButtonElement, haxe.extern.EitherType<IHTMLCanvasElement, haxe.extern.EitherType<IHTMLTableCaptionElement, haxe.extern.EitherType<IHTMLTableColElement, haxe.extern.EitherType<IHTMLDataElement, haxe.extern.EitherType<IHTMLDataListElement, haxe.extern.EitherType<IHTMLModElement, haxe.extern.EitherType<IHTMLDetailsElement, haxe.extern.EitherType<IHTMLDialogElement, haxe.extern.EitherType<IHTMLDirectoryElement, haxe.extern.EitherType<IHTMLDivElement, haxe.extern.EitherType<IHTMLDListElement, haxe.extern.EitherType<IHTMLFieldSetElement, haxe.extern.EitherType<IHTMLFontElement, haxe.extern.EitherType<IHTMLFrameElement, haxe.extern.EitherType<IHTMLFrameSetElement, haxe.extern.EitherType<IHTMLHeadingElement, haxe.extern.EitherType<IHTMLHRElement, haxe.extern.EitherType<IHTMLHtmlElement, haxe.extern.EitherType<IHTMLIFrameElement, haxe.extern.EitherType<IHTMLInputElement, haxe.extern.EitherType<IHTMLLabelElement, haxe.extern.EitherType<IHTMLLegendElement, haxe.extern.EitherType<IHTMLLIElement, haxe.extern.EitherType<IHTMLLinkElement, haxe.extern.EitherType<IHTMLMapElement, haxe.extern.EitherType<IHTMLMarqueeElement, haxe.extern.EitherType<IHTMLMenuElement, haxe.extern.EitherType<IHTMLMetaElement, haxe.extern.EitherType<IHTMLMeterElement, haxe.extern.EitherType<IHTMLOListElement, haxe.extern.EitherType<IHTMLOptGroupElement, haxe.extern.EitherType<IHTMLOptionElement, haxe.extern.EitherType<IHTMLOutputElement, haxe.extern.EitherType<IHTMLParagraphElement, haxe.extern.EitherType<IHTMLParamElement, haxe.extern.EitherType<IHTMLPictureElement, haxe.extern.EitherType<IHTMLProgressElement, haxe.extern.EitherType<ts.lib.IHTMLSelectElement, haxe.extern.EitherType<IHTMLSlotElement, haxe.extern.EitherType<IHTMLSourceElement, haxe.extern.EitherType<IHTMLSpanElement, haxe.extern.EitherType<IHTMLStyleElement, haxe.extern.EitherType<IHTMLTableElement, haxe.extern.EitherType<IHTMLTableSectionElement, haxe.extern.EitherType<IHTMLTableDataCellElement, haxe.extern.EitherType<IHTMLTemplateElement, haxe.extern.EitherType<IHTMLTextAreaElement, haxe.extern.EitherType<IHTMLTableHeaderCellElement, haxe.extern.EitherType<IHTMLTimeElement, haxe.extern.EitherType<IHTMLTitleElement, haxe.extern.EitherType<IHTMLTableRowElement, haxe.extern.EitherType<IHTMLTrackElement, haxe.extern.EitherType<IHTMLUListElement, IHTMLVideoElement>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
	/**
		Returns element's first attribute whose qualified name is qualifiedName, and null if there is no such attribute otherwise.
	**/
	function getAttribute(qualifiedName:String):Null<String>;
	/**
		Returns element's attribute whose namespace is namespace and local name is localName, and null if there is no such attribute otherwise.
	**/
	function getAttributeNS(namespace:Null<String>, localName:String):Null<String>;
	/**
		Returns the qualified names of all element's attributes. Can contain duplicates.
	**/
	function getAttributeNames():std.Array<String>;
	function getAttributeNode(name:String):Null<IAttr>;
	function getAttributeNodeNS(namespaceURI:String, localName:String):Null<IAttr>;
	function getBoundingClientRect():IDOMRect;
	function getClientRects():ts.lib.IDOMRectList;
	/**
		Returns a HTMLCollection of the elements in the object on which the method was invoked (a document or an element) that have all the classes given by classNames. The classNames argument is interpreted as a space-separated list of classes.
	**/
	function getElementsByClassName(classNames:String):ts.lib.HTMLCollectionOf<IElement>;
	@:overload(function<K>(qualifiedName:K):ts.lib.HTMLCollectionOf<haxe.extern.EitherType<ISVGScriptElement, haxe.extern.EitherType<ISVGSymbolElement, haxe.extern.EitherType<ISVGAElement, haxe.extern.EitherType<ISVGStyleElement, haxe.extern.EitherType<ISVGTitleElement, haxe.extern.EitherType<ISVGCircleElement, haxe.extern.EitherType<ISVGClipPathElement, haxe.extern.EitherType<ISVGDefsElement, haxe.extern.EitherType<ISVGDescElement, haxe.extern.EitherType<ISVGEllipseElement, haxe.extern.EitherType<ISVGFEBlendElement, haxe.extern.EitherType<ISVGFEColorMatrixElement, haxe.extern.EitherType<ISVGFEComponentTransferElement, haxe.extern.EitherType<ISVGFECompositeElement, haxe.extern.EitherType<ISVGFEConvolveMatrixElement, haxe.extern.EitherType<ISVGFEDiffuseLightingElement, haxe.extern.EitherType<ISVGFEDisplacementMapElement, haxe.extern.EitherType<ISVGFEDistantLightElement, haxe.extern.EitherType<ISVGFEFloodElement, haxe.extern.EitherType<ISVGFEFuncAElement, haxe.extern.EitherType<ISVGFEFuncBElement, haxe.extern.EitherType<ISVGFEFuncGElement, haxe.extern.EitherType<ISVGFEFuncRElement, haxe.extern.EitherType<ISVGFEGaussianBlurElement, haxe.extern.EitherType<ISVGFEImageElement, haxe.extern.EitherType<ISVGFEMergeElement, haxe.extern.EitherType<ISVGFEMergeNodeElement, haxe.extern.EitherType<ISVGFEMorphologyElement, haxe.extern.EitherType<ISVGFEOffsetElement, haxe.extern.EitherType<ISVGFEPointLightElement, haxe.extern.EitherType<ISVGFESpecularLightingElement, haxe.extern.EitherType<ISVGFESpotLightElement, haxe.extern.EitherType<ISVGFETileElement, haxe.extern.EitherType<ISVGFETurbulenceElement, haxe.extern.EitherType<ISVGFilterElement, haxe.extern.EitherType<ISVGForeignObjectElement, haxe.extern.EitherType<ISVGGElement, haxe.extern.EitherType<ISVGImageElement, haxe.extern.EitherType<ISVGLineElement, haxe.extern.EitherType<ISVGLinearGradientElement, haxe.extern.EitherType<ISVGMarkerElement, haxe.extern.EitherType<ISVGMaskElement, haxe.extern.EitherType<ISVGMetadataElement, haxe.extern.EitherType<ISVGPathElement, haxe.extern.EitherType<ISVGPatternElement, haxe.extern.EitherType<ISVGPolygonElement, haxe.extern.EitherType<ISVGPolylineElement, haxe.extern.EitherType<ISVGRadialGradientElement, haxe.extern.EitherType<ISVGRectElement, haxe.extern.EitherType<ISVGStopElement, haxe.extern.EitherType<ISVGSVGElement, haxe.extern.EitherType<ISVGSwitchElement, haxe.extern.EitherType<ISVGTextElement, haxe.extern.EitherType<ISVGTextPathElement, haxe.extern.EitherType<ISVGTSpanElement, haxe.extern.EitherType<ISVGUseElement, ISVGViewElement>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> { })
	@:overload(function(qualifiedName:String):ts.lib.HTMLCollectionOf<IElement> { })
	function getElementsByTagName<K>(qualifiedName:K):ts.lib.HTMLCollectionOf<haxe.extern.EitherType<IHTMLAnchorElement, haxe.extern.EitherType<IHTMLElement, haxe.extern.EitherType<IHTMLAppletElement, haxe.extern.EitherType<IHTMLScriptElement, haxe.extern.EitherType<IHTMLEmbedElement, haxe.extern.EitherType<ts.lib.IHTMLFormElement, haxe.extern.EitherType<IHTMLHeadElement, haxe.extern.EitherType<IHTMLImageElement, haxe.extern.EitherType<IHTMLAreaElement, haxe.extern.EitherType<IHTMLPreElement, haxe.extern.EitherType<IHTMLObjectElement, haxe.extern.EitherType<IHTMLAudioElement, haxe.extern.EitherType<IHTMLBaseElement, haxe.extern.EitherType<IHTMLBaseFontElement, haxe.extern.EitherType<IHTMLQuoteElement, haxe.extern.EitherType<IHTMLBodyElement, haxe.extern.EitherType<IHTMLBRElement, haxe.extern.EitherType<IHTMLButtonElement, haxe.extern.EitherType<IHTMLCanvasElement, haxe.extern.EitherType<IHTMLTableCaptionElement, haxe.extern.EitherType<IHTMLTableColElement, haxe.extern.EitherType<IHTMLDataElement, haxe.extern.EitherType<IHTMLDataListElement, haxe.extern.EitherType<IHTMLModElement, haxe.extern.EitherType<IHTMLDetailsElement, haxe.extern.EitherType<IHTMLDialogElement, haxe.extern.EitherType<IHTMLDirectoryElement, haxe.extern.EitherType<IHTMLDivElement, haxe.extern.EitherType<IHTMLDListElement, haxe.extern.EitherType<IHTMLFieldSetElement, haxe.extern.EitherType<IHTMLFontElement, haxe.extern.EitherType<IHTMLFrameElement, haxe.extern.EitherType<IHTMLFrameSetElement, haxe.extern.EitherType<IHTMLHeadingElement, haxe.extern.EitherType<IHTMLHRElement, haxe.extern.EitherType<IHTMLHtmlElement, haxe.extern.EitherType<IHTMLIFrameElement, haxe.extern.EitherType<IHTMLInputElement, haxe.extern.EitherType<IHTMLLabelElement, haxe.extern.EitherType<IHTMLLegendElement, haxe.extern.EitherType<IHTMLLIElement, haxe.extern.EitherType<IHTMLLinkElement, haxe.extern.EitherType<IHTMLMapElement, haxe.extern.EitherType<IHTMLMarqueeElement, haxe.extern.EitherType<IHTMLMenuElement, haxe.extern.EitherType<IHTMLMetaElement, haxe.extern.EitherType<IHTMLMeterElement, haxe.extern.EitherType<IHTMLOListElement, haxe.extern.EitherType<IHTMLOptGroupElement, haxe.extern.EitherType<IHTMLOptionElement, haxe.extern.EitherType<IHTMLOutputElement, haxe.extern.EitherType<IHTMLParagraphElement, haxe.extern.EitherType<IHTMLParamElement, haxe.extern.EitherType<IHTMLPictureElement, haxe.extern.EitherType<IHTMLProgressElement, haxe.extern.EitherType<ts.lib.IHTMLSelectElement, haxe.extern.EitherType<IHTMLSlotElement, haxe.extern.EitherType<IHTMLSourceElement, haxe.extern.EitherType<IHTMLSpanElement, haxe.extern.EitherType<IHTMLStyleElement, haxe.extern.EitherType<IHTMLTableElement, haxe.extern.EitherType<IHTMLTableSectionElement, haxe.extern.EitherType<IHTMLTableDataCellElement, haxe.extern.EitherType<IHTMLTemplateElement, haxe.extern.EitherType<IHTMLTextAreaElement, haxe.extern.EitherType<IHTMLTableHeaderCellElement, haxe.extern.EitherType<IHTMLTimeElement, haxe.extern.EitherType<IHTMLTitleElement, haxe.extern.EitherType<IHTMLTableRowElement, haxe.extern.EitherType<IHTMLTrackElement, haxe.extern.EitherType<IHTMLUListElement, IHTMLVideoElement>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
	@:overload(function(namespaceURI:String, localName:String):ts.lib.HTMLCollectionOf<ISVGElement> { })
	@:overload(function(namespaceURI:String, localName:String):ts.lib.HTMLCollectionOf<IElement> { })
	function getElementsByTagNameNS(namespaceURI:String, localName:String):ts.lib.HTMLCollectionOf<IHTMLElement>;
	/**
		Returns true if element has an attribute whose qualified name is qualifiedName, and false otherwise.
	**/
	function hasAttribute(qualifiedName:String):Bool;
	/**
		Returns true if element has an attribute whose namespace is namespace and local name is localName.
	**/
	function hasAttributeNS(namespace:Null<String>, localName:String):Bool;
	/**
		Returns true if element has attributes, and false otherwise.
	**/
	function hasAttributes():Bool;
	function hasPointerCapture(pointerId:Float):Bool;
	function insertAdjacentElement(position:String, insertedElement:IElement):Null<IElement>;
	function insertAdjacentHTML(where:String, html:String):Void;
	function insertAdjacentText(where:String, text:String):Void;
	/**
		Returns true if matching selectors against element's root yields element, and false otherwise.
	**/
	function matches(selectors:String):Bool;
	function msGetRegionContent():Any;
	function releasePointerCapture(pointerId:Float):Void;
	/**
		Removes element's first attribute whose qualified name is qualifiedName.
	**/
	function removeAttribute(qualifiedName:String):Void;
	/**
		Removes element's attribute whose namespace is namespace and local name is localName.
	**/
	function removeAttributeNS(namespace:Null<String>, localName:String):Void;
	function removeAttributeNode(attr:IAttr):IAttr;
	/**
		Displays element fullscreen and resolves promise when done.
		
		When supplied, options's navigationUI member indicates whether showing navigation UI while in fullscreen is preferred or not. If set to "show", navigation simplicity is preferred over screen space, and if set to "hide", more screen space is preferred. User agents are always free to honor user preference over the application's. The default value "auto" indicates no application preference.
	**/
	function requestFullscreen(?options:FullscreenOptions):ts.lib.IPromise<Void>;
	function requestPointerLock():Void;
	@:overload(function(x:Float, y:Float):Void { })
	function scroll(?options:ScrollToOptions):Void;
	@:overload(function(x:Float, y:Float):Void { })
	function scrollBy(?options:ScrollToOptions):Void;
	function scrollIntoView(?arg:haxe.extern.EitherType<Bool, ScrollIntoViewOptions>):Void;
	@:overload(function(x:Float, y:Float):Void { })
	function scrollTo(?options:ScrollToOptions):Void;
	/**
		Sets the value of element's first attribute whose qualified name is qualifiedName to value.
	**/
	function setAttribute(qualifiedName:String, value:String):Void;
	/**
		Sets the value of element's attribute whose namespace is namespace and local name is localName to value.
	**/
	function setAttributeNS(namespace:Null<String>, qualifiedName:String, value:String):Void;
	function setAttributeNode(attr:IAttr):Null<IAttr>;
	function setAttributeNodeNS(attr:IAttr):Null<IAttr>;
	function setPointerCapture(pointerId:Float):Void;
	/**
		If force is not given, "toggles" qualifiedName, removing it if it is present and adding it if it is not present. If force is true, adds qualifiedName. If force is false, removes qualifiedName.
		
		Returns true if qualifiedName is now present, and false otherwise.
	**/
	function toggleAttribute(qualifiedName:String, ?force:Bool):Bool;
	function webkitMatchesSelector(selectors:String):Bool;
	/**
		Appends an event listener for events whose type attribute value is type. The callback argument sets the callback that will be invoked when the event is dispatched.
		
		The options argument sets listener-specific options. For compatibility this can be a boolean, in which case the method behaves exactly as if the value was specified as options's capture.
		
		When set to true, options's capture prevents callback from being invoked when the event's eventPhase attribute value is BUBBLING_PHASE. When false (or not present), callback will not be invoked when event's eventPhase attribute value is CAPTURING_PHASE. Either way, callback will be invoked if event's eventPhase attribute value is AT_TARGET.
		
		When set to true, options's passive indicates that the callback will not cancel the event by invoking preventDefault(). This is used to enable performance optimizations described in §2.8 Observing event listeners.
		
		When set to true, options's once indicates that the callback will only be invoked once after which the event listener will be removed.
		
		The event listener is appended to target's event listener list and is not appended if it has the same type, callback, and capture.
		
		Appends an event listener for events whose type attribute value is type. The callback argument sets the callback that will be invoked when the event is dispatched.
		
		The options argument sets listener-specific options. For compatibility this can be a boolean, in which case the method behaves exactly as if the value was specified as options's capture.
		
		When set to true, options's capture prevents callback from being invoked when the event's eventPhase attribute value is BUBBLING_PHASE. When false (or not present), callback will not be invoked when event's eventPhase attribute value is CAPTURING_PHASE. Either way, callback will be invoked if event's eventPhase attribute value is AT_TARGET.
		
		When set to true, options's passive indicates that the callback will not cancel the event by invoking preventDefault(). This is used to enable performance optimizations described in §2.8 Observing event listeners.
		
		When set to true, options's once indicates that the callback will only be invoked once after which the event listener will be removed.
		
		The event listener is appended to target's event listener list and is not appended if it has the same type, callback, and capture.
	**/
	@:overload(function(type:String, listener:haxe.extern.EitherType<EventListener, EventListenerObject>, ?options:haxe.extern.EitherType<Bool, AddEventListenerOptions>):Void { })
	function addEventListener<K>(type:K, listener:(ev:IEvent) -> Any, ?options:haxe.extern.EitherType<Bool, AddEventListenerOptions>):Void;
	/**
		Removes the event listener in target's event listener list with the same type, callback, and options.
		
		Removes the event listener in target's event listener list with the same type, callback, and options.
	**/
	@:overload(function(type:String, listener:haxe.extern.EitherType<EventListener, EventListenerObject>, ?options:haxe.extern.EitherType<Bool, EventListenerOptions>):Void { })
	function removeEventListener<K>(type:K, listener:(ev:IEvent) -> Any, ?options:haxe.extern.EitherType<Bool, EventListenerOptions>):Void;
	static var prototype : IElement;
}
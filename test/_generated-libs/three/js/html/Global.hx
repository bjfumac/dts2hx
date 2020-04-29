package js.html;
@:native("") extern class Global {
	/**
		An object used to filter the nodes in a NodeIterator or TreeWalker. They don't know anything about the DOM or how to traverse nodes; they just know how to evaluate a single node against the provided filter.
	**/
	static var NodeFilter : { final FILTER_ACCEPT : Float; final FILTER_REJECT : Float; final FILTER_SKIP : Float; final SHOW_ALL : Float; final SHOW_ATTRIBUTE : Float; final SHOW_CDATA_SECTION : Float; final SHOW_COMMENT : Float; final SHOW_DOCUMENT : Float; final SHOW_DOCUMENT_FRAGMENT : Float; final SHOW_DOCUMENT_TYPE : Float; final SHOW_ELEMENT : Float; final SHOW_ENTITY : Float; final SHOW_ENTITY_REFERENCE : Float; final SHOW_NOTATION : Float; final SHOW_PROCESSING_INSTRUCTION : Float; final SHOW_TEXT : Float; };
	/**
		Used to reflect the zoomAndPan attribute, and is mixed in to other interfaces for elements that support this attribute.
	**/
	static var SVGZoomAndPan : { final SVG_ZOOMANDPAN_DISABLE : Float; final SVG_ZOOMANDPAN_MAGNIFY : Float; final SVG_ZOOMANDPAN_UNKNOWN : Float; };
}
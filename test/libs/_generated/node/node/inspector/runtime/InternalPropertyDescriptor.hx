package node.inspector.runtime;
/**
	Object internal property descriptor. This property isn't normally visible in JavaScript code.
**/
extern interface InternalPropertyDescriptor {
	/**
		Conventional property name.
	**/
	var name : String;
	/**
		The value associated with the property.
	**/
	@:optional
	var value : Null<RemoteObject>;
}
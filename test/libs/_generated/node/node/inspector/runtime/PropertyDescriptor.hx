package node.inspector.runtime;
/**
	Object property descriptor.
**/
extern interface PropertyDescriptor {
	/**
		Property name or symbol description.
	**/
	var name : String;
	/**
		The value associated with the property.
	**/
	@:optional
	var value : Null<RemoteObject>;
	/**
		True if the value associated with the property may be changed (data descriptors only).
	**/
	@:optional
	var writable : Null<Bool>;
	/**
		A function which serves as a getter for the property, or `undefined` if there is no getter
		(accessor descriptors only).
	**/
	@:optional
	var get : Null<RemoteObject>;
	/**
		A function which serves as a setter for the property, or `undefined` if there is no setter
		(accessor descriptors only).
	**/
	@:optional
	var set : Null<RemoteObject>;
	/**
		True if the type of this property descriptor may be changed and if the property may be
		deleted from the corresponding object.
	**/
	var configurable : Bool;
	/**
		True if this property shows up during enumeration of the properties on the corresponding
		object.
	**/
	var enumerable : Bool;
	/**
		True if the result was thrown during the evaluation.
	**/
	@:optional
	var wasThrown : Null<Bool>;
	/**
		True if the property is owned for the object.
	**/
	@:optional
	var isOwn : Null<Bool>;
	/**
		Property symbol object, if the property is of the `symbol` type.
	**/
	@:optional
	var symbol : Null<RemoteObject>;
}
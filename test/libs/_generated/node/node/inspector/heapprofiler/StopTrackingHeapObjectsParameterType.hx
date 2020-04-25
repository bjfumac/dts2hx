package node.inspector.heapprofiler;
extern interface StopTrackingHeapObjectsParameterType {
	/**
		If true 'reportHeapSnapshotProgress' events will be generated while snapshot is being taken
		when the tracking is stopped.
	**/
	@:optional
	var reportProgress : Null<Bool>;
}
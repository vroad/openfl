package openfl.events; #if !flash


/**
 * The EventPhase class provides values for the <code>eventPhase</code>
 * property of the Event class.
 */
#if openfl_shared
@:jsRequire("openfl", "openfl_events_EventPhase") extern
#end
enum EventPhase {
	
	CAPTURING_PHASE;
	AT_TARGET;
	BUBBLING_PHASE;
	
}


#else
typedef EventPhase = flash.events.EventPhase;
#end
package openfl.system; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_system_TouchscreenType") extern
#end
enum TouchscreenType {
	
	FINGER;
	NONE;
	STYLUS;
	
}


#else
typedef TouchscreenType = flash.system.TouchscreenType;
#end
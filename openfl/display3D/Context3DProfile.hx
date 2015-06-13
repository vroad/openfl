package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DProfile") extern
#end
enum Context3DProfile {
	
	BASELINE;
	BASELINE_CONSTRAINED;
	BASELINE_EXTENDED;
	
}


#else
typedef Context3DProfile = flash.display3D.Context3DProfile;
#end
package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DWrapMode") extern
#end
enum Context3DWrapMode {
	
	CLAMP;
	REPEAT;
	
}


#else
typedef Context3DWrapMode = flash.display3D.Context3DWrapMode;
#end
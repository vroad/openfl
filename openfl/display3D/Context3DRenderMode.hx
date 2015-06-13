package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DRenderMode") extern
#end
enum Context3DRenderMode {
	
	AUTO;
	SOFTWARE;
	
}


#else
typedef Context3DRenderMode = flash.display3D.Context3DRenderMode;
#end
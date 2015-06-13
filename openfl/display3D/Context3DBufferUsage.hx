package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DBufferUsage") extern
#end
enum Context3DBufferUsage {
	
	STATIC_DRAW;
	DYNAMIC_DRAW;
	
}

#else
typedef Context3DBufferUsage = flash.display3D.Context3DBufferUsage;
#end
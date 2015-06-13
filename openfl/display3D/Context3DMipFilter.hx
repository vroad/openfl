package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DMipFilter") extern
#end
enum Context3DMipFilter {
	
	MIPLINEAR;
	MIPNEAREST;
	MIPNONE;

}


#else
typedef Context3DMipFilter = flash.display3D.Context3DMipFilter;
#end
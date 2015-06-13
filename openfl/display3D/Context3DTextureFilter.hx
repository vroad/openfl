package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DTextureFilter") extern
#end
enum Context3DTextureFilter {
	
	ANISOTROPIC2X;
	ANISOTROPIC4X;
	ANISOTROPIC8X;
	ANISOTROPIC16X;
	LINEAR;
	NEAREST;
	
}


#else
typedef Context3DTextureFilter = flash.display3D.Context3DTextureFilter;
#end
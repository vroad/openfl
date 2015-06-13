package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DTextureFormat") extern
#end
enum Context3DTextureFormat {
	
	BGRA;
	COMPRESSED;
	COMPRESSED_ALPHA;
	ALPHA;
	
}


#else
typedef Context3DTextureFormat = flash.display3D.Context3DTextureFormat;
#end
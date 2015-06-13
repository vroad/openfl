package openfl.display3D; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DVertexBufferFormat") extern
#end
enum Context3DVertexBufferFormat {
	
	BYTES_4;
	FLOAT_1;
	FLOAT_2;
	FLOAT_3;
	FLOAT_4;
	
}


#else
typedef Context3DVertexBufferFormat = flash.display3D.Context3DVertexBufferFormat;
#end
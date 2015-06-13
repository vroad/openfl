package openfl.display3D; #if !flash


import openfl.gl.GL;

#if openfl_shared
@:jsRequire("openfl", "openfl_display3D_Context3DProgramType") extern
#end
enum Context3DProgramType {
	
	VERTEX;
	FRAGMENT;
	
}


#else
typedef Context3DProgramType = flash.display3D.Context3DProgramType;
#end
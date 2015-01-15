package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GL = openfl._v2.gl.GL;
#else
typedef GL = lime.graphics.opengl.GL;
#end
package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLObject = openfl._v2.gl.GLObject;
#else
typedef GLObject = lime.graphics.opengl.GLObject;
#end
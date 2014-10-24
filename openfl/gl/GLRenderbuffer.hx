package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLRenderbuffer = openfl._v2.gl.GLRenderbuffer;
#else
typedef GLRenderbuffer = lime.graphics.opengl.GLRenderbuffer;
#end
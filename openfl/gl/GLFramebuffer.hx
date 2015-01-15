package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLFramebuffer = openfl._v2.gl.GLFramebuffer;
#else
typedef GLFramebuffer = lime.graphics.opengl.GLFramebuffer;
#end
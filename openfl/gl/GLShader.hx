package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLShader = openfl._v2.gl.GLShader;
#else
typedef GLShader = lime.graphics.opengl.GLShader;
#end
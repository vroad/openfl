package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLProgram = openfl._v2.gl.GLProgram;
#else
typedef GLProgram = lime.graphics.opengl.GLProgram;
#end
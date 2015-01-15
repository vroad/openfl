package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLActiveInfo = openfl._v2.gl.GLActiveInfo;
#else
typedef GLActiveInfo = lime.graphics.opengl.GLActiveInfo;
#end
package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLContextAttributes = openfl._v2.gl.GLContextAttributes;
#else
typedef GLContextAttributes = lime.graphics.opengl.GLContextAttributes;
#end
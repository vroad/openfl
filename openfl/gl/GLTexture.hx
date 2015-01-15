package openfl.gl;


#if (!openfl_next && !flash && !html5 && !display)
typedef GLTexture = openfl._v2.gl.GLTexture;
#else
typedef GLTexture = lime.graphics.opengl.GLTexture;
#end
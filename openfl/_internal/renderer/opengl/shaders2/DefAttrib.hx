package openfl._internal.renderer.opengl.shaders2;

// TODO Find a way to apply these default attributes and uniforms to other shaders
@:enum abstract DefAttrib(String) from String to String {
	var Position = "openfl_aPosition";
	var TexCoord = "openfl_aTexCoord0";
	var Color = "openfl_aColor";
}
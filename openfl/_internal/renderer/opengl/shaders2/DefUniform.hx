package openfl._internal.renderer.opengl.shaders2;

@:enum abstract DefUniform(String) from String to String {
	var Sampler = "openfl_uSampler0";
	var ProjectionMatrix = "openfl_uProjectionMatrix";
	var Color = "openfl_uColor";
	var Alpha = "openfl_uAlpha";
	var ColorMultiplier = "openfl_uColorMultiplier";
	var ColorOffset = "openfl_uColorOffset";
	var UseColorTransform = "openfl_uUseColorTransform";
}
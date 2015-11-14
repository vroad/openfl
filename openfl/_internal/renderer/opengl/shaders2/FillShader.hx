package openfl._internal.renderer.opengl.shaders2;

import lime.graphics.GLRenderContext;
import openfl._internal.renderer.opengl.shaders2.DefAttrib;
import openfl._internal.renderer.opengl.shaders2.DefUniform;

class FillShader extends Shader {

	public function new(gl:GLRenderContext) {
		super(gl);
		
		vertexSrc = [
			'attribute vec2 ${FillAttrib.Position};',
			'uniform mat3 ${FillUniform.TranslationMatrix};',
			'uniform mat3 ${FillUniform.ProjectionMatrix};',
			
			'uniform vec4 ${FillUniform.Color};',
			'uniform float ${FillUniform.Alpha};',
			'uniform vec4 ${FillUniform.ColorMultiplier};',
			'uniform vec4 ${FillUniform.ColorOffset};',
			
			'varying vec4 vColor;',
			
			'vec4 colorTransform(const vec4 color, const float alpha, const vec4 multiplier, const vec4 offset) {',
			'   vec4 result = color * multiplier;',
			'   result.a *= alpha;',
			'   result = result + offset;',
			'   result = clamp(result, 0., 1.);',
			'   result = vec4(result.rgb * result.a, result.a);',
			'   return result;',
			'}',			
			
			'void main(void) {',
			'   gl_Position = vec4((${FillUniform.ProjectionMatrix} * ${FillUniform.TranslationMatrix} * vec3(${FillAttrib.Position}, 1.0)).xy, 0.0, 1.0);',
			'   vColor = colorTransform(${FillUniform.Color}, ${FillUniform.Alpha}, ${FillUniform.ColorMultiplier}, ${FillUniform.ColorOffset});',
			'}'

		];
		
		fragmentSrc = [
			'#ifdef GL_ES',
			'precision lowp float;',
			'#endif',
			
			'varying vec4 vColor;',
			
			'void main(void) {',
			'   gl_FragColor = vColor;',
			'}'
		];
		
		init ();
	}
	
	override private function init(force:Bool = false) {
		super.init(force);
		
		getAttribLocation(FillAttrib.Position);
		getUniformLocation(FillUniform.TranslationMatrix);
		getUniformLocation(FillUniform.ProjectionMatrix);
		getUniformLocation(FillUniform.Color);
		getUniformLocation(FillUniform.ColorMultiplier);
		getUniformLocation(FillUniform.ColorOffset);
	}
	
}

@:enum abstract FillAttrib(String) from String to String {
	var Position = DefAttrib.Position;
}

@:enum abstract FillUniform(String) from String to String {
	var TranslationMatrix = "openfl_uTranslationMatrix";
	var ProjectionMatrix = DefUniform.ProjectionMatrix;
	var Color = DefUniform.Color;
	var Alpha = DefUniform.Alpha;
	var ColorMultiplier = DefUniform.ColorMultiplier;
	var ColorOffset = DefUniform.ColorOffset;
}
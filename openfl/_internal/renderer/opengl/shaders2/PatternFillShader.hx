package openfl._internal.renderer.opengl.shaders2;

import lime.graphics.GLRenderContext;
import openfl._internal.renderer.opengl.shaders2.DefAttrib;
import openfl._internal.renderer.opengl.shaders2.DefUniform;

class PatternFillShader extends Shader {

	public function new(gl:GLRenderContext) {
		super(gl);
		
		vertexSrc = [
			'attribute vec2 ${PatternFillAttrib.Position};',
			'uniform mat3 ${PatternFillUniform.TranslationMatrix};',
			'uniform mat3 ${PatternFillUniform.ProjectionMatrix};',
			'uniform mat3 ${PatternFillUniform.PatternMatrix};',
			
			'varying vec2 vPosition;',
			
			'void main(void) {',
			'   gl_Position = vec4((${PatternFillUniform.ProjectionMatrix} * ${PatternFillUniform.TranslationMatrix} * vec3(${PatternFillAttrib.Position}, 1.0)).xy, 0.0, 1.0);',
			'   vPosition = (${PatternFillUniform.PatternMatrix} * vec3(${PatternFillAttrib.Position}, 1)).xy;',
			'}'

		];
		
		fragmentSrc = [
			'#ifdef GL_ES',
			'precision lowp float;',
			'#endif',
			
			'uniform float ${PatternFillUniform.Alpha};',
			'uniform vec2 ${PatternFillUniform.PatternTL};',
			'uniform vec2 ${PatternFillUniform.PatternBR};',
			'uniform sampler2D ${PatternFillUniform.Sampler};',
			
			'uniform vec4 ${PatternFillUniform.ColorMultiplier};',
			'uniform vec4 ${PatternFillUniform.ColorOffset};',
			
			'varying vec2 vPosition;',
			
			'vec4 colorTransform(const vec4 color, const float alpha, const vec4 multiplier, const vec4 offset) {',
			'   vec4 unmultiply = vec4(color.rgb / color.a, color.a);',
			'   vec4 result = unmultiply * multiplier;',
			'   result.a *= alpha;',
			'   result = result + offset;',
			'   result = clamp(result, 0., 1.);',
			'   result = vec4(result.rgb * result.a, result.a);',
			'   return result;',
			'}',	
			
			'void main(void) {',
			'   vec2 pos = mix(${PatternFillUniform.PatternTL}, ${PatternFillUniform.PatternBR}, vPosition);',
			'   vec4 tcol = texture2D(${PatternFillUniform.Sampler}, pos);',
			'   gl_FragColor = colorTransform(tcol, ${PatternFillUniform.Alpha}, ${PatternFillUniform.ColorMultiplier}, ${PatternFillUniform.ColorOffset});',
			'}'
		];
		
		init();
	}
	
	override private function init(force:Bool = false) {
		super.init(force);
		
		getAttribLocation(PatternFillAttrib.Position);
		
		getUniformLocation(PatternFillUniform.TranslationMatrix);
		getUniformLocation(PatternFillUniform.PatternMatrix);
		getUniformLocation(PatternFillUniform.ProjectionMatrix);
		getUniformLocation(PatternFillUniform.Sampler);
		getUniformLocation(PatternFillUniform.PatternTL);
		getUniformLocation(PatternFillUniform.PatternBR);
		getUniformLocation(PatternFillUniform.Alpha);
		getUniformLocation(PatternFillUniform.ColorMultiplier);
		getUniformLocation(PatternFillUniform.ColorOffset);
	}
	
}

@:enum abstract PatternFillAttrib(String) to String from String {
	var Position = DefAttrib.Position;
}

@:enum abstract PatternFillUniform(String) from String to String {
	var TranslationMatrix = "openfl_uTranslationMatrix";
	var PatternMatrix = "openfl_uPatternMatrix";
	var PatternTL = "openfl_uPatternTL";
	var PatternBR = "openfl_uPatternBR";
	var Sampler = DefUniform.Sampler;
	var ProjectionMatrix = DefUniform.ProjectionMatrix;
	var Color = DefUniform.Color;
	var Alpha = DefUniform.Alpha;
	var ColorMultiplier = DefUniform.ColorMultiplier;
	var ColorOffset = DefUniform.ColorOffset;
	
}

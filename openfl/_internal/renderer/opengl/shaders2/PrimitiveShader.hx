package openfl._internal.renderer.opengl.shaders2;

import lime.graphics.GLRenderContext;
import openfl._internal.renderer.opengl.shaders2.DefAttrib;
import openfl._internal.renderer.opengl.shaders2.DefUniform;

class PrimitiveShader extends Shader {

	public function new(gl:GLRenderContext) {
		super(gl);
		
		vertexSrc  = [
			'attribute vec2 ${PrimitiveAttrib.Position};',
			'attribute vec4 ${PrimitiveAttrib.Color};',
			
			'uniform mat3 ${PrimitiveUniform.TranslationMatrix};',
			'uniform mat3 ${PrimitiveUniform.ProjectionMatrix};',
			'uniform vec4 ${PrimitiveUniform.ColorMultiplier};',
			'uniform vec4 ${PrimitiveUniform.ColorOffset};',
			'uniform float ${PrimitiveUniform.Alpha};',
			
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
			'   gl_Position = vec4((${PrimitiveUniform.ProjectionMatrix} * ${PrimitiveUniform.TranslationMatrix} * vec3(${PrimitiveAttrib.Position}, 1.0)).xy, 0.0, 1.0);',
			'   vColor = colorTransform(${PrimitiveAttrib.Color}, ${PrimitiveUniform.Alpha}, ${PrimitiveUniform.ColorMultiplier}, ${PrimitiveUniform.ColorOffset});',
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
		
		init();
	}
	
	override private function init(force:Bool = false) {
		super.init(force);
		
		getAttribLocation(PrimitiveAttrib.Position);
		getAttribLocation(PrimitiveAttrib.Color);
		getUniformLocation(PrimitiveUniform.TranslationMatrix);
		getUniformLocation(PrimitiveUniform.ProjectionMatrix);
		getUniformLocation(PrimitiveUniform.Alpha);
		getUniformLocation(PrimitiveUniform.ColorMultiplier);
		getUniformLocation(PrimitiveUniform.ColorOffset);
	}
	
}

@:enum abstract PrimitiveAttrib(String) to String from String {
	var Position = DefAttrib.Position;
	var Color = DefAttrib.Color;
}

@:enum abstract PrimitiveUniform(String) from String to String {
	var TranslationMatrix = "openfl_uTranslationMatrix";
	var ProjectionMatrix = DefUniform.ProjectionMatrix;
	var Alpha = DefUniform.Alpha;
	var ColorMultiplier = DefUniform.ColorMultiplier;
	var ColorOffset = DefUniform.ColorOffset;
}

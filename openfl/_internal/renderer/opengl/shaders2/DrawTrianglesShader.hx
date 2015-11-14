package openfl._internal.renderer.opengl.shaders2;

import lime.graphics.GLRenderContext;
import openfl._internal.renderer.opengl.shaders2.DefAttrib;
import openfl._internal.renderer.opengl.shaders2.DefUniform;


class DrawTrianglesShader extends Shader {

	public function new(gl:GLRenderContext) {
		super(gl);
		
		vertexSrc = [
			'attribute vec2 ${DrawTrianglesAttrib.Position};',
			'attribute vec2 ${DrawTrianglesAttrib.TexCoord};',
			'attribute vec4 ${DrawTrianglesAttrib.Color};',
			'uniform mat3 ${DrawTrianglesUniform.ProjectionMatrix};',
			
			'varying vec2 vTexCoord;',
			'varying vec4 vColor;',
		
			'void main(void) {',
			'   gl_Position = vec4((${DrawTrianglesUniform.ProjectionMatrix} * vec3(${DrawTrianglesAttrib.Position}, 1.0)).xy, 0.0, 1.0);',
			'   vTexCoord = ${DrawTrianglesAttrib.TexCoord};',
			// the passed color is ARGB format
			'   vColor = ${DrawTrianglesAttrib.Color}.bgra;',
			'}',

		];
		
		fragmentSrc = [
			'#ifdef GL_ES',
			'precision lowp float;',
			'#endif',
			
			'uniform sampler2D ${DrawTrianglesUniform.Sampler};',
			'uniform vec3 ${DrawTrianglesUniform.Color};',
			'uniform bool ${DrawTrianglesUniform.UseTexture};',
			'uniform float ${DrawTrianglesUniform.Alpha};',
			'uniform vec4 ${DrawTrianglesUniform.ColorMultiplier};',
			'uniform vec4 ${DrawTrianglesUniform.ColorOffset};',
			
			'varying vec2 vTexCoord;',
			'varying vec4 vColor;',
			
			'vec4 tmp;',
			
			'vec4 colorTransform(const vec4 color, const vec4 tint, const vec4 multiplier, const vec4 offset) {',
			'   vec4 unmultiply = vec4(color.rgb / color.a, color.a);',
			'   vec4 result = unmultiply * tint * multiplier;',
			'   result = result + offset;',
			'   result = clamp(result, 0., 1.);',
			'   result = vec4(result.rgb * result.a, result.a);',
			'   return result;',
			'}',
			
			'void main(void) {',
			'   if(${DrawTrianglesUniform.UseTexture}) {',
			'       tmp = texture2D(${DrawTrianglesUniform.Sampler}, vTexCoord);',
			'   } else {',
			'       tmp = vec4(${DrawTrianglesUniform.Color}, 1.);',
			'   }',
			'   gl_FragColor = colorTransform(tmp, vColor, ${DrawTrianglesUniform.ColorMultiplier}, ${DrawTrianglesUniform.ColorOffset});',
			'}'
		];
		
		init ();
	}
	
	override private function init(force:Bool = false) {
		super.init(force);
		
		getAttribLocation(DrawTrianglesAttrib.Position);
		getAttribLocation(DrawTrianglesAttrib.TexCoord);
		getAttribLocation(DrawTrianglesAttrib.Color);
		
		getUniformLocation(DrawTrianglesUniform.Sampler);
		getUniformLocation(DrawTrianglesUniform.ProjectionMatrix);
		getUniformLocation(DrawTrianglesUniform.Color);
		getUniformLocation(DrawTrianglesUniform.Alpha);
		getUniformLocation(DrawTrianglesUniform.UseTexture);
		getUniformLocation(DrawTrianglesUniform.ColorMultiplier);
		getUniformLocation(DrawTrianglesUniform.ColorOffset);
		
	}
	
}

@:enum abstract DrawTrianglesAttrib(String) from String to String {
	var Position = DefAttrib.Position;
	var TexCoord = DefAttrib.TexCoord;
	var Color = DefAttrib.Color;
}

@:enum abstract DrawTrianglesUniform(String) from String to String {
	var UseTexture = "openfl_uUseTexture";
	var Sampler = DefUniform.Sampler;
	var ProjectionMatrix = DefUniform.ProjectionMatrix;
	var Color = DefUniform.Color;
	var Alpha = DefUniform.Alpha;
	var ColorMultiplier = DefUniform.ColorMultiplier;
	var ColorOffset = DefUniform.ColorOffset;	
}
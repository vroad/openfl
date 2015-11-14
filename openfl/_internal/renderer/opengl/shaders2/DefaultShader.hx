package openfl._internal.renderer.opengl.shaders2;

import lime.graphics.GLRenderContext;


class DefaultShader extends Shader {
	
	public static var VERTEX_SRC(default, null) = [
			'attribute vec2 ${DefAttrib.Position};',
			'attribute vec2 ${DefAttrib.TexCoord};',
			'attribute vec4 ${DefAttrib.Color};',
			
			'uniform mat3 ${DefUniform.ProjectionMatrix};',
			'uniform bool ${DefUniform.UseColorTransform};',
			
			'varying vec2 ${DefVarying.TexCoord};',
			'varying vec4 ${DefVarying.Color};',
			
			'void main(void) {',
			'   gl_Position = vec4((${DefUniform.ProjectionMatrix} * vec3(${DefAttrib.Position}, 1.0)).xy, 0.0, 1.0);',
			'   ${DefVarying.TexCoord} = ${DefAttrib.TexCoord};',
			'   if(${DefUniform.UseColorTransform})',
			'   	${DefVarying.Color} = ${DefAttrib.Color};',
			'   else',
			#if (js && html5)
			'   	${DefVarying.Color} = vec4(${DefAttrib.Color}.rgb * ${DefAttrib.Color}.a, ${DefAttrib.Color}.a);',
			#else
			'   	${DefVarying.Color} = vec4(${DefAttrib.Color}.bgr * ${DefAttrib.Color}.a, ${DefAttrib.Color}.a);',
			#end
			'}'
		];

	public function new(gl:GLRenderContext) {
		super(gl);
		
		vertexSrc = VERTEX_SRC;
		
		fragmentSrc = [
			'#ifdef GL_ES',
			'precision lowp float;',
			'#endif',
			
			'uniform sampler2D ${DefUniform.Sampler};',
			'uniform vec4 ${DefUniform.ColorMultiplier};',
			'uniform vec4 ${DefUniform.ColorOffset};',
			'uniform bool ${DefUniform.UseColorTransform};',
			
			'varying vec2 ${DefVarying.TexCoord};',
			'varying vec4 ${DefVarying.Color};',
			
			'vec4 colorTransform(const vec4 color, const vec4 tint, const vec4 multiplier, const vec4 offset) {',
			'	if(!${DefUniform.UseColorTransform}) {',
			'		return color * tint;',
			'	}',
			
			'	vec4 unmultiply;',
			'	if (color.a == 0.0) {',
			'		unmultiply = vec4(0.0, 0.0, 0.0, 0.0);',
			'	} else {',
			'   	unmultiply = vec4(color.rgb / color.a, color.a);',
			'	}',
			'   vec4 result = unmultiply * tint * multiplier;',
			'   result = result + offset;',
			'   result = clamp(result, 0., 1.);',
			'   result = vec4(result.rgb * result.a, result.a);',
			'   return result;',
			'}',
			
			'void main(void) {',
			'   vec4 tc = texture2D(${DefUniform.Sampler}, ${DefVarying.TexCoord});',
			'   gl_FragColor = colorTransform(tc, ${DefVarying.Color}, ${DefUniform.ColorMultiplier}, ${DefUniform.ColorOffset});',
			'}'
		
		];
		
		init();
		
	}
	
	override private function init(force:Bool = false) {
		super.init(force);

		getAttribLocation(DefAttrib.Position);
		getAttribLocation(DefAttrib.TexCoord);
		getAttribLocation(DefAttrib.Color);
		getUniformLocation(DefUniform.ProjectionMatrix);
		getUniformLocation(DefUniform.Sampler);
		getUniformLocation(DefUniform.ColorMultiplier);
		getUniformLocation(DefUniform.ColorOffset);
		getUniformLocation(DefUniform.UseColorTransform);
	}
	
}

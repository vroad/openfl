package openfl._internal.renderer.opengl;


import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLES20;
import openfl._internal.renderer.AbstractBlendModeManager;
import openfl.display.BlendMode;


class GLBlendModeManager extends AbstractBlendModeManager {
	
	
	private var currentBlendMode:BlendMode;
	private var gl:GLRenderContext;
	
	
	public function new (gl:GLRenderContext) {
		
		super ();
		
		this.gl = gl;
		
		setBlendMode (NORMAL);
		gl.enable (GLES20.BLEND);
		
	}
	
	
	public override function setBlendMode (blendMode:BlendMode):Void {
		
		if (currentBlendMode == blendMode) return;
		
		currentBlendMode = blendMode;
		
		switch (blendMode) {
			
			case ADD:
				
				gl.blendEquation (GLES20.FUNC_ADD);
				gl.blendFunc (GLES20.ONE, GLES20.ONE);
			
			case MULTIPLY:
				
				gl.blendEquation (GLES20.FUNC_ADD);
				gl.blendFunc (GLES20.DST_COLOR, GLES20.ONE_MINUS_SRC_ALPHA);
			
			case SCREEN:
				
				gl.blendEquation (GLES20.FUNC_ADD);
				gl.blendFunc (GLES20.ONE, GLES20.ONE_MINUS_SRC_COLOR);
			
			case SUBTRACT:
				
				gl.blendEquation (GLES20.FUNC_REVERSE_SUBTRACT);
				gl.blendFunc (GLES20.ONE, GLES20.ONE);
			
			#if desktop
			case DARKEN:
				
				gl.blendEquation (0x8007); // GL_MIN
				gl.blendFunc (GLES20.ONE, GLES20.ONE);
				
			case LIGHTEN:
				
				gl.blendEquation (0x8008); // GL_MAX
				gl.blendFunc (GLES20.ONE, GLES20.ONE);
			#end
			
			default:
				
				gl.blendEquation (GLES20.FUNC_ADD);
				gl.blendFunc (GLES20.ONE, GLES20.ONE_MINUS_SRC_ALPHA);
			
		}
		
	}
	
	
}
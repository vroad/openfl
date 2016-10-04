package openfl._internal.renderer.opengl;


import lime.graphics.opengl.GLES20;
import lime.utils.Float32Array;
import openfl._internal.renderer.cairo.CairoGraphics;
import openfl._internal.renderer.canvas.CanvasGraphics;
import openfl._internal.renderer.RenderSession;
import openfl.display.DisplayObject;
import openfl.geom.Matrix;

@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Graphics)
@:access(openfl.filters.BitmapFilter)
@:access(openfl.geom.Matrix)


class GLShape {
	
	
	public static inline function render (shape:DisplayObject, renderSession:RenderSession):Void {
		
		if (!shape.__renderable || shape.__worldAlpha <= 0) return;
		
		var graphics = shape.__graphics;
		var gl = renderSession.gl;
		
		if (graphics != null) {
			
			#if (js && html5)
			CanvasGraphics.render (graphics, renderSession, shape.__renderTransform);
			#elseif lime_cairo
			CairoGraphics.render (graphics, renderSession, shape.__renderTransform);
			#end
			
			var bounds = graphics.__bounds;
			
			if (graphics.__bitmap != null && graphics.__visible) {
				
				renderSession.blendModeManager.setBlendMode (shape.blendMode);
				renderSession.filterManager.pushObject (shape);
				renderSession.maskManager.pushObject (shape);
				
				var renderer:GLRenderer = cast renderSession.renderer;
				var shader = renderSession.shaderManager.currentShader;
				
				gl.uniformMatrix4fv (shader.data.uMatrix.getUniformLocation (), false, renderer.getMatrix (graphics.__worldTransform));
				
				gl.bindTexture (GLES20.TEXTURE_2D, graphics.__bitmap.getTexture (gl));
				
				if (renderSession.allowSmoothing) {
					
					gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MAG_FILTER, GLES20.LINEAR);
					gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MIN_FILTER, GLES20.LINEAR);
					
				} else {
					
					gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MAG_FILTER, GLES20.NEAREST);
					gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MIN_FILTER, GLES20.NEAREST);
					
				}
				
				gl.bindBuffer (GLES20.ARRAY_BUFFER, graphics.__bitmap.getBuffer (gl, shape.__worldAlpha));
				gl.vertexAttribPointer (shader.data.aPosition.getAttributeLocation (), 3, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
				gl.vertexAttribPointer (shader.data.aTexCoord.getAttributeLocation (), 2, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer (shader.data.aAlpha.getAttributeLocation (), 1, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
				
				gl.drawArrays (GLES20.TRIANGLE_STRIP, 0, 4);
				
				renderSession.maskManager.popObject (shape);
				renderSession.filterManager.popObject (shape);
				
			}
			
		}
		
	}
	
	
}
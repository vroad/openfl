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
		
		if (graphics != null) {
			
			#if (js && html5)
			CanvasGraphics.render (graphics, renderSession, shape.__renderTransform);
			#elseif lime_cairo
			CairoGraphics.render (graphics, renderSession, shape.__renderTransform);
			#end
			
			var bounds = graphics.__bounds;
			
			if (graphics.__bitmap != null && graphics.__visible) {
				
				var renderer:GLRenderer = cast renderSession.renderer;
				var gl = renderSession.gl;
				
				renderSession.blendModeManager.setBlendMode (shape.blendMode);
				renderSession.maskManager.pushObject (shape);
				
				var shader = renderSession.filterManager.pushObject (shape);
				
				shader.data.uImage0.input = graphics.__bitmap;
				shader.data.uImage0.smoothing = renderSession.allowSmoothing;
				shader.data.uMatrix.value = renderer.getMatrix (graphics.__worldTransform);
				
				renderSession.shaderManager.setShader (shader);
				
				gl.bindBuffer (GLES20.ARRAY_BUFFER, graphics.__bitmap.getBuffer (gl, shape.__worldAlpha));
				gl.vertexAttribPointer (shader.data.aPosition.getAttributeLocation (), 3, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
				gl.vertexAttribPointer (shader.data.aTexCoord.getAttributeLocation (), 2, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer (shader.data.aAlpha.getAttributeLocation (), 1, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
				
				gl.drawArrays (GLES20.TRIANGLE_STRIP, 0, 4);
				
				renderSession.filterManager.popObject (shape);
				renderSession.maskManager.popObject (shape);
				
			}
			
		}
		
	}
	
	
}
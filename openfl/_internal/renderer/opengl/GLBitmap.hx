package openfl._internal.renderer.opengl;


import lime.graphics.opengl.GLES20;
import lime.utils.Float32Array;
import openfl._internal.renderer.RenderSession;
import openfl.display.Bitmap;

@:access(openfl.display.Bitmap)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Stage)
@:access(openfl.filters.BitmapFilter)


class GLBitmap {
	
	
	public static inline function render (bitmap:Bitmap, renderSession:RenderSession):Void {
		
		if (!bitmap.__renderable || bitmap.__worldAlpha <= 0) return;
		
		if (bitmap.bitmapData != null && bitmap.bitmapData.__isValid) {
			
			var renderer:GLRenderer = cast renderSession.renderer;
			var gl = renderSession.gl;
			
			renderSession.blendModeManager.setBlendMode (bitmap.blendMode);
			renderSession.maskManager.pushObject (bitmap);
			
			var shader = renderSession.filterManager.pushObject (bitmap);
			
			shader.data.uImage0.input = bitmap.bitmapData;
			shader.data.uImage0.smoothing = renderSession.allowSmoothing && (bitmap.smoothing || renderSession.upscaled);
			shader.data.uMatrix.value = renderer.getMatrix (bitmap.__renderTransform);
			
			renderSession.shaderManager.setShader (shader);
			
			gl.bindBuffer (GLES20.ARRAY_BUFFER, bitmap.bitmapData.getBuffer (gl, bitmap.__worldAlpha));
			gl.vertexAttribPointer (shader.data.aPosition.getAttributeLocation (), 3, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer (shader.data.aTexCoord.getAttributeLocation (), 2, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer (shader.data.aAlpha.getAttributeLocation (), 1, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
			
			gl.drawArrays (GLES20.TRIANGLE_STRIP, 0, 4);
			
			renderSession.filterManager.popObject (bitmap);
			renderSession.maskManager.popObject (bitmap);
			
		}
		
	}
	
	
}
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
		
		var gl = renderSession.gl;
		
		if (bitmap.bitmapData != null && bitmap.bitmapData.__isValid) {
			
			renderSession.blendModeManager.setBlendMode (bitmap.blendMode);
			renderSession.filterManager.pushObject (bitmap);
			renderSession.maskManager.pushObject (bitmap);
			
			var renderer:GLRenderer = cast renderSession.renderer;
			var shader = renderSession.shaderManager.currentShader;
			
			gl.uniformMatrix4fv (shader.data.uMatrix.getUniformLocation (), false, renderer.getMatrix (bitmap.__renderTransform));
			
			gl.bindTexture (GLES20.TEXTURE_2D, bitmap.bitmapData.getTexture (gl));
			
			if (renderSession.allowSmoothing && (bitmap.smoothing || renderSession.upscaled)) {
				
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MAG_FILTER, GLES20.LINEAR);
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MIN_FILTER, GLES20.LINEAR);
				
			} else {
				
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MAG_FILTER, GLES20.NEAREST);
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MIN_FILTER, GLES20.NEAREST);
				
			}
			
			gl.bindBuffer (GLES20.ARRAY_BUFFER, bitmap.bitmapData.getBuffer (gl, bitmap.__worldAlpha));
			gl.vertexAttribPointer (shader.data.aPosition.getAttributeLocation (), 3, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer (shader.data.aTexCoord.getAttributeLocation (), 2, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer (shader.data.aAlpha.getAttributeLocation (), 1, GLES20.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
			
			gl.drawArrays (GLES20.TRIANGLE_STRIP, 0, 4);
			
			renderSession.maskManager.popObject (bitmap);
			renderSession.filterManager.popObject (bitmap);
			
		}
		
	}
	
	
}
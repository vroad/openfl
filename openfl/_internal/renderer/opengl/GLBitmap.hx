package openfl._internal.renderer.opengl;


import lime.graphics.opengl.GLES20;
import lime.utils.Float32Array;
import openfl._internal.renderer.RenderSession;
import openfl.display.Bitmap;
import openfl.filters.ShaderFilter;

@:access(openfl.display.Bitmap)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Stage)


class GLBitmap {
	
	
	public static inline function render (bitmap:Bitmap, renderSession:RenderSession):Void {
		
		if (!bitmap.__renderable || bitmap.__worldAlpha <= 0) return;
		
		var gl = renderSession.gl;
		
		if (bitmap.bitmapData != null && bitmap.bitmapData.__isValid) {
			
			var shader;
			
			if (bitmap.filters != null && Std.is (bitmap.filters[0], ShaderFilter)) {
				
				shader = cast (bitmap.filters[0], ShaderFilter).shader;
				
			} else {
				
				shader = renderSession.shaderManager.defaultShader;
				
			}
			
			renderSession.blendModeManager.setBlendMode (bitmap.blendMode);
			renderSession.shaderManager.setShader (shader);
			renderSession.maskManager.pushObject (bitmap);
			
			var renderer:GLRenderer = cast renderSession.renderer;
			
			gl.uniform1f (shader.data.uAlpha.index, bitmap.__worldAlpha);
			gl.uniformMatrix4fv (shader.data.uMatrix.index, false, renderer.getMatrix (bitmap.__worldTransform));
			
			gl.bindTexture (GLES20.TEXTURE_2D, bitmap.bitmapData.getTexture (gl));
			
			if (bitmap.smoothing || bitmap.stage.__displayMatrix.a != 1 || bitmap.stage.__displayMatrix.d != 1) {
				
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MAG_FILTER, GLES20.LINEAR);
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MIN_FILTER, GLES20.LINEAR);
				
			} else {
				
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MAG_FILTER, GLES20.NEAREST);
				gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MIN_FILTER, GLES20.NEAREST);
				
			}
			
			gl.bindBuffer (GLES20.ARRAY_BUFFER, bitmap.bitmapData.getBuffer (gl));
			gl.vertexAttribPointer (shader.data.aPosition.index, 3, GLES20.FLOAT, false, 5 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, GLES20.FLOAT, false, 5 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
			
			gl.drawArrays (GLES20.TRIANGLE_STRIP, 0, 4);
			
			renderSession.maskManager.popObject (bitmap);
			
		}
		
	}
	
	
}
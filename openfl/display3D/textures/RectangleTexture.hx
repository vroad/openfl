package openfl.display3D.textures; #if !flash


import openfl.display.BitmapData;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;


class RectangleTexture extends TextureBase {
	
	
	public var optimizeForRenderToTexture:Bool;
	
	
	public function new (glTexture:GLTexture, optimize:Bool, width:Int, height:Int) {
		
		optimizeForRenderToTexture = optimize;
		
		#if (js || neko)
		if (optimizeForRenderToTexture == null) optimizeForRenderToTexture = false;
		#end
		
		super (glTexture, width, height);
		
		#if (cpp || neko)
		if (optimizeForRenderToTexture)
			GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1); 
		
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
		#end
		
	}
	
	
	//public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:Int, async:Bool = false):Void {
		// TODO
	//}
	
	
	public function uploadFromBitmapData (bitmapData:BitmapData, miplevel:Int = 0):Void {
		
		var p = untyped bitmapData.__image.buffer.data;
		
		width = bitmapData.width;
		height = bitmapData.height;
		
		uploadFromUInt8Array(p);
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:Int):Void {
		
		#if js
		
		uploadFromUInt8Array(data != null ? data.byteView.subarray(byteArrayOffset) : null);
		
		#else
		
		uploadFromUInt8Array(new UInt8Array(data));
		
		#end
		
	}
	
	private function uploadFromUInt8Array(data:UInt8Array)
	{
		
		GL.bindTexture (GL.TEXTURE_2D, glTexture);
		
		#if (js && html5)
			
			if (optimizeForRenderToTexture)
				GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1);
			
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			
		#else
			
			if (optimizeForRenderToTexture) {
				
				GL.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, 1); 
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
				GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			 
			}
			
		#end
		
		// mipLevel always should be 0 in rectangle textures
		GL.texImage2D (GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
	}
	
}


#else
typedef RectangleTexture = flash.display3D.textures.RectangleTexture;
#end
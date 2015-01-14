package openfl.display3D.textures; #if !flash


import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.gl.GLFramebuffer;
import openfl.geom.Rectangle;
import openfl.utils.ArrayBuffer;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;

using openfl.display.BitmapData;


class Texture extends TextureBase {
	
	
	public var optimizeForRenderToTexture:Bool;
	
	
	public function new (glTexture:GLTexture, optimize:Bool, width:Int, height:Int) {
		
		optimizeForRenderToTexture = optimize;
		
		#if (js || neko)
		if (optimizeForRenderToTexture == null) optimizeForRenderToTexture = false;
		#end
		
		super (glTexture, width, height);
		
		#if (cpp || neko)
		if (optimizeForRenderToTexture) { 
			
			GL.pixelStorei (GL.UNPACK_FLIP_Y_WEBGL, 1); 
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
			
		}
		#end
		
	}
	
	
	public function uploadCompressedTextureFromByteArray (data:ByteArray, byteArrayOffset:Int, async:Bool = false):Void {
		
		// TODO
		
	}
	
	
	public function uploadFromBitmapData (bitmapData:BitmapData, miplevel:Int = 0):Void {
		
		var p = untyped bitmapData.__image.buffer.data;
		
		width = bitmapData.width;
		height = bitmapData.height;
		uploadFromUInt8Array(p, miplevel);
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:Int, miplevel:Int = 0):Void {
		
		#if js
		
		uploadFromUInt8Array(data != null ? data.byteView.subarray(byteArrayOffset) : null, miplevel);
		
		#else
		
		uploadFromUInt8Array(new UInt8Array(data), miplevel);
		
		#end
		
	}
	
	private function uploadFromUInt8Array(data:UInt8Array, miplevel:Int = 0)
	{
		
		GL.bindTexture (GL.TEXTURE_2D, glTexture);
		 
		if (optimizeForRenderToTexture) {
			
			GL.pixelStorei (GL.UNPACK_FLIP_Y_WEBGL, 1); 
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST); 			
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE); 
			
		}
		
		GL.texImage2D (GL.TEXTURE_2D, miplevel, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
	}
}


#else
typedef Texture = openfl.display3D.textures.Texture;
#end
package openfl.display3D.textures;


import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.utils.ArrayBufferView;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;


@:final class RectangleTexture extends TextureBase {
	
	public var optimizeForRenderToTexture:Bool;
	
	public function new (context:Context3D, glTexture:GLTexture, optimize:Bool, width:Int, height:Int, format:Int, type:Int) {
		
		optimizeForRenderToTexture = optimize;
		
		super (context, glTexture, width, height, format, type);
		
		uploadFromTypedArray (null);
		
		if (optimizeForRenderToTexture) {
			
			frameBuffer = GL.createFramebuffer ();
			
		}
		
	}
	
	
	//public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:Int, async:Bool = false):Void {
		// TODO
	//}
	
	
	public function uploadFromBitmapData (bitmapData:BitmapData, miplevel:Int = 0):Void {
		
		var image = bitmapData.image;
		
		if (!image.premultiplied && image.transparent) {
			
			image = image.clone ();
			image.premultiplied = true;
			
		}
		
		width = image.width;
		height = image.height;
		
		uploadFromTypedArray (image.data);
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:Int):Void {
		
		uploadFromTypedArray (getUInt8ArrayFromByteArray (data, byteArrayOffset));
		
	}
	
	@:deprecated("uploadFromUInt8Array is deprecated. Use uploadFromTypedArray instead.")
	public inline function uploadFromUInt8Array (data:UInt8Array):Void {
		
		uploadFromTypedArray (data);
		
	}
	
	public function uploadFromTypedArray (data:ArrayBufferView, yFlipped:Bool = false, premultiplied:Bool = true):Void {
		
		// TODO use premultiplied parameter
		
		GL.bindTexture (GL.TEXTURE_2D, glTexture);
		
		#if (js && html5)
		GL.pixelStorei (GL.UNPACK_FLIP_Y_WEBGL, yFlipped ? 0 : 1);
		#else
		if (!yFlipped) {
			
			data = flipPixels (data, width, height);
			
		}
		#end
		
		GL.texImage2D (GL.TEXTURE_2D, 0, format, width, height, 0, format, GL.UNSIGNED_BYTE, data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
	}
	
}
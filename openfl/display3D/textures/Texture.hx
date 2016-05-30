package openfl.display3D.textures;


import openfl.display3D.Context3D;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.utils.ArrayBufferView;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;

using openfl.display.BitmapData;


@:final class Texture extends TextureBase {
	
	public var optimizeForRenderToTexture:Bool;
	
	public var hasMipmap:Bool;
	
	public function new (context:Context3D, glTexture:GLTexture, optimize:Bool, width:Int, height:Int, format:Int, type:Int) {
		
		optimizeForRenderToTexture = optimize;

		hasMipmap = false;
		
		super (context, glTexture, width, height, format, type);
		
		uploadFromTypedArray (null);
		
		if (optimizeForRenderToTexture) {
			
			frameBuffer = GL.createFramebuffer ();
			
		}
		
	}
	
	
	public function uploadCompressedTextureFromByteArray (data:ByteArray, byteArrayOffset:Int, async:Bool = false):Void {
		
		// TODO
		
	}
	
	
	public function uploadFromBitmapData (bitmapData:BitmapData, miplevel:Int = 0):Void {
		
		var image = bitmapData.image;
		
		if (!image.premultiplied && image.transparent) {
			
			image = image.clone ();
			image.premultiplied = true;
			
		}
		
		width = image.width;
		height = image.height;
		
		uploadFromTypedArray (image.data, miplevel);
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:Int, miplevel:Int = 0):Void {
		
		uploadFromTypedArray (getUInt8ArrayFromByteArray (data, byteArrayOffset), miplevel);
		
	}
	
	
	@:deprecated("uploadFromUInt8Array is deprecated. Use uploadFromTypedArray instead.")
	public inline function uploadFromUInt8Array (data:UInt8Array, miplevel:Int = 0):Void {
		
		uploadFromTypedArray (data, miplevel);
		
	}
	
	
	public function uploadFromTypedArray (data:ArrayBufferView, miplevel:Int = 0, yFlipped:Bool = false, premultiplied:Bool = true):Void {
		
		// TODO use premultiplied parameter
		
		var size = getSizeForMipLevel (miplevel);
		
		GL.bindTexture (GL.TEXTURE_2D, glTexture);
		
		#if (js && html5)
		GL.pixelStorei (GL.UNPACK_FLIP_Y_WEBGL, yFlipped ? 0 : 1);
		#else
		if (!yFlipped) {
			
			data = flipPixels (data, size.width, size.height);
			
		}
		#end
		
		GL.texImage2D (GL.TEXTURE_2D, miplevel, format, size.width, size.height, 0, format, GL.UNSIGNED_BYTE, data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
	}
	
	
}
package openfl.display3D.textures;


import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.utils.ArrayBufferView;
import lime.utils.UInt8Array;
import openfl.display3D.Context3D;
import openfl.utils.ByteArray;

using openfl.display.BitmapData;


@:final class Texture extends TextureBase {	
	
	private var __optimizeForRenderToTexture:Bool;
	private var __hasMipMap:Bool;
	
	public function new (context:Context3D, glTexture:GLTexture, optimize:Bool, width:Int, height:Int, format:Int, type:Int) {
		
		super (context, glTexture, width, height, format, type);
		
		__optimizeForRenderToTexture = optimize;
		
		if (__optimizeForRenderToTexture) {
			
			__frameBuffer = GL.createFramebuffer ();
			
		}
		
		uploadFromTypedArray (null);
		
	}
	
	
	public function uploadCompressedTextureFromByteArray (data:ByteArray, byteArrayOffset:UInt, async:Bool = false):Void {
		
		// TODO
		
	}
	
	
	public function uploadFromBitmapData (source:BitmapData, miplevel:UInt = 0):Void {
		
		var image = source.image;
		
		if (!image.premultiplied && image.transparent) {
			
			image = image.clone ();
			image.premultiplied = true;
			
		}
		
		__width = image.width;
		__height = image.height;
		
		uploadFromTypedArray (image.data, miplevel);
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:UInt, miplevel:UInt = 0):Void {
		
		uploadFromTypedArray (__getUInt8ArrayFromByteArray (data, byteArrayOffset), miplevel);
		
	}
	
	
	// TODO: Should there be a typed array API, or just use ByteArray?
	
	
	@:deprecated("uploadFromUInt8Array is deprecated. Use uploadFromTypedArray instead.")
	@:noCompletion @:dox(hide) public inline function uploadFromUInt8Array (data:UInt8Array, miplevel:Int = 0):Void {
		
		uploadFromTypedArray (data, miplevel);
		
	}
	
	
	@:noCompletion @:dox(hide) public function uploadFromTypedArray (data:ArrayBufferView, miplevel:Int = 0, yFlipped:Bool = false, premultiplied:Bool = true):Void {
		
		// TODO use premultiplied parameter
		
		var size = __getSizeForMipLevel (miplevel);
		
		GL.bindTexture (GL.TEXTURE_2D, __glTexture);
		
		#if (js && html5)
		GL.pixelStorei (GL.UNPACK_FLIP_Y_WEBGL, yFlipped ? 0 : 1);
		#else
		if (!yFlipped) {
			
			data = __flipPixels (data, size.width, size.height);
			
		}
		#end
		
		GL.texImage2D (GL.TEXTURE_2D, miplevel, __format, size.width, size.height, 0, __format, GL.UNSIGNED_BYTE, data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
	}
	
	
}
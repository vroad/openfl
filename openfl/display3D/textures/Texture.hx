package openfl.display3D.textures; #if !flash


import openfl.display3D.Context3D;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.gl.GLFramebuffer;
import openfl.geom.Rectangle;
import openfl.utils.ArrayBuffer;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;

using openfl.display.BitmapData;


@:final class Texture extends TextureBase {
	
	
	public var optimizeForRenderToTexture:Bool;
	public var hasMipmap:Bool;
	
	public function new (context:Context3D, glTexture:GLTexture, optimize:Bool, width:Int, height:Int, internalFormat:Int, format:Int, type:Int) {
		
		optimizeForRenderToTexture = optimize;
		hasMipmap = false;
		
		super (context, glTexture, width, height, internalFormat, format, type);
		
		uploadFromUInt8Array(null);
		
		if (optimizeForRenderToTexture) {
			
			framebuffer = GL.createFramebuffer ();
			
		}
		
	}
	
	
	public function uploadCompressedTextureFromByteArray (data:ByteArray, byteArrayOffset:Int, async:Bool = false):Void {
		
		// TODO
		
	}
	
	
	public function uploadFromBitmapData (bitmapData:BitmapData, miplevel:Int = 0):Void {
		
		// TODO: Support upload from UInt8Array directly
		
		width = bitmapData.width;
		height = bitmapData.height;
		
		#if lime_legacy
		
		var p = BitmapData.getRGBAPixels (bitmapData);
		uploadFromByteArray(p, 0, miplevel);
		
		#else
		
		var p = bitmapData.image.data;
		uploadFromUInt8Array(p, miplevel);
		
		#end
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:Int, miplevel:Int = 0):Void {
		
		#if js
		
		uploadFromUInt8Array(data != null ? data.b.subarray(byteArrayOffset, data.b.length) : null, miplevel);
		
		#else
		
		uploadFromUInt8Array(new UInt8Array(data), miplevel);
		
		#end
		
	}
	
	public function uploadFromUInt8Array (data:UInt8Array, miplevel:Int = 0, xOffset:Int = 0, yOffset:Int = 0, _width:Int = 0, _height:Int = 0)
	{
		if (_width == 0)
			_width = width;
		if (_height == 0)
			_height = height;
		
		var level:Int = miplevel;
		while (level > 0)
		{
			
			_width >>= 1;
			_height >>= 1;
			level >>= 1;
			
		}
		
		#if !html5
		data = flipPixels(data, _width, _height);
		#end
		
		var alignment:Int = 8;
		var bpp:Int;
		
		switch (format)
		{
			
			case GL.ALPHA: bpp = 1;
			case GL.RGBA: bpp = 4;
			default: bpp = 4;
			
		}
		while (alignment != 1)
		{
			
			if ((_width * bpp) % alignment == 0)
				break;
			alignment >>= 1;
			
		}
		
		GL.pixelStorei (GL.UNPACK_ALIGNMENT, alignment);
		
		GL.bindTexture (GL.TEXTURE_2D, glTexture);
		
		if (data == null)
			GL.texImage2D (GL.TEXTURE_2D, miplevel, internalFormat, _width, _height, 0, format, type, null);
		else
			GL.texSubImage2D (GL.TEXTURE_2D, miplevel, xOffset, height - yOffset - _height, _width, _height, format, type, data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
		if (miplevel > 0)
			hasMipmap = true;
	}
}


#else
typedef Texture = flash.display3D.textures.Texture;
#end

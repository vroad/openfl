package openfl.display3D.textures; #if !flash


import openfl.display.BitmapData;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.UInt8Array;


class RectangleTexture extends TextureBase {
	
	
	public var optimizeForRenderToTexture:Bool;
	
	
	public function new (glTexture:GLTexture, optimize:Bool, width:Int, height:Int, internalFormat:Int, format:Int, type:Int) {
		
		optimizeForRenderToTexture = optimize;
		
		super (glTexture, width, height, internalFormat, format, type);
		
		uploadFromUInt8Array(null);
		
	}
	
	
	//public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:Int, async:Bool = false):Void {
		// TODO
	//}
	
	
	public function uploadFromBitmapData (bitmapData:BitmapData, miplevel:Int = 0):Void {
		
		// TODO: Support upload from UInt8Array directly
		
		width = bitmapData.width;
		height = bitmapData.height;
		
		#if lime_legacy
		
		var p = BitmapData.getRGBAPixels (bitmapData);
		uploadFromByteArray(p);
		
		#else
		
		var p = @:privateAccess (bitmapData.__image).data;
		uploadFromUInt8Array(p);
		
		#end
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:Int):Void {
		
		#if js
		
		uploadFromUInt8Array(data != null ? data.byteView.subarray(byteArrayOffset) : null);
		
		#else
		
		uploadFromUInt8Array(new UInt8Array(data));
		
		#end
		
	}
	
	public function uploadFromUInt8Array(data:UInt8Array, xOffset:Int = 0, yOffset:Int = 0, _width:Int = 0, _height:Int = 0)
	{
		
		if (_width == 0)
			_width = width;
		if (_height == 0)
			_height = height;
		
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
			GL.texImage2D (GL.TEXTURE_2D, 0, internalFormat, width, height, 0, format, type, null);
		else
			GL.texSubImage2D (GL.TEXTURE_2D, 0, xOffset, height - yOffset - _height, _width, _height, format, type, data);
		GL.bindTexture (GL.TEXTURE_2D, null);
		
	}
	
}


#else
typedef RectangleTexture = flash.display3D.textures.RectangleTexture;
#end
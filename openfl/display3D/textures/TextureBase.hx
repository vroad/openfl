package openfl.display3D.textures; #if !flash


import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.gl.GLFramebuffer;
import openfl.events.EventDispatcher;
import openfl.utils.UInt8Array;


class TextureBase extends EventDispatcher {
	
	
	public var height:Int;
	public var frameBuffer:GLFramebuffer;
	public var glTexture:GLTexture;
	public var width:Int;
	public var internalFormat:Int;
	public var format:Int;
	public var type:Int;
	
	
	public function new (glTexture:GLTexture, width:Int = 0, height:Int = 0, internalFormat:Int = GL.RGBA, format:Int = GL.RGBA, type:Int = GL.UNSIGNED_BYTE) {
		
		super ();
		
		this.width = width;
		this.height = height;
		this.glTexture = glTexture;
		this.internalFormat = internalFormat;
		this.format = format;
		this.type = type;
		
	}
	
	
	public function dispose ():Void {
		
		GL.deleteTexture (glTexture);
		
	}
	
	private function flipPixels(data:UInt8Array, _width:Int, _height:Int):UInt8Array
	{
		#if !html5
		if (data == null)
			return null;
		var data2 = new UInt8Array(data.length);
		var bpp:Int = 4;
		switch(this.format)
		{
			case GL.RGBA:
				bpp = 4;
			case GL.ALPHA:
				bpp = 1;
		}
		var bytesPerLine:Int = _width * bpp;
		var srcPosition:Int = (_height - 1) * bytesPerLine;
		var dstPosition:Int = 0;
		
		for(i in 0 ... _height)
		{
			data2.set(data.subarray(srcPosition, srcPosition + bytesPerLine), dstPosition);
			srcPosition -= bytesPerLine;
			dstPosition += bytesPerLine;
		}
		return data2;
		#else
		return null;
		#end
	}
	
	public function copyTo(dest:Texture, sourceX:Int, sourceY:Int, _width:Int, _height:Int, destX:Int, destY:Int)
	{
	}
	
	
}


#else
typedef TextureBase = flash.display3D.textures.TextureBase;
#end
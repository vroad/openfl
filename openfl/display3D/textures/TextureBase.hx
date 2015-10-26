package openfl.display3D.textures; #if !flash


import openfl.display3D.Context3D;
import openfl.gl.GL;
import openfl.gl.GLTexture;
import openfl.gl.GLFramebuffer;
import openfl.events.EventDispatcher;
import openfl.utils.UInt8Array;


class TextureBase extends EventDispatcher {
	
	public var context:Context3D;
	public var height:Int;
	public var glTexture:GLTexture;
	public var width:Int;
	public var internalFormat:Int;
	public var format:Int;
	public var type:Int;
	public var minFilter:Int;
	public var magFilter:Int;
	public var maxAnisoTrophy:Float;
	public var wrapMode:Int;
	public var framebuffer:GLFramebuffer;
	
	public function new (context:Context3D, glTexture:GLTexture, width:Int = 0, height:Int = 0, internalFormat:Int = GL.RGBA, format:Int = GL.RGBA, type:Int = GL.UNSIGNED_BYTE) {
		
		super ();
		
		this.context = context;
		this.width = width;
		this.height = height;
		this.glTexture = glTexture;
		this.internalFormat = internalFormat;
		this.format = format;
		this.type = type;
		this.minFilter = GL.NEAREST_MIPMAP_LINEAR;
		this.magFilter = GL.LINEAR;
		this.maxAnisoTrophy = 1.0;
		this.wrapMode = GL.REPEAT;
		
	}
	
	
	public function dispose ():Void {
		
		context.__deleteTexture (this);
		
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
	
	private function setMinFilter (filter:Int) {
		
		if (this.minFilter != filter) {
			
			minFilter = filter;
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filter);
			
		}
		
	}
	
	private function setMagFilter (filter:Int) {
		
		if (this.magFilter != filter) {
			
			magFilter = filter;
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filter);
			
		}
		
	}
	
	private function setMaxAnisotrophy (value:Float) {
		
		if (this.maxAnisoTrophy != value) {
			
			maxAnisoTrophy = value;
			GL.texParameterf (GL.TEXTURE_2D, @:privateAccess Context3D.TEXTURE_MAX_ANISOTROPY_EXT, value);
			
		}
		
	}
	
	private function setWrapMode (mode:Int) {
		
		if (this.wrapMode != mode) {
			
			wrapMode = mode;
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, wrapMode);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, wrapMode);
			
		}
		
	}
}


#else
typedef TextureBase = flash.display3D.textures.TextureBase;
#end
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
	
	
	public function new (glTexture:GLTexture, width:Int = 0, height:Int = 0) {
		
		super ();
		
		this.width = width;
		this.height = height;
		this.glTexture = glTexture;
		
	}
	
	
	public function dispose ():Void {
		
		GL.deleteTexture (glTexture);
		
	}
	
	private function flipPixels(data:UInt8Array):UInt8Array
	{
		#if !html5
		var data2 = new UInt8Array(data.length);
		var bytesPerLine:Int = width * 4;
		var srcPosition:Int = (height - 1) * bytesPerLine;
		var dstPosition:Int = 0;
		
		for(i in 0 ... height)
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
	
	
}


#else
typedef TextureBase = flash.display3D.textures.TextureBase;
#end
package openfl.display3D.textures;


import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLTexture;
import lime.utils.ArrayBufferView;
import lime.utils.UInt8Array;
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;
import openfl.utils.ByteArray.ByteArrayData;

@:access(openfl.display3D.Context3D)


class TextureBase extends EventDispatcher {
	
	public var __context:Context3D;
	public var __frameBuffer:GLFramebuffer;
	public var __height:Int;
	public var __width:Int;
	public var __glTexture:GLTexture;
	public var __format:Int;
	public var __type:Int;
	public var __minFilter:Int;
	public var __magFilter:Int;
	public var __maxAnisoTrophy:Float;
	public var __wrapMode:Int;
	
	public function new (context:Context3D, glTexture:GLTexture, width:Int = 0, height:Int = 0, format:Int = GL.RGBA, type:Int = GL.UNSIGNED_BYTE) {
		
		super ();
		
		__context = context;
		__width = width;
		__height = height;
		__glTexture = glTexture;
		__format = format;
		__type = type;
		__minFilter = GL.NEAREST_MIPMAP_LINEAR;
		__magFilter = GL.LINEAR;
		__maxAnisoTrophy = 1.0;
		__wrapMode = GL.REPEAT;
		
	}
	
	
	public function dispose ():Void {
		
		__context.__deleteTexture (this);
		
	}
	
	private function setMinFilter (filter:Int) {
		
		if (__minFilter != filter) {
			
			__minFilter = filter;
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, filter);
			
		}
		
	}
	
	private function setMagFilter (filter:Int) {
		
		if (__magFilter != filter) {
			
			__magFilter = filter;
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, filter);
			
		}
		
	}
	
	private function setMaxAnisotrophy (value:Float) {
		
		if (__maxAnisoTrophy != value) {
			
			__maxAnisoTrophy = value;
			GL.texParameterf (GL.TEXTURE_2D, @:privateAccess Context3D.TEXTURE_MAX_ANISOTROPY_EXT, value);
			
		}
		
	}
	
	private function setWrapMode (mode:Int) {
		
		if (__wrapMode != mode) {
			
			__wrapMode = mode;
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, __wrapMode);
			GL.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, __wrapMode);
			
		}
		
	}
	
	
	private function __flipPixels (inData:ArrayBufferView, _width:Int, _height:Int):UInt8Array {
		
		#if native
		if (inData == null) {
			
			return null;
			
		}
		
		var data = __getUInt8ArrayFromArrayBufferView (inData);
		var data2 = new UInt8Array (data.length);
		var bpp = 4;
		var bytesPerLine = _width * bpp;
		var srcPosition = (_height - 1) * bytesPerLine;
		var dstPosition = 0;
		
		for (i in 0 ... _height) {
			
			data2.set (data.subarray (srcPosition, srcPosition + bytesPerLine), dstPosition);
			srcPosition -= bytesPerLine;
			dstPosition += bytesPerLine;
			
		}
		
		return data2;
		#else
		return null;
		#end
		
	}
	
	
	private function __getSizeForMipLevel (miplevel:Int):{ width:Int, height:Int } {
		
		var _width = __width;
		var _height = __height;
		var lv = miplevel;
		
		while (lv > 0) {
			
			_width >>= 1;
			_height >>= 1;
			lv >>= 1;
			
		}
		
		return { width: _width, height: _height };
		
	}
	
	
	private function __getUInt8ArrayFromByteArray (data:ByteArray, byteArrayOffset:Int):UInt8Array {
		
		#if js
		return byteArrayOffset == 0 ? @:privateAccess (data:ByteArrayData).b : new UInt8Array (data.toArrayBuffer (), byteArrayOffset);
		#else
		return new UInt8Array (data.toArrayBuffer (), byteArrayOffset);
		#end
		
	}
	
	
	private function __getUInt8ArrayFromArrayBufferView (data:ArrayBufferView):UInt8Array {
		
		return new UInt8Array (data.buffer, data.byteOffset, data.byteLength);
		
	}
	
	
}
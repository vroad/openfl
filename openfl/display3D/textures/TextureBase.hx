package openfl.display3D.textures;


import lime.graphics.opengl.GLES20;
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
	public var __internalFormat:Int;
	public var __format:Int;
	public var __type:Int;
	public var __minFilter:Int;
	public var __magFilter:Int;
	public var __maxAnisoTrophy:Float;
	public var __wrapS:Int;
	public var __wrapT:Int;
	
	public function new (context:Context3D, glTexture:GLTexture, width:Int = 0, height:Int = 0, internalFormat:Int = GLES20.RGBA, format:Int = GLES20.RGBA, type:Int = GLES20.UNSIGNED_BYTE) {
		
		super ();
		
		__context = context;
		__width = width;
		__height = height;
		__glTexture = glTexture;
		__internalFormat = internalFormat;
		__format = format;
		__type = type;
		__minFilter = GLES20.NEAREST_MIPMAP_LINEAR;
		__magFilter = GLES20.LINEAR;
		__maxAnisoTrophy = 1.0;
		__wrapS = GLES20.REPEAT;
		__wrapT = GLES20.REPEAT;
		
	}
	
	
	public function dispose ():Void {
		
		__context.__deleteTexture (this);
		
	}
	
	private function setMinFilter (filter:Int) {
		
		if (__minFilter != filter) {
			
			__minFilter = filter;
			__context.gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MIN_FILTER, filter);
			
		}
		
	}
	
	private function setMagFilter (filter:Int) {
		
		if (__magFilter != filter) {
			
			__magFilter = filter;
			__context.gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_MAG_FILTER, filter);
			
		}
		
	}
	
	private function setMaxAnisotrophy (value:Float) {
		
		if (__maxAnisoTrophy != value) {
			
			__maxAnisoTrophy = value;
			__context.gl.texParameterf (GLES20.TEXTURE_2D, @:privateAccess Context3D.TEXTURE_MAX_ANISOTROPY_EXT, value);
			
		}
		
	}
	
	private function setWrapMode (wrapS:Int, wrapT:Int) {
		
		if (__wrapS != wrapS) {
			
			__wrapS = wrapS;
			__context.gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_WRAP_S, wrapS);
			
		}
		
		if (__wrapT != wrapT) {
			
			__wrapT = wrapT;
			__context.gl.texParameteri (GLES20.TEXTURE_2D, GLES20.TEXTURE_WRAP_T, wrapT);
			
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
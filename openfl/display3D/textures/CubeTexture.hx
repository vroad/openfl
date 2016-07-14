package openfl.display3D.textures;


import lime.graphics.opengl.GLES20;
import lime.graphics.opengl.GLTexture;
import openfl.display3D.Context3D;
import openfl.utils.ByteArray;

using openfl.display.BitmapData;

@:access(openfl.display3D.Context3D)

@:final class CubeTexture extends TextureBase {
	
	
	private var __size:Int;
	private var __textures:Array<GLTexture>;
	private var __hasMipMap:Bool;
	
	
	private function new (context:Context3D, glTexture:GLTexture, size:Int, internalFormat:Int, format:Int, type:Int) {
		
		super (context, glTexture, size, size, internalFormat, format, type);
		this.__hasMipMap = false;
		
		__size = size;
		__hasMipMap = false;
		
		__textures = [];
		
		for (i in 0...6) {
			
			__textures[i] = context.gl.createTexture ();
			
		}
		
	}
	
	
	public function uploadCompressedTextureFromByteArray (data:ByteArray, byteArrayOffset:UInt, async:Bool = false):Void {
		
		// TODO
		
	}
	
	
	public function uploadFromBitmapData (source:BitmapData, side:UInt, miplevel:UInt = 0):Void {
		
		var data = source.image.data;
		
		#if (js && html5)
		__context.gl.pixelStorei (GLES20.UNPACK_FLIP_Y_WEBGL, 0);
		#end
		
		__context.gl.bindTexture (GLES20.TEXTURE_CUBE_MAP, __glTexture);
		
		switch (side) {
			
			case 0:
				
				__context.gl.texImage2D (GLES20.TEXTURE_CUBE_MAP_POSITIVE_X, miplevel, __internalFormat, source.width, source.height, 0, __format, GLES20.UNSIGNED_BYTE, data);
			
			case 1:
				
				__context.gl.texImage2D (GLES20.TEXTURE_CUBE_MAP_NEGATIVE_X, miplevel, __internalFormat, source.width, source.height, 0, __format, GLES20.UNSIGNED_BYTE, data);
			
			case 2:
				
				__context.gl.texImage2D (GLES20.TEXTURE_CUBE_MAP_POSITIVE_Y, miplevel, __internalFormat, source.width, source.height, 0, __format, GLES20.UNSIGNED_BYTE, data);
			
			case 3:
				
				__context.gl.texImage2D (GLES20.TEXTURE_CUBE_MAP_NEGATIVE_Y, miplevel, __internalFormat, source.width, source.height, 0, __format, GLES20.UNSIGNED_BYTE, data);
			
			case 4:
				
				__context.gl.texImage2D (GLES20.TEXTURE_CUBE_MAP_POSITIVE_Z, miplevel, __internalFormat, source.width, source.height, 0, __format, GLES20.UNSIGNED_BYTE, data);
			
			case 5:
				
				__context.gl.texImage2D (GLES20.TEXTURE_CUBE_MAP_NEGATIVE_Z, miplevel, __internalFormat, source.width, source.height, 0, __format, GLES20.UNSIGNED_BYTE, data);
			
			default:
				
				throw "unknown side type";
			
		}
		
		__context.gl.bindTexture (GLES20.TEXTURE_CUBE_MAP, null);
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:UInt, side:UInt, miplevel:UInt = 0):Void {
		
		// TODO
		
	}
	
	
	private function __glTextureAt (index:Int):GLTexture {
		
		return __textures[index];
		
	}
	
	
}
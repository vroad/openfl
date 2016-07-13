package openfl.display3D;


import lime.graphics.opengl.GLES20;
import lime.graphics.opengl.GLBuffer;
import lime.utils.ArrayBufferView;
import lime.utils.Int16Array;
import openfl.utils.ByteArray;
import openfl.Vector;

@:access(openfl.display3D.Context3D)


@:final class IndexBuffer3D {
	
	
	private var __context:Context3D;
	private var __glBuffer:GLBuffer;
	private var __numIndices:Int;
	private var __bufferUsage:Int;
	
	
	private function new (context:Context3D, glBuffer:GLBuffer, numIndices:Int, bufferUsage:Int) {
		
		__context = context;
		__glBuffer = glBuffer;
		__numIndices = numIndices;
		__bufferUsage = bufferUsage;
		
	}
	
	
	public function dispose ():Void {
		
		__context.__deleteIndexBuffer (this);
		
	}
	
	
	public function uploadFromByteArray (data:ByteArray, byteArrayOffset:Int, startOffset:Int, count:Int):Void {
		
		var offset = byteArrayOffset + startOffset * 2;
		
		uploadFromTypedArray (new Int16Array (data.toArrayBuffer(), offset, count));
		
	}
	
	
	public function uploadFromTypedArray (data:ArrayBufferView):Void {
		
		__context.gl.bindBuffer (GLES20.ELEMENT_ARRAY_BUFFER, __glBuffer);
		__context.gl.bufferData (GLES20.ELEMENT_ARRAY_BUFFER, data, __bufferUsage);
		
	}
	
	
	public function uploadFromVector (data:Vector<UInt>, startOffset:Int, count:Int):Void {
		
		uploadFromTypedArray (new Int16Array (data, startOffset * 2, count));
		
	}
	
	
}
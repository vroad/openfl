package openfl.display3D; #if !flash


import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Int16Array;
import openfl.utils.ByteArray;
import openfl.Vector;


@:final class IndexBuffer3D {
	
	public var context:Context3D;
	public var glBuffer:GLBuffer;
	public var numIndices:Int;
	public var bufferUsage:Int;
	
	
	public function new (context:Context3D, glBuffer:GLBuffer, numIndices:Int, bufferUsage:Int) {
		
		this.context = context;
		this.glBuffer = glBuffer;
		this.numIndices = numIndices;
		this.bufferUsage = bufferUsage;
		
	}
	
	
	public function dispose ():Void {
		
		context.__deleteIndexBuffer (this);
		
	}
	
	
	public function uploadFromByteArray (byteArray:ByteArray, byteArrayOffset:Int, startOffset:Int, count:Int):Void {
		
		var bytesPerIndex = 2;
		GL.bindBuffer (GL.ELEMENT_ARRAY_BUFFER, glBuffer);
		
		var length:Int = count * bytesPerIndex;
		var offset:Int = byteArrayOffset + startOffset * bytesPerIndex;
		var indices:Int16Array;
		
		#if js
		indices = untyped __js__("new Int16Array(byteArray.byteView.buffer, offset, length)");
		#else
		indices = new Int16Array (byteArray, offset, length);
		#end
		
		GL.bufferData (GL.ELEMENT_ARRAY_BUFFER, indices, bufferUsage);
		
	}
	
	
	public function uploadFromVector (data:Vector<UInt>, startOffset:Int, count:Int):Void {
		
		var indices:Int16Array;
		GL.bindBuffer (GL.ELEMENT_ARRAY_BUFFER, glBuffer);
		
		#if js
		indices = new Int16Array (count);
		
		for (i in startOffset...(startOffset + count)) {
			
			indices[i] = data[i];
			
		}
		#else
		indices = new Int16Array (data, startOffset, count);
		#end
		
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices, bufferUsage);
		
	}
	
	public function uploadFromInt16Array(data:Int16Array, startOffset:Int, count:Int):Void 
	{
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, glBuffer);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, data.subarray (startOffset, startOffset + count), bufferUsage);
	}
}


#else
typedef IndexBuffer3D = flash.display3D.IndexBuffer3D;
#end
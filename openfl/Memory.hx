package openfl; #if !flash #if !openfl_legacy


import haxe.io.BytesData;
import openfl.utils.ByteArray;


class Memory {
	
	
	private static var gcRef:ByteArray;
	private static var len:Int;
	
	
	@:noCompletion static private function _setPositionTemporarily<T> (position:Int, action:Void -> T):T {
		
		var oldPosition:Int = gcRef.position;
		gcRef.position = position;
		var value:T = action ();
		gcRef.position = oldPosition;
		
		return value;
		
	}
	
	
	public static #if !debug inline #end function getByte (addr:Int):Int {
		
		#if debug if (addr < 0 || addr + 1 > len) throw("Bad address"); #end
		
		return #if nodejs 0 #else gcRef.__get (addr) #end;
		
	}
	
	
	public static #if !debug inline #end function getDouble (addr:Int):Float {
		
		#if debug if (addr < 0 || addr + 8 > len) throw ("Bad address"); #end
		
		return _setPositionTemporarily (addr, function () {
			
			return gcRef.readDouble ();
			
		});
		
	}
	
	
	public static #if !debug inline #end function getFloat (addr:Int):Float {
		
		#if debug if (addr < 0 || addr + 4 > len) throw ("Bad address"); #end
		
		return _setPositionTemporarily (addr, function () {
			
			return gcRef.readFloat ();
			
		});
		
	}
	
	
	public static #if !debug inline #end function getI32 (addr:Int):Int {
		
		#if debug if (addr < 0 || addr + 4 > len) throw ("Bad address"); #end
		
		return _setPositionTemporarily(addr, function () {
			
			return gcRef.readInt ();
			
		});
		
	}
	
	
	public static #if !debug inline #end function getUI16 (addr:Int):Int {
		
		#if debug if (addr < 0 || addr + 2 > len) throw ("Bad address"); #end
		
		return _setPositionTemporarily (addr, function () {
			
			return gcRef.readUnsignedShort ();
			
		});
		
	}
	
	
	public static function select (inBytes:ByteArray):Void {
		
		gcRef = inBytes;
		len = (inBytes != null) ? inBytes.length : 0;
		
	}
	
	
	public static #if !debug inline #end function setByte (addr:Int, v:Int):Void {
		
		#if debug if (addr < 0 || addr + 1 > len) throw ("Bad address"); #end
		
		#if nodejs
		#else
		gcRef.__set (addr, v);
		#end
		
	}
	
	
	public static #if !debug inline #end function setDouble (addr:Int, v:Float):Void {
		
		#if debug if (addr < 0 || addr + 8 > len) throw ("Bad address"); #end
		
		_setPositionTemporarily (addr, function () {
			
			gcRef.writeDouble (v);
			
		});
		
	}
	
	
	public static #if !debug inline #end function setFloat (addr:Int, v:Float):Void {
		
		#if debug if (addr < 0 || addr + 4 > len) throw ("Bad address"); #end
		
		_setPositionTemporarily (addr, function () {
			
			gcRef.writeFloat (v);
			
		});
		
	}
	
	
	public static #if !debug inline #end function setI16 (addr:Int, v:Int):Void {
		
		#if debug if (addr < 0 || addr + 2 > len) throw ("Bad address"); #end
		
		_setPositionTemporarily (addr, function () {
			
			gcRef.writeUnsignedShort (v);
			
		});
		
	}
	
	
	public static #if !debug inline #end function setI32 (addr:Int, v:Int):Void {
		
		#if debug if (addr < 0 || addr + 4 > len) throw ("Bad address"); #end
		
		_setPositionTemporarily (addr, function () {
			
			gcRef.writeInt (v);
			
		});
		
	}
	
	
}


#else
typedef Memory = openfl._legacy.Memory;
#end
#else
typedef Memory = flash.Memory;
#end
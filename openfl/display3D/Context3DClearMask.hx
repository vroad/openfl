package openfl.display3D;
import openfl._internal.utils.NullUtils;


@:enum abstract Context3DClearMask(UInt) from UInt to UInt from Int to Int {
	
	public var ALL = 0x07;
	public var COLOR = 0x01;
	public var DEPTH = 0x02;
	public var STENCIL = 0x04;
	
	#if cs
	@:noCompletion @:op(A == B) private static function equals (a:Context3DClearMask, b:Context3DClearMask):Bool {
		
		return NullUtils.valueEquals (a, b, Int);
		
	}
	#end
	
	#if cs
	@:noCompletion @:op(A != B) private static function notEquals (a:Context3DClearMask, b:Context3DClearMask):Bool {
		
		return !equals (a, b);
		
	}
	#end
	
}
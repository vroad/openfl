package openfl.display3D;
import openfl._internal.utils.NullUtils;


@:enum abstract Context3DClearMask(Null<Int>) {
	
	public var ALL = 0;
	public var COLOR = 1;
	public var DEPTH = 2;
	public var STENCIL = 3;
	
	@:from private static function fromString (value:String):Context3DClearMask {
		
		return switch (value) {
			
			case "all": ALL;
			case "color": COLOR;
			case "depth": DEPTH;
			case "stencil": STENCIL;
			default: null;
			
		}
		
	}
	
	@:to private static function toString (value:Int):String {
		
		return switch (value) {
			
			case Context3DClearMask.ALL: "all";
			case Context3DClearMask.COLOR: "color";
			case Context3DClearMask.DEPTH: "depth";
			case Context3DClearMask.STENCIL: "stencil";
			default: null;
			
		}
		
	}
	
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
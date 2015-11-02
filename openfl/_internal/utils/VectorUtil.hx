package openfl._internal.utils;

class VectorUtil
{
	inline public static function createVector<T> (length:Int, fixed:Bool):Vector<T> {
		
		#if js
		return new Array();
		#else
		return new Vector<T> (length, fixed);
		#end
		
	}
}
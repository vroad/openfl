package openfl.utils;


#if (flash || openfl_next || html5 || display)
typedef UInt8Array = lime.utils.UInt8Array;
#else
typedef UInt8Array = openfl._v2.utils.UInt8Array;
#end
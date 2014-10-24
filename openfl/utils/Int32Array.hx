package openfl.utils;


#if (flash || openfl_next || html5 || display)
typedef Int32Array = lime.utils.Int32Array;
#else
typedef Int32Array = openfl._v2.utils.Int32Array;
#end
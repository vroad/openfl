package openfl.utils;


#if (flash || openfl_next || html5 || display)
typedef ArrayBuffer = lime.utils.ArrayBuffer;
#else
typedef ArrayBuffer = openfl._v2.utils.ArrayBuffer;
#end
package openfl.utils;


#if (flash || openfl_next || html5 || display)
typedef Float32Array = lime.utils.Float32Array;
#else
typedef Float32Array = openfl._v2.utils.Float32Array;
#end
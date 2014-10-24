package openfl.utils;


#if flash
typedef CompressionAlgorithm = flash.utils.CompressionAlgorithm;
#elseif (openfl_next || html5 || display)
typedef CompressionAlgorithm = lime.utils.CompressionAlgorithm;
#else
typedef CompressionAlgorithm = openfl._v2.utils.CompressionAlgorithm;
#end
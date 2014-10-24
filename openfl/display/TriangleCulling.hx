package openfl.display; #if !flash #if (display || openfl_next || html5)


enum TriangleCulling {
	
	NEGATIVE;
	NONE;
	POSITIVE;
	
}


#else
typedef TriangleCulling = openfl._v2.display.TriangleCulling;
#end
#else
typedef TriangleCulling = flash.display.TriangleCulling;
#end
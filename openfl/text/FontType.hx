package openfl.text; #if !flash #if (display || openfl_next || html5)


enum FontType {
	
	DEVICE;
	EMBEDDED;
	EMBEDDED_CFF;
	
}


#else
typedef FontType = openfl._v2.text.FontType;
#end
#else
typedef FontType = flash.text.FontType;
#end
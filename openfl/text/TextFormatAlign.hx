package openfl.text; #if !flash #if (display || openfl_next || html5)


enum TextFormatAlign {
	
	LEFT;
	RIGHT;
	JUSTIFY;
	CENTER;
	
}


#else
typedef TextFormatAlign = openfl._v2.text.TextFormatAlign;
#end
#else
typedef TextFormatAlign = flash.text.TextFormatAlign;
#end
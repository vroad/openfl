package openfl.text; #if !flash #if (display || openfl_next || html5)


enum FontStyle {
	
	REGULAR;
	ITALIC;
	BOLD_ITALIC;
	BOLD;
	
}


#else
typedef FontStyle = openfl._v2.text.FontStyle;
#end
#else
typedef FontStyle = flash.text.FontStyle;
#end
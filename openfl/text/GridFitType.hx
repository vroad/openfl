package openfl.text; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_text_GridFitType") extern
#end
enum GridFitType {
	
	NONE;
	PIXEL;
	SUBPIXEL;
	
}


#else
typedef GridFitType = flash.text.GridFitType;
#end
package openfl.display; #if !flash #if !openfl_legacy


interface IGraphicsFill {
	
	var __graphicsFillType (default, null):GraphicsFillType;
	
}

#if openfl_shared
@:jsRequire("openfl", "openfl_display_GraphicsFillType") extern
#end
@:fakeEnum(Int) enum GraphicsFillType {
	
	SOLID_FILL;
	GRADIENT_FILL;
	BITMAP_FILL;
	END_FILL;
	
}


#else
typedef IGraphicsFill = openfl._legacy.display.IGraphicsFill;
#end
#else
typedef IGraphicsFill = flash.display.IGraphicsFill;
#end
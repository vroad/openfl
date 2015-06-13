package openfl.display; #if !flash #if !openfl_legacy


interface IGraphicsData {
	
	var __graphicsDataType (default, null):GraphicsDataType;
	
}

@:fakeEnum(Int)
#if openfl_shared
@:jsRequire("openfl", "openfl_display_GraphicsDataType") extern
#end
enum GraphicsDataType {
	
	STROKE;
	SOLID;
	GRADIENT;
	PATH;
	BITMAP;
	END;
	
}


#else
typedef IGraphicsData = openfl._legacy.display.IGraphicsData;
#end
#else
typedef IGraphicsData = flash.display.IGraphicsData;
#end
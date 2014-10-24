package openfl.display; #if !flash #if (display || openfl_next || html5)


enum StageQuality {
	
	BEST;
	HIGH;
	MEDIUM;
	LOW;
	
}


#else
typedef StageQuality = openfl._v2.display.StageQuality;
#end
#else
typedef StageQuality = flash.display.StageQuality;
#end
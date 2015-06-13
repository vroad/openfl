package openfl.display; #if !flash


/**
 * The StageDisplayState class provides values for the
 * <code>Stage.displayState</code> property.
 */
#if openfl_shared
@:jsRequire("openfl", "openfl_display_StageDisplayState") extern
#end
enum StageDisplayState {
	
	/**
	 * Specifies that the Stage is in normal mode.
	 */
	NORMAL;
	
	/**
	 * Specifies that the Stage is in full-screen mode.
	 */
	FULL_SCREEN;
	
	/**
	 * Specifies that the Stage is in full-screen mode with keyboard interactivity enabled.
	 */
	FULL_SCREEN_INTERACTIVE;
	
}


#else
typedef StageDisplayState = flash.display.StageDisplayState;
#end
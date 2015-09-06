package openfl.text; #if !flash #if !openfl_legacy


/**
 * The TextFormatAlign class provides values for text alignment in the
 * TextFormat class.
 */
#if openfl_shared
@:jsRequire("openfl", "openfl_text_TextFormatAlign") extern
#end
enum TextFormatAlign {
	
	/**
	 * Constant; aligns text to the left within the text field. Use the syntax
	 * <code>TextFormatAlign.LEFT</code>.
	 */
	LEFT;
	
	/**
	 * Constant; aligns text to the right within the text field. Use the syntax
	 * <code>TextFormatAlign.RIGHT</code>.
	 */
	RIGHT;
	
	/**
	 * Constant; justifies text within the text field. Use the syntax
	 * <code>TextFormatAlign.JUSTIFY</code>.
	 */
	JUSTIFY;
	
	/**
	 * Constant; centers the text in the text field. Use the syntax
	 * <code>TextFormatAlign.CENTER</code>.
	 */
	CENTER;
	
	/**
	 * Constant; aligns text to the start edge of a line. Use the syntax
	 * <code>TextFormatAlign.START</code>
	 */
	START;
	
	/**
	 * Constant; aligns text to the end edge of a line. Use the syntax
	 * <code>TextFormatAlign.END</code>
	 */
	END;
	
}


#else
typedef TextFormatAlign = openfl._legacy.text.TextFormatAlign;
#end
#else
typedef TextFormatAlign = flash.text.TextFormatAlign;
#end
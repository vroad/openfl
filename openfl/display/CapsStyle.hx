package openfl.display; #if !flash #if !openfl_legacy


/**
 * The CapsStyle class is an enumeration of constant values that specify the
 * caps style to use in drawing lines. The constants are provided for use as
 * values in the <code>caps</code> parameter of the
 * <code>openfl.display.Graphics.lineStyle()</code> method. You can specify the
 * following three types of caps:
 */
#if openfl_shared
@:jsRequire("openfl", "openfl_display_CapsStyle") extern
#end
enum CapsStyle {
	
	/**
	 * Used to specify no caps in the <code>caps</code> parameter of the
	 * <code>openfl.display.Graphics.lineStyle()</code> method.
	 */
	NONE;
	
	/**
	 * Used to specify round caps in the <code>caps</code> parameter of the
	 * <code>openfl.display.Graphics.lineStyle()</code> method.
	 */
	ROUND;
	
	/**
	 * Used to specify square caps in the <code>caps</code> parameter of the
	 * <code>openfl.display.Graphics.lineStyle()</code> method.
	 */
	SQUARE;
	
}


#else
typedef CapsStyle = openfl._legacy.display.CapsStyle;
#end
#else
typedef CapsStyle = flash.display.CapsStyle;
#end
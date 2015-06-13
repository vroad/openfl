package openfl.text; #if !flash


/**
 * The TextFieldType class is an enumeration of constant values used in
 * setting the <code>type</code> property of the TextField class.
 */
#if openfl_shared
@:jsRequire("openfl", "openfl_text_TextFieldType") extern
#end
enum TextFieldType {
	
	/**
	 * Used to specify a <code>dynamic</code> TextField.
	 */
	DYNAMIC;
	
	/**
	 * Used to specify an <code>input</code> TextField.
	 */
	INPUT;
	
}


#else
typedef TextFieldType = flash.text.TextFieldType;
#end
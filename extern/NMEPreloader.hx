extern class NMEPreloader extends openfl.display.Sprite
{
	function new() : Void;
	private var outline : openfl.display.Sprite;
	private var progress : openfl.display.Sprite;
	function getBackgroundColor() : Int;
	function getHeight() : Float;
	function getWidth() : Float;
	function onInit() : Void;
	function onLoaded() : Void;
	function onUpdate(bytesLoaded:Int, bytesTotal:Int) : Void;
}
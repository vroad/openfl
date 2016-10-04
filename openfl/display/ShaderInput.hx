package openfl.display;
import lime.graphics.opengl.GLUniformLocation;


@:final #if !js @:generic #end  class ShaderInput<T> /*implements Dynamic*/ {
	
	
	public var channels (default, null):Int;
	public var height:Int;
	public var index (default, null):ShaderInputIndex;
	public var input:T;
	@:noCompletion public var name:String;
	public var width:Int;
	
	
	public function new () {
		
		channels = 0;
		height = 0;
		index = null;
		width = 0;
		
	}
	
	
	public function getUniformLocation ():GLUniformLocation {
		
		switch (index) {
			
			case ShaderInputIndex.UniformLocation (v):
				
				return v;
				
			default:
				
				return null;
				
		}
		
	}
	
	
	public function getAttributeLocation ():Int {
		
		switch (index) {
			
			case ShaderInputIndex.AttributeLocation (v):
				
				return v;
				
			default:
				
				return -1;
				
		}
		
	}
	
	
}
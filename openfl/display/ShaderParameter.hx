package openfl.display;
import lime.graphics.opengl.GLUniformLocation;


@:final #if !js @:generic #end  class ShaderParameter<T> /*implements Dynamic*/ {
	
	
	public var index (default, null):ShaderInputIndex;
	@:noCompletion public var name:String;
	public var type (default, null):ShaderParameterType;
	public var value:Array<T>;
	
	
	public function new () {
		
		index = null;
		
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
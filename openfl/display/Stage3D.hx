package openfl.display; #if !flash


import haxe.Timer;
import openfl.display.OpenGLView;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DRenderMode;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;


class Stage3D extends EventDispatcher {
	
	
	public var context3D:Context3D;
	public var visible:Bool; // TODO
	public var x(default, set):Float;
	public var y(default, set):Float;
	
	
	public function new () {
		
		super ();
		visible = true;
		x = 0;
		y = 0;
		
	}
	
	public function requestContext3D (context3DRenderMode:Context3DRenderMode = null):Void {
		
		if (OpenGLView.isSupported) {
			
			Timer.delay(function() {
				
				context3D = new Context3D (this);
				dispatchEvent (new Event (Event.CONTEXT3D_CREATE));
				
			}, 1);
			
		} else {
			
			Timer.delay(function() {
				
				dispatchEvent (new ErrorEvent (ErrorEvent.ERROR));
				
			}, 1);
			
		}
		
	}
	
	@:noCompletion private function set_x(value:Float):Float {
		
		this.x = value;
		
		if (context3D != null) {
			
			context3D.__moveStage3D (this);
			
		}
		
		return value;
		
	}
	
	@:noCompletion private function set_y(value:Float):Float {
		
		this.y = value;
		
		if (context3D != null) {
			
			context3D.__moveStage3D (this);
			
		}
		
		return value;
		
	}
	
}


#else
typedef Stage3D = flash.display.Stage3D;
#end
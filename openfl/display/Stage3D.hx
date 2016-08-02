package openfl.display;


import haxe.Timer;
import openfl._internal.renderer.opengl.GLStage3D;
import openfl._internal.renderer.RenderSession;
import openfl.display.OpenGLView;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProfile;
import openfl.display3D.Context3DRenderMode;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.Vector;

@:access(openfl.display3D.Context3D)


class Stage3D extends EventDispatcher {
	
	
	public var context3D (default, null):Context3D;
	public var visible:Bool; // TODO
	public var x:Float;
	public var y:Float;
	
	
	public function new () {
		
		super ();
		visible = true;
		x = 0;
		y = 0;
		
	}
	
	
	public function requestContext3D (context3DRenderMode:Context3DRenderMode = AUTO, profile:Context3DProfile = BASELINE):Void {
		
		Timer.delay (function () {
			
			if (OpenGLView.isSupported) {
				
				context3D = new Context3D (this);
				dispatchEvent (new Event (Event.CONTEXT3D_CREATE));
				
			} else {
				
				dispatchEvent (new ErrorEvent (ErrorEvent.ERROR));
				
			}
			
		}, 1);
		
	}
	
	
	public function requestContext3DMatchingProfiles (profiles:Vector<Context3DProfile>):Void {
		
		requestContext3D ();
		
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
	
	public function __renderGL (renderSession:RenderSession):Void {
		
		if (context3D != null) {
			
			GLStage3D.render (this, renderSession);
			
		}
		
	}
	
	
}
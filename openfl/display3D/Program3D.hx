package openfl.display3D;


import lime.graphics.opengl.GLES20;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;

@:access(openfl.display3D.Context3D)


@:final class Program3D {
	
	
	private var __context:Context3D;
	private var __glProgram:GLProgram;
	
	/*#! Haxiomic Addition for performance improvements */
	private var __glFCLocationMap:Array<GLUniformLocation>;
	private var __glVCLocationMap:Array<GLUniformLocation>;
	private var __glFSLocationMap:Array<GLUniformLocation>; // sampler
	private var __glVALocationMap:Array<Int>;
	
	private var __yFlip:GLUniformLocation;
	
	
	private function new (context:Context3D, program:GLProgram) {
		
		__context = context;
		__glProgram = program;
		__glFCLocationMap = new Array<GLUniformLocation> ();
		__glVCLocationMap = new Array<GLUniformLocation> ();
		__glFSLocationMap = new Array<GLUniformLocation> ();
		__glVALocationMap = new Array<Int> ();
		__yFlip = null;
		
	}
	
	
	public function dispose ():Void {
		
		__context.__deleteProgram (this);
		
	}
	
	
	public function upload (vertexProgram:Dynamic, fragmentProgram:Dynamic):Void {
		
		__context.gl.attachShader (__glProgram, vertexProgram);
		__context.gl.attachShader (__glProgram, fragmentProgram);
		__context.gl.linkProgram (__glProgram);
		
		if (__context.gl.getProgramParameter (__glProgram, GLES20.LINK_STATUS) == 0) {
			
			var result = __context.gl.getProgramInfoLog (__glProgram);
			if (result != "") throw result;
			
		}
		
		for (i in 0 ... __context.gl.getProgramParameter (__glProgram, GLES20.ACTIVE_UNIFORMS)) {
			
			var info = __context.gl.getActiveUniform (__glProgram, i);
			var loc = __context.gl.getUniformLocation (__glProgram, info.name);
			
			if (info.name == "yflip") {
				
				__yFlip = loc;
				
			} else {
				
				var name = info.name.substr (0, 2);
				var idx = Std.parseInt (info.name.substr (2));
				
				switch (info.name.substr (0, 2)) {
					
					case "fc": __glFCLocationMap[idx] = loc;
					case "vc": __glVCLocationMap[idx] = loc;
					case "fs": __glFSLocationMap[idx] = loc;
					
				}
				
			}
			
		}
		
		var info, name, idx;
		
		for (i in 0 ... __context.gl.getProgramParameter (__glProgram, GLES20.ACTIVE_ATTRIBUTES)) {
			
			info = __context.gl.getActiveAttrib (__glProgram, i);
			name = info.name.substr (0, 2);
			idx = Std.parseInt (info.name.substr (2));
			
			if (name == "va") {
				
				__glVALocationMap[idx] = i;
				
			}
			
		}
		
	}
	
	
	private inline function __constUniformLocationFromAgal (type:Context3DProgramType, i:Int):GLUniformLocation {
		
		if (type == Context3DProgramType.VERTEX) {
			
			return __vsUniformLocationFromAgal (i);
			
		} else {
			
			return __fsUniformLocationFromAgal (i);
			
		}
		
	}
	
	
	private inline function __fsampUniformLocationFromAgal (i:Int):GLUniformLocation {
		
		return __glFSLocationMap[i];
		
	}
	
	
	private inline function __fsUniformLocationFromAgal (i:Int):GLUniformLocation {
		
		return __glFCLocationMap[i];
		
	}
	
	
	private inline function __vaUniformLocationFromAgal (i:Int):Int {
		
		return i >= 0 &&  i < __glVALocationMap.length ? __glVALocationMap[i] : -1;
		
	}
	
	
	private inline function __vsUniformLocationFromAgal (i:Int):GLUniformLocation {
		
		return __glVCLocationMap[i];
		
	}
	
	
	private inline function __yFlipLoc ():GLUniformLocation {
		
		return __yFlip;
		
	}
	
	
}
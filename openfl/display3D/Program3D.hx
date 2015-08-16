package openfl.display3D; #if !flash


import openfl.gl.GL;
import openfl.gl.GLActiveInfo;
import openfl.gl.GLProgram;
import openfl.gl.GLShader;
import openfl.gl.GLUniformLocation;

@:final class Program3D {
	
	public var glProgram:GLProgram;
	/*#! Haxiomic Addition for performance improvements */
	public var glFCLocationMap:Array<GLUniformLocation>;
	public var glVCLocationMap:Array<GLUniformLocation>;
	public var glFSLocationMap:Array<GLUniformLocation>; // sampler
	public var glVALocationMap:Array<Int>;

	public function new(program:GLProgram) {
		
		this.glProgram = program;
		this.glFCLocationMap = new Array<GLUniformLocation> ();
		this.glVCLocationMap = new Array<GLUniformLocation> ();
		this.glFSLocationMap = new Array<GLUniformLocation> ();
		this.glVALocationMap = new Array<Int> ();
		
	}
	
	
	public function dispose ():Void {
		
		GL.deleteProgram (glProgram);
		
	}
	
	
	public function upload (vertexShader:GLShader, fragmentShader:GLShader):Void {
		
		// TODO: Use ByteArray instead of Shader?
		
		GL.attachShader (glProgram, vertexShader);
		GL.attachShader (glProgram, fragmentShader);
		GL.linkProgram (glProgram);
		
		if (GL.getProgramParameter (glProgram, GL.LINK_STATUS) == 0) {
			
			var result = GL.getProgramInfoLog (glProgram);
			if (result != "") throw result;
			
		}

		for (i in 0 ... GL.getProgramParameter (glProgram, GL.ACTIVE_UNIFORMS)) {
			
			var info:GLActiveInfo = GL.getActiveUniform (glProgram, i);
			var loc:GLUniformLocation = GL.getUniformLocation (glProgram, info.name);
			
			if (yFlip == null && info.name == "yflip") {
				
				yFlip = loc;
				
			}
			else {
				
				var name:String = info.name.substr (0, 2);
				var idx:Int = Std.parseInt (info.name.substr (2));
				
				switch (info.name.substr (0, 2)) {
				
				case "fc": glFCLocationMap[idx] = loc;
				case "vc": glVCLocationMap[idx] = loc;
				case "fs": glFSLocationMap[idx] = loc;
				
				}
				
			}
			
		}
		
		for(i in 0 ... GL.getProgramParameter (glProgram, GL.ACTIVE_ATTRIBUTES)) {
			
			var info:GLActiveInfo = GL.getActiveAttrib (glProgram, i);
			var name:String = info.name.substr (0, 2);
			var idx:Int = Std.parseInt(info.name.substr (2));
			if (name == "va")
				glVALocationMap[idx] = i;
			
		}
	}
	
	var yFlip:Null<GLUniformLocation>;
	
	public inline function yFlipLoc():GLUniformLocation {
		
		return yFlip;
		
	}
	
	public inline function fsUniformLocationFromAgal(i:Int):GLUniformLocation {
		
		return glFCLocationMap[i];
		
	}
	
	public inline function vsUniformLocationFromAgal(i:Int):GLUniformLocation {
		
		return glVCLocationMap[i];
		
	}
	
	//sampler
	public inline function fsampUniformLocationFromAgal(i:Int):GLUniformLocation {
		
		return glFSLocationMap[i];
		
	}
	
	public inline function vaUniformLocationFromAgal(i:Int):Int {
		
		return glVALocationMap[i];
		
	}
	
}


#else
typedef Program3D = flash.display3D.Program3D;
#end
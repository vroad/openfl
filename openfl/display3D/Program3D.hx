package openfl.display3D;


import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLActiveInfo;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import openfl._internal.aglsl.AGLSLCompiler;
import openfl.utils.ByteArray;


@:final class Program3D {
	
	
	public var context:Context3D;
	public var glProgram:GLProgram;
	/*#! Haxiomic Addition for performance improvements */
	private var glFCLocationMap:Array<GLUniformLocation>;
	private var glVCLocationMap:Array<GLUniformLocation>;
	private var glFSLocationMap:Array<GLUniformLocation>; // sampler
	private var glVALocationMap:Array<Int>;
	
	
	public function new (context:Context3D, program:GLProgram) {
		
		this.context = context;
		this.glProgram = program;
		this.glFCLocationMap = new Array<GLUniformLocation> ();
		this.glVCLocationMap = new Array<GLUniformLocation> ();
		this.glFSLocationMap = new Array<GLUniformLocation> ();
		this.glVALocationMap = new Array<Int> ();
		
	}
	
	
	public function dispose ():Void {
		
		context.__deleteProgram (this);
		
	}
	
	
	public function upload (vertexShader:Dynamic, fragmentShader:Dynamic):Void {
		
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
			var idx:Int = Std.parseInt (info.name.substr (2));
			if (name == "va")
				glVALocationMap[idx] = i;
			
		}
	}
	
	var yFlip:Null<GLUniformLocation>;
	
	public inline function yFlipLoc ():GLUniformLocation {
		
		return yFlip;
		
	}
	
	public inline function fsUniformLocationFromAgal (i:Int):GLUniformLocation {
		
		#if html5
		return glFCLocationMap[i];
		#else
		return i >= 0 && i < glFCLocationMap.length ? glFCLocationMap[i] : -1;
		#end
		
	}
	
	public inline function vsUniformLocationFromAgal(i:Int):GLUniformLocation {
		
		#if html5
		return glVCLocationMap[i];
		#else
		return i >= 0 && i < glVCLocationMap.length ? glVCLocationMap[i] : -1;
		#end
		
	}
	
	//sampler
	public inline function fsampUniformLocationFromAgal(i:Int):GLUniformLocation {
		
		#if html5
		return glFSLocationMap[i];
		#else
		return i >= 0 &&  i < glFSLocationMap.length ? glFSLocationMap[i] : -1;
		#end
		
	}
	
	public inline function vaUniformLocationFromAgal(i:Int):Int {
		
		return i >= 0 && i < glVALocationMap.length ? glVALocationMap[i] : -1;
		
	}
	
	public inline function constUniformLocationFromAgal (type:Context3DProgramType, i:Int):GLUniformLocation {
		
		if (type == Context3DProgramType.VERTEX) {
			
			return vsUniformLocationFromAgal (i);
			
		} else {
				
			return fsUniformLocationFromAgal (i);
			
		}
		
	}
	
	
}
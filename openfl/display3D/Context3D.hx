package openfl.display3D;


import lime.app.Application;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.ExtensionBGRA;
import lime.graphics.opengl.GLES20;
import lime.graphics.opengl.GLFramebuffer;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLRenderbuffer;
import lime.utils.Float32Array;
import openfl.display.BitmapData;
import openfl.display.OpenGLView;
import openfl.display.Stage3D;
import openfl.display3D.textures.CubeTexture;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.display3D.textures.TextureBase;
import openfl.display3D._internal.RenderBufferType;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.geom.Matrix3D;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.Lib;

@:access(openfl.display3D.textures.CubeTexture)
@:access(openfl.display3D.textures.RectangleTexture)
@:access(openfl.display3D.textures.Texture)
@:access(openfl.display3D.textures.TextureBase)
@:access(openfl.display3D.IndexBuffer3D)
@:access(openfl.display3D.Program3D)
@:access(openfl.display3D.VertexBuffer3D)


@:final class Context3D {
	
	
	public static var supportsVideoTexture (default, null):Bool = false;
	
	private static var TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE;
	private static var MAX_SAMPLERS = 8;
	private static var MAX_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FF;
	
	private static var __anisotropySupportTested:Bool = false;
	private static var __maxSupportedAnisotropy:UInt = 256;
	private static var __supportsAnisotropy:Bool = false;
	private static var supportsPackedDepthStencil:Null<Bool> = null;
	
	public var backBufferHeight (default, null):Int;
	public var backBufferWidth (default, null):Int;
	public var driverInfo (default, null):String = "OpenGL (Direct blitting)";
	public var enableErrorChecking:Bool; // TODO (use gl.getError() and gl.validateProgram(program))
	public var maxBackBufferHeight:Int;
	public var maxBackBufferWidth:Int;
	public var profile (default, null):Context3DProfile = BASELINE;
	public var totalGPUMemory (default, null):Int = 0;
	
	private var __blendDestinationFactor:Context3DBlendFactor; // to mimic Stage3d behavior of keeping blending across frames:
	private var __blendEnabled:Bool; // to mimic Stage3d behavior of keeping blending across frames:
	private var __blendSourceFactor:Context3DBlendFactor; // to mimic Stage3d behavior of keeping blending across frames:
	private var __currentProgram:Program3D;
	private var __disposed:Bool;
	private var __drawing:Bool; // to mimic Stage3d behavior of not allowing calls to drawTriangles between present and clear
	private var __framebuffer:GLFramebuffer;
	private var __indexBuffersCreated:Array<IndexBuffer3D>; // to keep track of stuff to dispose when calling dispose
	private var __ogl:OpenGLView;
	private var __programsCreated:Array<Program3D>; // to keep track of stuff to dispose when calling dispose
	private var __renderbuffer:GLRenderbuffer;
	private var __samplerParameters:Array<SamplerState>; //TODO : use Tupple3
	private var __scrollRect:Rectangle;
	private var __stencilbuffer:GLRenderbuffer;
	private var __stencilCompareMode:Context3DCompareMode;
	private var __stencilRef:Int;
	private var __stencilReadMask:Int;
	private var __texturesCreated:Array<TextureBase>; // to keep track of stuff to dispose when calling dispose
	private var __vertexBuffersCreated:Array<VertexBuffer3D>; // to keep track of stuff to dispose when calling dispose
	private var __yFlip:Float;
	private var __backBufferDepthAndStencil:Bool;
	private var __rttDepthAndStencil:Bool;
	private var __scissorRectangle:Rectangle;
	private var __renderToTexture:Bool;
	private var __rttWidth:Int;
	private var __rttHeight:Int;
	private var renderBuffers:Map<RenderBufferType, GLRenderbuffer>;
	private var gl (get, null):GLRenderContext;
	
	
	private function new (stage3D:Stage3D) {
		
		__disposed = false;
		__drawing = false;
		
		__stencilCompareMode = Context3DCompareMode.ALWAYS;
		__stencilRef = 0;
		__stencilReadMask = 0xFF;
		
		__yFlip = 1;
		
		__vertexBuffersCreated = new Array ();
		__indexBuffersCreated = new Array ();
		__programsCreated = new Array ();
		__texturesCreated = new Array (); 
		__samplerParameters = new Array<SamplerState> ();
		
		for (i in 0...MAX_SAMPLERS) {
			
			__samplerParameters[i] = new SamplerState ();
			__samplerParameters[i].wrap = Context3DWrapMode.CLAMP;
			__samplerParameters[i].filter = Context3DTextureFilter.LINEAR;
			__samplerParameters[i].mipfilter =Context3DMipFilter.MIPNONE;
			
		}
		
		var stage = Lib.current.stage;
		
		__ogl = new OpenGLView ();
		var width:Float = stage.stageWidth;
		var height:Float = stage.stageHeight;
		__ogl.scrollRect = new Rectangle (0, 0, stage3D.x + width , stage3D.y + height);
		__scrollRect = new Rectangle (stage3D.x, stage3D.y, width, height);
		
		stage.addChildAt (__ogl, 0);
		
		__backBufferDepthAndStencil = false;
		__rttDepthAndStencil = false;
		__renderToTexture = false;
		__rttWidth = 0;
		__rttHeight = 0;
		renderBuffers = new Map ();
		
		maxBackBufferWidth = 4096;
		maxBackBufferHeight = 4096;
		
	}
	
	
	public function clear (red:Float = 0, green:Float = 0, blue:Float = 0, alpha:Float = 1, depth:Float = 1, stencil:UInt = 0, mask:Context3DClearMask = ALL):Void {
		
		if (!__drawing) {
			
		 	//__updateBlendStatus ();
		 	__drawing = true;
		 	
		}
		
		if (__scissorRectangle != null) {
			
			gl.disable (GLES20.SCISSOR_TEST);
			
		}
		
		gl.clearColor (red, green, blue, alpha);
		gl.clearDepth (depth);
		gl.clearStencil (stencil);
		
		gl.clear (__getGLClearMask (mask));
		
		if (__scissorRectangle != null) {
			
			gl.enable (GLES20.SCISSOR_TEST);
			
		}
		
	}
	
	
	public function configureBackBuffer (width:Int, height:Int, antiAlias:Int, enableDepthAndStencil:Bool = true, wantsBestResolution:Bool = false, wantsBestResolutionOnBrowserZoom:Bool = false):Void {
		
		__backBufferDepthAndStencil = enableDepthAndStencil;
		__updateDepthAndStencilState ();
		
		// TODO use antiAlias parameter
		__setBackBufferViewPort (null, null, width, height);
		__updateScissorRectangle ();
		
	}
	
	
	public function createCubeTexture (size:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int = 0):CubeTexture {
		
		var glFormat = getGLTextureFormat (format);
		var texture = new CubeTexture (this, gl.createTexture (), size, glFormat.format, glFormat.type); // TODO use format, optimizeForRenderToTexture and streamingLevels?
		__texturesCreated.push (texture);
		return texture;
		
	}
	
	
	public function createIndexBuffer (numIndices:Int, bufferUsage:Context3DBufferUsage = STATIC_DRAW):IndexBuffer3D {
		
		var indexBuffer = new IndexBuffer3D (this, gl.createBuffer(), numIndices, bufferUsage == Context3DBufferUsage.STATIC_DRAW ? GLES20.STATIC_DRAW : GLES20.DYNAMIC_DRAW);
		__indexBuffersCreated.push (indexBuffer);
		return indexBuffer;
		
	}
	
	
	public function createProgram ():Program3D {
		
		var program = new Program3D (this, gl.createProgram ());
		__programsCreated.push (program);
		return program;
		
	}
	
	
	public function createRectangleTexture (width:Int, height:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool):RectangleTexture {
		
		var glFormat = getGLTextureFormat(format);
		var texture = new RectangleTexture (this, gl.createTexture (), optimizeForRenderToTexture, width, height, glFormat.format, glFormat.type); // TODO use format, optimizeForRenderToTexture and streamingLevels?
		__texturesCreated.push (texture);
		return texture;
		
	}
	
	
	public function createTexture (width:Int, height:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int = 0):Texture {
		
		var glFormat = getGLTextureFormat(format);
		var texture = new Texture (this, gl.createTexture (), optimizeForRenderToTexture, width, height, glFormat.format, glFormat.type); // TODO use format, optimizeForRenderToTexture and streamingLevels?
		__texturesCreated.push (texture);
		return texture;
		
	}
	
	private function getGLTextureFormat(format:Context3DTextureFormat):{format:Int, type:Int}
	{
		
		switch (format)
		{
			
			case Context3DTextureFormat.BGRA:
				#if html5
				return { format:GLES20.RGBA, type:GLES20.UNSIGNED_BYTE };
				#else
				return { format:ExtensionBGRA.BGRA_EXT, type:GLES20.UNSIGNED_BYTE };
				#end
			default:
				return null;
			
		}
		
	}

	
	public function createVertexBuffer (numVertices:Int, data32PerVertex:Int, bufferUsage:Context3DBufferUsage = STATIC_DRAW):VertexBuffer3D {
		
		var vertexBuffer = new VertexBuffer3D (this, gl.createBuffer (), numVertices, data32PerVertex, bufferUsage == Context3DBufferUsage.STATIC_DRAW ? GLES20.STATIC_DRAW : GLES20.DYNAMIC_DRAW);
		__vertexBuffersCreated.push (vertexBuffer);
		return vertexBuffer;
		
	}
	
	
	public function dispose (recreate:Bool = true):Void {
		
		// TODO handle recreate
		// TODO simulate context loss by recreating a context3d and dispatch event on Stage3d(see Adobe Doc)
		// TODO add error on other method when context3d is disposed
		
		for (vertexBuffer in __vertexBuffersCreated) {
			
			vertexBuffer.dispose ();
			
		}
		
		__vertexBuffersCreated = null;
		
		for (indexBuffer in __indexBuffersCreated) {
			
			indexBuffer.dispose ();
			
		}
		
		__indexBuffersCreated = null;
		
		for (program in __programsCreated) {
			
			program.dispose ();
			
		}
		
		__programsCreated = null;
		__samplerParameters = null;
		
		for (texture in __texturesCreated) {
			
			texture.dispose ();
			
		}
		
		__texturesCreated = null;
		
		for (renderBuffer in renderBuffers) {
			
			gl.deleteRenderbuffer (renderBuffer);
			
		}
		
		renderBuffers = null;
		
		__disposed = true;
		
	}
	
	
	public function drawToBitmapData (destination:BitmapData):Void {
		
		// TODO
		
	}
	
	
	public function drawTriangles (indexBuffer:IndexBuffer3D, firstIndex:Int = 0, numTriangles:Int = -1):Void {
		
		var location = __currentProgram.__yFlipLoc ();
		gl.uniform1f (location, __yFlip);
		
		if (!__drawing && !__renderToTexture) {
			
			throw new Error ("Need to clear before drawing if the buffer has not been cleared since the last present() call.");
			
		}
		
		var numIndices;
		
		if (numTriangles == -1) {
			
			numIndices = indexBuffer.__numIndices;
			
		} else {
			
			numIndices = numTriangles * 3;
			
		}
		
		var byteOffset = firstIndex * 2;
		
		gl.bindBuffer (GLES20.ELEMENT_ARRAY_BUFFER, indexBuffer.__glBuffer);
		gl.drawElements (GLES20.TRIANGLES, numIndices, GLES20.UNSIGNED_SHORT, byteOffset);
		
	}
	
	
	public function present ():Void {
		
		__drawing = false;
		
	}
	
	
	public function setBlendFactors (sourceFactor:Context3DBlendFactor, destinationFactor:Context3DBlendFactor):Void {
		
		__blendEnabled = true;
		__blendSourceFactor = sourceFactor;
		__blendDestinationFactor = destinationFactor;
		
		__updateBlendStatus ();
		
	}
	
	
	public function setColorMask (red:Bool, green:Bool, blue:Bool, alpha:Bool):Void {
		
		gl.colorMask (red, green, blue, alpha);
		
	}
	
	
	public function setCulling (triangleFaceToCull:Context3DTriangleFace):Void {
		
		if (triangleFaceToCull == Context3DTriangleFace.NONE) {
			
			gl.disable (GLES20.CULL_FACE);
			
		} else {
			
			gl.enable (GLES20.CULL_FACE);
			
			switch (triangleFaceToCull) {
				
				case Context3DTriangleFace.FRONT: gl.cullFace (GLES20.BACK);
				case Context3DTriangleFace.BACK: gl.cullFace (GLES20.FRONT);
				case Context3DTriangleFace.FRONT_AND_BACK: gl.cullFace (GLES20.FRONT_AND_BACK);
				default: throw "Unknown Context3DTriangleFace type.";
				
			}
			
		}
		
		switch (triangleFaceToCull) {
			
			case Context3DTriangleFace.FRONT:
				
				__yFlip = -1;
			
			case Context3DTriangleFace.BACK:
				
				__yFlip = 1; // checked
			
			case Context3DTriangleFace.FRONT_AND_BACK:
				
				__yFlip = 1;
			
			case Context3DTriangleFace.NONE:
				
				__yFlip = 1; // checked
			
			default:
				
				throw "Unknown culling mode " + triangleFaceToCull + ".";
 			
 		}
		
	}
	
	
	public function setDepthTest (depthMask:Bool, passCompareMode:Context3DCompareMode):Void {
		
		gl.depthFunc (__getGLCompareMode (passCompareMode));
		gl.depthMask (depthMask);
		
	}
	
	
	public function setProgram (program3D:Program3D):Void {
		
		var glProgram = null;
		
		if (program3D != null) {
			
			glProgram = program3D.__glProgram;
			
		}
		
		gl.useProgram (glProgram);
		__currentProgram = program3D;
		//TODO reset bound textures, buffers... ?
		// Or maybe we should have arrays and map for each program so we can switch them while keeping the bounded texture and variable?
		
	}
	
	
	public function setProgramConstantsFromByteArray (programType:Context3DProgramType, firstRegister:Int, numRegisters:Int, data:ByteArray, byteArrayOffset:UInt):Void {
		
		data.position = byteArrayOffset;
		
		for (i in 0...numRegisters) {
			
			var location = __currentProgram.__constUniformLocationFromAgal (programType, firstRegister + i);
			__setGLSLProgramConstantsFromByteArray (location, data);
			
		}
		
	}
	
	
	public function setProgramConstantsFromMatrix (programType:Context3DProgramType, firstRegister:Int, matrix:Matrix3D, transposedMatrix:Bool = false):Void {
		
		// var locationName = __getUniformLocationNameFromAgalRegisterIndex (programType, firstRegister);
		// setProgramConstantsFromVector (programType, firstRegister, matrix.rawData, 16);
		
		var d = matrix.rawData;
		
		if (transposedMatrix) {
			
			setProgramConstantsFromVector(programType, firstRegister, [ d[0], d[4], d[8], d[12] ], 1);  
			setProgramConstantsFromVector(programType, firstRegister + 1, [ d[1], d[5], d[9], d[13] ], 1);
			setProgramConstantsFromVector(programType, firstRegister + 2, [ d[2], d[6], d[10], d[14] ], 1);
			setProgramConstantsFromVector(programType, firstRegister + 3, [ d[3], d[7], d[11], d[15] ], 1);
			
		} else {
			
			setProgramConstantsFromVector(programType, firstRegister, [ d[0], d[1], d[2], d[3] ], 1);
			setProgramConstantsFromVector(programType, firstRegister + 1, [ d[4], d[5], d[6], d[7] ], 1);
			setProgramConstantsFromVector(programType, firstRegister + 2, [ d[8], d[9], d[10], d[11] ], 1);
			setProgramConstantsFromVector(programType, firstRegister + 3, [ d[12], d[13], d[14], d[15] ], 1);
			
		}
		
	}
	
	
	public function setProgramConstantsFromVector (programType:Context3DProgramType, firstRegister:Int, data:Vector<Float>, numRegisters:Int = 1):Void {
		
		for (i in 0...numRegisters) {
			
			var currentIndex = i * 4;
			var location = __currentProgram.__constUniformLocationFromAgal (programType, firstRegister + i);
			__setGLSLProgramConstantsFromVector4 (location, data, currentIndex);
			
		}
		
	}
	
	
	public function setRenderToBackBuffer ():Void {
		
		gl.bindFramebuffer (GLES20.FRAMEBUFFER, null);
		
		__renderToTexture = false;
		__updateBackBufferViewPort ();
		__updateScissorRectangle();
		__updateDepthAndStencilState();
		
	}
	
	
	public function setRenderToTexture (texture:TextureBase, enableDepthAndStencil:Bool = false, antiAlias:Int = 0, surfaceSelector:Int = 0):Void {
		
		if (texture.__frameBuffer == null) {
			
			texture.__frameBuffer = gl.createFramebuffer ();
			
		}
		
		gl.bindFramebuffer (GLES20.FRAMEBUFFER, texture.__frameBuffer);
		
		if (supportsPackedDepthStencil == null) {
			
			supportsPackedDepthStencil = __hasGLExtension ("GL_OES_packed_depth_stencil") || __hasGLExtension ("GL_EXT_packed_depth_stencil");
			
		}
		
		var depthStencilRenderBuffer = null;
		var depthRenderBuffer = null;
		var stencilRenderBuffer = null;
		
		if (enableDepthAndStencil) {
			
			if (supportsPackedDepthStencil) {
				
				depthStencilRenderBuffer = renderBuffers[RenderBufferType.DepthStencil];
				
				if (depthStencilRenderBuffer == null) {
					
					renderBuffers[RenderBufferType.DepthStencil] = depthStencilRenderBuffer = gl.createRenderbuffer ();
					
				}
				
			} else {
				
				depthRenderBuffer = renderBuffers[RenderBufferType.Depth];
				stencilRenderBuffer = renderBuffers[RenderBufferType.Stencil];
				
				if (depthRenderBuffer == null) {
					
					renderBuffers[RenderBufferType.Depth] = depthRenderBuffer = gl.createRenderbuffer ();
					
				}
				
				if (stencilRenderBuffer == null) {
					
					renderBuffers[RenderBufferType.Stencil] = stencilRenderBuffer = gl.createRenderbuffer ();
					
				}
				
			}
			
		}
		
		if (enableDepthAndStencil) {
			
			if (supportsPackedDepthStencil) {
				
				gl.bindRenderbuffer (GLES20.RENDERBUFFER, depthStencilRenderBuffer);
				gl.renderbufferStorage (GLES20.RENDERBUFFER, GLES20.DEPTH_STENCIL, texture.__width, texture.__height);
				
			} else {
				
				gl.bindRenderbuffer (GLES20.RENDERBUFFER, depthRenderBuffer);
				gl.renderbufferStorage (GLES20.RENDERBUFFER, GLES20.DEPTH_COMPONENT16, texture.__width, texture.__height);
				gl.bindRenderbuffer (GLES20.RENDERBUFFER, stencilRenderBuffer);
				gl.renderbufferStorage (GLES20.RENDERBUFFER, GLES20.STENCIL_INDEX8, texture.__width, texture.__height);
				
			}
			
			gl.bindRenderbuffer (GLES20.RENDERBUFFER, null);
			
		}
		
		gl.framebufferTexture2D (GLES20.FRAMEBUFFER, GLES20.COLOR_ATTACHMENT0, GLES20.TEXTURE_2D, texture.__glTexture, 0);
		
		if (enableDepthAndStencil) {
			
			if (supportsPackedDepthStencil) {
				
				gl.framebufferRenderbuffer (GLES20.FRAMEBUFFER, GLES20.DEPTH_STENCIL_ATTACHMENT, GLES20.RENDERBUFFER, depthStencilRenderBuffer);
				
			} else {
				
				gl.framebufferRenderbuffer (GLES20.FRAMEBUFFER, GLES20.DEPTH_ATTACHMENT, GLES20.RENDERBUFFER, depthRenderBuffer);
				gl.framebufferRenderbuffer (GLES20.FRAMEBUFFER, GLES20.STENCIL_ATTACHMENT, GLES20.RENDERBUFFER, stencilRenderBuffer);
				
			}
			
		}
		
		gl.viewport (0, 0, texture.__width, texture.__height);
		
		__renderToTexture = true;
		__rttDepthAndStencil = enableDepthAndStencil;
		__rttWidth = texture.__width;
		__rttHeight = texture.__height;
		__updateScissorRectangle ();
		__updateDepthAndStencilState ();
		
	}
	
	
	public function setSamplerStateAt (sampler:Int, wrap:Context3DWrapMode, filter:Context3DTextureFilter, mipfilter:Context3DMipFilter):Void {
		
		//TODO for flash < 11.6 : patch the AGAL (using specific opcodes) and rebuild the program? 
		
		if (0 <= sampler && sampler <  MAX_SAMPLERS) {
			
			__samplerParameters[sampler].wrap = wrap;
			__samplerParameters[sampler].filter = filter;
			__samplerParameters[sampler].mipfilter = mipfilter;
			
		} else {
			
			throw "Sampler is out of bounds.";
			
		}
		
	}
	
	
	public function setScissorRectangle (rectangle:Rectangle):Void {
		
		__scissorRectangle = rectangle;
		
		if (rectangle == null) {
			
			gl.disable (GLES20.SCISSOR_TEST);
			return;
			
		}
		
		gl.enable (GLES20.SCISSOR_TEST);
		__updateScissorRectangle ();
		
	}
	
	
	public function setStencilActions (triangleFace:Context3DTriangleFace = FRONT_AND_BACK, compareMode:Context3DCompareMode = ALWAYS, actionOnBothPass:Context3DStencilAction = KEEP, actionOnDepthFail:Context3DStencilAction = KEEP, actionOnDepthPassStencilFail:Context3DStencilAction = KEEP):Void {
		
		__stencilCompareMode = compareMode;
		gl.stencilOp (__getGLStencilAction (actionOnDepthFail), __getGLStencilAction (actionOnDepthPassStencilFail), __getGLStencilAction (actionOnBothPass));
		gl.stencilFunc (__getGLCompareMode (__stencilCompareMode), __stencilRef, __stencilReadMask);
		
	}
	
	
	public function setStencilReferenceValue (referenceValue:UInt, readMask:UInt = 0xFF, writeMask:UInt = 0xFF):Void {
		
		__stencilReadMask = readMask;
		__stencilRef = referenceValue;
		
		gl.stencilFunc (__getGLCompareMode (__stencilCompareMode), __stencilRef, __stencilReadMask);
		gl.stencilMask (writeMask);
		
	}
	
	
	public function setTextureAt (sampler:Int, texture:TextureBase):Void {
		
		var location = __currentProgram.__fsampUniformLocationFromAgal (sampler);
		__setGLSLTextureAt (location, texture, sampler);
		
	}
	
	
	public function setVertexBufferAt (index:Int, buffer:VertexBuffer3D, bufferOffset:Int = 0, format:Context3DVertexBufferFormat = FLOAT_4):Void {
		
		var location = __currentProgram.__vaUniformLocationFromAgal (index);
		__setGLSLVertexBufferAt (location, buffer, bufferOffset, format);
		
	}
	
	
	private function __deleteIndexBuffer (buffer:IndexBuffer3D):Void {
		
		if (buffer.__glBuffer == null) {
			
			return;
			
		}
		
		__indexBuffersCreated.remove (buffer);
		gl.deleteBuffer (buffer.__glBuffer);
		buffer.__glBuffer = null;
		
	}
	
	
	private function __deleteProgram (program:Program3D):Void {
		
		if (program.__glProgram == null) {
			
			return;
			
		}
		
		__programsCreated.remove (program);
		gl.deleteProgram (program.__glProgram);
		program.__glProgram = null;
		
	}
	
	
	private function __deleteTexture (texture:TextureBase):Void {
		
		if (texture.__glTexture == null) {
			
			return;
			
		}
		
		__texturesCreated.remove (texture);
		gl.deleteTexture (texture.__glTexture);
		texture.__glTexture = null;
		
	}
	
	
	private function __deleteVertexBuffer (buffer:VertexBuffer3D):Void {
		
		if (buffer.__glBuffer == null) {
			
			return;
			
		}
		
		__vertexBuffersCreated.remove (buffer);
		gl.deleteBuffer (buffer.__glBuffer);
		buffer.__glBuffer = null;
		
	}
	
	
	private function __getGLBlend (blendMode:Context3DBlendFactor):Int {
		
		return switch (blendMode) {
			
			case DESTINATION_ALPHA: GLES20.DST_ALPHA;
			case DESTINATION_COLOR: GLES20.DST_COLOR;
			case ONE: GLES20.ONE;
			case ONE_MINUS_DESTINATION_ALPHA: GLES20.ONE_MINUS_DST_ALPHA;
			case ONE_MINUS_DESTINATION_COLOR: GLES20.ONE_MINUS_DST_COLOR;
			case ONE_MINUS_SOURCE_ALPHA: GLES20.ONE_MINUS_SRC_ALPHA;
			case ONE_MINUS_SOURCE_COLOR: GLES20.ONE_MINUS_SRC_COLOR;
			case SOURCE_ALPHA: GLES20.SRC_ALPHA;
			case SOURCE_COLOR: GLES20.SRC_COLOR;
			case ZERO: GLES20.ZERO;
			default: GLES20.ONE_MINUS_SRC_ALPHA;
			
		}
		
	}
	
	
	private function __getGLClearMask (clearMask:Context3DClearMask):Int {
		
		return switch (clearMask) {
			
			case ALL: GLES20.COLOR_BUFFER_BIT | GLES20.DEPTH_BUFFER_BIT | GLES20.STENCIL_BUFFER_BIT;
			case COLOR: GLES20.COLOR_BUFFER_BIT;
			case DEPTH: GLES20.DEPTH_BUFFER_BIT;
			case STENCIL: GLES20.STENCIL_BUFFER_BIT;
			default: GLES20.COLOR_BUFFER_BIT;
			
		}
		
	}
	
	
	private function __getGLCompareMode (compareMode:Context3DCompareMode):Int {
		
		return switch (compareMode) {
			
			case ALWAYS: GLES20.ALWAYS;
			case EQUAL: GLES20.EQUAL;
			case GREATER: GLES20.GREATER;
			case GREATER_EQUAL: GLES20.GEQUAL;
			case LESS: GLES20.LESS;
			case LESS_EQUAL: GLES20.LEQUAL; // TODO : wrong value
			case NEVER: GLES20.NEVER;
			case NOT_EQUAL: GLES20.NOTEQUAL;
			default: GLES20.EQUAL;
			
		}
		
	}
	
	
	private function __getGLStencilAction (stencilAction:Context3DStencilAction):Int {
		
		return switch (stencilAction) {
			
			case DECREMENT_SATURATE: GLES20.DECR;
			case DECREMENT_WRAP: GLES20.DECR_WRAP;
			case INCREMENT_SATURATE: GLES20.INCR;
			case INCREMENT_WRAP: GLES20.INCR_WRAP;
			case INVERT: GLES20.INVERT;
			case KEEP: GLES20.KEEP;
			case SET: GLES20.REPLACE;
			case ZERO: GLES20.ZERO;
			default: GLES20.KEEP;
			
		}
		
	}
	
	
	private function __getGLTriangleFace (triangleFace:Context3DTriangleFace):Int {
		
		return switch (triangleFace) {
			
			case BACK: GLES20.FRONT;
			case FRONT: GLES20.BACK;
			case FRONT_AND_BACK: GLES20.FRONT_AND_BACK;
			case NONE: 0;
			default: 0;
			
		}
		
	}
	
	
	private function __setBackBufferViewPort (?x:Int, ?y:Int, ?width:Int, ?height:Int) {
		
		if (x == null) x = Std.int (__scrollRect.x);
		if (y == null) y = Std.int (__scrollRect.y);
		if (width == null) width = Std.int (__scrollRect.width);
		if (height == null) height = Std.int (__scrollRect.height);
		
		__scrollRect.x = x;
		__scrollRect.y = y;
		__scrollRect.width = width;
		__scrollRect.height = height;
		__ogl.width = x + width;
		__ogl.height = y + height;
		
		__updateBackBufferViewPort ();
		
	}
	
	
	private function __setGLSLProgramConstantsFromByteArray (location:GLUniformLocation, data:ByteArray, byteArrayOffset:Int = 0):Void {
		
		data.position = byteArrayOffset;
		gl.uniform4f (location, data.readFloat (), data.readFloat (), data.readFloat (), data.readFloat ());
		
	}
	
	
	private function __setGLSLProgramConstantsFromMatrix (location:GLUniformLocation, matrix:Matrix3D, transposedMatrix:Bool = false):Void {
		
		gl.uniformMatrix4fv (location, !transposedMatrix, new Float32Array (matrix.rawData));
		
	}
	
	
	private function __setGLSLProgramConstantsFromVector4 (location:GLUniformLocation, data:Array<Float>, startIndex:Int = 0):Void {
		
		gl.uniform4f (location, data[startIndex], data[startIndex + 1], data[startIndex + 2], data[startIndex + 3]);
		
	}
	
	
	private function __setGLSLTextureAt (location:GLUniformLocation, texture:TextureBase, textureIndex:Int):Void {
		
		switch (textureIndex) {
			
			case 0 : gl.activeTexture (GLES20.TEXTURE0);
			case 1 : gl.activeTexture (GLES20.TEXTURE1);
			case 2 : gl.activeTexture (GLES20.TEXTURE2);
			case 3 : gl.activeTexture (GLES20.TEXTURE3);
			case 4 : gl.activeTexture (GLES20.TEXTURE4);
			case 5 : gl.activeTexture (GLES20.TEXTURE5);
			case 6 : gl.activeTexture (GLES20.TEXTURE6);
			case 7 : gl.activeTexture (GLES20.TEXTURE7);
			// TODO more?
			default: throw "Does not support texture8 or more";
			
		}
		
		if (texture == null) {
			
			gl.bindTexture (GLES20.TEXTURE_2D, null);
			gl.bindTexture (GLES20.TEXTURE_CUBE_MAP, null);
			return;
			
		}
		
		if (Std.instance (texture, Texture) != null || Std.instance (texture, RectangleTexture) != null) {
			
			gl.bindTexture (GLES20.TEXTURE_2D, texture.__glTexture);
			gl.uniform1i (location, textureIndex);
			
		} else if (Std.instance (texture, CubeTexture) != null) {
			
			gl.bindTexture (GLES20.TEXTURE_CUBE_MAP, texture.__glTexture );
			gl.uniform1i (location, textureIndex);
			
		} else {
			
			throw "Texture of type " + Type.getClassName (Type.getClass (texture)) + " not supported yet";
			
		}
		
		var parameters = __samplerParameters[textureIndex];
		
		if (parameters != null) {
			
			__setTextureParameters (texture, parameters.wrap, parameters.filter, parameters.mipfilter);
			
		} else {
			
			__setTextureParameters (texture, Context3DWrapMode.CLAMP, Context3DTextureFilter.NEAREST, Context3DMipFilter.MIPNONE);
			
		}
		
	}
	
	
	private function __setGLSLVertexBufferAt (location:Int, buffer:VertexBuffer3D, bufferOffset:Int = 0, ?format:Context3DVertexBufferFormat):Void {
		
		if (buffer == null) {
			
			if (location > -1) {
				
				gl.disableVertexAttribArray (location);
				
			}
			
			return;
			
		}
		
		gl.bindBuffer (GLES20.ARRAY_BUFFER, buffer.__glBuffer);
		
		var dimension = 4;
		var type = GLES20.FLOAT;
		var normalized:Bool = false;
		
		if (format == Context3DVertexBufferFormat.BYTES_4) {
			
			dimension = 4;
			type = GLES20.UNSIGNED_BYTE;
			normalized = true;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_1) {
			
			dimension = 1;
			type = GLES20.FLOAT;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_2) {
			
			dimension = 2;
			type = GLES20.FLOAT;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_3) {
			
			dimension = 3;
			type = GLES20.FLOAT;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_4) {
			
			dimension = 4;
			type = GLES20.FLOAT;
			
		} else {
			
			throw "Buffer format " + format + " is not supported";
			
		}
		
		gl.enableVertexAttribArray (location);
		gl.vertexAttribPointer (location, dimension, type, normalized, buffer.__data32PerVertex * 4, bufferOffset * 4);
		
	}
	
	@:access(openfl.display3D.textures.TextureBase)
	private function __setTextureParameters (texture:TextureBase, wrap:Context3DWrapMode, filter:Context3DTextureFilter, mipfilter:Context3DMipFilter):Void {
		
		if (!__anisotropySupportTested) {
			
			#if native
			
			__supportsAnisotropy = (gl.getSupportedExtensions ().indexOf ("GL_EXT_texture_filter_anisotropic") != -1);
			
			if (__supportsAnisotropy) {
				
				// GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT is not currently recongnised in Lime
				// If supported, max anisotropic filtering of 256 is assumed.
				// __maxSupportedAnisotropy = gl.getTexParameter (GLES20.TEXTURE_2D, MAX_TEXTURE_MAX_ANISOTROPY_EXT);
				gl.texParameteri (GLES20.TEXTURE_2D, TEXTURE_MAX_ANISOTROPY_EXT, __maxSupportedAnisotropy);
				
			}
			
			#else
			
			var ext:Dynamic = gl.getExtension ("EXT_texture_filter_anisotropic");
			if (ext == null || Reflect.field( ext, "MAX_TEXTURE_MAX_ANISOTROPY_EXT" ) == null) ext = gl.getExtension ("MOZ_EXT_texture_filter_anisotropic");
			if (ext == null || Reflect.field( ext, "MAX_TEXTURE_MAX_ANISOTROPY_EXT" ) == null) ext = gl.getExtension ("WEBKIT_EXT_texture_filter_anisotropic");
			__supportsAnisotropy = (ext != null);
			
			if (__supportsAnisotropy) {
				
				__maxSupportedAnisotropy = gl.getParameter (ext.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
				gl.texParameteri (GLES20.TEXTURE_2D, TEXTURE_MAX_ANISOTROPY_EXT, __maxSupportedAnisotropy);
				
			}
			
			#end
			
			__anisotropySupportTested = true;
			
		}
		
		if (Std.instance (texture, Texture) != null) {
			
			switch (wrap) {
				
				case Context3DWrapMode.CLAMP:
					
					texture.setWrapMode (GLES20.CLAMP_TO_EDGE, GLES20.CLAMP_TO_EDGE);
				
				case Context3DWrapMode.CLAMP_U_REPEAT_V:
					
					texture.setWrapMode (GLES20.CLAMP_TO_EDGE, GLES20.REPEAT);
				
				case Context3DWrapMode.REPEAT:
					
					texture.setWrapMode (GLES20.REPEAT, GLES20.REPEAT);
				
				case Context3DWrapMode.REPEAT_U_CLAMP_V:
					
					texture.setWrapMode (GLES20.REPEAT, GLES20.CLAMP_TO_EDGE);
				
			}
			
			// Currently using TEXTURE_MAX_ANISOTROPY_EXT instead of gl.TEXTURE_MAX_ANISOTROPY_EXT
			// until it is implemented.
			
			switch (filter) {
				
				case Context3DTextureFilter.LINEAR:
					
					texture.setMagFilter (GLES20.LINEAR);
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.NEAREST:
					
					texture.setMagFilter (GLES20.NEAREST);
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.ANISOTROPIC2X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 2) ? __maxSupportedAnisotropy : 2);
				 
				case Context3DTextureFilter.ANISOTROPIC4X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 4) ? __maxSupportedAnisotropy : 4);
				
				case Context3DTextureFilter.ANISOTROPIC8X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 8) ? __maxSupportedAnisotropy : 8);
				
				case Context3DTextureFilter.ANISOTROPIC16X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 16) ? __maxSupportedAnisotropy : 16);
				
			}
			
			switch (mipfilter) {
				
				case Context3DMipFilter.MIPLINEAR:
					
					texture.setMinFilter (GLES20.LINEAR_MIPMAP_LINEAR);
				
				case Context3DMipFilter.MIPNEAREST:
					
					texture.setMinFilter (GLES20.NEAREST_MIPMAP_NEAREST);
				
				case Context3DMipFilter.MIPNONE:
					
					texture.setMinFilter (filter == Context3DTextureFilter.NEAREST ? GLES20.NEAREST : GLES20.LINEAR);
				
			} 
			
			var tex:Texture = cast texture;
			if (mipfilter != Context3DMipFilter.MIPNONE && !tex.__hasMipMap) {
				
				gl.generateMipmap(GLES20.TEXTURE_2D);
				tex.__hasMipMap = true;
				
			}
			
		} else if (Std.instance (texture, RectangleTexture) != null) {
			
			texture.setWrapMode (GLES20.CLAMP_TO_EDGE, GLES20.CLAMP_TO_EDGE);
			
			switch (filter) {
				
				case Context3DTextureFilter.LINEAR:
					
					texture.setMagFilter (GLES20.LINEAR);
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.NEAREST:
					
					texture.setMagFilter (GLES20.NEAREST);
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.ANISOTROPIC2X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 2) ? __maxSupportedAnisotropy : 2);
				
				case Context3DTextureFilter.ANISOTROPIC4X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 4) ? __maxSupportedAnisotropy : 4);
				
				case Context3DTextureFilter.ANISOTROPIC8X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 8) ? __maxSupportedAnisotropy : 8);
				
				case Context3DTextureFilter.ANISOTROPIC16X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 16) ? __maxSupportedAnisotropy : 16);
				
			}
			
			texture.setMinFilter (filter == Context3DTextureFilter.NEAREST ? GLES20.NEAREST : GLES20.LINEAR);
			
		} else if (Std.instance (texture, CubeTexture) != null) {
			
			switch (wrap) {
				
				case Context3DWrapMode.CLAMP:
					
					texture.setWrapMode (GLES20.CLAMP_TO_EDGE, GLES20.CLAMP_TO_EDGE);
					
				case Context3DWrapMode.CLAMP_U_REPEAT_V:
					
					texture.setWrapMode (GLES20.CLAMP_TO_EDGE, GLES20.REPEAT);
				
				case Context3DWrapMode.REPEAT:
					
					texture.setWrapMode (GLES20.REPEAT, GLES20.REPEAT);
					
				case Context3DWrapMode.REPEAT_U_CLAMP_V:
					
					texture.setWrapMode (GLES20.REPEAT, GLES20.CLAMP_TO_EDGE);
				
			}
			
			switch (filter) {
				
				case Context3DTextureFilter.LINEAR:
					
					texture.setMagFilter (GLES20.LINEAR);
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.NEAREST:
					
					texture.setMagFilter (GLES20.NEAREST);
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.ANISOTROPIC2X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 2) ? __maxSupportedAnisotropy : 2);
				 
				case Context3DTextureFilter.ANISOTROPIC4X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 4) ? __maxSupportedAnisotropy : 4);
				
				case Context3DTextureFilter.ANISOTROPIC8X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 8) ? __maxSupportedAnisotropy : 8);
				
				case Context3DTextureFilter.ANISOTROPIC16X:
					
					if (__supportsAnisotropy)
						texture.setMaxAnisotrophy ((__maxSupportedAnisotropy < 16) ? __maxSupportedAnisotropy : 16);
				
			}
			
			switch (mipfilter) {
				
				case Context3DMipFilter.MIPLINEAR:
					
					texture.setMinFilter (GLES20.LINEAR_MIPMAP_LINEAR);
				
				case Context3DMipFilter.MIPNEAREST:
					
					texture.setMinFilter (GLES20.NEAREST_MIPMAP_NEAREST);
				
				case Context3DMipFilter.MIPNONE:
					
					texture.setMinFilter (filter == Context3DTextureFilter.NEAREST ? GLES20.NEAREST : GLES20.LINEAR);
				
			}
			
			var cubetex:CubeTexture = cast texture;
			if (mipfilter != Context3DMipFilter.MIPNONE && !cubetex.__hasMipMap) {
				
				gl.generateMipmap (GLES20.TEXTURE_CUBE_MAP);
				cubetex.__hasMipMap = true;
				
			}
			
		} else {
			
			throw "Texture of type " + Type.getClassName (Type.getClass (texture)) + " not supported yet";
			
		}
		
	}
	
	
	private function __updateBackBufferViewPort ():Void {
		
		if (!__renderToTexture) {
			
			gl.viewport (Std.int (__scrollRect.x), Std.int (__scrollRect.y), Std.int (__scrollRect.width), Std.int (__scrollRect.height));
			
		}
		
	}
	
	@:noCompletion public function __moveStage3D (stage3D:Stage3D) {
		
		__setBackBufferViewPort (Std.int (stage3D.x), Std.int (stage3D.y), null, null);
		
	}
	
	
	private function __updateBlendStatus ():Void {
		
		//TODO do the same for other states ?
		
		if (__blendEnabled) {
			
			gl.enable (GLES20.BLEND);
			gl.blendEquation (GLES20.FUNC_ADD);
			gl.blendFunc (__getGLBlend (__blendSourceFactor), __getGLBlend (__blendDestinationFactor));
			
		} else {
			
			gl.disable (GLES20.BLEND);
			
		}
		
	}
	
	private function __hasGLExtension (name:String):Bool {
		
		return (gl.getSupportedExtensions ().indexOf (name) != -1);
		
	}
	
	@:noCompletion private function get_backBufferWidth():Int {
		
		return Std.int(__scrollRect.width);
		
	}
	
	@:noCompletion private function get_backBufferHeight():Int {
		
		return Std.int(__scrollRect.height);
		
	}
	
	@:noCompletion private inline function get_gl ():GLRenderContext {
		
		return __ogl.gl;
		
	}
	
	private function __updateDepthAndStencilState ():Void {
		
		// used to enable masking
		var depthAndStencil = __renderToTexture ? __rttDepthAndStencil : __backBufferDepthAndStencil;
		
		if (depthAndStencil) {
			
			// TODO check whether this is kept across frame
			if (Application.current.window.config.depthBuffer) {
				
				gl.enable (GLES20.DEPTH_TEST);
				
			}
			
			if (Application.current.window.config.stencilBuffer) {
				
				gl.enable (GLES20.STENCIL_TEST);
				
			}
			
		} else {
			
			gl.disable (GLES20.DEPTH_TEST);
			gl.disable (GLES20.STENCIL_TEST);
			
		}
		
	}
	
	
	private function __updateScissorRectangle() {
		
		if (__scissorRectangle == null) {
			
			return;
			
		}
		
		//var width:Int = renderToTexture ? rttWidth : scrollRect.width;
		var height:Int = __renderToTexture ? __rttHeight : Std.int (__scrollRect.height);
		gl.scissor (Std.int (__scissorRectangle.x),
			Std.int (height - Std.int(__scissorRectangle.y) - Std.int (__scissorRectangle.height)),
			Std.int (__scissorRectangle.width),
			Std.int (__scissorRectangle.height)
		);
		
	}
	
	
}


@:noCompletion @:dox(hide) private class SamplerState {
	
	
	public var wrap:Context3DWrapMode;
	public var filter:Context3DTextureFilter;
	public var mipfilter:Context3DMipFilter;
	
	
	public function new ():Void {
		
		
		
	}
	
	
}
package openfl.display3D; #if !flash


import lime.app.Application;
import lime.app.Config;
import lime.ui.Window;
import openfl.display.BitmapData;
import openfl.display.OpenGLView;
import openfl.display.Stage3D;
import openfl.display3D.textures.CubeTexture;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.Texture;
import openfl.display3D.textures.TextureBase;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.geom.Matrix3D;
import openfl.geom.Rectangle;
import openfl.gl.GL;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLUniformLocation;
import openfl.gl.GLProgram;
import openfl.gl.GLRenderbuffer;
import openfl.utils.ByteArray;
import openfl.utils.Float32Array;
import openfl.Lib;


@:final class Context3D {
	
	
	private static var TEXTURE_MAX_ANISOTROPY_EXT = 0x84FE;
	private static var MAX_SAMPLERS = 8;
	private static var MAX_TEXTURE_MAX_ANISOTROPY_EXT = 0x84FF;
	
	private static var anisotropySupportTested:Bool = false;
	private static var supportsAnisotropy:Bool = false;
	private static var maxSupportedAnisotropy:UInt = 256;
	
	public var driverInfo (default, null):String; // TODO
	public var enableErrorChecking:Bool; // TODO (use GL.getError() and GL.validateProgram(program))
	
	private var blendDestinationFactor:Int; // to mimic Stage3d behavior of keeping blending across frames:
	private var blendEnabled:Bool; // to mimic Stage3d behavior of keeping blending across frames:
	private var blendSourceFactor:Int; // to mimic Stage3d behavior of keeping blending across frames:
	private var currentProgram:Program3D;
	private var disposed:Bool;
	private var renderToTexture : Bool;
	private var drawing:Bool; // to mimic Stage3d behavior of not allowing calls to drawTriangles between present and clear
	private var framebuffer:GLFramebuffer;
	private var indexBuffersCreated:Array<IndexBuffer3D>; // to keep track of stuff to dispose when calling dispose
	private var ogl:OpenGLView;
	private var programsCreated:Array<Program3D>; // to keep track of stuff to dispose when calling dispose
	private var renderbuffer:GLRenderbuffer;
	private var samplerParameters:Array<SamplerState>; //TODO : use Tupple3
	private var scissorRectangle:Rectangle;
	private var rttWidth:Int;
	private var rttHeight:Int;
	private var scrollRect:Rectangle;
	private var stencilbuffer:GLRenderbuffer;
	private var stencilCompareMode:Context3DCompareMode;
	private var stencilRef:Int;
	private var stencilReadMask:Int;
	private var texturesCreated:Array<TextureBase>; // to keep track of stuff to dispose when calling dispose
	private var vertexBuffersCreated:Array<VertexBuffer3D>; // to keep track of stuff to dispose when calling dispose
	private var _yFlip:Float;
	private var backBufferDepthAndStencil:Bool;
	private var rttDepthAndStencil:Bool;
	private var window:Window;
	
	public function new (stage3D:Stage3D) {
		
		disposed = false;
		renderToTexture = false;
		
		_yFlip = 1;
		
		stencilRef = stencilReadMask = 0;
		
		vertexBuffersCreated = new Array ();
		indexBuffersCreated = new Array ();
		programsCreated = new Array ();
		texturesCreated = new Array (); 
		samplerParameters = new Array<SamplerState> ();
		
		for (i in 0...MAX_SAMPLERS) {
			
			samplerParameters[i] = new SamplerState ();
			samplerParameters[i].wrap = Context3DWrapMode.CLAMP;
			samplerParameters[i].filter = Context3DTextureFilter.LINEAR;
			samplerParameters[i].mipfilter =Context3DMipFilter.MIPNONE;
			
		}
		
		var stage = Lib.current.stage;
		window = Application.current.window;
		
		ogl = new OpenGLView (window.config.depthBuffer, window.config.stencilBuffer);
		var width:Float = stage.stageWidth;
		var height:Float = stage.stageHeight;
		ogl.scrollRect = new Rectangle (0, 0, stage3D.x + width , stage3D.y + height);
		scrollRect = new Rectangle (stage3D.x, stage3D.y, width, height);
		
		stage.addChildAt(ogl, 0);
		
		#if html5
		GL.pixelStorei (GL.UNPACK_FLIP_Y_WEBGL, 1);
		GL.pixelStorei (GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
		#end
		
		backBufferDepthAndStencil = false;
		rttDepthAndStencil = false;
		
		stencilCompareMode = GL.ALWAYS;
		
	}
	
	
	public function clear (red:Float = 0, green:Float = 0, blue:Float = 0, alpha:Float = 1, depth:Float = 1, stencil:Int = 0, mask:Int = Context3DClearMask.ALL):Void {
		
		if (!drawing) {
			
		 	__updateBlendStatus ();
		 	drawing = true;
		 	
		}
		
		if (scissorRectangle != null)
			GL.disable(GL.SCISSOR_TEST);
		GL.clearColor (red, green, blue, alpha);
		GL.clearDepth (depth);
		GL.clearStencil (stencil);
		
		GL.clear (mask);
		
		if (scissorRectangle != null)
			GL.enable(GL.SCISSOR_TEST);
	}
	
	
	public function configureBackBuffer (width:Int, height:Int, antiAlias:Int, enableDepthAndStencil:Bool = true):Void {
		
		backBufferDepthAndStencil = enableDepthAndStencil;
		updateDepthAndStencilState();
		
		// TODO use antiAlias parameter
		setBackBufferViewPort (null, null, width, height);
		updateScissorRectangle ();
		
	}
	
	private function setBackBufferViewPort (?x:Int, ?y:Int, ?width:Int, ?height:Int) {
		
		if (x == null) x = Std.int (scrollRect.x);
		if (y == null) y = Std.int (scrollRect.y);
		if (width == null) width = Std.int (scrollRect.width);
		if (height == null) height = Std.int (scrollRect.height);
		
		scrollRect.x = x;
		scrollRect.y = y;
		scrollRect.width = width;
		scrollRect.height = height;
		ogl.width = x + width;
		ogl.height = y + height;
		
		updateBackBufferViewPort ();
		
	}
	
	private function updateBackBufferViewPort () {
		
		if (!renderToTexture) {
			
			GL.viewport (Std.int (scrollRect.x), Std.int (scrollRect.y), Std.int (scrollRect.width), Std.int (scrollRect.height));
			
		}
		
	}
	
	@:noCompletion public function __moveStage3D (stage3D:Stage3D) {
		
		setBackBufferViewPort (Std.int (stage3D.x), Std.int (stage3D.y), null, null);
		
	}
	
	private function updateDepthAndStencilState() {
		
		var depthAndStencil:Bool = renderToTexture ? rttDepthAndStencil : backBufferDepthAndStencil;
		
		if (depthAndStencil) {
			
			// TODO check whether this is kept across frame
			if (window.config.depthBuffer)
				GL.enable (GL.DEPTH_TEST);
			if (window.config.stencilBuffer)
				GL.enable (GL.STENCIL_TEST);
			
		} else {
			
			GL.disable (GL.DEPTH_TEST);
			GL.disable (GL.STENCIL_TEST);
			
		}
		
	}
	
	public function createCubeTexture (size:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int = 0):CubeTexture {
		
		var texture = new CubeTexture (this, GL.createTexture (), size); // TODO use format, optimizeForRenderToTexture and streamingLevels?
		texturesCreated.push (texture);
		return texture;
		
	}
	
	
	public function createIndexBuffer (numIndices:Int, bufferUsage:Context3DBufferUsage = null):IndexBuffer3D {
		
		if (bufferUsage == null) bufferUsage = Context3DBufferUsage.STATIC_DRAW;
		var indexBuffer = new IndexBuffer3D (this, GL.createBuffer (), numIndices, bufferUsage == Context3DBufferUsage.STATIC_DRAW ? GL.STATIC_DRAW : GL.DYNAMIC_DRAW);
		indexBuffersCreated.push (indexBuffer);
		return indexBuffer;
		
	}
	
	
	public function createProgram ():Program3D {
		
		var program = new Program3D (this, GL.createProgram ());
		programsCreated.push (program);
		return program;
		
	}
	
	
	public function createRectangleTexture (width:Int, height:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool):RectangleTexture {
		
		var glFormat = getGLTextureFormat(format);
		var texture = new RectangleTexture (this, GL.createTexture (), optimizeForRenderToTexture, width, height, glFormat.internalFormat, glFormat.format, glFormat.type); // TODO use format, optimizeForRenderToTexture and streamingLevels?
		texturesCreated.push (texture);
		return texture;
		
	}
	
	
	public function createTexture (width:Int, height:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int = 0):Texture {
		
		var glFormat = getGLTextureFormat(format);
		var texture = new Texture (this, GL.createTexture (), optimizeForRenderToTexture, width, height, glFormat.internalFormat, glFormat.format, glFormat.type); // TODO use format, optimizeForRenderToTexture and streamingLevels?
		texturesCreated.push (texture);
		return texture;
		
	}

	
	private function getGLTextureFormat(format:Context3DTextureFormat):{internalFormat:Int, format:Int, type:Int}
	{
		
		switch (format)
		{
			
			case Context3DTextureFormat.ALPHA:
				return { internalFormat:GL.ALPHA, format:GL.ALPHA, type:GL.UNSIGNED_BYTE };
			case Context3DTextureFormat.BGRA:
				#if html5
				return { internalFormat:GL.RGBA, format:GL.RGBA, type:GL.UNSIGNED_BYTE };
				#else
				return { internalFormat:GL.BGRA_EXT, format:GL.BGRA_EXT, type:GL.UNSIGNED_BYTE };
				#end
			default:
				return null;
			
		}
		
	}

	
	public function createVertexBuffer (numVertices:Int, data32PerVertex:Int, bufferUsage:Context3DBufferUsage = null):VertexBuffer3D {
		
		if (bufferUsage == null) bufferUsage = STATIC_DRAW;
		var vertexBuffer = new VertexBuffer3D (this, GL.createBuffer (), numVertices, data32PerVertex, bufferUsage == Context3DBufferUsage.STATIC_DRAW ? GL.STATIC_DRAW : GL.DYNAMIC_DRAW);
		vertexBuffersCreated.push (vertexBuffer);
		return vertexBuffer;
		
	}
	
	
	@:noCompletion public function __deleteTexture (texture:TextureBase):Void
	{
		
		if (texture.glTexture == null)
			return;
		texturesCreated.remove (texture);
		GL.deleteTexture (texture.glTexture);
		texture.glTexture = null;
		
	}
	
	@:noCompletion public function __deleteVertexBuffer (buffer:VertexBuffer3D):Void
	{
		
		if (buffer.glBuffer == null)
			return;
		vertexBuffersCreated.remove (buffer);
		GL.deleteBuffer (buffer.glBuffer);
		buffer.glBuffer = null;
		
	}
	
	@:noCompletion public function __deleteIndexBuffer (buffer:IndexBuffer3D):Void
	{
		
		if (buffer.glBuffer == null)
			return;
		indexBuffersCreated.remove (buffer);
		GL.deleteBuffer (buffer.glBuffer);
		buffer.glBuffer = null;
		
	}
	
	@:noCompletion public function __deleteProgram (program:Program3D):Void
	{
		
		if (program.glProgram == null)
			return;
		programsCreated.remove (program);
		GL.deleteProgram (program.glProgram);
		program.glProgram = null;
		
	}
	
	
	public function dispose ():Void {
		
		// TODO simulate context loss by recreating a context3d and dispatch event on Stage3d(see Adobe Doc)
		// TODO add error on other method when context3d is disposed
		
		for (vertexBuffer in vertexBuffersCreated) {
			
			vertexBuffer.dispose ();
			
		}
		
		vertexBuffersCreated = null;
		
		for (indexBuffer in indexBuffersCreated) {
			
			indexBuffer.dispose ();
			
		}
		
		indexBuffersCreated = null;
		
		for (program in programsCreated) {
			
			program.dispose ();
			
		}
		
		programsCreated = null;
 		
		samplerParameters = null;
		
		for (texture in texturesCreated) {
			
			texture.dispose ();
			
		}
		
		texturesCreated = null;
		
		if (framebuffer != null) {
			
			GL.deleteFramebuffer (framebuffer);
			framebuffer = null;
			
		}
		
		if (renderbuffer != null) {
			
			GL.deleteRenderbuffer (renderbuffer);
			renderbuffer = null;
			
		}
		
		disposed = true;
		
	}
	
	
	public function drawToBitmapData (destination:BitmapData):Void {
		
		// TODO
		
	}
	
	
	public function drawTriangles (indexBuffer:IndexBuffer3D, firstIndex:Int = 0, numTriangles:Int = -1):Void {
		
		var location:GLUniformLocation = currentProgram.yFlipLoc();
		GL.uniform1f (location, this._yFlip);

		if (!drawing && !renderToTexture) {
			
			throw new Error ("Need to clear before drawing if the buffer has not been cleared since the last present() call.");
			
		}
		
		var numIndices;
		
		if (numTriangles == -1) {
			
			numIndices = indexBuffer.numIndices;
			
		} else {
			
			numIndices = numTriangles * 3;
			
		}
		
		var byteOffset = firstIndex * 2;
		
		GL.bindBuffer (GL.ELEMENT_ARRAY_BUFFER, indexBuffer.glBuffer);
		GL.drawElements (GL.TRIANGLES, numIndices, GL.UNSIGNED_SHORT, byteOffset);
		
	}
	
	
	public function present ():Void {
		
		drawing = false;
		GL.useProgram (null);
		
		GL.bindBuffer (GL.ARRAY_BUFFER, null);
		GL.disable (GL.CULL_FACE);
		
		if (framebuffer != null) {

			GL.bindFramebuffer (GL.FRAMEBUFFER, null);

		}
		
		if (renderbuffer != null) {

			GL.bindRenderbuffer (GL.RENDERBUFFER, null);

		}

	}
	
	
	public function removeRenderMethod (func:Event -> Void):Void {
		
		ogl.render = null;
		
	}
	
	
	public function setBlendFactors (sourceFactor:Int, destinationFactor:Int):Void {
		
		// TODO: Type as Context3DBlendFactor instead of Int?
		
		blendEnabled = true;
		blendSourceFactor = sourceFactor;
		blendDestinationFactor = destinationFactor;
		
		__updateBlendStatus ();
		
	}
	
	
	public function setColorMask (red:Bool, green:Bool, blue:Bool, alpha:Bool):Void {
		
		GL.colorMask (red, green, blue, alpha);
		
	}
	
	
	
	public function setCulling (triangleFaceToCull:Int):Void {
		
		// TODO: Type as Context3DTriangleFace instead of Int?
		
		if (triangleFaceToCull == Context3DTriangleFace.NONE) {
			
			GL.disable (GL.CULL_FACE);
			
		} else {
			
			GL.enable (GL.CULL_FACE);
			
			switch (triangleFaceToCull) {
				
				case Context3DTriangleFace.FRONT: GL.cullFace (GL.BACK);
				case Context3DTriangleFace.BACK: GL.cullFace (GL.FRONT);
				case Context3DTriangleFace.FRONT_AND_BACK: GL.cullFace (GL.FRONT_AND_BACK);
				default: throw "Unknown Context3DTriangleFace type.";
				
			}
			
		}
		
		switch (triangleFaceToCull) {
			
			case Context3DTriangleFace.FRONT:
				
				this._yFlip = -1;
			
			case Context3DTriangleFace.BACK:
				
				this._yFlip = 1; // checked
			
			case Context3DTriangleFace.FRONT_AND_BACK:
				
				this._yFlip = 1;
			
			case Context3DTriangleFace.NONE:
				
				this._yFlip = 1; // checked
			
			default:
				
				throw "Unknown culling mode " + triangleFaceToCull + ".";
 			
 		}
	}
	
	
	public function setDepthTest (depthMask:Bool, passCompareMode:Int):Void {
		
		// TODO: Type as Context3DCompareMode instead of Int?
		
		GL.depthFunc (passCompareMode);
		GL.depthMask (depthMask);
		
	}
	
	
	public function setGLSLProgramConstantsFromByteArray (location:GLUniformLocation, data:ByteArray, byteArrayOffset:Int = 0):Void {
		
		data.position = byteArrayOffset;
		GL.uniform4f (location, data.readFloat (), data.readFloat (), data.readFloat (), data.readFloat ());
		
	}
	
	
	public function setGLSLProgramConstantsFromMatrix (location:GLUniformLocation, matrix:Matrix3D, transposedMatrix:Bool = false):Void {
		
		GL.uniformMatrix4fv (location, !transposedMatrix, new Float32Array (matrix.rawData));
		
	}
	
	
	public function setGLSLProgramConstantsFromVector4 (location:GLUniformLocation, data:Array<Float>, startIndex:Int = 0):Void {
		
		GL.uniform4f (location, data[startIndex], data[startIndex + 1], data[startIndex + 2], data[startIndex + 3]);
		
	}
	
	
	public function setGLSLTextureAt (location:GLUniformLocation, texture:TextureBase, textureIndex:Int):Void {
		
		switch (textureIndex) {
			
			case 0 : GL.activeTexture (GL.TEXTURE0);
			case 1 : GL.activeTexture (GL.TEXTURE1);
			case 2 : GL.activeTexture (GL.TEXTURE2);
			case 3 : GL.activeTexture (GL.TEXTURE3);
			case 4 : GL.activeTexture (GL.TEXTURE4);
			case 5 : GL.activeTexture (GL.TEXTURE5);
			case 6 : GL.activeTexture (GL.TEXTURE6);
			case 7 : GL.activeTexture (GL.TEXTURE7);
			// TODO more?
			default: throw "Does not support texture8 or more";
			
		}
		
		if (texture == null) {
			
			GL.bindTexture (GL.TEXTURE_2D, null);
			GL.bindTexture (GL.TEXTURE_CUBE_MAP, null);
			return;
			
		}
		
		if (Std.is (texture, Texture)) {
			
			GL.bindTexture (GL.TEXTURE_2D, cast (texture, Texture).glTexture);
			GL.uniform1i (location, textureIndex);
			
		} else if (Std.is (texture, RectangleTexture)) {
			
			GL.bindTexture (GL.TEXTURE_2D, cast (texture, RectangleTexture).glTexture);
			GL.uniform1i (location, textureIndex);
			
		} else if (Std.is (texture, CubeTexture) ) {
			
			GL.bindTexture (GL.TEXTURE_CUBE_MAP, cast (texture, CubeTexture).glTexture );
			GL.uniform1i (location, textureIndex);
			
		} else {
			
			throw "Texture of type " + Type.getClassName (Type.getClass (texture)) + " not supported yet";
			
		}
		
		var parameters:SamplerState = samplerParameters[textureIndex];
		
		if (parameters != null) {
			
			setTextureParameters (texture, parameters.wrap, parameters.filter, parameters.mipfilter);
			
		} else {
			
			setTextureParameters (texture, Context3DWrapMode.CLAMP, Context3DTextureFilter.NEAREST, Context3DMipFilter.MIPNONE);
			
		}
		
	}
	
	
	public function setGLSLVertexBufferAt (location:Int, buffer:VertexBuffer3D, bufferOffset:Int = 0, ?format:Context3DVertexBufferFormat):Void {
		
		if (buffer == null) {
			
			if (location > -1) {
				
				GL.disableVertexAttribArray (location);
				
			}
			
			return;
			
		}
		
		GL.bindBuffer (GL.ARRAY_BUFFER, buffer.glBuffer);
		
		var dimension = 4;
		var type = GL.FLOAT;
		var numBytes = 4;
		
		if (format == Context3DVertexBufferFormat.BYTES_4) {
			
			dimension = 4;
			type = GL.FLOAT;
			numBytes = 4;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_1) {
			
			dimension = 1;
			type = GL.FLOAT;
			numBytes = 4;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_2) {
			
			dimension = 2;
			type = GL.FLOAT;
			numBytes = 4;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_3) {
			
			dimension = 3;
			type = GL.FLOAT;
			numBytes = 4;
			
		} else if (format == Context3DVertexBufferFormat.FLOAT_4) {
			
			dimension = 4;
			type = GL.FLOAT;
			numBytes = 4;
			
		} else {
			
			throw "Buffer format " + format + " is not supported";
			
		}
		
		GL.enableVertexAttribArray (location);
		GL.vertexAttribPointer (location, dimension, type, false, buffer.data32PerVertex * numBytes, bufferOffset * numBytes);
		
	}
	
	
	public function setProgram (program3D:Program3D):Void {
		
		var glProgram:GLProgram = null;
		
		if (program3D != null) {
			
			glProgram = program3D.glProgram;
			
		}

		GL.useProgram (glProgram);
		currentProgram = program3D;
		//TODO reset bound textures, buffers... ?
		// Or maybe we should have arrays and map for each program so we can switch them while keeping the bounded texture and variable?
		
	}
	
	
	public function setProgramConstantsFromByteArray (programType:Context3DProgramType, firstRegister:Int, numRegisters:Int, data:ByteArray, byteArrayOffset:Int):Void {
		
		data.position = byteArrayOffset;
		
		for (i in 0...numRegisters) {
			
			var location:GLUniformLocation = programType == Context3DProgramType.VERTEX ? currentProgram.vsUniformLocationFromAgal(firstRegister + i) : currentProgram.fsUniformLocationFromAgal(firstRegister + i);
			setGLSLProgramConstantsFromByteArray(location, data);
			
		}
		
	}
	
	
	public function setProgramConstantsFromMatrix (programType:Context3DProgramType, firstRegister:Int, matrix:Matrix3D, transposedMatrix:Bool = false):Void {
		
		// var locationName = __getUniformLocationNameFromAgalRegisterIndex (programType, firstRegister);
		// setProgramConstantsFromVector (programType, firstRegister, matrix.rawData, 16);
		
		var d = matrix.rawData;
		if (transposedMatrix) {
			this.setProgramConstantsFromVector(programType, firstRegister, [ d[0], d[4], d[8], d[12] ], 1);  
			this.setProgramConstantsFromVector(programType, firstRegister + 1, [ d[1], d[5], d[9], d[13] ], 1);
			this.setProgramConstantsFromVector(programType, firstRegister + 2, [ d[2], d[6], d[10], d[14] ], 1);
			this.setProgramConstantsFromVector(programType, firstRegister + 3, [ d[3], d[7], d[11], d[15] ], 1);
		} else {
			this.setProgramConstantsFromVector(programType, firstRegister, [ d[0], d[1], d[2], d[3] ], 1);
			this.setProgramConstantsFromVector(programType, firstRegister + 1, [ d[4], d[5], d[6], d[7] ], 1);
			this.setProgramConstantsFromVector(programType, firstRegister + 2, [ d[8], d[9], d[10], d[11] ], 1);
			this.setProgramConstantsFromVector(programType, firstRegister + 3, [ d[12], d[13], d[14], d[15] ], 1);
		}

	}
	
	
	public function setProgramConstantsFromVector (programType:Context3DProgramType, firstRegister:Int, data:Array<Float>, numRegisters:Int = 1):Void {
		
		for (i in 0...numRegisters) {
			
			var currentIndex = i * 4;
			var location:GLUniformLocation = programType == Context3DProgramType.VERTEX ? currentProgram.vsUniformLocationFromAgal(firstRegister + i) : currentProgram.fsUniformLocationFromAgal(firstRegister + i);
			setGLSLProgramConstantsFromVector4(location, data, currentIndex);
			
		}
		
	}
	
	
	public function setRenderMethod (func:Event -> Void):Void {
		
		// TODO: Conform to API?
		
		ogl.render = function (rect:Rectangle) func (null);
		
	}
	
	
	public function setRenderToBackBuffer ():Void {

		if (framebuffer != null) {

			GL.bindFramebuffer (GL.FRAMEBUFFER, null);

		}
		
		if (renderbuffer != null) {

			GL.bindRenderbuffer (GL.RENDERBUFFER, null);

		}
		
		renderToTexture = false;
		updateBackBufferViewPort ();
		updateScissorRectangle();
		updateDepthAndStencilState();
	}
	
	
	public function setRenderToTexture (texture:TextureBase, enableDepthAndStencil:Bool = false, antiAlias:Int = 0, surfaceSelector:Int = 0):Void {
		
		// TODO : currently does not work (framebufferStatus always return zero)
		
		if (framebuffer == null) {
			
			framebuffer = GL.createFramebuffer ();
			
		}
		
		GL.bindFramebuffer (GL.FRAMEBUFFER, framebuffer);
		
		if (renderbuffer == null && enableDepthAndStencil) {
			
			renderbuffer = GL.createRenderbuffer ();
			
		}
		
		GL.bindRenderbuffer (GL.RENDERBUFFER, renderbuffer);
		#if (ios || tvos)
		if (enableDepthAndStencil) GL.renderbufferStorage (GL.RENDERBUFFER, 0x88F0, texture.width, texture.height);
		#else
		if (enableDepthAndStencil) GL.renderbufferStorage (GL.RENDERBUFFER, GL.DEPTH_STENCIL, texture.width, texture.height);
		#end
		GL.framebufferTexture2D (GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture.glTexture, 0);

		if (enableDepthAndStencil)
		{
			
			GL.framebufferRenderbuffer (GL.FRAMEBUFFER, GL.DEPTH_STENCIL_ATTACHMENT, GL.RENDERBUFFER, renderbuffer);
			
		}
		
		GL.viewport (0, 0, texture.width, texture.height);
		renderToTexture = true;
		rttDepthAndStencil = enableDepthAndStencil;
		rttWidth = texture.width;
		rttHeight = texture.height;
		updateScissorRectangle();
		updateDepthAndStencilState();
	}
	
	
	public function setSamplerStateAt (sampler:Int, wrap:Context3DWrapMode, filter:Context3DTextureFilter, mipfilter:Context3DMipFilter):Void {
		
		//TODO for flash < 11.6 : patch the AGAL (using specific opcodes) and rebuild the program? 
		
		if (0 <= sampler && sampler <  MAX_SAMPLERS) {
			
			samplerParameters[sampler].wrap = wrap;
			samplerParameters[sampler].filter = filter;
			samplerParameters[sampler].mipfilter = mipfilter;
			
		} else {
			
			throw "Sampler is out of bounds.";
			
		}
		
	}
	
	public function setScissorRectangle(rectangle:Rectangle):Void 
	{
		
		scissorRectangle = rectangle;
		// TODO test it
		
		if (rectangle == null) {
			
			GL.disable (GL.SCISSOR_TEST);
			return;
			
		}
		
		GL.enable (GL.SCISSOR_TEST);
		updateScissorRectangle ();
		
	}
	
	private function updateScissorRectangle()
	{
		
		if (scissorRectangle == null)
			return;
		
		//var width:Int = renderToTexture ? rttWidth : scrollRect.width;
		var height:Int = renderToTexture ? rttHeight : Std.int(scrollRect.height);
		GL.scissor (Std.int (scissorRectangle.x),
			Std.int (height - Std.int(scissorRectangle.y) - Std.int(scissorRectangle.height)),
			Std.int (scissorRectangle.width),
			Std.int (scissorRectangle.height)
		);
		
	}
	
	public function setStencilActions (?triangleFace:Context3DTriangleFace, ?compareMode:Context3DCompareMode, ?actionOnBothPass:Context3DStencilAction, ?actionOnDepthFail:Context3DStencilAction, ?actionOnDepthPassStencilFail:Context3DStencilAction):Void {
		
		if (triangleFace == null) triangleFace = Context3DTriangleFace.FRONT_AND_BACK;
		if (compareMode == null) compareMode = Context3DCompareMode.ALWAYS;
		if (actionOnBothPass == null) actionOnBothPass = Context3DStencilAction.KEEP;
		if (actionOnDepthFail == null) actionOnDepthFail = Context3DStencilAction.KEEP;
		if (actionOnDepthPassStencilFail == null) actionOnDepthPassStencilFail = Context3DStencilAction.KEEP;
		
		this.stencilCompareMode = compareMode;
		GL.stencilOp (actionOnDepthFail, actionOnDepthPassStencilFail, actionOnBothPass);
		GL.stencilFunc (stencilCompareMode, stencilRef, stencilReadMask);
		
	}
	
	
	public function setStencilReferenceValue (referenceValue:Int, readMask:Int = 0xFF, writeMask:Int = 0xFF):Void {
		
		stencilReadMask = readMask;
		stencilRef = referenceValue;
		
		GL.stencilFunc (stencilCompareMode, stencilRef, stencilReadMask);
		GL.stencilMask (writeMask);
		
	}
	
	
	public function setTextureAt (sampler:Int, texture:TextureBase):Void {
		
		var location = currentProgram.fsampUniformLocationFromAgal(sampler);
		setGLSLTextureAt (location, texture, sampler);
		
	}
	
	@:access(openfl.display3D.textures.TextureBase)
	private function setTextureParameters (texture:TextureBase, wrap:Context3DWrapMode, filter:Context3DTextureFilter, mipfilter:Context3DMipFilter):Void {
		
		if (!anisotropySupportTested) {
			
			#if !html5
			
			supportsAnisotropy = (GL.getSupportedExtensions ().indexOf ("GL_EXT_texture_filter_anisotropic") != -1);
			
			if (supportsAnisotropy) {
				// GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT is not currently recongnised in Lime
				// If supported, max anisotropic filtering of 256 is assumed.
				// maxSupportedAnisotropy = GL.getTexParameter (GL.TEXTURE_2D, MAX_TEXTURE_MAX_ANISOTROPY_EXT);
				GL.texParameteri (GL.TEXTURE_2D, TEXTURE_MAX_ANISOTROPY_EXT, maxSupportedAnisotropy);
			}

			#else

			var ext:Dynamic = GL.getExtension ("EXT_texture_filter_anisotropic");
			if (ext == null || Reflect.field( ext, "MAX_TEXTURE_MAX_ANISOTROPY_EXT" ) == null) ext = GL.getExtension ("MOZ_EXT_texture_filter_anisotropic");
			if (ext == null || Reflect.field( ext, "MAX_TEXTURE_MAX_ANISOTROPY_EXT" ) == null) ext = GL.getExtension ("WEBKIT_EXT_texture_filter_anisotropic");
			supportsAnisotropy = (ext != null);
			
			if (supportsAnisotropy) {
				maxSupportedAnisotropy = GL.getParameter (ext.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
				GL.texParameteri (GL.TEXTURE_2D, TEXTURE_MAX_ANISOTROPY_EXT, maxSupportedAnisotropy);
			}
			
			#end
			
			anisotropySupportTested = true;
						
		}
		
		if (Std.is (texture, Texture)) {
			
			switch (wrap) {
				
				case Context3DWrapMode.CLAMP:
					
					texture.setWrapMode (GL.CLAMP_TO_EDGE);
				
				case Context3DWrapMode.REPEAT:
					
					texture.setWrapMode (GL.REPEAT);
				
			}
			
			// Currently using TEXTURE_MAX_ANISOTROPY_EXT instead of GL.TEXTURE_MAX_ANISOTROPY_EXT
			// until it is implemented.
			
			switch (filter) {
				
				case Context3DTextureFilter.LINEAR:
					
					texture.setMagFilter (GL.LINEAR);
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.NEAREST:
					
					texture.setMagFilter (GL.NEAREST);
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.ANISOTROPIC2X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 2) ? maxSupportedAnisotropy : 2);
				 
				case Context3DTextureFilter.ANISOTROPIC4X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 4) ? maxSupportedAnisotropy : 4);
				
				case Context3DTextureFilter.ANISOTROPIC8X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 8) ? maxSupportedAnisotropy : 8);
				
				case Context3DTextureFilter.ANISOTROPIC16X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 16) ? maxSupportedAnisotropy : 16);
				
			}
			
			switch (mipfilter) {
				
				case Context3DMipFilter.MIPLINEAR:
					
					texture.setMinFilter (GL.LINEAR_MIPMAP_LINEAR);
				
				case Context3DMipFilter.MIPNEAREST:
					
					texture.setMinFilter (GL.NEAREST_MIPMAP_NEAREST);
				
				case Context3DMipFilter.MIPNONE:
					
					texture.setMinFilter (filter == Context3DTextureFilter.NEAREST ? GL.NEAREST : GL.LINEAR);
				
			} 
			
			var tex:Texture = cast texture;
			if (mipfilter != Context3DMipFilter.MIPNONE && !tex.hasMipmap)
			{
				
				GL.generateMipmap(GL.TEXTURE_2D);
				tex.hasMipmap = true;
				
			}
			
		} else if (Std.is (texture, RectangleTexture)) {
			
			texture.setWrapMode (GL.CLAMP_TO_EDGE);
			
			switch (filter) {
				
				case Context3DTextureFilter.LINEAR:
					
					texture.setMagFilter (GL.LINEAR);
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.NEAREST:
					
					texture.setMagFilter (GL.NEAREST);
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.ANISOTROPIC2X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 2) ? maxSupportedAnisotropy : 2);
				
				case Context3DTextureFilter.ANISOTROPIC4X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 4) ? maxSupportedAnisotropy : 4);
				
				case Context3DTextureFilter.ANISOTROPIC8X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 8) ? maxSupportedAnisotropy : 8);
				
				case Context3DTextureFilter.ANISOTROPIC16X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 16) ? maxSupportedAnisotropy : 16);
				
			}
			
			texture.setMinFilter (filter == Context3DTextureFilter.NEAREST ? GL.NEAREST : GL.LINEAR);
			
		} else if (Std.is (texture, CubeTexture)) {
			
			switch (wrap) {
				
				case Context3DWrapMode.CLAMP:
					
					texture.setWrapMode (GL.CLAMP_TO_EDGE);
				
				case Context3DWrapMode.REPEAT:
					
					texture.setWrapMode (GL.REPEAT);
				
			}
			
			switch (filter) {
				
				case Context3DTextureFilter.LINEAR:
					
					texture.setMagFilter (GL.LINEAR);
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.NEAREST:
					
					texture.setMagFilter (GL.NEAREST);
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy (1);
				
				case Context3DTextureFilter.ANISOTROPIC2X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 2) ? maxSupportedAnisotropy : 2);
				 
				case Context3DTextureFilter.ANISOTROPIC4X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 4) ? maxSupportedAnisotropy : 4);
				
				case Context3DTextureFilter.ANISOTROPIC8X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 8) ? maxSupportedAnisotropy : 8);
				
				case Context3DTextureFilter.ANISOTROPIC16X:
					
					if (supportsAnisotropy)
						texture.setMaxAnisotrophy ((maxSupportedAnisotropy < 16) ? maxSupportedAnisotropy : 16);
				
			}
			
			switch (mipfilter) {
				
				case Context3DMipFilter.MIPLINEAR:
					
					texture.setMinFilter (GL.LINEAR_MIPMAP_LINEAR);
				
				case Context3DMipFilter.MIPNEAREST:
					
					texture.setMinFilter (GL.NEAREST_MIPMAP_NEAREST);
				
				case Context3DMipFilter.MIPNONE:
					
					texture.setMinFilter (filter == Context3DTextureFilter.NEAREST ? GL.NEAREST : GL.LINEAR);
				
			}
			
			var cubetex:CubeTexture = cast texture;
			if (mipfilter != Context3DMipFilter.MIPNONE && !cubetex.hasMipmap) {
				
				GL.generateMipmap (GL.TEXTURE_CUBE_MAP);
				cubetex.hasMipmap = true;
				
			}
			
		} else {
			
			throw "Texture of type " + Type.getClassName (Type.getClass (texture)) + " not supported yet";
			
		}
		
	}
	
	
	public function setVertexBufferAt (index:Int, buffer:VertexBuffer3D, bufferOffset:Int = 0, ?format:Context3DVertexBufferFormat):Void {
		
		var location:Int = currentProgram.vaUniformLocationFromAgal(index);
		setGLSLVertexBufferAt (location, buffer, bufferOffset, format);
		
	}
	
	
	private function __updateBlendStatus ():Void {
		
		//TODO do the same for other states ?
		
		if (blendEnabled) {
			
			GL.enable (GL.BLEND);
			GL.blendEquation (GL.FUNC_ADD);
			GL.blendFunc (blendSourceFactor, blendDestinationFactor);
			
		} else {
			
			GL.disable (GL.BLEND);
			
		}
		
	}
	
	
}


private class SamplerState {
	
	
	public var wrap:Context3DWrapMode;
	public var filter:Context3DTextureFilter;
	public var mipfilter:Context3DMipFilter;
	
	
	public function new ():Void {
		
		
		
	}
	
	
}

#else
typedef Context3D = flash.display3D.Context3D;
#end

package openfl.geom; #if !flash

#if openfl_shared
@:jsRequire("openfl", "openfl_geom_Orientation3D") extern
#end
enum Orientation3D {
	
	AXIS_ANGLE;
	EULER_ANGLES;
	QUATERNION;
	
}


#else
typedef Orientation3D = flash.geom.Orientation3D;
#end
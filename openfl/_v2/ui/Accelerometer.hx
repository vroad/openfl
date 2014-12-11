package openfl._v2.ui; #if (!flash && !html5 && !openfl_next)


import openfl.Lib;


class Accelerometer {
	
	
	public static function get ():Acceleration {
		
		return lime_input_get_acceleration ();
		
	}
	
	
	private static var lime_input_get_acceleration = Lib.load ("lime", "lime_input_get_acceleration", 0);
	
	
}


#end
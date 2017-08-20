/*
Gui (c) Matt Bury 2009
Gui static class stores the classes of an externally loaded SWF file and allows access to its class library.
It is for DisplayObjects only and dynamic classes such as dynamic text fields cannot be accessed.

Example code:

var className:String = "MySubclassedDisplayObject";
var Contructor:Class = Gui.getClass(className);
var myDisplayObject:Sprite = new Constructor();
addChild(myDisplayObject);

*/

package com.matbury.sam.gui {
	
	import flash.system.ApplicationDomain;
	
	// AS 3.0 doesn't allow static class definitions
	public class Gui {
		
		private static var _content:ApplicationDomain;
		
		// No need for a class constructor function here.
		
		// Set the application domain object containing the loaded SWFs class definitions
		public static function setClasses(content:ApplicationDomain):void {
			_content = content;
		}
		
		// Return the class definition by name
		public static function getClass(lib:String):Class {
			var defined:Boolean = _content.hasDefinition(lib);
			if(defined) {
				return _content.getDefinition(lib) as Class;
			}
			return null;
		}
		
		public static function getAllClasses():void {
			// Is there some way to iterate through the class definitions here?
		}
	}
}
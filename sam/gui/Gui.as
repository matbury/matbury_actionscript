/*
    This file is part of the matbury.com Actionscript library
    matbury.com Multimedia Interactive Learning Applications (MILAs) are
    free software: you can redistribute them and/or modify them under 
    the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MILAs are distributed in the hope that they will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MILAs.  If not, see <http://www.gnu.org/licenses/>.

    @copyright © 2011 Matt Bury
    @link https://matbury.com/
    @email matbury@gmail.com
    @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
*/
﻿/*
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
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
CheckString.as custom AS 3.0 class
By Matt Bury - matbury@gmail.com - http://matbury.com/

Compares a user input string against another string and returns an array of TextFormat hexidecimal colour values green, amber and red to give the user detailed feedback on their text input.

Contructor:
var cs:CheckString = new CheckString();

Example code onKeyUp event handler:

		function onKeyUpHandler(event:KeyboardEvent):void {
			var original:String = "some example text";
			var input:String = inputTextField.text;
			var a:Array = cs.checkIt(original,input);
			if(a[0] == true){
				// user input is correct, do something
			} else {
				var f:TextFormat = new TextFormat();
				// loop through string character by character
				for(var i:uint = 0; i < len; i++) {
					// set TextFormat colour to value in returned array
					f.color = a[i];
					inputTextField.setTextFormat(f,i,i+1);
				}
			}
		}
*/

package com.matbury {
	
	public class CheckString {
		
		private var _colours:Array;
		
		public function CheckString(toLowerCase:Boolean = true) {
			// TextFormat colours are red, amber, green
			_colours = new Array(0xEE0000,0xFF9900,0x00CC00);
		}
		
		public function checkIt(original:String,input:String):Array {
			var _original:String = original;
			var _input:String = input;
			var _return:Array = new Array();
			var _length:uint = _input.length;
			// check if it's a full match
			if(_original == _input) {
				var correct:Boolean = true;
				_return[0] = correct;
			} else {
				// loop through the input string and check each character
				for(var i:uint = 0; i < _length; i++) {
					var o:String = _original.charAt(i);
					var s:String = _input.charAt(i);
					// same character / same position
					if(s == o) {
						_return[i] =  _colours[2]; // green
						// same character / different position
						} else if(_original.indexOf(s) != -1) {
							_return[i] = _colours[1]; // amber
							// wrong character
						} else if(s != o) {
							_return[i] = _colours[0]; // red
					}
				}
			}
			// return TextFormat colours to doc class
			return _return;
		}
	}
}
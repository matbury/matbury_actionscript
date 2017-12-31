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
Class Keys adds Ctrl + key functions to applications

Constructor:
var keys:Keys = new Keys(stage);

Methods:

*/
package com.matbury {
	
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.events.*;
	
	public class Keys extends Sprite{
		
		private var _stage:Stage;
		
		
		public function Keys(stg:Stage) {
			//super();
			_stage = stg;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function keyDown(event:KeyboardEvent):void {
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		}
		
		private function keyUp(event:KeyboardEvent):void {
			_stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			trace(event);
			var code:int = event.keyCode;
			if(event.ctrlKey) {
				switch(code) {
					
					case 67: // CTRL + p
					sendGrade();
					break;
					
					case 83: // CTRL + s
					sendGrade();
					break;
					
					default:
					trace("nothin'");
					
				}
			}
		}
		
		private function sendGrade():void {
			trace("sendGrade");
		}
	}
}
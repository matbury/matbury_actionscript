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
﻿package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class LoadBar extends Sprite {
		
		private var _lines:Array;
		
		public function LoadBar() {
			drawLines();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function drawLines():void {
			_lines = new Array();
			var len:uint = 13;
			var deg:Number = 360 / len;
			for(var i:uint = 0; i < len; i++) {
				var line:Sprite = new Sprite();
				line.graphics.lineStyle(3,0x444444,1,false,"none","round");
				line.graphics.moveTo(0,-10);
				line.graphics.lineTo(0,-17);
				line.rotation = i * deg;
				line.alpha = i / len;
				_lines.push(line);
				addChild(line);
			}
		}
		
		private function enterFrameHandler(event:Event):void {
			var len:uint = _lines.length;
			for(var i:uint = 0; i < len; i++) {
				_lines[i].alpha -= 0.02;
				if(_lines[i].alpha <= 0) {
					_lines[i].alpha = 1;
				}
			}
		}
	}
}
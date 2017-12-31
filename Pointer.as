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
﻿package com.matbury {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	
	public class Pointer extends Sprite {
		
		private var _arrow:Arr;
		private var _angle:Number = 0;
		
		public function Pointer() {
			initArrow();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			mouseChildren = false;
		}
		
		private function initArrow():void {
			_arrow = new Arr();
			var filter:DropShadowFilter = new DropShadowFilter(4,45,0,1,6,6);
			_arrow.filters = [filter];
			addChild(_arrow);
		}
		
		private function enterFrameHandler(event:Event):void {
			_arrow.y = Math.sin(_angle) * 15;
			_angle += 0.2;
		}
	}
}
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
﻿/**
 * @copyright: Pointer class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a gradient filled animated pointing arrow
 * @package: com.matbury.sam.gui
 * @constructor: var pointer:Pointer = new Pointer([topColor:int = 0x0000ff],[bottomColor:int = 0x000088],[w:Number = 20],[h:Number = 30],[sp:Number = 0.2]);
 * @methods: Pointer.speed Number (set only)
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import com.matbury.sam.gui.Arrow;
	
	public class Pointer extends Sprite {
		
		private var _arrow:Arrow;
		private var _angle:Number = 0;
		private var _topColor:int;
		private var _bottomColor:int;
		private var _wdth:Number;
		private var _hght:Number;
		private var _speed:Number;
		
		public function Pointer(topColor:int = 0x0000ff,bottomColor:int = 0x000088,w:Number = 20,h:Number = 30,sp:Number = 0.2) {
			_topColor = topColor;
			_bottomColor = bottomColor;
			_wdth = w;
			_hght = h;
			_speed = sp;
			initArrow();
			addEventListener(Event.ENTER_FRAME, enterFrame);
			mouseChildren = false;
		}
		
		private function initArrow():void {
			_arrow = new Arrow(_topColor,_bottomColor,_wdth,_hght);
			var filter:DropShadowFilter = new DropShadowFilter(4,45,0,1,4,4);
			_arrow.filters = [filter];
			addChild(_arrow);
		}
		
		private function enterFrame(event:Event):void {
			_arrow.y = Math.sin(_angle) * 15;
			_angle += _speed;
		}
		
		public function set speed(sp:Number):void {
			_speed = sp;
		}
	}
}
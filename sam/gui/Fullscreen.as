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
 * @copyright: Btn class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a button with an icon or text label
 * @package: com.matbury.sam.gui
 * @constructor: var btn:Fullscreen = new Fullscreen([str:String = ""],[i:uint = 0],[topColor:int = 0x0000ff],[bottomColor:int = 0x000088],[iconColor:int = 0xffffff]);
 * @methods: Btn.i = int (get and set)
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import com.matbury.sam.gui.Bg;
	
	public class Fullscreen extends Sprite {
		
		private var _dsf:DropShadowFilter;
		private var _t:TextField;
		private var _bg:Bg;
		private var _arrows:Array;
		private var _topColor:int;
		private var _bottomColor:int;
		private var _iconColor:int;
		private var _onStage:Boolean;
		private var _recording:Boolean = false;
		public static const FS:String = "fullscreen";
		
		public function Fullscreen(topColor:int = 0x0000ff, bottomColor:int = 0x000011, iconColor:int = 0xffffff) {
			_topColor = topColor;
			_bottomColor = bottomColor;
			_iconColor = iconColor;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			this.filters = [_dsf];
			mouseChildren = false;
			buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			drawBg();
			drawGoFullscreen();
		}
		
		private function addedToStage(event:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			_onStage = true;
		}
		
		private function removedFromStage(event:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			_onStage = false;
		}
		
		private function downHandler(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			if(_onStage) {
				parent.parent.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			}
			this.x += 2;
			this.y += 2;
			this.filters = [];
		}
		
		private function upHandler(event:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			if(_onStage) {
				parent.parent.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			}
			this.x -= 2;
			this.y -= 2;
			this.filters = [_dsf];
			dispatchEvent(new Event(FS));
		}
		
		private function drawBg(w:Number = 24,h:Number = 24):void {
			_bg = new Bg(w,h,_topColor,_bottomColor);
			addChildAt(_bg,0);
		}
		
		private function drawArrow():Sprite {
			var size:Number = 3;
			var s:Sprite = new Sprite();
			s.graphics.lineStyle(2,_iconColor);
			s.graphics.moveTo(-size,-size);
			s.graphics.lineTo(size,size);
			s.graphics.lineTo(size,-size);
			s.graphics.moveTo(size,size);
			s.graphics.lineTo(-size,size);
			return s;
		}
		
		private function drawGoFullscreen():void {
			_arrows = new Array();
			var spacing:int = 6;
			//
			var br:Sprite = drawArrow();
			br.x = spacing;
			br.y = spacing;
			addChild(br);
			_arrows.push(br);
			//
			var tl:Sprite = drawArrow();
			tl.rotation = 180;
			tl.x = -spacing;
			tl.y = -spacing;
			addChild(tl);
			_arrows.push(tl);
			//
			var tr:Sprite = drawArrow();
			tr.rotation = 90;
			tr.x = -spacing;
			tr.y = spacing;
			addChild(tr);
			_arrows.push(tr);
			//
			var bl:Sprite = drawArrow();
			bl.rotation = 270;
			bl.x = spacing;
			bl.y = -spacing;
			addChild(bl);
			_arrows.push(bl);
		}
		
		public function rotateArrows():void {
			var len:uint = _arrows.length;
			for(var i:uint = 0; i < len; i++) {
				_arrows[i].rotation += 180;
			}
		}
	}
} // End of Fullscreen class
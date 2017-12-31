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
 * @constructor: var btn:Btn = new Btn([str:String = ""],[i:uint = 0],[topColor:int = 0x0000ff],[bottomColor:int = 0x000088],[iconColor:int = 0xffffff]);
 * @methods: Btn.i = int (get and set)
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.gui.Bar;
	import com.matbury.sam.gui.Bg;
	
	public class Scrubber extends Sprite {
		
		private var _dsf:DropShadowFilter;
		private var _topColor:int;
		private var _bottomColor:int;
		private var _iconColor:int;
		private var _onStage:Boolean;
		private var _w:int;
		private var _l:Sprite;
		private var _r:Sprite;
		private var _bg:Sprite;
		private var _loaded:Sprite;
		private var _played:Sprite;
		private var _scrubber:Sprite;
		private var _lastPos:int;
		
		public function Scrubber(w:int = 100, topColor:int = 0x0000ff, bottomColor:int = 0x000011, iconColor:int = 0xffffff) {
			_topColor = topColor;
			_bottomColor = bottomColor;
			_iconColor = iconColor;
			_w = w;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			this.filters = [_dsf];
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			_l = drawBar(10);
			_l.x = -5;
			_r = drawBar(10);
			_r.x = w - 5;
			_bg = drawBar(w);
			drawLoaded(w);
			drawPlayed(w);
			drawScrubber();
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
		
		public function drawBar(w:Number = 26,h:Number = 26,topColor:Number = 0x0000ff,bottomColor:Number = 0x000088,gradientRotation:Number = 1.57,elipseWidth:Number = 5,elipseHeight:Number = 5):Sprite {
			var matrixX:Number = w * 0.2;
			var matrixY:Number = h * 0.8;
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(matrixX,matrixY,gradientRotation);
			var bg:Sprite = new Sprite();
			bg.graphics.beginGradientFill("linear",[topColor, bottomColor],[1,1],[0,255],matrix);
			bg.graphics.drawRoundRect(0,-h * 0.5,w,h,elipseWidth,elipseHeight);
			bg.graphics.endFill();
			addChild(bg);
			return bg;
		}
		
		private function drawLoaded(w:int):void {
			_loaded = new Sprite();
			_loaded.graphics.beginFill(0,1);
			_loaded.graphics.drawRect(0,-5,w,10);
			_loaded.graphics.endFill();
			addChild(_loaded);
		}
		
		public function set loaded(n:Number):void {
			_loaded.scaleX = n;
		}
		
		private function drawPlayed(w:int):void {
			_played = new Sprite();
			_played.graphics.beginFill(_iconColor,1);
			_played.graphics.drawRect(0,-5,w,10);
			_played.graphics.endFill();
			addChild(_played);
		}
		
		public function set played(n:Number):void {
			_played.scaleX = n;
		}
		
		private function drawScrubber():void {
			_scrubber = new Sprite();
			_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubberDown);
			_scrubber.graphics.beginFill(_iconColor,1);
			_scrubber.graphics.drawCircle(0,0,10);
			_scrubber.graphics.endFill();
			_scrubber.graphics.beginFill(0x0000BB,1);
			_scrubber.graphics.drawCircle(0,0,6);
			_scrubber.graphics.endFill();
			_scrubber.buttonMode = true;
			_scrubber.filters = [_dsf];
			addChild(_scrubber);
		}
		
		private function scrubberDown(event:MouseEvent):void {
			_scrubber.removeEventListener(MouseEvent.MOUSE_DOWN, scrubberDown);
			if(_onStage) {
				parent.parent.addEventListener(MouseEvent.MOUSE_UP, scrubberUp);
			}
			_scrubber.addEventListener(Event.ENTER_FRAME, scrubberMove);
			var rect:Rectangle = new Rectangle(0,0,_loaded.width,0);
			_scrubber.startDrag(false,rect);
		}
		
		private function scrubberUp(event:MouseEvent):void {
			if(_onStage) {
				parent.parent.removeEventListener(MouseEvent.MOUSE_UP, scrubberUp);
			}
			_scrubber.removeEventListener(Event.ENTER_FRAME, scrubberMove);
			_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubberDown);
			_scrubber.stopDrag();
			_lastPos = _scrubber.x / _bg.width * 100;
		}
		
		private function scrubberMove(event:Event):void {
			//dispatchEvent(new Event(RESIZE));
			var pos:Number = _scrubber.x / _loaded.width * 100;
			trace(pos);
		}
		
		public function set scrubber(n:Number):void {
			_scrubber.x = n;
		}
		
		public function set w(w:int):void {
			_bg.width = w;
			_loaded.width = w;
			_played.width = w;
			_r.x = _bg.width - 5;
			_scrubber.x = (_bg.width / 100) * _lastPos;
		}
	}
}
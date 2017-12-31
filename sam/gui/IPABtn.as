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
	import flash.text.*;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import com.matbury.sam.gui.Bar;
	import com.matbury.sam.gui.Bg;
	import com.matbury.sam.gui.Hoop;
	import com.matbury.sam.gui.Question;
	import com.matbury.sam.gui.Tick;
	import com.matbury.sam.gui.Triangle;
	
	public class IPABtn extends Sprite {
		
		private var _dsf:DropShadowFilter;
		private var _t:TextField;
		private var _symbols:Object;
		private var _bg:Bg;
		private var _i:uint;
		private var _label:String = "undefined";
		private var _topColor:int;
		private var _bottomColor:int;
		private var _iconColor:int;
		
		public function IPABtn(str:String = "", i:uint = 0, topColor:int = 0x0000ff, bottomColor:int = 0x000011, iconColor:int = 0xffffff) {
			_topColor = topColor;
			_bottomColor = bottomColor;
			_iconColor = iconColor;
			char = str;
			_i = i;
			mouseChildren = false;
			buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		private function downHandler(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			parent.parent.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			this.x += 2;
			this.y += 2;
			this.filters = [];
		}
		
		private function upHandler(event:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			parent.parent.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			this.x -= 2;
			this.y -= 2;
			this.filters = [_dsf];
		}
		
		public function set char(str:String):void {
			while(this.numChildren > 0) {
				this.removeChildAt(0);
			}
			// add an icon from FLA library
			switch(str) {
				
				case "answer":
				addAnswer();
				drawBg();
				break;
				
				case "back":
				addBack();
				drawBg();
				break;
				
				case "cross":
				addCross();
				drawBg();
				break;
				
				case "forward":
				addForward();
				drawBg();
				break;
				
				case "info":
				addInfo();
				drawBg();
				break;
				
				case "next":
				addNext();
				drawBg();
				break;
				
				case "pause":
				addPause();
				drawBg();
				break;
				
				case "play":
				addPlay();
				drawBg();
				break;
				
				case "question":
				addQuestion();
				drawBg();
				break;
				
				case "quit":
				addQuit();
				drawBg();
				break;
				
				case "rewind":
				addRewind();
				drawBg();
				break;
				
				case "stop":
				addStop();
				drawBg();
				break;
				
				case "stretched":
				addStretched();
				drawBg();
				break;
				
				case "tick":
				addTick();
				drawBg();
				break;
				
				default:
				var w:Number = addLabel(str);
				drawBg(w);
			}
		}
		
		private function addAnswer():void {
			var b1:Bar = new Bar(_iconColor,3,18);
			b1.x = - 3;
			b1.rotation = 25;
			addChild(b1);
			var b2:Bar = new Bar(_iconColor,3,18);
			b2.x = 4;
			b2.rotation = -25;
			addChild(b2);
			var b3:Bar = new Bar(_iconColor,3,8);
			b3.y = 3;
			b3.rotation = 90;
			addChild(b3);
		}
		
		private function addBack():void {
			var t1:Triangle = new Triangle(_iconColor);
			t1.rotation = 180;
			t1.x = -5;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor);
			t2.rotation = 180;
			t2.x = 3;
			addChild(t2);
		}
		
		private function addCross():void {
			var cross:Cross = new Cross(0xffffff);
			cross.x = -cross.width * 0.4;
			cross.y = cross.height * 0.4;
			addChild(cross);
		}
		
		private function addForward():void {
			var t1:Triangle = new Triangle(_iconColor);
			t1.x = -5;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor);
			t2.x = 3;
			addChild(t2);
			var b1:Bar = new Bar(_iconColor,3);
			b1.x = 8;
			addChild(b1);
		}
		
		private function addInfo():void {
			var h:Hoop = new Hoop(_iconColor,9,2);
			addChild(h);
			var d:Bar = new Bar(_iconColor,3.5,3.5);
			d.y = -4.5;
			addChild(d);
			var b:Bar = new Bar(_iconColor,3.5,10);
			b.y = 4;
			addChild(b);
		}
		
		private function addNext():void {
			var t1:Triangle = new Triangle(_iconColor);
			t1.x = -4;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor);
			t2.x = 4;
			addChild(t2);
		}
		
		private function addPause():void {
			var b1:Bar = new Bar(_iconColor);
			b1.x = - 4;
			addChild(b1);
			var b2:Bar = new Bar(_iconColor);
			b2.x = 4;
			addChild(b2);
		}
		
		private function addPlay():void {
			var tri:Triangle = new Triangle(_iconColor,12,16);
			addChild(tri);
		}
		
		private function addQuestion():void {
			var q:Question = new Question(_iconColor);
			addChild(q);
		}
		
		private function addQuit():void {
			var b1:Bar = new Bar(_iconColor,4,20);
			b1.rotation = 45;
			addChild(b1);
			var b2:Bar = new Bar(_iconColor,4,20);
			b2.rotation = -45;
			addChild(b2);
		}
		
		private function addRewind():void {
			var b1:Bar = new Bar(_iconColor,3);
			b1.x = -8;
			addChild(b1);
			var t1:Triangle = new Triangle(_iconColor);
			t1.rotation = 180;
			t1.x = -3;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor);
			t2.rotation = 180;
			t2.x = 5;
			addChild(t2);
		}
		
		private function addStop():void {
			var bar:Bar = new Bar(_iconColor,14,14);
			addChild(bar);
		}
		
		private function addStretched():void {
			var t1:Triangle = new Triangle(_iconColor,10,16);
			t1.x = -2;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor,10,16);
			t2.x = 2;
			addChild(t2);
			var t3:Triangle = new Triangle(_iconColor,10,16);
			t3.x = 6;
			addChild(t3);
		}
		
		private function addTick():void {
			var tick:Tick = new Tick(0xffffff);
			tick.x = -tick.width * 0.4;
			tick.y = tick.height * 0.4;
			addChild(tick);
		}
		
		private function addLabel(str:String):Number {
			_label = str;
			var f:TextFormat = new TextFormat("Charis SIL",20,_iconColor);
			_t = new TextField();
			_t.defaultTextFormat = f;
			_t.embedFonts = true;
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.text = " " + str + " ";
			_t.x = -_t.width * 0.5;
			_t.y = -_t.height * 0.5;
			addChild(_t);
			return _t.width * 1.1;
		}
		
		private function drawBg(w:Number = 24,h:Number = 24):void {
			_bg = new Bg(w,h,_topColor,_bottomColor);
			addChildAt(_bg,0);
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			this.filters = [_dsf];
		}
		
		public function set i(index:int):void {
			_i = index;
		}
		
		public function get i():int {
			return _i;
		}
		
		public function set label(str:String):void {
			_label = str;
			if(_t) {
				_t.text = str;
			}
		}		
		
		public function get label():String {
			return _label;
		}
	}
} // End of Btn class
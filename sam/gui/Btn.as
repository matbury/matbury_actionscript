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
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.gui.Bar;
	import com.matbury.sam.gui.Bg;
	import com.matbury.sam.gui.Hoop;
	import com.matbury.sam.gui.Question;
	import com.matbury.sam.gui.Tick;
	import com.matbury.sam.gui.Triangle;
	
	public class Btn extends Sprite {
		
		private var _dsf:DropShadowFilter;
		private var _t:TextField;
		private var _symbols:Object;
		private var _bg:Bg;
		private var _i:uint;
		private var _label:String = "undefined";
		private var _topColor:int;
		private var _bottomColor:int;
		private var _iconColor:int;
		private var _onStage:Boolean;
		private var _recording:Boolean = false;
		
		public static const ANSWER:String = "answer";
		public static const BACK:String = "back";
		public static const CAMERA:String = "camera";
		public static const CROSS:String = "cross";
		public static const DOWN:String = "down";
		public static const FORWARD:String = "forward";
		public static const INFO:String = "info";
		public static const NEXT:String = "next";
		public static const PAUSE:String = "pause";
		public static const PLAY:String = "play";
		public static const QUESTION:String = "question";
		public static const QUIT:String = "quit";
		public static const RECORD:String = "record";
		public static const REWIND:String = "rewind";
		public static const STOP:String = "stop";
		public static const STRETCHED:String = "stretched";
		public static const TICK:String = "tick";
		public static const UP:String = "up";
		
		public function Btn(str:String = "", i:uint = 0, topColor:int = 0x0000ff, bottomColor:int = 0x000011, iconColor:int = 0xffffff) {
			_i = i;
			_topColor = topColor;
			_bottomColor = bottomColor;
			_iconColor = iconColor;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			this.filters = [_dsf];
			this.char = str;
			mouseChildren = false;
			buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
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
		}
		
		public function set char(str:String):void {
			while(this.numChildren > 0) {
				this.removeChildAt(0);
			}
			// add an icon from FLA library
			switch(str) {
				
				case ANSWER:
				addAnswer();
				drawBg();
				break;
				
				case BACK:
				addBack();
				drawBg();
				break;
				
				case CAMERA:
				addCamera();
				drawBg(32,24);
				break;
				
				case CROSS:
				addCross();
				drawBg();
				break;
				
				case DOWN:
				addDown();
				drawBg();
				break;
				
				case FORWARD:
				addForward();
				drawBg();
				break;
				
				case INFO:
				addInfo();
				drawBg();
				break;
				
				case NEXT:
				addNext();
				drawBg();
				break;
				
				case PAUSE:
				addPause();
				drawBg();
				break;
				
				case PLAY:
				addPlay();
				drawBg();
				break;
				
				case QUESTION:
				addQuestion();
				drawBg();
				break;
				
				case QUIT:
				addQuit();
				drawBg();
				break;
				
				case RECORD:
				addRecord();
				drawBg();
				break;
				
				case REWIND:
				addRewind();
				drawBg();
				break;
				
				case STOP:
				addStop();
				drawBg();
				break;
				
				case STRETCHED:
				addStretched();
				drawBg();
				break;
				
				case TICK:
				addTick();
				drawBg();
				break;
				
				case UP:
				addUp();
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
		
		private function addCamera():void {
			var cam:Cam = new Cam(0xffffff);
			cam.x = -cam.width * 0.4;
			cam.y = cam.height * 0.4;
			addChild(cam);
		}
		
		private function addCross():void {
			var cross:Cross = new Cross(0xffffff);
			cross.x = -cross.width * 0.4;
			cross.y = cross.height * 0.4;
			addChild(cross);
		}
		
		private function addDown():void {
			var t1:Triangle = new Triangle(_iconColor);
			t1.rotation = 90;
			t1.y = -4;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor);
			t2.rotation = 90;
			t2.y = 4;
			addChild(t2);
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
		
		private function addRecord():void {
			var c:Circle = new Circle(_iconColor,14);
			c.x = 0;
			addChild(c);
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
			t1.x = -4;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor,10,16);
			t2.x = 0;
			addChild(t2);
			var t3:Triangle = new Triangle(_iconColor,10,16);
			t3.x = 4;
			addChild(t3);
		}
		
		private function addTick():void {
			var tick:Tick = new Tick(0xffffff);
			tick.x = -tick.width * 0.4;
			tick.y = tick.height * 0.4;
			addChild(tick);
		}
		
		private function addUp():void {
			var t1:Triangle = new Triangle(_iconColor);
			t1.rotation = -90;
			t1.y = -4;
			addChild(t1);
			var t2:Triangle = new Triangle(_iconColor);
			t2.rotation = -90;
			t2.y = 4;
			addChild(t2);
		}
		
		private function addLabel(str:String):Number {
			_label = str;
			var f:TextFormat = new TextFormat(Lang.FONT,20,_iconColor,true);
			_t = new TextField();
			_t.defaultTextFormat = f;
			_t.embedFonts = true;
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.text = str;
			_t.x = -_t.width * 0.5;
			_t.y = -_t.height * 0.5;
			addChild(_t);
			return _t.width * 1.1;
		}
		
		private function drawBg(w:Number = 24,h:Number = 24):void {
			_bg = new Bg(w,h,_topColor,_bottomColor);
			addChildAt(_bg,0);
		}
		
		private function deleteBg():void {
			if(_bg) {
				removeChild(_bg);
				_bg = null;
			}
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
				_t.x = -_t.width * 0.5;
				deleteBg();
				drawBg(_t.width);
			}
		}		
		
		public function get label():String {
			return _label;
		}
		
		public function set recording(bool:Boolean):void {
			_recording = bool;
			removeChildAt(1);
			if(_recording) {
				_iconColor = 0xFF0000;
			} else {
				_iconColor = 0xFFFFFF;
			}
			var c:Circle = new Circle(_iconColor,14);
			c.x = 0;
			addChild(c);
		}
		
		public function get recording():Boolean {
			return _recording;
		}
	}
} // End of Btn class
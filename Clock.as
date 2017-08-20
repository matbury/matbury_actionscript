/*
Clock.as class displays an elapsed time clock

By Matt Bury May 2008
matbury@gmail.com

Example code:

var clock:Clock = new Clock();
addChild(clock);
clock.startClock();

*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.*
	import flash.utils.getTimer;
	import com.matbury.milas.lang.en.Lang;
	
	public class Clock extends Sprite {
		
		private var _initT:uint;
		private var _show:Boolean = true;
		private var _tf:TextField;
		private var _showHide:TextField;
		private var _seconds:uint;
		private var _time:String;
		
		public function Clock() {
			mouseChildren = false;
			buttonMode = true;
			init();
			addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
		
		// create clock display text
		private function init():void {
			var f:TextFormat = new TextFormat(Lang.FONT,20,0,true);
			_tf = new TextField();
			_tf.defaultTextFormat = f;
			_tf.embedFonts = true;
			_tf.antiAliasType = AntiAliasType.ADVANCED;
			_tf.autoSize = TextFieldAutoSize.RIGHT;
			_tf.selectable = false;
			_tf.x = -10;
			addChild(_tf);
			_tf.text = "0:00";
			_showHide = new TextField();
			f.size = 10;
			_showHide.defaultTextFormat = f;
			_showHide.embedFonts = true;
			_showHide.antiAliasType = AntiAliasType.ADVANCED;
			_showHide.autoSize = TextFieldAutoSize.RIGHT;
			_showHide.selectable = false;
			_showHide.x = -10;
			_showHide.y = _tf.y + (_tf.height * 0.8);
			addChild(_showHide);
			_showHide.text = Lang.HIDE_CLOCK;
		}
		
		public function startClock():void {
			_initT = getTimer();
			addEventListener(Event.ENTER_FRAME, countHandler);
		}
		
		public function stopClock():void {
			removeEventListener(Event.ENTER_FRAME, countHandler);
		}
		
		private function countHandler(event:Event):void {
			var elapsed:uint = getTimer() - _initT;
			var seconds:uint = Math.floor(elapsed / 1000);
			_seconds = seconds;
			var minutes:uint = Math.floor(seconds / 60);
			seconds -= minutes * 60;
			_time = minutes + ":" + String(seconds + 100).substr(1,2);
			_tf.text = _time;
		}
		
		private function mouseUp(event:MouseEvent):void {
			if(_show) {
				_tf.textColor = 0xFFFFFF;
				_showHide.text = Lang.SHOW_CLOCK;
				_show = false;
			} else {
				_tf.textColor = 0x000000;
				_showHide.text = Lang.HIDE_CLOCK;
				_show = true;
			}
		}
		
		// var timeelapsed:uint = Clock.seconds;
		public function get seconds():uint {
			return _seconds;
		}
		
		// var timestring:String = Clock.time;
		public function get time():String {
			return _time;
		}
	}
}
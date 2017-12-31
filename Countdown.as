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
Countdown.as custom AS 3.0 class
By Matt Bury - matbury@gmail.com - http://matbury.com/

Contructor:
var _countdown:Countdown = new Countdown();

Example code:

		private function initCountdown():void {
			_countdown = new Countdown();
			_countdown.addEventListener(Countdown.TIME_OUT, timeOutHandler);
			_countdown.x = stage.stageWidth * 0.5;
			_countdown.y = stage.stageHeight * 0.5;
			_countdown.width = stage.stageHeight;
			_countdown.height = stage.stageHeight;
			addChild(_countdown);
			_countdown.start(1000);
		}
		
		private function timeOutHandler(event:Event):void {
			//_countdown.stop();
			_countdown.reset();
			_countdown.start(1000);
		}
		
*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Countdown extends Sprite {
		
		private var _colours:Array;
		private var _segments:Array;
		private var _degrees:Number;
		private var _index:uint = 0;
		private var _timer:Timer;
		private var _started:Boolean = false;
		private var _added:Boolean = false;
		public static const TIME_OUT:String = "timeout";
		
		public function Countdown() {
			initColours();
			initSegements();
		}
		
		// Create array of colours from green to yellow to red
		private function initColours():void {
			_colours = new Array();
			var len:uint = 51;
			// Green to yellow
			var colour:Number = 0x00FF00;
			for(var i:uint = 0; i < len; i++) {
				colour += (65536 * 5); // increment reds in steps
				_colours.push(colour);
			}
			// Yellow to red
			for(i = 0; i < len; i++) {
				colour -= (256 * 5); // decrement greens in steps
				_colours.push(colour);
			}
		}
		
		// Create an array of segments that make up a circle
		private function initSegements():void {
			_segments = new Array();
			var len:uint = _colours.length;
			var degrees:Number = 360 / len;
			for(var i:uint = 0; i < len; i++) {
				var segment:Shape = makeSegment(i);
				segment.rotation = i * degrees;
				addChild(segment);
				_segments.push(segment);
			}
		}
		
		// Draw a wedge segment
		private function makeSegment(i:uint):Shape {
			var segment:Shape = new Shape();
			segment.graphics.beginFill(_colours[i]);
			segment.graphics.lineTo(0,-50);
			segment.graphics.lineTo(3.3,-49.9);
			segment.graphics.lineTo(0,0);
			segment.graphics.endFill();
			return segment;
		}
		
		// Start the countdown time is in milliseconds
		public function start(time:uint = 10000):void {
			reset();
			if(!_started) {
				var len:uint = _segments.length;
				var interval:Number = time / len;
				_timer = new Timer(interval,len);
				_added = addListeners();
				_timer.start();
				_started = true;
			}
		}
		
		private function addListeners():Boolean {
			if(!_added) {
				_timer.addEventListener(TimerEvent.TIMER, timerHandler);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
			}
			return true;
		}
		
		private function removeListeners():Boolean {
			if(_added) {
				_timer.removeEventListener(TimerEvent.TIMER, timerHandler);
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
			}
			return false;
		}
		
		// Remove segments on each tick of the timer
		private function timerHandler(event:TimerEvent):void {
			removeChild(_segments[_index]);
			_index++;
		}
		
		// Timer has finished so tidy up
		private function timerCompleteHandler(event:TimerEvent):void {
			_added = removeListeners();
			_started = false;
			dispatchEvent(new Event(TIME_OUT));
		}
		
		// Stop the clock
		public function stop():void {
			if(_started) {
				_timer.stop();
				_added = removeListeners();
				_started = false;
			}
		}
		
		// Reset the clock
		public function reset():void {
			stop();
			var len:uint = _segments.length;
			for(var i:uint = 0; i < len; i++) {
				addChild(_segments[i]);
			}
			_index = 0;
		}
	}
}
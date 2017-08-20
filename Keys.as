/*
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
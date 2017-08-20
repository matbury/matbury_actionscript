package com.matbury.sam.gui {
	
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
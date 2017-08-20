package com.matbury {
	
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
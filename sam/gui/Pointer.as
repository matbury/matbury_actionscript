/**
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
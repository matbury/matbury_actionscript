/**
 * @copyright: Speakers class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a white panel with images and a text message
 * @package: com.matbury.sam.gui
 * @constructor: var speakers:Speakers = new Speakers();
 * @methods: Speakers.text String (set only)
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.gui.Btn;
	
	public class Speakers extends Sprite {
		
		private var _t:TextField;
		private var _m:String;
		
		public function Speakers(m:String = null) {
			if(m) {
				_m = m;
			} else {
				_m = Lang.SPEAKERS;
			}
			initBg();
			initImage();
			initText();
			positionText();
			initBtn();
			initFilter();
		}
		
		private function initBg():void {
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(-180,-115,360,230);
			this.graphics.endFill();
		}
		
		private function initImage():void {
			var spkrs:Spkrs = new Spkrs();
			addChild(spkrs);
		}
		
		private function initText():void {
			var f:TextFormat = new TextFormat("Trebuchet MS",20,0,true);
			f.align = TextFormatAlign.CENTER;
			_t = new TextField();
			_t.defaultTextFormat = f;
			_t.antiAliasType = AntiAliasType.ADVANCED;
			_t.embedFonts = true;
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.wordWrap = true;
			_t.width = this.width;
			_t.text = _m;
			addChild(_t);
		}
		
		private function positionText():void {
			_t.x = -_t.width * 0.5;
			_t.y = 5;
		}
		
		private function initBtn():void {
			var btn:Btn = new Btn(Lang.OK);
			btn.y = _t.y + _t.height + btn.height;
			addChild(btn);
		}
		
		private function initFilter():void {
			var filter:DropShadowFilter = new DropShadowFilter(4,45,0,1,4,4);
			filters = [filter];
			mouseChildren = false;
			buttonMode = true;
		}
		
		public function set text(str:String):void {
			_t.text = str;
			positionText();
		}
	}
}
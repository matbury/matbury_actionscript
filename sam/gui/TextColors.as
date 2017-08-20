/**
 * @copyright: TextColors class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a text icon indicating traffic light colour coding system for user text input
 * @package: com.matbury.sam.gui
 * @constructor: var textColors:TextColors = new TextColors();
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.text.*;
	import com.matbury.sam.gui.Cross;
	import com.matbury.sam.gui.Tick;
	
	public class TextColors extends Sprite {
		
		private var _t:TextField;
		private var _str:String = "Text colours:";
		
		public function TextColors() {
			this.mouseChildren = false;
			initTextField();
			formatTextColors();
			initTickCross();
			initHalf();
		}
		
		private function initTextField():void {
			var f:TextFormat = new TextFormat("Trebuchet MS",20,0,true);
			_t = new TextField();
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.defaultTextFormat = f;
			_t.embedFonts = true;
			_t.text = _str;
			addChild(_t);
		}
		
		private function formatTextColors():void {
			var colors:Array = new Array(0x00bb00,0xff9900,0xcc0000);
			var f:TextFormat = new TextFormat();
			var letters:Array = _str.split("");
			var len:uint = letters.length;
			var count:int = 0;
			for(var i:uint = 0; i < len; i++) {
				f.color = colors[count];
				_t.setTextFormat(f,i,i + 1);
				count++;
				if(count > 2) {
					count = 0;
				}
			}
		}
		
		private function initTickCross():void {
			var tick:Tick = new Tick();
			tick.x = _t.x + _t.width + 5;
			tick.y = _t.y + (tick.height * 1.1);
			addChild(tick);
			var cross:Cross = new Cross();
			cross.x = _t.x + _t.width + 55;
			cross.y = _t.y + (cross.height * 1.3);
			addChild(cross);
		}
		
		private function initHalf():void {
			var f:TextFormat = new TextFormat("Trebuchet MS",26,0xff9900,true);
			var half:TextField = new TextField();
			half.autoSize = TextFieldAutoSize.LEFT;
			half.defaultTextFormat = f;
			half.text = String.fromCharCode(189);
			half.x = _t.x + _t.width + 25;
			half.y = _t.y - 5;
			addChild(half);
		}
	}
}
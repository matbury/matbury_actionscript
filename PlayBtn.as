/*
unfinished play button. TODO - get button characters to appear in text field.
*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextField;
	
	public class PlayBtn extends Sprite {
		
		public var txt:TextField;
		private var _s:String;
		
		public function PlayBtn(s:String) {
			_s = s;
			init();
		}
		
		private function init():void {
			var bg:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(20,20,1.57);
			bg.graphics.beginGradientFill("linear",[0x0000ff, 0x000011],[100,100],[0,255],matrix);
			bg.graphics.drawRect(-10,-10,20,20);
			bg.graphics.endFill();
			addChild(bg);
			var f:TextFormat = new TextFormat();
			f.font = "Webdings";
			f.size = 15;
			f.color = 0xffffff;
			f.bold = true;
			f.align = TextFormatAlign.CENTER;
			txt = new TextField();
			txt.width = 115;
			txt.height = 26;
			txt.x = -txt.width * 0.5;
			txt.y = -txt.height * 0.5;
			txt.defaultTextFormat = f;
			txt.text = _s;
			addChild(txt);
		}
	}
}
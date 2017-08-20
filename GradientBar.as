package com.matbury {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextField;
	
	public class GradientBar extends Sprite {
		
		private var _top:Number;
		private var _bottom:Number;
		private var _text:String;
		private var _textColour:Number;
		private var _tf:TextField;
		
		public function GradientBar(top:Number = 0x0000FF, bottom:Number = 0x000044, text:String = "", textColour:Number = 0xFFFFFF) {
			_top = top;
			_bottom = bottom;
			_text = text;
			_textColour = textColour;
			init();
		}
		
		private function init():void {
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(20,20,1.57);
			this.graphics.beginGradientFill("linear",[_top, _bottom],[100,100],[0,255],matrix);
			this.graphics.drawRect(0,0,20,20);
			this.graphics.endFill();
			var f:TextFormat = new TextFormat();
			f.font = "Trebuchet MS";
			f.size = 15;
			f.color = 0xFFFFFF;
			f.bold = true;
			f.align = TextFormatAlign.CENTER;
			_tf = new TextField();
			_tf.width = 115;
			_tf.height = 26;
			_tf.x = -_tf.width * 0.5;
			_tf.y = -_tf.height * 0.5;
			_tf.defaultTextFormat = f;
			_tf.text = _text;
			addChild(_tf);
		}
	}
}
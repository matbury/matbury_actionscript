/*
	Pron.as class creates a 200x150 white rectangle with a TextField in the centre.
	For displaying text as images, especially for IPA tokens.
	Copyright © 2012 Matt Bury All rights reserved.
	http://matbury.com/
	matbury@gmail.com
	
	Constructor:
	var pron:Pron = new Pron(token:String);
	addChild(pron);
	
	Requires Charis SIL font embedded including characters: /i:ɪʊuəeˈˌɜɔæʌɑɒapbtdʧʤkgfvθðszʃʒmnŋhlrwj (British English PA).
*/
package com.matbury {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.text.*;
	
	public class PronImage extends Sprite {
		
		private var _bg:Shape;
		private var _t:TextField;
		private var _token:String;

		public function PronImage(token:String) {
			_token = token;
			initBg();
			initText();
		}
		
		private function initBg():void {
			_bg = new Shape();
			_bg.graphics.beginFill(0xFFFFFF,1);
			_bg.graphics.drawRect(-100,-75,200,150);
			_bg.graphics.endFill();
			addChild(_bg);
		}
		
		private function initText():void {
			var size:int = 40;
			var f:TextFormat = new TextFormat("Charis SIL",size);
			_t = new TextField();
			_t.defaultTextFormat = f;
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.embedFonts = true;
			_t.text = _token;
			while(_t.width > 190) {
				size--;
				f.size = size;
				_t.defaultTextFormat = f;
				_t.text = _token;
			}
			_t.x = - _t.width * 0.5;
			_t.y = - _t.height * 0.5;
			addChild(_t);
		}
	}
}

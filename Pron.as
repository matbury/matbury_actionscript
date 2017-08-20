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
	import flash.filters.DropShadowFilter;
	
	public class Pron extends Sprite {
		
		private var _bg:Shape;
		private var _t:TextField;
		private var _token:String;

		public function Pron(token:String) {
			_token = token;
			initBg();
			initText();
			filters = [new DropShadowFilter(2,45,0,1,2,2)];
			mouseChildren = false;
		}
		
		private function initBg():void {
			_bg = new Shape();
			_bg.graphics.beginFill(0xFFFFFF,1);
			_bg.graphics.drawRect(0,0,20,20);
			_bg.graphics.endFill();
			addChild(_bg);
		}
		
		private function initText():void {
			var size:int = 20;
			var f:TextFormat = new TextFormat("Charis SIL",size);
			_t = new TextField();
			_t.defaultTextFormat = f;
			_t.autoSize = TextFieldAutoSize.LEFT;
			_t.embedFonts = true;
			_t.text = _token;
			_t.selectable = false;
			_t.x = 15;
			_t.y = 15;
			addChild(_t);
		}
		
		private function resizeBg():void {
			_bg.width = _t.width;
			_bg.height = _t.height;
			_bg.x = _t.x;
			_bg.y = _t.y;
		}
		
		public function set tokens(s:String):void {
			_token = s;
			_t.text = _token;
			resizeBg();
		}
	}
}

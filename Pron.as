﻿/*
    This file is part of the matbury.com Actionscript library
    matbury.com Multimedia Interactive Learning Applications (MILAs) are
    free software: you can redistribute them and/or modify them under 
    the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MILAs are distributed in the hope that they will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MILAs.  If not, see <http://www.gnu.org/licenses/>.

    @copyright © 2011 Matt Bury
    @link https://matbury.com/
    @email matbury@gmail.com
    @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
*/
﻿/*
	Pron.as class creates a 200x150 white rectangle with a TextField in the centre.
	For displaying text as images, especially for IPA tokens.
	Copyright © 2012 Matt Bury .
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

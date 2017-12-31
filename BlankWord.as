/*
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
BlankWord.as custom AS 3.0 class
By Matt Bury - matbury@gmail.com
(c) 2008 Matt Bury


Constructor:
var blankword:BlankWord = new BlankWord(word:String, posX:Number, posY:Number);
*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import com.matbury.milas.lang.en.Lang;
	
	public class BlankWord extends Sprite {
		
		private var _blank:TextField;
		private var _white:TextFormat;
		private var _black:TextFormat;
		private var _toLowerCase:Boolean;
		public var word:String;
		public var i:int;
		public var finished:Boolean = false;
		
		public function BlankWord(w:String, posX:Number, posY:Number, index:int, toLowerCase:Boolean = true) {
			word = w;
			this.x = posX;
			this.y = posY;
			i = index;
			_toLowerCase = toLowerCase;
			buttonMode = true;
			initBlankWord();
			initCheckWord();
		}
		
		private function initBlankWord():void {
			_white = new TextFormat();
			_white.font = Lang.FONT;
			_white.size = 15;
			_white.color = 0xDDDDDD;
			_white.bold = true;
			
			_black = new TextFormat();
			_black.color = 0x000000;
			
			_blank = new TextField();
			_blank.defaultTextFormat = _white;
			_blank.embedFonts = true;
			_blank.antiAliasType = AntiAliasType.ADVANCED;
			_blank.autoSize = TextFieldAutoSize.LEFT;
			_blank.selectable = false;
			_blank.background = true;
			_blank.backgroundColor = 0xDDDDDD;
			_blank.text = word + " ";
			addChild(_blank);
		}
		
		private function initCheckWord():void {
			if(_toLowerCase) {
				word = word.toLowerCase();
			}
			word = word.replace(".","");
			word = word.replace(",","");
			word = word.replace("?","");
			word = word.replace("!","");
			word = word.replace(":","");
			word = word.replace(";","");
			word = word.replace("\"","");
		}
		
		public function showText():void {
			_blank.setTextFormat(_black);
			finished = true;
		}
	}
}
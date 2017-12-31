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
﻿/**
 * @copyright: Symbol class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws white square with a coloured border and places a TextField in the centre that supports the IPA
 * @package: com.matbury.sam.gui
 * @constructor: var symbol:Symbol = new Symbol(xml:XML,[size:Number = 45],[colour:Number = 0x0000bb]);
 * @methods: Symbol.char String, Symbol.xml XML (get only)
 *
 
(Requires a TextField in FLA with IPA characters embedded as Arial Unicode MS. English IPA character codes are as follows: 618,230,594,650,601,101,652,105,720,593,720,596,720,117,720,604,720,101,618,601,650,97,618,97,650,596,618,618,601,101,601,650,601,112,107,102,116,115,643,952,679,104,98,609,118,100,122,658,240,676,108,114,119,106,109,110,331)

Requires an Arial font object in FLA library set export to Arial

**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.text.*;
	
	public class Symbol extends Sprite {
		
		private var _xml:XML;
		private var _smil:Namespace;
		private var _size:Number;
		private var _colour:Number;
		private var _roundness:int;
		private var _txt:TextField;
		private var _tf:TextFormat;
		private var _font:Font;
		
		public function Symbol(xml:XML,size:Number = 45,colour:Number = 0x0000bb,roundness:int = 0) {
			mouseChildren = false;
			buttonMode = true;
			_xml = xml;
			_size = size;
			_colour = colour;
			_roundness = roundness;
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_xml.name());
			default xml namespace = _smil;
			initBackground();
			initText();
		}
		
		private function initBackground():void {
			var line:int = _size / 15;
			var half:Number = _size * 0.5;
			this.graphics.lineStyle(line,_colour);
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRoundRect(-half,-half,_size,_size,_roundness,_roundness);
			this.graphics.endFill();
		}
		
		private function initText():void {
			_tf = new TextFormat();
			_tf.size = _size * 0.75;
			_tf.font = "Charis SIL";
			_txt = new TextField();
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.defaultTextFormat = _tf;
			_txt.embedFonts = true; // embedded in TextField in FLA file
			_txt.selectable = false;
			_txt.text = String(_xml.@pron);
			_txt.x = -_txt.width * 0.5;
			_txt.y = -_txt.height * 0.6;
			addChild(_txt);
		}
		
		public function get char():String {
			var char:String = _xml.@pron;
			return char;
		}
		
		public function get xml():XML {
			return _xml;
		}
	}
}
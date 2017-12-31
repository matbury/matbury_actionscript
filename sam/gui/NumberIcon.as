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
 * @copyright: NumberIcon class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a small square with a number in the centre
 * @package: com.matbury.sam.gui
 * @constructor: var numberIcon:NumberIcon = new NumberIcon(num:uint,[bgColor:int = 0xbbbbbb],[txtColor:int = 0xffffff],[font:String = "Trebuchet MS"]);
 * @methods: NumberIcon.index = int (get only)
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.text.*;
	import com.matbury.sam.gui.Bg;
	
	public class NumberIcon extends Sprite {
		
		private var _num:uint;
		private var _bgColor:int;
		private var _txtColor:int;
		private var _font:String;
		private var _bg:Bg;
		private var _tf:TextField;
		
		public function NumberIcon(num:uint, bgColor:int = 0xbbbbbb,txtColor:int = 0xffffff,font:String = "Trebuchet MS") {
			_num = num;
			_bgColor = bgColor;
			_txtColor = txtColor;
			_font = font;
			init();
		}
		
		private function init():void {
			initTextField();
			initBg();
		}
		
		private function initTextField():void {
			var f:TextFormat = new TextFormat(_font,12,_txtColor,true,false,false,null,null,TextFormatAlign.CENTER);
			_tf = new TextField();
			_tf.defaultTextFormat = f;
			_tf.embedFonts = true;
			_tf.width = 18;
			_tf.height = 18;
			_tf.y = -2; // align it better with bg
			addChild(_tf);
			_tf.text = String(_num + 1); // convert to human readable number
			_tf.mouseEnabled = false;
		}
		
		private function initBg():void {
			_bg = new Bg(18,18,_bgColor,_bgColor);
			_bg.x += _bg.width * 0.5;
			_bg.y += _bg.height * 0.5;
			addChild(_bg);
			addChild(_tf);
		}
		
		public function get index():uint {
			return _num;
		}
	}
}
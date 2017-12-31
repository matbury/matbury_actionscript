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
﻿package com.matbury {
	
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
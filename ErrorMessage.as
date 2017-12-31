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
ErrorMessage class my Matt Bury 2008
matbury@gmail.com

Displays a prominent error message to the user.

Example doc class or FLA file code:

var msg:String = "This is an error message!";
var sWidth:Number = stage.stageWidth;
var sHeight:Number = stage.stageHeight;
var tfWidth:Number = sWidth * 0.5;
var em:ErrorMessage = new ErrorMessage(msg,sWidth,sHeight,tfWidth);
addChild(em);
*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class ErrorMessage extends Sprite {
		
		private var _msg:String;
		private var _nav:String = "";
		private var _stageWidth:Number;
		private var _stageHeight:Number;
		private var _tfWidth:Number;
		private var _bg:Sprite;
		
		public function ErrorMessage(msg:String,sWidth:Number,sHeight:Number,tfWidth:Number, nav:Boolean = false) {
			_msg = msg;
			_stageWidth = sWidth;
			_stageHeight = sHeight;
			_tfWidth = tfWidth;
			mouseChildren = false;
			if(nav) {
				addEventListener(MouseEvent.MOUSE_DOWN, gotoMatt);
				buttonMode = true;
				_nav = "\n Click here to visit matbury.com";
			}
			createText();
		}
		
		private function createText():void {
			var f:TextFormat = new TextFormat();
			f.align = TextFormatAlign.CENTER;
			f.font = "Trebuchet MS";
			f.color = 0xDD0000;
			f.size = 20;
			var t:TextField = new TextField();
			t.multiline = true;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.width = _tfWidth;
			t.wordWrap = true;
			t.background = true;
			t.backgroundColor = 0xDDDDDD;
			t.defaultTextFormat = f;
			t.selectable = false;
			t.text = _msg + _nav;
			t.x = _stageWidth * 0.5 - (t.width * 0.5);
			t.y = _stageHeight * 0.5 - (t.height * 0.5);
			addChild(t);
		}
		
		private function gotoMatt(event:MouseEvent):void {
			var url:String = "http://matbury.com/";
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request, "_self");
		}
	}
}
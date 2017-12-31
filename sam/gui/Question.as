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
 * @copyright: Question class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a question mark icon (TextField)
 * @package: com.matbury.sam.gui
 * @constructor: var question:Question = new Question([color:int = 0xffffff],[w:Number = 25],[h:Number = 20]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.text.*;
	
	public class Question extends Sprite {
		
		public function Question(color:int = 0xffffff,w:Number = 25,h:Number = 20) {
			var f:TextFormat = new TextFormat("Trebuchet MS",w,color,true);
			var t:TextField = new TextField();
			t.selectable = false;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.defaultTextFormat = f;
			t.text = "?";
			t.x = -t.width * 0.5;
			t.y = -t.height * 0.5;
			addChild(t);
		}
	}
}
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
 * @copyright: Playback class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: ??
 * @package: com.matbury.sam.gui
 * @constructor: 
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Rectangle;
	
	public class Playback extends Sprite {
		
		private var _background:Sprite;
		private var _loadBar:Sprite;
		private var _progressBar:Sprite;
		private var _frame:Sprite;
		private var _scrubber:Sprite;
		private var _elapsed:TextField;
		private var _remaining:TextField;
		
		public function Playback(bg:Sprite,lb:Sprite,pb:Sprite,fr:Sprite,scr:Sprite) {
			_background = bg;
			_loadBar = lb;
			_progressBar = pb;
			_frame = fr;
			_scrubber = scr;
			initGui();
			initText();
		}
		
		private function initGui():void {
			addChild(_background);
			_loadBar.scaleX = 0;
			addChild(_loadBar);
			_progressBar.scaleX = 0;
			addChild(_progressBar);
			addChild(_frame);
			_scrubber.buttonMode = true;
			_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, down);
			addChild(_scrubber);
		}
		
		private function initText():void {
			var f:TextFormat = new TextFormat("Trebuchet MS",14,0,true);
			_elapsed = new TextField();
			_elapsed.defaultTextFormat = f;
			_elapsed.autoSize = TextFieldAutoSize.LEFT;
			_elapsed.x = -10;
			_elapsed.y = _background.height * 0.4;
			addChild(_elapsed);
			_elapsed.text = "0:00";
			_remaining = new TextField();
			_remaining.defaultTextFormat = f;
			_remaining.autoSize = TextFieldAutoSize.RIGHT;
			_remaining.x = _background.width - 12;
			_remaining.y = _background.height * 0.4;
			addChild(_remaining);
			_remaining.text = "0:00";
		}
		
		private function down(event:MouseEvent):void {
			_scrubber.removeEventListener(MouseEvent.MOUSE_DOWN, down);
			this.parent.parent.addEventListener(MouseEvent.MOUSE_UP, up);
			var rect:Rectangle = new Rectangle(0,0,300,0);
			_scrubber.startDrag(false,rect);
			addEventListener(MouseEvent.MOUSE_MOVE, mover);
		}
		
		private function up(event:MouseEvent):void {
			_scrubber.addEventListener(MouseEvent.MOUSE_DOWN, down);
			this.parent.parent.removeEventListener(MouseEvent.MOUSE_UP, up);
			removeEventListener(MouseEvent.MOUSE_MOVE, mover);
			_scrubber.stopDrag();
			// play from new position
		}
		
		private function mover(event:MouseEvent):void {
			_progressBar.width = _scrubber.x;
			_elapsed.text = String(_scrubber.x);
			_remaining.text = String(300 - _scrubber.x);
		}
		
		public function loadProgress():void {
			
		}
		
		private function playbackProgress():void {
			
		}
	}
}
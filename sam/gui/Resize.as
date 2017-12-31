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
﻿package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Resize extends Sprite {
		
		public function Resize(color:int = 0xFFFFFF,w:Number = 20,h:Number = 20) {
			var ox:int = w * 0.5;
			var oy:int = h * 0.5;
			var tl:int = w * 0.1;
			var tr:int = w * 0.4;
			var br:int = w * 0.9;
			var bl:int = w * 0.6;
			this.graphics.beginFill(color,1);
			this.graphics.moveTo(tl - ox, tl - oy);
			this.graphics.lineTo(tl - ox, tr - oy);
			this.graphics.lineTo(tr - ox, tl - oy);
			this.graphics.lineTo(tl - ox, tl - oy);
			this.graphics.moveTo(br - ox, br - oy);
			this.graphics.lineTo(br - ox, bl - oy);
			this.graphics.lineTo(bl - ox, br - oy);
			this.graphics.lineTo(br - ox, br - oy);
			this.graphics.drawCircle(w * 0.5 - ox, h * 0.5 - oy, w * 0.15);
			this.graphics.endFill();
		}
	}
}
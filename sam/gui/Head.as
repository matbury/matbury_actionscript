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
	
	public class Head extends Sprite {
		
		public function Head(w:Number = 22,h:Number = 22) {
			var halfW:Number = w * 0.5;
			var halfH:Number = h * 0.5;
			this.graphics.beginFill(0xdddddd);
			this.graphics.drawRect(-halfW,-halfH,w,h);
			this.graphics.endFill();
			this.graphics.beginFill(0xaaaaaa);
			this.graphics.drawEllipse(-halfW * 0.6,-halfH * 0.9,halfW * 1.2,halfW * 1.5);
			this.graphics.endFill();
			this.graphics.beginFill(0xaaaaaa);
			this.graphics.moveTo(-halfW,halfH);
			this.graphics.lineTo(halfW,halfH);
			this.graphics.curveTo(0,0,-halfW,halfH);
			this.graphics.endFill();
		}
	}
}
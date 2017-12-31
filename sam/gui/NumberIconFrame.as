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
	
	public class NumberIconFrame extends Sprite {

		public function NumberIconFrame(w:Number = 18,h:Number = 18,elipseWidth:Number = 3,elipseHeight:Number = 3) {
			var wdth:Number = w * 0.5;
			var hgth:Number = h * 0.5;
			graphics.lineStyle(1,0x444444,1);
			graphics.drawRoundRect(0,0,w,h,elipseWidth,elipseHeight);
		}
	}
}

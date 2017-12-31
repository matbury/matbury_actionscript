﻿/*
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
 * @copyright: Cross class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a hand-drawn cross symbol
 * @package: com.matbury.sam.gui
 * @constructor: var cross:Cross = new Cross([color:int = 0xcc0000],[w:Number = 12],[h:Number = 12]);
 * @methods:
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Cross extends Sprite {
		
		public function Cross(color:int = 0xcc0000,w:Number = 12,h:Number = 12) {
			var line:Number = w * 0.3;
			this.graphics.lineStyle(line,color);
			this.graphics.moveTo(w,-h);
			this.graphics.curveTo(w * 0.4, -h * 0.6, 0, 0);
			this.graphics.moveTo(0,-h);
			this.graphics.curveTo(w * 0.6, -h * 0.6, w, 0);
		}
	}
}
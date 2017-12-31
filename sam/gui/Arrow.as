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
 * @copyright: Arrow class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a gradient filled arrow shape
 * @package: com.matbury.sam.gui
 * @constructor: var arrow:Arrow = new Arrow([topColor:int = 0x0000ff],[bottomColor:int = 0x000088],[w:Number = 20],[h:Number = 30]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class Arrow extends Sprite {
		
		public function Arrow(topColor:int = 0x0000ff,bottomColor:int = 0x000088,w:Number = 20,h:Number = 30) {
			var qwdth:Number = w * 0.25;
			var wdth:Number = w * 0.5;
			var hght:Number = h * 0.5;
			var matrix:Matrix = new Matrix();
			var offsetY:Number = 35;
			matrix.createGradientBox(w * 0.6,hght,0);
			this.graphics.beginGradientFill("linear",[topColor, bottomColor],[1,1],[0,255],matrix);
			this.graphics.moveTo(-qwdth,hght + offsetY);
			this.graphics.lineTo(-qwdth,0 + offsetY);
			this.graphics.lineTo(-wdth,0 + offsetY);
			this.graphics.lineTo(0,-hght + offsetY);
			this.graphics.lineTo(wdth,0 + offsetY);
			this.graphics.lineTo(qwdth,0 + offsetY);
			this.graphics.lineTo(qwdth,hght + offsetY);
			this.graphics.lineTo(-qwdth,hght + offsetY);
			this.graphics.endFill();
		}
	}
}
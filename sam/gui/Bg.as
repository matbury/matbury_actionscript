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
 * @copyright: Bg class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a gradient filled rounded rectangle shape (background for buttons)
 * @package: com.matbury.sam.gui
 * @constructor: var bg:Bg = new Bg([w:Number = 26],[h:Number = 26],[topColor:Number = 0x0000ff],[bottomColor:Number = 0x000088],[gradientRotation:Number = 1.57],[elipseWidth:Number = 5],[elipseHeight:Number = 5]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class Bg extends Sprite {
		
		public function Bg(w:Number = 26,h:Number = 26,topColor:Number = 0x0000ff,bottomColor:Number = 0x000088,gradientRotation:Number = 1.57,elipseWidth:Number = 5,elipseHeight:Number = 5) {
			var wdth:Number = w * 0.5;
			var hgth:Number = h * 0.5;
			var matrixX:Number = w * 0.2;
			var matrixY:Number = h * 0.8;
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(matrixX,matrixY,1.57);
			this.graphics.beginGradientFill("linear",[topColor, bottomColor],[1,1],[0,255],matrix);
			this.graphics.drawRoundRect(-wdth,-hgth,w,h,elipseWidth,elipseHeight);
			this.graphics.endFill();
		}
	}
}
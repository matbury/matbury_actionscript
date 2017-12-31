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
 * @copyright: Triangle class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a hand-drawn tick icon
 * @package: com.matbury.sam.gui
 * @constructor: var tick:Triangle = new Triangle([color:int = 0x00bb00],[w:Number = 15],[h:Number = 15]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Triangle extends Sprite {
		
		public function Triangle(colour:int = 0xffffff,w:Number = 8,h:Number = 16) {
			var wdth:Number = w * 0.5;
			var hght:Number = h * 0.5;
			this.graphics.beginFill(colour);
			this.graphics.moveTo(-wdth,-hght);
			this.graphics.lineTo(-wdth,hght);
			this.graphics.lineTo(wdth,0);
			this.graphics.lineTo(-wdth,-hght);
			this.graphics.endFill();
		}
	}
}
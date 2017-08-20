/**
 * @copyright: Hoop class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a hoop icon
 * @package: com.matbury.sam.gui
 * @constructor: var hoop:Hoop = new Hoop([color:int = 0xffffff],[radius:Number = 8],[thickness:Number = 2]);
 * @methods:
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Hoop extends Sprite {
		
		public function Hoop(color:int = 0xffffff,radius:Number = 8,thickness:Number = 2) {
			this.graphics.lineStyle(thickness,color);
			this.graphics.drawCircle(0,0,radius);
		}
	}
}
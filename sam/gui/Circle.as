/**
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
	
	public class Circle extends Sprite {
		
		public function Circle(colour:int = 0xffffff,w:Number = 16,h:Number = 16) {
			var wdth:Number = w * 0.5;
			var hght:Number = h * 0.5;
			this.graphics.beginFill(colour);
			this.graphics.drawCircle(0,0,wdth);
			this.graphics.endFill();
		}
	}
}
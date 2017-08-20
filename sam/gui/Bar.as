/**
 * @copyright: Bar class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a rectangle icon
 * @package: com.matbury.sam.gui
 * @constructor: var bar:Bar = new Bar([colour:int = 0xffffff],[w:Number = 4],[h:Number = 16]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Bar extends Sprite {
		
		public function Bar(colour:int = 0xffffff,w:Number = 4,h:Number = 16) {
			var wdth:Number = w * 0.5;
			var hght:Number = h * 0.5;
			this.graphics.beginFill(colour);
			this.graphics.drawRect(-wdth,-hght,w,h);
			this.graphics.endFill();
		}
	}
}
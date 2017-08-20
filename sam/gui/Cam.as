/**
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
	
	public class Cam extends Sprite {
		
		public function Cam(color:int = 0xFFFFFF,w:Number = 22,h:Number = 14) {
			var line:Number = w * 0.1;
			this.graphics.lineStyle(line,color);
			this.graphics.drawRoundRect(-1, -h, w, h, w * 0.3);
			this.graphics.drawCircle(w * 0.6, -h * 0.5, h * 0.4);
		}
	}
}
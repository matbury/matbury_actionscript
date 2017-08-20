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
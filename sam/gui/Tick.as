/**
 * @copyright: Tick class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a hand-drawn tick icon
 * @package: com.matbury.sam.gui
 * @constructor: var tick:Tick = new Tick([color:int = 0x00bb00],[w:Number = 15],[h:Number = 15]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Tick extends Sprite {
		
		public function Tick(color:int = 0x00bb00,w:Number = 15,h:Number = 15) {
			var line:Number = w * 0.3;
			this.graphics.lineStyle(line,color);
			this.graphics.moveTo(w,-h);
			this.graphics.curveTo(w * 0.4, -h * 0.6, w * 0.25, 0);
			this.graphics.curveTo(w * 0.17, -h * 0.17, 0, -h * 0.25);
		}
	}
}
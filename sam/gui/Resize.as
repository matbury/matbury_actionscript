package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Resize extends Sprite {
		
		public function Resize(color:int = 0xFFFFFF,w:Number = 20,h:Number = 20) {
			var ox:int = w * 0.5;
			var oy:int = h * 0.5;
			var tl:int = w * 0.1;
			var tr:int = w * 0.4;
			var br:int = w * 0.9;
			var bl:int = w * 0.6;
			this.graphics.beginFill(color,1);
			this.graphics.moveTo(tl - ox, tl - oy);
			this.graphics.lineTo(tl - ox, tr - oy);
			this.graphics.lineTo(tr - ox, tl - oy);
			this.graphics.lineTo(tl - ox, tl - oy);
			this.graphics.moveTo(br - ox, br - oy);
			this.graphics.lineTo(br - ox, bl - oy);
			this.graphics.lineTo(bl - ox, br - oy);
			this.graphics.lineTo(br - ox, br - oy);
			this.graphics.drawCircle(w * 0.5 - ox, h * 0.5 - oy, w * 0.15);
			this.graphics.endFill();
		}
	}
}
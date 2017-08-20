package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class Head extends Sprite {
		
		public function Head(w:Number = 22,h:Number = 22) {
			var halfW:Number = w * 0.5;
			var halfH:Number = h * 0.5;
			this.graphics.beginFill(0xdddddd);
			this.graphics.drawRect(-halfW,-halfH,w,h);
			this.graphics.endFill();
			this.graphics.beginFill(0xaaaaaa);
			this.graphics.drawEllipse(-halfW * 0.6,-halfH * 0.9,halfW * 1.2,halfW * 1.5);
			this.graphics.endFill();
			this.graphics.beginFill(0xaaaaaa);
			this.graphics.moveTo(-halfW,halfH);
			this.graphics.lineTo(halfW,halfH);
			this.graphics.curveTo(0,0,-halfW,halfH);
			this.graphics.endFill();
		}
	}
}
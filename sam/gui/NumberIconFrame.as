package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	
	public class NumberIconFrame extends Sprite {

		public function NumberIconFrame(w:Number = 18,h:Number = 18,elipseWidth:Number = 3,elipseHeight:Number = 3) {
			var wdth:Number = w * 0.5;
			var hgth:Number = h * 0.5;
			graphics.lineStyle(1,0x444444,1);
			graphics.drawRoundRect(0,0,w,h,elipseWidth,elipseHeight);
		}
	}
}

/**
 * @copyright: Bg class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a gradient filled rounded rectangle shape (background for buttons)
 * @package: com.matbury.sam.gui
 * @constructor: var bg:Bg = new Bg([w:Number = 26],[h:Number = 26],[topColor:Number = 0x0000ff],[bottomColor:Number = 0x000088],[gradientRotation:Number = 1.57],[elipseWidth:Number = 5],[elipseHeight:Number = 5]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	public class Bg extends Sprite {
		
		public function Bg(w:Number = 26,h:Number = 26,topColor:Number = 0x0000ff,bottomColor:Number = 0x000088,gradientRotation:Number = 1.57,elipseWidth:Number = 5,elipseHeight:Number = 5) {
			var wdth:Number = w * 0.5;
			var hgth:Number = h * 0.5;
			var matrixX:Number = w * 0.2;
			var matrixY:Number = h * 0.8;
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(matrixX,matrixY,1.57);
			this.graphics.beginGradientFill("linear",[topColor, bottomColor],[1,1],[0,255],matrix);
			this.graphics.drawRoundRect(-wdth,-hgth,w,h,elipseWidth,elipseHeight);
			this.graphics.endFill();
		}
	}
}
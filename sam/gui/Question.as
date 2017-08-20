/**
 * @copyright: Question class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a question mark icon (TextField)
 * @package: com.matbury.sam.gui
 * @constructor: var question:Question = new Question([color:int = 0xffffff],[w:Number = 25],[h:Number = 20]);
 * @methods: 
**/
package com.matbury.sam.gui {
	
	import flash.display.Sprite;
	import flash.text.*;
	
	public class Question extends Sprite {
		
		public function Question(color:int = 0xffffff,w:Number = 25,h:Number = 20) {
			var f:TextFormat = new TextFormat("Trebuchet MS",w,color,true);
			var t:TextField = new TextField();
			t.selectable = false;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.defaultTextFormat = f;
			t.text = "?";
			t.x = -t.width * 0.5;
			t.y = -t.height * 0.5;
			addChild(t);
		}
	}
}
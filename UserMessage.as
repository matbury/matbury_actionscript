/*
UserMessage.as custom AS 3.0 class
By Matt Bury
matbury@gmail.com
http://matbury.com/

Contructor:
var _um:UserMessage = new UserMessage(message:String,url:String = null,width:int = 400,fontSize:int = 18,fontColor:Number = 0,bgColor:Number = 0xffffff);

Example code:

		private function initUserMessage():void {
			var message:String = "some text";
			var url:String = "http://matbury.com/";
			_um = new UserMessage(message,url);
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			addChild(_um);
		}
		
		private function addText(txt:String):void {
			_um.addMessage(txt);
		}
*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.text.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.matbury.sam.gui.Btn;
	
	public class UserMessage extends Sprite {
		
		private var _tf:TextField;
		private var _f:TextFormat;
		private var _btn:Btn;
		private var _bg:Sprite;
		private var _padding:int = 30;
		private var _message:String; // message
		private var _link:String; // button link URL
		private var _w:int; // width
		private var _fontSize:int; // font size
		private var _fontColor:int; // font colour
		private var _bgColor:int; // font colour
		private var _OKadded:Boolean = false; // add OK button
		public static const CLICKED:String = "clicked";
		
		public function UserMessage(message:String,url:String = null,w:int = 400,fontSize:int = 18,fontColor:int = 0,bgColor:Number = 0xffffff) {
			_message = message;
			_w = w;
			_fontSize = fontSize;
			_fontColor = fontColor;
			_bgColor = bgColor;
			initText();
			initBg();
			adjust();
			if(url) {
				_link = url;
				initLink();
			} else {
				this.addEventListener(MouseEvent.CLICK, closeClickHandler);
			}
			this.buttonMode = true;
		}
		
		// Create and format text field
		private function initText():void {
			mouseChildren = false;
			_f = new TextFormat();
			_f.align = TextFormatAlign.CENTER;
			_f.font = "Trebuchet MS";
			_f.size = _fontSize;
			_f.color = _fontColor;
			_f.bold = true;
			_tf = new TextField();
			_tf.autoSize = TextFieldAutoSize.CENTER;
			_tf.width = _w;
			_tf.wordWrap = true;
			_tf.defaultTextFormat = _f;
			_tf.embedFonts = true;
			_tf.selectable = false;
			_tf.text = _message;
			_tf.x = -_tf.width * 0.5;
			_tf.y = -_tf.height * 0.5;
		}
		
		// Create background
		private function initBg():void {
			_bg = new Sprite();
			_bg.graphics.beginFill(_bgColor);
			_bg.graphics.drawRect(0,0,1,1);
			_bg.graphics.endFill();
			addChild(_bg);
			addChild(_tf);
		}
		
		// Resize and centre the text field and background
		private function adjust():void {
			_tf.x = -_tf.width * 0.5;
			_tf.y = -_tf.height * 0.5;
			_bg.width = _tf.width + _padding;
			_bg.height = _tf.height + _padding;
			_bg.x = -_bg.width * 0.5;
			_bg.y = -_bg.height * 0.5;
		}
		
		// Add navigation to supplied link URL
		private function initLink():void {
			this.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function clickHandler(event:MouseEvent):void {
			var request:URLRequest = new URLRequest(_link);
			navigateToURL(request,"_self");
		}
		
		// tell doc class that UserMessage has been clicked
		private function closeClickHandler(event:MouseEvent):void {
			this.removeEventListener(MouseEvent.CLICK, closeClickHandler);
			dispatchEvent(new Event(CLICKED));
		}
		
		// Add OK button
		public function set addOK(b:Boolean):void {
			if(b) {
				initBtn();
			} else {
				deleteBtn();
			}
			adjustToAdded();
		}
		
		private function initBtn():void {
			_btn = new Btn("OK");
			addChild(_btn);
			_OKadded = true;
		}
		
		private function deleteBtn():void {
			removeChild(_btn);
			_btn = null;
			_OKadded = false;
		}
		
		// Append more text to text field
		public function addMessage(message:String):void {
			_tf.appendText("\n" + message);
			adjustToAdded();
		}
		
		// adjust positions of objects to accommodate added text
		private function adjustToAdded():void {
			if(_OKadded) {
				_bg.height = _tf.height + _padding + (_btn.height * 1.5);
				_btn.y = _bg.y + _bg.height - _padding;
			} else {
				_bg.height = _tf.height + _padding;
			}
		}
	}
}
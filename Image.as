/*
Image class by Matt Bury (C)2009
matbury@gmail.com
http://matbury.com/

Constructor:
var image:Image = new Image(index:int,node:XML,moodledata:String);

Properties:
Image.soundPosition (get only) in milliseconds

Methods:
question
Image.showQuestionImage()
Image.playQuestion()
Image.playQuestionStretched()

answer
Image.showAnswerImage()
Image.playAnswer()
Image.playAnswerStretched()

correct
Image.showCorrectImage()
Image.playCorrect()
Image.playCorrectStretched()

wrong
Image.showWrongImage()
Image.playWrong()
Image.playWrongStretched()

speaker
Image.playSpeaker()

play controls
Image.pauseSound()
Image.resumeSound()
Image.stopSound()

Events:
Image.SOUND_COMPLETE

E.g:
var i:uint = 0;
var image:Image = new Image(i,_xml.interaction.node[i],FlashVars.moodledata);
image.showAnswerImage();
*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.text.TextField;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.filters.DropShadowFilter;
	import com.matbury.sam.gui.LoadBar;
	
	public class Image extends Sprite {
		
		private var _index:int;
		private var _node:XML;
		private var _moodledata:String;
		private var _image:String;
		private var _loader:Loader;
		private var _lb:LoadBar;
		private var _imageShowable:Boolean = false;
		private var _dsf:DropShadowFilter;
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _position:int;
		private var _playing:Boolean = false;
		public static const IMAGE_LOADED:String = "imageLoaded";
		public static const IMAGE_FAILED:String = "imageFailed";
		public static const SOUND_LOADED:String = "soundLoaded";
		public static const SOUND_FAILED:String = "soundFailed";
		
		public function Image(index:int,node:XML,moodledata:String) {
			_index = index;
			_node = node;
			_moodledata = moodledata;
			mouseChildren = false;
			buttonMode = true;
			initLoadBar();
		}
		
		private function initLoadBar():void {
			_lb = new LoadBar();
			addChild(_lb);
		}
		
		/*
		-------------------------- Image Loader --------------------------
		*/
		// question
		public function showQuestionImage():void {
			if(_node.question.image != "" && _node.question.image != undefined) {
				var url:String = _moodledata + _node.question.image;
				loadImage(url);
			} else {
				showErrorText("Error: No URL present in XML file\nAt: <node " + _index + " ><question><image/>");
			}
		}
		
		// answer
		public function showAnswerImage():void {
			if(_node.answer.image != "" && _node.answer.image != undefined) {
				var url:String = _moodledata + _node.answer.image;
				loadImage(url);
			} else {
				showErrorText("Error: No URL present in XML file\nAt: <node " + _index + " ><answer><image/>");
			}
		}
		
		// correct
		public function showCorrectImage():void {
			if(_node.correct.image != "" && _node.correct.image != undefined) {
				var url:String = _moodledata + _node.correct.image;
				loadImage(url);
			} else {
				showErrorText("Error: No URL present in XML file\nAt: <node " + _index + " ><correct><image/>");
			}
		}
		
		// wrong
		public function showWrongImage():void {
			if(_node.wrong.image != "" && _node.wrong.image != undefined) {
				var url:String = _moodledata + _node.wrong.image;
				loadImage(url);
			} else {
				showErrorText("Error: No URL present in XML file\nAt: <node " + _index + " ><wrong><image/>");
			}
		}
		
		// speaker
		public function showSpeakerImage():void {
			if(_node.speaker.image != "" && _node.speaker.image != undefined) {
				var url:String = _moodledata + _node.speaker.image;
				loadImage(url);
			} else {
				showErrorText("Error: No URL present in XML file\nAt: <node " + _index + " ><speaker><image/>");
			}
		}
		
		private function loadImage(url:String):void {
			var request:URLRequest = new URLRequest(url);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIoErrorHandler);
			_loader.load(request);
		}
		
		private function loaderCompleteHandler(event:Event):void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderIoErrorHandler);
			_loader.x = -_loader.width * 0.5;
			_loader.y = -_loader.height * 0.5;
			removeChild(_lb);
			addChild(_loader);
			initFilter();
			dispatchEvent(new Event(IMAGE_LOADED));
		}
		
		private function loaderIoErrorHandler(event:IOErrorEvent):void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderIoErrorHandler);
			showErrorText(event.text + "\nAt: <node " + _index + " >");
			dispatchEvent(new Event(IMAGE_FAILED));
		}
		
		private function showErrorText(str:String):void {
			var t:TextField = new TextField();
			t.width = 200;
			t.height = 150;
			t.x = -100;
			t.y = -75;
			t.wordWrap = true;
			t.text = str;
			addChild(t);
			addChild(_lb);
			removeChild(_lb);
		}
		
		private function initFilter():void {
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			filters = [_dsf];
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		private function downHandler(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			parent.parent.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			x += 2;
			y += 2;
			filters = [];
		}
		
		private function upHandler(event:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			parent.parent.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			x -= 2;
			y -= 2;
			filters = [_dsf];
		}
		
		/*
		----------------------------- Sound -----------------------------
		*/
		// play question
		public function playQuestion():void {
			stopSound();
			if(_node.question.audio != "" && _node.question.audio != undefined) {
				var url:String = _moodledata + _node.question.audio;
				playSound(url);
			}
		}
		// play question stretched
		public function playQuestionStretched():void {
			stopSound();
			if(_node.question.stretched != "" && _node.question.stretched != undefined) {
				var url:String = _moodledata + _node.question.stretched;
				playSound(url);
			}
		}
		// play answer
		public function playAnswer():void {
			stopSound();
			if(_node.answer.audio != "" && _node.answer.audio != undefined) {
				var url:String = _moodledata + _node.answer.audio;
				playSound(url);
			}
		}
		// play answer stretched
		public function playAnswerStretched():void {
			stopSound();
			if(_node.answer.stretched != "" && _node.answer.stretched != undefined) {
				var url:String = _moodledata + _node.answer.stretched;
				playSound(url);
			}
		}
		// play correct
		public function playCorrect():void {
			stopSound();
			if(_node.correct.audio != "" && _node.correct.audio != undefined) {
				var url:String = _moodledata + _node.correct.audio;
				playSound(url);
			}
		}
		// play wrong
		public function playWrong():void {
			stopSound();
			if(_node.wrong.audio != "" && _node.wrong.audio != undefined) {
				var url:String = _moodledata + _node.wrong.audio;
				playSound(url);
			}
		}
		// play speaker
		public function playSpeaker():void {
			stopSound();
			if(_node.speaker.audio != "" && _node.speaker.audio != undefined) {
				var url:String = _moodledata + _node.speaker.audio;
				playSound(url);
			}
		}
		// play speaker stretched
		public function playSpeakerStretched():void {
			stopSound();
			if(_node.speaker.stretched != "" && _node.speaker.stretched != undefined) {
				var url:String = _moodledata + _node.speaker.stretched;
				playSound(url);
			}
		}
		
		private function playSound(url:String):void {
			if(!_playing) {
				var request:URLRequest = new URLRequest(url);
				_sound = new Sound();
				_sound.addEventListener(Event.COMPLETE, soundLoadedHandler);
				_sound.addEventListener(IOErrorEvent.IO_ERROR, soundIoErrorHandler);
				_sound.load(request);
				_channel = _sound.play();
				_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_playing = true;
			}
		}
		
		public function pauseSound():void {
			if(_playing) {
				_position = _channel.position;
				_channel.stop();
				_playing = false;
			}
		}
		
		public function resumeSound():void {
			if(!_playing) {
				_channel = _sound.play(_position);
				_playing = true;
			}
		}
		
		public function stopSound():void {
			if(_playing) {
				_channel.stop();
				_position = 0;
				_playing = false;
			}
		}
		
		public function get soundPosition():int {
			return _position;
		}
		
		private function soundLoadedHandler(event:Event):void {
			_sound.removeEventListener(Event.COMPLETE, soundLoadedHandler);
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, soundIoErrorHandler);
			dispatchEvent(new Event(SOUND_LOADED));
		}
		
		private function soundIoErrorHandler(event:IOErrorEvent):void {
			_sound.removeEventListener(Event.COMPLETE, soundLoadedHandler);
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, soundIoErrorHandler);
			_playing = false;
			showErrorText(event.text + "\nAt: <node " + _index + " >");
			dispatchEvent(new Event(SOUND_FAILED));
		}
		
		// Allow only 1 sound to play at a time
		private function soundCompleteHandler(event:Event):void {
			_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			dispatchEvent(event);
			_playing = false;
		}
		
		public function get index():uint {
			return _index;
		}
	}
}
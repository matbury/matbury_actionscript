/*
CCImage class by Matt Bury (C)2013
matt@matbury.com
http://matbury.com/

Constructor:
var image:Image = new Image(index:int,item:Object);

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
	import flash.text.TextField;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.filters.DropShadowFilter;
	import com.matbury.PronImage;
	import com.matbury.milas.lang.en.Lang;

	public class CCImage extends Sprite {
		
		private var _index:int;
		private var _item:Object;
		private var _img:Sprite;
		private var _imageShowable:Boolean = false;
		private var _dsf:DropShadowFilter;
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _position:int;
		private var _playing:Boolean = false;
		
		public function CCImage(index:int,item:Object) {
			_index = index;
			_item = item;
			// get any namespace properties to avoid parsing errors
			mouseChildren = false;
			buttonMode = true;
		}
		
		/*
		-------------------------- Init Image --------------------------
		*/
		// question
		public function showQuestionImage():void {
			try {
				_img = new _item.question.img();
				addChild(_img);
				initFilter();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// answer
		public function showAnswerImage():void {
			try {
				_img = new _item.answer.img();
				addChild(_img);
				initFilter();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// speaker
		public function showSpeakerImage():void {
			try {
				_img = new _item.speaker.img();
				addChild(_img);
				initFilter();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// speaker
		public function showIPA():void {
			var token:String = _item.answer.text;
			var pron:PronImage = new PronImage(token);
			addChild(pron);
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
		}
		
		private function initFilter():void {
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			_img.filters = [_dsf];
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		private function downHandler(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			parent.parent.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			x += 2;
			y += 2;
			_img.filters = [];
		}
		
		private function upHandler(event:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			parent.parent.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			x -= 2;
			y -= 2;
			_img.filters = [_dsf];
		}
		
		/*
		----------------------------- Play Sound -----------------------------
		*/
		// play question
		public function playQuestion():void {
			stopSound();
			try {
				_sound = new _item.question.audio();
				playSound();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// play question stretched
		public function playQuestionStretched():void {
			stopSound();
			try {
				_sound = new _item.question.audio_str();
				playSound();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// play answer
		public function playAnswer():void {
			stopSound();
			try {
				_sound = new _item.answer.audio();
				playSound();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// play answer stretched
		public function playAnswerStretched():void {
			stopSound();
			try {
				_sound = new _item.answer.audio_str();
				playSound();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// play speaker
		public function playSpeaker():void {
			stopSound();
			try {
				_sound = new _item.speaker.audio();
				playSound();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		// play speaker stretched
		public function playSpeakerStretched():void {
			stopSound();
			try {
				_sound = new _item.speaker.audio_str();
				playSound();
			} catch(e:Error) {
				showErrorText(e.message);
			}
		}
		
		private function playSound():void {
			if(!_playing) {
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
		
		// Allow only 1 sound to play at a time
		private function soundCompleteHandler(event:Event):void {
			_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			dispatchEvent(event);
			_playing = false;
		}
		
		public function get index():uint {
			return _index;
		}
		
		public function get duration():uint {
			if(_sound) {
				return _sound.length;
			} else {
				return 0;
			}
		}
	}
}
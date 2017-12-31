/*
    This file is part of the matbury.com Actionscript library
    matbury.com Multimedia Interactive Learning Applications (MILAs) are
    free software: you can redistribute them and/or modify them under 
    the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MILAs are distributed in the hope that they will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MILAs.  If not, see <http://www.gnu.org/licenses/>.

    @copyright © 2011 Matt Bury
    @link https://matbury.com/
    @email matbury@gmail.com
    @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
*/
﻿/*
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
	import com.matbury.PronImage;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.milas.lang.en.Lang;

	public class SMILImage extends Sprite {
		
		private var _index:int;
		private var _node:XML;
		private var _smil:Namespace;
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
		
		public function SMILImage(index:int,node:XML,moodledata:String) {
			_index = index;
			_node = node;
			_moodledata = moodledata;
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_node.name());
			default xml namespace = _smil;
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
			try {
				var url:String = _moodledata + _node.par.(@id == "question").img[0].@src;
				loadImage(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ question");
			}
		}
		
		// answer
		public function showAnswerImage():void {
			try {
				var url:String = _moodledata + _node.par.(@id == "answer").img[0].@src;
				loadImage(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ answer");
			}
		}
		
		// correct
		public function showCorrectImage():void {
			try {
				var url:String = _moodledata + _node.par.(@id == "correct").img[0].@src;
				loadImage(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ correct");
			}
		}
		
		// wrong
		public function showWrongImage():void {
			try {
				var url:String = _moodledata + _node.par.(@id == "wrong").img[0].@src;
				loadImage(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ wrong");
			}
		}
		
		// speaker
		public function showSpeakerImage():void {
			try {
				var url:String = _moodledata + _node.par.(@id == "speaker").img[0].@src;
				loadImage(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ speaker");
			}
		}
		
		// speaker
		public function showIPA():void {
			var token:String = _node.par.(@id == "answer").audio.(@id == "normal").@pron;
			var pron:PronImage = new PronImage(token);
			addChild(pron);
			initFilter();
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
			showErrorText(event.text);
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
			try {
				var url:String = _moodledata + _node.par.(@id == "question").audio.(@id == "normal").@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ question");
			}
		}
		// play question stretched
		public function playQuestionStretched():void {
			stopSound();
			try {
				var url:String = _moodledata + _node.par.(@id == "question").audio.(@id == "stretched").@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ question");
			}
		}
		// play answer
		public function playAnswer():void {
			stopSound();
			try {
				var url:String = _moodledata + _node.par.(@id == "answer").audio.(@id == "normal").@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ answer");
			}
		}
		// play answer stretched
		public function playAnswerStretched():void {
			stopSound();
			try {
				var url:String = _moodledata + _node.par.(@id == "answer").audio.(@id == "stretched").@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ answer");
			}
		}
		// play correct
		public function playCorrect():void {
			stopSound();
			try {
				var url:String = _moodledata + _node.par.(@id == "correct").audio[0].@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ correct");
			}
		}
		// play wrong
		public function playWrong():void {
			stopSound();
			try {
				var url:String = _moodledata + _node.par.(@id == "wrong").audio[0].@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ wrong");
			}
		}
		// play speaker
		public function playSpeaker():void {
			stopSound();
			try {
				var url:String = _moodledata + _node.par.(@id == "speaker").audio.(@id == "normal").@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ speaker");
			}
		}
		// play speaker stretched
		public function playSpeakerStretched():void {
			stopSound();
			try {
				var url:String = _moodledata + _node.par.(@id == "speaker").audio.(@id == "stretched").@src;
				playSound(url);
			} catch(e:Error) {
				showErrorText(e.message + " par[" + _index + "] @ speaker");
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
			showErrorText(event.toString());
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
		
		public function get duration():uint {
			if(_sound) {
				return _sound.length;
			} else {
				return 0;
			}
		}
	}
}
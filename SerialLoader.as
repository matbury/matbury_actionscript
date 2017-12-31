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
﻿/**
* class SerialLoader
* package com.matbury.swf
* By Matt Bury - matbury@gmail.com - http://matbury.com/
* Version 0.1 28/09/2009
* Copyright Matt Bury 2009
* SWF Activity Module preloader
*
*/

/*
Example FLA/doc class code:

import com.matbury.SerialLoader;

private var _sl:SerialLoader;
private var _errors:Array;

_sl = new SerialLoader(rooturl:String,xml:XML);
_sl.addEventListener(SerialLoader.FINISHED_LOADING, finishedLoading);
_sl.addEventListener(SerialLoader.LOADING_ERRORS, loadingErrors);
addChild(_sl);

private function finishedLoading(event:Event):void {
	_sl.removeEventListener(SerialLoader.FINISHED_LOADING, finishedLoading);
	trace(event);
	//continue
}

private function loadingErrors(event:Event):void {
	_errors = _sl.errors;
	trace(_errors); // send these to error reporting service via FlashRemoting
}

Please note: The current DB model is for swf_interaction_data:
pmp3, qmp3, amp3, smp3, images

but not cmp3 or wmp3

*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class SerialLoader extends Sprite{
		
		private var _xml:XML;
		private var _rooturl:String;
		private var _preloader:TextField;
		private var _tempImages:Array; // URLs to image files
		private var _tempSounds:Array; // URLs to MP3 files
		private var _images:Array; // image files
		private var _sounds:Array; // sound files
		private var _errors:Array; // IO_ERRORS
		private var _imagesMessage:String;
		private var _len:uint;
		private var _index:uint = 0;
		private var _posx:int = 0;
		private var _posy:int = 0;
		public static const FINISHED_LOADING:String = "finishedLoading";
		public static const LOADING_ERRORS:String = "loadingErrors";
		
		public function SerialLoader(rooturl:String,xml:XML) {
			_rooturl = rooturl;
			_xml = xml;
			var r:String = "";
			_errors = new Array();
			_images = new Array();
			createPreloader();
			initImages();
			loadImages();
		}
		
		private function createPreloader():void {
			var f:TextFormat = new TextFormat();
			f.font = "Trebuchet MS";
			f.size = 20;
			f.align = TextFormatAlign.CENTER;
			f.bold = true;
			_preloader = new TextField();
			_preloader.autoSize = TextFieldAutoSize.CENTER;
			_preloader.defaultTextFormat = f;
			_preloader.text = "Loading image " + (_index + 1) + "... 0%\n" + (_index + 1) + " of " + _len;
			_preloader.x = -_preloader.width * 0.5;
			_preloader.y = -_preloader.height;
			addChild(_preloader);
		}
		
		private function initImages():void {
			_tempImages = new Array();
			var len:uint = _xml.interaction.node.length();
			for(var i:uint = 0; i < len; i++) {
				var s:String = _rooturl + _xml.interaction.node[i].answer.image;
				_tempImages.push(s);
			}
			_len = _tempImages.length;
		}
		
		private function loadImages():void {
			if(_index < _len){
				var url:String = _tempImages[_index];
				var request:URLRequest = new URLRequest(url);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.load(request);
				_images.push(loader);
			} else {
				_imagesMessage = "Loaded " + _len + " images.\n" ;
				_index = 0;
				initSounds();
				loadSounds();
			}
		}
		
		private function progressHandler(event:ProgressEvent):void {
			var loaded:int = event.bytesLoaded;
			var total:int = event.bytesTotal;
			var percent:int = Math.floor(loaded / total * 100);
			_preloader.text = "Loading image " + (_index + 1) + "... " + percent + "%\n" + (_index + 1) + " of " + _len;
		}
		
		private function initHandler(event:Event):void {
			var loader:Loader = Loader(event.target.loader);
			removeListeners(loader);
			/*loader.x = _posx;
			loader.y = _posy;
			addChild(loader);
			_posx += loader.width * 0.6;
			if(_posx > _stage.stageWidth - loader.width) {
				_posx = 0;
				_posy += loader.height;
			}*/
			_index++;
			loadImages();
		}
		
		private function errorHandler(event:IOErrorEvent):void {
			_errors.push(event.toString());
			//var loader:Loader = Loader(event.target.loader);
			//removeListeners(loader);
			_index++;
			loadImages();
		}
		
		private function removeListeners(loader:Loader):void {
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.contentLoaderInfo.removeEventListener(Event.INIT, initHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		// push all MP3 URLs that exist into a single array
		private function initSounds():void {
			_tempSounds = new Array();
			var len:uint = _xml.interaction.node.length();
			for(var i:uint = 0; i < len; i++) {
				//
				var q:String = _rooturl + _xml.interaction.node[i].question.audio;
				_tempSounds.push(q);
				//
				var q_s:String = _rooturl + _xml.interaction.node[i].question.stretched;
				_tempSounds.push(q_s);
				//
				var a:String = _rooturl + _xml.interaction.node[i].answer.audio;
				_tempSounds.push(a);
				//
				var a_s:String = _rooturl + _xml.interaction.node[i].answer.stretched;
				_tempSounds.push(a_s);
			}
			_len = _tempSounds.length;
			_sounds = new Array();
		}
		
		private function loadSounds():void {
			if(_index < _len){
				var url:String = _tempSounds[_index];
				var request:URLRequest = new URLRequest(url);
				var sound:Sound = new Sound();
				sound.addEventListener(ProgressEvent.PROGRESS, soundProgressHandler);
				sound.addEventListener(Event.COMPLETE, soundCompleteHandler);
				sound.addEventListener(IOErrorEvent.IO_ERROR, soundErrorHandler);
				sound.load(request);
				_sounds.push(sound);
			} else {
				if(_errors.length > 0) {
					loadingErrors();
				}
				dispatchEvent(new Event(FINISHED_LOADING));
			}
		}
		
		private function soundProgressHandler(event:ProgressEvent):void {
			var loaded:int = event.bytesLoaded;
			var total:int = event.bytesTotal;
			var percent:int = Math.floor(loaded / total * 100);
			_preloader.text = _imagesMessage + "Loading sound " + (_index + 1) + "... " + percent + "%\n" + (_index + 1) + " of " + _len;
		}
		
		private function soundCompleteHandler(event:Event):void {
			var sound:Sound = Sound(event.target);
			removeSoundListeners(sound);
			_index++;
			loadSounds();
		}
		
		private function soundErrorHandler(event:IOErrorEvent):void {
			_errors.push(event.toString());
			var sound:Sound = Sound(event.target);
			removeSoundListeners(sound);
			_index++;
			loadSounds();
		}
		
		private function removeSoundListeners(sound:Sound):void {
			sound.removeEventListener(ProgressEvent.PROGRESS, soundProgressHandler);
			sound.removeEventListener(Event.COMPLETE, soundCompleteHandler);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, soundErrorHandler);
		}
		
		private function loadingErrors():void {
			var len:uint = _errors.length;
			 if(len == 1) {
				_preloader.text = "A media file failed to load.\nThe site administrator has been notified.";
			} else {
				_preloader.text = len + " media files failed to load.\nThe site administrator has been notified.";
			}
			_preloader.text = _errors.toString();
			dispatchEvent(new Event(LOADING_ERRORS));
		}
		
		public function get errors():Array {
			return _errors;
		}
	}
}
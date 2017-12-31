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
* class LoadXML (c) Matt Bury 2007
* package com.matbury
* By Matt Bury - matbury@gmail.com - http://matbury.com/
* Version 2.0 19/04/2011
* SWF Activity Module LoadXML handles loading XML files 
*
*/

/*
Example code:

import com.matbury.LoadXML

		var url:String = "http://yoursite.com/path/to/xml/file.xml";
		var lxml:LoadXML = new LoadXML();
		lxml.addEventListener(LoadXML.LOADED, loadedHandler);
		lxml.addEventListener(LoadXML.FAILED, failedHandler);
		lxml.load(url);
		
		function loadedHandler(event:Event):void {
			lxml.removeEventListener(LoadXML.LOADED, loadedHandler);
			lxml.removeEventListener(LoadXML.FAILED, failedHandler);
			// do something
		}
		
		function failedHandler(event:Event):void {
			lxml.removeEventListener(LoadXML.LOADED, loadedHandler);
			lxml.removeEventListener(LoadXML.FAILED, failedHandler);
			// do something
		}
*/

package com.matbury {
	
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	
	public class LoadXML extends Sprite {
		
		private var _xml:XML;
		private var _loader:URLLoader;
		private var _error:String;
		
		public static const LOADED:String = "loaded";
		public static const FAILED:String = "failed";
				
		public function LoadXML() {
			// do nothing
		}
		
		public function load(url:String):void {
			var _url:String = url;
			var request:URLRequest = new URLRequest(_url);
			_loader = new URLLoader();
			configureListeners(_loader);
			try {
				_loader.load(request);
			} catch(e:Error) {
				removeListeners(_loader);
				dispatchEvent(new Event(FAILED));
				_error = e.message;
			}
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function removeListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
            dispatcher.removeEventListener(Event.OPEN, openHandler);
            dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function completeHandler(event:Event):void {
			// clean up
			removeListeners(_loader);
			if(_loader.data) {
				try {
				_xml = XML(_loader.data);
				dispatchEvent(new Event(LOADED));
				} catch(e:Error) {
					dispatchEvent(new Event(FAILED));
					_error = e.message;
					trace(e.message);
				}
			} else {
				dispatchEvent(new Event(FAILED));
			}
		}
		
		private function openHandler(event:Event):void {
			dispatchEvent(event);
		}
		
		private function progressHandler(event:ProgressEvent):void {
			dispatchEvent(event);
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			removeListeners(_loader);
			dispatchEvent(new Event(FAILED));
		}
		
		private function httpStatusHandler(event:HTTPStatusEvent):void {
			dispatchEvent(event);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			removeListeners(_loader);
			dispatchEvent(new Event(FAILED));
		}
		
		public function set xml(xml:XML):void {
			_xml = xml;
		}
		
		public function get xml():XML {
			return _xml;
		}
	}
}
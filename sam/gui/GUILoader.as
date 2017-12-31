﻿/*
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
GUILoader (c) Matt Bury 2009
GUILoader class loads an external SWF library of GUI graphics and makes their classes available for runtime instiation.

Example code:

	import com.matbury.sam.GUILoader;
	import com.matbury.sam.Gui;

		private var _guiLoader:GUILoader;

		private function init():void {
			var url:String = "skins/gradient_square_blue.swf"; // normally retrieved from FlashVars.skin;
			_guiLoader = new GUILoader();
			_guiLoader.addEventListener(GUILoader.GUI_LOADED, guiLoaded);
			_guiLoader.addEventListener(GUILoader.GUI_ERROR, guiError);
			_guiLoader.load(url);
		}
		
		private function guiLoaded(event:Event):void {
			_guiLoader.removeEventListener(GUILoader.GUI_LOADED, guiLoaded);
			_guiLoader.removeEventListener(GUILoader.GUI_ERROR, guiError);
			Gui.setClasses(_guiLoader.UI);
			createObjects();
			createObjects();
			giveMessage();
		}
		
		private function guiError(event:Event):void {
			_guiLoader.removeEventListener(GUILoader.GUI_LOADED, guiLoaded);
			_guiLoader.removeEventListener(GUILoader.GUI_ERROR, guiError);
		}
*/
package com.matbury.sam.gui {
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.errors.IllegalOperationError;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	public class GUILoader extends EventDispatcher {
		
		public static const GUI_LOADED:String = "guiClassLoaded";
		public static const GUI_ERROR:String = "guiLoadError";
		public static const GUI_SECURITY_ERROR:String = "guiSecurityError";
		private var _loader:Loader;
		
		public function GUILoader() {
			init();
		}
		
		private function init():void {
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityHandler);
		}
		
		// Load the SWF that contains the UI graphics classes
		public function load(lib:String):void {
			var request:URLRequest = new URLRequest(lib);
			var context:LoaderContext = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			_loader.load(request, context);
		}
		
		public function get UI():ApplicationDomain {
			return _loader.contentLoaderInfo.applicationDomain;
		}
		
		private function initHandler(event:Event):void {
			dispatchEvent(new Event(GUI_LOADED));
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			dispatchEvent(new Event(GUI_ERROR));
		}
		
		private function securityHandler(event:Event):void {
			dispatchEvent(new Event(GUI_SECURITY_ERROR));
		}
	}
}
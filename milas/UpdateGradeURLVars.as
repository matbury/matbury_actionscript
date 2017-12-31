/*
    UpdateGradeURLVars Multimedia Interactive Learning Application (MILA).

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
﻿package  com.matbury.milas {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import com.matbury.milas.lang.en.Lang;
	
	public class UpdateGradeURLVars extends Sprite {
	
		private var _loader:URLLoader;
		public static const GRADE_UPDATED:String = "gradeUpdated";
		public static const GRADE_FAILED:String = "gradeFailed";
		public var loaderVars:String = "";
		
		public function UpdateGradeURLVars() {
			//
		}
		
		public function updateGrade(obj:Object):void {
			if(obj.rawgrade === Infinity || obj.rawgrade === 0) {
				loaderVars = Lang.GRADE_NA;
				dispatchEvent(new Event(GRADE_FAILED));
			} else {
				_loader = new URLLoader();
				configureListeners(_loader);
				var vars:URLVariables = new URLVariables();
				vars.instance = obj.instance;
				vars.swfid = obj.swfid;
				vars.rawgrade = obj.rawgrade; // Grade %
				vars.feedbackformat = obj.feedbackformat; // Elapsed time in seconds
				vars.feedback = obj.feedback;
				var request:URLRequest = new URLRequest(obj.gradeupdate);
				request.data = vars;
				request.method = URLRequestMethod.POST;
				try {
					_loader.load(request);
				} catch (e:Error) {
					// Inform user, e.g. "\n" + e.name + ", " + e.message;
					loaderVars = Lang.INCORRECT_DATA;
					dispatchEvent(new Event(GRADE_FAILED));
				}
			}
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, complete);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
		
		private function removeListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(Event.COMPLETE, complete);
			dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
		
		private function complete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			removeListeners(loader);
			loaderVars = loader.data.toString();
			if(loaderVars.indexOf("<html") !== -1) {
				loaderVars = Lang.INCORRECT_DATA;
				dispatchEvent(new Event(GRADE_FAILED));
			} else {
				dispatchEvent(new Event(GRADE_UPDATED));
			}
		}
		
		private function ioError(event:IOErrorEvent):void {
			var loader:URLLoader = URLLoader(event.target);
			removeListeners(loader);
			loaderVars = "Error: " + event.type;
			dispatchEvent(new Event(GRADE_FAILED));
		}
		
		private function securityError(event:SecurityErrorEvent):void {
			var loader:URLLoader = URLLoader(event.target);
			removeListeners(loader);
			loaderVars = "Error: " + event.type;
			dispatchEvent(new Event(GRADE_FAILED));
		}
	}
}
/**
* IMPORTANT: AmfPHP no longer works with Moodle. Please use FlashVars instead:
    com.matbury.sam.data.FlashVars
* class Amf connects learning applications to Moodle DB via lib/amfphp/services
* Uses AMFPHP 1.9
*/

﻿/*
    Amf Multimedia Interactive Learning Application (MILA).

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

/*
Example code to push a grade into Moodle grade book:

import com.matbury.sam.data.Amf;

		var amf:Amf;
		
		// Send the snapshot to the server to be saved by Snapshot.php
        private function sendData():void {
                // Send the ByteArray to AMFPHP
                _amf = new Amf(); // create Flash Remoting API object
                _amf.addEventListener(Amf.GOT_DATA, gotDataHandler); // listen for server response
                _amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
                var obj:Object = new Object(); // create an object to hold data sent to the server
                obj.feedback = "Testing saving WAV files to Moodle."; // (String) optional
                obj.feedbackformat = Math.floor(getTimer() / 1000); // (int) elapsed time in seconds
                obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
                obj.instance = FlashVars.instance; // (int) Moodle instance ID
                obj.rawgrade = 0; // (Number) grade, normally 0 - 100 but depends on grade book settings
                obj.pushgrade = true; // To push or not push a grade
                obj.servicefunction = "Audio.amf_save_audio"; // (String) ClassName.method_name
                obj.swfid = FlashVars.swfid; // (int) activity ID
                obj.bytearray = _recorder.output;
                obj.audiotype = "wav"; // PNGExport = png, JPGExport = jpg
                _amf.getObject(obj); // send the data to the server
        }
                
        // Connection to AMFPHP succeeded
        // Manage returned data and inform user
        private function gotDataHandler(event:Event):void {
                // Clean up listeners
                _amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
                _amf.removeEventListener(Amf.FAULT, faultHandler);
                // Check if grade was sent successfully
				try {
					switch(_amf.obj.result) {
							//
							case "SUCCESS":
							_display.text = _amf.obj.message;
							navigateToGradebook(_amf.obj.audiourl);
							break;
							//
							case "NO_SNAPSHOT_DIRECTORY":
							_display.text = _amf.obj.message;
							break;
							//
							case "FILE_NOT_WRITTEN":
							_display.text = _amf.obj.message;
							break;
							//
							default:
							_display.text = _amf.obj.message;
					}
				} catch(e:Error) {
					_display.text = _amf.obj.toString();
				}
        }
        
        // Connection to AMFPHP failed
        private function faultHandler(event:Event):void {
                // Clean up listeners
                _amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
                _amf.removeEventListener(Amf.FAULT, faultHandler);
                _display.text = "Fault handler error: There was a problem. Your image was not saved.";
        }
        
        private function navigateToGradebook(url:String):void {
                // Open returned URL in a new window,
                //var request:URLRequest = new URLRequest(url);
               	//navigateToURL(request,"_blank");
                // or...
                // redirect to Moodle grade book
                var gradebook:String = FlashVars.gradebook;
				var request:URLRequest = new URLRequest(gradebook);
                navigateToURL(request,"_self");
        }
*/

package com.matbury.sam.data {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	public class Amf extends Sprite {
		
		// server
		private var _responder:Responder;
		private var _nc:NetConnection;
		private var _obj:Object;
		private var _array:Array;
		// events
		public static const GOT_DATA:String = "gotData";
		public static const FAULT:String = "fault";
		public static const SECURITY_FAULT:String = "securityFault";
		public static const GATEWAY_ERROR:String = "Null object reference 'gateway' parameter in com.matbury.sam.data.Amf.";
		public static const SWF_ID_ERROR:String = "Null object reference 'swfid' parameter in com.matbury.sam.data.Amf.";
		public static const INSTANCE_ID_ERROR:String = "Null object reference 'instance' parameter in com.matbury.sam.data.Amf.";
		public static const SERVICE_FUNCTION_ERROR:String = "Null object reference 'servicefunction' parameter in com.matbury.sam.data.Amf.";
		public static const AMF_PHP_RUNTIME_ERROR:String = "amfphpRuntimeError";
		public static const CALL_BAD_VERSION:String = "Packet encoded in an unidentified format.";
		
		public function Amf() {
			//
		}
		
		private function initConnection(gateway:String):Boolean {
			if(gateway != "undefined" && gateway != "") {
				_nc = new NetConnection();
				_nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				_nc.connect(gateway);
				return true;
			} else {
				dispatchEvent(new Event(GATEWAY_ERROR));
				return false;
			}
		}
		
		private function checkObject(obj:Object):void {
			// Throw an error if the required parameters aren't present
			if(obj.gateway == null) {
				dispatchEvent(new Event(GATEWAY_ERROR));
			} else if(obj.swfid == null) {
				dispatchEvent(new Event(SWF_ID_ERROR));
			} else if(obj.instance == null) {
				dispatchEvent(new Event(INSTANCE_ID_ERROR));
			} else if(obj.servicefunction == null) {
				dispatchEvent(new Event(SERVICE_FUNCTION_ERROR));
			}
		}
		
		// --------------------------------------------------------------------- return object
		public function getObject(obj:Object):void {
			var connected:Boolean = initConnection(obj.gateway);
			if(connected) {
				checkObject(obj);
				_responder = new Responder(onObject,onFault);
				_nc.call(obj.servicefunction, _responder, obj);
			}
		}
		
		private function onObject(obj:Object):void {
			_obj = obj;
			dispatchEvent(new Event(GOT_DATA));
		}
		
		// --------------------------------------------------------------------- return Array
		public function getArray(obj:Object):void {
			var connected:Boolean = initConnection(obj.gateway);
			if(connected) {
				checkObject(obj);
				_responder = new Responder(onArray,onFault);
				_nc.call(obj.servicefunction, _responder, obj);
			}
		}
		
		private function onArray(obj:Object):void {
			// Convert object into an array of objects
			_array = new Array();
			for(var s:String in obj) {
				_array.push(obj[s]);
			}
			dispatchEvent(new Event(GOT_DATA));
		}
		
		// --------------------------------------------------------------------- errors
		private function onFault(obj:Object):void {
			_obj = obj;
			dispatchEvent(new Event(FAULT));
		}
		
		/*
		TypeError: Error #1034: Type Coercion failed: cannot convert "NetConnection.Call.Failed" to flash.events.Event.
	at com.matbury.sam.data::Amf/netStatusHandler()
		*/
		private function netStatusHandler(event:NetStatusEvent):void {
			_obj = event;
			//dispatchEvent(event); // uncomment this line for debugging
			// Use following code for production sites
			switch(event.info.code) {
				
				case "NetConnection.Call.BadVersion":
				dispatchEvent(new Event(FAULT));
				break;
				
				case "NetConnection.Call.Failed":
				dispatchEvent(new Event(FAULT));
				break;
				
				case "NetConnection.Call.Prohibited":
				dispatchEvent(new Event(FAULT));
				break;
				
				case "NetConnection.Connect.Failed":
				dispatchEvent(new Event(FAULT));
				break;
				
				case "NetConnection.Connect.Rejected":
				dispatchEvent(new Event(FAULT));
				break;
				
				default:
				dispatchEvent(new Event(event.info.code)); // NetConnection.Connect.Success or NetConnection.Connect.Closed
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			_obj = event;
			dispatchEvent(new Event(SECURITY_FAULT));
		}
		
		// --------------------------------------------------------------------- returned data
		public function get obj():Object {
			return _obj;
		}
		
		public function get array():Array {
			return _array;
		}
		
		// Convert AMFPHP error object into string data
		public function get error():String {
			var errorData:String = "Oops! There was a problem.";
			for(var s:String in _obj) {
				errorData += "\n" + s + " = " + _obj[s];
			}
			// Could be thrown by a PHP 5.3 deprecation warning...
			if(errorData.indexOf("deprecated") != -1) {
				errorData += "\nThis is probably because your LMS/CMS is not fully compatible with PHP 5.3+. Try downgrading to PHP 5.2 or lower until your LMS/CMS compatibility has been updated.";
			}
			return errorData;
		}
	}
}
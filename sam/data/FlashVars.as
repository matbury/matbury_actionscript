/**
* class FlashVars
* package com.matbury.sam.data
* Copyright Matt Bury 2009
* By Matt Bury - matt@matbury.com - http://matbury.com/
* Version 1.1 13/08/2013
* Licence - GNU GPL 3.0 http://www.gnu.org/licenses/gpl.html
* SWF Activity Module variables
*
*/

/*
Example FLA/doc class code:

import com.matbury.sam.data.FlashVars;
FlashVars.vars = this.root.loaderInfo.parameters;

*/

package com.matbury.sam.data {
	
	public class FlashVars extends Object {
// ------------------------------- VARS ------------------------------------ //
		private static var _info:Object; // stores error messages about parameters in FlashVars
		private static var _amfinfo:Object; // stores error messages about parameters in Amf
		// passed in by mod/swf/lib.php
		// Moodle FlashVars in alphabetical order
		private static var _apikey:String;
		private static var _configxml:String;
		private static var _course:uint;
		private static var _coursepage:String;
		private static var _exiturl:String;
		private static var _fullbrowser:String;
		private static var _fullscreen:String;
		private static var _gamelength:uint;
		private static var _gateway:String;
		private static var _gradeupdate:String;
		private static var _gradebook:String;
		private static var _grademax:Number;
		private static var _grademin:Number;
		private static var _gradepass:Number;
		private static var _instance:uint;
		private static var _nextinstance:uint;
		private static var _interaction:uint;
		private static var _moodledata:String;
		private static var _skin:String; // Deprecated
		private static var _starttime:String;
		private static var _sessiontimeout:uint;
		private static var _swfid:uint;
		private static var _userid:uint;
		private static var _wwwroot:String;
		private static var _xmlurl:String;
		
// ------------------------ SETTER FUNCTION ------------------------ //
		// this.root.loaderInfo.parameters object passed in from main SWF assign parameters to 
		//static variables so they can be accessed from anywhere in an application
		// Listed in alphabetical order
		public static function set vars(obj:Object):void {
			_info = new Object();
			// apikey:String = null - Some web services require an API key for authentication, e.g. Google Maps
			var validated:Boolean = checkVar(obj.apikey);
			if(validated) {
				_apikey = obj.apikey;
			} else {
				 _apikey = "undefined";
				_info.apikey = "apikey not set";
			}
			// configxml:String = null - FlashVars can also be set using a config XML file
			validated = checkVar(obj.configxml);
			if(validated) {
				_configxml = obj.configxml;
			} else {
				_configxml = "undefined";
				_info.configxml = "configxml not set";
			}
			// course:String - Current course ID
			validated = checkVar(obj.course);
			if(validated) {
				_course = obj.course;
			} else {
				_course = 0;
				_info.course = "course not set";
			}
			// coursepage:String - URL to current course page, useful for redirects
			validated = checkVar(obj.coursepage);
			if(validated) {
				_coursepage = obj.coursepage;
			} else {
				_coursepage = "undefined";
				_info.coursepage = "coursepage not set";
			}
			// exiturl:String - URL to 
			validated = checkVar(obj.exiturl);
			if(validated) {
				_exiturl = obj.exiturl;
			} else {
				_exiturl = "undefined";
				_info.exiturl = "exiturl not set";
			}
			// fullbrowser:String - URL to current course page, useful for redirects
			validated = checkVar(obj.fullbrowser);
			if(validated) {
				_fullbrowser = obj.fullbrowser;
			} else {
				_fullbrowser = "undefined";
				_info.fullbrowser = "fullbrowser not set";
			}
			// fullscreen:String - allowFullScreen parameter
			validated = checkVar(obj.fullscreen);
			if(validated) {
				_fullscreen = obj.fullscreen;
			} else {
				_fullscreen = "undefined";
				_info.fullscreen = "fullscreen not set";
			}
			// gamelength:uint - number of questions, items or activities to present
			validated = checkVar(obj.gamelength);
			if(validated) {
				_gamelength = obj.gamelength;
			} else {
				_gamelength = 0;
				_info.gamelength = "gamelength not set";
			}
			// gateway:String - Flash Remoting gateway for communicating with Moodle
			validated = checkVar(obj.gateway);
			if(validated) {
				_gateway = obj.gateway;
			} else {
				_gateway = "undefined";
				_info.gateway = "gateway not set";
			}
			// grade:String - URLLoader/URLVariables script for saving grades in Moodle
			validated = checkVar(obj.gradeupdate);
			if(validated) {
				_gradeupdate = obj.gradeupdate;
			} else {
				_gradeupdate = "undefined";
				_info.gradeupdate = "gradeupdate not set";
			}
			// gradebook:String = null - FlashVars can also be set using a config XML file
			validated = checkVar(obj.gradebook);
			if(validated) {
				_gradebook = obj.gradebook;
			} else {
				_gradebook = "undefined";
				_info.gradebook = "gradebook not set";
			}
			// grademax:Number = null - FlashVars can also be set using a config XML file
			validated = checkVar(obj.grademax);
			if(validated) {
				_grademax = obj.grademax;
			} else {
				_grademax = 100;
				_info.grademax = "grademax not set";
			}
			// grademin:Number = null - FlashVars can also be set using a config XML file
			validated = checkVar(obj.grademin);
			if(validated) {
				_grademin = obj.grademin;
			} else {
				_grademin = 0;
				_info.grademin = "grademin not set";
			}
			// gradepass:Number = null - FlashVars can also be set using a config XML file
			validated = checkVar(obj.gradepass);
			if(validated) {
				_gradepass = obj.gradepass;
			} else {
				_gradepass = 0;
				_info.gradepass = "gradepass not set";
			}
			// instance:int - instance of activity module ID
			validated = checkVar(obj.instance);
			if(validated) {
				_instance = obj.instance;
			} else {
				_instance = 0;
				_info.instance = "instance not set";
			}
			// instance:int - instance of activity module ID
			validated = checkVar(obj.nextinstance);
			if(validated) {
				_nextinstance = obj.nextinstance;
			} else {
				_nextinstance = 0;
				_info.nextinstance = "nextinstance not set";
			}
			// interaction:int - learning interaction data set ID
			validated = checkVar(obj.interaction);
			if(validated) {
				_interaction = obj.interaction;
			} else {
				_interaction = 0;
				_info.interaction = "interaction not set";
			}
			// moodledata:String - URL to current course moodledata directory
			validated = checkVar(obj.moodledata);
			if(validated) {
				_moodledata = obj.moodledata;
			} else {
				_moodledata = "undefined";
				_info.moodledata = "moodledata not set";
			}
			// skin:String = null - Flash applications can load an external SWF containing GUI classes
			validated = checkVar(obj.skin);
			if(validated) {
				_skin = obj.skin;
			} else {
				_skin = "undefined";
				_info.skin = "skin not set";
			}
			// starttime:String - start time on server of learning interaction
			validated = checkVar(obj.starttime);
			if(validated) {
				_starttime = obj.starttime;
			} else {
				_starttime = "undefined";
				_info.starttime = "starttime not set";
			}
			// _sessiontimeout - Time in seconds until Moodle session times out
			validated = checkVar(obj.sessiontimeout);
			if(validated) {
				_sessiontimeout = obj.sessiontimeout;
			} else {
				_sessiontimeout = 0;
				_info.sessiontimeout = "sessiontimeout not set";
			}
			// swfid:int - instance of swf module ID
			validated = checkVar(obj.swfid);
			if(validated) {
				_swfid = obj.swfid;
			} else {
				_swfid = 0;
				_info.swfid = "swfid not set";
			}
			// userid:int - user ID
			validated = checkVar(obj.userid);
			if(validated) {
				_userid = obj.userid;
			} else {
				_userid = 0;
				_info.userid = "userid not set";
			}
			// wwwroot:String - URL to main Moodle directory
			validated = checkVar(obj.wwwroot);
			if(validated) {
				_wwwroot = obj.wwwroot;
			} else {
				_wwwroot = "undefined";
				_info.wwwroot = "wwwroot not set";
			}
			// xmlurl:String = null - URL to learning interaction data XML file
			validated = checkVar(obj.xmlurl);
			if(validated) {
				_xmlurl = obj.xmlurl;
			} else {
				_xmlurl = "undefined";
				_info.xmlurl = "xmlurl not set";
			}
		}
		
// ------------------------ GETTER AND SETTER FUNCTIONS ------------------------ //

		// Listed in alphabetical order
		
		public static function get apikey():String {
			return _apikey;
		}
		
		public static function set apikey(k:String):void {
			_apikey = k;
		}
		
		public static function get configxml():String {
			return _configxml;
		}
		
		public static function set configxml(cfg:String):void {
			_configxml = cfg;
		}
		
		public static function get coursepage():String {
			return _coursepage;
		}
		
		public static function set coursepage(cp:String):void {
			_coursepage = cp;
		}
		
		public static function get exiturl():String {
			return _exiturl;
		}
		
		public static function set exiturl(eu:String):void {
			_exiturl = eu;
		}
		
		public static function get course():uint {
			return _course;
		}
		
		public static function set course(n:uint):void {
			_course = n;
		}
		
		public static function get fullbrowser():String {
			return _fullbrowser;
		}
		
		public static function set fullbrowser(fb:String):void {
			_fullbrowser = fb;
		}
		
		public static function get fullscreen():String {
			return _fullscreen;
		}
		
		public static function set fullscreen(fs:String):void {
			_fullscreen = fs;
		}
		
		public static function get gamelength():uint {
			return _gamelength;
		}
		
		public static function set gamelength(n:uint):void {
			_gamelength = n;
		}
		
		public static function get gateway():String {
			return _gateway;
		}
		
		public static function set gateway(gw:String):void {
			_gateway = gw;
		}
		
		public static function get gradeupdate():String {
			return _gradeupdate;
		}
		
		public static function set gradeupdate(gr:String):void {
			_gradeupdate = gr;
		}
		
		public static function get gradebook():String {
			return _gradebook;
		}
		
		public static function set gradebook(gb:String):void {
			_gradebook = gb;
		}
		
		public static function get grademax():Number {
			return _grademax;
		}
		
		public static function set grademax(n:Number):void {
			_grademax = n;
		}
		
		public static function get grademin():Number {
			return _grademin;
		}
		
		public static function set grademin(n:Number):void {
			_grademin = n;
		}
		
		public static function get gradepass():Number {
			return _gradepass;
		}
		
		public static function set gradepass(n:Number):void {
			_gradepass = n;
		}
		
		public static function get instance():uint {
			return _instance;
		}
		
		public static function set instance(n:uint):void {
			_instance = n;
		}
		
		public static function get nextinstance():uint {
			return _nextinstance;
		}
		
		public static function set nextinstance(n:uint):void {
			_nextinstance = n;
		}
		
		public static function get interaction():uint {
			return _interaction;
		}
		
		public static function set interaction(n:uint):void {
			_interaction = n;
		}
		
		public static function get moodledata():String {
			return _moodledata;
		}
		
		public static function set moodledata(url:String):void {
			_moodledata = url;
		}
		
		public static function get sessiontimeout():uint {
			return _sessiontimeout;
		}
		
		public static function set sessiontimeout(st:uint):void {
			_sessiontimeout = st;
		}
		
		public static function get skin():String { // Deprecated
			return _skin;
		}
		
		public static function set skin(s:String):void { // Deprecated
			_skin = s;
		}
		
		public static function get starttime():String {
			return _starttime;
		}
		
		public static function set starttime(st:String):void {
			_starttime = st;
		}
		
		public static function get swfid():uint {
			return _swfid;
		}
		
		public static function set swfid(n:uint):void {
			_swfid = n;
		}
		
		public static function get userid():uint {
			return _userid;
		}
		
		public static function set userid(n:uint):void {
			_userid = n;
		}
		
		public static function get wwwroot():String {
			return _wwwroot;
		}
		
		public static function set wwwroot(url:String):void {
			_wwwroot = url;
		}
		
		public static function get xmlurl():String {
			return _xmlurl;
		}
		
		public static function set xmlurl(url:String):void {
			_xmlurl = url;
		}
		
// -------------------------------------------------------------------------- //
		
		// Error report
		public static function set amfinfo(obj:Object):void {
			_amfinfo = obj;
		}
		
		public static function get amfinfo():Object {
			return _amfinfo;
		}
		
		public static function get info():Object {
			return _info;
		}
		
// --------------------------- VALIDATE FLASHVARS --------------------------- //
		
		private static function checkVar(s:String):Boolean {
			// If null
			if(!s) {
				return false;
			}
			if(s == null) {
				return false;
			}
			try{
				var str:String = s;
			} catch (e:Error) {
				return false;
			}
			// If malicious injection attack
			if(s.indexOf("javascript") != -1) {
				_info += "WARNING! Illegal FlashVars parameter passed in!!! -> " + s;
				throw new Error("WARNING! Illegal FlashVars parameter passed in!!! -> " + s);
				s = null;
				return false;
			}
			return true;
		}
	}
}
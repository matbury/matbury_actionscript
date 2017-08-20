/*
    SMILTagCloud Multimedia Interactive Learning Application (MILA)

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
package com.matbury.milas {
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.*;
	import flash.text.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import com.matbury.sam.gui.Btn;
	import com.matbury.Clock;
	import com.matbury.CMenu;
	import com.matbury.LoadXML;
	import com.matbury.UserMessage;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.LoadBar;
	
	public class SMILTagCloud extends Sprite {
		
		private var _version:String = "2012.06.20";
		private var _amf:Amf;
		private var _xml:XML;
		private var _smil:Namespace;
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _length:uint;
		private var _clock:Clock;
		private var _cmenu:CMenu;
		private var _dsf:DropShadowFilter;
		private var _f:TextFormat;
		private var _title:TextField;
		private var _um:UserMessage;
		private var _titleText:String;
		private var _intro:String;
		private var _forum:int = 9;
		private var _discussion:int = 1;
		private var _discussions:Array;
		private var _exWords:Array;
		private var _words:Array;
		private var _lib:Array;
		private var _tfs:Array;
		
		public function SMILTagCloud() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			/* 
			FlashVars.xmlurl = "../cloud/xml/cloud_words.smil";
			initLoadBar();
			loadData();
			*/
			licenceCheck();
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
		}
		
		private function resize(event:Event):void {
			positionLoadBar();
			positionUserMessage();
			positionTitle();
			positionClock();
		}
		
		/*
		######################### SECURITY CHECK ##########################
		*/
		private function licenceCheck():void {
			var sc:LicenceCheck = new LicenceCheck();
			var checked:Boolean = sc.check(this.root.loaderInfo.url);
			if(checked) {
				initLoadBar();
				positionLoadBar();
				loadData();
			} else {
				showError(Lang.NOT_LICENSED);
				positionUserMessage();
				_um.addEventListener(MouseEvent.MOUSE_DOWN, visitMattBury);
			}
		}
		
		// show user error message with details
		private function showError(message:String):void {
			_um = new UserMessage(message,null,400,18,0xdd0000,0xeeeeee);
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function positionUserMessage():void {
			if(_um) {
				_um.x = stage.stageWidth * 0.5;
				_um.y = stage.stageHeight * 0.5;
			}
		}
		
		// navigate to matbury.com
		private function visitMattBury(event:MouseEvent):void {
			var request:URLRequest = new URLRequest("http://matbury.com/");
			navigateToURL(request,"_self");
		}
		
		/*
		########################### PRELOADER ############################
		*/
		private function initLoadBar():void {
			_loadBar = new LoadBar();
			addChild(_loadBar);
		}
		
		private function positionLoadBar():void {
			if(_loadBar) {
				_loadBar.x = stage.stageWidth * 0.5;
				_loadBar.y = stage.stageHeight * 0.5;
			}
		}
		
		private function deleteLoadBar():void {
			if(_loadBar) {
				removeChild(_loadBar);
				_loadBar = null;
			}
		}
		
		/*
		########################## LOAD DATA #############################
		*/
		private function loadData():void {
			var url:String = FlashVars.xmlurl;
			_loadXML = new LoadXML();
			_loadXML.addEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.addEventListener(LoadXML.FAILED, failedHandler);
			_loadXML.load(url);
		}
		
		function loadedHandler(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.removeEventListener(LoadXML.FAILED, failedHandler);
			deleteLoadBar();
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_loadXML.xml.namespace());
			default xml namespace = _smil;
			initExWords();
			//
			try {
				_titleText = _loadXML.xml.head.meta.(@name == "Title").@content;
			} catch(e:Error) {
				_titleText = "Word Cloud";
			}
			try {
				_intro = _loadXML.xml.head.meta.(@name == "Intro").@content;
			} catch(e:Error) {
				_intro = "Most frequently used words.";
			}
			try {
				initInteraction();
			} catch(e:Error) {
				showError(Lang.NO_ACTIVITY_DATA);
				positionUserMessage();
			}
		}
		
		function initExWords():void {
			_exWords = new Array();
			var len:uint = _loadXML.xml.body.seq.par.(@id == "keyword").text.length();
			for(var i:uint = 0; i < len; i++) {
				_exWords.push(_loadXML.xml.body.seq.par.(@id == "keyword").text[i]);
			}
		}
		
		function failedHandler(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.removeEventListener(LoadXML.FAILED, failedHandler);
			showError(Lang.NO_ACTIVITY_DATA);
			positionUserMessage();
		}
		
		/*
		########################## INTERACTION #############################
		*/
		private function initInteraction():void {
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			_f = new TextFormat(Lang.FONT,15,0,false);
			initTitle();
			initClock();
			resize(null);
			//getForumPosts();
			getForumDiscussions();
		}
		
		/*
		############################ TITLE #############################
		*/
		private function initTitle():void {
			_title = new TextField();
			_f.size = 20;
			_title.defaultTextFormat = _f;
			_title.embedFonts = true;
			_title.antiAliasType = AntiAliasType.ADVANCED;
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.selectable = false;
			_title.text = _titleText;
			addChild(_title);
		}
		
		private function positionTitle():void {
			if(_title) {
				_title.x = stage.stageWidth * 0.5 - (_title.width * 0.5);
				_title.y = 5;
			}
		}
		
		/*
		############################ CLOCK #############################
		*/
		private function initClock():void {
			_clock = new Clock();
			addChild(_clock);
		}
		
		private function positionClock():void {
			if(_clock) {
				_clock.x = stage.stageWidth;
				_clock.y = 0;
			}
		}
		
		/*
		############################ GET FORUM DISCUSSIONS #############################
		*/
		private function getForumDiscussions():void {
			_um = new UserMessage("Getting discussions... ");
			_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
			positionUserMessage();
			addChild(_um);
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotDiscussionsHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			var obj:Object = new Object(); // create an object to hold data sent to the server
			obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			obj.swfid = FlashVars.swfid; // (int) activity ID
			obj.instance = FlashVars.instance; // (int) Moodle instance ID
			obj.forum = _forum;
			obj.servicefunction = "Forum.amf_get_forum_discussions"; // (String) ClassName.method_name
			_amf.getObject(obj); // send the data to the server
		}
		
		// Connection to AMFPHP succeeded
		// Manage returned data and inform user
		private function gotDiscussionsHandler(event:Event):void {
			// Clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDiscussionsHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			// Check if grade was sent successfully
			try {
				switch(_amf.obj.result) {
					//
					case "SUCCESS":
					_um.addMessage("Got forum discussions.");
					/*for(var s:String in _amf.obj.discussions) {
						_um.addMessage(s + " = " + _amf.obj.discussions[s].name
									   + "\ncourse = " + _amf.obj.discussions[s].course
									   + "\nforum = " + _amf.obj.discussions[s].forum
									   + "\nid = " + _amf.obj.discussions[s].id);
					}*/
					initDiscussions();
					positionDiscussions();
					break;
					//
					case "NO_PERMISSION":
					_um.addMessage(_amf.obj.message);
					break;
					//
					default:
					_um.addMessage("Unknown error.");
				}
			} catch(e:Error) {
				_um.addMessage(Lang.GRADE_UNKNOWN + "\n" + Lang.PHP_VERSION_ERROR);
			}
		}
		
		private function initDiscussions():void {
			_discussions = new Array();
			for(var s:String in _amf.obj.discussions) {
				var obj:Object = _amf.obj.discussions[s];
				var d:Btn = new Btn(obj.name,obj.id,0xFFFFFF,0xCCCCCC,0);
				d.addEventListener(MouseEvent.MOUSE_UP, discussionUp);
				addChild(d);
				_discussions.push(d);
			}
		}
		
		private function positionDiscussions():void {
			if(_discussions) {
				var posX:int = stage.stageWidth * 0.5;
				var posY:int = 50;
				var len:uint = _discussions.length;
				for(var i:uint = 0; i < len; i++) {
					_discussions[i].x = posX;
					_discussions[i].y = posY;
					posY += _discussions[i].height * 1.1;
				}
			}
		}
		
		private function deleteDiscussions():void {
			if(_discussions) {
				var len:uint = _discussions.length;
				for(var i:uint = 0; i < len; i++) {
					_discussions[i].removeEventListener(MouseEvent.MOUSE_UP, discussionUp);
					removeChild(_discussions[i]);
				}
				_discussions = null;
			}
		}
		
		private function discussionUp(event:MouseEvent):void {
			var d:Btn = event.currentTarget as Btn;
			_discussion = d.i;
			deleteDiscussions();
			getForumPosts();
		}
		
		// Display server errors
		private function faultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDiscussionsHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			var msg:String = Lang.ERROR;
			for(var s:String in _amf.obj.info) { // trace out returned data
				msg += "\n" + s + "=" + _amf.obj.info[s];
			}
			_um.addMessage(msg);
		}
		
		private function umClickedHandler(event:Event):void {
			if(_um) {
				_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
				removeChild(_um);
				_um = null;
			}
		}
		
		/*
		############################ GET FORUM POSTS #############################
		*/
		private function getForumPosts():void {
			//_um = new UserMessage("Getting posts... ");
			_um.addMessage("Getting posts... ");
			_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
			positionUserMessage();
			addChild(_um);
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotPostsHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			var obj:Object = new Object(); // create an object to hold data sent to the server
			obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			obj.swfid = FlashVars.swfid; // (int) activity ID
			obj.instance = FlashVars.instance; // (int) Moodle instance ID
			obj.forum = _forum;
			obj.discussion = _discussion;
			obj.servicefunction = "Forum.amf_get_forum_posts"; // (String) ClassName.method_name
			_amf.getObject(obj); // send the data to the server
		}
		
		// Connection to AMFPHP succeeded
		// Manage returned data and inform user
		private function gotPostsHandler(event:Event):void {
			// Clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotPostsHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			// Check if grade was sent successfully
			try {
				switch(_amf.obj.result) {
					//
					case "SUCCESS":
					_um.addMessage("Got discussion posts.");
					for(var s:String in _amf.obj.posts) {
						//_um.addMessage(s + " = " + _amf.obj.posts[s].words[0]);
					}
					initWords();
					break;
					//
					case "NO_PERMISSION":
					_um.addMessage(_amf.obj.message);
					break;
					//
					default:
					_um.addMessage("Unknown error.");
				}
			} catch(e:Error) {
				_um.addMessage(Lang.GRADE_UNKNOWN + "\n" + Lang.PHP_VERSION_ERROR);
			}
		}
		/*
		_amf.obj.posts // array of posts
		_amf.obj.posts[i].text // text stripped of HTML tags
		_amf.obj.posts[i].words[j] // array of words
		*/
		private function initWords():void {
			var words:Array = new Array();
			var len_i:uint = _amf.obj.posts.length;
			for(var i:uint = 0; i < len_i; i++) {
				var len_j:uint = _amf.obj.posts[i].words.length;
				for(var j:uint = 0; j < len_j; j++) {
					words.push(_amf.obj.posts[i].words[j]);
				}
			}
			//_um.addMessage("Number of all words = " + words.length);
			_words = filterWords(words);
			//_um.addMessage("Number of key words = " + words.length + " " + words.toString());
			countWords();
		}
		
		/*private function init2DWords(words:Array):Array {
			var len:uint = words.length;
			var s:String = words[0];
			var newWords:Array = new Array(s);
			for(var i:uint = 1; i < len; i++) {
				if(words[i] == s) {
					newWords[i].push(words[i]);//????
				}
			}
			return newWords;
		}*/
		
		private function filterWords(words:Array):Array {
			words.sort();
			var len_i:uint = words.length;
			var len_j:uint = _exWords.length;
			var filtred:Array = new Array();
			for(var i:uint = 0; i < len_i; i++) {
				var matched:Boolean = false;
				for(var j:uint = 0; j < len_j; j++) {
					if(words[i] == _exWords[j]) {
						matched = true;
					}
				}
				if(!matched) {
					filtred.push(words[i]);
				}
			}
			return filtred;
		}
		
		private function initCloud(words:Array):void {
			_words = new Array();
			var len:uint = words.length;
			for(var i:uint = 0; i < len; i++) {
				
			}
		}
				
				
		private function countWords():void {
			_words.sort();
			var len:uint = _words.length;
			_lib = new Array();
			var arr:Array = new Array(_words[0]);
			_lib.push(arr);
			var current:String = _words[0];
			for(var i:uint = 1; i < len; i++) {
				if(_words[i].length > 0) {
					if(_words[i] != current) {
						current = _words[i];
						var a:Array = new Array(_words[i]);
						_lib.push(a);
					} else {
						_lib[_lib.length - 1].push(_words[i]);
					}
				}
			}
			_lib.sort(sortOnLength);
			//showWordFrequency();
			removeChild(_um);
			initTexts();
		}
		
		private function sortOnLength(a:Array, b:Array):int {
			if(a.length < b.length) {
				return 1;
			} else if(a.length > b.length) {
				return -1;
			} else {
				return 0;
			}
		}
		
		private function showWordFrequency():void {
			var len:uint = _lib.length;
			for(var i:uint = 0; i < len; i++) {
				//_um.addMessage(_lib[i][0] + "	=		" + _lib[i].length + " " + _lib[i][0].length);
				//trace(_lib[i][0] + "	=		" + _lib[i].length + " " + _lib[i][0].length);
			}
		}
		
		private function initTexts():void {
			_tfs = new Array();
			var len:uint = _lib.length;
			var posX:int = 10;
			var posY:int = 10;
			var maxWidth:int = 0;
			var f:TextFormat = new TextFormat("Trebuchet MS",5,0,true);
			for(var i:uint = 0; i < len; i++) {
				var c:int = _lib[i].length;
				if(c > 1) {
					var s:String = _lib[i][0];
					var t:TextField = new TextField();
					f.size = c * 7;
					t.defaultTextFormat = f;
					t.autoSize = TextFieldAutoSize.LEFT;
					t.text = s + " " + c;
					//
					f.size = 10;
					t.setTextFormat(f,s.length,t.length);
					t.x = posX;
					t.y = posY;
					if(t.width > maxWidth) {
						maxWidth = t.width;
					}
					posY += t.height;
					if(posY + t.height + 10 > stage.stageHeight) {
						posX += maxWidth + 10;
						posY = 10;
						maxWidth = 0;
					}
					addChild(t);
					_tfs.push(t);
				}
			}
		}
	}
}
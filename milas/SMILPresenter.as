/*
	SMILPresenter Multimedia Interactive Learning Application (MILA).
	Copyright © 2011 Matt Bury All rights reserved.
	http://matbury.com/
	matbury@gmail.com
*/
package com.matbury.milas {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import com.matbury.Clock;
	import com.matbury.CMenu;
	import com.matbury.LoadXML;
	import com.matbury.UserMessage;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.Cross;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.NumberIcon;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.Tick;
	
	public class SMILPresenter extends Sprite {
		
		private var _version:String = "2013.04.15";
		private var _amf:Amf;
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _xml:XML;
		private var _smil:Namespace;
		private var _length:uint;
		private var _clock:Clock;
		private var _dsf:DropShadowFilter;
		private var _speakers:Speakers;
		private var _completed:int = 0;
		private var _score:Array;
		private var _numbers:Array;
		private var _point:Sprite;
		private var _index:int = -1;
		private var _f:TextFormat;
		private var _titleText:TextField;
		private var _next:Btn;
		private var _prev:Btn;
		private var _timer:Timer;
		private var _cmenu:CMenu;
		private var _um:UserMessage;
		private var _containers:Array;
		private var _pars:Array;
		
		public function SMILPresenter() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			initCMenu();
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			stage.addEventListener(Event.RESIZE, resize);
			//securityCheck();
			/* */
			FlashVars.xmlurl = "../commonobjects/xml/slide_show.smil";
			FlashVars.moodledata = "../";
			initLoadBar();
			positionLoadBar();
			loadData();
			
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
		}
		
		private function initBack():void {
			var btn:Btn = new Btn("back");
			btn.addEventListener(MouseEvent.MOUSE_DOWN, goToCoursePage);
			btn.x = btn.width * 0.7;
			btn.y = btn.height * 0.7;
			addChild(btn);
		}
		
		private function goToCoursePage(event:MouseEvent):void {
			var request:URLRequest = new URLRequest(FlashVars.coursepage);
			navigateToURL(request,"_self");
		}
		
		private function resize(event:Event):void {
			positionUserMessage();
			positionLoadBar();
			positionClock();
			positionTitle();
			adjustScoreBar();
			positionSpeakers();
			positionButtons();
			positionPoint();
		}
		
		/*
		######################### SECURITY CHECK ##########################
		*/
		// check website URL for instance of permitted domain
		private function securityCheck():void {
			var sc:LicenceCheck = new LicenceCheck();
			var checked:Boolean = sc.check(this.root.loaderInfo.url);
			if(checked) {
				initLoadBar();
				loadData();
			} else {
				showError(Lang.NOT_LICENSED);
				positionUserMessage();
				_um.addEventListener(MouseEvent.MOUSE_DOWN, visitMattBury);
			}
		}
		
		private function showError(msg:String):void {
			_um = new UserMessage(msg,null,400,18,0xdd0000,0xeeeeee);
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function positionUserMessage():void {
			if(_um) {
				_um.x = stage.stageWidth * 0.5;
				_um.y = stage.stageHeight * 0.5;
			}
		}
		
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
			_xml = _loadXML.xml;
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_xml.name());
			default xml namespace = _smil;
			initInteraction();
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
			_f = new TextFormat(Lang.FONT,20,0,true);
			_length = _xml.body.seq.length();
			//getSeq();
			initClock();
			initTitle();
			initScoreBar();
			initPoint();
			positionPoint();
			initButtons();
			initSpeakers();
			resize(null);
		}
		
		/*
		########################### CLOCK ###########################
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
		########################### TITLE ###########################
		*/
		private function initTitle():void {
			// title
			_titleText = new TextField();
			_titleText.defaultTextFormat = _f;
			_titleText.embedFonts = true;
			_titleText.antiAliasType = AntiAliasType.ADVANCED;
			_titleText.autoSize = TextFieldAutoSize.LEFT;
			_titleText.selectable = false;
			_titleText.mouseEnabled = false;
			_titleText.text = _xml.head.meta.(@name == "Title").@content;
			addChild(_titleText)
		}
		
		private function positionTitle():void {
			if(_titleText) {
				_titleText.x = 35;
				_titleText.y = 5;
			}
		}
		
		/*
		########################### NUMBER ICONS ###########################
		*/
		// create score bar numbers across bottom of stage
		private function initScoreBar():void {
			_numbers = new Array();
			for(var i:uint = 0; i < _length; i++) {
				var icn:NumberIcon = new NumberIcon(i);
				icn.addEventListener(MouseEvent.MOUSE_UP, numberUp);
				icn.buttonMode = true;
				addChild(icn);
				_numbers.push(icn);
			}
		}
		
		// wrap number icons around stage and position from bottom as necessary
		private function adjustScoreBar():void {
			if(_numbers) {
				var len:uint = _numbers.length;
				var spacing:int = 22; // number icon spacing
				var across:int = Math.floor(stage.stageWidth / spacing); // number of icons across
				var down:int = Math.ceil(len / across); // number of icons down
				var posY:int = stage.stageHeight - (spacing * down); // start y position
				var posX:int = 2;
				for(var i:uint = 0; i < len; i++) {
					_numbers[i].x = posX;
					_numbers[i].y = posY;
					if(posX < stage.stageWidth - (spacing * 2)) {
						posX += spacing;
					} else {
						posX = 2;
						posY += spacing;
					}
				}
			}
		}
		
		private function numberUp(event:MouseEvent):void {
			var icn:NumberIcon = event.currentTarget as NumberIcon;
			_index = icn.index;
			deleteContainers();
			initContainers();
			positionContainers();
			positionPoint();
			updateButtons();
		}
		
		/*
		#################################### CURRENT NUMBER ICON POINTER ####################################
		*/
		private function initPoint():void {
			_point = new Sprite();
			_point.graphics.lineStyle(2,0x666666);
			_point.graphics.drawRoundRect(0,0,18,18,5,5);
			addChild(_point);
		}
		
		private function positionPoint():void {
			var len:int = _numbers.length;
			if(_point && _numbers && len > 0 && _index >= 0) {
				_point.x = _numbers[_index].x;
				_point.y = _numbers[_index].y;
			} else {
				_point.x = -30;
				_point.y = -30;
			}
		}
		
		/*
		#################################### NAVIGATION BUTTONS ####################################
		*/
		private function initButtons():void {
			_prev = new Btn("back");
			_prev.addEventListener(MouseEvent.MOUSE_UP, prevUp);
			_prev.mouseChildren = false;
			_prev.buttonMode = true;
			_prev.filters = [_dsf];
			addChild(_prev);
			_next = new Btn("next");
			_next.addEventListener(MouseEvent.MOUSE_UP, nextUp);
			_next.mouseChildren = false;
			_next.buttonMode = true;
			_next.filters = [_dsf];
			addChild(_next);
		}
		
		private function positionButtons():void {
			if(_prev) {
				_prev.x = stage.stageWidth * 0.47;
				_prev.y = _numbers[0].y - 20;
			}
			if(_next) {
				_next.x = stage.stageWidth * 0.53;
				_next.y = _numbers[0].y - 20;
			}
		}
		
		private function updateButtons():void {
			addChild(_prev);
			addChild(_next);
		}
		
		private function prevUp(event:MouseEvent):void {
			if(_index > 0) {
				deleteContainers();
				_index--;
				initContainers();
				positionContainers();
				positionPoint();
				updateButtons();
			}
		}
		
		private function nextUp(event:MouseEvent):void {
			if(_index < _length - 1) {
				deleteContainers();
				_index++;
				initContainers();
				positionContainers();
				positionPoint();
				updateButtons();
			}
		}
		
		/*
		########################## TRAVERSE SMIL DATA TREE #############################
		*/
		// Get all par elements in seq
		// A seq makes up one slide/page of display containers
		/*private function getSeq():Array {
			var pars:Array = new Array();
			var types:Array = new Array(MediaType.ANIMATION,
										MediaType.AUDIO,
										MediaType.IMG,
										MediaType.TEXT,
										MediaType.TEXT_STREAM,
										MediaType.VIDEO);
			var len:uint = _xml.body.seq[_index].par.length();
			trace(len);
			for(var i:uint = 0; i < len; i++) {
				var par:Array = getPar(_xml.body.seq[_index].par[i]);
				pars.push(par);
			}
			return pars;
		}
		
		// A par array provides data for a display container
		// Types of display container are: animation, audio, img, text or video
		// Display containers can display more than one page/slide of like media, 
		// e.g. photo slideshow or video playlist (including captions)
		private function getPar(par:XML):Array {
			var elements:Array = new Array();
			var len:uint = par.children().length();
			for(var i:uint = 0; i < len; i++) {
				var element:Object = getAttributes(par.children()[i]);
				element.mediaType = String(par.@name); // animation/audio/img/text/video
				element.text = String(par.text[i]);
				elements.push(element);
			}
			return elements;
		}
		
		// Convert XML element into object
		private function getAttributes(xml:XML):Object {
			var element:Object = new Object();
			var len:uint = xml.attributes().length();
			for(var i:uint = 0; i < len; i++) {
				var s:String = xml.attributes()[i].name();
				element[s] = xml.attributes()[i];
			}
			return element;
		}*/
		
		/*
		############################# MEDIA CONTAINERS ################################
		*/
		/*private function initContainer():void {
			_containers = new Array();
			var seq:Array = getSeq();
			var len:uint = seq.length;
			for(var i:uint = 0; i < len; i++) {
				var c:TextContainer = new TextContainer(seq[i],stage);
				c.addEventListener(MouseEvent.MOUSE_DOWN, containerDown);
				addChild(c);
				_containers.push(c);
			}
		}*/
		
		private function initContainers():void {
			_containers = new Array();
			var len:uint = _xml.body.seq[_index].par.length();
			for(var i:uint = 0; i < len; i++) {
				var name:String = _xml.body.seq[_index].par[i].@name;
				switch(name){
					
					case MediaType.ANIMATION:
					//initAnimationContainer(_xml.body.seq[_index].par[i]);
					//trace("initAnimationContainer");
					break;
					
					case MediaType.AUDIO:
					//initAudioContainer(_xml.body.seq[_index].par[i]);
					//trace("initAudioContainer");
					break;
					
					case MediaType.IMG:
					initImgContainer(_xml.body.seq[_index].par[i]);
					//trace("initImgContainer");
					break;
					
					case MediaType.TEXT:
					initTextContainer(_xml.body.seq[_index].par[i]);
					//trace("initTextContainer");
					break;
					
					case MediaType.VIDEO:
					//initVideoContainer(_xml.body.seq[_index].par[i]);
					//trace("initVideoContainer");
					break;
					
					default:
					//trace("no match");
					break;
				}
			}
		}
		
		/*private function initAnimationContainer(par:XML):void {
			var c:AnimationContainer = new AnimationContainer(par,stage);
			c.addEventListener(MouseEvent.MOUSE_DOWN, containerDown);
			addChild(c);
			_containers.push(c);
		}
		
		private function initAudioContainer(par:XML):void {
			var c:AudioContainer = new AudioContainer(par,stage);
			c.addEventListener(MouseEvent.MOUSE_DOWN, containerDown);
			addChild(c);
			_containers.push(c);
		}*/
		
		private function initImgContainer(par:XML):void {
			var c:ImgContainer = new ImgContainer(par,stage);
			c.addEventListener(MouseEvent.MOUSE_DOWN, containerDown);
			addChild(c);
			_containers.push(c);
		}
		
		private function initTextContainer(par:XML):void {
			var c:TextContainer = new TextContainer(par,stage);
			c.addEventListener(MouseEvent.MOUSE_DOWN, containerDown);
			addChild(c);
			_containers.push(c);
		}
		
		/*private function initVideoContainer(par:XML):void {
			var c:VideoContainer = new VideoContainer(par,stage);
			c.addEventListener(MouseEvent.MOUSE_DOWN, containerDown);
			addChild(c);
			_containers.push(c);
		}*/
		
		private function positionContainers():void {
			if(_containers.length > 0) {
				// 5 points on stage
				var tl:Point = new Point(stage.stageWidth * 0.25,stage.stageHeight * 0.35); // top left
				var tr:Point = new Point(stage.stageWidth * 0.75,stage.stageHeight * 0.35); // top right
				var bl:Point = new Point(stage.stageWidth * 0.25,stage.stageHeight * 0.65); // bottom left
				var br:Point = new Point(stage.stageWidth * 0.75,stage.stageHeight * 0.65); // bottom right
				var m:Point = new Point(stage.stageWidth * 0.5,stage.stageHeight * 0.5); // middle
				var positions:Array = new Array(tl,tr,bl,br,m);
				var offsetX:int = _containers[0].width * 0.5;
				var offsetY:int = _containers[0].height * 0.5;
				var len:uint = _containers.length;
				for(var i:uint = 0; i < len; i++) {
					_containers[i].x = positions[i].x - offsetX;
					_containers[i].y = positions[i].y - offsetY;
				}
			}
		}
		
		private function containerDown(event:MouseEvent):void {
			var c:Container = event.currentTarget as Container;
			addChild(c);
			updateButtons();
		}
		
		private function deleteContainers():void {
			if(_containers) {
				var len:uint = _containers.length;
				for(var i:uint = 0; i < len; i++) {
					removeChild(_containers[i]);
				}
				_containers = null;
			}
		}
		
		/*
		#################################### TIMER ####################################
		*/
		private function startTimer():void {
			if(!_timer) {
				var count:int = 5;
				_timer = new Timer(1000,count);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);		
				_timer.start();
			}
		}
		
		private function stopTimer():void {
			if(_timer) {
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);	
				_timer = null;
			}
		}
		
		private function timerComplete(event:TimerEvent):void {
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			_timer = null;
		}
		
		/*
		############################ SPEAKERS #############################
		*/
		private function initSpeakers():void {
			_speakers = new Speakers();
			_speakers.addEventListener(MouseEvent.MOUSE_UP, speakersDown);
			_speakers.filters = [_dsf];
			_speakers.mouseChildren = false;
			_speakers.buttonMode = true;
			addChild(_speakers);
		}
		
		private function positionSpeakers():void {
			if(_speakers) {
				_speakers.x = stage.stageWidth * 0.5;
				_speakers.y = stage.stageHeight * 0.5;
			}
		}
		
		private function speakersDown(event:MouseEvent):void {
			_speakers.removeEventListener(MouseEvent.MOUSE_UP, speakersDown);
			removeChild(_speakers);
			_speakers = null;
			_clock.startClock();
			nextUp(null);
		}
		
		/*
		############################ END ACTIVITY #############################
		*/
		private function endActivity():void {
			if(_timer) {
				_timer.stop();
			}
			var msg:String = ".";
			_um = new UserMessage(msg);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.filters = [_dsf];
			_um.addOK = true;
			addChild(_um);
			positionUserMessage();
			_clock.stopClock();
			sendGrade();
		}
		
		/*
		############################ SEND DATA #############################
		*/
		private function sendGrade():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			var obj:Object = new Object(); // create an object to hold data sent to the server
			obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			obj.swfid = FlashVars.swfid; // (int) activity ID
			obj.instance = FlashVars.instance; // (int) Moodle instance ID
			obj.feedback = "."; // (String) optional
			obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			obj.rawgrade = 100;// (Number) grade, normally 0 - 100 but depends on grade book settings
			obj.servicefunction = "Grades.amf_grade_update"; // (String) ClassName.method_name
			_amf.getObject(obj); // send the data to the server
		}
		
		// Connection to AMFPHP succeeded
		// Manage returned data and inform user
		private function gotDataHandler(event:Event):void {
			// Clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			// Check if grade was sent successfully
			switch(_amf.obj.result) {
				//
				case "SUCCESS":
				_um.addMessage(Lang.GRADE_SENT);
				break;
				//
				case "NO_PERMISSION":
				_um.addMessage(_amf.obj.message);
				break;
				//
				default:
				_um.addMessage("Unknown error.");
			}
			addChild(_um);
		}
		
		// Display server errors
		private function faultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			var msg:String = "Error: ";
			for(var s:String in _amf.obj.info) {
				msg += "\n" + s + "=" + _amf.obj.info[s];
			}
			_um.addMessage(msg);
		}
		
		private function umClickedHandler(event:Event):void {
			_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
			removeChild(_um);
			_um = null;
		}
	}
}
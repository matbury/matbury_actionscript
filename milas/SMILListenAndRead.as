/*
	XMLListenAndRead Multimedia Interactive Learning Application (MILA).
	Copyright © 2011 Matt Bury All rights reserved.
	http://matbury.com/
	matbury@gmail.com
*/
package com.matbury.milas {
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.filters.DropShadowFilter;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	import com.matbury.Clock;
	import com.matbury.CMenu;
	import com.matbury.LoadXML;
	import com.matbury.SMILImage;
	import com.matbury.UserMessage;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.NumberIcon;
	import com.matbury.sam.gui.Pointer;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.Tick;
	
	public class SMILListenAndRead extends Sprite {
		
		private var _version:String = "2011.11.05";
		private var _amf:Amf;
		private var _xml:XML;
		private var _smil:Namespace;
		private var _loadXML:LoadXML;
		private var _length:uint;
		private var _clock:Clock;
		private var _clockVisible:Boolean = true;
		private var _dsf:DropShadowFilter;
		private var _speakers:Speakers;
		private var _pointer:Pointer;
		private var _f:TextFormat;
		private var _numbers:Array;
		private var _offsetY:int = 0;
		private var _read:Array;
		private var _point:Sprite;
		private var _completed:int;
		private var _title:TextField;
		private var _loadBar:LoadBar;
		private var _text:TextField;
		private var _textContainer:Sprite;
		private var _fontSize:int = 17;
		private var _bg:Sprite;
		private var _sideBar:Sprite;
		private var _image:SMILImage;
		private var _bck:Btn;
		private var _stp:Btn;
		private var _ply:Btn;
		private var _nxt:Btn;
		private var _down:Btn;
		private var _up:Btn;
		private var _page:int = 0;
		private var _playing:Boolean = false;
		private var _position:int;
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _cmenu:CMenu;
		private var _um:UserMessage;
		private var _end:Btn;
		
		public function SMILListenAndRead() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			initCMenu();
			/*
			//FlashVars.xmlurl = "../tokillamockingbird/to_kill_a_mocking_bird_01.smil";
			FlashVars.xmlurl = "../alices_adventures_in_wonderland/xml/alices_adventures_in_wonderland_ch_01.smil";
			FlashVars.moodledata = "../";
			FlashVars.instance = 229;
			FlashVars.swfid = 46;
			initLoadBar();
			positionLoadBar();
			loadData();
			*/
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			stage.addEventListener(Event.RESIZE, resize);
			licenceCheck();//
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
		}
		
		private function resize(event:Event):void {
			positionLoadBar();
			positionText();
			positionSideBar();
			adjustSideBar();
			positionClock();
			positionControls();
			positionScoreBar();
			positionPoint();
			positionPointer();
			positionImage();
			positionEndAndSend();
			positionSpeakers();
			positionUserMessage();
		}
		
		/*
		######################### SECURITY CHECK ##########################
		*/
		// check website URL for instance of permitted domain
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
		
		private function deleteUserMessage():void {
			if(_um) {
				removeChild(_um);
				_um = null;
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
			if(this.root.loaderInfo.parameters.fontsize) {
				_fontSize = int(this.root.loaderInfo.parameters.fontsize);
			}
			//
			_f = new TextFormat(Lang.FONT,_fontSize,0,true);
			_length = _xml.body.seq.length();
			if(_length < 1) {
				showError(Lang.INCORRECT_DATA);
			}
			//
			_read = new Array();
			for(var i:uint = 0; i < _length; i++) {
				_read.push(0);
			}
			//
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			initText();
			initSideBar();
			initClock();
			initScoreBar();
			initPoint();
			initImage();
			initControls();
			initUserMessage();
			initSpeakers();
			resize(null);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
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
		
		/*
		########################## TEXT AREA #############################
		*/
		private function initText():void {
			_textContainer = new Sprite();
			_textContainer.mouseChildren = false;
			_textContainer.buttonMode = true;
			addChild(_textContainer);
			_text = new TextField();
			//_text.mouseWheelEnabled = true;
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.selectable = false;
			_text.defaultTextFormat = _f;
			_text.multiline = true;
			_text.wordWrap = true;
			_textContainer.addChild(_text);
			_text.htmlText = convertURLs(_xml.body.seq[_page].par.(@id == "answer").text);
			_textContainer.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
		}
		
		private function convertURLs(txt:String):String {
			var txts:Array = txt.split("../../");
			var len:uint = txts.length;
			var newTxt:String = txts[0];
			for(var i:uint = 1; i < len; i++) {
				newTxt += FlashVars.moodledata + txts[i];
			}
			return newTxt;
		}
		
		private function positionText():void {
			if(_text) {
				_text.x = stage.stageWidth * 0.5;
				_text.width = (stage.stageWidth * 0.5) - 15;
			}
		}
		
		private function startDragHandler(event:MouseEvent):void {
			_textContainer.removeEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
			var dragRect:Rectangle = new Rectangle(_textContainer.x, -(_textContainer.height - stage.stageHeight + 30), 0, _textContainer.height - stage.stageHeight + 50);
			_textContainer.startDrag(false,dragRect);
		}
		
		private function stopDragHandler(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
			_textContainer.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
			_textContainer.stopDrag();
			adjustSideBar();
		}
		
		/*
		########################## TEXT SIDE BAR #############################
		*/
		private function initSideBar():void {
			_bg = new Sprite();
			_bg.graphics.lineStyle(4,0xDDDDDD,1,true);
			_bg.graphics.lineTo(0,stage.stageHeight);
			addChild(_bg);
			//
			_sideBar = new Sprite();
			_sideBar.graphics.lineStyle(4,0x888888,1,true,LineScaleMode.VERTICAL,CapsStyle.ROUND);
			_sideBar.graphics.lineTo(0,stage.stageHeight);
			addChild(_sideBar);
		}
		
		private function positionSideBar():void {
			if(_bg && _sideBar) {
				_bg.x = stage.stageWidth - 2;
				_bg.y = 0;
				_bg.height = stage.stageHeight;
				_sideBar.height = stage.stageHeight * (stage.stageHeight / _textContainer.height);
				_sideBar.y = 0;
				_sideBar.x = stage.stageWidth - 2;
				_textContainer.y = 0;
			}
		}
		
		// calculate _sideBar position as a ratio of _text position
		private function adjustSideBar():void {
			if(_sideBar) {
				_sideBar.y = -(stage.stageHeight - _sideBar.height) * (_textContainer.y / (_textContainer.height - stage.stageHeight));
			}
		}
		
		// scroll text up and down with cursor keys
		private function keyDownHandler(event:KeyboardEvent):void {
			var key:int = event.keyCode;
			if(key == 38 && _textContainer.y < 5) { // up arrow key
				_textContainer.y += 23;
			}
			if(key == 40 && _textContainer.y > -_textContainer.height + stage.stageHeight - 30) { // down arrow key
				_textContainer.y += -23;
			}
			adjustSideBar();
		}
		
		/*
		########################## CLOCK #############################
		*/
		private function initClock():void {
			_clock = new Clock();
			addChild(_clock);
		}
		
		private function positionClock():void {
			if(_clock) {
				_clock.x = _clock.width + 7;
				_clock.y = 0;
			}
		}
		
		/*
		########################## SCORE BAR #############################
		*/
		private function initScoreBar():void {
			_numbers = new Array();
			for(var i:uint = 0; i < _length; i++) {
				var icn:NumberIcon = new NumberIcon(i);
				addChild(icn);
				_numbers.push(icn);
			}
		}
		
		// wrap number icons around stage and position from bottom as necessary
		private function positionScoreBar():void {
			if(_numbers) {
				var len:uint = _numbers.length;
				var spacing:int;
				if(len > 0) {
					spacing = _numbers[0].width + 2; // number icon spacing
				} else {
					spacing = 22;
				}
				var across:int = Math.floor((stage.stageWidth * 0.5) / spacing); // number of icons across
				var down:int = Math.ceil(len / across); // number of icons down
				var posY:int = stage.stageHeight - (spacing * down); // start y position
				var posX:int = 2;
				for(var i:uint = 0; i < len; i++) {
					_numbers[i].x = posX;
					_numbers[i].y = posY;
					if(posX < (stage.stageWidth * 0.5) - (spacing * 2)) {
						posX += spacing;
					} else {
						posX = 2;
						posY += spacing;
					}
				}
			}
		}
		
		private function initPoint():void {
			_point = new Sprite();
			_point.graphics.lineStyle(2,0x666666);
			_point.graphics.drawRoundRect(0,0,18,18,5,5);
			addChild(_point);
		}
		
		private function positionPoint():void {
			var len:int = _numbers.length;
			if(_point && _numbers && len > 0) {
				_point.x = _numbers[_page].x;
				_point.y = _numbers[_page].y;
			}
		}
		
		/*
		########################## PLAYER BUTTONS #############################
		*/
		private function initControls():void {
			_bck = new Btn("back");
			_bck.addEventListener(MouseEvent.MOUSE_UP, bckUp);
			addChild(_bck);
			_stp = new Btn("stop");
			_stp.addEventListener(MouseEvent.MOUSE_UP, stpUp);
			addChild(_stp);
			_ply = new Btn("play");
			_ply.addEventListener(MouseEvent.MOUSE_UP, plyUp);
			_ply.addEventListener(MouseEvent.MOUSE_UP, deletePointer);
			addChild(_ply);
			_nxt = new Btn("next");
			_nxt.addEventListener(MouseEvent.MOUSE_UP, nxtUp);
			addChild(_nxt);
			_down = new Btn("down");
			_down.addEventListener(MouseEvent.MOUSE_DOWN, downDown);
			addChild(_down);
			_up = new Btn("up");
			_up.addEventListener(MouseEvent.MOUSE_DOWN, upDown);
			addChild(_up);
		}
		
		private function positionControls():void {
			var posX:int = stage.stageWidth * 0.2;
			var posY:int = stage.stageHeight * 0.9;
			if(_bck) {
				_bck.x = posX;
				posX += _bck.width + 4;
				_bck.y = posY;
			}
			if(_stp) {
				_stp.x = posX;
				posX += _stp.width + 4;
				_stp.y = posY;
			}
			if(_ply) {
				_ply.x = posX;
				posX += _ply.width + 4;
				_ply.y = posY;
			}
			if(_nxt) {
				_nxt.x = posX;
				posX += _nxt.width + 4;
				_nxt.y = posY;
			}
			if(_down) {
				_down.x = stage.stageWidth * 0.72;
				_down.y = stage.stageHeight - 20;
			}
			if(_up) {
				_up.x = stage.stageWidth * 0.78;
				_up.y = stage.stageHeight - 20;
			}
		}
		
		private function bckUp(event:MouseEvent):void {
			if(_page > 0) {
				_page--;
				deleteUserMessage();
				stopSound();
				_position = 0;
				playSound();
				deleteImage();
				initImage();
				positionImage();
				_text.htmlText = convertURLs(_xml.body.seq[_page].par.(@id == "answer").text);
				positionSideBar();
				positionPoint();
			}
		}
		
		private function stpUp(event:MouseEvent):void {
			stopSound();
		}
		
		private function plyUp(event:MouseEvent):void {
			if(_playing) {
				pauseSound();
			} else {
				playSound();
			}
		}
		
		private function nxtUp(event:MouseEvent):void {
			if(_page < _length - 1) {
				_page++;
				deleteUserMessage();
				stopSound();
				_position = 0;
				playSound();
				deleteImage();
				initImage();
				positionImage();
				_text.htmlText = convertURLs(_xml.body.seq[_page].par.(@id == "answer").text);
				positionSideBar();
				positionPoint();
			}
		}
		
		private function downDown(event:MouseEvent):void {
			_down.removeEventListener(MouseEvent.MOUSE_DOWN, downDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, downUp);
			this.addEventListener(Event.ENTER_FRAME, scrollDown);
		}
		
		private function downUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, downUp);
			_down.addEventListener(MouseEvent.MOUSE_DOWN, downDown);
			this.removeEventListener(Event.ENTER_FRAME, scrollDown);
		}
		
		private function scrollDown(event:Event):void {
			if(_textContainer.y > -_textContainer.height + stage.stageHeight - 30) { // down arrow key
				_textContainer.y -= 8;
			}
			adjustSideBar();
		}
		
		private function upDown(event:MouseEvent):void {
			_up.removeEventListener(MouseEvent.MOUSE_DOWN, upDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, upUp);
			this.addEventListener(Event.ENTER_FRAME, scrollUp);
		}
		
		private function upUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, upUp);
			_up.addEventListener(MouseEvent.MOUSE_DOWN, upDown);
			this.removeEventListener(Event.ENTER_FRAME, scrollUp);
		}
		
		private function scrollUp(event:Event):void {
			if(_textContainer.y < 5) { // up arrow key
				_textContainer.y += 8;
			}
			adjustSideBar();
		}
		
		/*
		########################## SOUND PLAYBACK #############################
		*/
		private function playSound():void {
			var url:String = FlashVars.moodledata + _xml.body.seq[_page].par.(@id == "answer").audio.@src;
			var request:URLRequest = new URLRequest(url);
			_sound = new Sound(request);
			_sound.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			_sound.addEventListener(Event.COMPLETE, soundLoaded);
			_channel = _sound.play(_position);
			_channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			_ply.char = "pause";
			_playing = true;
			_read[_page] = 1;
		}
		
		private function ioError(event:IOErrorEvent):void {
			// no sound! clean up
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			_sound.removeEventListener(Event.COMPLETE, soundLoaded);
			showError(Lang.SOUND_LOAD_FAILED);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.addOK = true; // add OK button
			positionUserMessage();
		}
		
		private function soundLoaded(event:Event):void {
			// clean up
			_sound.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			_sound.removeEventListener(Event.COMPLETE, soundLoaded);
		}
		
		private function soundComplete(event:Event):void {
			_ply.char = "play";
			_position = 0;
			_playing = false;
			var tick:Tick = new Tick();
			tick.y += 20;
			_numbers[_page].addChild(tick);
			_read[_page] = 5;
			updateScore();
		}
		
		private function updateScore():void {
			// Count the number of ticks added to numbers
			var len:uint = _numbers.length;
			var completed:uint = 0;
			for(var i:uint = 0; i < len; i++) {
				if(_numbers[i].numChildren > 2) {
					completed++;
				}
			}
			_completed = completed;
			if(completed >= len) {
				endActivity();
			}
		}
		
		private function pauseSound():void {
			if(_playing) {
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				_position = _channel.position;
				_channel.stop();
				_ply.char = "play";
				_playing = false;
			}
		}
		
		private function stopSound():void {
			if(_playing) {
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				_channel.stop();
				_position = 0;
				_ply.char = "play";
				_playing = false;
			}
		}
		
		/*
		########################## IMAGE #############################
		*/
		private function initImage():void {
			_image = new SMILImage(_page,_xml.body.seq[_page],FlashVars.moodledata);
			_image.showAnswerImage();
			addChildAt(_image,0);
		}
		
		private function positionImage():void {
			if(_image) {
				_image.x = stage.stageWidth * 0.25;
				_image.y = stage.stageHeight * 0.5;
			}
		}
		
		private function deleteImage():void {
			if(_image) {
				removeChild(_image);
				_image = null;
			}
		}
		
		/*
		########################## POINTER #############################
		*/
		private function initPointer():void {
			_pointer = new Pointer();
			_pointer.rotation = 180;
			addChild(_pointer);
		}
		
		private function positionPointer():void {
			if(_pointer && _ply) {
				_pointer.x = _ply.x;
				_pointer.y = _ply.y;
			}
		}
		
		private function deletePointer(event:MouseEvent):void {
			if(_pointer && _ply) {
				_ply.removeEventListener(MouseEvent.MOUSE_UP, deletePointer);
				removeChild(_pointer);
				_pointer = null;
			}
		}
		
		// Give user text scrolling instructions
		private function initUserMessage():void {
			_um = new UserMessage(Lang.SCROLL_KEYS,null,300);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.addOK = true; // add OK button
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		/*
		############################ SPEAKERS #############################
		*/
		// Tell user to expect audio
		private function initSpeakers():void {
			_speakers = new Speakers();
			_speakers.addEventListener(MouseEvent.MOUSE_UP, speakersDown);
			addChild(_speakers);
		}
		
		private function positionSpeakers():void {
			if(_speakers) {
				_speakers.x = stage.stageWidth * 0.5;
				_speakers.y = stage.stageHeight * 0.5;
			}
		}
		
		// remove poster and start activity clock
		private function speakersDown(event:MouseEvent):void {
			_speakers.removeEventListener(MouseEvent.MOUSE_UP, speakersDown);
			removeChild(_speakers);
			_speakers = null;
			_clock.startClock();
			initPointer();
			positionPointer();
			initEndAndSend();
			positionEndAndSend();
		}
		
		/*
		############################ END ACTIVITY BUTTON #############################
		*/
		// User can click this button to stop the dictation and send the results
		// to the grade book
		private function initEndAndSend():void {
			_end = new Btn(Lang.SUBMIT);
			_end.addEventListener(MouseEvent.MOUSE_UP, endUpHandler);
			addChild(_end);
		}
		
		private function positionEndAndSend():void {
			if(_end) {
				_end.x = stage.stageWidth * 0.5 - (_end.width * 0.55);
				_end.y = stage.stageHeight - (_end.height + 10);
			}
		}
		
		private function deleteEndAndSend():void {
			if(_end) {
				removeChild(_end);
				_end = null;
			}
		}
		
		private function endUpHandler(event:MouseEvent):void {
			_end.removeEventListener(MouseEvent.MOUSE_UP, endUpHandler);
			deleteEndAndSend();
			endActivity();
		}
		
		private function endActivity():void {
			pauseSound();
			deleteEndAndSend();
			var msg:String = Lang.YOUVE_COMPLETED + " " + _completed + " " + Lang.PAGES + ".";
			_um = new UserMessage(msg);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.filters = [_dsf];
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
			obj.feedback = "<p>" + Lang.COMPLETED + _read.toString() + "</p><p>Key: 0 = not read, 1 = started, 5 = finished.</p>"; // (String) optional
			obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			obj.rawgrade = calculateGrade(); //_completed / _length; // (Number) grade, normally 0 - 100 but depends on grade book settings
			obj.servicefunction = "Grades.amf_grade_update"; // (String) ClassName.method_name
			_amf.getObject(obj); // send the data to the server
			_um.addMessage(Lang.COMPLETED + _read.toString() + "\n" + Lang.GRADE + " " + obj.rawgrade + "%\nKey: 0 = not read, 1 = started, 2 = finished.");
		}
		
		private function calculateGrade():Number {
			var max:int = _length * 5;
			var score:int = 0;
			for(var i:uint = 0; i < _length; i++) {
				var n:int = _read[i];
				score += n;
			}
			var percent:int = score / max * 100;
			return percent;
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
			} catch(e:Error) {
				_um.addMessage(Lang.GRADE_UNKNOWN + "\n" + Lang.PHP_VERSION_ERROR);
			}
			addChild(_um);
		}
		
		private function faultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			var msg:String = Lang.ERROR;
			for(var s:String in _amf.obj.info) { // trace out returned data
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
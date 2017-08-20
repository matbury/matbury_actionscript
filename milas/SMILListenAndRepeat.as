/*
	XMLListenAndRepeat Multimedia Interactive Learning Application (MILA).
	Copyright © 2012 Matt Bury All rights reserved.
	http://matbury.com/
	matbury@gmail.com
	Requires Flash Player 10+
*/
package com.matbury.milas {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.media.Microphone;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import com.matbury.BlankWord;
	import com.matbury.CheckString;
	import com.matbury.Clock;
	import com.matbury.CMenu;
	import com.matbury.SMILImage;
	import com.matbury.LoadXML;
	import com.matbury.ShuffledIndex;
	import com.matbury.UserMessage;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.milas.UpdateGradeURLVars;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.Cross;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.NumberIcon;
	import com.matbury.sam.gui.NumberIconFrame;
	import com.matbury.sam.gui.Pointer;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.TextColors;
	import com.matbury.sam.gui.Tick;
	// WAV mic recorder
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.bytearray.micrecorder.MicRecorder;
	import org.bytearray.micrecorder.events.RecordingEvent;
	// WAV playback
	import org.as3wavsound.WavSoundChannel;
	import org.as3wavsound.WavSound;
	
	public class SMILListenAndRepeat extends Sprite {
		
		private var _version:String = "2014.04.24";
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _xml:XML;
		private var _smil:Namespace;
		private var _amf:Amf;
		private var _sg:UpdateGradeURLVars;
		private var _obj:Object; // grade data object
		private var _length:uint;
		private var _clock:Clock;
		private var _clockVisible:Boolean = true;
		private var _dsf:DropShadowFilter;
		private var _speakers:Speakers;
		private var _si:ShuffledIndex;
		private var _shuffle:Boolean = true;
		private var _currentIndex:int = 0;
		private var _answers:Array;
		private var _completed:int = 0;
		private var _numbers:Array;
		private var _sentence:String;
		private var _text:TextField;
		private var _mp3:String;
		private var _image:SMILImage;
		private var _next:Btn;
		private var _prev:Btn;
		private var _play:Btn;
		private var _stretched:Btn;
		private var _userPlay:Btn;
		private var _userRecord:Btn;
		private var _pointer:Pointer;
		private var _f:TextFormat;
		private var _timer:Timer;
		private var _title:TextField;
		private var _um:UserMessage;
		private var _end:Btn;
		private var _menu:CMenu;
		//
		private var _recorder:MicRecorder;
		private var _mic:Microphone;
		private var _gain:int = 100;
		private var _channel:WavSoundChannel;
		private var _bock:Bock;
		private var _duration:int;
		
		public function SMILListenAndRepeat() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			/* 
			//FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects.smil";
			FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects_short.smil";
			//FlashVars.xmlurl = "../animals/xml/animals.smil";
			FlashVars.moodledata = "../";
			initLoadBar();
			positionLoadBar();
			loadData();
			*/
			securityCheck();
		}
		
		private function initCMenu():void {
			_menu = new CMenu(_version);
			addChild(_menu);
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
				positionLoadBar();
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
		############################ PRELOADER ############################
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
			_length = _xml.body.seq.length();
			if(_length > 2) {
				initInteraction();
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
			_f = new TextFormat("Trebuchet MS",20,0,true);
			if(this.root.loaderInfo.parameters.shuffle) {
				if(this.root.loaderInfo.parameters.shuffle == "false") {
					_shuffle = false;
				}
			}
			_si = new ShuffledIndex(_length,_shuffle);
			_answers = new Array();
			for(var i:uint = 0; i < _length; i++) {
				_answers.push(0); // set all to not answered
			}
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			_bock = new Bock();
			initClock();
			initScoreBar();
			initPlay();
			initStretched();
			initUserPlay();
			initUserRecord();
			initNext();
			initPrev();
			nextImage();
			nextText();
			initEndAndSend();
			initSpeakers();
			initMic();
			resize(null);
		}
		
		private function resize(event:Event):void {
			positionClock();
			adjustScoreBar();
			positionNumberIconShadow();
			positionPlay();
			positionStretched();
			positionUserPlay();
			positionUserRecord();
			positionNext();
			positionImage();
			positionPrev();
			positionText();
			positionEndAndSend();
			positionPointer();
			positionSpeakers();
			positionUserMessage();
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
		
		private function initClock():void {
			_clock = new Clock();
			addChild(_clock);
		}
		
		private function positionClock():void {
			if(_clock) {
				_clock.x = stage.stageWidth;
				_clock.y = 10;
			}
		}
		
		private function initScoreBar():void {
			_numbers = new Array();
			for(var i:uint = 0; i < _length; i++) {
				var icn:NumberIcon = new NumberIcon(i);
				icn.addEventListener(MouseEvent.CLICK, icnClick);
				icn.buttonMode = true;
				addChild(icn);
				_numbers.push(icn);
			}
		}
		
		// wrap number icons around stage and position from bottom as necessary
		private function adjustScoreBar():void {
			if(_numbers) {
				var len:uint = _numbers.length;
				var spacing:int;
				if(len > 0) {
					spacing = _numbers[0].width + 2; // number icon spacing
				} else {
					spacing = 22;
				}
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
		private function positionNumberIconShadow():void {
			if(_numbers) {
				// Remove all shadows
				var len:uint = _numbers.length;
				for(var i:uint = 0; i < len; i++) {
					_numbers[i].filters = [];
				}
				// Put shadow on current NumberIcon
				_numbers[_currentIndex].filters = [_dsf];
			}
		}
		
		private function icnClick(event:MouseEvent):void {
			var icn:NumberIcon = event.currentTarget as NumberIcon;
			_currentIndex = icn.index;
			nextSentence();
		}
		
		/*
		############################ NEXT BUTTON ############################
		*/
		private function initNext():void {
			_next = new Btn("next");
			_next.addEventListener(MouseEvent.CLICK, nextUp);
			addChild(_next);
		}
		
		private function positionNext():void {
			if(_next) {
				_next.x = (stage.stageWidth * 0.5) + (_next.width * 2.1);
				_next.y = stage.stageHeight * 0.5;
			}
		}
		
		private function deleteNext():void {
			if(_next) {
				_next.removeEventListener(MouseEvent.CLICK, nextUp);
				removeChild(_next);
				_next = null;
			}
		}
		
		private function nextUp(event:MouseEvent):void {
			_currentIndex++;
			if(_currentIndex >= _length) {
				_currentIndex = 0;
			}
			nextSentence();
		}
		
		/*
		########################### PREVIOUS BUTTON ###########################
		*/
		private function initPrev():void {
			_prev = new Btn("back");
			_prev.addEventListener(MouseEvent.CLICK, prevUp);
			addChild(_prev);
		}
		
		private function positionPrev():void {
			if(_prev) {
				_prev.x = (stage.stageWidth * 0.5) - (_prev.width * 2.1);
				_prev.y = stage.stageHeight * 0.5;
			}
		}
		
		private function deletePrev():void {
			if(_prev) {
				_prev.removeEventListener(MouseEvent.CLICK, prevUp);
				removeChild(_prev);
				_prev = null;
			}
		}
		
		private function prevUp(event:MouseEvent):void {
			_currentIndex--;
			if(_currentIndex < 0) {
				_currentIndex = _length - 1;
			}
			nextSentence();
		}
		
		/*
		########################### PLAY BUTTON ###########################
		*/
		private function initPlay():void {
			_play = new Btn("play");
			_play.addEventListener(MouseEvent.MOUSE_DOWN, playDown);
			addChild(_play);
		}
		
		private function positionPlay():void {
			if(_play) {
				_play.x = (stage.stageWidth * 0.5) - (_play.width * 0.7);
				_play.y = stage.stageHeight * 0.5;
			}
		}
		
		private function playDown(event:MouseEvent):void {
			_image.playAnswer();
		}
		
		private function deletePlay():void {
			if(_play) {
				_play.removeEventListener(MouseEvent.MOUSE_DOWN, playDown);
				removeChild(_play);
				_play = null;
			}
		}
		
		/*
		########################## STRETCHED BUTTON ##########################
		*/
		private function initStretched():void {
			_stretched = new Btn("stretched");
			_stretched.addEventListener(MouseEvent.MOUSE_DOWN, stretchedDown);
			addChild(_stretched);
		}
		
		private function positionStretched():void {
			if(_stretched) {
				_stretched.x = (stage.stageWidth * 0.5) + (_stretched.width * 0.7);
				_stretched.y = stage.stageHeight * 0.5;
			}
		}
		
		private function stretchedDown(event:MouseEvent):void {
			_image.playAnswerStretched();
		}
		
		private function deleteStretched():void {
			if(_stretched) {
				_stretched.removeEventListener(MouseEvent.MOUSE_DOWN, stretchedDown);
				removeChild(_stretched);
				_stretched = null;
			}
		}
		
		/*
		########################### USER RECORD BUTTON ###########################
		*/
		private function initUserRecord():void {
			_userRecord = new Btn("record");
			_userRecord.addEventListener(MouseEvent.MOUSE_DOWN, userRecordDown);
			addChild(_userRecord);
		}
		
		private function positionUserRecord():void {
			if(_userRecord) {
				_userRecord.x = (stage.stageWidth * 0.5) - (_userRecord.width * 0.7);
				_userRecord.y = stage.stageHeight * 0.8;
			}
		}
		
		private function userRecordDown(event:MouseEvent):void {
			_image.addEventListener(Event.SOUND_COMPLETE, imageSoundComplete);
			_image.playAnswer();
			deletePointer();
		}
		
		private function imageSoundComplete(event:Event):void {
			_image.removeEventListener(Event.SOUND_COMPLETE, imageSoundComplete);
			startRecording();
		}
		
		private function deleteUserRecord():void {
			if(_userRecord) {
				removeChild(_userRecord);
				_userRecord = null;
			}
		}
		
		/*
		########################### USER RECORD BUTTON ###########################
		*/
		private function initPointer():void {
			_pointer = new Pointer();
			_pointer.rotation = 90;
			addChild(_pointer);
		}
		
		private function positionPointer():void {
			if(_pointer) {
				_pointer.x = _userRecord.x;
				_pointer.y = _userRecord.y;
			}
		}
		
		private function deletePointer():void {
			if(_pointer) {
				removeChild(_pointer);
				_pointer = null;
			}
		}
		
		/*
		########################### USER PLAY BUTTON ###########################
		*/
		private function initUserPlay():void {
			_userPlay = new Btn("play");
			_userPlay.addEventListener(MouseEvent.MOUSE_DOWN, userPlayDown);
			addChild(_userPlay);
		}
		
		private function positionUserPlay():void {
			if(_userPlay) {
				_userPlay.x = (stage.stageWidth * 0.5) + (_userPlay.width * 0.7);
				_userPlay.y = stage.stageHeight * 0.8;
			}
		}
		
		private function userPlayDown(event:MouseEvent):void {
			playMic();// play user recording
		}
		
		private function deleteUserPlay():void {
			if(_userPlay) {
				_userPlay.removeEventListener(MouseEvent.MOUSE_DOWN, userPlayDown);
				removeChild(_userPlay);
				_userPlay = null;
			}
		}
		
		/*
		############################# (DE)ACTIVATE MICROPHONE #############################
		*/
		private function initMic():void {
			_mic = Microphone.getMicrophone();
			_mic.setUseEchoSuppression(true);
			_mic.setLoopBack(true);
			_mic.gain = _gain;
		}
		
		private function activateMic():void {
			if(_mic) {
				_mic.setLoopBack(true);
			}
		}
		
		private function deactivateMic():void {
			if(_mic) {
				_mic.setLoopBack(false);
			}
		}
		
		/*
		########################### RECORD MIC INPUT ###########################
		*/
		private function startRecording():void {
			if(!_userRecord.recording) {
				_userRecord.recording = true; // change icon to red
				_bock.play();
				recordMic();
				startTimer();
			} else {
				_userRecord.recording = false; // change icon to white
			}
		}
		
		private function stopRecording():void {
			if(_userRecord.recording) {
				_userRecord.recording = false; // change icon to white
				_bock.play();
				if(_recorder) {
					_recorder.stop();
					playMic();
				}
			} else {
				_userRecord.recording = true; // change icon to red
			}
		}
		
		private function startTimer():void {
			_duration = _image.duration * 3; // Give users 3xs playback duration to repeat
			_timer = new Timer(_duration,1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			_timer.start();
		}
		
		private function timerComplete(event:TimerEvent):void {
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			_timer = null;
			stopRecording();
		}
		
		private function recordMic():void {
			//MicRecorder(encoder:IEncoder, microphone:Microphone=null, gain:uint=100, rate:uint=44, silenceLevel:uint=0, timeOut:uint=4000)
			var encoder:WaveEncoder = new WaveEncoder(_gain * 0.01);
			_recorder = new MicRecorder(encoder,_mic,_gain,44,0,4000);
			_recorder.record();
		}
		
		// Playback mic recording
		private function playMic():void {
			if(_recorder && !_userRecord.recording && !_channel) {
				var player:WavSound = new WavSound(_recorder.output);
				_channel = player.play();
				_channel.addEventListener(Event.SOUND_COMPLETE, micPlayComplete);
			}
		}
		
		private function micPlayComplete(event:Event):void {
			_channel.removeEventListener(Event.SOUND_COMPLETE, micPlayComplete);
			_channel = null;
			// Add tick to current number icon
			if(_numbers[_currentIndex].numChildren < 3) { // only add 1 tick!
				var tick:Tick = new Tick();
				tick.y = tick.height;
				_numbers[_currentIndex].addChild(tick);
			}
			_answers[_currentIndex] = 2;
			checkScore();
		}
		
		/*
		############################## IMAGE ##############################
		*/
		private function nextImage():void {
			var index:uint = _si.ind[_currentIndex];
			_image = new SMILImage(index,_xml.body.seq[index],FlashVars.moodledata);
			_image.showAnswerImage();
			_image.addEventListener(MouseEvent.MOUSE_DOWN, imageDown);
			//_image.addEventListener(Event.SOUND_COMPLETE, imageSoundComplete);
			addChild(_image);
		}
		
		private function positionImage():void {
			if(_image) {
				_image.x = stage.stageWidth * 0.5;
				_image.y = stage.stageHeight * 0.25;
			}
		}
		
		private function deleteImage():void {
			if(_image) {
				_image.removeEventListener(MouseEvent.MOUSE_DOWN, imageDown);
				removeChild(_image);
				_image = null;
			}
		}
		
		private function imageDown(event:MouseEvent):void {
			var image:SMILImage = event.currentTarget as SMILImage;
			image.playAnswer();
		}
		
		/*
		############################ NEXT SENTENCE ############################
		*/
		private function nextSentence():void {
			// clear elements
			deleteText();
			deleteImage();
			// new elements
			nextText();
			nextImage();
			resize(null);
		}
		
		// split time string into words and display next to clock
		private function nextText():void {
			var posX:Number = 0;
			var posY:Number = 0;
			var index:uint = _si.ind[_currentIndex];
			try {
				_sentence = _xml.body.seq[index].par.(@id == "answer").text[0];
			} catch(e:Error) {
				_sentence = "";
			}
			_text = new TextField();
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.defaultTextFormat = _f;
			_text.embedFonts = true;
			_text.multiline = false;
			_text.text = _sentence;
			addChild(_text);
		}
		
		private function positionText():void {
			if(_text) {
				if(_text.width > stage.stageWidth * 0.85) {
					_text.wordWrap = true;
					_text.width = stage.stageWidth * 0.85;
				}
				_text.x = (stage.stageWidth * 0.5) - (_text.width * 0.5);
				_text.y = (stage.stageHeight * 0.65) - (_text.height * 0.5);
			}
		}
		
		// delete all the words and arrays
		private function deleteText():void {
			if(_text) {
				removeChild(_text);
				_text = null;
			}
		}
		
		/*
		############################ SPEAKERS #############################
		*/
		private function initSpeakers():void {
			_speakers = new Speakers("Please get ready to\nrecord and listen.");
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
		
		private function deleteSpeakers():void {
			if(_speakers) {
				_speakers.removeEventListener(MouseEvent.MOUSE_UP, speakersDown);
				removeChild(_speakers);
				_speakers = null;
			}
		}
		
		private function speakersDown(event:MouseEvent):void {
			deleteSpeakers();
			initPointer();
			positionPointer();
			_clock.startClock();
		}
		
		/*
		############################ END ACTIVITY BUTTON #############################
		*/
		// User can click this button to stop the dictation and send the results
		// to the grade book
		private function initEndAndSend():void {
			_end = new Btn(Lang.SUBMIT);
			_end.addEventListener(MouseEvent.MOUSE_UP, endUp);
			addChild(_end);
		}
		
		private function positionEndAndSend():void {
			if(_end) {
				_end.x = stage.stageWidth * 0.5;
				_end.y = stage.stageHeight - (_end.height + 15);
			}
		}
		
		private function deleteEndAndSend():void {
			if(_end) {
				removeChild(_end);
				_end = null;
			}
		}
		
		private function endUp(event:MouseEvent):void {
			// Only end if it isn't recording
			if(!_userRecord.recording) {
				_end.removeEventListener(MouseEvent.MOUSE_UP, endUp);
				deleteEndAndSend();
				checkScore();
				endActivity();
				sendGrade();
			}
		}
		
		/*
		######################## CHECK ITEMS COMPLETED ########################
		*/
		private function checkScore():void {
			var len:uint = _answers.length;
			_completed = 0;
			// Count completed items
			for(var i:uint = 0; i < len; i++) {
				if(_answers[i] == 2) {
					_completed++;
				}
			}
			// If all items have been completed, end and save grade
			/*if(_completed >= len) {
				endActivity();
				sendGrade();
			}*/
		}
		
		private function endActivity():void {
			_clock.stopClock();
			// Display score
			var percent:int = Math.floor(_completed / _length * 100);
			var msg:String = Lang.YOUVE_COMPLETED + " " + _completed + "/" + _length + " " + Lang.SENTENCES + ".\n" + percent + "%";
			_um = new UserMessage(msg);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.addOK = true;
			_um.filters = [_dsf];
			addChild(_um);
			positionUserMessage();
			removeButtons();
		}
		
		private function removeButtons():void {
			//deleteNumberIconFrame();
			deletePrev();
			deleteNext();
			deletePlay();
			deleteStretched();
			deleteUserPlay();
			deleteUserRecord();
		}
		
		private function umClickedHandler(event:Event):void {
			if(_um) {
				_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
				removeChild(_um);
			}
		}
		
		/*
		############################ SEND DATA #############################
		*/
		// Try to send grade via AmfPHP first. If that fails, send via URLVariables.
		private function sendGrade():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			// prepare grade data object
			_obj = new Object();
			_obj.feedback = _completed + " / " + _length; // (String) optional
			_obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			_obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			_obj.gradeupdate = FlashVars.gradeupdate; // (String) URLVariables URL
			_obj.instance = FlashVars.instance; // (int) Moodle instance ID
			_obj.rawgrade = Math.floor(_completed / _length * 100); // (Number) grade, normally 0 - 100 but depends on grade book settings
			_obj.servicefunction = "Grades.amf_grade_update"; // (String) ClassName.method_name
			_obj.swfid = FlashVars.swfid; // (int) activity ID
			_amf.getObject(_obj); // send the data to the server
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
					updateGradeURLVars(); // AmfPHP failed so try URLVariables
				}
			} catch(e:Error) {
				_um.addMessage(Lang.GRADE_UNKNOWN + "\n" + Lang.PHP_VERSION_ERROR);
				updateGradeURLVars(); // AmfPHP failed so try URLVariables
			}
			addChild(_um);
		}
		
		// Display server errors
		private function faultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			/*var msg:String = Lang.ERROR;
			for(var s:String in _amf.obj.info) { // trace out returned data
				msg += "\n" + s + "=" + _amf.obj.info[s];
			}
			_um.addMessage(msg);*/
			updateGradeURLVars(); // AmfPHP failed so try URLVariables
		}
		
		private function updateGradeURLVars():void {
			_sg = new UpdateGradeURLVars();
			_sg.addEventListener(UpdateGradeURLVars.GRADE_UPDATED, gradeUpdated);
			_sg.addEventListener(UpdateGradeURLVars.GRADE_FAILED, gradeFailed);
			_sg.updateGrade(_obj);
		}
		
		private function gradeUpdated(event:Event):void {
			_sg.removeEventListener(UpdateGradeURLVars.GRADE_UPDATED, gradeUpdated);
			_sg.removeEventListener(UpdateGradeURLVars.GRADE_FAILED, gradeFailed);
			_um.addMessage(Lang.GRADE_SENT);
			addChild(_um);
		}
		
		private function gradeFailed(event:Event):void {
			_sg.removeEventListener(UpdateGradeURLVars.GRADE_UPDATED, gradeUpdated);
			_sg.removeEventListener(UpdateGradeURLVars.GRADE_FAILED, gradeFailed);
			_um.addMessage(Lang.GRADE_NOT_SENT);
			_um.addMessage(_sg.loaderVars);
			addChild(_um);
		}
	}
}// end of ListenAndRepeat
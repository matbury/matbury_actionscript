/*
    SMILListenAndWrite Multimedia Interactive Learning Application (MILA)

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
	import flash.filters.DropShadowFilter;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import com.matbury.BlankWord;
	import com.matbury.CheckString;
	import com.matbury.Clock;
	import com.matbury.CMenu;
	import com.matbury.UserMessage;
	import com.matbury.Image;
	import com.matbury.LoadXML;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.milas.UpdateGradeURLVars;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.Pointer;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.TextColors;
	
	public class SMILListenAndWrite extends Sprite {
		
		private var _version:String = "2014.04.24";
		private var _amf:Amf;
		private var _sg:UpdateGradeURLVars;
		private var _obj:Object; // grade data object
		private var _xml:XML;
		private var _smil:Namespace;
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _url:String;
		private var _audio:DictationAudio;
		private var _f:TextFormat;
		private var _intro:TextField;
		private var _blanks:Array;
		private var _wordsAndButtons:Array;
		private var _btn:Btn;
		private var _dsf:DropShadowFilter;
		private var _float:TextField;
		private var _textColors:TextColors;
		private var _title:TextField;
		private var _speakers:Speakers;
		private var _pointer:Pointer;
		private var _cs:CheckString;
		private var _currentWord:BlankWord;
		private var _input:String;
		private var _lastIndex:uint;
		private var _score:Array;
		private var _percent:int;
		private var _totalWords:int;
		private var _wordsCompleted:int;
		private var _scoreDisplay:TextField;
		private var _clock:Clock;
		private var _clockVisible:Boolean = true;
		private var _cmenu:CMenu;
		private var _um:UserMessage;
		private var _end:Btn;
		private var _sent:Boolean = false;
		
		public function SMILListenAndWrite() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_f = new TextFormat("Trebuchet MS",20,0,true);
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			/* 
			FlashVars.xmlurl = "../schoolanswerphone/xml/school_answerphone_2010_08_20.smil";
			FlashVars.moodledata = "../";
			initLoadBar();
			positionLoadBar();
			loadData();
			*/
			securityCheck();
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
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
				_um.addEventListener(MouseEvent.MOUSE_DOWN, visitMattBury);
				positionUserMessage();
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
		############################ LOAD DATA ############################
		*/
		private function loadData():void {
			var url:String = FlashVars.xmlurl;
			_loadXML = new LoadXML();
			_loadXML.addEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.addEventListener(LoadXML.FAILED, failedHandler);
			_loadXML.load(url);
		}
		
		private function loadedHandler(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.removeEventListener(LoadXML.FAILED, failedHandler);
			deleteLoadBar();
			_xml = _loadXML.xml;
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_xml.name());
			default xml namespace = _smil;
			initInteraction();
		}
		
		private function failedHandler(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.removeEventListener(LoadXML.FAILED, failedHandler);
			showError(Lang.NO_ACTIVITY_DATA);
			positionUserMessage();
		}
		
		/*
		######################## START INTERACTION ########################
		*/
		private function initInteraction():void {
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			initTextColors();
			initTitle();
			initClock();
			initScoreDisplay();
			initAudio();
			initIntro();
			initPlayAll();
			initSpeakers();
			resize(null);
		}
		
		private function resize(event:Event):void {
			positionUserMessage();
			positionTextColors();
			positionTitle();
			positionClock();
			positionScoreDisplay();
			positionIntro();
			positionPlayAll();
			positionSpeakers();
			positionPointer();
			positionEndAndSend();
			positionText();
			positionSpeakers();
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
		
		private function initTextColors():void {
			_textColors = new TextColors();
			addChild(_textColors);
		}
		
		private function positionTextColors():void {
			if(_textColors) {
				_textColors.x = stage.stageWidth * 0.5 - (_textColors.width * 0.5);
			}
		}
		
		private function initClock():void {
			_clock = new Clock();
			addChild(_clock);
		}
		
		private function positionClock():void {
			if(_clock) {
				_clock.x = stage.stageWidth;
			}
		}
		
		private function initTitle():void {
			_title = new TextField();
			_title.defaultTextFormat = _f;
			_title.embedFonts = true;
			_title.antiAliasType = AntiAliasType.ADVANCED;
			_title.autoSize = TextFieldAutoSize.LEFT;
			try {
				_title.text = String(_xml.head.meta.(@name == "Title").@content);
			} catch(e:Error) {
				_title.text = "Listen and write";
			}
			addChild(_title);
		}
		
		private function positionTitle():void {
			if(_title) {
				_title.x = stage.stageWidth * 0.5 - (_title.width * 0.5);
				_title.y = stage.stageHeight * 0.06;
			}
		}
		
		private function initScoreDisplay():void {
			_scoreDisplay = new TextField();
			_scoreDisplay.defaultTextFormat = _f;
			_scoreDisplay.embedFonts = true;
			_scoreDisplay.antiAliasType = AntiAliasType.ADVANCED;
			_scoreDisplay.autoSize = TextFieldAutoSize.LEFT;
			_scoreDisplay.text = Lang.LOADING;
			positionScoreDisplay();
			addChild(_scoreDisplay);
		}
		
		private function positionScoreDisplay():void {
			if(_scoreDisplay) {
				_scoreDisplay.x = stage.stageWidth - (_scoreDisplay.width + 20);
				_scoreDisplay.y = stage.stageHeight - (_scoreDisplay.height + 10);
			}
		}
		
		private function initSpeakers():void {
			_speakers = new Speakers();
			_speakers.filters = [_dsf];
			_speakers.mouseChildren = false;
			_speakers.buttonMode = true;
			addChild(_speakers);
			_speakers.addEventListener(MouseEvent.MOUSE_DOWN, speakersHandler);
		}
		
		private function positionSpeakers():void {
			if(_speakers) {
				_speakers.x = stage.stageWidth * 0.5;
				_speakers.y = stage.stageHeight * 0.5;
			}
		}
		
		private function speakersHandler(event:MouseEvent):void {
			_speakers.removeEventListener(MouseEvent.MOUSE_DOWN, speakersHandler);
			removeChild(_speakers);
			_speakers = null;
			_scoreDisplay.defaultTextFormat = _f;
			_scoreDisplay.text = "0%";
			positionScoreDisplay();
			initPointer();
			positionPointer();
		}
		
		/*
		#################################### INTRO TEXT ####################################
		*/
		private function initIntro():void {
			_intro = new TextField();
			_intro.defaultTextFormat = _f;
			_intro.embedFonts = true;
			_intro.antiAliasType = AntiAliasType.ADVANCED;
			_intro.autoSize = TextFieldAutoSize.CENTER;
			addChild(_intro);
			_intro.text = "1. Listen to the complete audio recording.\n2. Listen and write.\n\nPress play to start.";
		}
		
		private function positionIntro():void {
			if(_intro) {
				_intro.x = stage.stageWidth * 0.5 - (_intro.width * 0.5);
				_intro.y = stage.stageHeight * 0.3;
			}
		}
		
		private function deleteIntro():void {
			if(_intro) {
				removeChild(_intro);
				_intro = null;
			}
		}
		
		/*
		#################################### POINTER ####################################
		*/
		private function initPointer():void {
			_pointer = new Pointer();
			addChild(_pointer);
		}
		
		private function positionPointer():void {
			if(_pointer) {
				_pointer.x = _btn.x;
				_pointer.y = _btn.y;
			}
		}
		
		private function deletePointer():void {
			if(_pointer) {
				removeChild(_pointer);
				_pointer = null;
			}
		}
		
		/*
		#################################### LOAD AUDIO ####################################
		*/
		private function initAudio():void {
			_audio = new DictationAudio(_xml);
			_audio.addEventListener(DictationAudio.SOUNDS_LOADED, alHandler);
			_audio.addEventListener(DictationAudio.SOUNDS_FAILED, afHandler);
			_audio.loadAudio();
		}
		
		private function alHandler(event:Event):void {
			// clean up
			_audio.removeEventListener(DictationAudio.SOUNDS_LOADED, alHandler);
			_audio.removeEventListener(DictationAudio.SOUNDS_FAILED, afHandler);
			_scoreDisplay.text = "";
		}
		
		private function afHandler(event:Event):void {
			// clean up
			_audio.removeEventListener(DictationAudio.SOUNDS_LOADED, alHandler);
			_audio.removeEventListener(DictationAudio.SOUNDS_FAILED, afHandler);
			showError(Lang.SOUND_LOAD_FAILED);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			positionUserMessage();
		}
		
		/*
		#################################### PLAY ALL AUDIO ####################################
		*/
		private function initPlayAll():void {
			_btn = new Btn("play");
			_btn.addEventListener(MouseEvent.MOUSE_UP, introUp);
			addChild(_btn);
		}
		
		private function positionPlayAll():void {
			if(_btn) {
				_btn.x = stage.stageWidth * 0.5;
				_btn.y = stage.stageHeight * 0.6;
			}
		}
		
		private function introUp(event:MouseEvent):void {
			_btn.removeEventListener(MouseEvent.MOUSE_UP, introUp);
			_audio.addEventListener(DictationAudio.SOUNDS_FINISHED, allFinished);
			_audio.addEventListener(DictationAudio.SOUNDS_FAILED, allFailed);
			_audio.playAll();
			_intro.text = "1. Listen to the complete audio recording.\n2. Listen and write.\n\nPlaying audio... ";
			deletePointer();
		}
		
		private function allFinished(event:Event):void {
			_audio.removeEventListener(DictationAudio.SOUNDS_FINISHED, allFinished);
			_audio.removeEventListener(DictationAudio.SOUNDS_FAILED, allFailed);
			_btn.char = "next";
			_btn.addEventListener(MouseEvent.MOUSE_UP, nextUp);
			_intro.text = "1. Listen to the complete audio recording.\n2. Listen and write.\n\nAudio complete.";
			initPointer();
			positionPointer();
		}
		
		private function allFailed(event:Event):void {
			_audio.removeEventListener(DictationAudio.SOUNDS_FINISHED, allFinished);
			_audio.removeEventListener(DictationAudio.SOUNDS_FAILED, allFailed);
			_btn.char = "next";
			_btn.addEventListener(MouseEvent.MOUSE_UP, nextUp);
			_intro.text = "1. Listen to the complete audio recording.\n2. Listen and write.";
			showError(Lang.SOUND_LOAD_FAILED);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			positionUserMessage();
		}
		
		private function deleteNextBtn():void {
			if(_btn) {
				_btn.removeEventListener(MouseEvent.MOUSE_UP, nextUp);
				removeChild(_btn);
				_btn = null;
			}
		}
		
		private function nextUp(event:MouseEvent):void {
			deleteUserMessage();
			deleteNextBtn();
			deleteIntro();
			deletePointer();
			initDictation();
		}
		
		private function initDictation():void {
			initText();
			positionText();
			initKeyWords();
			initFloat();
			initCompareStrings();
			positionFloat();
			initEndAndSend();
			positionEndAndSend();
			_clock.startClock();
		}
		
		/*
		######################## BLANK WORDS AND PLAY BUTTONS ########################
		*/
		private function initText():void {
			var index:uint = 0;
			_blanks = new Array();
			_score = new Array();
			_wordsAndButtons = new Array();
			var lenth:uint = _xml.body.seq.length();
			for(var i:uint = 0; i < lenth; i++) {
				var btn:Btn = new Btn("play",i);
				_wordsAndButtons.push(btn);
				btn.addEventListener(MouseEvent.MOUSE_DOWN, playDownHandler);
				addChild(btn);
				var stretched:String = _xml.body.seq[i].par.(@id == "answer").audio.(@id == "stretched").@src;
				if(stretched != null) {
					btn = new Btn("stretched",i);
					_wordsAndButtons.push(btn);
					btn.addEventListener(MouseEvent.MOUSE_DOWN, stretchedDownHandler);
					addChild(btn);
				}
				var sentence:String = _xml.body.seq[i].par.(@id == "answer").text;
				var words:Array = sentence.split(" ");
				var len:uint = words.length;
				for(var j:uint = 0; j < len; j++) {
					var bw:BlankWord = new BlankWord(words[j],index);
					_wordsAndButtons.push(bw);
					index++;
					bw.addEventListener(MouseEvent.MOUSE_DOWN, wordDownHandler);
					addChild(bw);
					_blanks.push(bw);
					var correct:Boolean = false;
					_score.push(correct);
				}
			}
			_totalWords = _blanks.length;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageFocusHandler);
		}
		
		private function positionText():void {
			if(_wordsAndButtons) {
				var posX:Number = 180;
				var posY:Number = _title.y + _title.height + 10;
				var len:uint = _wordsAndButtons.length;
				for(var i:uint = 0; i < len; i++) {
					if(posX > stage.stageWidth - (_wordsAndButtons[i].width + 5)) {
						posX = 180;
						posY += _wordsAndButtons[i].height + 5;
					}
					_wordsAndButtons[i].x = posX;
					_wordsAndButtons[i].y = posY;
					posX += _wordsAndButtons[i].width + 3;
					if(_wordsAndButtons[i] is Btn) {
						_wordsAndButtons[i].x += _wordsAndButtons[i].width * 0.5;
						_wordsAndButtons[i].y += _wordsAndButtons[i].height * 0.5;
					}
				}
			}
		}
		
		private function playDownHandler(event:MouseEvent):void {
			_btn = event.currentTarget as Btn;
			_audio.playAudio(_btn.i);
			stage.focus = _float;
		}
		
		private function stretchedDownHandler(event:MouseEvent):void {
			_btn = event.currentTarget as Btn;
			_audio.playStretched(_btn.i);
			stage.focus = _float;
		}
		
		private function stageFocusHandler(event:MouseEvent):void {
			if(_float) {
				stage.focus = _float;
			}
		}
		
		/*
		######################## KEY WORDS COLUMN ########################
		*/
		private function initKeyWords():void {
			_f.size = 15;
			var t:TextField = new TextField();
			t.defaultTextFormat = _f;
			t.embedFonts = true;
			t.antiAliasType = AntiAliasType.ADVANCED;
			t.multiline = true;
			t.wordWrap = true;
			t.selectable = false;
			t.y = stage.stageHeight * 0.1;
			t.width = 180;
			t.height = stage.stageHeight - t.y;
			t.text = Lang.KEYWORDS;
			addChild(t);
			var i_len:uint = _xml.body.seq.length();
			for(var i:uint = 0; i < i_len; i++) {
				var j_len:uint = _xml.body.seq[i].par.(@id == "keyword").text.length();
				for(var j:uint = 0; j < j_len; j++) {
					var clue:String = _xml.body.seq[i].par.(@id == "keyword").text[j];
					if(clue != null) {
						t.appendText("\n" + clue);
					}
				}
			}
		}
		
		/*
		######################## USER INPUT TEXT FIELD ########################
		*/
		private function initFloat():void {
			_float = new TextField();
			_float.type = TextFieldType.INPUT;
			_float.defaultTextFormat = _f;
			_float.embedFonts = true;
			_float.antiAliasType = AntiAliasType.ADVANCED;
			_float.restrict = "a-z\\-'";
			_float.text = "";
			_float.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			addChild(_float);
			_currentWord = _blanks[0];
			_currentWord.filters = [_dsf];
			_lastIndex = _blanks[0].ndx;
		}
		
		private function deleteFloat():void {
			if(_float) {
				_float.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
				removeChild(_float);
				_float = null;
			}
		}
		
		private function positionFloat():void {
			if(_float) {
				_float.width = _currentWord.width;
				_float.height = _currentWord.height;
				_float.x = _currentWord.x;
				_float.y = _currentWord.y;
				var i:uint = _currentWord.word.length;
				_float.maxChars = i;
				_float.text = "";
				stage.focus = _float;
			}
		}
		
		private function initCompareStrings():void {
			_cs = new CheckString();
		}
		
		/*
		######################## SUBMIT BUTTON ########################
		*/
		// User can click this button to stop the dictation and send the results
		// to the grade book
		private function initEndAndSend():void {
			_end = new Btn(Lang.SUBMIT);
			_end.addEventListener(MouseEvent.MOUSE_UP, endUp);
			_end.filters = [_dsf];
			_end.mouseChildren = false;
			_end.buttonMode = true;
			addChild(_end);
		}
		
		private function positionEndAndSend():void {
			if(_end) {
				_end.x = stage.stageWidth * 0.5;
				_end.y = stage.stageHeight - _end.height + 3;
			}
		}
		
		private function deleteEndAndSend():void {
			if(_end) {
				_end.removeEventListener(MouseEvent.MOUSE_UP, endUp)
				removeChild(_end);
				_end = null;
			}
		}
		
		private function endUp(event:MouseEvent):void {
			deleteEndAndSend();
			checkScore();
			endActivity();
		}
		
		/*
		######################## COMPARE USER INPUT ########################
		*/
		function keyUp(event:KeyboardEvent):void {
			compareStrings();
		}
		
		private function compareStrings():void {
			if(_float) {
				var input:String = _float.text;
				var original:String = _currentWord.word;
				var len:uint = input.length;
				var a:Array = _cs.checkIt(original,input);
				if(a[0] == true){
					_currentWord.removeEventListener(MouseEvent.MOUSE_DOWN, wordDownHandler);
					_currentWord.showText();
					_currentWord.finished = true;
					var index:uint = _currentWord.ndx;
					_score[index] = true;
					checkScore();
					gotoNextWord();
				} else {
					var f:TextFormat = new TextFormat();
					for(var i:uint = 0; i < len; i++) {
						f.color = a[i];
						_float.setTextFormat(f,i,i+1);
					}
				}
			}
		}
		
		private function checkScore():void {
			var len:uint = _score.length;
			var score:uint = 0;
			for(var i:uint = 0; i < len; i++) {
				if(_score[i] == true) {
					score++;
				}
			}
			_percent = Math.floor(score / len * 100);
			_wordsCompleted = score;
			_scoreDisplay.text = _percent + "%";
			positionScoreDisplay();
			var time:String = _clock.time;
			if(score >= len && _sent == false) {
				endActivity();
			}
		}
		
		private function wordDownHandler(event:MouseEvent):void {
			_currentWord = event.currentTarget as BlankWord;
			_lastIndex = _currentWord.ndx;
			positionShadow();
			positionFloat();
		}
		
		private function positionShadow():void {
			var len:uint = _blanks.length;
			for(var i:uint = 0; i < len; i++) {
				_blanks[i].filters = [];
			}
			_currentWord.filters = [_dsf];
		}
		
		private function gotoNextWord():void {
			var len:uint = _blanks.length;
			// if we're at the last word, go to first word
			if(_lastIndex >= len -1) {
				_lastIndex = 0;
			}
			// are there any unfinished words after this one?
			var finished:Boolean = true;
			for(var i:uint = _lastIndex; i < len; i++) {
				if(_blanks[i].finished == false) {
					finished = false;
				}
			}
			// if there are unfinished words, look for the next one
			if(finished == false) {
				for(i = _lastIndex; i < len; i++) {
					if(_blanks[i].finished == false) {
						_currentWord = _blanks[i];
						_lastIndex = _blanks[i].ndx;
						positionFloat();
						positionShadow();
						break;
					}
				}
				// if there aren't any finished words, go to first word
			} else {
				_lastIndex = 0;
				for(i = _lastIndex; i < len; i++) {
					if(_blanks[i].finished == false) {
						_currentWord = _blanks[i];
						_lastIndex = _blanks[i].ndx;
						positionFloat();
						positionShadow();
						break;
					}
				}
			}
		}
		
		/*
		########################## END ACTIVITY ###########################
		*/
		private function endActivity():void {
			_clock.stopClock();
			deleteFloat();
			deleteEndAndSend();
			var msg:String = _percent + "% " + Lang.COMPLETED_END + ".\n" + Lang.TIME + _clock.time;
			_um = new UserMessage(msg);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.addOK = true;
			_um.filters = [_dsf];
			addChild(_um);
			positionUserMessage();
			sendGrade();
		}
		
		private function umClickedHandler(event:Event):void {
			if(_um) {
				_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
				removeChild(_um);
				_um = null;
			}
		}
		
		/*
		############################ SEND DATA #############################
		*/
		private function sendGrade():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			// prepare grade data object
			_obj = new Object();
			_obj.feedback = _wordsCompleted + "/" + _blanks.length + " " + Lang.WORDS + " " + Lang.COMPLETED_END + "."; // (String) optional
			_obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			_obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			_obj.gradeupdate = FlashVars.gradeupdate; // (String) URLVariables URL
			_obj.instance = FlashVars.instance; // (int) Moodle instance ID
			_obj.rawgrade = _percent; // (Number) grade, normally 0 - 100 but depends on grade book settings
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
					_um.addMessage(_amf.obj.message);
					break;
					//
					case "NO_PERMISSION":
					_um.addMessage(_amf.obj.message);
					break;
					//
					case "NO_GRADE_ITEM":
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
}
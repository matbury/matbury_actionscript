/*
    SMILLookAndDescribe Multimedia Interactive Learning Application (MILA)

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
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
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
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.TextColors;
	import com.matbury.sam.gui.Tick;
	
	public class SMILLookAndDescribe extends Sprite {
		
		private var _version:String = "2014.04.20";
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
		private var _completed:int = 0; // Number of questions completed correctly
		private var _skipped:int = 0;
		private var _si:ShuffledIndex;
		private var _shuffle:Boolean = true;
		private var _currentIndex:int = 0;
		private var _blanks:Array;
		private var _lastIndex:int;
		private var _currentWord:BlankWord;
		private var _score:Array;
		private var _answers:Array; // 0 = wrong, 1 = correct, 2 = unanswered
		private var _wrong:Array; // incorrect answers (shown at end)
		private var _sentence:String;
		private var _mp3:String;
		private var _image:SMILImage;
		private var _next:Btn;
		private var _skip:Btn;
		private var _play:Btn;
		private var _stretched:Btn;
		private var _info:Btn;
		private var _cs:CheckString;
		private var _f:TextFormat;
		private var _float:TextField;
		private var _timer:Timer;
		private var _title:TextField;
		private var _container:Sprite;
		private var _numbers:Array;
		private var _textColors:TextColors;
		private var _um:UserMessage;
		private var _end:Btn;
		private var _menu:CMenu;
		
		public function SMILLookAndDescribe() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			/* 
			//FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects.smil";
			FlashVars.xmlurl = "../animals/xml/animals.smil";
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
			_f = new TextFormat("Trebuchet MS",15,0,true);
			if(this.root.loaderInfo.parameters.shuffle) {
				if(this.root.loaderInfo.parameters.shuffle == "false") {
					_shuffle = false;
				}
			}
			_si = new ShuffledIndex(_length,_shuffle);
			_cs = new CheckString();
			_answers = new Array();
			for(var i:uint = 0; i < _length; i++) {
				_answers.push(2); // set all to not answered
			}
			_wrong = new Array();
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			initTextColors();
			initClock();
			initScoreBar();
			initPlay();
			initStretched();
			initNext();
			initSkip();
			nextImage();
			nextText();
			initFloat();
			initEndAndSend();
			initSpeakers();
			resize(null);
		}
		
		private function resize(event:Event):void {
			positionTextColours();
			positionClock();
			adjustScoreBar();
			positionPlay();
			positionStretched();
			positionNext();
			positionImage();
			positionSkip();
			positionText();
			positionFloat();
			positionEndAndSend();
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
		
		private function initTextColors():void {
			_textColors = new TextColors();
			addChild(_textColors);
		}
		
		private function positionTextColours():void {
			if(_textColors) {
				_textColors.x = stage.stageWidth * 0.5 - (_textColors.width * 0.5);
				_textColors.y = stage.stageHeight * 0.83;
			}
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
				_play.x = stage.stageWidth * 0.5 - 20;
				_play.y = stage.stageHeight * 0.6;
			}
		}
		
		private function playDown(event:MouseEvent):void {
			_image.playAnswer();
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
				_stretched.x = stage.stageWidth * 0.5 + 20;
				_stretched.y = stage.stageHeight * 0.6;
			}
		}
		
		private function stretchedDown(event:MouseEvent):void {
			_image.playAnswerStretched();
		}
		
		/*
		############################ NEXT BUTTON ############################
		*/
		private function initNext():void {
			_next = new Btn("next");
			_next.addEventListener(MouseEvent.MOUSE_UP, nextUp);
			_next.visible = false;
			addChild(_next);
		}
		
		private function positionNext():void {
			if(_next) {
				_next.x = stage.stageWidth * 0.5;
				_next.y = stage.stageHeight * 0.8;
			}
		}
		
		private function nextUp(event:MouseEvent):void {
			nextSentence();
			deleteText();
			nextText();
			positionText();
			if(_float == null) {
				initFloat();
			}
			positionFloat();
			_next.visible = false;
			_skip.visible = false;
		}
		
		private function showNext():void {
			_next.visible = true;
			stopTimer();
		}
		
		/*
		################## TIMER TO GIVE SKIP TO NEXT OPTION ##################
		*/
		private function initSkip():void {
			_skip = new Btn("next");
			_skip.addEventListener(MouseEvent.MOUSE_UP, skipUp);
			_skip.visible = false;
			addChild(_skip);
		}
		
		private function positionSkip():void {
			if(_skip) {
				_skip.x = stage.stageWidth * 0.5;
				_skip.y = stage.stageHeight * 0.8;
			}
		}
		
		private function deleteSkip():void {
			if(_skip) {
				removeChild(_skip);
				_skip = null;
			}
		}
		
		private function skipUp(event:MouseEvent):void {
			_skip.visible = false;
			var cross:Cross = new Cross();
			cross.y = cross.height;
			_numbers[_currentIndex].addChild(cross);
			var index:uint = _si.ind[_currentIndex];
			_answers[index] = 0;
			_wrong.push(index);
			_skipped++;
			showAnswer();
			_image.playAnswer();// play sound
			checkScore();
		}
		
		// Number of seconds to wait before showing show answer button
		private function startTimer():void {
			var tm:int;
			if(this.root.loaderInfo.parameters.timer) {
				tm = this.root.loaderInfo.parameters.timer;
			} else {
				tm = _sentence.length * 0.5;
			}
			_timer = new Timer(1000,tm);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);		
			_timer.start();
		}
		
		private function timerComplete(event:TimerEvent):void {
			_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			_timer = null;
			_skip.visible = true;
		}
		
		private function stopTimer():void {
			if(_timer) {
				_timer.stop();
			}
			_skip.visible = false;
		}
		
		private function showAnswer():void {
			var len:uint = _blanks.length;
			for(var i:uint = 0; i < len; i++) {
				_blanks[i].showText();
			}
			removeChild(_float);
			_float = null;
			showNext();
		}
		
		/*
		############################## IMAGE ##############################
		*/
		private function nextImage():void {
			var index:uint = _si.ind[_currentIndex];
			_image = new SMILImage(index,_xml.body.seq[index],FlashVars.moodledata);
			_image.showAnswerImage();
			_image.addEventListener(MouseEvent.MOUSE_DOWN, imageDown);
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
		
		/*
		###################### USER INPUT & FEEDBACK ######################
		*/
		private function nextSentence():void {
			_currentIndex++;
			if(_currentIndex >= _length) {
				_currentIndex = 0;
				_si.shuffle();
			}
			if(_image) {
				deleteImage();
			}
			nextImage();
			positionImage();
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
			var words:Array = _sentence.split(" ");
			var len:uint = words.length;
			_blanks = new Array();
			_score = new Array();
			_container = new Sprite();
			for(var i:uint = 0; i < len; i++) {
				var bw:BlankWord = new BlankWord(words[i],posX,posY,i); // word
				bw.addEventListener(KeyboardEvent.KEY_UP, keyUp);
				bw.addEventListener(MouseEvent.MOUSE_DOWN, wordDownHandler);
				posX += bw.width + 3;
				if(posX > stage.stageWidth * 0.8) {
					posX = 0;
					posY += bw.height + 3;
				}
				_container.addChild(bw);
				_blanks.push(bw);
				var correct:Boolean = false;
				_score.push(correct); // keep track of completed words
			}
			addChild(_container);
			startTimer();
		}
		
		private function positionText():void {
			if(_container) {
				_container.x = (stage.stageWidth * 0.5) - (_container.width * 0.5);
				_container.y = stage.stageHeight * 0.65;
			}
		}
		
		// delete all the words and arrays
		private function deleteText():void {
			if(_container) {
				removeChild(_container);
				_container = null;
				_score = null;
			}
		}
		
		// create input text field
		private function initFloat():void {
			_float = new TextField();
			_float.type = TextFieldType.INPUT;
			_float.defaultTextFormat = _f;
			_float.embedFonts = true;
			_float.restrict = "a-z\\-'";
			_float.text = "";
			_float.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			addChild(_float);
			_currentWord = _blanks[0];
			_currentWord.filters = [_dsf];
			_lastIndex = _blanks[0].i;
			_float.x = _container.x;
			_float.y = _container.y;
			_float.width = _currentWord.width;
			_float.height = _currentWord.height;
			stage.focus = _float;
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUp);
		}
		
		private function stageUp(event:MouseEvent):void {
			if(_float) {
				stage.focus = _float;
			}
		}
		
		private function deleteFloat():void {
			if(_float) {
				_float.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
				removeChild(_float);
				_float = null;
			}
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
		
		private function deleteSpeakers():void {
			if(_speakers) {
				_speakers.removeEventListener(MouseEvent.MOUSE_UP, speakersDown);
				removeChild(_speakers);
				_speakers = null;
			}
		}
		
		private function speakersDown(event:MouseEvent):void {
			deleteSpeakers();
			_clock.startClock();
		}
		
		/*
		######################## CHECK USER INPUT ########################
		*/
		
		function keyUp(event:KeyboardEvent):void {
			if(_float) {
				compareStrings();
			}
		}
		
		// compare user input text with word text and colour code the user input
		private function compareStrings():void {
			var input:String = _float.text; // user input
			var original:String = _currentWord.word; // word
			var a:Array = _cs.checkIt(original,input);
			// if they're the same, show word and go to next word
			if(a[0] == true){
				_currentWord.removeEventListener(MouseEvent.MOUSE_DOWN, wordDownHandler);
				_currentWord.showText();
				_currentWord.finished = true;
				var index:uint = _currentWord.i;
				_score[index] = true;
				gotoNextWord();
			} else {
				// colour code the user input: green, amber and red
				var len:uint = input.length;
				var f:TextFormat = new TextFormat();
				for(var i:uint = 0; i < len; i++) {
					f.color = a[i];
					_float.setTextFormat(f,i,i+1);
				}
			}
		}
		
		private function checkScore():void {
			// tally up completed words
			var len:uint = _score.length;
			var score:uint = 0;
			// words in current time completed
			for(var i:uint = 0; i < len; i++) {
				if(_score[i] == true) {
					score++;
				}
			}
			// if all words are completed show Next Time button
			if(score >= len) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUp);
				deleteFloat();
				_currentWord.filters = [];
				_completed++;
				var tick:Tick = new Tick();
				tick.y = tick.height;
				_numbers[_currentIndex].addChild(tick);
				var index:uint = _si.ind[_currentIndex];
				_answers[index] = 1;
				_image.playAnswer();// play current sound
				showNext(); // show Next Time button
			}
			// if total target is reached, end game
			if(_completed + _skipped >= _length) {
				deleteEndAndSend();
				endActivity(); // automatically sends user results
			}
		}
		
		private function endActivity():void {
			var percent:int = Math.floor(_completed / _length * 100);
			var msg:String = Lang.YOUVE_COMPLETED + " " + _completed + "/" + _length + " " + Lang.SENTENCES + ".\n" + percent + "%";
			_um = new UserMessage(msg);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.addOK = true;
			_um.filters = [_dsf];
			addChild(_um);
			positionUserMessage();
			_clock.stopClock();
			stopTimer();
			deleteFloat();
			removeButtons();
			sendGrade();
			if(_wrong.length > 0) {
				_um.addMessage("Click on the (i) button to see your wrong answers.");
				initInfo();
			} else {
				_um.addMessage("There are no wrong answers to display.");
			}
		}
		
		private function removeButtons():void {
			_play.removeEventListener(MouseEvent.MOUSE_DOWN, playDown);
			_play.visible = false;
			_stretched.removeEventListener(MouseEvent.MOUSE_DOWN, stretchedDown);
			_stretched.visible = false;
			_next.removeEventListener(MouseEvent.MOUSE_UP, nextUp);
			_next.visible = false;
			_skip.removeEventListener(MouseEvent.MOUSE_UP, skipUp);
			_skip.visible = false;
		}
		
		/*
		############################ SELECT WORD ############################
		*/
		private function wordDownHandler(event:MouseEvent):void {
			_currentWord = event.currentTarget as BlankWord;
			_lastIndex = _currentWord.i;
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
		
		private function positionFloat():void {
			if(_float) {
				_float.width = _currentWord.width;
				_float.height = _currentWord.height;
				_float.x = _currentWord.x + _container.x;
				_float.y = _currentWord.y + _container.y;
				var i:uint = _currentWord.word.length;
				_float.maxChars = i;
				_float.text = "";
				stage.focus = _float;
			}
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
						_lastIndex = _blanks[i].i;
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
						_lastIndex = _blanks[i].i;
						positionFloat();
						positionShadow();
						break;
					}
				}
			}
			checkScore();
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
			_end.removeEventListener(MouseEvent.MOUSE_UP, endUp);
			deleteEndAndSend();
			checkScore();
			endActivity();
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
		
		/*
		########################### SHOW WRONG ############################
		*/
		private function initInfo():void {
			_info = new Btn("info");
			_info.addEventListener(MouseEvent.MOUSE_UP, infoUp);
			_info.x = stage.stageWidth * 0.5;
			_info.y = stage.stageHeight - (_info.height + 5);
			_info.filters = [_dsf];
			addChild(_info);
		}
		
		private function infoUp(event:MouseEvent):void {
			_info.removeEventListener(MouseEvent.MOUSE_UP, infoUp);
			_info.visible = false;
			removeChild(_image);
			removeChild(_textColors);
			removeChild(_container);
			removeChild(_clock);
			addChild(_um);
			removeChild(_um);
			_um = null;
			initWrongImages();
		}
		
		// display all incorrect images and allow sounds to be played
		private function initWrongImages():void {
			var posX:int = 70;
			var posY:int = 40;
			var len:int = _wrong.length;
			for(var i:uint = 0; i < len; i++) {
				var image:SMILImage = new SMILImage(_wrong[i],_xml.body.seq[_wrong[i]],FlashVars.moodledata);
				image.showAnswerImage();
				image.scaleX = 0.5;
				image.scaleY = 0.5;
				image.addEventListener(MouseEvent.MOUSE_DOWN, imageDown);
				image.x = posX;
				image.y = posY;
				addChild(image);
				var t:TextField = new TextField();
				_f.size = 12;
				t.defaultTextFormat = _f;
				t.embedFonts = true;
				t.autoSize = TextFieldAutoSize.LEFT;
				t.text = _xml.body.seq[_wrong[i]].par.(@id == "answer").text[0];
				t.x = image.x - 40;
				t.y = image.y + 35;
				addChild(t);
				var cross:Cross = new Cross();
				cross.x = t.x - cross.width;
				cross.y = t.y + t.height;
				addChild(cross);
				posY += 100;
				if(posY > stage.stageHeight - 50) {
					posX += 150;
					posY = 40;
				}
			}
		}
		
		private function imageDown(event:MouseEvent):void {
			var image:SMILImage = event.currentTarget as SMILImage;
			image.playAnswer();
		}
	}
}// end of LookAndDescribe
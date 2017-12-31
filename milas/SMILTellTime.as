/*
    SMILTellTime Multimedia Interactive Learning Application (MILA)

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
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import com.matbury.BlankWord;
	import com.matbury.CheckString;
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
	import com.matbury.sam.gui.TextColors;
	import com.matbury.sam.gui.Tick;
	
	public class SMILTellTime extends Sprite {
		
		private var _version:String = "2011.08.18";
		private var _amf:Amf;
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _xml:XML;
		private var _smil:Namespace;
		private var _clock:Clock;
		private var _dsf:DropShadowFilter;
		private var _face:Face;
		private var _time:String;
		private var _audio:Audio;
		private var _speakers:Speakers;
		private var _length:uint = 20;
		private var _completed:int = 0;
		private var _blanks:Array;
		private var _lastIndex:int;
		private var _currentWord:BlankWord;
		private var _score:Array;
		private var _numbers:Array;
		private var _numIndex:int = 0;
		private var _cs:CheckString;
		private var _f:TextFormat;
		private var _float:TextField;
		private var _titleText:TextField;
		private var _writeText:TextField;
		private var _exampleText:TextField;
		private var _textColors:TextColors;
		private var _next:Btn;
		private var _show:Btn;
		private var _play:Btn;
		private var _timer:Timer;
		private var _delay:Number = 1;
		private var _shown:Boolean = false;
		private var _cmenu:CMenu;
		private var _um:UserMessage;
		
		public function SMILTellTime() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			//securityCheck();
			/**/
			FlashVars.xmlurl = "../tellthetime/xml/tell_time_english_new.smil";
			FlashVars.moodledata = "../";
			initLoadBar();
			positionLoadBar();
			loadData();
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
		}
		
		private function resize(event:Event):void {
			positionUserMessage();
			positionLoadBar();
			positionClock();
			positionTextColors();
			positionTexts();
			positionFace();
			adjustScoreBar();
			positionSpeakers();
			positionShowAnswer();
			positionNext();
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
			_f = new TextFormat(Lang.FONT,25,0,true);
			if(this.root.loaderInfo.parameters.gamelength) {
				_length = Number(this.root.loaderInfo.parameters.gamelength);
			}
			if(this.root.loaderInfo.parameters.delay) {
				_delay = Number(this.root.loaderInfo.parameters.delay);
			}
			_cs = new CheckString();
			_audio = new Audio();
			//initClock();
			//initTextColors();
			//initTexts();
			initFace();
			initNext(); // testing only
			positionNext(); // testing only
			//initScoreBar();
			//initSpeakers();
			//initShowAnswer();
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
		########################### INSTRUCTIONS ###########################
		*/
		private function initTextColors():void {
			_textColors = new TextColors();
			addChild(_textColors);
		}
		
		private function positionTextColors():void {
			if(_textColors) {
				_textColors.x = 5;
				_textColors.y = stage.stageHeight * 0.7;
			}
		}
		
		private function initTexts():void {
			// title
			_titleText = new TextField();
			_titleText.defaultTextFormat = _f;
			_titleText.embedFonts = true;
			_titleText.antiAliasType = AntiAliasType.ADVANCED;
			_f.size = 20;
			_titleText.autoSize = TextFieldAutoSize.LEFT;
			_titleText.text = _xml.example.question.text; //"What's the time?";
			addChild(_titleText);
			// example
			_exampleText = new TextField();
			_exampleText.defaultTextFormat = _f;
			_exampleText.embedFonts = true;
			_exampleText.antiAliasType = AntiAliasType.ADVANCED;
			_exampleText.autoSize = TextFieldAutoSize.LEFT;
			_exampleText.text = _xml.example.answer.text; //"Example: It's twenty-five past seven.";
			addChild(_exampleText);
			// write display
			_writeText = new TextField();
			_writeText.defaultTextFormat = _f;
			_writeText.embedFonts = true;
			_writeText.antiAliasType = AntiAliasType.ADVANCED;
			_writeText.autoSize = TextFieldAutoSize.LEFT;
			_writeText.text = "Click on Next time to start.";//_xml.example.keywords.keyword; //"Write the time here:";
			addChild(_writeText);
		}
		
		private function positionTexts():void {
			if(_titleText) {
				_titleText.x = 5;
				_titleText.y = 5;
			}
			if(_exampleText) {
				_exampleText.x = 5;
				_exampleText.y = stage.stageHeight * 0.2;
			}
			if(_writeText) {
				_writeText.x = 5;
				_writeText.y = stage.stageHeight * 0.4;
			}
		}
		
		/*
		########################### CLOCK FACE ###########################
		*/
		private function initFace():void {
			_face = new Face();
			_face.minute.filters = [_dsf];
			_face.hour.filters = [_dsf];
			_face.rim.filters = [_dsf];
			addChild(_face);
		}
		
		private function positionFace():void {
			if(_face) {
				_face.x = stage.stageWidth * 0.5;
				_face.y = stage.stageHeight * 0.5;
				_face.scaleX = _face.scaleY = 0.7;
			}
		}
		
		private function enterFrameHandler(event:Event):void {
			_face.minute.rotation += 6;
			_face.hour.rotation += 0.5;
		}
		
		/*
		########################### PLAY BUTTON ###########################
		*/
		private function initPlay():void {
			_play = new Btn("play");
			_play.addEventListener(MouseEvent.MOUSE_UP, playUp);
			addChild(_play);
		}
		
		private function positionPlay():void {
			if(_play && _face) {
				_play.x = _face.x;
				_play.y = _face.y + (_face.height * 0.57);
			}
		}
		
		private function playUp(event:MouseEvent):void {
			if(_audio) {
				_audio.playAudio();
			}
		}
		
		private function deletePlay():void {
			if(_play) {
				_play.removeEventListener(MouseEvent.MOUSE_UP, playUp);
				removeChild(_play);
				_play = null;
			}
		}
		
		// create score bar numbers across bottom of stage
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
				var spacing:int = _numbers[0].width + 2; // number icon spacing
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
		
		private function initNext():void {
			_next = new Btn("Next time");
			_next.addEventListener(MouseEvent.MOUSE_UP, nextUp);
			_next.mouseChildren = false;
			_next.buttonMode = true;
			_next.filters = [_dsf];
			addChild(_next);
		}
		
		private function positionNext():void {
			if(_next) {
				_next.x = 60;
				_next.y = stage.stageHeight * 0.6;
			}
		}
		
		private function nextUp(event:MouseEvent):void {
			//_next.removeEventListener(MouseEvent.MOUSE_UP, nextUp);
			//removeChild(_next);
			nextTime();
			/*deleteText();
			nextText();
			if(!_float) {
				initFloat();
			}
			positionFloat();
			addChild(_show);
			removeChild(_show);
			_shown = false;
			startTimer();*/
		}
		
		private function showNext():void {
			addChild(_show);
			removeChild(_show);
			_next.addEventListener(MouseEvent.MOUSE_UP, nextUp);
			addChild(_next);
			_numIndex++;
			stopTimer();
		}
		
		/*
		################## TIMER TO GIVE SHOW ANSWER OPTION ##################
		*/
		private function startTimer():void {
			if(!_timer) {
				var letters:Array = _time.split("");
				var num:int = letters.length;
				var count:int = Math.round(num * _delay);
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
			addChild(_show);
			_shown = true;
		}
		
		private function initShowAnswer():void {
			_show = new Btn(Lang.SHOW_ANSWER);
			_show.addEventListener(MouseEvent.MOUSE_DOWN, showAnswerDown);
			_show.mouseChildren = false;
			_show.buttonMode = true;
			_show.filters = [_dsf];
		}
		
		private function positionShowAnswer():void {
			if(_show) {
				_show.x = 200;
				_show.y = stage.stageHeight * 0.6;
			}
		}
		
		private function showAnswerDown(event:MouseEvent):void {
			_show.removeEventListener(MouseEvent.MOUSE_DOWN, showAnswerDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, showAnswerUp);
			_show.x += 2;
			_show.y += 2;
			_show.filters = [];
		}
		
		private function showAnswerUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, showAnswerUp);
			_show.addEventListener(MouseEvent.MOUSE_DOWN, showAnswerDown);
			_show.x -= 2;
			_show.y -= 2;
			_show.filters = [_dsf];
			showAnswer();
		}
		
		private function showAnswer():void {
			var len:uint = _blanks.length;
			for(var i:uint = 0; i < len; i++) {
				_blanks[i].showText();
			}
			deleteFloat();
			removeChild(_show);
			var cross:Cross = new Cross();
			cross.y = cross.height;
			_numbers[_numIndex].addChild(cross);
			showNext();
		}
		
		/*
		########################### SELECT TIME ###########################
		*/
		private function nextTime():void {
			deletePlay();
			// stop the clock hands
			_face.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			// select random hours and minutes
			var hr:uint = Math.floor(Math.random() * 12);
			var min:uint = Math.floor(Math.random() * 11);
			var sound2:String; // hours
			if(min == 0) {
				// The time is X o'clock
				_time = _xml.body.seq.(@id == "oclock").par[hr].text;
				_face.minute.rotation = 0;
				_face.hour.rotation = (hr * 30);
				// load and play audio
				//sound2 = _xml.body.seq.(@id == "oclock").par[hr].audio.(@id == "normal").@src;
				//_audio.loadAudio(sound2);
			} else {
				//
				_time = _xml.body.seq.(@id == "minutes").par[min].text;
				_time += " " + _xml.body.seq.(@id == "hours").par[hr].text;
				_face.minute.rotation = (min + 1) * 30;
				if(min < 6) {
					// The time is X minutes past the hour
					_face.hour.rotation = (hr * 30) + (min * 2.5);
				} else {
					// The time is X minutes to the hour
					_face.hour.rotation = (hr * 30) + (min * 2.5) - 30;
				}
				if(min > 5) {
					// The time is X minutes to the hour
					hr += 12;
				}
				// load and play audio
				//var sound1:String = FlashVars.moodledata + _xml.body.seq.(@id == "minutes").par[min].audio.(@id == "normal").@src; // minutes
				//sound2 = FlashVars.moodledata + _xml.body.seq.(@id == "hours").par[hr].audio.(@id == "normal").@src;
				//_audio.loadAudio(sound1,sound2);
				//initPlay();
				//positionPlay();
			}
			//_writeText.text = _xml.head.meta.(@name == "Instructions").@content;
		}
		
		/*
		###################### USER INPUT & FEEDBACK ######################
		*/
		// split time string into words and display next to clock
		private function nextText():void {
			var posX:Number = 30;
			var posY:Number = stage.stageHeight * 0.5;
			var words:Array = _time.split(" ");
			var len:uint = words.length;
			_blanks = new Array();
			_score = new Array();
			for(var i:uint = 0; i < len; i++) {
				var bw:BlankWord = new BlankWord(words[i],posX,posY,i); // word
				bw.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				bw.addEventListener(MouseEvent.MOUSE_DOWN, wordDownHandler);
				posX += bw.width + 3;
				if(posX > stage.stageWidth * 0.5) {
					posX = 30;
					posY += bw.height + 3;
				}
				addChild(bw);
				_blanks.push(bw);
				var correct:Boolean = false;
				_score.push(correct); // keep track of completed words
			}
		}
		
		// delete all the words and arrays
		private function deleteText():void {
			if(_blanks) {
				var len:uint = _blanks.length;
				for(var i:uint = 0; i < len; i++) {
					removeChild(_blanks[i]);
					_blanks[i] = null;
				}
				_score = null;
			}
		}
		
		// create input text field
		private function initFloat():void {
			_f.size = 15;
			_float = new TextField();
			_float.type = TextFieldType.INPUT;
			_float.defaultTextFormat = _f;
			_float.restrict = "a-z\\-'";
			_float.text = "";
			_float.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addChild(_float);
			_currentWord = _blanks[0];
			_currentWord.filters = [_dsf];
			_lastIndex = _blanks[0].i;
			stage.focus = _float;
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		private function stageUpHandler(event:MouseEvent):void {
			if(_float) {
				stage.focus = _float;
			}
		}
		
		private function deleteFloat():void {
			if(_float) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				_float.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				removeChild(_float);
				_float = null;
			}
		}
		
		/*
		######################## CHECK USER INPUT ########################
		*/
		function keyUpHandler(event:KeyboardEvent):void {
			compareStrings();
		}
		
		// compare user input text with word text and colour code the user input
		private function compareStrings():void {
			if(_float) {
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
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				deleteFloat();
				_currentWord.filters = [];
				_writeText.text = Lang.CORRECT;
				_completed++;
				// add a tick to the score bar
				var tick:Tick = new Tick();
				tick.y = tick.height;
				_numbers[_numIndex].addChild(tick);
				// Count the number of ticks added to numbers
				var numLen:uint = _numbers.length;
				var tried:uint = 0;
				for(i = 0; i < numLen; i++) {
					if(_numbers[i].numChildren > 2) {
						tried++;
					}
				}
				if(tried >= numLen) {
					_writeText.text = "";
					endActivity(); // automatically sends user results
				} else {
					showNext(); // show Next Time button
					_audio.playAudio(); // play the completed time
				}
			}
		}
		
		/*
		######################## SELECT WORD ########################
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
				_float.x = _currentWord.x;
				_float.y = _currentWord.y;
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
				if(!_blanks[i].finished) {
					finished = false;
				}
			}
			// if there are unfinished words, look for the next one
			if(!finished) {
				for(i = _lastIndex; i < len; i++) {
					if(!_blanks[i].finished) {
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
			_face.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			initNext();
			positionNext();
		}
		
		private function endActivity():void {
			if(_timer) {
				_timer.stop();
			}
			addChild(_show);
			removeChild(_show);
			_writeText.text = "";
			var msg:String = Lang.YOUVE_COMPLETED + " " + _completed + "/" + _length + " " + Lang.SENTENCES + ".";
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
			obj.feedback = _completed + " / " + _length + " " + Lang.COMPLETED_END + "."; // (String) optional
			obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			obj.rawgrade = _completed / _length * 100;// (Number) grade, normally 0 - 100 but depends on grade book settings
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
		
		// Display server errors
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
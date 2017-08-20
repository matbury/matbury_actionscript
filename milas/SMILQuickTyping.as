/*
    XMLListenAndRead Multimedia Interactive Learning Application (MILA)

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
	import com.matbury.Countdown;
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
	import com.matbury.sam.gui.Tick;
	
	public class SMILQuickTyping extends Sprite {
		
		private var _version:String = "2014.04.24";
		private var _amf:Amf;
		private var _sg:UpdateGradeURLVars;
		private var _obj:Object; // grade data object
		private var _cmenu:CMenu;
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _xml:XML;
		private var _smil:Namespace;
		private var _length:uint;
		private var _clock:Clock;
		private var _dsf:DropShadowFilter;
		private var _title:TextField;
		private var _example:TextField;
		private var _numbers:Array;
		private var _f:TextFormat;
		private var _rf:TextFormat;
		private var _completed:int = 0; // current number of words completed
		private var _percent:int;
		private var _si:ShuffledIndex;
		private var _shuffle:Boolean = true;
		private var _index:int = 0;
		private var _question:TextField;
		private var _keyword:TextField;
		private var _beg:TextField;
		private var _blank:BlankWord;
		private var _endText:TextField;
		private var _float:TextField;
		private var _answers:TextField;
		private var _cs:CheckString;
		private var _um:UserMessage;
		private var _end:Btn;
		private var _countdown:Countdown; // countdown clock
		private var _white:Sprite; // semi transparent circle over countdown clock
		private var _difficulty:Number = 1; // difficulty level passed in as FlashVar
		private var _timer:Timer;
		private var _time:uint; // countdown time _time = word.length * _difficulty * 1000 (milliseconds)
		// default text
		private var _titleText:String;
		private var _introText:String;
		
		public function SMILQuickTyping() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, resize);
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			initCMenu();
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			/* 
			//FlashVars.xmlurl = "../xml/qt_upper_int_fce_keyword_trans.smil"; // long blanks
			//FlashVars.xmlurl = "../xml/qt_int_for_and_since_short.smil"; // short blanks
			FlashVars.xmlurl = "../xml/qt_elem_irregular_participles.smil"; // 
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
			if(url) {
				_loadXML = new LoadXML();
				_loadXML.addEventListener(LoadXML.LOADED, loadedHandler);
				_loadXML.addEventListener(LoadXML.FAILED, failedHandler);
				_loadXML.load(url);
			} else {
				showError(Lang.NO_ACTIVITY_DATA);
				positionUserMessage();
			}
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
			showError(Lang.INCORRECT_DATA);
			positionUserMessage();
		}
		
		/*
		########################## INTERACTION #############################
		*/
		private function initInteraction():void {
			initParameters();
			initStyling();
			initCountdown();
			initTitle();
			initClock();
			initExample();
			initScoreBar();
			initQuestion();
			initAnswers();
			initInstructions();
			resize(null);
		}
		
		private function resize(event:Event):void {
			positionCountdown();
			positionTitle();
			positionClock();
			positionExample();
			positionScoreBar();
			positionEndAndSend();
			positionAnswers();
			positionQuestion();
			positionWord();
			positionFloat();
			positionUserMessage();
		}
		
		private function initParameters():void {
			_length = _xml.body.seq.length();
			if(this.root.loaderInfo.parameters.shuffle) {
				if(this.root.loaderInfo.parameters.shuffle == "false") {
					_shuffle = false;
				}
			}
			_si = new ShuffledIndex(_length,_shuffle);
			if(this.root.loaderInfo.parameters.difficulty) {
				_difficulty = this.root.loaderInfo.parameters.difficulty;
			}
			try {
				_titleText = _xml.head.meta.(@name == "Title").@content;
			} catch(e:Error) {
				_titleText = "Quick typing activity";
			}
			try {
				_introText = _xml.head.meta.(@name == "Intro").@content;
			} catch(e:Error) {
				_introText = "Type your answers before the countdown clock finishes.";
			}
		}
		
		private function initStyling():void {
			// black text format
			_f = new TextFormat("Trebuchet MS",18,0,true);
			// red text format
			_rf = new TextFormat("Trebuchet MS",18,0xDD0000,true);
		}
		
		/*
		############################# COUNTDOWN TIMER #############################
		*/
		private function initCountdown():void {
			_countdown = new Countdown();
			_countdown.addEventListener(Countdown.TIME_OUT, timeOutHandler);
			_countdown.filters = [_dsf];
			addChild(_countdown);
			// Cover countdown with semi-opaque white circle
			_white = new Sprite();
			_white.graphics.beginFill(0xFFFFFF,0.75);
			_white.graphics.drawCircle(_countdown.x,_countdown.y,_countdown.height * 0.55);
			_white.graphics.endFill();
			addChild(_white);
		}
		
		private function positionCountdown():void {
			if(_countdown) {
				// if the FP window is really big, make the countdown a reasonable size
				if(stage.stageHeight > 500) {
					_countdown.width = 480;
					_countdown.height = 480;
				} else if(stage.stageHeight < stage.stageWidth * 0.8) {
					_countdown.width = stage.stageHeight * 0.95;
					_countdown.height = stage.stageHeight * 0.95;
				} else {
					_countdown.width = stage.stageWidth * 0.8;
					_countdown.height = stage.stageWidth * 0.8;
				}
				_countdown.x = stage.stageWidth * 0.5;
				_countdown.y = _countdown.height * 0.55;
				_white.width = _countdown.height * 1.1;
				_white.height = _countdown.height * 1.1;
				_white.x = _countdown.x;
				_white.y = _countdown.y;
			}
		}
		
		/*
		############################# TITLE #############################
		*/
		private function initTitle():void {
			// title
			_title = new TextField();
			_f.size = 20;
			_title.defaultTextFormat = _f;
			_f.size = 18;
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
		############################# CLOCK #############################
		*/
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
		
		/*private function findLongestAnswer():int {
			var maxLength:int = 0;
			var l:int;
			var tf:TextField = new TextField();
			tf.defaultTextFormat = _f;
			tf.autoSize = TextFieldAutoSize.LEFT;
			var len:uint = _xml.body.seq.length();
			for(var i:uint = 0; i < len; i++) {
				var beg:String = _xml.body.seq[i].par.(@id == "gapfill").text.(@id == "beg");
				var mid:String = _xml.body.seq[i].par.(@id == "gapfill").text.(@id == "mid");
				var end:String = _xml.body.seq[i].par.(@id == "gapfill").text.(@id == "end");
				var answer:String = beg + " " + mid + " " + end;
				tf.text = answer;
				l = tf.width;
				if(l > maxLength) {
					maxLength = l;
				}
			}
			tf = null;
			return l;
		}*/
		
		/*
		############################# EXAMPLE #############################
		*/
		private function initExample():void {
			_example = new TextField();
			_f.align = TextFormatAlign.CENTER;
			_example.defaultTextFormat = _f;
			_f.align = TextFormatAlign.LEFT;
			_example.embedFonts = true;
			_example.antiAliasType = AntiAliasType.ADVANCED;
			_example.autoSize = TextFieldAutoSize.LEFT;
			_example.multiline = true;
			_example.selectable = false;
			var question:String = _xml.body.seq[0].par.(@id == "question").text[0];
			var beg:String = _xml.body.seq[0].par.(@id == "gapfill").text.(@id == "beg");
			var mid:String = _xml.body.seq[0].par.(@id == "gapfill").text.(@id == "mid");
			var end:String = _xml.body.seq[0].par.(@id == "gapfill").text.(@id == "end");
			var answer:String = beg + " " + mid + " " + end;
			// keyword may not be present
			var keyword:String;
			if(_xml.body.seq[0].par.(@id == "keyword").text[0]) {
				keyword = "		" + _xml.body.seq[0].par.(@id == "keyword").text[0];
			} else {
				keyword = "<->";
			}
			if(question != "" && answer != "") {
				_example.text = question + "\n" + keyword + "\n" + answer;
			}
			addChild(_example);
		}
		
		private function positionExample():void {
			if(_example) {
				_example.x = stage.stageWidth * 0.5 - (_example.width * 0.5);
				_example.y = stage.stageHeight * 0.08;
			}
		}
		
		/*
		############################# SCORE BAR #############################
		*/
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
		private function positionScoreBar():void {
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
		
		/*
		############################# QUESTION TEXT FIELD #############################
		*/
		// text field for clue word and keyword
		private function initQuestion():void {
			_question = new TextField();
			_question.defaultTextFormat = _f;
			_question.embedFonts = true;
			_question.antiAliasType = AntiAliasType.ADVANCED;
			_question.autoSize = TextFieldAutoSize.LEFT;
			_question.selectable = false;
			addChild(_question);
		}
		
		private function positionQuestion():void {
			if(_question) {
				_question.x = 10;
				_question.y = stage.stageHeight * 0.23;
			}
		}
		
		/*
		############################# ANSWERS TEXT FIELD #############################
		*/
		private function initAnswers():void {
			var format:TextFormat = new TextFormat(Lang.FONT,16,0);
			_answers = new TextField();
			_answers.defaultTextFormat = format;
			_answers.embedFonts = true;
			_answers.antiAliasType = AntiAliasType.ADVANCED;
			_answers.wordWrap = true;
			_answers.selectable = false;
			_answers.text = "";
			addChild(_answers);
		}
		
		private function positionAnswers():void {
			if(_answers) {
				_answers.x = 10;
				_answers.y = stage.stageHeight * 0.5;
				_answers.width = stage.stageWidth - 20;
				_answers.height = stage.stageHeight * 0.5;
			}
		}
		
		/*
		############################ INSTRUCTIONS #############################
		*/
		private function initInstructions():void {
			var message:String = _titleText + "\n\n" + _introText;
			_um = new UserMessage(message);
			_um.addEventListener(MouseEvent.MOUSE_UP, instructionsUp);
			_um.addOK = true;
			_um.buttonMode = true;
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function instructionsUp(event:MouseEvent):void {
			_um.removeEventListener(MouseEvent.MOUSE_UP, instructionsUp);
			umClickedHandler(null);
			_clock.startClock();
			_cs = new CheckString();
			initFloat();
			nextWord();
			initEndAndSend();
			positionEndAndSend();
		}
		
		/*
		############################ PROCESSES #############################
		*/
		private function timeOutHandler(event:Event):void {
			showRedWord();
			removeChild(_blank);
			_blank = null;
			_countdown.reset();
			deleteText();
			nextWord();
		}
		
		// create user input text field
		private function initFloat():void {
			_float = new TextField();
			_float.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUp);
			_float.type = TextFieldType.INPUT;
			_float.defaultTextFormat = _f;
			_float.embedFonts = true;
			_float.antiAliasType = AntiAliasType.ADVANCED;
			addChild(_float);
		}
		
		// clear user input text field
		private function positionFloat():void {
			if(_float) {
				_float.width = _blank.width;
				_float.height = _blank.height;
				_float.x = _blank.x;
				_float.y = _blank.y;
				_float.maxChars = _blank.word.length;
				_float.text = "";
				stage.focus = _float;
				addChild(_float);
			}
		}
		
		// select next word
		private function nextWord():void {
			if(_index < _length) {
				createWord();
				positionWord();
				positionFloat();
				if(_index > 0) {
					_countdown.start(_time);
				}
				_index++;
			} else {
				deleteEndAndSend();
				endActivity();
			}
		}
		
		// create next new word
		private function createWord():void {
			var index:uint = _si.ind[_index];
			var question:String = _xml.body.seq[index].par.(@id == "question").text[0];
			var keyword:String = _xml.body.seq[index].par.(@id == "keyword").text[0];
			if(!keyword) {
				keyword = "";
			}
			_question.text = question + "\n     " + keyword + "\n";
			_time = question.length * _difficulty * 1000; // adjust countdown time to length of question
			//
			var beg:String = _xml.body.seq[index].par.(@id == "gapfill").text.(@id == "beg");
			if(beg != "" && beg != null) {
				_beg = new TextField();
				_beg.defaultTextFormat = _f;
				_beg.embedFonts = true;
				_beg.antiAliasType = AntiAliasType.ADVANCED;
				_beg.autoSize = TextFieldAutoSize.LEFT;
				_beg.text = beg;
				addChild(_beg);
			}
			//
			var mid:String = _xml.body.seq[index].par.(@id == "gapfill").text.(@id == "mid");
			_blank = new BlankWord(mid,0,0,0,false);
			_blank.height += 5;
			//
			var end:String = _xml.body.seq[index].par.(@id == "gapfill").text.(@id == "end");
			if(end != "" && end != null) {
				_endText = new TextField();
				_endText.defaultTextFormat = _f;
				_endText.embedFonts = true;
				_endText.antiAliasType = AntiAliasType.ADVANCED;
				_endText.autoSize = TextFieldAutoSize.LEFT;
				_endText.text = end;
				addChild(_endText);
			}
			addChild(_blank);
		}
		
		private function positionWord():void {
			var posX:int = 10;
			var posY:int = stage.stageHeight * 0.33;
			if(_beg) {
				_beg.x = posX;
				_beg.y = posY;
				posX += _beg.width + 2;
			}
			if(_blank) {
				_blank.x = posX;
				_blank.y = posY;
				_blank.width = (_blank.word.length * 9) + 15;
				posX += _blank.width + 2;
			}
			if(_endText) {
				_endText.x = posX;
				_endText.y = posY;
			}
		}
		
		private function deleteText():void {
			if(_beg){
				removeChild(_beg);
				_beg = null;
			}
			if(_endText){
				removeChild(_endText);
				_endText = null;
			}
		}
		
		// check user input text against answer
		private function keyUp(event:KeyboardEvent):void {
			var original:String = _blank.word;
			var input:String = _float.text;
			var a:Array = _cs.checkIt(original,input);
			if(a[0] == true){
				addTick();
				wordCompleted();// user input is correct
			} else {
				var f:TextFormat = new TextFormat();
				// loop through string character by character
				var len:uint = input.length;
				for(var i:uint = 0; i < len; i++) {
					// set TextFormat colour to value in returned array
					f.color = a[i];
					_float.setTextFormat(f,i,i+1);
				}
			}
		}
		
		// keep focus on user input text field
		private function stageUp(event:MouseEvent):void {
			if(_float) {
				stage.focus = _float;
			}
		}
		
		// add word to list of displayed words
		private function wordCompleted():void {
			_completed++;
			showWord(0x000000);
			removeChild(_blank);
			_blank = null;
			deleteText();
			nextWord();
		}
		
		// words not completed shown in red
		private function showRedWord():void {
			addCross();
			showWord(0xDD0000);
		}
		
		//
		private function addTick():void {
			var tick:Tick = new Tick();
			tick.x = 2;
			tick.y = 16;
			_numbers[_index - 1].addChild(tick);
		}
		
		//
		private function addCross():void {
			var cross:Cross = new Cross();
			cross.x = 2;
			cross.y = 16;
			_numbers[_index - 1].addChild(cross);
		}
		
		// add word to list of displayed words
		private function showWord(n:Number):void {
			var format:TextFormat = new TextFormat(Lang.FONT,16,n);
			if(_index > 0) {
				var index:uint = _si.ind[_index - 1];
			} else {
				index = _si.ind[_index];
			}
			var question:String = String(_xml.body.seq[index].question.text);
			var beg:String = String(_xml.body.seq[index].par.(@id == "gapfill").text.(@id == "beg"));
			var mid:String = String(_xml.body.seq[index].par.(@id == "gapfill").text.(@id == "mid"));
			var end:String = String(_xml.body.seq[index].par.(@id == "gapfill").text.(@id == "end"));
			var before:int = _answers.text.length - 1;
			var answer:String = question + "   >>> " + beg + " " + mid + " " + end;
			if(answer.length > 65) {
				answer += "\n";
			}
			_answers.appendText(answer);
			var after:int = _answers.text.length - 1;
			_answers.setTextFormat(format,before,after);
		}
		
		/*
		############################ END ACTIVITY BUTTON #############################
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
				_end.y = stage.stageHeight * 0.95;
			}
		}
		
		private function deleteEndAndSend():void {
			if(_end) {
				removeChild(_end);
				_end = null;
			}
		}
		
		private function endUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, endUp);
			deleteEndAndSend();
			endActivity();
		}
		
		/*
		########################## END ACTIVITY ###########################
		*/
		private function endActivity():void {
			_float.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			_countdown.stop();
			_clock.stopClock();
			removeChild(_float);
			_float = null;
			_blank = null;
			_percent = Math.round(_completed / _length * 100);
			var msg:String = Lang.YOUVE_COMPLETED + " " + _percent + "%\n" + Lang.TIME + _clock.time;
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
			_obj.feedback = _completed + "/" + _length + " " + Lang.SENTENCES + " " + Lang.COMPLETED_END + "."; // (String) optional
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
}
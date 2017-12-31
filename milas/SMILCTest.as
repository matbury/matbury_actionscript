/*
    SMILCTest Multimedia Interactive Learning Application (MILA).

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
	import com.matbury.milas.UpdateGradeURLVars;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.TextColors;
	
	public class SMILCTest extends Sprite {
		
		private var _version:String = "2014.04.20";
		private var _amf:Amf;
		private var _sg:UpdateGradeURLVars;
		private var _obj:Object; // grade data object
		private var _xml:XML;
		private var _smil:Namespace;
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _length:uint;
		private var _clock:Clock;
		private var _cmenu:CMenu;
		private var _dsf:DropShadowFilter;
		private var _f:TextFormat;
		private var _inputText:TextField;
		private var _inputSource:TextField;
		private var _inputSourceLabel:TextField;
		private var _sourceText:String = "";
		private var _input:Boolean = false;
		private var _make:Btn;
		private var _wordsCompleted:int = 0;
		private var _percent:int = 0;
		private var _score:Array;
		private var _title:TextField;
		private var _scoreDisplay:TextField;
		private var _um:UserMessage;
		private var _tf:TextField;
		private var _titleText:String;
		private var _intro:String;
		private var _textColors:TextColors;
		private var _paragraph:String = "";
		private var _firstWords:Array;
		private var _wordGroups:Array;
		private var _words:Array;
		private var _posX:int;
		private var _posY:int;
		private var _cs:CheckString;
		private var _float:TextField;
		private var _currentWord:BlankWord;
		private var _lastIndex:int;
		private var _end:Btn;
		
		public function SMILCTest() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			/* 
			FlashVars.xmlurl = "../xml/ctest.smil";
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
			positionScoreDisplay();
			positionTitle();
			positionClock();
			positionTextColors();
			positionEndAndSend();
			positionWords();
			positionFloat();
			positionInputText();
			positionInputSource();
			positionMake();
		}
		
		/*
		######################### SECURITY CHECK ##########################
		*/
		private function licenceCheck():void {
			var sc:LicenceCheck = new LicenceCheck();
			var checked:Boolean = sc.check(this.root.loaderInfo.url);
			if(checked) {
				if(this.root.loaderInfo.parameters.input) {
					initVars();
					_input = true;
					initInteraction();
				} else 
				if(this.root.loaderInfo.parameters.paragraph) {
					initVars();
					initInteraction();
				} else {
					initLoadBar();
					positionLoadBar();
					loadData();
				}
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
		
		private function initVars():void {
			if(this.root.loaderInfo.parameters.title) {
				_titleText = this.root.loaderInfo.parameters.title;
			} else {
				_titleText = "C-Test";
			}
			if(this.root.loaderInfo.parameters.instructions) {
				_intro = this.root.loaderInfo.parameters.instructions;
			} else {
				_intro = Lang.FILL_IN + " " + Lang.WORDS + ".";
			}
			if(this.root.loaderInfo.parameters.paragraph) {
				_paragraph = this.root.loaderInfo.parameters.paragraph;
			}
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
			try {
				_titleText = _loadXML.xml.head.meta.(@name == "Title").@content;
			} catch(e:Error) {
				_titleText = "C-Test";
			}
			try {
				_intro = _loadXML.xml.head.meta.(@name == "Intro").@content;
			} catch(e:Error) {
				_intro = "Completed the missing letters in the paragraph.";
			}
			try {
				_paragraph = _loadXML.xml.body.seq.par[0].(@id == "answer").text;
				initInteraction();
			} catch(e:Error) {
				showError(Lang.NO_ACTIVITY_DATA);
				positionUserMessage();
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
			initScoreDisplay();
			initTitle();
			initClock();
			initTextColors();
			//
			if(_input) {
				initInputText();
				initInputSource();
				initMake();
			} else 
			if(_paragraph.length < 300) {
				showError(Lang.INCORRECT_DATA);
				positionUserMessage();
			} else {
				createFirstTwoSentences();
				positionWords();
				initInstructions();
				positionUserMessage();
			}
			resize(null);
		}
		
		/*
		############################ INPUT TEXT #############################
		*/
		private function initInputText():void {
			_f.size = 20;
			_inputText = new TextField();
			_inputText.type = TextFieldType.INPUT;
			//_inputText.restrict = "a-z A-Z 0-9 . , \\- ! ? "; // Doesn't allow ' characters!
			_inputText.restrict = "^“”’/"; // Try a more permissive strategy
			_inputText.defaultTextFormat = _f;
			_inputText.embedFonts = true;
			_inputText.antiAliasType = AntiAliasType.ADVANCED;
			_inputText.wordWrap = true;
			_inputText.border = true;
			_inputText.text = "";
			_title.text = "Copy and paste C-Test paragraph text into text box below...";
			addChild(_inputText);
		}
		
		private function positionInputText():void {
			if(_inputText) {
				_inputText.width = stage.stageWidth * 0.8;
				_inputText.height = stage.stageHeight * 0.6;
				_inputText.x = stage.stageWidth * 0.1;
				_inputText.y = stage.stageHeight * 0.15;
				stage.focus = _inputText;
			}
		}
		
		private function deleteInputText():void {
			if(_inputText) {
				removeChild(_inputText);
				_inputText = null;
			}
		}
		
		private function initInputSource():void {
			_f.size = 20;
			_inputSourceLabel = new TextField();
			_inputSourceLabel.autoSize = TextFieldAutoSize.LEFT;
			_inputSourceLabel.defaultTextFormat = _f;
			_inputSourceLabel.embedFonts = true;
			_inputSourceLabel.antiAliasType = AntiAliasType.ADVANCED;
			_inputSourceLabel.text = "Source: ";
			addChild(_inputSourceLabel);
			_inputSource = new TextField();
			_inputSource.type = TextFieldType.INPUT;
			_inputSource.defaultTextFormat = _f;
			_inputSource.embedFonts = true;
			_inputSource.antiAliasType = AntiAliasType.ADVANCED;
			_inputSource.border = true;
			_inputSource.text = "";
			addChild(_inputSource);
		}
		
		private function positionInputSource():void {
			if(_inputSourceLabel) {
				_inputSourceLabel.height = 28;
				_inputSourceLabel.x = stage.stageWidth * 0.1;
				_inputSourceLabel.y = stage.stageHeight * 0.8;
			}
			if(_inputSource) {
				_inputSource.width = (stage.stageWidth * 0.8) - _inputSourceLabel.width;
				_inputSource.height = 28;
				_inputSource.x = (stage.stageWidth * 0.1) + _inputSourceLabel.width;
				_inputSource.y = stage.stageHeight * 0.8;
			}
		}
		
		private function deleteInputSource():void {
			if(_inputSource) {
				removeChild(_inputSource);
				_inputSource = null;
			}
			if(_inputSourceLabel) {
				removeChild(_inputSourceLabel);
				_inputSourceLabel = null;
			}
		}
		
		/*
		############################ MAKE TEST BUTTON #############################
		*/
		private function initMake():void {
			_make = new Btn("Make C-Test");
			_make.addEventListener(MouseEvent.MOUSE_UP, makeUp);
			addChild(_make);
		}
		
		private function positionMake():void {
			if(_make) {
				_make.x = stage.stageWidth * 0.5;
				_make.y = stage.stageHeight * 0.95;
			}
		}
		
		private function deleteMake():void {
			if(_make) {
				removeChild(_make);
				_make = null;
			}
		}
		
		private function makeUp(event:MouseEvent):void {
			_paragraph = _inputText.text;
			_sourceText = _inputSource.text;
			if(_paragraph.length < 300) {
				showError("The input text is too short.\nPlease input a longer paragraph.");
				positionUserMessage();
				startTimer();
			} else {
				_title.text = _titleText;
				positionTitle();
				deleteInputText();
				deleteInputSource();
				deleteMake();
				createFirstTwoSentences();
				positionWords();
				initEndAndSend();
				positionEndAndSend();
				initFloat();
				initCompareStrings();
				positionFloat();
				addWordListeners();
			}
		}
		
		private function startTimer():void {
			var timer:Timer = new Timer(1000,5);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			timer.start();
		}
		
		private function timerComplete(event:TimerEvent):void {
			var timer:Timer = event.target as Timer;
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerComplete);
			removeChild(_um);
			_um = null;
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
		############################ SCORE DISPLAY #############################
		*/
		private function initScoreDisplay():void {
			_scoreDisplay = new TextField();
			_f.size = 20;
			_scoreDisplay.defaultTextFormat = _f;
			_scoreDisplay.embedFonts = true;
			_scoreDisplay.antiAliasType = AntiAliasType.ADVANCED;
			_scoreDisplay.autoSize = TextFieldAutoSize.LEFT;
			_scoreDisplay.selectable = false;
			_scoreDisplay.text = Lang.COMPLETED + _percent + "%";
			positionScoreDisplay();
			addChild(_scoreDisplay);
		}
		
		private function positionScoreDisplay():void {
			if(_scoreDisplay) {
				_scoreDisplay.x = stage.stageWidth - _scoreDisplay.width;
				_scoreDisplay.y = stage.stageHeight - _scoreDisplay.height;
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
		############################ TEXT COLOURS #############################
		*/
		private function initTextColors():void {
			_textColors = new TextColors();
			addChild(_textColors);
		}
		
		private function positionTextColors():void {
			if(_textColors) {
				_textColors.x = 0;
				_textColors.y = stage.stageHeight - _textColors.height;
			}
		}
		
		/*
		############################ INSTRUCTIONS #############################
		*/
		private function initInstructions():void {
			var message:String = _titleText + "\n\n" + _intro;
			_um = new UserMessage(message);
			_um.addEventListener(MouseEvent.MOUSE_UP, instructionsUp);
			_um.buttonMode = true;
			_um.addOK = true;
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function instructionsUp(event:MouseEvent):void {
			_um.removeEventListener(MouseEvent.MOUSE_UP, instructionsUp);
			removeChild(_um);
			_um = null;
			// This is where the user interaction starts
			_clock.startClock();
			initEndAndSend();
			positionEndAndSend();
			initFloat();
			initCompareStrings();
			positionFloat();
			addWordListeners();
		}
		
		/*
		############################ CREATE TEXT #############################
		*/
		private function createFirstTwoSentences():void {
			_firstWords = new Array();
			// get first two sentences, which are left intact
			var sentences:Array = _paragraph.split(".");
			var firstTwo:String = sentences[0] + "." + sentences[1] + ".";
			var words:Array = firstTwo.split(" ");
			// create text fields for words
			var len:uint = words.length;
			for(var i:uint = 0; i < len; i++) {
				var b:BlankWord = new BlankWord(words[i], 0, 0, 0);
				b.showText();
				addChild(b);
				_firstWords.push(b);
			}
			// get the rest of the paragraph
			var index:uint = firstTwo.length;
			var nextSentences:String = _paragraph.substring(index + 1,_paragraph.length);
			createNextSentences(nextSentences);
		}
		
		// create input text
		private function createNextSentences(sentences:String):void {
			_wordGroups = new Array();
			_words = new Array();
			_score = new Array();
			var words:Array = sentences.split(" ");
			var len:uint = words.length;
			var index:uint = 0;
			for(var i:uint = 0; i < len; i+=2) {
				var wordGroup:Object = new Object();
				var obj:Object = getHalfWord(words[i]);
				// create first half of first word
				if(obj.first != "") {
					var b1:BlankWord = new BlankWord(obj.first, 0, 0, 0);
					b1.showText();
					addChild(b1);
					_posX += b1.width - 6;
					wordGroup.a = b1;
				} else {
					wordGroup.a = null;
				}
				// create second half of first word
				var b2:BlankWord = new BlankWord(obj.second, 0, 0, index);
				index++;
				addChild(b2);
				_words.push(b2);
				_score.push(false);
				wordGroup.b = b2;
				// Make sure we stay within words array length limits for second word
				if(i < len - 1) {
					var b3:BlankWord = new BlankWord(words[i + 1], 0, 0, 0);
					b3.showText();
					addChild(b3);
					wordGroup.c = b3;
				} else {
					wordGroup.c = null;
				}
				_wordGroups.push(wordGroup);
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageFocusHandler);
		}
		
		private function getHalfWord(word:String):Object {
			var obj:Object = new Object();
			if(word.toLowerCase() != "a") {
				// split word into 2 halves, the second being longer than the first if uneven number of letters
				var len:uint = word.length;
				var index:uint = Math.floor(len * 0.5);
				obj.first = word.substring(0,index);
				obj.second = word.substring(index,len);
			} else {
				obj.first = "";
				obj.second = word;
			}
			return obj;
		}
		
		private function positionWords():void {
			var posX:int = 5;
			var posY:int = stage.stageHeight * 0.1;
			if(_firstWords) {
				var len:uint = _firstWords.length;
				for(var i:uint = 0; i < len; i++) {
					if(posX + _firstWords[i].width > stage.stageWidth) {
						posX = 5;
						posY += _firstWords[i].height + 5;
					}
					_firstWords[i].x = posX;
					_firstWords[i].y = posY;
					posX += _firstWords[i].width + 4;
				}
			}
			if(_wordGroups) {
				len = _wordGroups.length;
				for(i = 0; i < len; i++) {
					//
					if(_wordGroups[i].a) {
						if(posX + _wordGroups[i].a.width + _wordGroups[i].b.width > stage.stageWidth) {
							posX = 5;
							posY += _wordGroups[i].a.height + 5;
						}
						_wordGroups[i].a.x = posX + 3;
						_wordGroups[i].a.y = posY;
						posX += _wordGroups[i].a.width;
					}
					if(_wordGroups[i].b) {
						_wordGroups[i].b.x = posX - 3;
						_wordGroups[i].b.y = posY;
						posX += _wordGroups[i].b.width;
					}
					if(_wordGroups[i].c) {
						if(posX + _wordGroups[i].c.width > stage.stageWidth) {
							posX = 5;
							posY += _wordGroups[i].c.height + 5;
						}
						_wordGroups[i].c.x = posX;
						_wordGroups[i].c.y = posY;
						posX += _wordGroups[i].c.width;
					}
				}
			}
		}
		
		// add mouse listeners to select input words
		private function addWordListeners():void {
			var len:uint = _words.length;
			for(var i:uint = 0; i < len; i++) {
				_words[i].addEventListener(MouseEvent.MOUSE_DOWN, wordDownHandler);
			}
		}
		
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
				_end.y = stage.stageHeight - _end.height + 3;
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
			checkScore();
			endActivity();
		}
		
		/*
		############################ HANDLE USER INPUT #############################
		*/
		private function stageFocusHandler(event:MouseEvent):void {
			if(_float) {
				stage.focus = _float;
			}
		}
		
		private function initFloat():void {
			_float = new TextField();
			_float.type = TextFieldType.INPUT;
			_f.size = 15;
			_float.defaultTextFormat = _f;
			_float.embedFonts = true;
			_float.antiAliasType = AntiAliasType.ADVANCED;
			_float.restrict = "a-z\\-'";
			_float.text = "";
			_float.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addChild(_float);
			_currentWord = _words[0];
			_currentWord.filters = [_dsf];
			_lastIndex = _words[0].i;
		}
		
		private function initCompareStrings():void {
			_cs = new CheckString();
		}
		
		/*
		######################## COMPARE USER INPUT ########################
		*/
		
		function keyUpHandler(event:KeyboardEvent):void {
			compareStrings();
		}
		
		private function compareStrings():void {
			var input:String = _float.text;
			var original:String = _currentWord.word;
			var len:uint = input.length;
			var a:Array = _cs.checkIt(original,input);
			if(a[0] == true){
				_currentWord.removeEventListener(MouseEvent.MOUSE_DOWN, wordDownHandler);
				_currentWord.showText();
				_currentWord.finished = true;
				var index:uint = _currentWord.i;
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
			_scoreDisplay.text = Lang.COMPLETED + _percent + "%";
			positionScoreDisplay();
			var time:String = _clock.time;
			if(score >= len) {
				deleteEndAndSend();
				endActivity();
			}
		}
		
		private function wordDownHandler(event:MouseEvent):void {
			_currentWord = event.currentTarget as BlankWord;
			_lastIndex = _currentWord.i;
			positionShadow();
			positionFloat();
		}
		
		private function positionShadow():void {
			var len:uint = _words.length;
			for(var i:uint = 0; i < len; i++) {
				_words[i].filters = [];
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
			var len:uint = _words.length;
			// if we're at the last word, go to first word
			if(_lastIndex >= len -1) {
				_lastIndex = 0;
			}
			// are there any unfinished words after this one?
			var finished:Boolean = true;
			for(var i:uint = _lastIndex; i < len; i++) {
				if(_words[i].finished == false) {
					finished = false;
				}
			}
			// if there are unfinished words, look for the next one
			if(!finished) {
				for(i = _lastIndex; i < len; i++) {
					if(_words[i].finished == false) {
						_currentWord = _words[i];
						_lastIndex = _words[i].i;
						positionFloat();
						positionShadow();
						break;
					}
				}
				// if there aren't any finished words, go to first word
			} else {
				_lastIndex = 0;
				for(i = _lastIndex; i < len; i++) {
					if(_words[i].finished == false) {
						_currentWord = _words[i];
						_lastIndex = _words[i].i;
						positionFloat();
						positionShadow();
						break;
					}
				}
			}
		}
		
		private function endActivity():void {
			_clock.stopClock();
			removeChild(_float);
			var message:String = Lang.YOUVE_COMPLETED + _wordsCompleted + "/" + _words.length + " " + Lang.WORDS + ".";
			_um = new UserMessage(message);
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
		// Try to send grade via AmfPHP first. If that fails, send via URLVariables.
		private function sendGrade():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			// prepare grade data object
			_obj = new Object();
			_obj.feedback = _wordsCompleted + "/" + _words.length + " " + Lang.WORDS + " " + Lang.COMPLETED_END + ".\n Text: " + _paragraph + ".\n Text source: " + _sourceText; // (String) optional
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
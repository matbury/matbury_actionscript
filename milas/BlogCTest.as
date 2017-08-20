/*
	XMLCTest Multimedia Interactive Learning Application (MILA).
	Copyright © 2011 Matt Bury All rights reserved.
	http://matbury.com/
	matbury@gmail.com
*/
package com.matbury.milas {
	
	import flash.desktop.*;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
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
	import com.matbury.UserMessage;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.Fullscreen;
	import com.matbury.sam.gui.TextColors;
	
	public class BlogCTest extends Sprite {
		
		private var _version:String = "2014.04.24";
		private var _length:uint;
		private var _clock:Clock;
		private var _cmenu:CMenu;
		private var _dsf:DropShadowFilter;
		private var _f:TextFormat;
		private var _inputText:TextField;
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
		private var _copyText:String = "";
		private var _copy:Btn;
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
		private var _fullScreen:Fullscreen;
		
		public function BlogCTest() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			licenceCheck();
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
		}
		
		private function resize(event:Event):void {
			positionUserMessage();
			positionScoreDisplay();
			positionTitle();
			positionClock();
			positionTextColors();
			positionEndAndSend();
			positionCopy();
			positionWords();
			positionFloat();
			positionInputText();
			positionMake();
			positionFullScreen();
		}
		
		/*
		######################### SECURITY CHECK ##########################
		*/
		private function licenceCheck():void {
			var sc:LicenceCheck = new LicenceCheck();
			var checked:Boolean = sc.check(this.root.loaderInfo.url);
			if(checked) {
				initVars();
				_input = true;
				initInteraction();
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
			_titleText = "C-Test";
			//showError(Lang.NO_ACTIVITY_DATA);
			//positionUserMessage();
		}
		
		/*
		########################## INTERACTION #############################
		*/
		private function initInteraction():void {
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			_f = new TextFormat(Lang.FONT,15,0,true);
			initScoreDisplay();
			initTitle();
			initClock();
			initTextColors();
			//
			if(_input) {
				initInputText();
				initMake();
				initFullScreen();
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
			_f.size = 16;
			_inputText = new TextField();
			_inputText.type = TextFieldType.INPUT;
			//_inputText.restrict = "a-z A-Z 0-9 . , \\- ! ? "; // Doesn't allow ' characters!
			_inputText.restrict = "^“”‘’0-9(){}[]<>&*_\#\/+"; //‘ Try a more permissive strategy
			_inputText.defaultTextFormat = _f;
			_inputText.embedFonts = true;
			_inputText.antiAliasType = AntiAliasType.ADVANCED;
			_inputText.wordWrap = true;
			_inputText.border = true;
			_inputText.text = "";
			_title.text = "Copy (Ctrl + c) and paste (Ctrl + v) at least\n3 sentences of text into text box below...";
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
			//_paragraph = "The British government will on Thursday agree an historic compensation payment to victims of one of the darkest episodes of the country's imperial past and express its sincere regret for the torture inflicted upon thousands of people imprisoned during Kenya's Mau Mau insurgency. In a statement to MPs, William Hague, foreign secretary, is expected to announce payments of £2,600 each to more than 5,000 survivors of the vast network of prison camps that the British authorities established across its colony during the bloody 1950s conflict: a total of about £14m. After weeks of negotiations with lawyers representing three elderly former prisoners who brought a series of test cases in the high court in London, the government has agreed also to fund the construction of a memorial in Nairobi to Kenya's victims of colonial-era torture.";
			if(_paragraph.length < 300) {
				showError("The input text is too short.\nPlease input a longer paragraph.");
				positionUserMessage();
				startTimer();
			} else {
				_title.text = _titleText;
				deleteInputText();
				deleteMake();
				createFirstTwoSentences();
				initEndAndSend();
				deleteCopy();
				initCopy();
				initFloat();
				initCompareStrings();
				resize(null);
				addWordListeners();
				_clock.startClock();
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
			_f.size = 18;
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
			_copyText = firstTwo;
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
				// Create copy and paste version of c-test in _copyText
				var regexp:RegExp = new RegExp("[A-Za-z]","g");
				_copyText += " " + obj.first + obj.second.replace(regexp,"_");
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
					_copyText += " " + words[i + 1]; // Add complete words to copy and paste version of c-test
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
		
		/*
		######################### END AND RESTART ##########################
		*/
		// User can click this button to stop the dictation and send the results
		// to the grade book
		private function initEndAndSend():void {
			_end = new Btn("Score");
			_end.addEventListener(MouseEvent.MOUSE_UP, endUp);
			addChild(_end);
		}
		
		private function positionEndAndSend():void {
			if(_end) {
				_end.x = stage.stageWidth * 0.44;
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
			_end.removeEventListener(MouseEvent.MOUSE_UP, endUp);
			_end.label = "New C-Test";
			checkScore();
			endActivity();
			_end.addEventListener(MouseEvent.MOUSE_UP, newCTest);
		}
		
		private function newCTest(event:MouseEvent):void {
			var url:String = "http://blog.matbury.com/2013/01/10/free-online-interactive-c-test-generator/";
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request, "_self");
		}
		
		/*
		######################### COPY TEXT TO CLIP BOARD ##########################
		*/
		private function initCopy():void {
			_copy = new Btn("Copy");
			_copy.addEventListener(MouseEvent.MOUSE_UP, copyUp);
			addChild(_copy);
		}
		
		private function positionCopy():void {
			if(_copy) {
				_copy.x = stage.stageWidth * 0.56;
				_copy.y = stage.stageHeight - _copy.height + 3;
			}
		}
		
		private function deleteCopy():void {
			if(_copy) {
				_copy.removeEventListener(MouseEvent.MOUSE_UP, copyUp);
				removeChild(_copy);
				_copy = null;
			}
		}
		
		private function copyUp(event:MouseEvent):void {
			_copy.label = "Copied";
			_copyText = "C-Test\n\n" + _copyText + "\n\nThis test was generated by C-Test app © Matt Bury 2012 All rights reserved | matbury.com at http://blog.matbury.com/2013/01/10/free-online-interactive-c-test-generator/\n\nPlease check that you have appropriate permission from the copyright holder to reproduce the text used to generate this test.";
			Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _copyText);
		}
		
		/*
		######################### FULLSCREEN MODE SWITCHING ##########################
		*/
		private function initFullScreen():void {
			_fullScreen = new Fullscreen();
			_fullScreen.addEventListener(MouseEvent.MOUSE_UP, toggleFullScreen);
			addChild(_fullScreen);
		}
		
		private function positionFullScreen():void {
			if(_fullScreen) {
				_fullScreen.x = _fullScreen.width * 0.5 + 2;
				_fullScreen.y = _fullScreen.height * 0.5 + 2;
			}
		}
		
		private function deleteFullScreen():void {
			if(_fullScreen) {
				removeChild(_fullScreen);
				_fullScreen = null;
			}
		}
		
		private function toggleFullScreen(event:MouseEvent):void {
			_fullScreen.rotateArrows();
			switch(stage.displayState) {
				case StageDisplayState.NORMAL:
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;//"fullScreen";
				break;
				case StageDisplayState.FULL_SCREEN_INTERACTIVE:
				default:
				stage.displayState = StageDisplayState.NORMAL;//"normal";    
				break;
			}
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
		
		private function deleteFloat():void {
			if(_float) {
				removeChild(_float);
				_float = null;
			}
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
			deleteFloat();
			deleteCopy();
			var message:String = Lang.YOUVE_COMPLETED + _wordsCompleted + "/" + _words.length + " " + Lang.WORDS + ".";
			_um = new UserMessage(message);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.addOK = true;
			_um.filters = [_dsf];
			addChild(_um);
			positionUserMessage();
		}
		
		private function umClickedHandler(event:Event):void {
			if(_um) {
				_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
				removeChild(_um);
				_um = null;
			}
		}
	}
}
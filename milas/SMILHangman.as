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
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.*;
	import flash.text.*;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.filters.DropShadowFilter;
	import com.matbury.CMenu;
	import com.matbury.Clock;
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
	import com.matbury.sam.gui.Pointer;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.TextColors;
	import com.matbury.sam.gui.Tick;
	
	public class SMILHangman extends Sprite {
		
		private var _version:String = "2014.04.24";
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
		private var _clockVisible:Boolean = true;
		private var _dsf:DropShadowFilter;
		private var _speakers:Speakers;
		private var _f:TextFormat;
		private var _numbers:Array;
		private var _um:UserMessage;
		private var _indexes:Array;
		private var _si:ShuffledIndex;
		private var _index:uint;
		private var _numChars:uint = 11;
		private var _numWrong:uint = 0;
		private var _charsUsed:Array;
		private var _score:uint = 0;
		private var _played:uint = 0;
		private var _countText:TextField;
		private var _gameText:TextField;
		private var _shown:String;
		private var _ticked:Array;
		private var _letters:Array;
		private var _man:Man;
		private var _manArray:Array;
		private var _start:Btn;
		private var _next:Btn;
		private var _sentence:String;
		private var _shuffle:Boolean = true;
		private var _image:SMILImage;
		private var _imageLoaded:Boolean = false;
		private var _end:Btn;
		private var _offsetY:int = 0;
		
		public function SMILHangman() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			/*
			FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects.smil";
			FlashVars.moodledata = "../";
			initLoadBar();
			positionLoadBar();
			loadData();
			*/
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			stage.addEventListener(Event.RESIZE, resize);
			initCMenu();
			securityCheck();
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
		}
		
		private function resize(event:Event):void {
			positionLoadBar();
			positionClock();
			adjustScoreBar(); // always adjust scorebar before the other objects
			positionText();
			positionLetters();
			positionMan();
			positionSpeakers();
			positionStart();
			positionNext();
			positionEndAndSend();
			positionUserMessage();
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
			removeChild(_loadBar);
			_loadBar = null;
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
			_f = new TextFormat("Trebuchet MS",20,0,true);
			_f.align = TextFormatAlign.CENTER;
			_length = _xml.body.seq.length(); // get number of XML nodes
			if(_length > 4) {
				_indexes = new Array();
				for(var i:uint = 0; i < _length; i++) {
					_indexes.push(i);
				}
				_si = new ShuffledIndex(_length);
				initClock();
				positionClock();
				initScoreBar();
				adjustScoreBar(); // always adjust scorebar before the other objects
				initText();
				positionText();
				initLetters();
				positionLetters();
				initMan();
				positionMan();
				resetMan();
				initSpeakers();
				positionSpeakers();
			} else {
				showError(Lang.NO_ACTIVITY_DATA);
				positionUserMessage();
			}
		}
		
		private function initParameters():void {
			if(this.root.loaderInfo.parameters.shuffle) {
				var shuffle:String = this.root.loaderInfo.parameters.shuffle;
				if(shuffle == "false") {
					_shuffle = false;
				}
			}
		}
		
		/*
		############################################ CLOCK ############################################
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
		############################################ SCORE BAR ############################################
		*/
		private function initScoreBar():void {
			_numbers = new Array();
			var len:uint = _xml.body.seq.length();
			for(var i:uint = 0; i < len; i++) {
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
				_offsetY = 0;
				for(var i:uint = 0; i < len; i++) {
					_numbers[i].x = posX;
					_numbers[i].y = posY;
					if(posX < stage.stageWidth - (spacing * 2)) {
						posX += spacing;
					} else {
						posX = 2;
						posY += spacing;
						_offsetY += _numbers[i].height;
					}
				}
			}
		}
		
		/*
		############################################ TEXT ############################################
		*/
		private function initText():void {
			// set up the "guesses left" text field
			_countText = new TextField();
			_countText.autoSize = TextFieldAutoSize.LEFT;
			_countText.defaultTextFormat = _f;
			_countText.antiAliasType = AntiAliasType.ADVANCED;
			_countText.embedFonts = true;
			_countText.selectable = false;
			_countText.text = _numChars + " " + Lang.ATTEMPTS_REMAINING + ".";
			addChild(_countText);
			// set up the hangman text field
			_f.letterSpacing = 3;
			_gameText = new TextField();
			_gameText.autoSize = TextFieldAutoSize.LEFT;
			_gameText.defaultTextFormat = _f;
			_gameText.antiAliasType = AntiAliasType.ADVANCED;
			_gameText.embedFonts = true;
			_gameText.wordWrap = true;
			_gameText.selectable = false;
			addChild(_gameText);
		}
		
		private function positionText():void {
			if(_countText) {
				_countText.x = stage.stageWidth * 0.5 - (_countText.width * 0.5);
				_countText.y = stage.stageHeight * 0.73 - _offsetY;
			}
			if(_gameText) {
				_gameText.width = stage.stageWidth * 0.8;
				_gameText.x = (stage.stageWidth * 0.5) - (_gameText.width * 0.5);
				_gameText.y = stage.stageHeight * 0.6 - _offsetY;
			}
		}
		
		/*
		############################################ LETTERS ############################################
		*/
		// row of letters, a-z that get ticked/crossed off when they've been used
		private function initLetters():void {
			_ticked = new Array();
			_letters = new Array();
			var centre:Number = stage.stageWidth * 0.5;
			for(var i:uint = 0; i < 26; i++) {
				var letter:Letter = new Letter();
				letter.txt.text = String.fromCharCode(i + 97);// a,b,c,d,etc.
				addChild(letter);
				_letters.push(letter);
				_ticked.push(false);
			}
		}
		
		private function positionLetters():void {
			if(_letters) {
				var left:Number = 10;
				var space:Number = (stage.stageWidth - (left * 2)) / 26;
				//var posY:int = _numbers[0].y - 70;
				var len:uint = _letters.length;
				for(var i:uint = 0; i < len; i++) {
					_letters[i].x = left + (i * space);
					_letters[i].y = stage.stageHeight * 0.83 - _offsetY;
				}
			}
		}
		
		/*
		############################################ HANGMAN ############################################
		*/
		// hangman graphic display
		private function initMan():void {
			_man = new Man();
			addChild(_man);
			_manArray = new Array(
			_man.barBottom,
			_man.barVert,
			_man.barTop,
			_man.barDiag,
			_man.rope,
			_man.head,
			_man.body,
			_man.armr,
			_man.arml,
			_man.legr,
			_man.legl);
		}
		
		private function positionMan():void {
			if(_man) {
				_man.x = (stage.stageWidth * 0.5) - (_man.width * 0.5);
				_man.y = 20;
			}
		}
		
		// Make hangman body parts invisible
		private function resetMan():void {
			if(_man) {
				var len:uint = _manArray.length;
				for(var i:uint = 0; i < len; i++){
					_manArray[i].visible = false;
				}
			}
		}
		
		/*
		############################################ START BUTTON ############################################
		*/
		// create start button - for first game
		private function initStart():void {
			_start = new Btn(Lang.START);
			addChild(_start);
			_start.addEventListener(MouseEvent.MOUSE_DOWN, startDown);
		}
		
		private function positionStart():void {
			if(_start) {
				_start.x = stage.stageWidth * 0.5;
				_start.y = stage.stageHeight * 0.5;
			}
		}
		
		private function startDown(event:MouseEvent):void {
			_start.removeEventListener(MouseEvent.MOUSE_DOWN, startDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, startUp);
			_clock.startClock();
		}
		
		private function startUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, startUp);
			deleteStart();
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			resetMan();
			clearLetters();
			initLetters();
			positionLetters();
			initHangman();
			initEndAndSend();
			positionEndAndSend();
			stage.focus = _gameText;
		}
		
		private function deleteStart():void {
			if(_start) {
				removeChild(_start);
				_start = null;
			}
		}
		
		/*
		############################################ NEXT BUTTON ############################################
		*/
		// create next button - for subsequent games
		private function initNext():void {
			_next = new Btn(Lang.NEXT);
			_next.visible = false;
			addChild(_next);
			_next.addEventListener(MouseEvent.MOUSE_DOWN, nextDown);
		}
		
		private function positionNext():void {
			if(_next) {
				_next.x = stage.stageWidth * 0.5;
				_next.y = stage.stageHeight * 0.5;
			}
		}
		
		private function nextDown(event:MouseEvent):void {
			_next.removeEventListener(MouseEvent.MOUSE_DOWN, nextDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, nextUp);
		}
		
		private function nextUp(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, nextUp);
			_next.visible = false;
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			resetMan();
			clearLetters();
			initLetters();
			positionLetters();
			initHangman();
		}
		
		private function initHangman():void {
			_charsUsed = new Array();
			_countText.text = Lang.TYPE_LETTERS;
			positionText();
			if(_shuffle) {
				var index:uint = _si.ind[_index];
			} else {
				index = _indexes[_index];
			}
			_sentence = _xml.body.seq[index].par.(@id == "answer").text[0];
			// create a copy of text with _ for each letter
			_shown = _sentence.replace(/[A-Za-z]/g,"_");
			_numWrong = 0;
			_gameText.text = _shown;
			deleteImage();
			initImage(index);
		}
		
		private function keyHandler(event:KeyboardEvent) {
			// get letter pressed
			var letter:int = event.charCode - 97; // index of _letters array to add tick or cross
			if(event.charCode > 64 && event.charCode < 123){
				positionText();
				var charPressed:String = String.fromCharCode(event.charCode);
				// loop through and find matching letters
				var foundLetter:Boolean = false;
				var len:uint = _sentence.length;
				for(var i:uint = 0; i < len; i++) {
					if (_sentence.charAt(i).toLowerCase() == charPressed) {
						// match found, change _shown _sentence
						_shown = _shown.substr(0,i) + _sentence.substr(i,1) + _shown.substr(i + 1);
						foundLetter = true;
						addTick(letter);
					}
				}
				// update on-screen text
				_gameText.text = _shown;
				//check if sentence is completed
				if(_shown == _sentence){
					winGame();
					nextGame();
				} else if (!foundLetter) {
					// has the wrong character been pressed before?
					len = _charsUsed.length;
					var letterMatched:Boolean = false;
					for(i = 0; i < len; i++) {
						if(_charsUsed[i] == charPressed) {
							letterMatched = true;
						}
					}
					if(!letterMatched) {
						_charsUsed.push(charPressed); // keep record of wrong characters pressed
						_numWrong++;
						_countText.text = (_numChars - _numWrong) + " " + Lang.ATTEMPTS_REMAINING + ".";
						positionText();
						if(_numWrong >= _numChars) {
							loseGame();
							nextGame();
						}
						addCross(letter);
						updateMan();
					}
				}
			}
		}
		
		private function updateMan():void {
			for(var i:uint = 0; i < _numWrong; i++) {
				_manArray[i].visible = true;
			}
		}
		
		private function addTick(index:int):void {
			if(!_ticked[index]) {
				_ticked[index] = true;
				var tick:Tick = new Tick();
				tick.x = -5;
				tick.y = 10;
				_letters[index].addChild(tick);
			}
		}
		
		private function addCross(index:int):void {
			if(!_ticked[index]) {
				_ticked[index] = true;
				var cross:Cross = new Cross();
				cross.x = -5;
				cross.y = 10;
				_letters[index].addChild(cross);
			}
		}
		
		// if user loses a game
		private function loseGame():void {
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
			_next.addEventListener(MouseEvent.MOUSE_DOWN, nextDown);
			_countText.text = Lang.WRONG;
			positionText();
			_gameText.text = _sentence;
			crossNumberIcon(_index);
		}
		
		// if user wins a game
		private function winGame():void {
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
			_next.addEventListener(MouseEvent.MOUSE_DOWN, nextDown);
			_countText.text = Lang.CORRECT;
			positionText();
			_score++;
			tickNumberIcon(_index);
		}
		
		private function nextGame():void {
			_played++;
			_index++;
			if(_index >= _length) {
				endActivity();
			} else {
				_charsUsed = null;
				_next.visible = true;
				showImage();
				_image.playAnswer();
			}
		}		
		
		private function tickNumberIcon(index:uint):void {
			var tick:Tick = new Tick();
			tick.y = 18;
			_numbers[index].addChild(tick);
		}
		
		private function crossNumberIcon(index:uint):void {
			var cross:Cross = new Cross();
			cross.y = 18;
			_numbers[index].addChild(cross);
		}
		
		private function clearLetters():void {
			_ticked = null;
			var len:uint = _letters.length;
			for(var i:uint = 0; i < len; i++) {
				removeChild(_letters[i]);
				_letters[i] = null;
			}
		}
		
		/*
		######################################## IMAGE ########################################
		*/
		private function initImage(index:uint):void {
			_image = new SMILImage(index,_xml.body.seq[index],FlashVars.moodledata);
			_image.addEventListener(SMILImage.IMAGE_LOADED, imageLoadedHandler);
			_image.addEventListener(MouseEvent.CLICK, imageClickHandler);
			_image.showAnswerImage();
		}
		
		private function imageLoadedHandler(event:Event):void {
			_image.removeEventListener(SMILImage.IMAGE_LOADED, imageLoadedHandler);
			_image.x = _image.width * 0.5 + 20;
			_image.y = _image.height * 0.5 + 10;
			_imageLoaded = true;
		}
		
		private function showImage():void {
			if(_imageLoaded) {
				addChild(_image);
			}
		}
		
		private function imageClickHandler(event:MouseEvent):void {
			_image.playAnswer();
		}
		
		private function deleteImage():void {
			if(_image) {
				addChild(_image);
				removeChild(_image);
				_image.removeEventListener(MouseEvent.CLICK, imageClickHandler);
				_image = null;
			}
		}
		
		/*
		############################ SPEAKERS #############################
		*/
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
		
		private function speakersDown(event:MouseEvent):void {
			_speakers.removeEventListener(MouseEvent.MOUSE_UP, speakersDown);
			removeChild(_speakers);
			_speakers = null;
			initNext();
			positionNext();
			initStart();
			positionStart();
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
				_end.x = stage.stageWidth * 0.5;
				_end.y = stage.stageHeight * 0.9 - _offsetY;
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
		
		/*
		############################ SEND DATA #############################
		*/
		private function endActivity():void {
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
			deleteEndAndSend();
			_next.visible = false;
			_countText.text = "";
			_clock.stopClock();
			var message:String = Lang.YOUVE_COMPLETED + " " + _score + " " + Lang.GAMES + "\n" + Lang.SCORE + Math.floor(_score / _length * 100) + "%";
			_um = new UserMessage(message);
			_um.addOK = true;
			_um.addEventListener(MouseEvent.CLICK, umClickHandler);
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			_um.filters = [_dsf];
			addChild(_um);
			sendGrade();
		}
		
		private function umClickHandler(event:MouseEvent):void {
			removeChild(_um);
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
			_obj.feedback = _score + "/" + _length + " " + Lang.GAMES + " " + Lang.COMPLETED_END + "."; // (String) optional
			_obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			_obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			_obj.gradeupdate = FlashVars.gradeupdate; // (String) URLVariables URL
			_obj.instance = FlashVars.instance; // (int) Moodle instance ID
			_obj.rawgrade = Math.floor(_score / _length * 100); // (Number) grade, normally 0 - 100 but depends on grade book settings
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
			/*var msg:String = "Error: ";
			for(var s:String in _amf.obj.info) { // output returned data
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
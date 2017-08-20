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
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.matbury.Clock;
	import com.matbury.CMenu;
	import com.matbury.LoadXML;
	import com.matbury.UserMessage;
	import com.matbury.WordSearch;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.milas.UpdateGradeURLVars;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.Btn;
	
	public class SMILWordSearch extends Sprite {
		
		private var _version:String = "2014.04.24";
		private var _iData:Array;
		private var _words:Array;
		private var _feedback:Array;
		private var _loadXML:LoadXML;
		private var _smil:Namespace;
		private var _length:uint;
		private var _msg:String;
		private var _wordsPlaced:uint = 0;
		private var _wordsDone:uint = 0;
		private var _games:uint = 0;
		private var _score:uint = 0;
		//
		private var _dsf:DropShadowFilter;
		private var _poster:Poster;
		private var _wordsearch:WordSearch;
		private var _f:TextFormat;
		private var _scoreText:TextField;
		private var _clock:Clock;
		private var _position:int = 0;
		private var _amf:Amf;
		private var _sg:UpdateGradeURLVars;
		private var _obj:Object; // grade data object
		private var _loadBar:LoadBar;
		private var _um:UserMessage;
		private var _end:Btn;
		// User feedback
		private var _gamesPlayed:String = "Games played: ";
		private var _wordsFound:String = " words found.";
		private var _wordsTotal:String = "Score: ";
		private var _endMessage1:String = "You've found ";
		private var _endMessage2:String = " words!\n";
		private var _gradeSaved:String = "Your grade has been sent to the grade book.";
		private var _errorMessage:String = "There was a problem. Please contact your teacher/admin.";
		private var _phpErrorMessage:String = "There was a problem. Your grade may or may not have been sent to the grade book. Please check the grade book item for this activity. If your grade has not been sent, please contact your teacher/admin.";
		private var _tooFewWords:String = Lang.INCORRECT_DATA;
		
		public function SMILWordSearch() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			/* 
			FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects.smil";
			*/
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			initCMenu();
			if(this.root.loaderInfo.parameters.glossaryid) {
				getGlossaryData();
			} else if(this.root.loaderInfo.parameters.words) {
				initFlashVarsWords();
			} else {
				initLoadBar();
				loadData();
			}
		}
		
		private function initCMenu():void {
			var cmenu:CMenu = new CMenu(_version);
			addChild(cmenu);
		}
		
		private function initLoadBar():void {
			_loadBar = new LoadBar();
			_loadBar.x = stage.stageWidth * 0.5;
			_loadBar.y = stage.stageHeight * 0.5;
			addChild(_loadBar);
		}
		
		private function deleteLoadBar():void {
			removeChild(_loadBar);
			_loadBar = null;
		}
		
		/*
		########################## LOAD XML DATA #############################
		*/
		private function loadData():void {
			var url:String = FlashVars.xmlurl;
			if(url) {
				_loadXML = new LoadXML();
				_loadXML.addEventListener(LoadXML.LOADED, loaded);
				_loadXML.addEventListener(LoadXML.FAILED, failed);
				_loadXML.load(url);
			} else {
				showError(Lang.NO_ACTIVITY_DATA);
			}
		}
		
		private function loaded(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loaded);
			_loadXML.removeEventListener(LoadXML.FAILED, failed);
			deleteLoadBar();
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_loadXML.xml.name());
			default xml namespace = _smil;
			initXMLWords();
		}
		
		private function failed(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loaded);
			_loadXML.removeEventListener(LoadXML.FAILED, failed);
			deleteLoadBar();
			showError(Lang.NO_ACTIVITY_DATA);
		}
		
		private function showError(msg:String):void {
			_um = new UserMessage(msg,null,400,18,0xdd0000,0xeeeeee);
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function showMessage():void {
			var em:UserMessage = new UserMessage(_msg);
			em.x = stage.stageWidth * 0.5;
			em.y = stage.stageHeight * 0.4;
			em.mouseChildren = false;
			addChild(em);
		}
		
		/*
		######################## START INTERACTION ########################
		*/
		// Convert XML keywords into an array
		private function initXMLWords():void {
			// create vocab array from loaded XML data
			_words = new Array();
			_feedback = new Array();
			var i_len:uint = _loadXML.xml.body.seq.length();
			for(var i:uint = 0; i < i_len; i++) {
				var j_len:uint = _loadXML.xml.body.seq[i].par.(@id == "keyword").text.length();
				for (var j:uint = 0; j < j_len; j++) {
					var word:String = String(_loadXML.xml.body.seq[i].par.(@id == "keyword").text[j]);
					_words.push(word);
					_feedback.push(word);
				}
			}
			_length = _words.length;
			if(_length < 2) {
				_msg = _tooFewWords;
				showMessage();
			} else {
				initDisplay();
				initPoster();
				initClock();
			}
		}
		
		// Convert FlashVars words value into an array
		private function initFlashVarsWords():void {
			// create vocab array from loaded XML data
			var words:String = this.root.loaderInfo.parameters.words;
			if(words.charAt(words.length - 1) == ",") {
				words = words.slice(0,words.length - 1);
			}
			_words = words.split(",");
			_feedback = words.split(",");
			_length = _words.length;
			if(_length < 2) {
				_msg = _tooFewWords;
				showMessage();
			} else {
				initDisplay();
				initPoster();
				initClock();
			}
		}
		
		/*
		############################ GET GLOSSARY DATA #############################
		*/
		private function getGlossaryData():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, glossaryGotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, glossaryFaultHandler); // listen for server fault
			var obj:Object = new Object(); // create an object to hold data sent to the server
			obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			obj.swfid = FlashVars.swfid; // (int) activity ID
			obj.instance = FlashVars.instance; // (int) Moodle instance ID
			obj.glossaryid = this.root.loaderInfo.parameters.glossaryid; // (int) Moodle instance ID
			obj.servicefunction = "Glossary.amf_get_entries"; // (String) ClassName.method_name
			_amf.getObject(obj); // send the data request to the server
		}
		
		// Connection to AMFPHP succeeded
		// Manage returned data and inform user
		private function glossaryGotDataHandler(event:Event):void {
			// Clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, glossaryGotDataHandler);
			_amf.removeEventListener(Amf.FAULT, glossaryFaultHandler);
			// Check if grade was sent successfully
			switch(_amf.obj.result) {
				//
				case "SUCCESS":
				initGlossaryWords();
				break;
				//
				case "NO_GLOSSARY":
				_msg = String(_amf.obj.message);
				showMessage();
				break;
				//
				case "NO_PERMISSION":
				_msg = String(_amf.obj.message);
				showMessage();
				break;
				//
				default:
				_msg = "Unknown error.";
				showMessage();
			}
		}
		
		private function glossaryFaultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, glossaryGotDataHandler);
			_amf.removeEventListener(Amf.FAULT, glossaryFaultHandler);
			_msg = "Get glossary data failed.";
			showMessage();
		}
		
		private function initGlossaryWords():void {
			_words = new Array();
			_feedback = new Array();
			_length = _amf.obj.records.length;
			for(var i:uint = 0; i < _length; i++) {
				_words.push(_amf.obj.records[i].concept);
				_feedback.push(_amf.obj.records[i].concept);
			}
			if(_length < 2) {
				_msg = "You do not have permission to access glossary data.";
				showMessage();
			} else {
				initDisplay();
				initPoster();
				initClock();
			}
		}
		
		/*
		############################ START WORD SEARCH #############################
		*/
		private function initDisplay():void {
			// score display
			_f = new TextFormat("Trebuchet MS",20,0,true);
			_scoreText = new TextField();
			_scoreText.autoSize = TextFieldAutoSize.RIGHT;
			_f.align = TextFormatAlign.RIGHT;
			_scoreText.defaultTextFormat = _f;
			_scoreText.embedFonts = true;
			_scoreText.x = stage.stageWidth - 10;
			_scoreText.text = "\n\n\n";
			addChild(_scoreText);
			_scoreText.y = stage.stageHeight - _scoreText.height;
		}
		
		private function initPoster():void {
			_poster = new Poster();
			_poster.x = stage.stageWidth * 0.5;
			_poster.y = stage.stageHeight * 0.5;
			_poster.mouseChildren = false;
			_poster.buttonMode = true;
			_poster.filters = [_dsf];
			_poster.addEventListener(MouseEvent.MOUSE_DOWN, posterHandler);
			addChild(_poster);
		}
		
		private function initClock():void {
			_clock = new Clock();
			_clock.x = stage.stageWidth;
			_clock.y = 10;
			addChild(_clock);
		}
		
		// Create a new word search
		private function initWordSearch():void {
			var size:uint;
			if(this.root.loaderInfo.parameters.size){
				size = this.root.loaderInfo.parameters.size;
			} else {
				size = 20; // default size
			}
			var len:uint = _words.length;
			if(len > 0) {
				var words:Array = new Array();
				if(len > 20) {
					for(var i:uint = 0; i < 20; i++) {
						var rnd:uint = Math.floor(Math.random() * _words.length);
						words.push(_words[rnd]);
						_words.splice(rnd,1);
					}
					_wordsearch = new WordSearch(words,size);
				} else {
					_wordsearch = new WordSearch(_words,size); 
				}
				addChild(_wordsearch);
				_wordsearch.startWordSearch();
				_wordsPlaced = _wordsearch.words;
				_scoreText.text = _gamesPlayed + _games + "\n" + _wordsDone + "/" + _wordsPlaced + _wordsFound + "\n" + _wordsTotal + _score;
				_wordsearch.x = stage.stageWidth * 0.01;
				_wordsearch.y = -10;
				_wordsearch.addEventListener(WordSearch.FINISHED, finishedHandler);
				_wordsearch.addEventListener(WordSearch.WORD_FOUND, wordHandler);
			} else {
				endInteraction();
			}
		}
		
		private function finishedHandler(event:Event):void {
			_games++;
			_wordsDone = 0;
			deleteWordSearch();
			initWordSearch();
		}
		
		private function wordHandler(event:Event):void {
			_score++;
			_wordsDone++;
			_scoreText.text = _gamesPlayed + _games + "\n" + _wordsDone + "/" + _wordsPlaced + _wordsFound + "\n" + _wordsTotal+ _score;
		}
		
		private function deleteWordSearch():void {
			_wordsearch.removeEventListener(WordSearch.FINISHED, finishedHandler);
			_wordsearch.removeEventListener(WordSearch.WORD_FOUND, wordHandler);
			removeChild(_wordsearch);
			_wordsearch = null;
		}
		
		private function posterHandler(event:MouseEvent):void {
			_poster.removeEventListener(MouseEvent.MOUSE_DOWN, posterHandler);
			removeChild(_poster);
			_poster = null;
			initWordSearch();
			initEndAndSend();
			positionEndAndSend();
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
				_end.y = stage.stageHeight - (_end.height + 3);
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
			endInteraction();
		}
		
		private function umClickedHandler(event:Event):void {
			_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
			removeChild(_um);
			_um = null;
		}
		
		private function endInteraction():void {
			deleteEndAndSend();
			showEndScore();
			_clock.stopClock();
			sendData();
		}
		
		private function showEndScore():void {
			var msg:String = _gamesPlayed + _games + "\n" + _wordsTotal + _score + " words.";
			_um = new UserMessage(msg);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		/*
		############################ SEND DATA #############################
		*/
		// Try to send grade via AmfPHP first. If that fails, send via URLVariables.
		private function sendData():void {
			_amf = new Amf();
			_amf.addEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.addEventListener(Amf.FAULT, faultHandler);
			// prepare grade data object
			_obj = new Object();
			var feedback:String = _score + "/" + _length + " words found";
			if(this.root.loaderInfo.parameters.glossaryid) {
				feedback += " (glossaryid = " + this.root.loaderInfo.parameters.glossaryid + ")";
				_obj.glossaryid = this.root.loaderInfo.parameters.glossaryid;
			}
			_obj.feedback = feedback;
			_obj.feedbackformat = _clock.seconds;
			_obj.gateway = FlashVars.gateway;
			_obj.gradeupdate = FlashVars.gradeupdate; // (String) URLVariables URL
			_obj.instance = FlashVars.instance;
			_obj.rawgrade = Math.floor(_score / _length * 100); // Always pass maximum grade
			_obj.servicefunction = "Grades.amf_grade_update";
			_obj.swfid = FlashVars.swfid;
			_amf.getObject(_obj);
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
/*
    SMILListenAndSelect Multimedia Interactive Learning Application (MILA).

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
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	//import flash.text.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import flash.utils.Timer;
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
	import com.matbury.sam.gui.Pointer;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.Tick;
	
	public class SMILListenAndSelect extends Sprite {
		
		private var _version:String = "2014.04.24";
		private var _amf:Amf;
		private var _sg:UpdateGradeURLVars;
		private var _obj:Object; // grade data object
		private var _length:uint; // total number of items in XML list
		private var _loadXML:LoadXML;
		private var _xml:XML;
		private var _smil:Namespace;
		//
		private var _sia:ShuffledIndex; // correct answers
		private var _sid:ShuffledIndex; // distractors
		private var _shuffle:Boolean = true;
		private var _siaPos:int = 0;
		private var _sidPos:int = 0;
		private var _images:Array;
		private var _correctImage:SMILImage;
		private var _points:Array;
		private var _hit:Boolean;
		private var _tries:uint = 0;
		private var _score:uint = 0;
		private var _play:Btn;
		private var _numbers:Array;
		private var _dsf:DropShadowFilter;
		//private var _display:TextField;
		private var _loadBar:LoadBar;
		private var _clock:Clock;
		private var _menu:CMenu;
		private var _speakers:Speakers;
		private var _pointer:Pointer;
		private var _um:UserMessage;
		private var _ended:Boolean = false;
		//private var _started:Boolean = false;
		private var _end:Btn;
		
		public function SMILListenAndSelect() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, resize);
			initCMenu();
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			/* 
			FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects.smil";
			FlashVars.moodledata = "../";
			loadData();
			positionLoadBar();
			initLoadBar();
			*/
			securityCheck();
		}
		
		private function initCMenu():void {
			_menu = new CMenu(_version);
			addChild(_menu);
		}
		
		//
		private function resize(event:Event):void {
			positionUserMessage();
			initPoints();
			positionImages();
			positionClock();
			adjustScoreBar();
			positionPointer();
			positionPlay();
			positionSpeakers();
			positionEndAndSend();
		}
		
		/*
		######################### SECURITY CHECK ##########################
		*/
		// check website URL for instance of permitted domain
		private function securityCheck():void {
			var sc:LicenceCheck = new LicenceCheck();
			var checked:Boolean = sc.check(this.root.loaderInfo.url);
			if(checked) {
				loadData();
				initLoadBar();
				positionLoadBar();
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
		private function initInteraction() {
			_length = _xml.body.seq.length();
			if(this.root.loaderInfo.parameters.shuffle) {
				if(this.root.loaderInfo.parameters.shuffle == "false") {
					_shuffle = false;
				}
			}
			_sia = new ShuffledIndex(_length,_shuffle); // correct answers
			_sid = new ShuffledIndex(_length); // distractors
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			initClock();
			positionClock();
			initImages();
			shuffleImages();
			initPoints();
			positionImages();
			initScoreBar();
			adjustScoreBar();
			initPointer();
			positionPointer();
			initSpeakers();
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
		
		// create shuffled indexes for four images
		private function initPoints():void {
			// _points are positions for 4 images
			var X:Number = stage.stageWidth * 0.25;
			var Y:Number = (stage.stageHeight - 25) * 0.25;
			_points = new Array([X,Y],[X,Y * 3],[X * 3,Y],[X * 3,Y * 3]);
		}
		
		// create and start display clock
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
		
		// create 4 images
		private function initImages():void {
			_hit = false;
			_images = new Array();
			var sip:ShuffledIndex = new ShuffledIndex(4);
			var sipPos:uint = 0;
			var posa:uint = _sia.ind[_siaPos];
			// create 1 correct image
			var image:SMILImage = new SMILImage(posa,_xml.body.seq[posa],FlashVars.moodledata);
			image.showAnswerImage();
			image.addEventListener(MouseEvent.MOUSE_DOWN, correctDownHandler);
			_correctImage = image;
			addChild(image);
			_images.push(image);
			_siaPos++;
			sipPos++;
			if(_siaPos >= _length) {
				_siaPos = 0;
			}
			// create 3 wrong images
			while(_images.length < 4) {
				var posd:uint = _sid.ind[_sidPos];
				if(posd != posa) {
					image = new SMILImage(posd,_xml.body.seq[posd],FlashVars.moodledata);
					image.showAnswerImage();
					image.addEventListener(MouseEvent.MOUSE_DOWN, wrongDownHandler);
					sipPos++;
					addChild(image);
					_images.push(image);
				}
				_sidPos++;
				if(_sidPos >= _length) {
					_sidPos = 0;
				}
			}
		}
		
		private function shuffleImages():void {
			var rnd:uint;
			var shuffledImages:Array = new Array();
			while(_images.length > 0) {
				rnd = Math.floor(Math.random() * _images.length);
				shuffledImages.push(_images[rnd]);
				_images.splice(rnd,1);
			}
			_images = shuffledImages;
		}
		
		private function positionImages():void {
			if(_images) {
				var len:uint = _images.length;
				for(var i:uint = 0; i < len; i++) {
					_images[i].x = _points[i][0];
					_images[i].y = _points[i][1];
				}
			}
		}
		
		// play sound associated with clicked image
		private function correctDownHandler(event:MouseEvent):void {
			if(!_hit) {
				showNext();
				var image:SMILImage = event.currentTarget as SMILImage;
				var tick:Tick = new Tick();
				tick.y = tick.height;
				tick.scaleX = tick.scaleY = 4;
				tick.x -= tick.width * 0.5;
				tick.y += tick.height * 0.5;
				tick.filters = [_dsf];
				image.addChild(tick);
				tick = new Tick();
				tick.y = tick.height;
				if(_siaPos != 0) {
					_numbers[_siaPos - 1].addChild(tick);
				} else {
					_numbers[_length - 1].addChild(tick);
				}
				_score++;
			}
			event.currentTarget.playAnswer();
			_hit = true;
			_tries++;
			var completed:int = updateScore();
			if(completed >= _numbers.length && !_ended) {
				stopGame();
				_ended = true;
			}
		}
		
		// play sound associated with clicked image
		private function wrongDownHandler(event:MouseEvent):void {
			event.currentTarget.playAnswer();
			if(!_hit) {
				var image:SMILImage = event.currentTarget as SMILImage;
				// add cross to selected image
				var cross:Cross = new Cross();
				cross.scaleX = cross.scaleY = 4;
				cross.x -= cross.width * 0.5;
				cross.y += cross.height * 0.5;
				cross.filters = [_dsf];
				image.addChild(cross);
				_tries++;
			}
			updateScore();
		}
		
		// delete all four images for current question
		private function deleteImages():void {
			for(var i:uint = 0; i < _images.length; i++) {
				removeChild(_images[i]);
				_images[i] = null;
			}
			_images = null;
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
		
		// create pointer to show user where to start
		private function initPointer():void {
			_pointer = new Pointer();
			addChild(_pointer);
		}
		
		private function positionPointer():void {
			if(_pointer) {
				_pointer.x = stage.stageWidth * 0.5;
				_pointer.y = stage.stageHeight * 0.5;
			}
		}
		
		private function deletePointer():void {
			if(_pointer) {
				removeChild(_pointer);
				_pointer = null;
			}
		}
		
		// show user a message to turn on their speakers
		private function initSpeakers():void {
			_speakers = new Speakers();
			_speakers.mouseChildren = false;
			_speakers.buttonMode = true;
			_speakers.filters = [_dsf];
			addChild(_speakers);
			_speakers.addEventListener(MouseEvent.MOUSE_DOWN, speakersHandler);
		}
		
		private function positionSpeakers():void {
			if(_speakers) {
				_speakers.x = stage.stageWidth * 0.5;
				_speakers.y = stage.stageHeight * 0.5;
			}
		}
		
		// Delete "Turn on your speakers" message
		private function speakersHandler(event:MouseEvent):void {
			_speakers.removeEventListener(MouseEvent.MOUSE_DOWN, speakersHandler);
			removeChild(_speakers);
			_speakers = null;
			initPlay();
			positionPlay();
			_clock.startClock();
			initEndAndSend();
			positionEndAndSend();
		}
		
		// Create play sound and next button
		private function initPlay():void {
			_play = new Btn("play");
			_play.addEventListener(MouseEvent.MOUSE_UP, playUp);
			addChild(_play);
		}
		
		private function positionPlay():void {
			if(_play) {
				_play.x = stage.stageWidth * 0.5;
				_play.y = stage.stageHeight * 0.5;
			}
		}
		
		private function deletePlay():void {
			if(_play) {
				removeChild(_play);
				_play = null;
			}
		}
		
		private function playUp(event:MouseEvent):void {
			deletePointer();
			_correctImage.playAnswer();
		}
		
		private function nextUp(event:MouseEvent):void {
			_play.addEventListener(MouseEvent.MOUSE_UP, playUp);
			_play.removeEventListener(MouseEvent.MOUSE_UP, nextUp);
			_play.char = "play";
			deleteImages();
			initImages();
			shuffleImages();
			positionImages();
			_correctImage.playAnswer();
		}
		
		// show next >> navigation button
		private function showNext():void {
			if(_play) {
				_play.removeEventListener(MouseEvent.MOUSE_UP, playUp);
				_play.addEventListener(MouseEvent.MOUSE_UP, nextUp);
				_play.char = "next";
			}
		}
		
		// display new score
		private function updateScore():int {
			// Count the number of ticks added to numbers
			var len:uint = _numbers.length;
			var completed:uint = 0;
			for(var i:uint = 0; i < len; i++) {
				if(_numbers[i].numChildren > 2) {
					completed++;
				}
			}
			return completed;
		}
		
		// stop the timer
		private function stopGame():void {
			deleteEndAndSend();
			deletePlay();
			deletePointer();
			_clock.stopClock();
			showEndScore();
			sendGrade();
		}
		
		private function showEndScore():void {
			var completed:int = updateScore();
			var msg:String = Lang.YOUVE_COMPLETED + completed + " images in " + _tries + " tries.";
			_um = new UserMessage(msg);
			_um.addOK = true;
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.filters = [_dsf];
			addChild(_um);
			positionUserMessage();
		}
		
		private function umClickedHandler(event:Event):void {
			_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
			removeChild(_um);
			_um = null;
		}
		
		/*
		############################ END ACTIVITY BUTTON #############################
		*/
		// User can click this button to stop the dictation and send the results
		// to the grade book
		private function initEndAndSend():void {
			_end = new Btn(Lang.SUBMIT);
			_end.addEventListener(MouseEvent.MOUSE_DOWN, endDownHandler);
			_end.filters = [_dsf];
			_end.mouseChildren = false;
			_end.buttonMode = true;
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
		
		private function endDownHandler(event:MouseEvent):void {
			_end.removeEventListener(MouseEvent.MOUSE_DOWN, endDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, endUpHandler);
		}
		
		private function endUpHandler(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, endUpHandler);
			removeChild(_end);
			_end = null;
			stopGame();
		}
		
		/*
		############################ SEND DATA #############################
		*/
		// Try to send grade via AmfPHP first. If that fails, send via URLVariables.
		private function sendGrade():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			var completed:int = updateScore();
			// prepare grade data object
			_obj = new Object();
			_obj.feedback = Lang.COMPLETED + " " + completed + " images in " + _tries + " tries."; // (String) optional
			_obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			_obj.gateway = FlashVars.gateway; // (String) AmfPHP gateway URL
			_obj.gradeupdate = FlashVars.gradeupdate; // (String) URLVariables URL
			_obj.instance = FlashVars.instance; // (int) Moodle instance ID
			_obj.rawgrade = Math.floor(_length / _tries * 100); // (Number) grade, normally 0 - 100 but depends on grade book settings
			_obj.servicefunction = "Grades.amf_grade_update"; // (String) ClassName.method_name
			_obj.swfid = FlashVars.swfid; // (int) activity ID
			_amf.getObject(_obj); // send the data to the server
		}
		
		// Connection to AmfPHP succeeded
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
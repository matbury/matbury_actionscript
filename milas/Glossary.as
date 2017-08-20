package com.matbury.milas {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Stage;
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
	import com.matbury.Image;
	import com.matbury.LoadXML;
	import com.matbury.ShuffledIndex;
	import com.matbury.UserMessage;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.Cross;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.NumberIcon;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.TextColors;
	import com.matbury.sam.gui.Tick;
	
	public class Glossary extends Sprite {
		
		private var _version:String = "2011.07.19";
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _xml:XML;
		private var _amf:Amf;
		private var _tf:TextField;
		private var _html:String;
		private var _length:uint;
		private var _clock:Clock;
		private var _clockVisible:Boolean = true;
		private var _dsf:DropShadowFilter;
		private var _speakers:Speakers;
		private var _completed:int = 0; // Number of questions completed correctly
		private var _skipped:int = 0;
		private var _si:ShuffledIndex;
		private var _currentIndex:int = 0;
		private var _blanks:Array;
		private var _lastIndex:int;
		private var _currentWord:BlankWord;
		private var _score:Array;
		private var _answers:Array; // 0 = wrong, 1 = correct, 2 = unanswered
		private var _wrong:Array; // incorrect answers (shown at end)
		private var _sentence:String;
		private var _mp3:String;
		private var _image:Image;
		private var _next:Btn;
		private var _skip:Btn;
		private var _play:Btn;
		private var _info:Btn;
		private var _cs:CheckString;
		private var _f:TextFormat;
		private var _float:TextField;
		private var _timer:Timer;
		private var _stretched:Btn;
		private var _title:TextField;
		private var _container:Sprite;
		private var _numbers:Array;
		private var _textColors:TextColors;
		private var _um:UserMessage;
		private var _menu:CMenu;
		private var _started:Boolean = false;
		
		public function Glossary() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			initCMenu();
			securityCheck();
		}
		
		private function initCMenu():void {
			_menu = new CMenu(_version);
			addChild(_menu);
		}
		
		/*
		########################### PRELOADER ############################
		*/
		private function initLoadBar():void {
			_loadBar = new LoadBar();
			_loadBar.x = stage.stageWidth * 0.5;
			_loadBar.y = stage.stageHeight * 0.5;
			addChild(_loadBar);
		}
		
		private function deleteLoadBar():void {
			if(_loadBar) {
				removeChild(_loadBar);
				_loadBar = null;
			}
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
				initGlossaries();
				//loadData();
			} else {
				showError("This MILA is not licensed for this location.\nPlease contact Matt Bury at\nmatbury@gmail.com\nor\nclick here to visit matbury.com");
				_um.addEventListener(MouseEvent.MOUSE_DOWN, visitMattBury);
			}
		}
		
		private function showError(msg:String):void {
			_um = new UserMessage(msg,null,400,18,0xdd0000,0xeeeeee);
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function visitMattBury(event:MouseEvent):void {
			var request:URLRequest = new URLRequest("http://matbury.com/");
			navigateToURL(request,"_self");
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
			_xml = _loadXML.xml;
			deleteLoadBar();
			initInteraction();
		}
		
		function failedHandler(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.removeEventListener(LoadXML.FAILED, failedHandler);
			var msg:String = "Sorry, I couldn't find the data for this activity.\nPlease try again.\nIf this problem persists, please contact your teacher or the site administrator.";
			showError(msg);
		}
		
		/*
		########################## INTERACTION #############################
		*/
		private function initInteraction():void {
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			_f = new TextFormat("Trebuchet MS",15,0,true);
			/*_length = _xml.interaction.node.length();
			_si = new ShuffledIndex(_length);
			_cs = new CheckString();
			_answers = new Array();
			for(var i:uint = 0; i < _length; i++) {
				_answers.push(2); // set all to not answered
			}
			_wrong = new Array();*/
			if(FlashVars.fullbrowser == "true") {
				initBack();
			}
			/*
			initTextColors();
			positionTextColours();
			initClock();
			positionClock();
			initScoreBar();
			adjustScoreBar();
			initPlay();
			positionPlay();
			initStretched();
			positionStretched();
			initNext();
			positionNext();
			initSkip();
			positionSkip();
			nextImage();
			positionImage();
			nextText();
			positionText();
			initFloat();
			initSpeakers();
			positionSpeakers();
			stage.addEventListener(Event.RESIZE, resizeHandler);
			*/
		}
		
		private function showMessage(msg:String):void {
			_um = new UserMessage(msg);
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function deleteMessage():void {
			if(_um) {
				removeChild(_um);
				_um = null;
			}
		}
		
		private function resizeHandler(event:Event):void {
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
			if(!_started) {
				positionSpeakers();
			}
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
			_textColors.x = stage.stageWidth * 0.5 - (_textColors.width * 0.5);
			_textColors.y = stage.stageHeight * 0.83;
		}
		
		private function initClock():void {
			_clock = new Clock();
			addChild(_clock);
		}
		
		private function positionClock():void {
			_clock.x = stage.stageWidth;
			_clock.y = 10;
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
		
		/*
		########################### PLAY BUTTON ###########################
		*/
		private function initPlay():void {
			_play = new Btn("play");
			_play.addEventListener(MouseEvent.MOUSE_DOWN, playDown);
			addChild(_play);
			//_pointerTarget = _play;
		}
		
		private function positionPlay():void {
			_play.x = stage.stageWidth * 0.5 - 20;
			_play.y = stage.stageHeight * 0.6;
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
			_stretched.x = stage.stageWidth * 0.5 + 20;
			_stretched.y = stage.stageHeight * 0.6;
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
			_next.x = stage.stageWidth * 0.5;
			_next.y = stage.stageHeight * 0.8;
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
			_skip.x = stage.stageWidth * 0.5;
			_skip.y = stage.stageHeight * 0.8;
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
			_image = new Image(index,_xml.interaction.node[index],FlashVars.moodledata);
			_image.showAnswerImage();
			_image.addEventListener(MouseEvent.MOUSE_DOWN, imageDown);
			addChild(_image);
		}
		
		private function positionImage():void {
			_image.x = stage.stageWidth * 0.5;
			_image.y = stage.stageHeight * 0.25;
		}
		
		private function deleteImage():void {
			_image.removeEventListener(MouseEvent.MOUSE_DOWN, imageDown);
			removeChild(_image);
			_image = null;
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
			_sentence = _xml.interaction.node[index].answer.text;
			var words:Array = _sentence.split(" ");
			var len:uint = words.length;
			_blanks = new Array();
			_score = new Array();
			_container = new Sprite();
			for(var i:uint = 0; i < len; i++) {
				var bw:BlankWord = new BlankWord(words[i],posX,posY,i); // word
				bw.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
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
			_container.x = (stage.stageWidth * 0.5) - (_container.width * 0.5);
			_container.y = stage.stageHeight * 0.65;
		}
		
		// delete all the words and arrays
		private function deleteText():void {
			removeChild(_container);
			_container = null;
			_score = null;
		}
		
		// create input text field
		private function initFloat():void {
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
			_float.x = _container.x;
			_float.y = _container.y;
			_float.width = _currentWord.width;
			_float.height = _currentWord.height;
			stage.focus = _float;
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		private function stageUpHandler(event:MouseEvent):void {
			stage.focus = _float;
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
			_speakers.x = stage.stageWidth * 0.5;
			_speakers.y = stage.stageHeight * 0.5;
		}
		
		private function speakersDown(event:MouseEvent):void {
			_speakers.removeEventListener(MouseEvent.MOUSE_UP, speakersDown);
			removeChild(_speakers);
			_speakers = null;
			_clock.startClock();
			_started = true;
		}
		
		/*
		######################## CHECK USER INPUT ########################
		*/
		
		function keyUpHandler(event:KeyboardEvent):void {
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
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				removeChild(_float);
				_float = null;
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
				endActivity(); // automatically sends user results
			}
		}
		
		private function endActivity():void {
			var percent:int = _completed / _length * 100;
			var msg:String;
			var len:uint = _xml.feedback.grade.length();
			if(percent >= FlashVars.grademin){
				msg = "Well, done!\n You've completed " + _completed + "/" + _length + " sentences.\n" + percent + "%";
			} else {
				msg = "Oh dear!\nYou've completed " + _completed + "/" + _length + " sentences.\n" + percent + "%\nPlease try again.";
			}
			_um = new UserMessage(msg);
			_um.addEventListener(UserMessage.CLICKED, umClickedHandler);
			_um.addOK = true;
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			_um.filters = [_dsf];
			addChild(_um);
			_clock.stopClock();
			stopTimer();
			removeButtons();
			sendGrade();
			if(_wrong.length > 0) {
				_um.addMessage("\nClick on the (i) button to see any wrong answers.");
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
			_float.width = _currentWord.width;
			_float.height = _currentWord.height;
			_float.x = _currentWord.x + _container.x;
			_float.y = _currentWord.y + _container.y;
			var i:uint = _currentWord.word.length;
			_float.maxChars = i;
			_float.text = "";
			stage.focus = _float;
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
		############################ GET GLOSSARIES #############################
		*/
		private function initGlossaries():void {
			initUserMessage();
			hideUserMessage();
			initDataDisplay();
			getGlossaries();
			//getData();
		}
		
		private function initUserMessage():void {
			_um = new UserMessage("");
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function showUserMessage():void {
			if(_um) {
				_um.visible = true;
			}
		}
		
		private function hideUserMessage():void {
			if(_um) {
				_um.visible = false;
			}
		}
		
		private function initDataDisplay():void {
			_tf = new TextField();
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.width = stage.stageWidth;
			_tf.height = stage.stageHeight;
			_tf.htmlText = "<p>Data:</p>";
			addChild(_tf);
		}
		
		private function getGlossaries():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, glossariesGotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, glossariesFaultHandler); // listen for server fault
			var obj:Object = new Object(); // create an object to hold data sent to the server
			obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			obj.swfid = FlashVars.swfid; // (int) activity ID
			obj.instance = FlashVars.instance; // (int) Moodle instance ID
			//obj.feedback = _completed + " / " + _length; // (String) optional
			//obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			//obj.rawgrade = _completed / _length * 100; // (Number) grade, normally 0 - 100 but depends on grade book settings
			obj.servicefunction = "Glossary.amf_get_glossaries"; // (String) ClassName.method_name
			_amf.getArray(obj); // send the data to the server
		}
				
		private function glossariesGotDataHandler(event:Event):void {
			deleteLoadBar();
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			// check if grade was sent successfully
			if(_amf.obj != false) {
				_um.addMessage("Got glossary data");
				glossariesDisplayData();
			} else {
				_um.addMessage("Get glossary data failed.");
				showUserMessage();
			}
		}
		
		private function glossariesFaultHandler(event:Event):void {
			deleteLoadBar();
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			_um.addMessage("Get glossary data failed.");
			showUserMessage();
		}
		
		private function glossariesDisplayData():void {
			hideUserMessage();
			var len:uint = _amf.array.length;
			for(var i:uint = 0; i < len; i++) {
				_tf.htmlText += "<p>Glossary id = " + _amf.array[i].id + " | name = " + _amf.array[i].name + " | intro = " + _amf.array[i].intro + "</p>";
			}
			_tf.htmlText += "<br/><br/>";
			getData();
		}
		
		/*
		############################ GET GLOSSARY DATA #############################
		*/
		private function getData():void {
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, glossaryGotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, glossaryFaultHandler); // listen for server fault
			var obj:Object = new Object(); // create an object to hold data sent to the server
			obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			obj.swfid = FlashVars.swfid; // (int) activity ID
			obj.instance = FlashVars.instance; // (int) Moodle instance ID
			if(this.root.loaderInfo.parameters.glossaryid) {
				obj.glossaryid = this.root.loaderInfo.parameters.glossaryid; // (int) Moodle instance ID
				obj.servicefunction = "Glossary.amf_get_entries"; // (String) ClassName.method_name
				_amf.getArray(obj); // send the data to the server
			} else {
				_um.addMessage("glossaryid undefined\nEdit SWF and add correct glossaryid\nin name/value parameters");
				showUserMessage();
			}
		}
				
		private function glossaryGotDataHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			// check if grade was sent successfully
			if(_amf.obj != false) {
				_um.addMessage("Got glossary data");
				displayData();
			} else {
				_um.addMessage("Get glossary data failed.");
				showUserMessage();
			}
		}
		
		private function glossaryFaultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			_um.addMessage("Get glossary data failed.");
			showUserMessage();
		}
		
		private function displayData():void {
			hideUserMessage();
			var len:uint = _amf.array.length;
			for(var i:uint = 0; i < len; i++) {
				_tf.htmlText += "<p>id = " + _amf.array[i].id + " | concept = " + _amf.array[i].concept + " | definition = " + _amf.array[i].definition + "</p>";
			}
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
			obj.feedback = _completed + " / " + _length; // (String) optional
			obj.feedbackformat = _clock.seconds; // (int) elapsed time in seconds
			obj.rawgrade = _completed / _length * 100; // (Number) grade, normally 0 - 100 but depends on grade book settings
			obj.servicefunction = "Grades.amf_grade_update"; // (String) ClassName.method_name
			_amf.getObject(obj); // send the data to the server
		}
				
		private function gotDataHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			// check if grade was sent successfully
			if(_amf.obj != false) {
				_um.addMessage("Your grade has been sent to the grade book.");
				/*for(var s:String in _amf.obj) { // trace out returned data
					msg += "\n" + s + "=" + _amf.obj[s];
				}*/
			} else {
				_um.addMessage("There was a problem sending your grade to the grade book.");
			}
		}
		
		private function faultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			_um.addMessage("There was a problem sending your grade to the grade book.");
		}
		
		private function umClickedHandler(event:Event):void {
			_um.removeEventListener(UserMessage.CLICKED, umClickedHandler);
			removeChild(_um);
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
				var image:Image = new Image(_wrong[i],_xml.interaction.node[_wrong[i]],FlashVars.moodledata);
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
				t.autoSize = TextFieldAutoSize.LEFT;
				t.text = _xml.interaction.node[_wrong[i]].answer.text;
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
			var image:Image = event.currentTarget as Image;
			image.playAnswer();
		}
	}
}// end of LookAndDescribe
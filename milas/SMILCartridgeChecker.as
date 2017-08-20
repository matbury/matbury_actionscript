/*
	XMLCartridgeChecker application displays contents of MILA content catridges for error checking.
	Copyright © 2011 Matt Bury All rights reserved.
	http://matbury.com/
	matbury@gmail.com
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
	import com.matbury.CMenu;
	import com.matbury.LoadXML;
	import com.matbury.Pointer;
	import com.matbury.SMILImage;
	import com.matbury.UserMessage;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.data.Amf;
	import com.matbury.sam.gui.Btn;
	import com.matbury.sam.gui.Head;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.NumberIcon;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.Pron;
	
	public class SMILCartridgeChecker extends Sprite {
		
		private var _version:String = "2012.11.06";
		private var _amf:Amf;
		private var _xml:XML;
		private var _smil:Namespace;
		private var _loadXML:LoadXML;
		private var _loadBar:LoadBar;
		private var _length:uint;
		private var _position:int = 0;
		private var _cmenu:CMenu;
		private var _clockVisible:Boolean = true;
		private var _dsf:DropShadowFilter;
		private var _speakers:Speakers;
		private var _f:TextFormat;
		private var _shown:Boolean = false;
		private var _numbers:Array;
		private var _point:Sprite;
		private var _title:TextField;
		private var _um:UserMessage;
		private var _nodeDisplay:TextField;
		// display objects
		private var _forward:Btn;
		private var _back:Btn;
		private var _nodeItems:Array;
		// question
		private var _questionImage:SMILImage;
		private var _questionPlay:Btn;
		private var _questionPlayStretched:Btn;
		// answer
		private var _answerImage:SMILImage;
		private var _answerPlay:Btn;
		private var _answerPlayStretched:Btn;
		private var _pron:Pron;
		// speaker
		private var _speakerImage:SMILImage;
		private var _speakerPlay:Btn;
		private var _speakerPlayStretched:Btn;
		// IPA token
		private var _ipaImage:SMILImage;
		// video
		//
		private var _ts:int = 16; // text font size
		private var _btns:Array;
		// SMIL XML node
		private var _smilTextBtn:PingBtn;
		private var _smilText:TextField;
		// FlashVars
		private var _flashVarsBtn:PingBtn;
		private var _flashVarsText:TextField;
		// Services
		private var _servicesBtn:PingBtn;
		private var _services:AMFServices;
		private var _bg:Sprite;
		// Push grade
		private var _pushGradeBtn:PingBtn;
		private var _pushGrade:PushGrade;
		// Save Snapshot
		private var _snapshotBtn:PingBtn;
		//private var _snaphot:Snapshot;
		// Save avatar
		private var _saveAvatarBtn:PingBtn;
		//private var _saveAvatar:SaveAvatar;
		// Contact Matt
		private var _contactMattBtn:PingBtn;
		//
		
		public function SMILCartridgeChecker() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//_smil = new Namespace(En.SMIL_NAMESPACE_21);
			//default xml namespace = _smil;
			FlashVars.vars = this.root.loaderInfo.parameters;
			/*
			//FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects_short.smil";
			//FlashVars.xmlurl = "../commonobjects/xml/elem_common_objects_namespace.smil";
			//FlashVars.xmlurl = "../animals/xml/animals.smil";
			FlashVars.xmlurl = "../numbers_0-120/xml/numbers_0-120_all.smil";
			FlashVars.moodledata = "../";
			*/
			initCMenu();
			initLoadBar();
			positionLoadBar();
			loadData();
			stage.addEventListener(Event.RESIZE, resize);
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
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
			//trace(_xml.body.seq[0].par.(@id == "question").img.@src);
			//trace(_xml.name());
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_xml.name());
			default xml namespace = _smil;
			_length = _xml.body.seq.length();
			if(_length > 3) {
				initInteraction();
			} else {
				var msg:String = "Sorry, there is insuffient data for this activity. Please provide at least 4 items";
				showErrorMessage(msg);
				positionErrorMessage();
			}
		}
		
		function failedHandler(event:Event):void {
			_loadXML.removeEventListener(LoadXML.LOADED, loadedHandler);
			_loadXML.removeEventListener(LoadXML.FAILED, failedHandler);
			var msg:String = "Sorry, I couldn't find the data for this activity. Please try again. If this problem persists, please contact your teacher or the site administrator.";
			showErrorMessage(msg);
			positionErrorMessage();
		}
		
		private function showErrorMessage(msg:String):void {
			_um = new UserMessage(msg,null,400,18,0xdd0000,0xdddddd);
			addChild(_um);
		}
		
		private function positionErrorMessage():void {
			if(_um) {
				_um.x = stage.stageWidth * 0.5;
				_um.y = stage.stageHeight * 0.5;
			}
		}
		
		/*
		#################################################### INTERACTION #######################################################
		*/
		private function initInteraction():void {
			_dsf = new DropShadowFilter(2,45,0x000000,1,2,2);
			_f = new TextFormat();
			_f.font = "Trebuchet MS";
			_f.size = 15;
			_f.bold = true;
			initTitle();
			initScoreBar();
			initPoint();
			initControls();
			initNodeDisplay();
			//initScrollBar();
			initNode();
			initPron();
			initSpeakers();
			initSmilTextBtn();
			initFlashVarsBtn();
			initServicesBtn();
			initPushGradeBtn();
			initSnapshotBtn();
			initSaveAvatarBtn();
			initContactMattBtn();
			_btns = new Array(_smilTextBtn,_flashVarsBtn,_servicesBtn,_pushGradeBtn,_snapshotBtn,_saveAvatarBtn,_contactMattBtn);
			resize(null);
		}
		
		private function resize(event:Event):void {
			positionScoreBar();
			positionLoadBar();
			positionPoint();
			positionNodeDisplay();
			//positionScrollBar();
			positionControls();
			positionSpeakers();
			positionBtns();
		}
		
		private function initTitle():void {
			_title = new TextField();
			_title.selectable = false;
			_f.size = 15;
			_title.defaultTextFormat = _f;
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.text = "Keys: q=play question | w=play question stretched | a=play answer | s=play answer stretched";
			_title.y = 32;
			addChild(_title);
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
		
		private function initPoint():void {
			_point = new Sprite();
			_point.graphics.lineStyle(2,0x666666);
			_point.graphics.drawRoundRect(0,0,18,18,5,5);
			addChild(_point);
		}
		
		private function positionPoint():void {
			if(_point) {
				_point.x = _numbers[_position].x;
				_point.y = _numbers[_position].y;
			}
		}
		
		// Displays XML node data
		private function initNodeDisplay():void {
			var f:TextFormat = new TextFormat("Charis SIL",16,0,true);
			_nodeDisplay = new TextField();
			_nodeDisplay.defaultTextFormat = f;
			_nodeDisplay.embedFonts = true;
			_nodeDisplay.multiline = true;
			_nodeDisplay.autoSize = TextFieldAutoSize.LEFT;
			addChild(_nodeDisplay);
		}
		
		private function positionNodeDisplay():void {
			if(_nodeDisplay) {
				_nodeDisplay.y = 250;
				if(_nodeDisplay.width > stage.stageWidth) {
					_nodeDisplay.width = stage.stageWidth;
				}
			}
		}
		
		// node display forward and back controls
		private function initControls():void {
			_forward = new Btn("next");
			_forward.addEventListener(MouseEvent.MOUSE_UP, forwardUp);
			addChild(_forward);
			_back = new Btn("back");
			_back.addEventListener(MouseEvent.MOUSE_UP, backUp);
			addChild(_back);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function positionControls():void {
			if(_forward) {
				_forward.x = (stage.stageWidth * 0.5) + _forward.width;
				_forward.y = stage.stageHeight - (_forward.height + 20);
			}
			if(_back) {
				_back.x = (stage.stageWidth * 0.5) - _back.width;
				_back.y = stage.stageHeight - (_back.height + 20);
			}
		}
		
		private function keyDown(event:KeyboardEvent):void {
			var key:int = event.keyCode;
			switch(key) {
				
				case 190: // > = next
				forwardUp(null);
				break;
				
				case 188: // < = previous
				backUp(null);
				break;
				
				case 81: // q = play question
				playQuestion(null);
				break;
				
				case 87: // w = play question stretched
				playQuestionStretched(null);
				break;
				
				case 65: // a = play audio
				playAnswer(null);
				break;
				
				case 83: // s = play stretched
				playAnswerStretched(null);
				break;
				
				default:
				//
			}
		}
		
		// load next node
		private function forwardUp(event:MouseEvent):void {
			if(_position < _length - 1) {
				_position++;
			} else {
				_position = 0;
			}
			_point.x = _numbers[_position].x;
			_point.y = _numbers[_position].y;
			deleteNode();
			initNode();
		}
		
		// load previous node
		private function backUp(event:MouseEvent):void {
			if(_position > 0) {
				_position--;
			} else {
				_position = _length - 1;
			}
			_point.x = _numbers[_position].x;
			_point.y = _numbers[_position].y;
			deleteNode();
			initNode();
		}
		
		// load and display all node items
		private function initNode():void {
			var top:int = 140;
			_nodeItems = new Array();
			//
			// question
			_questionImage = new SMILImage(_position,_xml.body.seq[_position],FlashVars.moodledata);
			_questionImage.showQuestionImage();
			_questionImage.x = 100;
			_questionImage.y = top;
			addChild(_questionImage);
			_nodeItems.push(_questionImage);
			//
			_questionPlay = new Btn("play",_position);
			_questionPlay.addEventListener(MouseEvent.MOUSE_DOWN, playQuestion);
			_questionPlay.x = _questionImage.x - 85;
			_questionPlay.y = _questionImage.y - 60;
			addChild(_questionPlay);
			_nodeItems.push(_questionPlay);
			//
			_questionPlayStretched = new Btn("stretched",_position);
			_questionPlayStretched.addEventListener(MouseEvent.MOUSE_DOWN, playQuestionStretched);
			_questionPlayStretched.x = _questionPlay.x;
			_questionPlayStretched.y = _questionPlay.y + _questionPlay.height + 2;
			addChild(_questionPlayStretched);
			_nodeItems.push(_questionPlayStretched);
			//
			// answer
			_answerImage = new SMILImage(_position,_xml.body.seq[_position],FlashVars.moodledata);
			_answerImage.showAnswerImage();
			_answerImage.x = 304;
			_answerImage.y = top;
			addChild(_answerImage);
			_nodeItems.push(_answerImage);
			//
			_answerPlay = new Btn("play",_position);
			_answerPlay.addEventListener(MouseEvent.MOUSE_DOWN, playAnswer);
			_answerPlay.addEventListener(MouseEvent.MOUSE_OVER, showIPAAnswer);
			_answerPlay.x = _answerImage.x - 85;
			_answerPlay.y = _answerImage.y - 60;
			addChild(_answerPlay);
			_nodeItems.push(_answerPlay);
			//
			_answerPlayStretched = new Btn("stretched",_position);
			_answerPlayStretched.addEventListener(MouseEvent.MOUSE_DOWN, playAnswerStretched);
			_answerPlayStretched.x = _answerPlay.x;
			_answerPlayStretched.y = _answerPlay.y + _answerPlay.height + 2;
			addChild(_answerPlayStretched);
			_nodeItems.push(_answerPlayStretched);
			// speaker
			_speakerImage = new SMILImage(_position,_xml.body.seq[_position],FlashVars.moodledata);
			_speakerImage.addEventListener(MouseEvent.MOUSE_DOWN, showSpeaker);
			_speakerImage.showSpeakerImage();
			_speakerImage.x = 508;
			_speakerImage.y = top;
			addChild(_speakerImage);
			_nodeItems.push(_speakerImage);
			// IPA token
			_ipaImage = new SMILImage(_position,_xml.body.seq[_position],FlashVars.moodledata);
			_ipaImage.showIPA();
			_ipaImage.x = 712;
			_ipaImage.y = top;
			addChild(_ipaImage);
			_nodeItems.push(_ipaImage);
			//
			_speakerPlay = new Btn("play",_position);
			_speakerPlay.addEventListener(MouseEvent.MOUSE_DOWN, playSpeaker);
			_speakerPlay.x = _speakerImage.x - 85;
			_speakerPlay.y = _speakerImage.y - 60;
			addChild(_speakerPlay);
			_nodeItems.push(_speakerPlay);
			//
			_speakerPlayStretched = new Btn("stretched",_position);
			_speakerPlayStretched.addEventListener(MouseEvent.MOUSE_DOWN, playSpeakerStretched);
			_speakerPlayStretched.x = _speakerImage.x - 85;
			_speakerPlayStretched.y = _speakerPlay.y  + _speakerPlay.height + 2;
			addChild(_speakerPlayStretched);
			_nodeItems.push(_speakerPlayStretched);
			//
			// video - TODO - Create video player & control bar
			
			// display XML node as text
			displayNodeText();
			//_scrollBar.update();
			// SMIL XML text panel
			if(_smilText) {
				_smilText.text = String(_xml.body.seq[_position]);
				addChild(_smilText);
			}
			// FlashVars text panel
			if(_flashVarsText) {
				addChild(_flashVarsText);
			}
			// Services text panel
			if(_services) {
				addChild(_bg);
				addChild(_services);
			}
		}
		
		private function deleteNode():void {
			var len:uint = _nodeItems.length;
			for(var i:uint = 0; i < len; i++) {
				removeChild(_nodeItems[i]);
			}
		}
		
		private function initPron():void {
			_pron = new Pron(":)");
			_pron.visible = false;
			addChild(_pron);
		}
		
		// question
		private function playQuestion(event:MouseEvent):void {
			_questionImage.playQuestion();
		}
		
		private function playQuestionStretched(event:MouseEvent):void {
			_questionImage.playQuestionStretched();
		}
		
		// answer
		private function playAnswer(event:MouseEvent):void {
			_answerImage.playAnswer();
		}
		
		// show IPA for answer
		private function showIPAAnswer(event:MouseEvent):void {
			_answerPlay.removeEventListener(MouseEvent.MOUSE_OVER, showIPAAnswer);
			_answerPlay.addEventListener(MouseEvent.MOUSE_OUT, hideIPAAnswer);
			_pron.tokens = _xml.body.seq[_position].par.(@id == "answer").audio.(@id == "normal").@pron;
			_pron.x = mouseX;
			_pron.y = mouseY;
			_pron.visible = true;
			addChild(_pron);
		}
		
		private function hideIPAAnswer(event:MouseEvent):void {
			_answerPlay.removeEventListener(MouseEvent.MOUSE_OUT, hideIPAAnswer);
			_answerPlay.addEventListener(MouseEvent.MOUSE_OVER, showIPAAnswer);
			_pron.visible = false;
		}
		
		private function playAnswerStretched(event:MouseEvent):void {
			_answerImage.playAnswerStretched();
		}
		
		// speaker
		private function showSpeaker(event:MouseEvent):void {
			//
		}
		
		//
		private function playSpeaker(event:MouseEvent):void {
			_speakerImage.playSpeaker();
		}
		
		// 
		private function playSpeakerStretched(event:MouseEvent):void {
			_speakerImage.playSpeakerStretched();
		}
		
		private function displayNodeText():void {
			var output:String = "question = ";
			try {
				output += _xml.body.seq[_position].par.(@id == "question").text[0];
			} catch(e:Error) {
				output += " - ";
			}
			output += "\nanswer = ";
			try {
				output += _xml.body.seq[_position].par.(@id == "answer").text[0];
			} catch(e:Error) {
				output += " - ";
			}
			output += "\npron = ";
			try {
				output += _xml.body.seq[_position].par.(@id == "answer").audio.(@id == "normal").@pron;
			} catch(e:Error) {
				output += " - ";
			}
			output += "\ngapfill (beg | mid | end): ";
			try {
				output += _xml.body.seq[_position].par.(@id == "gapfill").text.(@id == "beg") + " | ";
			} catch(e:Error) {
				output += " - ";
			}
			try {
				output += _xml.body.seq[_position].par.(@id == "gapfill").text.(@id == "mid") + " | ";
			} catch(e:Error) {
				output += " - ";
			}
			try {
				output += _xml.body.seq[_position].par.(@id == "gapfill").text.(@id == "end");
			} catch(e:Error) {
				output += " - ";
			}
			try {
				var correct:String = _xml.body.seq[_position].par.(@id == "correct").text[0];
				if(correct && correct != "") {
					output += "\ncorrect = " + correct;
				}
			} catch(e:Error) {
				output += " - ";
			}
			try {
				var wrong:String = _xml.body.seq[_position].par.(@id == "wrong").text[0];
				if(wrong && wrong != "") {
					output += "\nwrong = " + wrong;
				}
			} catch(e:Error) {
				output += " - ";
			}
			output += "\nkeyword = ";
			try {
				output += _xml.body.seq[_position].par.(@id == "keyword").text[0];
				output += " " + _xml.body.seq[_position].par.(@id == "keyword").text[0].@pron;
			} catch(e:Error) {
				output += " - ";
			}
			try {
				var speaker:String = _xml.body.seq[_position].par.(@id == "speaker").text[0];
				if(speaker && speaker != "") {
					output += "\nspeaker = " + speaker;
				}
			} catch(e:Error) {
				output += " - ";
			}
			_nodeDisplay.text = output;
		}
		
		/*
		############################ SMIL XML TEXT DISPLAY #############################
		*/
		private function initSmilTextBtn():void {
			_smilTextBtn = new PingBtn("Show SMIL");
			_smilTextBtn.addEventListener(MouseEvent.MOUSE_UP, smilTextUp);
			_smilTextBtn.x = stage.stageWidth - _smilTextBtn.width;
			_smilTextBtn.y = _smilTextBtn.height * 0.5;
			addChild(_smilTextBtn);
		}
		
		private function smilTextUp(event:MouseEvent):void {
			if(_smilText) {
				deleteSmilText();
			} else {
				initSmilText();
				positionSmilText();
			}
		}
		
		private function initSmilText():void {
			var f:TextFormat = new TextFormat("Charis SIL",14);
			_smilText = new TextField();
			_smilText.defaultTextFormat = f;
			_smilText.background = true;
			_smilText.wordWrap = true;
			_smilText.text = String(_xml.body.seq[_position]);
			addChild(_smilText);
			_smilTextBtn.txt = "Hide SMIL";
		}
		
		private function positionSmilText():void {
			if(_smilText) {
				_smilText.y = 30;
				_smilText.width = stage.stageWidth;
				_smilText.height = stage.stageHeight - _smilText.y;
			}
		}
		
		private function deleteSmilText():void {
			if(_smilText) {
				removeChild(_smilText);
				_smilText = null;
				_smilTextBtn.txt = "Show SMIL";
			}
		}
		
		/*
		############################ FLASHVARS TEXT DISPLAY #############################
		*/
		private function initFlashVarsBtn():void {
			_flashVarsBtn = new PingBtn("Show FlashVars");
			_flashVarsBtn.addEventListener(MouseEvent.MOUSE_UP, flashVarsTextUp);
			addChild(_flashVarsBtn);
		}
		
		private function flashVarsTextUp(event:MouseEvent):void {
			if(_flashVarsText) {
				deleteFlashVarsText();
			} else {
				initFlashVarsText();
				positionFlashVarsText();
			}
		}
		
		private function initFlashVarsText():void {
			var f:TextFormat = new TextFormat("Charis SIL",14);
			_flashVarsText = new TextField();
			_flashVarsText.defaultTextFormat = f;
			_flashVarsText.background = true;
			_flashVarsText.wordWrap = true;
			var vars:Array = new Array();
			var obj:Object = this.root.loaderInfo.parameters;
			for(var s:String in obj) {
				vars.push(s + " = " + obj[s]);
			}
			vars.sort();
			var str:String = "";
			var len:uint = vars.length;
			for(var i:uint = 0; i < len; i++) {
				str += vars[i] + "\n";
			}
			_flashVarsText.text = str;
			addChild(_flashVarsText);
			_flashVarsBtn.txt = "Hide FlashVars";
		}
		
		private function positionFlashVarsText():void {
			if(_flashVarsText) {
				_flashVarsText.y = 30;
				_flashVarsText.width = stage.stageWidth;
				_flashVarsText.height = stage.stageHeight - _flashVarsText.y;
			}
		}
		
		private function deleteFlashVarsText():void {
			if(_flashVarsText) {
				removeChild(_flashVarsText);
				_flashVarsText = null;
				_flashVarsBtn.txt = "Show FlashVars";
			}
		}
		
		/*
		############################ SERVICES DISPLAY #############################
		*/
		private function initServicesBtn():void {
			_servicesBtn = new PingBtn("Show Services");
			_servicesBtn.addEventListener(MouseEvent.MOUSE_UP, servicesUp);
			addChild(_servicesBtn);
		}
		
		private function servicesUp(event:MouseEvent):void {
			if(_services) {
				deleteServices();
				deleteBg();
			} else {
				initBg();
				initServices();
				positionServices();
			}
		}
		
		private function initServices():void {
			_services = new AMFServices();
			addChild(_services);
			_servicesBtn.txt = "Hide Services";
		}
		
		private function positionServices():void {
			if(_services) {
				_services.y = 30;
				_bg.width = stage.stageWidth;
				_bg.height = stage.stageHeight - _services.y;
			}
		}
		
		private function deleteServices():void {
			if(_services) {
				removeChild(_services);
				_services = null;
				_servicesBtn.txt = "Show Services";
			}
		}
		
		/*
		############################ SEND GRADE #############################
		*/
		private function initPushGradeBtn():void {
			_pushGradeBtn = new PingBtn("Push Grade");
			_pushGradeBtn.addEventListener(MouseEvent.MOUSE_UP, pushGradeUp);
			addChild(_pushGradeBtn);
		}
		
		private function pushGradeUp(event:MouseEvent):void {
			if(_pushGrade) {
				deletePushGrade();
				deleteBg();
				_pushGradeBtn.txt = "Push Grade";
			} else {
				initBg();
				initPushGrade();
				_pushGradeBtn.txt = "Hide Grade";
			}
		}
		
		private function initPushGrade():void {
			_pushGrade = new PushGrade();
			_pushGrade.y = 50;
			addChild(_pushGrade);
		}
		
		private function deletePushGrade():void {
			if(_pushGrade) {
				removeChild(_pushGrade);
				_pushGrade = null;
			}
		}
		
		/*
		############################ SAVE IMAGE #############################
		*/
		private function initSnapshotBtn():void {
			_snapshotBtn = new PingBtn("Save Snapshot");
			_snapshotBtn.addEventListener(MouseEvent.MOUSE_UP, snapshotUp);
			addChild(_snapshotBtn);
		}
		
		private function snapshotUp(event:MouseEvent):void {
			/*if(_snapshot) {
				deleteSnapshot();
				deleteBg();
				_snapshotBtn.txt = "Save Snapshot";
			} else {
				initBg();
				initSnapshot();
				_snapshotBtn.txt = "Hide Snapshot";
			}*/
		}
		
		private function initSnapshot():void {
			/*_snapshot = new Snapshot();
			_snapshot.y = 50;
			addChild(_snapshot);*/
		}
		
		private function deleteSnapshot():void {
			/*if(_snapshot) {
				removeChild(_snapshot);
				_snapshot = null;
			}*/
		}
		
		/*
		############################ SAVE AVATAR #############################
		*/
		private function initSaveAvatarBtn():void {
			_saveAvatarBtn = new PingBtn("Save Avatar");
			_saveAvatarBtn.addEventListener(MouseEvent.MOUSE_UP, saveAvatarUp);
			addChild(_saveAvatarBtn);
		}
		
		private function saveAvatarUp(event:MouseEvent):void {
			/*if(_snapshot) {
				deleteSaveAvatar();
				deleteBg();
				_saveAvatarBtn.txt = "Save Avatar";
			} else {
				initBg();
				initSaveAvatar();
				_saveAvatarBtn.txt = "Hide Avatar";
			}*/
		}
		
		private function initSaveAvatar():void {
			/*_saveAvatar = new SaveAvatar();
			_saveAvatar.y = 50;
			addChild(_saveAvatar);*/
		}
		
		private function deleteSaveAvatar():void {
			/*if(_saveAvatar) {
				removeChild(_saveAvatar);
				_saveAvatar = null;
			}*/
		}
		
		/*
		############################ CONTACT MATT #############################
		*/
		private function initContactMattBtn():void {
			_contactMattBtn = new PingBtn("Contact Matt");
			_contactMattBtn.addEventListener(MouseEvent.MOUSE_UP, contactMattUp);
			addChild(_contactMattBtn);
		}
		
		private function contactMattUp(event:MouseEvent):void {
			var url:String = "http://blog.matbury.com/contact/";
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request,"_blank");
		}
		
		private function positionBtns():void {
			var posX:int = 0;
			var len:uint = _btns.length;
			for(var i:uint = 0; i < len; i++) {
				_btns[i].y = 2;
				_btns[i].x = posX;
				posX += _btns[i].width + 3;
			}
		}
		
		/*
		############################ BACKGROUND #############################
		*/
		private function initBg():void {
			_bg = new Sprite();
			_bg.graphics.beginFill(0xFFFFFF,1);
			_bg.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight - 30);
			_bg.graphics.endFill();
			_bg.y = 30;
			addChild(_bg);
		}
		
		private function positionBg():void {
			if(_bg) {
				_bg.y = 30;
				_bg.height = stage.stageHeight - 30;
				_bg.width = stage.stageWidth;
			}
		}
		
		private function deleteBg():void {
			if(_bg) {
				removeChild(_bg);
				_bg = null;
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
		}
	}
}
package com.matbury.milas {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import com.matbury.Clock;
	import com.matbury.CMenu;
	import com.matbury.LoadXML;
	import com.matbury.UserMessage;
	import com.matbury.milas.lang.en.Lang;
	import com.matbury.sam.data.FlashVars;
	import com.matbury.sam.gui.LoadBar;
	import com.matbury.sam.gui.Speakers;
	import com.matbury.sam.gui.Symbol;
	
	public class SMILIPA extends Sprite {
		
		// model
		private var _version:String = "2014.04.20";
		private var _lxml:LoadXML;
		private var _smil:Namespace;
		// view
		private var _space:int = 5;
		private var _size:Number = 45;
		private var _right:int;
		private var _dsf:DropShadowFilter;
		private var _font:Font;
		private var _tf:TextFormat;
		private var _colours:Array;
		private var _um:UserMessage;
		private var _clock:Clock;
		private var _speakers:Speakers;
		private var _loadBar:LoadBar;
		// controller
		private var _groups:Array; // 2D array of phonetic symbol buttons
		private var _current:Symbol;
		private var _currBtn:Sprite; // current play button within Btn
		private var _title:TextField;
		private var _buttons:Array; // current symbol play buttons
		
		public function SMILIPA() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			FlashVars.vars = this.root.loaderInfo.parameters;
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			/*
			//FlashVars.xmlurl = "../pron/xml/phonemics_general_intermediate.xml";
			FlashVars.xmlurl = "../pron/xml/phonemics_general_elementary.smil";
			FlashVars.moodledata = "../";
			initLoadBar();
			positionLoadBar();
			loadData();
			*/
			if(this.root.loaderInfo.parameters.size) {
				_size = this.root.loaderInfo.parameters.size;
			}
			initCMenu();
			stage.addEventListener(Event.RESIZE, resize);
			securityCheck();
		}
		
		private function initCMenu():void {
			var cmenu:CMenu = new CMenu(_version);
			addChild(cmenu);
		}
		
		/*
		####################################### STAGE RESIZE ########################################
		*/
		private function resize(event:Event):void {
			positionLoadBar();
			positionUserMessage();
			positionSpeakers();
			positionClock();
		}
		
		/*
		####################################### LICENCE CHECK ########################################
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
		
		// show user error message with details
		private function showError(message:String):void {
			_um = new UserMessage(message,null,400,18,0xdd0000,0xeeeeee);
			_um.x = stage.stageWidth * 0.5;
			_um.y = stage.stageHeight * 0.5;
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
		####################################### LOAD XML DATA ########################################
		*/
		private function loadData():void {
			_lxml = new LoadXML();
			_lxml.addEventListener(LoadXML.LOADED, loadedHandler);
			_lxml.addEventListener(LoadXML.FAILED, failedHandler);
			_lxml.load(FlashVars.xmlurl);
		}
		
		private function loadedHandler(event:Event):void {
			_lxml.removeEventListener(LoadXML.LOADED, loadedHandler);
			_lxml.removeEventListener(LoadXML.FAILED, failedHandler);
			deleteLoadBar();
			// get any namespace properties to avoid parsing errors
			_smil = new Namespace(_lxml.xml.name());
			default xml namespace = _smil;
			initChart();
		}
		
		private function failedHandler(event:Event):void {
			_lxml.removeEventListener(LoadXML.LOADED, loadedHandler);
			_lxml.removeEventListener(LoadXML.FAILED, failedHandler);
			showError(Lang.NO_ACTIVITY_DATA);
		}
		
		/*
		####################################### START INTERACTION ########################################
		*/
		// create phonemic symbols chart from loaded XML file
		private function initChart():void {
			var space:int = _size * 1.5;
			_colours = new Array(0xff9900,0xdd0000,0x9800ff,0x00bb00,0x0000ff,0x888888,0x662200,0x006688,0xDD00DD,0x88DD00,0xff9900,0xdd0000,0x9800ff,0x00bb00,0x0000ff,0x888888,0x662200,0x006688,0xDD00DD,0x88DD00); // border colours for phonemic buttons
			_groups = new Array();
			var len:uint = _lxml.xml.body.seq.length();
			for(var i:uint = 0; i < len; i++) {
				var group:Array = createSymbols(_lxml.xml.body.seq[i],_colours[i],space * i);
				_groups.push(group);
			}
			initTitle();
			positionTitle();
			initSpeakers();
			positionSpeakers();
			initClock();
			positionClock();
		}
		
		private function initTitle():void {
			_tf = new TextFormat("Charis SIL",_size,0);
			_title = new TextField();
			_title.embedFonts = true;
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.defaultTextFormat = _tf;
			_title.text = "";
			addChild(_title);
		}
		
		private function positionTitle():void {
			if(_title) {
				_title.x = _right + 60;
				_title.y = 10;
			}
		}
		
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
		
		// create phonemic symbol button from XML node
		private function createSymbols(xml:XML,colour:Number,posX:int):Array {
			var btns:Array = new Array();
			var len:uint = xml.par.length();
			for(var i:uint = 0; i < len; i++) {
				var b:Symbol = new Symbol(xml.par[i],_size,colour);
				b.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
				b.x = b.width + posX;
				b.y = i * (b.width + _space) + b.width;
				b.filters = [_dsf];
				addChild(b);
				btns.push(b);
			}
			_right = posX + b.width;
			return btns;
		}
		
		private function downHandler(event:MouseEvent):void {
			_current = event.currentTarget as Symbol;
			_current.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			_current.x += 2;
			_current.y += 2;
			_current.filters = [];
			_title.text = "/" + _current.char + "/";
			initButtons();
		}
		
		private function upHandler(event:MouseEvent):void {
			_current.addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			_current.x -= 2;
			_current.y -= 2;
			_current.filters = [_dsf];
		}
		
		/*
		####################################### PLAY BUTTONS ########################################
		*/
		// Create play button for each word in list
		private function initButtons():void {
			if(_buttons) {
				deleteButtons();
			}
			_buttons = new Array();
			var len:uint = _current.xml.audio.length();
			for(var i:uint = 0; i < len; i++) {
				var b:Bttn = new Bttn(_current.xml.audio[i],_size);
				b.x = _title.x;
				b.y = _title.y + _title.height + (i * (b.height));
				b.bg.filters = [_dsf];
				b.bg.addEventListener(MouseEvent.MOUSE_DOWN, btnDownHandler);
				addChild(b);
				_buttons.push(b);
			}
		}
		
		private function deleteButtons():void {
			var len:uint = _buttons.length;
			for(var i:uint = 0; i < len; i++) {
				removeChild(_buttons[i]);
				_buttons[i].bg.addEventListener(MouseEvent.MOUSE_DOWN, btnDownHandler);
				_buttons[i] = null;
			}
			_buttons = null;
		}
		
		private function btnDownHandler(event:MouseEvent):void {
			_currBtn = event.currentTarget as Sprite;
			_currBtn.removeEventListener(MouseEvent.MOUSE_DOWN, btnDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, btnUpHandler);
			_currBtn.x += 2;
			_currBtn.y += 2;
			_currBtn.filters = [];
			playSound();
		}
		
		private function btnUpHandler(event:MouseEvent):void {
			_currBtn.addEventListener(MouseEvent.MOUSE_DOWN, btnDownHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, btnUpHandler);
			_currBtn.x -= 2;
			_currBtn.y -= 2;
			_currBtn.filters = [_dsf];
		}
		
		private function playSound():void {
			var btn:Bttn = _currBtn.parent as Bttn;
			var url:String = FlashVars.moodledata + btn.url;
			var request:URLRequest = new URLRequest(url);
			var sound:Sound = new Sound();
			sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			var context:SoundLoaderContext = new SoundLoaderContext(10);
			sound.load(request,context);
			sound.play();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			//trace(event);
		}
		
		/*
		####################################### SPEAKERS ########################################
		*/
		// Tell user to expect audio
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
		
		// remove poster and start activity clock
		private function speakersDown(event:MouseEvent):void {
			_speakers.removeEventListener(MouseEvent.MOUSE_UP, speakersDown);
			removeChild(_speakers);
			_speakers = null;
			_clock.startClock();
		}
	}
}
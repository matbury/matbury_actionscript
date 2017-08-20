package com.matbury.milas {
	
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.*;
    import flash.filters.DropShadowFilter;
    import flash.geom.Matrix;
    import flash.media.Camera;
    import flash.media.Video;
    import flash.net.*;
    import flash.text.*;
    import flash.utils.ByteArray;
    import com.adobe.images.JPGEncoder;
    import com.matbury.CMenu;
    import com.matbury.ResizeBitmap;
    import com.matbury.UserMessage;
    import com.matbury.sam.data.Amf;
    import com.matbury.sam.data.FlashVars;
    import com.matbury.sam.gui.Btn;
    import com.matbury.sam.gui.LoadBar;
    import com.matbury.milas.lang.en.Lang;

    public class AvatarCamera extends Sprite {
		
		private var _version:String = "2011.08.28";
		private var _amf:Amf;
		private var _current:TextField;
		private var _instructions:TextField;
		private var _loadBar:LoadBar;
        private var _video:Video;
		private var _snapshotsSmall:Array;
		private var _snapshotsBig:Array;
		private var _avatars:Array;
		private var _i:uint = 0;
		private var _cmenu:CMenu;
		private var _shutter:Btn;
		private var _deleteAll:Btn;
		private var _byteArray:ByteArray;
		private var _um:UserMessage;
		private var _dsf:DropShadowFilter;
		private var _big:Loader;
		private var _small:Loader;
        
        public function AvatarCamera() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			FlashVars.vars = this.root.loaderInfo.parameters;
			stage.addEventListener(Event.RESIZE, resize);
			_dsf = new DropShadowFilter(2,45,0,1,2,2);
			initCMenu();
			//securityCheck();
                        initInteraction();
		}
		
		private function resize(event:Event):void {
			positionText();
			positionUserMessage();
			positionCurrentAvatars();
			positionLoadBar();
			positionCamera();
			positionShutter();
			positionDeleteAll();
			positionAvatars();
		}
		
		private function initCMenu():void {
			_cmenu = new CMenu(_version);
			addChild(_cmenu);
		}
		
		/*
		######################### SECURITY CHECK ##########################
		*/
		// check website URL for instance of permitted domain
		private function securityCheck():void {
			var sc:LicenceCheck = new LicenceCheck();
			var checked:Boolean = sc.check(this.root.loaderInfo.url);
			if(checked) {
				initInteraction();
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
		##################################### INTERACTION ######################################
		*/
		private function initInteraction():void {
			_snapshotsSmall = new Array();
			_snapshotsBig = new Array();
			_avatars = new Array();
			initText();
			loadCurrentAvatars();
			positionCurrentAvatars();
			initLoadBar();
			positionLoadBar();
			initCamera();
			initShutter();
			positionShutter();
			initDeleteAll();
			positionDeleteAll();
			resize(null);
		}
		
		/*
		##################################### TEXT ######################################
		*/
		private function initText():void {
			var f:TextFormat = new TextFormat(Lang.FONT,20,0xFFFFFF,true);
			_current = new TextField();
			_current.defaultTextFormat = f;
			_current.autoSize = TextFieldAutoSize.LEFT;
			_current.embedFonts = true;
			_current.text = "Current avatar:";
			addChild(_current);
			_instructions = new TextField();
			_instructions.defaultTextFormat = f;
			_instructions.autoSize = TextFieldAutoSize.LEFT;
			_instructions.multiline = true;
			_instructions.embedFonts = true;
			_instructions.text = "Click button to take avatar snapshots.\nClick on desired avatar to save it.";
			addChild(_instructions);
		}
		
		private function positionText():void {
			if(_current) {
				_current.x = 5;
				_current.y = 5;
			}
			if(_instructions) {
				_instructions.x = stage.stageWidth * 0.6;
				_instructions.y = 30;
			}
		}
		
		private function deleteText():void {
			if(_current) {
				removeChild(_current);
				_current = null;
			}
		}
		
		/*
		##################################### CURRENT AVATARS ######################################
		*/
		private function loadCurrentAvatars():void {
			var date:Date = new Date();
			var big:String = FlashVars.wwwroot + "user/pix.php/" + FlashVars.userid + "/f1.jpg?nocache=" + date.time;
			var bigRequest:URLRequest = new URLRequest(big);
			_big = new Loader();
			configureListeners(_big.contentLoaderInfo);
			_big.load(bigRequest);
			addChild(_big);
			//
			var small:String = FlashVars.wwwroot + "user/pix.php/" + FlashVars.userid + "/f2.jpg?nocache=" + date.time;
			var smallRequest:URLRequest = new URLRequest(small);
			_small = new Loader();
			configureListeners(_small.contentLoaderInfo);
			_small.load(smallRequest);
			addChild(_small);
		}
		
		private function positionCurrentAvatars():void {
			if(_big) {
				_big.x = 5;
				_big.y = 30;
			}
			if(_small) {
				_small.x = 110;
				_small.y = 30;
			}
		}
		
		private function deleteCurrentAvatars():void {
			if(_big) {
				removeChild(_big);
				_big = null;
			}
			if(_small) {
				removeChild(_small);
				_small = null;
			}
		}
		
		private function refreshAvatars():void {
			deleteCurrentAvatars();
			loadCurrentAvatars();
			positionCurrentAvatars();
		}
		
		private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, loaderComplete);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
		
		private function removeListeners(dispatcher:IEventDispatcher):void {
			dispatcher.removeEventListener(Event.COMPLETE, loaderComplete);
			dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
		
		private function loaderComplete(event:Event):void {
			var dispatcher:IEventDispatcher = event.target.loader.contentLoaderInfo as IEventDispatcher;
			removeListeners(dispatcher);
		}
		
		private function ioError(event:IOErrorEvent):void {
			var dispatcher:IEventDispatcher = event.target.loader.contentLoaderInfo as IEventDispatcher;
			removeListeners(dispatcher);
		}
		
		/*
		##################################### LOAD BAR ######################################
		*/
		private function initLoadBar():void {
			_loadBar = new LoadBar();
			addChild(_loadBar);
		}
		
		private function positionLoadBar():void {
			if(_loadBar) {
				_loadBar.x = stage.stageWidth * 0.5;
				_loadBar.y = 80;
			}
		}
		
		private function deleteLoadBar():void {
			if(_loadBar) {
				removeChild(_loadBar);
				_loadBar = null;
			}
		}
		
		/*
		##################################### CAMERA ######################################
		*/
		private function initCamera():void {
            var camera:Camera = Camera.getCamera();
			camera.setMode(100, 100, 30);
            if (camera != null) {
                _video = new Video(100, 100);
				_video.smoothing = true;
                _video.attachCamera(camera);
                addChild(_video);
            } else {
                showMessage("You need a camera.");
				positionUserMessage();
            }
        }
		
		private function positionCamera():void {
			if(_video) {
				_video.x = stage.stageWidth * 0.5 - (_video.width * 0.5);
				_video.y = 30;
			}
		}
        
		private function initShutter():void {
			_shutter = new Btn("camera");
			_shutter.addEventListener(MouseEvent.MOUSE_DOWN, shutterDown);
			addChild(_shutter);
		}
		
		private function positionShutter():void {
			if(_shutter) {
				_shutter.x = stage.stageWidth * 0.5 + 75;
				_shutter.y = 80;
			}
		}
		
		private function shutterDown(event:MouseEvent):void {
			var bitmapData:BitmapData = new BitmapData(_video.width, _video.height, false, 0xFFFFFF);
			bitmapData.draw(Video(_video), null, null, null, null, true);
			var avatar:Avatar = new Avatar(bitmapData, _i);
			avatar.addEventListener(MouseEvent.MOUSE_UP, avatarUp);
			_i++;
			addChild(avatar);
			_avatars.push(avatar);
			positionAvatars();
			positionDeleteAll();
		}
		
		private function positionAvatars():void {
			var len:uint = _avatars.length;
			var posX:int = 5;
			var posY:int = 150;
			for(var i:uint = 0; i < len; i++) {
				_avatars[i].x = posX;
				_avatars[i].y = posY;
				posX = _avatars[i].x + _avatars[i].width + 5;
				if(posX >= stage.stageWidth - (_avatars[i].width + 5)) {
					posX = 5;
					posY += _avatars[i].height + 10;
				}
			}
		}
		
		private function deleteAllAvatars():void {
			var len:uint = _avatars.length;
			for(var i:uint = 0; i < len; i++) {
				removeChild(_avatars[i]);
				_avatars[i] = null;
			}
			_avatars = new Array();
			_i = 0;
		}
		
		private function avatarUp(event:MouseEvent):void {
			var avatar:Avatar = event.currentTarget as Avatar;
			sendData(avatar.i);
		}
		
		private function initDeleteAll():void {
			_deleteAll = new Btn("Delete all");
			_deleteAll.addEventListener(MouseEvent.MOUSE_UP, deleteAllUp);
			addChild(_deleteAll);
		}
		
		private function positionDeleteAll():void {
			if(_deleteAll) {
				_deleteAll.x = stage.stageWidth * 0.5;
				_deleteAll.y = stage.stageHeight * 0.95;
				addChild(_deleteAll);
			}
		}
		
		private function deleteAllUp(event:MouseEvent):void {
				deleteAllAvatars();
		}
		
		/*
		################################################## USER MESSAGE #####################################################
		*/
		// Show text message to user
		private function showMessage(message:String):void {
			deleteUserMessage();
			_um = new UserMessage(message);
			_um.filters = [_dsf];
			addChild(_um);
		}
		
		private function deleteUserMessage():void {
			if(_um) {
				removeChild(_um);
				_um = null;
			}
		}
		
		/*
		################################################## SEND DATA #####################################################
		*/
		// Send the snapshot to the server to be saved by Snapshot.php
		private function sendData(index:uint):void {
			// Tell user what we're doing.
			showMessage("Saving your image...");
			positionUserMessage();
			var jpgEncoder:JPGEncoder = new JPGEncoder(80);
			var avatar:ByteArray = jpgEncoder.encode(_avatars[index].avatar);
			var thumb:ByteArray = jpgEncoder.encode(_avatars[index].thumb);
			// Send the ByteArray to AMFPHP
			_amf = new Amf(); // create Flash Remoting API object
			_amf.addEventListener(Amf.GOT_DATA, gotDataHandler); // listen for server response
			_amf.addEventListener(Amf.FAULT, faultHandler); // listen for server fault
			var obj:Object = new Object(); // create an object to hold data sent to the server
			obj.feedback = "User has successfully saved avatar from webcam."; // (String) optional
			obj.feedbackformat = 0; // (int) elapsed time in seconds
			obj.gateway = FlashVars.gateway; // (String) AMFPHP gateway URL
			obj.instance = FlashVars.instance; // (int) Moodle instance ID
			obj.rawgrade = 100; // (Number) grade, normally 0 - 100 but depends on grade book settings
			obj.pushgrade = true;
			obj.servicefunction = "Snapshot.amf_save_avatar"; // (String) ClassName.method_name
			obj.swfid = FlashVars.swfid; // (int) activity ID
			obj.avatar = avatar;
			obj.thumb = thumb;
			obj.imagetype = "jpg"; // PNGExport = png, JPGExport = jpg
			_amf.getObject(obj); // send the data to the server
		}
		
		// Connection to AMFPHP succeeded
		// Manage returned data and inform user
		private function gotDataHandler(event:Event):void {
			// Clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			// Check if grade was sent successfully
			switch(_amf.obj.result) {
				//
				case "SUCCESS":
				//showMessage(_amf.obj.message);
				//positionUserMessage();
				//navigateToImage(_amf.obj.imageurl);
				deleteUserMessage();
				refreshAvatars();
				break;
				//
				case "NO_SNAPSHOT_DIRECTORY":
				showMessage(_amf.obj.message);
				positionUserMessage();
				break;
				//
				case "FILE_NOT_WRITTEN":
				showMessage(_amf.obj.message);
				positionUserMessage();
				break;
				//
				case "NO_PERMISSION":
				showMessage(_amf.obj.message);
				positionUserMessage();
				break;
				//
				default:
				showMessage("Unknown error.");
				positionUserMessage();
			}
		}
		
		// Display server errors
		private function faultHandler(event:Event):void {
			// clean up listeners
			_amf.removeEventListener(Amf.GOT_DATA, gotDataHandler);
			_amf.removeEventListener(Amf.FAULT, faultHandler);
			var message:String = "Error: ";
			for(var s:String in _amf.obj.info) { // trace out returned data
				message += "\n" + s + "=" + _amf.obj.info[s];
			}
			showMessage(message);
			_um.addMessage(_amf.obj.toString());
			positionUserMessage();
		}
		
		private function navigateToImage(url:String):void {
			// Open returned URL in a new window,
			var request:URLRequest = new URLRequest(url);
			//navigateToURL(request,"_blank");
		}
    }
}
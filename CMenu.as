/*
CMenu class by Matt Bury
matbury@gmail.com
http://matbury.com

Example code:

		private function initCMenu():void {
			var version:String = "2011.01.22";
			_cmenu = new CMenu(version);
			addChild(_cmenu);
		}
		
*/

package com.matbury {
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	public class CMenu extends Sprite{
		
		private var _cm:ContextMenu;
		private var _version:String;
		
		public function CMenu(version:String = "undefined") {
			_version = version;
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(event:Event):void {
			_cm = new ContextMenu();
			removeDefaultItems();
			addCustomItems();
			parent.contextMenu = _cm;
		}
		
		private function removeDefaultItems():void {
			_cm.hideBuiltInItems();
			var defaultItems:ContextMenuBuiltInItems = _cm.builtInItems;
            defaultItems.print = true;
		}
		
		private function addCustomItems():void {
			// Title
			var mila:ContextMenuItem = new ContextMenuItem("Multimedia Interactive Learning Application (MILA)");
			_cm.customItems.push(mila);
			// Copyright
			var c:String = String.fromCharCode(169);
			var copyright:ContextMenuItem = new ContextMenuItem("Copyright " + c + " 2011 Matt Bury");
			_cm.customItems.push(copyright);
			// Link to matbury.com
			var matbury:ContextMenuItem = new ContextMenuItem("About matbury.com...");
			_cm.customItems.push(matbury);
			matbury.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, matburyHandler);
			// Version
			var version:ContextMenuItem = new ContextMenuItem("Version: " + _version);
			_cm.customItems.push(version);
		}
		
		private function matburyHandler(event:ContextMenuEvent):void {
			var url:String = "http://matbury.com/";
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request,"_blank");
		}
	}
}
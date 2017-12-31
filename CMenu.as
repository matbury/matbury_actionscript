/*
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
﻿/*
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
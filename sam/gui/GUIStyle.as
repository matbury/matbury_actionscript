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
﻿/**
 * @copyright: GUIStyle class by Matt Bury (C)2010
 * @email: matbury@gmail.com
 * @website: http://matbury.com/
 * @description: Draws a hand-drawn cross symbol
 * @package: com.matbury.sam.gui
 * @constructor: static class
 * @methods:
 * @var GUIStyle.arrowWidth Number
 * @var GUIStyle.arrowHeight Number
 * @var GUIStyle.bottomColor int
 * @var GUIStyle.defaultBgWidth Number
 * @var GUIStyle.defaultBgHeight Number
 * @var GUIStyle.font String
 * @var GUIStyle.heading1 int
 * @var GUIStyle.heading2 int
 * @var GUIStyle.fontSize int
 * @var GUIStyle.iconColor int
 * @var GUIStyle.pointerSpeed Number
 * @var GUIStyle.roundedCornerWidth Number
 * @var GUIStyle.roundedCornerHeight Number
 * @var GUIStyle.topColor int
**/
package com.matbury.sam.gui {
	
	public class GUIStyle {
		
		private static var _arrowWidth:Number = 20;
		private static var _arrowHeight:Number = 30;
		private static var _bottomColor:int = 0x000011;
		private static var _defaultBgWidth:Number = 26;
		private static var _defaultBgHeight:Number = 26;
		private static var _font:String = "Trebuchet MS";
		private static var _heading1:int = 30;
		private static var _heading2:int = 20;
		private static var _fontSize:int = 16;
		private static var _iconColor:int = 0xffffff;
		private static var _pointerSpeed:Number = 0.2;
		private static var _roundedCornerWidth:Number = 5;
		private static var _roundedCornerHeight:Number = 5;
		private static var _topColor:int = 0x0000ff;
		
		// ------------------------------------------------------------------------------- arrow width
		public static function set arrowWidth(val:Number):void {
			_arrowWidth = val;
		}
		
		public static function get arrowWidth():Number {
			return _arrowWidth;
		}
		
		// ------------------------------------------------------------------------------- arrow height
		public static function set arrowHeight(val:Number):void {
			_arrowHeight = val;
		}
		
		public static function get arrowHeight():Number {
			return _arrowHeight;
		}
		
		// ------------------------------------------------------------------------------- bottom color
		public static function set bottomColor(val:int):void {
			_bottomColor = val;
		}
		
		public static function get bottomColor():int {
			return _bottomColor;
		}
		
		// ------------------------------------------------------------------------------- default Bg width
		public static function set defaultBgWidth(val:Number):void {
			_defaultBgWidth = val;
		}
		
		public static function get defaultBgWidth():Number {
			return _defaultBgWidth;
		}
		
		// ------------------------------------------------------------------------------- default Bg height
		public static function set defaultBgHeight(val:Number):void {
			_defaultBgHeight = val;
		}
		
		public static function get defaultBgHeight():Number {
			return _defaultBgHeight;
		}
		
		// ------------------------------------------------------------------------------- font
		public static function set font(val:String):void {
			_font = val;
		}
		
		public static function get font():String {
			return _font;
		}
		
		// ------------------------------------------------------------------------------- _heading1
		public static function set heading1(val:int):void {
			_heading1 = val;
		}
		
		public static function get heading1():int {
			return _heading1;
		}
		
		// ------------------------------------------------------------------------------- _heading2_fontSize
		public static function set heading2(val:int):void {
			_heading2 = val;
		}
		
		public static function get heading2():int {
			return _heading2;
		}
		
		// ------------------------------------------------------------------------------- _fontSize
		public static function set fontSize(val:int):void {
			_fontSize = val;
		}
		
		public static function get fontSize():int {
			return _fontSize;
		}
		
		// ------------------------------------------------------------------------------- icon color
		public static function set iconColor(val:int):void {
			_iconColor = val;
		}
		
		public static function get iconColor():int {
			return _iconColor;
		}
		
		// ------------------------------------------------------------------------------- pointer speed
		public static function set pointerSpeed(val:Number):void {
			_pointerSpeed = val;
		}
		
		public static function get pointerSpeed():Number {
			return _pointerSpeed;
		}
		
		// ------------------------------------------------------------------------------- rounded corner width
		public static function set roundedCornerWidth(val:Number):void {
			_roundedCornerWidth = val;
		}
		
		public static function get roundedCornerWidth():Number {
			return _roundedCornerWidth;
		}
		
		// ------------------------------------------------------------------------------- rounded corner height
		public static function set roundedCornerHeight(val:Number):void {
			_roundedCornerHeight = val;
		}
		
		public static function get roundedCornerHeight():Number {
			return _roundedCornerHeight;
		}
		
		// ------------------------------------------------------------------------------- top color
		public static function set topColor(val:int):void {
			_topColor = val;
		}
		
		public static function get topColor():int {
			return _topColor;
		}
	}
}
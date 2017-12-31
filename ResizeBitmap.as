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
﻿package com.matbury {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	public class ResizeBitmap extends Sprite {
		
		private var _bitmap:Bitmap;
		private var _bitmapdata:BitmapData;
		
		public function ResizeBitmap(bitmapData:BitmapData, w:Number = 35, h:Number = 35, percent:Boolean = true) {
			if(percent) {
				scaleBitmap(bitmapData,w,h);
			} else {
				resizeBitmap(bitmapData,w,h);
			}
		}
		
		private function scaleBitmap(bitmapData:BitmapData, w:Number, h:Number):void {
			var scaleW:Number = w / 100;
			var scaleH:Number = h / 100;
			var matrix:Matrix = new Matrix();
			matrix.scale(scaleW, scaleH);
			_bitmapdata = new BitmapData(bitmapData.width * scaleW, bitmapData.height * scaleH, false, 0xFFFFFF);
			_bitmapdata.draw(bitmapData, matrix, null, null, null, true);
			_bitmap = new Bitmap(_bitmapdata);
		}
		
		private function resizeBitmap(bitmapData:BitmapData, w:Number, h:Number):void {
			var wPercent:Number = w / bitmapData.width;
			var hPercent:Number = w / bitmapData.height;
			var matrix:Matrix = new Matrix();
			matrix.scale(wPercent, hPercent);
			_bitmapdata = new BitmapData(w, h, false, 0xFFFFFF);
			_bitmapdata.draw(bitmapData, matrix, null, null, null, true);
			_bitmap = new Bitmap(_bitmapdata);
		}
		
		public function get bitmap():Bitmap {
			return _bitmap;
		}
		
		public function get bitmapdata():BitmapData {
			return _bitmapdata;
		}
	}
}
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
RandomIndex class by Matt Bury 2007
matbury@yahoo.co.uk

Creates an array of random numbers (indicies) of a specified length from a specified total number.

var ri:RandomIndex = new RandomIndex(selection:uint,maxNumber:uint);
myArray = ri._rnd;

*/
package com.matbury {
	
	public class RandomIndex {
		
		public var _rnd:Array;
		private var _length:uint;
		private var _total:uint;
		
		public function RandomIndex(arrayLength:uint,maxNumber:uint){
			_length = arrayLength;
			_total = maxNumber;
			_rnd = new Array();
			selectIndexes();
		}
		
		public function selectIndexes():Array {
			var match:Boolean = false;
			while(_rnd.length < _length){
				var rnd:uint = Math.floor(Math.random() * _total);
				match = false;
				// check if the number is already in the array
				var lenth:uint = _rnd.length;
				for(var i:uint = 0; i < lenth; i ++){
					var obj:uint = _rnd[i];
					if(rnd == obj){
						match = true;
						break;
					}
				}
				// if not, push it in
				if(match == false){
					_rnd.push(rnd);
				}
			}
			return _rnd;
		}
	}
}
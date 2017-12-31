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
ShuffledIndex.as class by Matt Bury 2008
matbury@yahoo.co.uk

This class provides an easy way to effectively 'shuffle the index' of any array
while leaving order of the array itself intact. 

Example:
import com.matbury.ShuffledIndex;

// Calculate length of array
var _length:uint = myArray.length;

// Pass length of array into constructor
var si:ShuffledIndex = new ShuffledIndex(lenth);

// Trace the shuffled array
function showShuffle():void {
	for(var i:uint = 0; i < myArray.length; i++) {
		var index:uint = si.ind[i];
		trace(myArray[index]);
	}
}

*/

package com.matbury {
	
	public class ShuffledIndex {
		
		private var _len:uint;
		private var _nums:Array;
		public var ind:Array;
		
		public function ShuffledIndex(len:uint,shuffled:Boolean = true) {
			_len = len;
			initArray();
			if(shuffled) {
				shuffle(); // return shuffled indices
			} else {
				ind = _nums; // return serial indices, i.e. 0,1,2,3,etc.
			}
		}
		
		private function initArray():void {
			_nums = new Array();
			for(var i:uint = 0; i < _len; i++) {
				_nums.push(i);
			}
		}
		
		public function shuffle():void {
			var r:uint;
			ind = new Array();
			while(_nums.length > 0) {
				r = Math.floor(Math.random() * _nums.length);
				ind.push(_nums[r]);
				_nums.splice(r,1);
			}
		}
	}
}
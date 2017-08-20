/*
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
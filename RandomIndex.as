/*
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
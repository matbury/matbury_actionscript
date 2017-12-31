﻿/*
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
CompareStrings class by Matt Bury 2007
matbury@yahoo.co.uk

Example FLA code:

// 'input' is an input TextField
// 'original' is a string to test against

var original:String = "abcdef";

var cs:CompareStrings = new CompareStrings();
var answer:Array = new Array(0x000000,0,1); // values returned by reference
var format:TextFormat = new TextFormat(); // set colour changes from answer array

input.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
input.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);

function keyDownHandler(event:KeyboardEvent):void {
	if(fText.caretIndex > 0){
		cs.checkIt(fText.text,currentWord,fText.caretIndex);
		colour.color = cs.answer[0];
		fText.setTextFormat(colour,cs.answer[1],cs.answer[2]);
	}
}
	
function keyUpHandler(event:KeyboardEvent):void {
	if(fText.caretIndex > 1){
		if(cs.answer[0] == 0x000000){
			currentBlank._blank.setTextFormat(black);
			currentBlank.finished = true;
			gotoNextWord();
		}
	}
}
*/

package com.matbury {
	
	public class CompareStrings {
		
		public var answer:Array;
		
		public function CompareStrings() {
			answer = new Array(0x000000,0,0);
		}
		
		public function checkIt(_a:String,_b:String,caret:int):Array {
			// compare whole strings
			if(_a == _b){
					answer[0] = 0x000000; //correct= if(answer[0] == 0x000000){}
					answer[1] = 0; // begin
					answer[2] = _a.length; // end
				}else{
			
			// compare same lengths
			if(_a == _b.substr(0,_a.length)){
					answer[0] = 0x009900; // green
					answer[1] = 0; // begin
					answer[2] = _a.length; // end
				}else{
			
			// compare last typed character
			if(_a.charAt(caret - 1) == _b.charAt(caret - 1)){
					answer[0] = 0x009900; // green
					answer[1] = caret - 1; // begin
					answer[2] = caret; // end
				}else{
			
			// look for existence of last typed character
			if(_b.indexOf(_a.charAt(caret - 1)) != -1){
					answer[0] = 0xFF9900; // amber
					answer[1] = caret - 1; // begin
					answer[2] = caret; // end
				}else{
			
			// the last typed character doesn't match anything
					answer[0] = 0xDD0000; // red
					answer[1] = caret - 1; // begin
					answer[2] = caret; // end
				}
				}
				}
			}
			return answer;
		}
	}
}
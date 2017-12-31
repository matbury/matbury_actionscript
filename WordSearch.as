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
WordSearch custom class by Matt Bury
matbury@gmail.com

Requires the following in FLA library:
- Poster Sprite.

Example code:

var array:Array = new Array(); // array of words/phrases less than 22 characters
var arrayCopy:Array = array.slice();
var ws:WordSearch = new WordSearch(array);
addChild(ws);

*/
package com.matbury {
	import flash.display.*;
	import flash.text.*;
	import flash.geom.Point;
	import flash.events.*;
	
	public class WordSearch extends Sprite {
		
		private var _puzzleSize:uint;
		private var _spacing:Number;
		private var _outineSize:Number;
		private var _offset:Point;
		private var _f:TextFormat;
		//constants
		public static const FINISHED:String = "finished";
		public static const WORD_FOUND:String = "word";
		// words and _grid
		private var _newWords:Array;
		private var _rndWords:Array;
		private var _wordList:Array;
		private var _usedWords:Array;
		private var _grid:Array;
		// game state
		private var _dragMode:Boolean;
		private var _startPoint:Point;
		private var _endPoint:Point;
		private var _numFound:int;
		// sprites
		private var _gameSprite:Sprite;
		private var _outlineSprite:Sprite;
		private var _oldOutlineSprite:Sprite;
		private var _letterSprites:Sprite;
		private var _wordsSprite:Sprite;
		//
		private var _letters:Array;
		private var _foundWords:Array;
		
		public function WordSearch(loadedWords:Array, size:uint = 20) {
			_puzzleSize = size;
			_spacing = 22;
			_outineSize = 26;
			_offset = new Point(15,15);
			_foundWords = new Array();
			_newWords = loadedWords;
		}
		
		public function startWordSearch():void {
			// word list
			_rndWords = new Array();
			var len:uint = _newWords.length;
			for(var w:uint = 0; w < len; w++){
				var rnd:uint = Math.floor(Math.random() * _newWords.length);
				_rndWords.push(_newWords[rnd]);
				_newWords.splice(rnd,1);
			}
			_wordList = _rndWords;
			// set up sprites
			_gameSprite = new Sprite();
			addChild(_gameSprite);
			_oldOutlineSprite = new Sprite();
			_gameSprite.addChild(_oldOutlineSprite);
			_outlineSprite = new Sprite();
			_gameSprite.addChild(_outlineSprite);
			_letterSprites = new Sprite();
			_gameSprite.addChild(_letterSprites);
			_wordsSprite = new Sprite();
			_gameSprite.addChild(_wordsSprite);
			// array of _letters
			var _letters:Array = placeLetters();
			// array of sprites
			_grid = new Array();
			// create format object
			_f = new TextFormat("Trebuchet MS",20,0x000000,true,false,false,null,null,TextFormatAlign.CENTER);
			// create grid of letters
			for(var x:int = 0; x < _puzzleSize; x++){
				_grid[x] = new Array();
				for(var y:int = 0; y < _puzzleSize; y++){
					// create new letter field and sprite
					var newLetter:TextField = new TextField();
					newLetter.antiAliasType = AntiAliasType.ADVANCED;
					newLetter.defaultTextFormat = _f;
					newLetter.embedFonts = true;
					newLetter.x = x * _spacing + _offset.x;
					newLetter.y = y * _spacing + _offset.y;
					newLetter.width = _spacing;
					newLetter.height = _spacing * 1.3;
					newLetter.text = _letters[x][y];
					newLetter.selectable = false;
					newLetter.background = false;
					var newLetterSprite = new Sprite();
					newLetterSprite.addChild(newLetter);
					_letterSprites.addChild(newLetterSprite);
					_grid[x][y] = newLetterSprite;
					// add event listeners
					newLetterSprite.addEventListener(MouseEvent.MOUSE_DOWN, clickLetter);
					newLetterSprite.addEventListener(MouseEvent.MOUSE_OVER, overLetter);
				}
			}
			// stage listener
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseRelease);
			// create word list fields and sprites
			len = _usedWords.length;
			var newWordWidth:int = 0;
			for(var i:int = 0; i < len; i++){
				var newWord:TextField = new TextField();
				newWord.autoSize = TextFieldAutoSize.CENTER;
				newWord.defaultTextFormat = _f;
				newWord.embedFonts = true;
				newWord.y = (i * _spacing + _offset.y) + 20;
				newWord.height = _spacing * 1.3;
				newWord.text = _usedWords[i];
				newWord.selectable = false;
				_wordsSprite.addChild(newWord);
				// Find the widest newWord
				if(newWordWidth < newWord.width) {
					newWordWidth = newWord.width;
				}
			}
			_wordsSprite.x = newLetter.x + (newWordWidth * 0.55);
			// set game state
			_dragMode = false;
			_numFound = 0;
		}
		
		// Return the number of placed words
		public function get words():uint {
			return _usedWords.length;
		}
		
		// place the words in a _grid of _letters
		private function placeLetters():Array {
			// create empty _grid
			var _letters:Array = new Array();
			for(var xi:int = 0; xi < _puzzleSize; xi++){
				_letters[xi] = new Array();
				for(var yi:int = 0; yi < _puzzleSize; yi++){
					_letters[xi][yi] = "*";
				}
			}
			// make copy of word list
			var _wordListCopy:Array = _wordList.concat();
			_usedWords = new Array();
			// make 2000 attempts to add words
			var repeatTimes:int = 2000;
			repeatLoop:while (_wordListCopy.length > 0){
				if(repeatTimes-- <= 0) break;
				// pick a random word, location and direction
				var wordNum:int = Math.floor(Math.random() * _wordListCopy.length);
				var word:String = _wordListCopy[wordNum].toLowerCase();
				var x:uint = Math.floor(Math.random() * _puzzleSize);
				var y:uint = Math.floor(Math.random() * _puzzleSize);
				var dx:int = Math.floor(Math.random() * 2);
				var dy:int = Math.floor(Math.random() * 2);
				if((dx == 0) && (dy == 0)) continue repeatLoop;
				// check each spot in _grid to see if word fits
				letterLoop:for (var j:int = 0; j < word.length; j++){
					if((x + dx * j < 0) || (y + dy *j < 0) || (x + dx * j >= _puzzleSize) || (y + dy * j >= _puzzleSize)) continue repeatLoop;
					var thisLetter:String = _letters[x + dx * j][y + dy * j];
					if ((thisLetter != "*") && (thisLetter != word.charAt(j))) continue repeatLoop;
				}
				// insert word into _grid
				insertLoop:for (j = 0; j < word.length; j++){
					_letters[x + dx * j][y + dy * j] = word.charAt(j);
				}
				// remove word from list
				_wordListCopy.splice(wordNum,1);
				_usedWords.push(word);
			}
			// fill rest of _grid with random _letters
			for(x = 0; x < _puzzleSize; x++){
				for(y = 0; y < _puzzleSize; y++){
					if(_letters[x][y] == "*"){
						_letters[x][y] = String.fromCharCode(97 + Math.floor(Math.random() * 26));
					}
				}
			}
			return _letters;
		}
		
		// player clicks down on a letter to start
		private function clickLetter(event:MouseEvent):void {
			var letter:String = event.currentTarget.getChildAt(0).text;
			_startPoint = findGridPoint(event.currentTarget);
			_dragMode = true;
		}
		
		// player dragging over _letters
		private function overLetter(event:MouseEvent):void {
			if(_dragMode == true){
				_endPoint = findGridPoint(event.currentTarget);
				// if valid range, show outline
				_outlineSprite.graphics.clear();
				if(isValidRange(_startPoint,_endPoint)){
					drawOutline(_outlineSprite,_startPoint,_endPoint,0xFF0000);
				}
			}
		}
		
		// mouse released
		private function mouseRelease(event:MouseEvent):void {
			if(_dragMode == true){
				_dragMode = false;
				_outlineSprite.graphics.clear();
				// get word and check it
				if(isValidRange(_startPoint,_endPoint)){
					var word = getSelectedWord();
					checkWord(word);
				}
			}
		}
		
		// when a letter is clicked, find and return the x and y location
		private function findGridPoint(letterSprite:Object):Point{
			//loop through all sprites and find this one
			for (var x:int = 0; x < _puzzleSize; x++){
				for(var y:int = 0; y < _puzzleSize; y++){
					if(_grid[x][y] == letterSprite){
						return new Point(x,y);
					}
				}
			}
			return null;
		}
		
		// determine if range is in the same row, column or 45 degree diagonal
		private function isValidRange(p1,p2:Point):Boolean{
			if(p1.x == p2.x) {
				return true;
			}
			if(p1.y == p2.y) {
				return true;
			}
			if(Math.abs(p2.x - p1.x) == Math.abs(p2.y - p1.y)) {
				return true;
			}
			return false;
		}
		
		// draw a thick line from one location to another
		private function drawOutline(s:Sprite,p1,p2:Point,c:Number):void {
			var off:Point = new Point(_offset.x + _spacing / 2, _offset.y + _spacing / 2);
			s.graphics.lineStyle(_outineSize,c);
			s.graphics.moveTo(p1.x * _spacing + off.x, p1.y * _spacing + off.y + 5);
			s.graphics.lineTo(p2.x * _spacing + off.x, p2.y * _spacing + off.y + 5);
		}
		
		// find selected _letters based on start and end points
		private function getSelectedWord():String {
			// determine dx and dy of selection, and word length
			var dx = _endPoint.x - _startPoint.x;
			var dy = _endPoint.y - _startPoint.y;
			var wordLength:Number = Math.max(Math.abs(dx),Math.abs(dy)) + 1;
			// get each character of selection
			var word:String = "";
			for(var i:int = 0; i < wordLength; i++) {
				var x = _startPoint.x;
				if (dx < 0) x -= i;
				if (dx > 0) x += i;
				var y = _startPoint.y;
				if (dy < 0) y -= i;
				if (dy > 0) y += i;
				word += _grid[x][y].getChildAt(0).text;
			}
			return word;
		}
		
		// check word against word list
		private function checkWord(word:String):void {
			// loop through words
			for(var i:int = 0; i < _usedWords.length; i++) {
				// compare word
				if (word == _usedWords[i].toLowerCase()) {
					foundWord(word);
					_foundWords.push(word);
				}
				// compare word reversed
				var reverseWord:String = word.split("").reverse().join("");
				if (reverseWord == _usedWords[i].toLowerCase()) {
					foundWord(reverseWord);
					_foundWords.push(reverseWord);
				}
			}
		}
		
		// word found, remove from list, make outline permanent
		private function foundWord(word:String):void {
			var alreadyFound:Boolean = checkPreFoundWords(word);
			if(!alreadyFound) {
				// draw outline in permanent sprite
				drawOutline(_oldOutlineSprite,_startPoint,_endPoint,0xFF9999);
				// find text field and set it to gray
				var len:uint = _wordsSprite.numChildren;
				for(var i:int = 0; i < len; i++) {
					if (TextField(_wordsSprite.getChildAt(i)).text.toLowerCase() == word) {
						TextField(_wordsSprite.getChildAt(i)).textColor = 0xCCCCCC;
					}
				}
				// tell doc class to increment score by 1 
				dispatchEvent(new Event(WORD_FOUND));
				// see if all have been found
				_numFound++;
				if (_numFound == _usedWords.length) {
					dispatchEvent(new Event(FINISHED));
				}
			}
		}
		
		// check that word hasn't already been found
		private function checkPreFoundWords(word:String):Boolean {
			var len:uint = _foundWords.length;
			for(var i:uint = 0; i < len; i++) {
				if(word == _foundWords[i]) {
					return true;
				}
			}
			return false;
		}
	}
}
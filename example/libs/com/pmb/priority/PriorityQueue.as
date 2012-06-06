package com.pmb.priority {
	public class PriorityQueue {
		public static const MAX_HEAP:uint = 0;
		public static const MIN_HEAP:uint = 1;
		private var _queue:Array;
		private var _criteria:String;
		private var _isMax:Boolean;
		private var _length:uint = 0;
		/**
		 * This is an improved Priority Queue data type implementation that can be used to sort any object type.
		 * It uses a technique called a binary heap for max sorts, and array.sortOn for min sorts.
		 * 
		 * For more information on why this priorityQueue works this way.. see the tests!
		 * Array.sortOn is faster for min sorts, but a normal binary heap is faster for max sorts.
		 * This is probably due to whatever sorting algorithm is doing under the covers of array.sortOn. (It's closed source -- so theres no way for us to know!)
		 * 
		 * For more on binary heaps see: http://en.wikipedia.org/wiki/Binary_heap
		 * 
		 * @param criteria The criteria by which to sort the objects. This should be a property of the objects you're sorting.
		 * @param heapType either PriorityQueue.MAX_HEAP or PriorityQueue.MIN_HEAP.
		 **/
		public function PriorityQueue(criteria:String,heapType:uint) {
			if (heapType==MAX_HEAP) {
				_isMax = true;
			} else if (heapType==MIN_HEAP) {
				_isMax = false;
			} else {
				throw new Error(heapType + " not supported."); 
			}
			_criteria = criteria;
			_queue = new Array();
		}
		/**
		 * Inserts the value into the heap and sorts it.
		 * 
		 * @param value The object to insert into the heap.
		 **/
		public function insert(value:*):void {
			if (!value.hasOwnProperty(_criteria)) {
				throw new Error("Cannot insert " + value + " because it does not have a property by the name of " + _criteria + ".");
			}
			_length = _queue.push(value);
			bubbleUp(_length-1);
		}
		/**
		 * Returns the length of the heap.
		 * @return the length of the heap
		 **/
		public function get length():uint {
			return _length;
		}
		/**
		 * Peeks at the highest priority element.
		 * @return the highest priority element
		 **/
		public function getHighestPriorityElement():* {
			return _queue[0];
		}
		/**
		 * Removes and returns the highest priority element from the queue.
		 * @return the highest priority element
		 **/
		public function shiftHighestPriorityElement():* {
			if (_length < 0) {
				throw new Error("There are no more elements in your priority queue.");
			}
			var oldRoot:* = _queue[0];
			var newRoot:* = _queue.pop();
			_length--;
			_queue[0] = newRoot;
			swapUntilQueueIsCorrect(0);
			return oldRoot;
		}
		private function bubbleUp(index:uint):void {
			if (index==0) {
				return;
			}
			
			var parent:uint = getParentOf(index);
			if (evaluate(index,parent)) {
				swap(index,parent);
				bubbleUp(parent);
			} else {
				return;
			}
		}
		private function swapUntilQueueIsCorrect(value:uint):void {
			var left:uint = getLeftOf(value);
			var right:uint = getRightOf(value);
			
			if (evaluate(left,value)) {
				swap(value,left);
				swapUntilQueueIsCorrect(left);
			} else if (evaluate(right,value)) {
				swap(value,right);
				swapUntilQueueIsCorrect(right);
			} else if (value==0) {
				return;
			} else {
				swapUntilQueueIsCorrect(0);
			}
		}
		
		private function swap(self:uint,target:uint):void {
			var placeHolder:* = _queue[self];
			_queue[self] = _queue[target];
			_queue[target] = placeHolder;
		}
		
		/**
		 * Helpers
		 */
		private function evaluate(self:uint,target:uint):Boolean {
			if (_queue[target]==null||_queue[self]==null) {
				return false;
			}
			if (_isMax) {
				if (_queue[self][_criteria] > _queue[target][_criteria]) {
					return true;
				} else {
					return false;
				}
			} else {
				if (_queue[self][_criteria] < _queue[target][_criteria]) {
					return true;
				} else {
					return false;
				}
			}
		}
		private function getParentOf(index:uint):uint {
			return (index-1) >> 1;	
		}
		private function getLeftOf(index:uint):uint {
			return (index << 1) + 1;
		}
		private function getRightOf(index:uint):uint {
			return (index << 1) + 2;
		}
	}
}
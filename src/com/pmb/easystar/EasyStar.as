package com.pmb.easystar
{
	import com.pmb.easystar.events.PathFoundEvent;
	import com.pmb.easystar.events.PathNotFoundEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/*
	EasyStarAS3
	Code By (@prettymuchbryce: brycedneal@gmail.com)
	Code is blessed under the MIT License.
	Based on Patrick Lester's "A* Pathfinder for Beginners": http://www.policyalmanac.org/games/aStarTutorial.htm
	
	_grid is a Vector of Vector<uint>'s containing 0 for walkable and 1 for unwalkable.
	*/
	public class EasyStar extends EventDispatcher
	{
		protected const _straightCost:uint = 10;
		protected const _diagonalCost:uint = 14; //As of now there is no diagonal support
		
		protected var _collisionGrid:Vector.<Vector.<uint>>;
		protected var _openList:Vector.<Node>;
		protected var _nodeDictionary:Dictionary;
		
		protected var _calculationsThisFrame:uint;
		protected var _calculationsPerFrame:uint;
		protected var _startCoordinateX:uint;
		protected var _startCoordinateY:uint
		protected var _endCoordinateX:uint;
		protected var _endCoordinateY:uint;
		protected var _pathFound:Boolean;
		protected var _openListLen:uint;
		public function EasyStar(){_pathFound = true;}
		public function setCollisionGrid(value:Vector.<Vector.<uint>>):void {
			_collisionGrid = value;
		}
		public function calculatePath(startCoordinate:Point,endCoordinate:Point,calculationsPerFrame:uint = 200):void {
			if (!_collisionGrid) throw new Error("Can't caculate a path without a grid. Use setGrid first.");

			_openListLen = 0;
			_startCoordinateX = startCoordinate.x;
			_startCoordinateY = startCoordinate.y;
			_endCoordinateX = endCoordinate.x;
			_endCoordinateY = endCoordinate.y;
			
			if (_startCoordinateX<0||_startCoordinateY<0||_endCoordinateX<0||_endCoordinateY<0||_startCoordinateX>_collisionGrid[0].length-1||_startCoordinateY>_collisionGrid.length-1||_endCoordinateX>_collisionGrid[0].length-1||_endCoordinateY>_collisionGrid.length-1) {
				throw new Error("Your start or end point is outside the scope of your grid.");
				return;
			} else if (_startCoordinateX==_endCoordinateX&&_startCoordinateY==_endCoordinateY) {
				throw new Error("Your start and end point are the same. You should really be catching this before you send a calculatePath to EasyStar.");
				return;
			}
			if (_collisionGrid[_endCoordinateY][_endCoordinateX]>=1) {
				dispatchEvent(new PathNotFoundEvent());
				return;
			}
			_nodeDictionary = new Dictionary();
			_openList = new Vector.<Node>();
			_pathFound = false;
			
			_calculationsPerFrame = calculationsPerFrame;
			addToOpenList(coordinateToNode(_startCoordinateX,_startCoordinateY,null));
		}
		public function addToOpenList(n:Node):void {
			_openListLen++;
			_openList[_openListLen-1] = n;
		}
		public function calculate():void {
			if (!_collisionGrid||_pathFound) return;
			_calculationsThisFrame = 0;
			while ( _calculationsThisFrame < _calculationsPerFrame && _pathFound==false) {
				var searchNode:Node;
				var searchNodei:uint;
				for (var i:int = 0; i < _openListLen; i++) {
					if (i==0) {
						searchNode = _openList[i];
						searchNodei = i;
					} else {
						if (_openList[i].F<searchNode.F) {
							searchNode = _openList[i];
							searchNodei = i;
						}
					}
				}
				
				if (_openListLen==0) {
					dispatchEvent(new PathNotFoundEvent());
					_pathFound = true;
					return;
				}
			
				if (searchNode.coordinateY > 0) {
					checkAdjacentNode(searchNode,0,-1);
					if (_pathFound) return;
				}
				if (searchNode.coordinateX < _collisionGrid[0].length-1) {
					checkAdjacentNode(searchNode,+1,0);
					if (_pathFound) return;
				}
				if (searchNode.coordinateY < _collisionGrid.length-1) {
					checkAdjacentNode(searchNode,0,+1);
					if (_pathFound) return;
				}
				if (searchNode.coordinateX > 0) {
					checkAdjacentNode(searchNode,-1,0);
					if (_pathFound) return;
				}
			
				searchNode.list = searchNode.CLOSED_LIST;
				_openList[searchNodei] = _openList[_openListLen-1];
				_openListLen--;
				_calculationsThisFrame++;
			}
		}
		protected function checkAdjacentNode(searchNode:Node,x:int,y:int):void {
			var adjacentCoordinateX:uint = searchNode.coordinateX+x;
			var adjacentCoordinateY:uint = searchNode.coordinateY+y;
			if (_endCoordinateX==adjacentCoordinateX&&_endCoordinateY==adjacentCoordinateY) {
				_pathFound = true;
				var path:Vector.<Point> = new Vector.<Point>();
				var pathLen:uint = 0;
				path[pathLen] = new Point(adjacentCoordinateX,adjacentCoordinateY);
				pathLen++;
				path[pathLen] = new Point(searchNode.coordinateX,searchNode.coordinateY);
				pathLen++;
				var parent:Node = searchNode.parent;
				while (parent!=null) {
					path[pathLen] = new Point(parent.coordinateX,parent.coordinateY);
					pathLen++;
					parent = parent.parent;
				}
				path.reverse();
				dispatchEvent(new PathFoundEvent(path));
				return;
			}
			if (_collisionGrid[adjacentCoordinateY][adjacentCoordinateX]==0) {
				var adjacentNode:Node = coordinateToNode(adjacentCoordinateX,adjacentCoordinateY,searchNode);
				if (!adjacentNode.list) {
					adjacentNode.list = adjacentNode.OPEN_LIST;
					addToOpenList(adjacentNode);
				} else if (adjacentNode.list==adjacentNode.OPEN_LIST) {
					if (searchNode.G+_straightCost<adjacentNode.G) {
						adjacentNode.G = searchNode.G+_straightCost;
						adjacentNode.parent = searchNode;
					}
				}
			}
		}
		protected function coordinateToNode(coordinateX:uint,coordinateY:uint,parent:Node):Node {
			if (_nodeDictionary[coordinateX+"_"+coordinateY]) return _nodeDictionary[coordinateX+"_"+coordinateY];
			
			var H:uint = getSimpleDistance(coordinateX,coordinateY,_endCoordinateX,_endCoordinateY);
			if (parent) var G:uint = parent.G+_straightCost; else G=H;
			
			var node:Node = new Node(parent,coordinateX,coordinateY,G,H);
			_nodeDictionary[coordinateX+"_"+coordinateY] = node;
			return node;
		}
		protected function getSimpleDistance(coordinateAX:uint,coordinateAY:uint,coordinateBX:uint,coordinateBY:uint):uint {
			return Math.abs(coordinateAX - coordinateBX)*_straightCost + Math.abs(coordinateAY - coordinateBY)*_straightCost;
		}
	}
}
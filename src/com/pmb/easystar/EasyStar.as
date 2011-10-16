package com.pmb.easystar
{
	import com.pmb.easystar.events.PathFoundEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import com.pmb.easystar.events.PathNotFoundEvent;

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
		public function EasyStar(){_pathFound = true;}
		public function setCollisionGrid(value:Vector.<Vector.<uint>>):void {
			_collisionGrid = value;
		}
		public function calculatePath(startCoordinate:Point,endCoordinate:Point,calculationsPerFrame:uint = 200):void {
			if (!_collisionGrid) throw new Error("Can't caculate a path without a grid. Use setGrid first.");

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
			_openList = new Vector.<Node>;
			_pathFound = false;
			
			_calculationsPerFrame = calculationsPerFrame;
			_openList.push(coordinateToNode(_startCoordinateX,_startCoordinateY,null));
		}
		public function calculate():void {
			if (!_collisionGrid||_pathFound) return;
			_calculationsThisFrame = 0;
			while ( _calculationsThisFrame < _calculationsPerFrame && _pathFound==false) {
				//get next node in open list
				_openList.sort(sortListByF);
				
				if (_openList.length==0) {
					dispatchEvent(new PathNotFoundEvent());
					_pathFound = true;
					return;
				}
				var searchNode:Node = _openList[0];
			
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
				_openList.shift();
				_calculationsThisFrame++;
			}
		}
		
		private function sortListByF(x:Node,y:Node):Number
		{
			if (x.F<y.F) return -1;
			else if (x.F==y.F) return 0;
			return 1;
		}
		protected function checkAdjacentNode(searchNode:Node,x:int,y:int):void {
			//var adjacentCoordinate:Point = new Point(searchNode.coordinateX+x,searchNode.coordinateY+y);
			var adjacentCoordinateX:uint = searchNode.coordinateX+x;
			var adjacentCoordinateY:uint = searchNode.coordinateY+y;
			if (_endCoordinateX==adjacentCoordinateX&&_endCoordinateY==adjacentCoordinateY) {
			
				_pathFound = true;
				var path:Vector.<Point> = new Vector.<Point>();
				path.push(new Point(adjacentCoordinateX,adjacentCoordinateY));
				path.push(new Point(searchNode.coordinateX,searchNode.coordinateY));
				var parent:Node = searchNode.parent;
				while (parent!=null) {
					path.push(new Point(parent.coordinateX,parent.coordinateY));
					parent = parent.parent;
				}
				path.reverse();
				dispatchEvent(new PathFoundEvent(path));
				return;
			}
			if (_collisionGrid[adjacentCoordinateY][adjacentCoordinateX]==0) {
				var node:Node = coordinateToNode(adjacentCoordinateX,adjacentCoordinateY,searchNode);
				if (!node.list) {
					node.list = node.OPEN_LIST;
					_openList.push(node);
				} else if (node.list==node.OPEN_LIST) {
					if (searchNode.G+_straightCost<node.G) {
						node.G = searchNode.G+_straightCost;
						node.parent = searchNode;
					}
				}
			}
		}
		protected function coordinateToNode(coordinateX:uint,coordinateY:uint,parent:Node):Node {
			//Lets first check to see if we already have this coordinate saved as a node in our dictionary.
			if (_nodeDictionary[coordinateX+"_"+coordinateY]) return _nodeDictionary[coordinateX+"_"+coordinateY];
			
			var G:uint = getSimpleDistance(coordinateX,coordinateY,_endCoordinateX,_endCoordinateY);
			if (parent) var H:uint = parent.H+_straightCost; else H=G;
			
			var node:Node = new Node(parent,coordinateX,coordinateY,G,H);
			_nodeDictionary[coordinateX+"_"+coordinateY] = node;
			return node;
		}
		protected function getSimpleDistance(coordinateAX:uint,coordinateAY:uint,coordinateBX:uint,coordinateBY:uint):uint {
			return Math.abs(coordinateAX - coordinateBX)*_straightCost + Math.abs(coordinateAY - coordinateBY)*_straightCost;
		}
	}
}
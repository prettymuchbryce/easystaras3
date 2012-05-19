package com.pmb.easystar {
	import com.pmb.easystar.events.PathFoundEvent;
	import com.pmb.easystar.events.PathNotFoundEvent;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * EasyStarAS3
	 * github.com/prettymuchbryce/EasyStarAS3
	 * Blessed under the MIT License. 
	 * 
	 * 
	 * Code By Bryce Neal
	 * hi@prettymuchbryce.com
	 * Based on Patrick Lester's "A* Pathfinding for beginners" http://www.policyalmanac.org/games/aStarTutorial.htm
	 **/
	public class EasyStar extends EventDispatcher {
		private static const STRAIGHT_COST:uint = 10;
		private static const DIAGONAL_COST:uint = 14; //As of now there is no diagonal support -- but this would roughly be the cost of a diagonal move
		
		private var _collisionGrid:Vector.<Vector.<uint>>;
		private var _openList:Vector.<Node>;
		private var _nodeDictionary:Dictionary;
		
		private var _calculationsThisFrame:uint;
		private var _iterationsPerCalculation:uint;
		private var _startCoordinateX:uint;
		private var _startCoordinateY:uint
		private var _endCoordinateX:uint;
		private var _endCoordinateY:uint;
		private var _isDoneCalculating:Boolean;
		private var _openListLen:uint;
		private var _acceptableTiles:Vector.<uint>;
		private var _pointsToAvoid:Dictionary;
		
		/**
		 * @param acceptableTiles A vector of tiles that easyStar will deem as acceptable moves.
		 * @param iterationsPerCalculation the number of iterations that easy star to will perform per calculate() call
		 * @param pointsToAvoid This is an optional parameter. In addition to avoiding tiles that are not included in the acceptedTiles list, EasyStar will also avoid all points in this dictionary.
		 * The dictionary should have a key where the x and y values are deliminated by an understcore like this: pointsToAvoid[25 + "_" + 21] = 1;
		 * This would mean that the position 25,21 is considered an unacceptable move, even if the tile-type is in the acceptableTiles list.
		 **/
		public function EasyStar(acceptableTiles:Vector.<uint>, iterationsPerCalculation:uint = 200, pointsToAvoid:Dictionary = null) {
			_acceptableTiles = acceptableTiles;
			_pointsToAvoid = pointsToAvoid;
			if (_pointsToAvoid == null) {
				_pointsToAvoid = new Dictionary();
			}
			_iterationsPerCalculation = iterationsPerCalculation;
			_isDoneCalculating = true;
		}

		/**
		 * Sets the collision grid that easy star uses.
		 * 
		 * @param collisionGrid The collision grid that this Easy Star instance will read from. This should be a vector of vector of uints where 0 is walkable and 1 is unwalkable.
		 **/
		public function setCollisionGrid(collisionGrid:Vector.<Vector.<uint>>):void {
			_collisionGrid = collisionGrid;
		}
		
		/**
		 * Sets the start and end point that easy star will attempt to make a path from.
		 * 
		 * @param startCoordinate The x and y of the start point on the grid.
		 * @param endCoordinate The x and y of the end point on the grid.
		 * @param calculationsPerFrame How many calculations to perform per frame. If you want to try and find a solution instantly, then you should set this to a very high number.
		 * 
		 * Due to the flash's single threaded nature, a high number of calculations could slow down the performance of your app.
		 **/
		public function setPath(startCoordinate:Point,endCoordinate:Point):void {
			if (!_collisionGrid) {
				throw new Error("You can't set a path without first setting a grid. Use setGrid before you try to set a path.");
			}

			_openListLen = 0;
			_startCoordinateX = startCoordinate.x;
			_startCoordinateY = startCoordinate.y;
			_endCoordinateX = endCoordinate.x;
			_endCoordinateY = endCoordinate.y;
			_nodeDictionary = new Dictionary();
			_openList = new Vector.<Node>();

			if (_startCoordinateX<0||_startCoordinateY<0||_endCoordinateX<0||_endCoordinateY<0||_startCoordinateX>_collisionGrid[0].length-1||_startCoordinateY>_collisionGrid.length-1||_endCoordinateX>_collisionGrid[0].length-1||_endCoordinateY>_collisionGrid.length-1) {
				throw new Error("Your start or end point is outside the scope of your grid.");
				return;
			} else if (_startCoordinateX==_endCoordinateX&&_startCoordinateY==_endCoordinateY) {
				dispatchEvent(new PathFoundEvent(new Vector.<Point>()));
				return;
			}
			
			//Checks to make sure your end point is a walkable tile.
			var endTile:uint = _collisionGrid[_endCoordinateY][_endCoordinateX];
			var isAcceptable:Boolean = false;
			for (var i:uint = 0; i < _acceptableTiles.length; i++) {
				if (endTile == _acceptableTiles[i]) {
					isAcceptable = true;
					break;
				}
			}
			if (isAcceptable == false) {
				dispatchEvent(new PathNotFoundEvent());
				return;
			}
			
			_isDoneCalculating = false;
			
			addToOpenList(coordinateToNode(_startCoordinateX,_startCoordinateY,null,STRAIGHT_COST));
		}
		
		/**
		 * This method does n iterations of calculations based on the calculationsPerFrame you specified during your path.
		 **/
		public function calculate():void {
			if (!_collisionGrid||_isDoneCalculating) {
				return;
			}
			_calculationsThisFrame = 0;
			while ( _calculationsThisFrame < _iterationsPerCalculation && !_isDoneCalculating) {
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
					_isDoneCalculating = true;
					return;
				}
			
				if (searchNode.coordinateY > 0) {
					checkAdjacentNode(searchNode,0,-1,STRAIGHT_COST);
					if (_isDoneCalculating) {
						return;
					}
				}
				if (searchNode.coordinateX < _collisionGrid[0].length-1) {
					checkAdjacentNode(searchNode,+1,0,STRAIGHT_COST);
					if (_isDoneCalculating) {
						return;
					}
				}
				if (searchNode.coordinateY < _collisionGrid.length-1) {
					checkAdjacentNode(searchNode,0,+1,STRAIGHT_COST);
					if (_isDoneCalculating) {
						return;
					}
				}
				if (searchNode.coordinateX > 0) {
					checkAdjacentNode(searchNode,-1,0,STRAIGHT_COST);
					if (_isDoneCalculating) {
						return;
					}
				}
			
				searchNode.list = Node.CLOSED_LIST;
				_openList[searchNodei] = _openList[_openListLen-1];
				_openListLen--;
				_calculationsThisFrame++;
			}
		}
		
		private function addToOpenList(n:Node):void {
			_openListLen++;
			_openList[_openListLen-1] = n;
		}
		
		private function checkAdjacentNode(searchNode:Node,x:int,y:int, cost:uint):void {
			var adjacentCoordinateX:uint = searchNode.coordinateX+x;
			var adjacentCoordinateY:uint = searchNode.coordinateY+y;
			if (_endCoordinateX==adjacentCoordinateX&&_endCoordinateY==adjacentCoordinateY) {
				_isDoneCalculating = true;
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
			if (_pointsToAvoid[adjacentCoordinateX + "_" + adjacentCoordinateY] == null) {
				for (var i:int = 0; i < _acceptableTiles.length; i++) {
					if (_collisionGrid[adjacentCoordinateY][adjacentCoordinateX] == _acceptableTiles[i]) {
						var node:Node = coordinateToNode(adjacentCoordinateX, adjacentCoordinateY, searchNode, cost);
						if (!node.list) {
							node.list = Node.OPEN_LIST;
							addToOpenList(node);
						} else if (node.list == Node.OPEN_LIST) {
							if (searchNode.G + cost < node.G) {
								node.G = searchNode.G + cost;
								node.parent = searchNode;
							}
						}
						break;
					}
				}
			}
		}
		
		private function coordinateToNode(coordinateX:uint, coordinateY:uint, parent:Node, cost:uint):Node {
			//Lets first check to see if we already have this coordinate saved as a node in our dictionary.
			if (_nodeDictionary[coordinateX + "_" + coordinateY])
				return _nodeDictionary[coordinateX + "_" + coordinateY];
			
			var H:uint = getDistance(coordinateX, coordinateY, _endCoordinateX, _endCoordinateY);
			if (parent)
				var G:uint = parent.G + cost;
			else
				G = H;
			
			var node:Node = new Node(parent, coordinateX, coordinateY, G, H);
			_nodeDictionary[coordinateX + "_" + coordinateY] = node;
			return node;
		}
		
		private function getDistance(x1:uint, x2:uint, y1:uint, y2:uint):uint {
			return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
		}
	}	
}
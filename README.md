# EasyStarAS3

[![Example](http://prettymuchbryce.com/easystar.jpg)

EasyStarAS3 is a simple AStar API that helps you find your way around walls in your tile-based game. Basically, it gives you the shortest path without running your character through walls.

EasyStarAS3 really only has 3 methods that you need to worry about

	easyStar.setCollisionGrid(collisionGrid:Vector.<Vector.<uint>>);
	easyStar.calculatePath(startPoint:Point,endPoint:Point,calculationsPerFrame:uint);
	easyStar.calculate();

* The collision grid is a Vector containing rows of Vector.<uint>s where 0 is walkable and 1 is unwalkable.

* EasyStar will dispatch an event if it finds your path, or if there is no possible path.

* You can tell EasyStar how many calculations it should perform each frame. This is important if you are making lots of calculations or have a very large collision grid.

* EasyStar only supports up right down left movement. No diagonals for now.

# Usage

Check out the example file for a better simple working example.

	public class EasyStarTest extends Sprite
	{
		public var myCollisionGrid:Vector.<Vector.<uint>>;
		public function EasyStarTest():void {
			var easyStar:EasyStar = new EasyStar();
		
			easyStar.addEventListener(PathFoundEvent.EVENT,onPathFound);
			easyStar.addEventListener(PathNotFoundEvent.EVENT,onNoPathFound);

			//Create your collision grid however you like here

			easyStar.setCollisionGrid(myCollisionGrid);
		
			easyStar.calculatePath(myStartPoint,myEndPoint);
		
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		public function onEnterFrame(e:Event):void {
			easyStar.calculate();
		}
		public function onPathFound(e:PathFoundEvent):void {
			trace("My path was found.. heres how I get there:");
			for (var i:int = 0; i < e.path.length; i++) {
				trace (e.path[i]);
			}
		}
		public function onNoPathFound(e:PathNotFoundEvent):void {
			trace("There appears to be no path to my end point");
		}
	}
		
		
# EasyStarAS3

[![Launch Example](http://prettymuchbryce.com/easystaras3/easystar.jpg)](http://prettymuchbryce.com/easystaras3/Main.html)

A* is an algorithm for finding the shortest path between two points. It is very useful in game development. Any tile-based game that requires this kind of movement will utilize some form of A*.
Think Tower Defense games, City Building games, Rogue-Likes, the list goes on.

EasyStarAS3 is a simple A* API written in AS3. It allows you to take advantage of A* without having to spend time learning how it works or writing your own implementation, though I would highly encourage you to do so anyway. :)

## Some Features of EasyStarAS3

* The ability to spread out your calculations over multiple frames. EasyStarAS3 lets you specify how many calculations should be performed each frame.
* The ability to add separate points to avoid, outside of those that are avoided based on tile type.
* The ability to specify which tile types are walkable, and which are unwalkable.
* EasyStar will dispatch an event if it finds your path, or if there is no possible path.
* Easy!

## Getting Started

To use EasyStarAS3, first create a grid that represents the map in your game. Maybe you have made this map with a level editor, or by procedural generation. Here we create a hard-coded map.

	_myGrid = new Vector.<Vector.<uint>>();
	for (var y:uint = 0; y < _mapHeight; y++) {
		_myGrid.push(new Vector.<uint>);
	}
	_myGrid[0].push(0,0,0,0,1,0,1,1,0,0,0,0,0,0,0);
	_myGrid[1].push(1,1,1,0,1,0,1,0,0,0,0,0,0,0,0);
	_myGrid[2].push(1,0,0,0,0,0,1,0,0,0,0,0,0,0,0);
	_myGrid[3].push(1,0,0,0,0,0,1,1,1,1,1,1,1,1,0);
	_myGrid[4].push(1,1,0,0,0,0,0,0,0,0,0,0,0,1,0);
	_myGrid[5].push(1,0,1,1,0,0,1,0,0,0,0,0,0,1,0);
	_myGrid[6].push(1,0,1,1,0,0,1,0,0,0,0,0,0,1,0);
	_myGrid[7].push(1,0,0,0,0,0,1,1,1,1,0,0,0,1,0);
	_myGrid[8].push(1,0,0,0,0,0,1,0,0,1,0,0,0,1,0);
	_myGrid[9].push(1,1,1,1,1,1,1,0,0,1,0,0,0,0,0);
	

Next you should create a vector containing the tiles that should be "walkable". In our case, I want the 0's to be walkable and the 1's to be walls.

	var _acceptableTiles:Vector.<uint> = new Vector.<uint>();
	_acceptableTiles.push(0); 

I now have everything I need to create my EasyStarAS3 instance.

	var myEasyStar:EasyStar = new EasyStar(_acceptableTiles);

Next I want to let EasyStarAS3 know what my grid looks like, so I need to call the setCollisionGrid method.

	myEasyStar.setCollisionGrid(_myGrid);

We are getting close now. 

All I need to do is give it a path that I want. In the case of my example, I give easyStar a path every time the user clicks. Lets say I want to find a path from the upper left hand corner of the map, to a position a few tiles to the right.

	var startPoint:Point = new Point(0,0);
	var endPoint:Point = new Point(3,0);
	myEasyStar.setPath(startPoint,endPoint);

EasyStarAS3 will not yet start calculating my path. In order for EasyStarAS3 to actually start calculating, I must call the calculate() method. It is good practice to call the calculate() method on an enterFrame event. 
If you have a large collision map, then it is possible that these calculations could slow down your game. For this reason, it might be a good idea to give EasyStarAS3 a smaller iterationsPerCalculations value in it's constructor.. This way it may take more frames for you to find a path, but you won't completely halt your game trying to find a path. Don't forget -- Flash Player 10 is single-threaded, and making intensive calculations could mean dropping your frame-rate, and nobody wants that!

In this example, lets just assume that we don't have this problem, and that our collisionGrid is small, and that our path is easy to find -- which it is!

But.. before we tell EasyStarAS3 to start calculating.. we need to be ready to accept the event that it gives back. For this reason, we should add our event listeners. EasyStarAS3 has only two events. One for each outcome. Either your path was found, or it wasn't found.

	myEasyStar.addEventListener(PathFoundEvent.EVENT,onPathFoundEvent);
	myEasyStar.addEventListener(PathNotFoundEvent.EVENT,onPathNotFoundEvent);

I won't go through the trouble of showing you what you might do when you catch these events, thats for you to decide! In the example above, I show how to make your character use these events to start traversing the returned path.

So now that we have everything set up, the only set left is to calculate the path.

	myEasyStar.calculate();

..and it's that easy! 

Please let me know if you have any questions, comments, or suggestions.

## Example project
Included is an example project. If you're using FlashBuilder, just File -> Import -> Existing Projects into WorkSpace, and navigate to the EasyStarAS3 directory.
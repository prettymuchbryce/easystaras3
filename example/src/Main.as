package {
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.pmb.easystar.EasyStar;
	import com.pmb.easystar.events.PathFoundEvent;
	import com.pmb.easystar.events.PathNotFoundEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	[SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]
	
	/**
	 * A very simple example app using EasyStarAS3 for A* Pathfinding.
	 * This little app demonstrates how to get up and going with EasyStarAS3 and is commented heavily.
	 * 
	 * https://github.com/prettymuchbryce/EasyStarAS3
	 **/
	public class Main extends Sprite {
		[Embed(source = "../assets/tiles.png")]
		private static const IMG_TILES:Class;
		private static const TILE_SHEET:BitmapData = new IMG_TILES().bitmapData;
		private static const PLAYER_GRAPHIC:uint = 4;
		private static const TILE_SIZE:uint = 32;
		private static const MAP_WIDTH:uint = 20;
		private static const MAP_HEIGHT:uint = 15;

		private var _easyStar:EasyStar;
		private var _tileMap:Vector.<Vector.<uint>>;
		
		private var _buffer:Bitmap;
		private var _selectionSquare:Sprite;
		private var _playerX:uint = 19; //These are the true values of our players position in relation to the tileMap.
		private var _playerY:uint = 4;
		private var _playerVisualPosition:Point = new Point(_playerX*TILE_SIZE,_playerY*TILE_SIZE); //This is the player graphic's pixel position.
		public function Main() {
			stage.quality = StageQuality.LOW;
			
			//Create an empty buffer to draw the grid onto
			_buffer = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,false,0x0));
			addChild(_buffer);
			
			//Create the mouse over square that displays when we mouse over a tile
			_selectionSquare = new Sprite();
			_selectionSquare.graphics.beginFill(0xFFFFFF,.3);
			_selectionSquare.graphics.drawRect(0,0,TILE_SIZE,TILE_SIZE);
			_selectionSquare.graphics.endFill();
			addChild(_selectionSquare);

			//Setup our collision grid.
			//EasyStar takes a vector of Vector.<uint>'s
			//This could even be the same grid that you're using to visually represent which tiles should display... but this might be impractical for bigger games.
			_tileMap = new Vector.<Vector.<uint>>();
			for (var y:int = 0; y < MAP_HEIGHT; y++) _tileMap.push(new Vector.<uint>);
			 _tileMap[0].push(0,0,1,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0);
			 _tileMap[1].push(0,2,2,2,2,2,0,2,2,2,2,2,2,2,2,2,2,2,2,0);
			 _tileMap[2].push(0,2,2,2,2,2,0,2,2,2,2,0,2,2,2,2,2,2,2,0);
			 _tileMap[3].push(0,2,2,2,2,2,0,2,2,2,2,0,2,2,2,3,3,3,2,0);
			 _tileMap[4].push(0,2,2,2,2,2,0,2,2,2,2,0,2,2,2,3,3,3,2,2);
			 _tileMap[5].push(0,2,2,2,2,2,0,2,2,2,2,0,2,2,2,3,3,3,2,0);
			 _tileMap[6].push(0,2,2,2,2,2,0,2,2,2,2,0,2,2,2,2,2,2,2,0);
			 _tileMap[7].push(0,2,0,0,1,0,0,0,2,2,2,0,0,0,2,2,2,2,2,0);
			 _tileMap[8].push(0,2,2,2,2,2,2,0,2,2,2,2,2,0,2,2,2,2,2,0);
			 _tileMap[9].push(0,2,2,2,2,2,2,0,0,1,0,0,0,0,0,1,0,0,2,0);
			_tileMap[10].push(0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0);
			_tileMap[11].push(0,2,2,2,2,2,2,2,2,2,2,0,0,1,0,0,2,0,0,0);
			_tileMap[12].push(0,2,2,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2,2,0);
			_tileMap[13].push(0,2,2,2,2,2,2,2,2,2,2,0,2,2,2,2,2,2,2,0);
			_tileMap[14].push(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

			//Here we prep our acceptable tiles so that EasyStarAS3 knows which tiles are okay to walk on.
			//2 is the hardwood floor
			//3 is the rug.
			var acceptableTiles:Vector.<uint> = new Vector.<uint>();
			acceptableTiles.push(2);
			acceptableTiles.push(3);
			
			//Here we setup EasyStarAS3, and give it our tileMap.
			//In our particular case -- our tileMap happens to map directly to our collisionGrid. That is -- certain visual tiles should never be "walkable", and certain ones should always be.
			_easyStar = new EasyStar(acceptableTiles);
			_easyStar.setCollisionGrid(_tileMap);
			
			//We also add some events so that we can know what to do when we find a path (or dont find one).
			_easyStar.addEventListener(PathFoundEvent.EVENT,onPathFoundEvent);
			_easyStar.addEventListener(PathNotFoundEvent.EVENT,onPathNotFoundEvent);
			
			//Here we add a couple more events for click checking, and refreshing the screen.
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onClick);
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		/**
		 * Dispatched when no path was found.
		 * @param event The PathNotFound event dispatched by EasyStarAS3.
		 **/
		private function onPathNotFoundEvent(event:PathNotFoundEvent):void {
			trace("No path was found!");
		}
		
		/**
		 * Dispatched when a path has been found. This method starts our player off on traversing the path that was found.
		 * @param event The PathFoundEvent dispatched by EasyStarAS3.
		 **/
		private function onPathFoundEvent(e:PathFoundEvent):void {
			traversePath(e.path);
		}
		
		/**
		 * Responding to a click event. 
		 * This method figures out where the player clicked, and then lets EasyStarAS3 know we want to try to find a path there using setPath(start,end);
		 **/
		private function onClick(event:Event):void {
			TweenMax.killTweensOf(_playerVisualPosition);
			var tileClicked:Point = new Point(Math.floor(mouseX/TILE_SIZE),Math.floor(mouseY/TILE_SIZE));
			
			var playerPoint:Point = new Point(_playerX,_playerY);
			if (playerPoint.equals(tileClicked)) {
				return;
			}
			_easyStar.setPath(playerPoint,tileClicked);
		}
		
		/**
		 * Traverses the path.
		 * @param path A list of points representing the path to the destination.
		 **/
		private function traversePath(path:Vector.<Point>):void {
			if (path==null||path.length==0) {
				return;
			}
			_playerX = path[0].x;
			_playerY = path[0].y;
			TweenMax.to(_playerVisualPosition,.15,{x:path[0].x*TILE_SIZE,y:path[0].y*TILE_SIZE,onComplete:traversePath,onCompleteParams:new Array(path),ease:Linear.easeNone});
			path.shift();
		}
		
		/**
		 * Here we do easyStar's calculations, and then draw graphics to the screen. 
		 * It's safe to call calculate() even if there is no current path being calculated.
		 **/
		private function onEnterFrame(event:Event):void {
			_selectionSquare.x = Math.floor(mouseX/TILE_SIZE)*TILE_SIZE;
			_selectionSquare.y = Math.floor(mouseY/TILE_SIZE)*TILE_SIZE;
			_easyStar.calculate();
			draw();
		}
		
		/**
		 * Draws the graphics to the screen.
		 **/
		private function draw():void {
			//These 4 lines draw the tile grid
			for (var y:uint = 0; y < MAP_HEIGHT; y++) {
				for (var x:uint = 0; x < MAP_WIDTH; x++) {
					_buffer.bitmapData.copyPixels(TILE_SHEET,new Rectangle(_tileMap[y][x]*TILE_SIZE,0,TILE_SIZE,TILE_SIZE),new Point(x*TILE_SIZE,y*TILE_SIZE));
				}
			}
			
			//This line draws the player
			_buffer.bitmapData.copyPixels(TILE_SHEET,new Rectangle(4*TILE_SIZE,0,TILE_SIZE,TILE_SIZE),_playerVisualPosition);
		}
	}
}
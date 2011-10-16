package
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	import com.pmb.easystar.EasyStar;
	import com.pmb.easystar.events.PathFoundEvent;
	import com.pmb.easystar.events.PathNotFoundEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	[SWF(width="960", height="640", frameRate="60", backgroundColor="#002143")]
	public class Main extends Sprite
	{
		protected var _easyStar:EasyStar;
		protected var _myGrid:Vector.<Vector.<uint>>;
		
		protected var _tileSize:uint = 64;
		protected var _mapWidth:uint = 15;
		protected var _mapHeight:uint = 10;
		
		protected var _buffer:Bitmap;
		protected var _buffer2:Bitmap;
		protected var _player:Sprite;
		protected var _playerX:uint = 0;
		protected var _playerY:uint = 0;
		public function Main()
		{
			//Create an empty buffer to draw the grid onto
			_buffer = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,false,0x0));
			addChild(_buffer);
			
			//This buffer just creates the checker effect
			_buffer2 = new Bitmap(new BitmapData(_buffer.bitmapData.width,_buffer.bitmapData.height,false,0x0));
			addChild(_buffer2);
			_buffer2.alpha = .1;
			
			//Create the Player and add him to the stage
			_player = new Sprite();
			_player.graphics.beginFill(0x0000FF);
			_player.graphics.drawCircle(_tileSize/2,_tileSize/2,_tileSize/3);
			addChild(_player);
			
			//Setup our collision grid.
			//EasyStar takes a vector of Vector.<uint>'s where 0 is walkable and 1 is unwalkable
			_myGrid = new Vector.<Vector.<uint>>();
			for (var y:int = 0; y < _mapHeight; y++) _myGrid.push(new Vector.<uint>);
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
			
			//Draw this information to our bitmap
			drawScreen();

			
			//Setup EasyStar, and give it our grid.
			//Also add some events so we can know what to do when we find a path (or dont find one)
			_easyStar = new EasyStar();
			_easyStar.setCollisionGrid(_myGrid);
			_easyStar.addEventListener(PathFoundEvent.EVENT,onPathFoundEvent);
			_easyStar.addEventListener(PathNotFoundEvent.EVENT,onPathNotFoundEvent);
			
			//Add Some other events for click checking and EnterFrame
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onClick);
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
		}
		
		protected function onPathNotFoundEvent(event:Event):void
		{
			trace("No path was found!");
		}
		
		protected function onPathFoundEvent(e:PathFoundEvent):void {
			traversePath(e.path);
		}
		protected function onEnterFrame(event:Event):void
		{
			_easyStar.calculate();
		}
		protected function onClick(event:Event):void
		{
			TweenMax.killTweensOf(_player);
			var tileClicked:Point = new Point(Math.floor(mouseX/_tileSize),Math.floor(mouseY/_tileSize));
			
			//You can tell easystar how many calculations you want it to make per frame.
			//If you are doing too many calculations then your game could slow down
			//This is especially true if you have more than a few objects trying to find paths at once or you have a huge map
			var playerPoint:Point = new Point(_playerX,_playerY);
			if (playerPoint.equals(tileClicked)) return;
			_easyStar.calculatePath(playerPoint,tileClicked,100);
		}
		protected function traversePath(path:Vector.<Point>):void {
			if (path==null||path.length==0) return;
			_playerX = path[0].x;
			_playerY = path[0].y;
			TweenMax.to(_player,.15,{x:path[0].x*_tileSize,y:path[0].y*_tileSize,onComplete:traversePath,onCompleteParams:new Array(path),ease:Linear.easeNone});
			path.shift();
		}
		public function drawScreen():void {
			for (var y:int = 0; y < _mapHeight; y++) {
				for (var x:int = 0; x < _mapWidth; x++) {
					if ((x+y)%2) var offset:uint = 1;
					else offset=0;
					if (offset==0) _buffer2.bitmapData.fillRect(new Rectangle(x*_tileSize,y*_tileSize,_tileSize,_tileSize),0xFFFFFF);
					if (_myGrid[y][x]==0) {
						_buffer.bitmapData.fillRect(new Rectangle(x*_tileSize,y*_tileSize,_tileSize,_tileSize),0x00FF00);
					} else {
						_buffer.bitmapData.fillRect(new Rectangle(x*_tileSize,y*_tileSize,_tileSize,_tileSize),0xFF0000);
					}
				}
			}
		}
	}
}
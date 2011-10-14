package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.greensock.TweenMax;

	[SWF(width="960", height="640", frameRate="60", backgroundColor="#002143")]
	public class Main extends Sprite
	{
		protected var _tileSize:uint = 64;
		protected var _mapWidth:uint = 15;
		protected var _mapHeight:uint = 10;
		protected var _myGrid:Array;
		protected var _buffer:Bitmap;
		protected var _player:Sprite;
		protected var _testPath:Vector.<Point> = new Vector.<Point>;
		public function Main()
		{
			createTestPath();
			_buffer = new Bitmap(new BitmapData(stage.stageWidth,stage.stageHeight,false,0x0));
			addChild(_buffer);
			_myGrid = new Array();
			_player = new Sprite();
			_player.graphics.beginFill(0x0000FF);
			_player.graphics.drawCircle(_tileSize/2,_tileSize/2,_tileSize/3);
			addChild(_player);
			for (var y:int = 0; y < _mapHeight; y++) {
				var row:Array = new Array();
				for (var x:int = 0; x < _mapWidth; x++) {
					if (Math.random()<.9) {
						row.push(0);
					} else row.push(1);
				}
				_myGrid.push(row);
			}
			drawScreen();
			_buffer.addEventListener(MouseEvent.CLICK,onClick);
			traversePath(_testPath);
		}
		protected function createTestPath():void {
			_testPath.push(new Point(3,4));
			_testPath.push(new Point(4,4));
			_testPath.push(new Point(4,5));
			_testPath.push(new Point(4,4));
			_testPath.push(new Point(4,3));
			_testPath.push(new Point(4,2));
			_testPath.push(new Point(3,2));
		}
		protected function onClick(event:Event):void
		{
			var tileClicked:Point = new Point(Math.floor(mouseX/_tileSize),Math.floor(mouseY/_tileSize));
			
		}
		protected function traversePath(path:Vector.<Point>):void {
			if (path.length==0) return;
			
			TweenMax.to(_player,1,{x:path[0].x*_tileSize,y:path[0].y*_tileSize,onComplete:traversePath,onCompleteParams:new Array(path)});
			path.splice(0,1);
		}
		public function drawScreen():void {
			for (var y:int = 0; y < _mapHeight; y++) {
				for (var x:int = 0; x < _mapWidth; x++) {
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
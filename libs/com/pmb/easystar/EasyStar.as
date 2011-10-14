package com.pmb.easystar
{
	import flash.geom.Point;

	public class EasyStar
	{
		protected var _gridWidth:uint;
		protected var _gridHeight:uint;
		protected var _grid:Vector.<Vector.<uint>>;
		protected var _closedList
		public function EasyStar(gridWidth:uint,gridHeight:uint)
		{
			
		}
		public function updateGrid(value:Vector.<Vector.<uint>>):void {
			_grid = value;
		}
		public function calculatePath(start:Point,end:Point,calculationsPerFrame:uint):void {
			
		}
	}
}
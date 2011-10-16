package com.pmb.easystar
{
	import flash.geom.Point;

	public class Node
	{
		public const OPEN_LIST:String = "OPEN";
		public const CLOSED_LIST:String = "CLOSED";
		public var parent:Node;
		public var coordinateX:uint;
		public var coordinateY:uint;
		public var list:String;
		public var G:uint;
		public var H:uint;
		public function Node(parent:Node,coordinateX:uint,coordinateY:uint,G:uint,H:uint):void {
			this.coordinateX = coordinateX;
			this.coordinateY = coordinateY;
			this.parent = parent;
			this.G = G;
			this.H = H;
		}
		public function get F():uint {
			return G+H;
		}
	}
}
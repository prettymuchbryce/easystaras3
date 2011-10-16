package com.pmb.easystar
{
	import flash.geom.Point;

	public class Node
	{
		public const OPEN_LIST:String = "OPEN";
		public const CLOSED_LIST:String = "CLOSED";
		public var parent:Node;
		public var coordinate:Point;
		public var list:String;
		public var G:uint;
		public var H:uint;
		public function Node(parent:Node,coordinate:Point,G:uint,H:uint):void {
			this.coordinate = coordinate;
			this.parent = parent;
			this.G = G;
			this.H = H;
		}
		public function get F():uint {
			return G+H;
		}
	}
}
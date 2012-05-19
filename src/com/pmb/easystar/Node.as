package com.pmb.easystar {
	import flash.geom.Point;

	/**
	 * This class represents a single node. A node is a representation of a tile that we are searching or have already searched.
	 **/
	public class Node {
		public static const OPEN_LIST:String = "OPEN";
		public static const CLOSED_LIST:String = "CLOSED";
		public var parent:Node;
		public var coordinateX:uint;
		public var coordinateY:uint;
		public var list:String;
		public var G:uint;
		public var H:uint;
		/**
		 * @param parent The parent of this node.
		 * @param coordinateX The X position of this node in the coordinate space.
		 * @param coordinateY the Y position of this node in the coordinate space.
		 * @param G the G cost of this node.
		 * @param H the heuristic cost of this node.
		 **/
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
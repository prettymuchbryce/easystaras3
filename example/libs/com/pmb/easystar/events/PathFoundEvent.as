package com.pmb.easystar.events {
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * An event dispatched when a path has not been found.
	 * 
	 * This event contains a vector of points which contain the coordinate data.
	 * This data is ordered from start to end, and always represents a valid path.
	 **/
	public class PathFoundEvent extends Event {
		public static const EVENT:String = "PathFoundEvent";
		public var path:Vector.<Point>;
		public function PathFoundEvent(path:Vector.<Point>) {
			this.path = path;
			super(EVENT);
		}
		override public function clone():Event {
			return new PathFoundEvent(path);
		}
	}
}
package com.pmb.easystar.events
{
	import flash.events.Event;
	import flash.geom.Point;
	public class PathFoundEvent extends Event
	{
		public static const EVENT:String = "PathFoundEvent";
		public var path:Vector.<Point>;
		public function PathFoundEvent(path:Vector.<Point>)
		{
			this.path = path;
			super(EVENT);
		}
	}
}
package com.pmb.easystar.events
{
	import flash.events.Event;

	public class PathNotFoundEvent extends Event
	{
		public static const EVENT:String = "PathNotFoundEvent";
		public function PathNotFoundEvent():void
		{
			super(EVENT);
		}
	}
}
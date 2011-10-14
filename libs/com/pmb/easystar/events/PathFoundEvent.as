package com.pmb.easystar.events
{
	import flash.events.Event;
	
	public class PathFoundEvent extends Event
	{
		public static const EVENT:String = "PathFoundEvent";
		public function PathFoundEvent()
		{
			super(EVENT);
		}
	}
}
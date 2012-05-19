package com.pmb.easystar.events {
	import flash.events.Event;

	/**
	 * An event dispatched when a path has not been found.
	 **/
	public class PathNotFoundEvent extends Event {
		public static const EVENT:String = "PathNotFoundEvent";
		public function PathNotFoundEvent():void {
			super(EVENT);
		}
	}
}
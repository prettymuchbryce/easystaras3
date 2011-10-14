package com.pmb.easystar
{
	public class Node
	{
		protected var _parent:Node;
		protected var _G:uint;
		protected var _H:uint;
		public function Node(parent:Node):void {
			_parent = parent;
		}
	}
}
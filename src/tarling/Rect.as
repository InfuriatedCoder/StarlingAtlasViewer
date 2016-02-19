package tarling 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author © Vadim Ledyaev 2015
	 */
	public class Rect extends Rectangle 
	{
		public var id:String;
		public var pivot:Point
		
		public function Rect(id:String, pivot:Point = null, x:Number=0, y:Number=0, width:Number=0, height:Number=0) 
		{
			super(x, y, width, height);
			
			if (pivot)
			{
				this.pivot = pivot;
			}else {
				this.pivot = new Point()
			}
			this.id = id;
		}
		
		override public function toString():String 
		{
			var result:String = 'RECT ' + id + ', @[' + x + ':' + y + '][w' + width + ', h' + height + '][px:' + pivot.x + ', py:' + pivot.y + ']';
			return result
		}
	}
}
package tarling 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.TouchscreenType;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Vadim Ledyaev ©2015
	 */
	public class AtlasViewer extends Sprite 
	{		
		private var currentXML:XML;
		private var rects:Vector.<tarling.Rect>;
		public static var INSTANCE:AtlasViewer = new AtlasViewer()
		public var view:Image
		private var hightlight:Shape= new Shape()
		public var currentRect:Rect;
		
		public function AtlasViewer() 
		{
			super();
			INSTANCE = this
		}
		
		public function init():void 
		{
			addChild(hightlight)
			hightlight.visible = false
			hightlight.touchable = false;
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var touch:Touch = e.getTouch(view)
			if (touch) 
			{
				var pos:Point = touch.getLocation(view)
				var _x:Number = pos.x
				var _y:Number = pos.y
				
				findRects(new Point(_x, _y))
				
				pos = touch.getLocation(stage)
				
				_x = pos.x
				_y = pos.y
				if (_y > stage.stageHeight - 30) _y = stage.stageHeight - 60
				if (_x > 1024 - GUI.cursor.txt.textWidth / 2  - 5) _x = 1024 - GUI.cursor.txt.textWidth / 2 - 5
				if (_x < GUI.cursor.txt.textWidth / 2 + 5) _x = GUI.cursor.txt.textWidth / 2 + 5
				
				
				GUI.cursor.x = _x
				GUI.cursor.y = _y
			}
		}
		
		private function findRects(p:Point):void 
		{
			currentRect = null;
			for each(var rect:Rect in rects)
			{
				if (rect.containsPoint(p))
				{
					currentRect = rect
					break
				}
			}
			hightlight.graphics.clear();
			
			hightlight.scaleX = hightlight.scaleY = view.scaleX;
			if (currentRect) {
				hightlight.visible = true
				hightlight.graphics.lineStyle(4, 0)
				hightlight.graphics.drawRoundRect(currentRect.x, currentRect.y, currentRect.width, currentRect.height, 10)
				hightlight.graphics.lineStyle(2, 0xFFFFFF)
				hightlight.graphics.drawRoundRect(currentRect.x, currentRect.y, currentRect.width, currentRect.height, 10)
				hightlight.graphics.beginFill(0)
				hightlight.graphics.drawCircle(currentRect.x + currentRect.pivot.x, currentRect.y + currentRect.pivot.y, 7)
				hightlight.graphics.beginFill(0xFF6666)
				hightlight.graphics.drawCircle(currentRect.x + currentRect.pivot.x, currentRect.y + currentRect.pivot.y, 5)
				GUI.cursor.txt.text = currentRect.id
			}else {
				hightlight.visible = false;
			}
		}
		
		public function showAtlasImage(atlas:XML, sourceBD:BitmapData = null, sourceATFBA:ByteArray = null):void
		{
			if (view) {
				view.removeFromParent(true)
			}
			if (sourceBD)
			{
				var texture:Texture = Texture.fromBitmapData(sourceBD)
			}else {
				texture = Texture.fromAtfData(sourceATFBA)
			}
			view = new Image(texture);
			addChild(view);
			if (view.width >= view.height) 
			{
				view.width = 1024;
				view.scaleY = view.scaleX;
			}else {
				view.height = 1024;
				view.scaleX = view.scaleY;
			}
			
			view.addEventListener(TouchEvent.TOUCH, onTouch);
			
			rects = new Vector.<Rect> ()
			currentXML= atlas;
			parseXML()
			addChild(hightlight)
		}
		
		private function parseXML():void 
		{
			var elements:XMLList = currentXML.children()
			var total:int = elements.length();
			var j:int, element:XML, rect:Rect, id:String;
			for (j = 0; j < total; j++) 
			{
				//<SubTexture name="chocolateBar" x="1252" y="0" width="170" height="170" pivotX="85" pivotY="85"/>
				
				element = elements[j];
				id = element.@name;
				var pivot:Point;
				if (element.@pivotX || element.@pivotY) pivot = new Point();
				if (element.@pivotX) pivot.x = element.@pivotX;
				if (element.@pivotY) pivot.y = element.@pivotY;
				rect = new Rect(id, pivot, element.@x, element.@y, element.@width, element.@height)
				rects.push(rect)
				//trace(rect)
			}
		}
	}
}
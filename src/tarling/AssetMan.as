package tarling
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.events.*
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.textures.TextureSmoothing;
	import starling.utils.AssetManager;
	
	/**
	 * ...
	 * @author Vadim Ledyaev ©2014
	 */
	public class AssetMan extends AssetManager 
	{
		public static var INSTANCE:AssetMan = new AssetMan();
		
		public static var progressCallback:Function;
		public static var pivots:Dictionary;
		
		public function AssetMan() 
		{
			if(INSTANCE)
			{
				throw "CAN'T CREATE ANOTHER INSTANCE OF SINGLETON AssetMan";
			} else 
			{
				INSTANCE = this;
				
				INSTANCE.verbose = true;
				INSTANCE.keepAtlasXmls = true;
			}
		}
		
		
		public static function init(progressCallback:Function):void
		{
			AssetMan.progressCallback = progressCallback; 
			INSTANCE.enqueue(EmbeddedAssets); 
			INSTANCE.loadQueue(loadingProgress);
		}
		
		public static function loadingProgress(ratio:Number):void 
		{
			if (ratio == 1.0)
			{
				getPivots();
			}
			progressCallback(ratio);
		}
		
		public static function getPivots():void 
		{
			pivots = new Dictionary();
			var names:Vector.<String> = INSTANCE.getXmlNames();
			for each(var xmlName:String in names)
			{
				var xml:XML = INSTANCE.getXml(xmlName);
				for each (var subTexture:XML in xml.SubTexture)
				{
					var name:String        = subTexture.attribute("name");
					var pivotX:Number      = parseFloat(subTexture.attribute("pivotX"));
					var pivotY:Number      = parseFloat(subTexture.attribute("pivotY"));
					pivots[name] = new Point();
					if (pivotX) pivots[name].x = pivotX;
					if (pivotY) pivots[name].y = pivotY;
				}
			}
		}
		
		public static function getImage(id:String):Image
		{
			var texture:Texture = INSTANCE.getTexture(id);
			if (!texture) 
			{
				trace("MISSING TEXTURE:", id);
				texture = INSTANCE.getTexture("MISSING_TEXTURE");
			}
			var result:Image = new Image(texture);
			
			if (pivots[id])
			{
				result.pivotX = pivots[id].x;
				result.pivotY = pivots[id].y;
			}else {
				result.alignPivot();
			}
			
			return result;
		}
		
		public static function getSpriteWithImage(id:String):Sprite
		{
			var result:Sprite = new Sprite();
			result.addChild(getImage(id));
			
			return result;
		}
		
		static public function getMovieClip(id:String):MovieClip 
		{
			var textures:Vector.<Texture> = INSTANCE.getTextures(id);
			
			if (textures.length == 0)
			{
				trace("MISSING TEXTURES:", id);
				textures = new Vector.<Texture>()
				textures.push(INSTANCE.getTexture("MISSING_TEXTURE"));
			}
			
			var result:MovieClip = new MovieClip(textures);
			
			if (pivots[id + "0000"])
			{
				result.pivotX = pivots[id + "0000"].x;
				result.pivotY = pivots[id + "0000"].y;
			}else {
				result.alignPivot();
			}
			
			Starling.juggler.add(result);
			
			return result;
		}
		
		static public function getBitmapData(displayObject:Image):BitmapData 
		{
			var stageWidth:Number = Starling.current.stage.stageWidth;
			var stageHeight:Number = Starling.current.stage.stageHeight;
			
			var support:RenderSupport = new RenderSupport();
			RenderSupport.clear();
			support.setProjectionMatrix(0, 0, stageWidth, stageHeight);
			support.applyBlendMode(true);
			
			var stageBitmapData:BitmapData = new BitmapData(stageWidth, stageHeight, true, 0x0);
			support.blendMode = displayObject.blendMode;
			displayObject.render(support, 1.0);
			support.finishQuadBatch();
			Starling.context.drawToBitmapData(stageBitmapData);
			
			var cropBounds:Rectangle = new Rectangle(0, 0, displayObject.width / displayObject.scaleX, displayObject.height / displayObject.scaleY);
			var resultBitmapData:BitmapData = new BitmapData(cropBounds.width, cropBounds.height, true, 0x0);
			resultBitmapData.copyPixels(stageBitmapData, cropBounds, new Point());
			
			return resultBitmapData;
		}
	}
}
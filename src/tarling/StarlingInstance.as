package tarling 
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import starling.core.Starling;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author Vadim Ledyaev ©2015
	 */
	public class StarlingInstance extends Starling 
	{
		public static var context3DProfile:String
		public static var INSTANCE:StarlingInstance;
		
		public function StarlingInstance(stage:Stage) 
		{
			super(AtlasViewer, stage, null, null, Context3DRenderMode.AUTO, 'auto');
			//this.showStatsAt(HAlign.RIGHT, VAlign.TOP, 1);
		}
		
		public static function init(stage:Stage):void
		{
			handleLostContext = true;
			
			if(!INSTANCE) INSTANCE = new StarlingInstance(stage);
			INSTANCE.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextReady);
		}
		
		static private function onContextReady(e:Event):void 
		{
			context3DProfile = INSTANCE.context.profile;
			AssetMan.init(assetsCallback);
			INSTANCE.start();
		}
		
		static private function assetsCallback(ratio:Number):void 
		{
			if (ratio == 1)
			{
				AtlasViewer.INSTANCE.init();
			}
		}
	}
}
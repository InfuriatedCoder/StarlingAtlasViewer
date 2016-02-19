package 
{
	import flash.desktop.NativeDragActions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.external.ExternalInterface;
	import tarling.StarlingInstance;
	
	/**
	 * ...
	 * @author © Vadim Ledyaev 2015
	 */
	public class Main extends Sprite 
	{
		
		public function Main() 
		{
			addChild(new GUI());
			
			StarlingInstance.init(stage);
			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("loadAtlas", onloadLevelID)
			}
		}
		
		public function onloadLevelID(atf:String, xml:String):void 
		{
			ExternalInterface.call('alert', 'ok!')
		}
	}
}
package  
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.system.System;
	import flash.utils.ByteArray;
	import tarling.AtlasViewer;
	/**
	 * ...
	 * @author © Vadim Ledyaev 2015
	 * 
	 * @see extracting rotation, translation and scale values from 2d transformation matrix:
	 * @see http://math.stackexchange.com/questions/13150/extracting-rotation-scale-values-from-2d-transformation-matrix
	 * @see http://stackoverflow.com/questions/4361242/extract-rotation-scale-values-from-2d-transformation-matrix
	 */
	public class GUI extends gui 
	{
		public static var INSTANCE:GUI
		
		private var currentXML:File
		private var currentRGB:File
		
		public static var cursor:spriteID = new spriteID()
		
		public function GUI() 
		{
			super();
			
			dropHere.visible 	= false;
			cantDrop.visible 	= false;
			this.focusRect 		= false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded)
			GUI.INSTANCE = this;
			doubleClickEnabled = true;
			addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick)	
		}
		
		private function onDoubleClick(e:MouseEvent):void 
		{
			if (AtlasViewer.INSTANCE.currentRect) 
			{
				System.setClipboard(AtlasViewer.INSTANCE.currentRect.id)
			}
		}
		
		private function onAdded(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			trace('added')
			
			addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn);
			addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,  onDrop);
			addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT,  onDragExit);
			
			addChild(cursor);
			cursor.y = -20000
			cursor.txt.text = '';
		}
		
		private function onDragExit(e:NativeDragEvent):void 
		{
			dropHere.visible = false;
			cantDrop.visible = false;
		}
		
		private function onDragIn(e:NativeDragEvent):void 
		{
			var transferable:Clipboard = e.clipboard;
			
			if (transferable.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) 
			{
				var files:Array = transferable.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				
				var anyAcceptable:Boolean
				var hasPNGorATF:Boolean
				var hasXML:Boolean
				for each(var file:File in files) {
					if (file.extension.toLowerCase() == 'atf' || file.extension.toLowerCase() == 'png')  {
						hasPNGorATF = true;
					}
					if (file.extension.toLowerCase() == 'xml') {
						hasXML = true;
					}
				}
				if (hasPNGorATF && hasXML && files.length == 2) anyAcceptable = true;
				
				if (anyAcceptable)
				{
					title.visible = false;
					NativeDragManager.dropAction = NativeDragActions.MOVE;
					NativeDragManager.acceptDragDrop(this);
					dropHere.visible = true;
				}else {
					cantDrop.visible = true;
				}
				
			} else { trace("Unrecognized format") };
		}
		
		private function onDrop(e:NativeDragEvent):void 
		{
			dropHere.visible = false;
			cantDrop.visible = false;
			var clip:Clipboard = e.clipboard;
			var files:Array = clip.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			currentRGB = null;
			currentXML = null;
			if (files && files.length) {
				var file:File;
				for each(file in files)
				{
					file.load();
					file.addEventListener(Event.COMPLETE, onFileLoadComplete);
				}
			}
		}
		
		private function onFileLoadComplete(e:Event):void 
		{
			var file:File = e.target as File;
			
			if (file.extension == 'xml') {
				currentXML = file;
			}else {
				currentRGB = file;
			}
			
			if (currentXML && currentRGB) 
			{
				var xml:XML = XML(currentXML.data)
				if (currentRGB.extension == 'png')
				{
					var pngBA:ByteArray = currentRGB.data;
					var loader:Loader = new Loader()
					loader.loadBytes(pngBA)
					var pngBD:BitmapData = new BitmapData(loader.width, loader.height, true)
					pngBD.draw(loader)
				}else {
					var atfBA:ByteArray = currentRGB.data;
				}
				
				AtlasViewer.INSTANCE.showAtlasImage(xml, pngBD, atfBA)
			}
		}
		
		private function isEmptyObject(myObject:Object):Boolean
		{
			var isEmpty:Boolean = true;
			for (var s:String in myObject) {
				isEmpty = false;
				break;
			}
			return isEmpty;
		}
	}
}
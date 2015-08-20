package 
{
	import flash.display.Loader;
	import flash.display.Sprite;
 	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.ApplicationDomain;
 	
	[SWF(backgroundColor="#000000", frameRate="30", width="1024", height="768")]
	
	public class GameShell extends Sprite 
	{		
		[Embed(source = "bin/game.swf", mimeType = "application/octet-stream")]	
		private static const GameBytes:Class;
 		
 		public function GameShell()
		{
			stage.scaleMode = "noBorder";
			var self:Sprite = this;
			var ctx:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
			ctx.allowCodeImport = true;
			ctx.parameters = self.loaderInfo.parameters;
			ctx.requestedContentParent = self.parent;		// put in same parent as this
			ctx.applicationDomain = self.loaderInfo.applicationDomain;
			var ldr:Loader = new Loader();
			ldr.loadBytes(new GameBytes(),ctx);
			
			stage.addEventListener(MouseEvent.RIGHT_CLICK, function(ev:Event):void {trace("doNothing!!!");});	// disable the right click
		}//endConstr
	}//endClass
}//endPackage
/* AS3
	Copyright 2015
*/

package extra {
	import com.gskinner.motion.GTween;
	import com.vtc.utils.SimpleEventDispatcher;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import com.vtc.utils.randRange;
	import com.vtc.utils.FunctionQueue;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	/**
	 *	I took these frame functions outside of the fla so it's easier to search and maintain
	 * 
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 11.4
	 * 
	 *	@author Koh Peng Chuan / Vista Technology Capital
	 *	@since 7 May 2015
	*/	
		
		
	public class Behaviours {
		
		public static var SED:SimpleEventDispatcher;
		public static var LANG:String;
		
		/**
		 * Behavior for the HUD object
		 * 
		 * @param	$mc
		 */
		public static function hudBehaviour($mc:MovieClip):void {
			
			trace($mc);
			
			//$mc.btnStartBonusGame.alpha = 0;
			trace("hud");
			$mc.btnStartFreeSpins.alpha = 0;
			$mc.btnStartBonusGame.visible = false;
			$mc.btnStartFreeSpins.visible = false;
			alignChildren($mc);

			// ----- do the buttons bobbing on water fx
			trace("hud");
			var B:Vector.<MovieClip> = new Vector.<MovieClip>();
			for (var i:int = 0; i < $mc.numChildren; i++)			
			{
				if ($mc.getChildAt(i) is MovieClip)
				{
					var cmc:MovieClip = $mc.getChildAt(i) as MovieClip;
					cmc.bobAng = B.length;
					cmc.oy = cmc.y;
					B.push(cmc);
				}
			}
			trace("hud");
			var ppp = $mc;
			function enterFrameHandler(ev:Event):void
			{
				if ($mc.stage==null) return;
				
				$mc.fullBetWin.visible = $mc.btnSpin.visible || $mc.btnStop.visible;
				$mc.boxLineBet.visible = $mc.btnLineBet.visible;
				$mc.boxAutoSpin.visible = $mc.btnAutoSpin.visible || $mc.btnAutoStop.visible;
				
				// ----- 
				if ($mc.btnStartBonusGame.visible || $mc.btnStartFreeSpins.visible)
				{
					if ($mc.btnStartBonusGame.fadeIn == null && $mc.btnStartFreeSpins.fadeIn == null)					
					{
						for (i = B.length - 1; i > -1; i--)						
							if (B[i]!=$mc.btnStartBonusGame && 
								B[i]!=$mc.btnStartFreeSpins && 
								B[i].out==null)
							{
								B[i].out = true;
								//Utils.heatFadeFx(B[i],"out");
								Utils.simpleFadeFx(B[i],"out");
							}
						if ($mc.btnStartBonusGame.visible)	{Utils.simpleFadeFx($mc.btnStartBonusGame,"in",null,1,0); $mc.btnStartBonusGame.fadeIn=true;}
						if ($mc.btnStartFreeSpins.visible)	{Utils.simpleFadeFx($mc.btnStartFreeSpins,"in",null,1,0); $mc.btnStartFreeSpins.fadeIn=true;}
					}
				}
				else
				{
					$mc.btnStartBonusGame.fadeIn=null;
					$mc.btnStartFreeSpins.fadeIn=null;
					$mc.btnStartBonusGame.alpha = 0;
					$mc.btnStartFreeSpins.alpha = 0;
					for (i=B.length-1; i>-1; i--)
						if (B[i]!=$mc.btnStartBonusGame && 
							B[i]!=$mc.btnStartFreeSpins &&
							B[i].out!=null)
						{
							B[i].out = null;
							//Utils.heatFadeFx(B[i],"in");
							Utils.simpleFadeFx(B[i],"in");
						}
				}
				
				$mc.cntrAutoSpin.tf.text = $mc.boxAutoSpin.tf.text;
				$mc.cntrAutoSpin.visible = $mc.btnAutoStop.visible;
				$mc.boxAutoSpin.visible = $mc.btnAutoSpin.visible;
			}//endfunction

			function removeHandler(ev:Event):void
			{
				$mc.removeEventListener(Event.REMOVED_FROM_STAGE, removeHandler);
				$mc.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);				
			}//endfunction

			$mc.addEventListener(Event.REMOVED_FROM_STAGE, removeHandler);			
			$mc.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Behaviour for the lower left free spin counter
		 * 
		 * @param	$mc
		 */
		public static function freeSpinHudBehaviour($mc:MovieClip):void {
			alignChildren($mc);
			if ($mc["cdmc"]) {
				var cdmc:MovieClip = $mc["cdmc"] as MovieClip;
				var tf:TextField = $mc["tf"] as TextField;
				function trackFreespins($e:Event):void {
					if (int(tf.text) != cdmc.currentFrame) {
						if ((int(tf.text) > 0) && (int(tf.text) <= cdmc.totalFrames)) {
							cdmc.visible = true;
							cdmc.gotoAndStop(int(tf.text));
						} else {
							cdmc.visible = false;							
						}
					}
				}
				
				cdmc.addEventListener(Event.ENTER_FRAME, trackFreespins);
			}
		}
		
		public static function flashStreetLamp($mc:MovieClip):void {
			var light:MovieClip = $mc;
			
			light.fq = new FunctionQueue(50);
			light.flashes = randRange(1, 3);
			
			function turnOff():void {
				light.visible = false;
				FunctionQueue(light.fq).runFuncAfter(turnOn, 100);
			}

			function turnOn():void {
				light.visible = true;
				light.alpha = 1;
				light.flashes --;
				if (light.flashes > 0) {
					FunctionQueue(light.fq).runFuncAfter(turnOff, 100);
				} else {
					light.flashes = randRange(1, 4);
					if (light.flashes > 3) {
						FunctionQueue(light.fq).runFuncAfter(dim, randRange(3000, 10000));
						light.flashes = randRange(1, 3);
					} else {
						FunctionQueue(light.fq).runFuncAfter(turnOff, randRange(3000, 10000));
					}
				}
			}
			
			function dim():void {
				Utils.simpleFadeFx(light, "out", doneDim, 0.5 + (Math.random() * 2));				
			}
			
			function doneDim($g:GTween):void {
				turnOn();
			}
			
			turnOn();
		}
		
		/**
		 * Behaviours for the pageWin object
		 * 
		 * @param	$mc
		 */
		public static function pageWinBehaviour($mc:MovieClip):void {
			/*
			import flash.display.Bitmap;
			import flash.display.BitmapData;
			import flash.events.Event;
			import flash.geom.Vector3D;

			var fireworksBmp:Bitmap = new Bitmap(new BitmapData(this.width,this.height,true,0x00000000),"auto",false);
			addChildAt(fireworksBmp,1);
			var shootFireworks:Function = null;


			function enterFrameHandler(ev:Event):void
			{
				if (visible==false) return;
				//shoot(startP:Vector3D,vel:Vector3D,duration:int=30,burstLv:int=2,burstNum:int=30,burstVel:Number=20,damp:Number=1):void
				for (var i:int=0; i<10; i++)
				shootFireworks(	new Vector3D(fireworksBmp.width/2,fireworksBmp.height/2-30),
								Utils.randVector3D(20),
								60,	// lifetime
								0,	// burst lv
								30,	// burstNum
								20,	// burstVel
								1,	// damp
								0xFFFFFF);	// color
			}//endfunction

			function addedToStageHandler(ev:Event=null):void
			{
				trace("pageWin addedToStage handler");
				shootFireworks = Utils.fireworksFx(fireworksBmp,new Vector3D(0,0,0,0),50);
				addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			}
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			if (this.stage!=null)	addedToStageHandler();
			*/			
		}

		/**
		 * Creates a blurred bitmap from a target DisplayObject. 
		 * Bitmap and its bitmapdata must first be initialized to the desired dimensions
		 * Good for simple background blurs
		 * 
		 * @param	$toblur		The displayobject to replicate
		 * @param	$bitmap		$toblur will be drawn onto this bitmap and blurred
		 */
		public static function blur($toblur:DisplayObject, $bitmap:Bitmap, $fillcolor:uint = 0):void {
			$bitmap.bitmapData.unlock();
			$bitmap.bitmapData.fillRect($bitmap.bitmapData.rect, $fillcolor);
			$bitmap.bitmapData.draw($toblur);
			$bitmap.filters = [new BlurFilter(5, 5, BitmapFilterQuality.HIGH)];
			$bitmap.bitmapData.lock();
		}

		public static function replaceToken($original:String, ...args):String {
			var s:String = $original;
			for (var i:int = 0; i < args.length - 1; i += 2) {
				s = s.split(args[i].toString()).join(args[i + 1].toString());
			}
			return s;
		}
		
		public static function langMc($mc:MovieClip):void {
			if ($mc.currentLabels.some(function($o:Object, $i:int, $A:Array):Boolean { return $o.name == LANG; })) {
				$mc.gotoAndStop(LANG);
			} else {
				$mc.gotoAndStop(1);
			}
		}
		
		public static function alignChildren($mc:MovieClip):void {
			for (var n:int = 0; n < $mc.numChildren; n ++) {
				$mc.getChildAt(n).x = int($mc.getChildAt(n).x);
				$mc.getChildAt(n).y = int($mc.getChildAt(n).y);
			}
		}
		
		public static function loadLangXML($slotassets:SlotAssets, $online:Boolean, $ver:String, $callback:Function):void {
			// ----- loads in the game text copy -----------------------------------------
			var ldr:URLLoader = new URLLoader(new URLRequest((($online)? "": "../") + "../commons/xml/" + LANG + ".xml" + (($online)? "?v=" + int(Math.random() * 10000): "")));
			function xmlLoaded(event:Event):void 
			{ 
				$slotassets.xmlTxts = XML(ldr.data);
				ldr.removeEventListener(Event.COMPLETE, xmlLoaded);
				ldr = new URLLoader(new URLRequest("lang/" + LANG + ".xml" + (($online)? "?v=" + $ver: "")));
				ldr.addEventListener(Event.COMPLETE, xmlLoaded2);
			}//endfunction
			ldr.addEventListener(Event.COMPLETE, xmlLoaded); 
			
			function xmlLoaded2($e:Event):void {
				var l:XMLList = XML(ldr.data).children(), k:int = $slotassets.xmlTxts.children().length(), m:int;
				for (var i:int = 0; i < l.length(); i ++) {
					m = 0;
					while ((m < k) && (l[i].name() != $slotassets.xmlTxts.children()[m].name())) m ++;
					if (m < k) {
						for (var a:int = 0; a < l[i].attributes().length(); a ++) {
							$slotassets.xmlTxts.children()[m].@[l[i].attributes()[a].name()] = l[i].attributes()[a];
						}						
					} else {
						$slotassets.xmlTxts.appendChild(l[i]);
					}
				}
				$callback();
			}
		}
	}
}
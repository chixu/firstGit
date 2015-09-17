/* AS3
	Copyright 2014
*/

package {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Linear;
	import com.vtc.utils.FunctionQueue;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.Video;
	import flash.ui.Mouse;
	import com.vtc.text.setText;
	import flash.text.TextField;
	import com.vtc.text.fitText;
	import com.vtc.console.Console;
	import com.vtc.utils.randRange;
	import extra.Behaviours;
	
	/**
	 *	Bonus game 2 for Boxing
	 * 
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 11.4
	 * 
	 *	@author Koh Peng Chuan / Vista Technology Capital
	 *	@since 11 May 2015
	*/	
		
		
	public class BonusGame2 extends BonusPointAndClick {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------

		public static const SRC_SHOOTER_IDLE:String = "anims/bonus2/bonus2_shooteridle.swf";
		public static const SRC_SHOOTER_FIRE:String = "anims/bonus2/bonus2_shooterfire.swf";
		public static const SRC_IDLE:String = "anims/bonus2/bonus2_anim%0idle.swf";
		public static const SRC_FIRE:String = "anims/bonus2/bonus2_anim%0fire.swf";
		public static const SRC_DIE:String = "anims/bonus2/bonus2_anim%0die.swf";
		public static const SRC_ENDING:String = "anims/bonus2/bonus2_ending.swf";
		public static const SRC_RAIN:String = "anims/bonus2/bonus2_rain.swf";
		public static const SRC_RETICLE:String = "anims/bonus2/reticle.swf";
		public static const SRC_BLOOD:String = "anims/BloodSplatter.swf";

		private const SRC_SHOOT:String = "sounds/machinegun.mp3";
		private const SRC_ENEMYSHOOT:String = "sounds/gunshots.mp3";
		private const SRC_ENEMYDIE:String = "sounds/bonus2/bonus2_die.mp3";
		private const SRC_COMPLETE_SFX:String = "sounds/totalWinBGM.mp3";
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		private var _idle:Vector.<MovieClip>;
		private var _action:Vector.<MovieClip>;
		private var _die:Vector.<MovieClip>;
		private var _ending:MovieClip;
		private var _shooteridle:MovieClip;
		private var _shooterfire:MovieClip;
		private var _rain:MovieClip;
		private var _reticle:MovieClip;
		private var _blood:MovieClip;
		
		private var _buttoncontainer:Sprite;
		private var _showAmt:Number = 0;
		private var _showInc:Number;
		private var _doneDelay:int = 100;
		private var _cid:int;
		private var _totalwin:Number;
		private var _counttween:GTween;
		private var _kill:Boolean;
		
		private var _fq:FunctionQueue;
		
		//--------------------------------------
		//  PUBLIC VARIABLES
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 * Constructor
		 */
		public function BonusGame2($mc:MovieClip):void {
			super($mc, 1,
				$mc["mark0"] as MovieClip, 
				$mc["mark1"] as MovieClip, 
				$mc["mark2"] as MovieClip, 
				$mc["mark3"] as MovieClip, 
				$mc["mark4"] as MovieClip);
			
			_idle = new Vector.<MovieClip>;
			_action = new Vector.<MovieClip>;
			_die = new Vector.<MovieClip>;
			for (var b:int = 0; b < _buttons.length; b ++) {
				buttonCallbacks(b, buttonSuccess, buttonFailure, buttonOver, b);				
				_idle[b] = null;
				_action[b] = null;
				_die[b] = null;
			}
			_clicksallowed = 3;
			_fq = new FunctionQueue();
			
			onComplete(gameComplete);
		}
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function buttonSuccess($id:int, $playsound:Boolean = true, $anim:Boolean = true):void {			
			_cid = $id;
			_kill = true;
			_buttons[$id].visible = false;
			//stopIdlePlays();
			if ($anim) {
				if (_shooterfire) {
					animLoaded(_shooterfire, "shooterfire", $id);
				} else {
					loadMovie(SRC_SHOOTER_FIRE, animLoaded, "shooterfire", $id);
				}
			} else {
				if (_die[$id]) {
					animLoaded(_die[$id], "die", $id);
				} else {
					loadMovie(Behaviours.replaceToken(SRC_DIE, "%0", $id.toString()), animLoaded, "die", $id);
				}
			}
			if ($playsound) playSound(SRC_ENEMYDIE);
		}
		
		/*private function doneSuccess($clicked:int, $id:int):void {
			showAmount($clicked, $id, winAmount);			
			resetClick();
		}*/
		
		private function buttonFailure($id:int, $playsound:Boolean = true, $anim:Boolean = true):void {
			_buttons[$id].visible = false;
			_kill = false;
			//stopIdlePlays();
			if ($anim) {
				if (_shooterfire) {
					animLoaded(_shooterfire, "shooterfire", $id);
				} else {
					loadMovie(SRC_SHOOTER_FIRE, animLoaded, "shooterfire", $id);
				}
			} else {
				if (_action[$id]) {
					animLoaded(_action[$id], "fire", $id);
				} else {
					loadMovie(Behaviours.replaceToken(SRC_FIRE, "%0", $id.toString()), animLoaded, "fire", $id);
				}						
			}
			if ($playsound) playSound(SRC_ENEMYSHOOT);
		}
		
		private function buttonOver($over:Boolean, $id:int):void {
			if (allowClick) {
				stopIdlePlays();
				if (_idle[$id].visible) {
					if ($over) {
						_idle[$id].play();
						if (_reticle) _reticle.gotoAndPlay(2);
					} else {
						if (_reticle) _reticle.gotoAndStop(1);
					}
				}
			}
		}
		
		/**
		 * Triggered when the last button is clicked. This will be triggered before the done animations in the gameStep loop is performed.
		 */
		private function gameComplete():void {
			trace("running gameComplete()");
			if (mc["pageWin"]) {
				if (_blood) {
					animLoaded(_blood, "blood", -1);
				} else {
					loadMovie(SRC_BLOOD, animLoaded, "blood", -1);
				}
				mc.addChild(mc["pageWin"]);
				Utils.simpleFadeFx(mc["pageWin"], "in", null, 0.5);
				mc["pageWin"].visible = true;
			}
			_showAmt = 0;
			playSound(SRC_COMPLETE_SFX, true);			
			_showInc = _totalwin / 60;
			winAmount = _totalwin;
		}
		
		private function readyToPlay():void {
			for (var b:int = 0; b < _buttons.length; b ++) {
				_buttons[b].visible = true;
			}
			
			// check if there's anything to restore
			if (playHistory && (playHistory.length > 0)) {
				var ps:Boolean = true; // plays only 1 selection sound
				for (var p:int = 0; p < playHistory.length; p ++) {
					winAmount = playHistory[p].val;
					if (winAmount > 0) {
						buttonSuccess(playHistory[p].selected, ps, false);
						ps = false;
					} else {
						buttonFailure(playHistory[p].selected, false, false);
					}
				}
			}

		}

		private function animLoaded($mc:MovieClip, $ident:String, $id:int):void {
			smoothAllVideo($mc);
			$mc.gotoAndStop(1);
			$mc.tabEnabled = false;
			$mc.mouseEnabled = false;
			$mc.mouseChildren = false;
			switch ($ident) {
				case "shooteridle":
					_shooteridle = $mc;
					mc.addChild($mc);
					$mc.play();
					break;
				case "shooterfire":
					_shooterfire = $mc;
					mc.addChild($mc);
					$mc.visible = true;
					_shooteridle.visible = false;
					_shooteridle.stop();
					Utils.playOnceAndStop($mc, 0, shooterFireDone, $id);
					playSound(SRC_SHOOT);
					trace("shot success = " + _kill);
					if (_kill) {
						if (_die[$id]) {
							animLoaded(_die[$id], "die", $id);
						} else {
							loadMovie(Behaviours.replaceToken(SRC_DIE, "%0", $id.toString()), animLoaded, "die", $id);
						}
					} else {
						if (_action[$id]) {
							animLoaded(_action[$id], "fire", $id);
						} else {
							loadMovie(Behaviours.replaceToken(SRC_FIRE, "%0", $id.toString()), animLoaded, "fire", $id);
						}						
					}
					break;
				case "idle":
					_idle[$id] = $mc;
					mc.addChild($mc);
					if (_rain) mc.addChild(_rain);
					break;
				case "fire":
					_action[$id] = $mc;
					mc.addChild($mc);
					$mc.visible = true;
					_idle[$id].visible = false;
					Utils.playOnceAndStop($mc, 0, animDone, $id, false);
					if (_rain) mc.addChild(_rain);
					if (_shooterfire) mc.addChild(_shooterfire);
					showAmount(_alreadyclicked, $id, 0);
					break;
				case "die":
					_die[$id] = $mc;
					mc.addChild($mc);
					$mc.visible = true;
					_idle[$id].visible = false;
					Utils.playOnceAndStop($mc, 0, animDone, $id, true);
					if (_rain) mc.addChild(_rain);
					if (_shooterfire) mc.addChild(_shooterfire);
					if (playHistory && (_alreadyclicked < playHistory.length)) {
						showAmount(_alreadyclicked, $id, playHistory[_alreadyclicked].val);
					} else {
						showAmount(_alreadyclicked, $id, winAmount);
					}
					break;
				case "ending":
					Mouse.show();
					if (_reticle.visible) {
						_reticle.visible = false;
						_ending = $mc;
						mc.addChild($mc);
						$mc.visible = true;
						Utils.playOnceAndStop($mc);
						resetClick();
						if (_rain) {
							_rain.visible = false;
							_rain.stop();
						}
					}
					break;
				case "rain":
					_rain = $mc;
					$mc.visible = true;
					$mc.play();
					mc.addChild($mc);
					if (_shooteridle) mc.addChild(_shooteridle);
					break;
				case "reticle":
					if (!_reticle) {
						_reticle = $mc;
						_reticle.addEventListener(Event.ENTER_FRAME, followMouse);
					}
					_reticle.visible = true;
					Mouse.hide();
					mc.addChild(_reticle);
					break;
				case "blood":
					_blood = $mc;
					mc.addChild($mc);
					mc.addChild(mc["pageWin"]);
					$mc.x = mc["pageWin"].x;
					$mc.y = mc["pageWin"].y;
					Utils.playOnceAndStop($mc);
					$mc.visible = true;
					break;
			}
		}
		
		private function shooterFireDone($id:int):void {
			_shooterfire.visible = false;
			_shooteridle.visible = true;
			_shooteridle.play();
		}
		
		private function animDone($id:int, $success:Boolean):void {
			if (!$success) {
				if (_action[$id]) _action[$id].visible = false;
				_idle[$id].visible = true;
			} else {
				_idle[$id].visible = false;
			}
			if (_alreadyclicked >= _clicksallowed - 1) {
				_fq.runFuncAfter(doEnding, 2000);
			} else {
				resetClick();
			}
		}
		
		private function doEnding():void {
			if (_ending) 
				animLoaded(_ending, "ending", -1);
			else 
				loadMovie(SRC_ENDING, animLoaded, "ending", -1);
		}
		
		private function followMouse($e:Event):void {
			if ((mc) && (mc.stage)) {
				_reticle.x = mc.mouseX;
				_reticle.y = mc.mouseY;
				mc.addChild(_reticle);
			}
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------		
		
		override protected function initGame():void {
			super.initGame();
			if (!_buttoncontainer) {
				_buttoncontainer = new Sprite();
				mc.addChild(_buttoncontainer);
			}
			_doneDelay = 100;
			_totalwin = 0;
			_showAmt = 0;
			
			if (mc["pageWin"]) {
				mc["pageWin"]["bg"].visible = false;
				mc["pageWin"].visible = false;
				Utils.applyFontTo(mc["pageWin"]["textTf"] as TextField, Boxing.NUMBER_FONT.fontName);
				setText(mc["pageWin"]["titleTf"] as TextField, slotAssets.xmlTxts.game.@labtablewin, "", Boolean(Boxing.DEFAULT_FONT != null), (Boxing.DEFAULT_FONT)? Boxing.DEFAULT_FONT.fontName: "");
			}
			
			for (var a:int = 0; a < _clicksallowed; a ++) {
				if (mc["amt" + a]) {
					mc["amt" + a].mouseEnabled = false;
					mc["amt" + a].visible = false;
					Utils.applyFontTo(mc["amt" + a]["tf"] as TextField, Boxing.NUMBER_FONT.fontName);
				}
			}
			if (_blood) {
				_blood.visible = false;
			}
			
			if (_shooteridle) {
				mc.addChild(_shooteridle);
				_shooteridle.visible = true;
			} else {
				loadMovie(SRC_SHOOTER_IDLE, animLoaded, "shooteridle", -1);
			}
			if (_shooterfire) _shooterfire.visible = false;
			if (_ending) _ending.visible = false;
			
			for (var b:int = 0; b < _buttons.length; b ++) {
				_buttons[b].visible = false;
				_buttons[b].alpha = 0;
				mc.addChild(_buttons[b]);
				mc["mark" + b].visible = false;
				if (!_idle[b]) loadMovie(Behaviours.replaceToken(SRC_IDLE, "%0", b.toString()), animLoaded, "idle", b) else {
					_idle[b].visible = true;
				}
				if (_action[b]) _action[b].visible = false;
				if (_die[b]) _die[b].visible = false;
			}
			stopIdlePlays();
			
			if (_rain) {
				_rain.visible = true;
				_rain.play();
			} else {
				loadMovie(SRC_RAIN, animLoaded, "rain", -1);
			}
			
			//var f:String = (Boxing.DEFAULT_FONT)? Boxing.DEFAULT_FONT.fontName: "";
			//Utils.applyFontTo(mc["hinttf"] as TextField, f);
			//Utils.setSimpleText(mc["hinttf"] as TextField, slotAssets.xmlTxts.bonus2.@hint1);
			//mc["hinttf"].visible = true;
			
			if (mc["titlemc"]) {
				Behaviours.langMc(mc["titlemc"] as MovieClip);
			}
			
			if (!_reticle) {
				loadMovie(SRC_RETICLE, animLoaded, "reticle", -1);
			} else {
				animLoaded(_reticle, "reticle", -1);
			}
			
			delayCall(readyToPlay, 40);						
		}
		
		override protected function updateWinnings(xml:XML):void {
			super.updateWinnings(xml);
		}
		
		override protected function gameStep():void {
			//super.gameStep();
			if (_done) {
				_showAmt = Math.min(_totalwin, _showAmt + _showInc);
				if (mc["pageWin"]) {
					//mc["pageWin"].visible = true;
					//mc["pageWin"].alpha = Math.min(1, mc["pageWin"].alpha + 0.05);					
					mc["pageWin"].textTf.text = Utils.comma3(_showAmt);
				}
				_doneDelay--;
				if (_doneDelay < 0) finish = true;
			}
		}
		
		private function showAmount($click:int, $id:int, $val:Number):void {
			var i:int = 0;
			while (mc["amt" + i].visible) i ++;
			if ($val > 0) {
				setText(mc["amt" + i].tf as TextField, $val.toFixed(2), "", true, Boxing.NUMBER_FONT.fontName);
				TextField(mc["amt" + i].tf).textColor = 0xFFFF00;
				_totalwin += $val;
			} else {
				setText(mc["amt" + i].tf as TextField, slotAssets.xmlTxts.bonus2.@miss, "", true, (Boxing.DEFAULT_FONT != undefined)? Boxing.DEFAULT_FONT.fontName: "");
				TextField(mc["amt" + i].tf).textColor = 0xFF0000;
			}
			mc.addChild(mc["amt" + i]);			
			mc["amt" + i].visible = true;
			mc["amt" + i].x = int(mc["mark" + $id].x + (mc["mark" + $id].width * 0.5));
			mc["amt" + i].y = int(mc["mark" + $id].y + mc["amt" + i].height);
			Utils.simpleFadeFx(mc["amt" + i], "in", null, 1.0);
		}
		
		private function stopIdlePlays():void {
			for (var i:int = 0; i < _idle.length; i ++) {
				if (_idle[i]) _idle[i].stop();
			}
		}
		
		/**
		 * Destructor
		 */
		override public function dispose():void {
			if (_buttoncontainer) {
				while (_buttoncontainer.numChildren > 0) _buttoncontainer.removeChildAt(0);
				if (_buttoncontainer.parent) _buttoncontainer.parent.removeChild(_buttoncontainer);
				_buttoncontainer = null;
			}
			_idle.length = 0;
			_action.length = 0;
			_die.length = 0;
			_idle = null;
			_action = null;
			_die = null;
			super.dispose();
		}
	}
}
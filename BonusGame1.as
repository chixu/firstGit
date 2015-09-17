/* AS3
	Copyright 2014
*/

package {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.Linear;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 *	Bonus game 2 for GoldenEggs
	 * 
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 11.4
	 * 
	 *	@author Koh Peng Chuan / Vista Technology Capital
	 *	@since 11 May 2015
	*/	
	
		
	public class BonusGame1 extends BonusGameBase {
		
		public static const NUM_CARD:int = 5;
		
		private var _cards:Vector.<Card>;

		private var _btnCollect:SimpleButton;
		private var _btnHalf:SimpleButton;
		private var _btnDouble:SimpleButton;
		private var _btnCollectDis:MovieClip;
		private var _btnHalfDis:MovieClip;
		private var _btnDoubleDis:MovieClip;
		private var _txtBet:TextField;
		private var _txtBank:TextField;
		private var _txtDoubleHalf:TextField;
		private var _txtDouble:TextField;
		private var _playAmount:Number;			//record the win amount at the beginning of the bonus game.	
		private var _isBetDoubleHalf:Boolean;
		private var _hasWon:Boolean;
		/**
		 * @param	m = mc
		 * @usage	controller for BonusGame1 mc
		 */
		public function BonusGame1(m:MovieClip):void
		{
			mc = m;
			_cards = new Vector.<Card>();
			_cards.push(new Card(m.Card1, m.Card1Ani, true));
			_cards.push(new Card(m.Card2, m.Card2Ani));
			_cards.push(new Card(m.Card3, m.Card3Ani));
			_cards.push(new Card(m.Card4, m.Card4Ani));
			_cards.push(new Card(m.Card5, m.Card5Ani));
			for (var i:int = 1; i < NUM_CARD; i++)
			{
				_cards[i].cardIndex = i;
				_cards[i].game = this;
				for (var j:int = 1; j < NUM_CARD; j++)
				{
					if(i!=j)_cards[i].restCards.push(_cards[j]);
				}
			}
			_btnCollect = m.btnCollect;
			_btnHalf = m.btnHalf;
			_btnDouble = m.btnDouble;
			_btnCollectDis = m.BtnGetDis;
			_btnHalfDis = m.BtnHalfDis;
			_btnDoubleDis = m.BtnDoubleDis;
			_txtBet = m.TxtBet;
			_txtBank = m.TxtBank;
			_txtDouble = m.TxtDouble;
			_txtDoubleHalf = m.TxtHalf;			
			
			_btnCollect.addEventListener(MouseEvent.CLICK, onCollectClick);
			_btnHalf.addEventListener(MouseEvent.CLICK, onHalfClick);
			_btnDouble.addEventListener(MouseEvent.CLICK, onDoubleClick);
			//initGame();
		}
		
		private function onCollectClick(e:MouseEvent)
		{
			setButtonsEnabled(false);
			var reqStr:String = gameAPIUrl + "bonusgame?key=" + userKey + "&bonus=" + bonusKey + "&step="+(bonusStep++)+"&param=0";
			trace(reqStr);
			var callback:Function = function(xml:XML):void
			{
				//for (var i:int = 0; i < NUM_CARD; i++)
				//{
					//_cards[i].removeListeners();
				//}
				//mc.parent.removeChild(mc);	
				winAmount = parseFloat(xml.win);
				finish = true;
			}
			asyncSendReq(reqStr, callback);
		}
		
		private function onHalfClick(e:MouseEvent)
		{
			_isBetDoubleHalf = true;
			setButtonsEnabled(false);
			var reqStr:String = gameAPIUrl + "bonusgame?key=" + userKey + "&bonus=" + bonusKey + "&step="+(bonusStep++)+"&param=1";
			trace(reqStr);
			asyncSendReq(reqStr, bonusRequestHandler);
		}		
		
		
		
		private function onDoubleClick(e:MouseEvent)
		{
			_isBetDoubleHalf = false;
			setButtonsEnabled(false);
			var reqStr:String = gameAPIUrl + "bonusgame?key=" + userKey + "&bonus=" + bonusKey + "&step="+(bonusStep++)+"&param=2";
			trace(reqStr);
			asyncSendReq(reqStr, bonusRequestHandler);
		}
		
		/*
		 * calls after player click the half/double button
		 * */
		protected function bonusRequestHandler(xml:XML=null)
		{
			trace("bonusRequestHandler");
			var suit:int = parseInt(xml.data.wheels.item[0].@suit);
			var idx:int = parseInt(xml.data.wheels.item[0]);
			_cards[0].suit = suit; _cards[0].cardValue = idx;
			_cards[0].animationCallback = function() { setCardsEnabled(true); };
			_cards[0].flip();
			updateTextFields();
		}
		
		/*
		 * enable cards to click
		 * */
		private function setCardsEnabled(b:Boolean):void
		{
			for (var i:int = 1; i < NUM_CARD; i++)
			{
				_cards[i].enabled = b;
			}
		}
		
		/**
		 * this bonus game specific initialization
		 */
		protected override function initGame():void
		{
			trace(_cards);
			for (var i:int = 0; i < NUM_CARD; i++)
			{
				_cards[i].init();
				//_cards[i].enabled = false;
			}
			
			setButtonsEnabled(true);
			_hasWon = false;
		}

		
		/*
		 * update text fields according to the received xml
		 * */
		override protected function updateWinnings(xml:XML):void 
		{
			_playAmount = parseFloat(xml.data.@gamewin);
			
			updateTextFields();
		}
		
		protected function updateTextFields():void 
		{
			if (bonusStep == 1)
			{
				_txtBet.text = "";
				_txtBank.text = _playAmount.toString();
				//if the playAmount is 0.75
				//on ui it will show 0.38 
				_txtDoubleHalf.text = (Math.ceil(_playAmount*150)/100).toString();
				_txtDouble.text = (_playAmount*2).toString();
			}
			else
			{
				if (_isBetDoubleHalf)
				{
					_txtBet.text = _txtBank.text = (Math.ceil(_playAmount*50)/100).toString();
					//if the playAmount is 0.75
					//on ui it will show 0.38 
					_txtDoubleHalf.text = (Math.ceil(_playAmount*150)/100).toString();
					_txtDouble.text = "";
				}
				else
				{
					_txtBet.text = _playAmount.toString();
					_txtBank.text = "0";
					//if the playAmount is 0.75
					//on ui it will show 0.38 
					_txtDoubleHalf.text = "";
					_txtDouble.text = (_playAmount*2).toString();
				}
			}
		}
		
		
		/*
		 * enable or disable the bottom 3 buttons
		 * */
		private function setButtonsEnabled(b:Boolean):void
		{
			_btnCollect.visible = _btnDouble.visible = _btnHalf.visible = b;
			_btnCollectDis.visible = _btnDoubleDis.visible = _btnHalfDis.visible = !b;
			
		}
		
		/*
		 * called when any of the player card is clicked
		 * the clicked the card will be revealed first, followed by the first one, second one and so on.
		 * */
		public function flipAllCards(firstCard:Card):void
		{	
			setCardsEnabled(false);
			var reqStr:String = gameAPIUrl + "bonusgame?key=" + userKey + "&bonus=" + bonusKey + "&step=" + bonusStep + "&param=" + firstCard.cardIndex;	
			bonusStep = 1;
			asyncSendReq(reqStr, function(xml:XML)
			{	
				var gameWin:Number = parseFloat(xml.win);	
				winAmount = parseFloat(xml.win);
				for (var i:int = 1; i < NUM_CARD; i++)
				{
					var suit:int = parseInt(xml.data.wheels.item[i].@suit);
					var idx:int = parseInt(xml.data.wheels.item[i]);
					_cards[i].suit = suit; 
					_cards[i].cardValue = idx;
				}
				var numCardsToFlip :int = BonusGame1.NUM_CARD - 2;
				//callback will run after all the cards are flipped
				var cb:Function = function(callback:Function)
				{
					trace("cb callback" , numCardsToFlip);
					numCardsToFlip --;
					if (numCardsToFlip < 0)
					{	if(callback)callback();}
					else
					{
						var cardToFlip:Card = firstCard.restCards[BonusGame1.NUM_CARD - 3 - numCardsToFlip];
						cardToFlip.animationCallback = function() { cb(callback); };
						cardToFlip.flip();
					}
				}
				firstCard.animationCallback = function() { cb(function() { delayCall(function() { checkFinished(xml.data.wheels.@finish);} , 100); } ); };
				firstCard.flip();
			});
		}
		
		private function checkFinished(f:String)
		{
			if (f == "1")
			{
				finish = true;				
			}
			else
			{
				_playAmount = _isBetDoubleHalf?Math.ceil(_playAmount * 150) / 100:_playAmount * 2;
				updateTextFields();
				initGame();
			}
		}
		
	}	
	
}

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

class CardSuit
{
	public static const HEART:int = 1;
	public static const DIAMOND:int = 2;
	public static const CLUB:int = 3;
	public static const SPADE:int = 4;
}

class Card extends MovieClip {
	
		public var restCards:Vector.<Card>;
		public var anim:MovieClip;
		//private var _btn:SimpleButton;
		private var _ani:MovieClip;
		private var _allCards:MovieClip;
		private var _enabled:Boolean = false;
		public var isDealer:Boolean;
		public var animationCallback:Function;
		public var suit:int ;
		public var cardValue:int;
		public var cardIndex:int;
		public var game:BonusGame1;
		
		public function Card(allCards:MovieClip, ani:MovieClip, isd:Boolean = false):void
		{
			_ani = ani;
			_allCards = allCards;			
			isDealer = isd;
			//_btn = _allCards.btn;
			restCards = new Vector.<Card>();
			init();
		}
		
		public function init():void
		{
			_allCards.gotoAndStop(1);
			_ani.gotoAndStop(1);
			_allCards.visible = true;
			_ani.visible = false;
			enabled = false;
			if(!isDealer)_allCards.btn.addEventListener(MouseEvent.CLICK, onMouseClicked);
		}
		
		private function onAniEnterFrame(e:Event) :void
		{
			if (_ani.currentFrame == _ani.totalFrames)
			{
				_ani.stop();
				_ani.removeEventListener(Event.ENTER_FRAME, onAniEnterFrame);
				showCard();
				if (animationCallback) animationCallback();
			}
		}
		
		private function onMouseClicked(e:MouseEvent) :void
		{
			trace("card clicked");
			if (!isDealer)
			{
				game.flipAllCards(this);
			}
		}
		
		
		public function removeListeners():void
		{
			
		}
		
		
		override public function  set enabled(b:Boolean):void
		{
			_enabled = b;
			if (!isDealer)
			{	
				_allCards.btn.mouseEnabled = b;
			}
		}
		
		override public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/*
		 * play the flipping animation
		 * call the animationCallback after played.
		 * */
		public function flip():void
		{
			_allCards.visible = false;
			_ani.visible = true;
			_ani.gotoAndPlay(1);
			_ani.addEventListener(Event.ENTER_FRAME, onAniEnterFrame);
		}
		
		/*
		 * display the correct card according to the suit and cardvalue
		 * e.g. suit = 1 cardvalue = 13, it will display heart of king.
		 * */
		public function showCard():void
		{
			_allCards.visible = true;			
			_ani.visible = false;
			var suitModifier:int;
			if (suit == CardSuit.CLUB) suitModifier = 0;
			else if (suit == CardSuit.DIAMOND) suitModifier = 1;
			else if (suit == CardSuit.HEART) suitModifier = 2;
			else suitModifier = 3;
			_allCards.gotoAndStop(suitModifier*13+cardValue);
		}
	}
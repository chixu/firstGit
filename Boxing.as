package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.media.Video;
	import extra.Behaviours;
	import com.vtc.text.setText;
	
	import flash.events.MouseEvent;
	//import com.vtc.console.Console;
	
	import com.vtc.utils.SimpleEventDispatcher;

	public class Boxing extends MovieClip
	{
		public static const VERSION:String = "112";
		
		private static const GAME_WIDTH:int = 1024;
		private static const GAME_HEIGHT:int = 768;
		
		private static const GAMENAME:String = "boxing";
		
		private static const FORCED_LANG:String = ""; // use "" for deployment
		
		
		public static var NUMBER_FONT:Font;
		public static var DEFAULT_FONT:Font;
		public static var LANG_FONT:Font;
		public static var GAME_FONT:String;
		
		private static var LANG_SPECIFIC_FONTS:Array = ["en", "id", "cs", "jp"]; // specify if a language has any specific font to load
		private static var STATIC_LOGO:Array = ["jp", "cs"];
		
		private var bg:MovieClip;
		private var hudflvs:Object;
		private var _lang:String;
		private var _rain:MovieClip;
		
		private var _slotassets:SlotAssets;
		private var _slotscommons:SlotCommons;

		/*private var _mainGameAssets:Vector.<String> = Vector.<String>([
														"anims/CarAnim.swf",
														"anims/slotfire.swf",
														"anims/AvatarHide1.swf",
														"anims/AvatarHide2.swf",
														"anims/AvatarHide3.swf",
														BonusGame1.SRC_BG,
														"anims/bonus1/bonus1_item0.swf",
														"anims/bonus1/bonus1_item1.swf",
														"anims/bonus1/bonus1_item2.swf",
														"anims/bonus1/bonus1_item3.swf",
														"anims/bonus2/bonus2_anim0idle.swf",
														"anims/bonus2/bonus2_anim1idle.swf",
														"anims/bonus2/bonus2_anim2idle.swf",
														"anims/bonus2/bonus2_anim3idle.swf",
														"anims/bonus2/bonus2_anim4idle.swf",
														BonusGame2.SRC_SHOOTER_IDLE
														]);*/
														
														
		private var _mainGameAssets:Vector.<String> = Vector.<String>([
														"anims/hud_fg.swf",
														"anims/hud_bg.swf",
														"anims/AvatarIdle.swf",
														"anims/AvatarIdle1.swf",
														"anims/AvatarIdle2.swf",
														"anims/AvatarWin1.swf",
														"anims/AvatarWin2.swf"
														]);
														
		private var _bonusGameAssets:Vector.<String>;
		
		private var _assetQueue:Vector.<String>;
		
		private var _cprog:int;
		
		private var _inscatter:Boolean = false;
		
		private var _hide:Vector.<MovieClip>;
		
		//=======================================================================================
		//
		//=======================================================================================
		public function Boxing():void
		{
			super();
			SlotCommons.defaultFunplay = true;
			SlotCommons.payLineDisplayRight = false;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			Behaviours.SED = SimpleEventDispatcher.instance;
		}//endconstr
		
		private function isOnline():Boolean {
			var sVars:Array = stage.loaderInfo.loaderURL.split("/");
			for (var i:int = 0; i < sVars.length; i ++) {
				switch (sVars[i]) {
					case "file:": return false;
					// case"subdomain.domain.com": return sVars[i];
				}
			}
			return true;
		}
		
		//=======================================================================================
		//
		//=======================================================================================
		
		private function addedToStage(ev:Event):void
		{
			//Console.instance.init(stage);
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			if (isOnline()) Utils.loadFilesVer = VERSION;
			stage.scaleMode = StageScaleMode.SHOW_ALL; // need to set to SHOW_ALL to display a 4:3 resolution on a wide screen. otherwise the top and bottom will be cropped if NO_BORDER is used since flash will try to stretch the image to the edges.
			_lang = (FORCED_LANG != "")? FORCED_LANG.toLowerCase(): getLanguage();
			Behaviours.LANG = _lang;
			//_mainGameAssets.push("anims/symbol10Expanding" + useLangVariant() + ".swf");
			loadAssets(_lang);
			//Console.instance.echo("language = " + lang);
			if (preload["titlemc"]) preload["titlemc"].gotoAndStop(_lang.toLowerCase());
			scrollRect = new Rectangle(0, 0, GAME_WIDTH, GAME_HEIGHT);
		}//endfunction
		
		//=======================================================================================
		// loads common game assets and language specific game assets
		//=======================================================================================
		
		private function queueAsset($url:String):void {
			if (!_assetQueue) {
				_assetQueue = new Vector.<String>;
				_cprog = 0;
			}
			_assetQueue.push($url);
		}
		
		private function processLoadQueue($mc:MovieClip = null):void {
			
			if (_assetQueue && (_assetQueue.length > 0)) {
				var sprog:int = _cprog;
				var mga:int = ((_mainGameAssets)? _mainGameAssets.length: 0);
				_cprog = sprog + int((100 - sprog) / (_assetQueue.length + mga));
				trace(_assetQueue[0]);
				var a:String = _assetQueue.shift();
				Utils.loadFromURL(a, preload, processLoadQueue, sprog, _cprog);
			} else {				
				_assetQueue = null;
				_slotassets = new SlotAssets(GAME_WIDTH, GAME_HEIGHT);
				//_slotscommons = new SlotCommons(_slotassets, "", "", true);
				preloadAsset();
			}
		}
		
		private function loadAssets(lang:String="en"):void
		{
			trace("Language = " + lang);			
			//preload.scaleX = stage.stageWidth / preload.width;
			//preload.scaleY = stage.stageHeight / preload.height;
			
			queueAsset("fonts/basefont.swf");
			var l:String = lang.toLowerCase();
			if (LANG_SPECIFIC_FONTS.indexOf(l) >= 0) queueAsset("fonts/" + l + ".swf");
			queueAsset("GameAssets.swf");
			queueAsset("lang/" + l + ".swf");
			processLoadQueue();
		}//endfunction
		
		private function preloadAsset():void {
			
			if (_mainGameAssets && (_mainGameAssets.length > 0)) {
				var a:String = _mainGameAssets.shift();
				Utils.loadMovie(a, assetPreloadStarted);
			} else {
				_mainGameAssets = null;
				Behaviours.loadLangXML(_slotassets, isOnline(), VERSION, doneXMLLoading);
			}
		}
		
		private function doneXMLLoading():void {
			initSlotGame(_lang);			
		}
		
		private function assetPreloadStarted($mc:MovieClip):void {
			$mc.gotoAndStop(1);
			/*for (var n:int = 0; n < $mc.numChildren; n ++) {
				if ($mc.getChildAt(n) is MovieClip) MovieClip($mc.getChildAt(n)).stop();
			}*/
			var sprog:int = _cprog;
			var mga:int = ((_mainGameAssets)? _mainGameAssets.length: 0);
			_cprog = sprog + int((100 - sprog) / (mga + 1));
			//trace(sprog + " - " + _cprog + ", " + (mga + 1));
			Utils.preload($mc.loaderInfo, preload, preloadAsset, sprog, _cprog);
		}
		
		
		//=======================================================================================
		//
		//=======================================================================================
		private function applyFontEmbedding($tf:TextField, $fontName:String = ""):void {
			if($tf==null)return;
			var ttf:TextFormat = $tf.defaultTextFormat;
			$tf.embedFonts = Boolean((DEFAULT_FONT != null) || ($fontName != ""));
			if ($fontName != "") {
				ttf.font = $fontName;
			} else {
				if (DEFAULT_FONT) {
					ttf.font = DEFAULT_FONT.fontName;
					if (DEFAULT_FONT.fontStyle == "bold") ttf.bold = true;
				} else {
					ttf.font = "_sans";
				}
			}
			switch (_lang) {
				case "en":
				case "id":
				case "cs":
				case "kr":
				case "vn": 
					break;
				case "kh": 
					if (!$tf.embedFonts) {
						ttf.size = Number(ttf.size) + 4;
						$tf.y -= Number(ttf.size) * 0.3;
					}
					break;
				case "th":
					if (!$tf.embedFonts) {
						ttf.size = Number(ttf.size) + 3;
						//$tf.y += Number(ttf.size) * 0.3;
					}
					break;
			}
			$tf.defaultTextFormat = ttf;
			$tf.setTextFormat(ttf);
			$tf.autoSize = "center";
			$tf.wordWrap = true;
			$tf.antiAliasType = "normal";
			$tf.mouseEnabled = false;
			$tf.tabEnabled = false;
			$tf.x = int($tf.x);
			$tf.y = int($tf.y);
		}
			

		private function initSlotGame(lang:String="en"):void
		{
			//_lang = lang;
			trace("initSlotGame("+lang+")");
			
			var slotAssets:SlotAssets = _slotassets;
			
			slotAssets.lang = lang;	// pass language identifier in
			NUMBER_FONT = Utils.loadFont("NumberFont");
			DEFAULT_FONT = Utils.loadFont("GameFont");
			LANG_FONT = Utils.loadFont("LangFont"); // load language specific font
			if (LANG_FONT == null) {
				LANG_FONT = DEFAULT_FONT;
			} else {
				if (DEFAULT_FONT == null) DEFAULT_FONT = LANG_FONT; // not very likely, but just in case
			}
			GAME_FONT = (LANG_FONT)? LANG_FONT.fontName: "";
			
			trace("DEFAULT_FONT = " + (DEFAULT_FONT == null)? "na": DEFAULT_FONT.fontName);
			trace("NUMBER_FONT = " + NUMBER_FONT.fontName);
			trace("LANG_FONT = " + ((LANG_FONT == null)? "na": LANG_FONT.fontName));
			trace("GAME_FONT = " + GAME_FONT);
			
			//GAME_FONT = Utils.loadFont("LangFont").fontName;

			// ----- specify the main sprite ---------------------------------------------
			var clsDef:Class = Class(getDefinitionByName("Main"));
			var main:MovieClip = new clsDef();
			slotAssets.mainSprite = main;
			addChild(slotAssets.mainSprite);
			slotAssets.mainSprite.scaleX = stage.stageWidth / GAME_WIDTH; // slotAssets.mainSprite.width;
			slotAssets.mainSprite.scaleY = stage.stageHeight / GAME_HEIGHT; // slotAssets.mainSprite.height;
			slotAssets.mainSprite.visible = false;
			
			// ----- specify symbol animations -------------------------------------------
			slotAssets.reelsSprite = main.reels;
			slotAssets.symbolAnimURLs =Vector.<String>(["anims/symbol0Ani.swf",
														"anims/symbol1Ani.swf",
														"anims/symbol2Ani.swf",
														"anims/symbol3Ani.swf",
														"anims/symbol4Ani.swf",
														"anims/symbol5Ani.swf",
														"anims/symbol6Ani.swf",
														"anims/symbol7Ani.swf",
														"anims/symbol8Ani.swf",
														"anims/symbol9Ani.swf",
														"anims/symbol10Ani.swf",
														"anims/symbol11Ani.swf",
														"anims/symbol12Ani.swf"]);
			clsDef = Class(getDefinitionByName("BoxLineWin"));
			slotAssets.lineWinBox = new clsDef();
			applyFontEmbedding(slotAssets.lineWinBox.tf, NUMBER_FONT.fontName);
			clsDef = Class(getDefinitionByName("BoxLineMul"));
			slotAssets.lineMulBox = new clsDef();
			applyFontEmbedding(slotAssets.lineMulBox.tf, NUMBER_FONT.fontName);
			clsDef = Class(getDefinitionByName("PageWin"));
			slotAssets.pageWin = new clsDef();
			applyFontEmbedding(slotAssets.pageWin.textTf as TextField, NUMBER_FONT.fontName);
			Behaviours.pageWinBehaviour(slotAssets.pageWin as MovieClip);
			
			slotAssets.createCheatBar(Vector.<String>(["Small Win", "Big Win", "Free Spin", "Bonus 1", "Bonus 2"]), GAME_WIDTH);
			
			// ----- declare Avatar anims to play with -----------------------------------
			slotAssets.avatarSprite = new Sprite();
			slotAssets.avatarSprite.mouseEnabled = false;
			slotAssets.avatarSprite.mouseChildren = false;
			slotAssets.avatarIdleURLs = Vector.<String>(["anims/AvatarIdle.swf","anims/AvatarIdle1.swf","anims/AvatarIdle.swf","anims/AvatarIdle.swf","anims/AvatarIdle2.swf"]);
			slotAssets.avatarWinURLs = Vector.<String>(["anims/AvatarWin1.swf","anims/AvatarWin2.swf"]);
			slotAssets.avatarLoseURLs = Vector.<String>(["anims/AvatarIdle.swf"]);
			//slotAssets.avatarFreeSpinURLs = Vector.<String>(["anims/NeZhaFreeSpin.swf"]);
			
			// ----- declare HUD assets --------------------------------------------------
						
			clsDef = Class(getDefinitionByName("HudEN")); // default HUD
			if (Utils.hasDefinition("Hud" + lang.toUpperCase())) { // if there is a language specific HUD
				clsDef = getDefinitionByName("Hud" + lang.toUpperCase()) as Class;
			}
			
			var hud:MovieClip = new clsDef();
			///Behaviours.hudBehaviour(hud);
			slotAssets.mainSprite.addChild(hud);
			slotAssets.hudSprite = hud;
			slotAssets.btnStop = hud.btnStop;
			slotAssets.btnSpin = hud.btnSpin;
			slotAssets.btnAutoStop = hud.btnAutoStop;
			slotAssets.btnAutoSpin = hud.btnAutoSpin;
			slotAssets.btnAutoSpinPlus = hud.boxAutoSpin.btnPlus;
			slotAssets.btnAutoSpinMinus = hud.boxAutoSpin.btnMinus;
			slotAssets.btnLineBet = hud.btnLineBet;
			slotAssets.btnLineBetPlus = hud.boxLineBet.btnPlus;
			slotAssets.btnLineBetMinus = hud.boxLineBet.btnMinus;
			slotAssets.btnStartFreeSpins = hud.btnStartFreeSpins;
			slotAssets.btnStartBonusGame = hud.btnStartBonusGame;
			slotAssets.btnMaxBet = hud.btnMaxBet;
			slotAssets.btnInfo = hud.btnInfo;
			slotAssets.txtWin = hud.fullBetWin.TxtWin;
			slotAssets.txtAutoSpin = hud.boxAutoSpin.tf;
			slotAssets.txtLineBet = hud.boxLineBet.tf;
			slotAssets.txtTotalBet = hud.fullBetWin.TxtFullBet;
			slotAssets.txtMsgBox = hud.TxtMsgBox;
			//slotAssets.txtUserName = bar.userTf;
			//slotAssets.txtBalance = bar.balanceTf;
			slotAssets.btnStartDoubleUp = hud.btnDoubleUp;
			clsDef = Class(getDefinitionByName("BoxBigWin"));		// the big win money spewing box
			slotAssets.bigWinBox = new clsDef();
			applyFontEmbedding(slotAssets.bigWinBox["tf"] as TextField, NUMBER_FONT.fontName);
			hud["boxBigWin"] = slotAssets.bigWinBox;
			hud.addChild(slotAssets.bigWinBox);
			
			clsDef = Class(getDefinitionByName("BoxFreeSpins"));	// the free spin counts box
			slotAssets.freeSpinBox = new clsDef();
			Behaviours.freeSpinHudBehaviour(slotAssets.freeSpinBox);
			applyFontEmbedding(slotAssets.freeSpinBox["tf"] as TextField, NUMBER_FONT.fontName);
			hud["boxFreeSpins"] = slotAssets.freeSpinBox;
			if (slotAssets.freeSpinBox["title"]) slotAssets.freeSpinBox["title"].gotoAndStop(_lang.toLowerCase());
			hud.addChild(slotAssets.freeSpinBox);
			
			//slotAssets.btnHistory = bar.btnHistory;
			//slotAssets.btnLogin = bar.btnLogin;
			
						
			//slotAssets.mainSprite.addChild(slotAssets.mainSprite["barside"]);
			
			//=========================================================
			//===========init Boxing Animation Buttons
			//=========================================================
			//slotAssets.btnLineBetAnim = hud.btnLineBetAnim;
			
			
			
			
			slotAssets.mainSprite.addChild(slotAssets.avatarSprite);// add the avatar anim container in main
			slotAssets.mainSprite.addChild(hud); // place hud ABOVE the avatar

			/*var T:Vector.<TextField> = Vector.<TextField>([	slotAssets.txtMsgBox,
															hud.fullBetWin.winLabelTf,
															hud.fullBetWin.totalBetLabelTf,
															slotAssets.pageWin.titleTf
															]);
			var N:Vector.<TextField> = Vector.<TextField>([
															hud.boxLineBet.tf,
															hud.cntrAutoSpin.tf,
															hud.boxAutoSpin.tf,
															hud.fullBetWin.TxtWin,
															hud.fullBetWin.TxtFullBet,
															slotAssets.pageWin.textTf
															]);
			for (var i:int = 0; i < T.length; i++) { // default font
				applyFontEmbedding(T[i], (DEFAULT_FONT != null)? DEFAULT_FONT.fontName: "");
			}//endfor
			
			for (var n:int = 0; n < N.length; n ++) { // numbers
				applyFontEmbedding(N[n], NUMBER_FONT.fontName);
			}*/
			
			hud.boxAutoSpin.tf.mouseEnabled = true;
			
			// ----- declare language specific intro/info pages --------------------------
			//clsDef = Class(getDefinitionByName("PageIntro"+lang.toUpperCase()));
			//slotAssets.pageIntro = new clsDef();	// Intro page
			//slotAssets.pageIntro.name = "PageIntro";
			clsDef = Class(getDefinitionByName("PageInfo"+lang.toUpperCase()));
			slotAssets.pageInfo = new clsDef();		// Info page and stuffs
			clsDef = Class(getDefinitionByName("BonusLoading"+lang.toUpperCase()));
			slotAssets.pageBonusLoading = new clsDef();
			if (slotAssets.pageIntro) {
				slotAssets.btnIntroClose = slotAssets.pageIntro.playBtn;
				slotAssets.btnIntroDoNotShowAgain = slotAssets.pageIntro.tickBtn;				
			} else {
				slotAssets.btnIntroClose = null;
				slotAssets.btnIntroDoNotShowAgain = null;				
			}
			slotAssets.btnInfoNext = slotAssets.pageInfo.btnNext;
			slotAssets.btnInfoPrev = slotAssets.pageInfo.btnPrev;
			slotAssets.btnInfoReturn = slotAssets.pageInfo.btnReturn;
			/*function addToStageHandler(ev:Event):void
			{	// hack to make sure avatar is on top of info page
				if (slotAssets.avatarSprite.parent==slotAssets.pageInfo.parent)
				{
					var pp:Sprite = slotAssets.avatarSprite.parent as Sprite;
					if (pp.getChildIndex(slotAssets.avatarSprite)<pp.getChildIndex(slotAssets.pageInfo))
						pp.swapChildren(slotAssets.avatarSprite,slotAssets.pageInfo);
				}
				
				slotAssets.avatarSprite.visible = false;
			}
			
			function removedFromStageHandler($e:Event):void {
				slotAssets.avatarSprite.visible = true;				
			}*/
			//slotAssets.pageInfo.addEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
			//slotAssets.pageInfo.addEventListener(Event.REMOVED_FROM_STAGE,removedFromStageHandler);
			
			// ----- declare sounds ------------------------------------------------------
			//slotAssets.sndIntroBGMURL = "sounds/introBGM.mp3";
			slotAssets.sndIntroBGMURL = "sounds/mainBGM.mp3";
			slotAssets.sndGameBGMURL = "sounds/mainBGM.mp3";
			slotAssets.sndWinBGMURL = "sounds/totalWinBGM.mp3";
			slotAssets.sndFreeSpinURL = null;
			slotAssets.sndFreeSpinBGMURL = "sounds/freespinBGM.mp3";
			slotAssets.sndPlusURL = "sounds/spin.mp3";
			slotAssets.sndMinusURL = "sounds/spin.mp3";
			slotAssets.sndStartSpinURL = "sounds/spin.mp3";
			slotAssets.SndSymbolURLs = Vector.<String>(["sounds/Symbol0.mp3",
														"sounds/Symbol1.mp3",
														"sounds/Symbol2.mp3",
														"sounds/Symbol3.mp3",
														"sounds/Symbol4.mp3",
														"sounds/Symbol5.mp3",
														"sounds/symbol6.mp3",
														"sounds/Symbol7.mp3",
														"sounds/symbol8.mp3",
														"sounds/symbol9.mp3",
														"sounds/symbol10.mp3",
														"sounds/symbol11.mp3",
														"sounds/symbol12.mp3"]);
														
			slotAssets.SndSymbolStopURLs = Vector.<String>([null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null,
															null]);
															
			slotAssets.SndReelStopURLs = Vector.<String>(["sounds/reelStop.mp3",
														  "sounds/reelStop.mp3",
														  "sounds/reelStop.mp3",
														  "sounds/reelStop.mp3",
														  "sounds/reelStop.mp3"]);
														  
			slotAssets.SndScatterReelStopURLs = Vector.<String>(["sounds/scatterstop.mp3",
														  "sounds/scatterstop.mp3",
														  "sounds/scatterstop.mp3",
														  "sounds/scatterstop.mp3",
														  "sounds/scatterstop.mp3"]);
			
			// ----- production server config ------------------------------------------------
			var dom:String = "w88api.com";
			
			var proto:String = "http";
			if (loaderInfo.url.indexOf("https://")==0) proto = "https";
		   
			// ----- Live server config -------------------------------------------------
			var serverURL:String = proto+"://rslotservice.w88api.com/onlinecasino/common/";
			var gameAPIURL:String = proto+"://rslotservice.w88api.com/onlinecasino/Games/" + GAMENAME + "/"; 
			   
			// ----- UAT server config --------------------------------------------------
			if (loaderInfo.url.indexOf("file://")!=-1 || loaderInfo.url.indexOf("uat.com/")!=-1)
			{
				serverURL = "http://slotservice.bet8uat.com/onlinecasino/common/";
				gameAPIURL =  "http://slotservice.bet8uat.com/onlinecasino/Games/" + GAMENAME + "/";
				SlotCommons.encryptMessages = false;
			}
			// ----- init slots!! ------------------------------------------------------------
			_slotscommons = new SlotCommons(_slotassets, serverURL, gameAPIURL);
			
			_slotscommons.BetLines = Vector.<Array>([[2,2,2,2,2],	// line 1
				[1,1,1,1,1],	// line 2
				[3,3,3,3,3],	// line 3
				[1,2,3,2,1],	// line 4
				[3,2,1,2,3],	// line 5
				[1,1,2,1,1],	// line 6
				[3,3,2,3,3],	// line 7
				[2,3,3,3,2],	// line 8
				[2,1,1,1,2],	// line 9
				[2,1,2,1,2],	// line 10
				[2,3,2,3,2],	// line 11
				[1,2,1,2,1],	// line 12
				[3,2,3,2,3],	// line 13
				[2,2,1,2,2],	// line 14
				[2,2,3,2,2]]);

			var slots:SlotCommons = _slotscommons;
				
			///slots.addExpandingAnim("10,10,10","anims/symbol10Expanding" + useLangVariant() + ".swf", null, false, null, false, true);	// set expanding anims
			
			
			
			// ----- setup bonus game --------------------------------------------------------
			var bonus1Cls:Class = Class(getDefinitionByName("Bonus1"));
			var bonus2Cls:Class = Class(getDefinitionByName("Bonus2"));
			slots.addDoubleUp(1,new BonusGame1(new bonus1Cls()), null,"sounds/bonus1/bonus1_bgm.mp3"); // select weapon
			///slots.addBonusGame(4,new BonusGame2(new bonus2Cls()), null,"sounds/bonus2/bonus2_bgm.mp3");	// shoot enemies
			var L:Vector.<String> = Vector.<String>(["en","cs","id","vn","kr","th","kh","jp"]);
			var idx:int = L.indexOf(lang.toLowerCase())+1;
			
			 
			slots.addFreeSpin(2);
			
			slots.avatarFpf = 1;
			slots.animsFpf = 1;
			slots.expandingFpf = 1;
			
			slots.setWinLinesColor(0x464943, 0x696e69);
			///slots.addSlotFireTo(Vector.<int>([8, 9, 10]), "anims/slotfire.swf", "sounds/slotfire.mp3");
			///Utils.loadMovie("anims/bigWinAnim.swf",function(mc:MovieClip):void {slotAssets.bigWinBox.addChild(mc);});
			
			bg = slotAssets.mainSprite.getChildByName("bg") as MovieClip;
			///Behaviours.flashStreetLamp(bg["normalBg"]["light"]);
			///Behaviours.flashStreetLamp(bg["normalBg"]["light2"]);
			hudflvs = { };
			
			/*function freeSpinConditionCheck($e:Event):void {
				var bg:MovieClip = slotAssets.mainSprite.getChildByName("bg") as MovieClip;
				if (!bg) return;
				if (slots.inFreeSpins()) {
					if (bg["normalBg"].alpha == 1) {
						Utils.simpleFadeFx(bg["normalBg"], "out", null, 2.0);
						Utils.simpleFadeFx(bg["freeSpinBg"], "in", null, 2.0);
						if (hud["freespinslogo"]) {							
							hud["freespinslogo"].visible = true;
							hud["Gamelogo"].visible = false;
						}
						if (hudflvs["dayleft"]) hudflvs["dayleft"].stop();
						if (hudflvs["dayright"]) hudflvs["dayright"].stop();
						if (hudflvs["daylampsleft"]) hudflvs["daylampsleft"].stop();
						if (hudflvs["daylampsright"]) hudflvs["daylampsright"].stop();
						if (hudflvs["nightleft"]) hudflvs["nightleft"].play();
						if (hudflvs["nightright"]) hudflvs["nightright"].play();
						if (hudflvs["nightlampsleft"]) hudflvs["nightlampsleft"].play();
						if (hudflvs["nightlampsright"]) hudflvs["nightlampsright"].play();
					}
				} else {
					if (bg["freeSpinBg"].alpha == 1) {
						Utils.simpleFadeFx(bg["normalBg"], "in", null, 1.0);
						Utils.simpleFadeFx(bg["freeSpinBg"], "out", null, 1.0);
						if (hud["freespinslogo"]) {
							hud["freespinslogo"].visible = false;
							hud["Gamelogo"].visible = true;
						}
						if (hudflvs["dayleft"]) hudflvs["dayleft"].play();
						if (hudflvs["dayright"]) hudflvs["dayright"].play();
						if (hudflvs["daylampsleft"]) hudflvs["daylampsleft"].play();
						if (hudflvs["daylampsright"]) hudflvs["daylampsright"].play();
						if (hudflvs["nightleft"]) hudflvs["nightleft"].stop();
						if (hudflvs["nightright"]) hudflvs["nightright"].stop();
						if (hudflvs["nightlampsleft"]) hudflvs["nightlampsleft"].stop();
						if (hudflvs["nightlampsright"]) hudflvs["nightlampsright"].stop();
					}					
				}
			}*/
			//Utils.loadMovie("anims/hud/bg_topleft.swf", hudFLVLoaded, "topleft");
			//Utils.loadMovie("anims/hud/bg_topright.swf", hudFLVLoaded, "topright");
			///Utils.loadMovie("anims/hud/Rain.swf", hudFLVLoaded, "rain");
			
			///if (STATIC_LOGO.indexOf(_lang) < 0) {
			///	trace("using animated logo for " + _lang);
			///	Utils.loadMovie("anims/hud/Logo.swf", hudFLVLoaded, "logo");				
			///}
			
			///if (!_hide) {
			///	_hide = new Vector.<MovieClip>;
			///	_hide[0] = null;
			///	_hide[1] = null;
			///	_hide[2] = null;
			///	Utils.loadMovie("anims/AvatarHide1.swf", avatarHide, 0);
			///	Utils.loadMovie("anims/AvatarHide2.swf", avatarHide, 1);
			///	Utils.loadMovie("anims/AvatarHide3.swf", avatarHide, 2);
			///}
			
			function avatarHide($mc:MovieClip, $id:int):void {
				_hide[$id] = $mc;
			}
			
			//slotAssets.mainSprite.addEventListener(Event.ENTER_FRAME, freeSpinConditionCheck);
			
 			///setText(hud.fullBetWin.winLabelTf as TextField, slotAssets.xmlTxts.game.@labwin, "", Boolean(DEFAULT_FONT != null), ((DEFAULT_FONT != null)? DEFAULT_FONT.fontName: ""));
			///setText(hud.fullBetWin.totalBetLabelTf as TextField, slotAssets.xmlTxts.game.@labtotalbet, "", Boolean(DEFAULT_FONT != null), ((DEFAULT_FONT != null)? DEFAULT_FONT.fontName: ""));
			
			_slotscommons.addListener(SlotCommons.EVENT_FREESPIN_PREANIM_START, freeSpinPreAnimStart);
			_slotscommons.addListener(SlotCommons.EVENT_FREESPIN_PREANIM_DONE, freeSpinPreAnimDone);
			_slotscommons.addListener(SlotCommons.EVENT_BONUSGAME_START, enterBonusGame);
			_slotscommons.addListener(SlotCommons.EVENT_BONUSGAME_DONE, doneBonusGame);
			//_slotscommons.addListener(SlotCommons.EVENT_FREESPIN_START, startFreeSpin);
			//_slotscommons.addListener(SlotCommons.EVENT_FREESPIN_DONE, endFreeSpin);
			
			SimpleEventDispatcher.instance.listen("playSound", playASound);
			
		}//endfunction
		
		private function playASound($snd:String, $s:Boolean = false):void {
			_slotscommons.playSound($snd, $s);
		}
		
		private function freeSpinPreAnimStart():void {
			_slotassets.avatarSprite.visible = false;
			_slotassets.mainSprite["bg"].addChild(_hide[0]);
			Utils.playOnceAndStop(_hide[0], 0, hidden);
		}
		
		private function hidden():void {
			_slotassets.mainSprite["bg"].removeChild(_hide[0]);
			_slotassets.mainSprite["bg"].addChild(_hide[1]);
			_hide[1].play();
		}
		
		private function freeSpinPreAnimDone():void {
			_hide[1].stop();
			_slotassets.mainSprite["bg"].removeChild(_hide[1]);
			_slotassets.mainSprite["bg"].addChild(_hide[2]);
			Utils.playOnceAndStop(_hide[2], 0, unhidden);
		}
		
		private function unhidden():void {
			for (var i:int = 0; i < _hide.length; i ++) {
				if (_hide[i].parent) _hide[i].parent.removeChild(_hide[i]);
			}
			_slotassets.avatarSprite.visible = true;
		}
		
		private function enterBonusGame($bonus:String):void {
			if (_rain) _rain.visible = false;
		}
		
		private function doneBonusGame():void {
			if (_rain) _rain.visible = true;
		}
		
		/*private function startFreeSpin():void {
		}
		
		private function endFreeSpin():void {
		}*/

		//=======================================================================================
		//
		//=======================================================================================
		
		private function hudFLVLoaded($mc:MovieClip, $type:String):void {
			hudflvs[$type] = $mc;
			$mc.mouseEnabled = false;
			for (var n:int = 0; n < $mc.numChildren; n ++) {
				if ($mc.getChildAt(n) is Video) {
					Video($mc.getChildAt(0)).smoothing = true;
				}
			}			
			switch ($type) {
				case "topleft":
				case "topright":
				case "logo":
					bg["normalBg"].addChild($mc);
					if (hudflvs[$type]) {
						bg["normalBg"].addChild(hudflvs[$type]);
						bg["normalBg"].addChild(bg["normalBg"]["light"]);
					}
					if (hudflvs["logo"]) {
						bg["normalBg"].addChild(hudflvs["logo"]);
						_slotassets.hudSprite["Gamelogo"].visible = false;
					}
					break;
				case "rain":
					_rain = $mc;
					if (_slotassets.mainSprite.getChildByName("PageIntro")) {
						$mc.addEventListener(Event.ENTER_FRAME, rainHandler);
					} else {
						_slotassets.mainSprite.addChild($mc);
					}
					break;
			}
		}
		
		private function rainHandler($e:Event):void {
			if (!_slotassets.mainSprite.getChildByName("PageIntro")) {
				_rain.removeEventListener(Event.ENTER_FRAME, rainHandler);
				_slotassets.mainSprite.addChild(_rain);				
			}
		}
		
		private function getLanguage():String
		{
			// ----- detect language from URL
			var lang:String = "en";
			
			try {				
				// ----- detect language from site cookie
				var cookie:String = ExternalInterface.call("function() {return document.cookie;}");
				if (cookie!=null)
				{
					var cookStrs:Array = cookie.split(";");
					for (var i:int=0; i<cookStrs.length; i++)
					{
						var ss:String = cookStrs[i];
						while (ss.charAt(0)==" ") ss = ss.substring(1);
						if (ss.indexOf("language=")==0)	
							lang = ss.split("language=")[1].split(";")[0];
					}//endfor
				}//endif
				var curUrl:String = ExternalInterface.call("window.location.href.toString");
				if (curUrl==null)	curUrl = "";
				if (curUrl.indexOf("lang=")!=-1)	lang = curUrl.split("lang=")[1].split("&")[0];
			} 
			catch (e:Error) 
			{
				trace(e);
			}
			lang = lang.toLowerCase();
			switch (true) {
				case (lang.indexOf("us") >= 0):
				case (lang.indexOf("en") >= 0): return "en";
				case (lang.indexOf("cn") >= 0):
				case (lang.indexOf("zh") >= 0):
				case (lang.indexOf("cs") >= 0): return "cs";
				case (lang.indexOf("th") >= 0): return "th";
				case (lang.indexOf("vi") >= 0):
				case (lang.indexOf("vn") >= 0): return "vn";
				case (lang.indexOf("kr") >= 0): return "kr";
				case (lang.indexOf("km") >= 0):
				case (lang.indexOf("kh") >= 0): return "kh";
				case (lang.indexOf("id") >= 0): return "id";
				case (lang.indexOf("ja") >= 0):
				case (lang.indexOf("jp") >= 0): return "jp";
			}
			return lang;
		}//endfunction
		
		private function useLangVariant():String {
			switch (_lang.toUpperCase()) {
				case "CS":
				case "JP":
					return _lang.toUpperCase();
			}
			return "EN";
		}
		
		/**
		 * Preload essential bonus game assets
		 */
		/*private function preloadBonusGameAssets():void {
			_bonusGameAssets = Vector.<String>([
												]);
			
			bonusPreload();
		}
		
		private function bonusPreload():void {
			if (_bonusGameAssets && (_bonusGameAssets.length > 0)) {
				var a:String = _bonusGameAssets.shift();
				_slotscommons.loadMovie(a, bonusPreloadInit);
			} else {
				_bonusGameAssets = null;
			}
		}
		
		private function bonusPreloadInit($mc:MovieClip):void {
			bonusPreload();
		}*/
			
	}//endclass
}//endpackage
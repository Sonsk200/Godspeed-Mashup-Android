package;

import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import openfl.media.Sound;

import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import sys.io.File;
#if windows
import Discord.DiscordClient;
#end
#if sys
import Sys;
import sys.FileSystem;
#end
import ui.Hitbox;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	public static var mania:Int = 0;
	public static var keyAmmo:Array<Int> = [4, 6, 9];
	//private var ctrTime:Float = 0;

	public static var songPosBG:FlxSprite;
	public var visibleCombos:Array<FlxSprite> = [];
	public static var songPosBar:FlxBar;

	public static var inResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	
	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public var originalX:Float;

	var dn0:Float = 0;
	var dn1:Float = 0;
	var dn2:Float = 0;
	var dn3:Float = 0;
	var dn5:Float = 0;
	var dn6:Float = 0;
	var dn7:Float = 0;
	var dn8:Float = 0;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	public static var redshaggy:Character;
	public static var yellowshaggy:Character;
	public static var purpleshaggy:Character;
	public static var tiky:Character;

	var tikyactive:Bool = false;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var sDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	var grace:Bool = false;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	public var health:Float = 1; //making public because sethealth doesnt work without it
	private var combo:Int = 0;
	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;
	public var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;


	public var iconP1:HealthIcon; //making these public again because i may be stupid
	public var iconP2:HealthIcon; //what could go wrong?
	public var iconShag:HealthIcon; //what could go wrong?
	public var camHUD:FlxCamera;
	//var cs_reset:Bool = false;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;
	public var cannotDie = false;
	private var camGame:FlxCamera;
	var switchtimer:Bool;

	private var cutTime:Float;
	private var shaggyT:FlxTrail;
	private var redshaggyT:FlxTrail;
	private var yellowshaggyT:FlxTrail;
	private var purpleshaggyT:FlxTrail;
	private var bfT:FlxTrail;
	private var ctrTime:Float = 0;
	private var notice:FlxText;
	private var nShadow:FlxText;

	var endingzoom:Bool = false;

	public var sh_r:Float = 600;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)


	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	public var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	var godCutEnd:Bool = false;
	var godMoveBf:Bool = true;
	var godMoveGf:Bool = false;
	var godMoveSh:Bool = false;
	var redshagfly:Int = 0;
	var startedCountdown:Bool = false;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var burst:FlxSprite;
	var rock:FlxSprite;
	var rock2:FlxSprite;
	var gf_rock:FlxSprite;
	var doorFrame:FlxSprite;
	var dfS:Float = 1;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public var isgreenshaggy:Bool = false;
	public var isredshaggy:Bool = false;
	public var isyellowshaggy:Bool = false;
	public var ispurpleshaggy:Bool = false;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	var cs_reset:Bool = false;
	var s_ending:Bool = false;

	var gf_launched:Bool = false;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;

	public static var highestCombo:Int = 0;

	private var executeModchart = false;
	public static var startTime = 0.0;

	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }
	
    var _hitbox:Hitbox;

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
			{
				sicks = 0;
				bads = 0;
				shits = 0;
				goods = 0;
			}
			misses = 0;
	
			repPresses = 0;
			repReleases = 0;


		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		
		executeModchart = FileSystem.exists(Paths.lua(songLowercase  + "/modchart"));
		
		if (!executeModchart)
		{
			var path = Paths.luaAsset(songLowercase  + "/modchart");
			var luaFile = openfl.Assets.getBytes(path);

			FileSystem.createDirectory(Main.path + "assets");
			FileSystem.createDirectory(Main.path + "assets/data");
			FileSystem.createDirectory(Main.path + "assets/data/tutorial");
			FileSystem.createDirectory(Main.path + "assets/data/where-are-you");
			FileSystem.createDirectory(Main.path + "assets/data/godspeed");


			File.saveBytes(Paths.lua(songLowercase  + "/modchart"), luaFile);

			executeModchart = FileSystem.exists(Paths.lua(songLowercase  + "/modchart"));
		}
		

		trace('Mod chart: ' + executeModchart + " - " + Main.path + Paths.lua(songLowercase + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		curStage = "";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end


		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		mania = SONG.mania;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);
	
		//dialogue shit
		switch (songLowercase)
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		//defaults if no stage was found in chart
		var stageCheck:String = 'stage';
		
		if (SONG.stage == null) {
			switch(storyWeek)
			{
				case 2: stageCheck = 'halloween';
				case 3: stageCheck = 'philly';
				case 4: stageCheck = 'limo';
				case 5: if (songLowercase == 'winter-horrorland') {stageCheck = 'mallEvil';} else {stageCheck = 'mall';}
				case 6: if (songLowercase == 'thorns') {stageCheck = 'schoolEvil';} else {stageCheck = 'school';}
				case 7: stageCheck = 'sky';
				//i should check if its stage (but this is when none is found in chart anyway)
			}
		} else {stageCheck = SONG.stage;}

		if (!PlayStateChangeables.Optimize)
		{

		switch(stageCheck)
		{
			case 'halloween': 
			{
				curStage = 'spooky';
				halloweenLevel = true;

				var hallowTex = Paths.getSparrowAtlas('halloween_bg','week2');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = FlxG.save.data.antialiasing;
				add(halloweenBG);

				isHalloween = true;
			}
			case 'philly': 
					{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					if(FlxG.save.data.distractions){
						add(phillyCityLights);
					}

					for (i in 0...5)
					{
							var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
							light.scrollFactor.set(0.3, 0.3);
							light.visible = false;
							light.setGraphicSize(Std.int(light.width * 0.85));
							light.updateHitbox();
							light.antialiasing = FlxG.save.data.antialiasing;
							phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain','week3'));
					add(streetBehind);

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train','week3'));
					if(FlxG.save.data.distractions){
						add(phillyTrain);
					}

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes','week3'));
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street','week3'));
					add(street);
			}
			case 'limo':
			{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset','week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					skyBG.antialiasing = FlxG.save.data.antialiasing;
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo','week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = FlxG.save.data.antialiasing;
					add(bgLimo);
					if(FlxG.save.data.distractions){
						grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						add(grpLimoDancers);
	
						for (i in 0...5)
						{
								var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
								dancer.scrollFactor.set(0.4, 0.4);
								grpLimoDancers.add(dancer);
						}
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay','week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive','week4');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = FlxG.save.data.antialiasing;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol','week4'));
					fastCar.antialiasing = FlxG.save.data.antialiasing;
					// add(limo);
			}
			case 'mall':
			{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls','week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop','week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = FlxG.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if(FlxG.save.data.distractions){
						add(upperBoppers);
					}


					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator','week5'));
					bgEscalator.antialiasing = FlxG.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree','week5'));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop','week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if(FlxG.save.data.distractions){
						add(bottomBoppers);
					}


					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow','week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = FlxG.save.data.antialiasing;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa','week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = FlxG.save.data.antialiasing;
					if(FlxG.save.data.distractions){
						add(santa);
					}
			}
			case 'mallEvil':
			{
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG','week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree','week5'));
					evilTree.antialiasing = FlxG.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow",'week5'));
						evilSnow.antialiasing = FlxG.save.data.antialiasing;
					add(evilSnow);
					}
			case 'school':
			{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky','week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool','week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet','week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees','week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (songLowercase == 'roses')
						{
							if(FlxG.save.data.distractions){
								bgGirls.getScared();
							}
						}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					if(FlxG.save.data.distractions){
						add(bgGirls);
					}
			}
			case 'schoolEvil':
			{
					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool','week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);

					/* 
							var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
							bg.scale.set(6, 6);
							// bg.setGraphicSize(Std.int(bg.width * 6));
							// bg.updateHitbox();
							add(bg);
							var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
							fg.scale.set(6, 6);
							// fg.setGraphicSize(Std.int(fg.width * 6));
							// fg.updateHitbox();
							add(fg);
							wiggleShit.effectType = WiggleEffectType.DREAMY;
							wiggleShit.waveAmplitude = 0.01;
							wiggleShit.waveFrequency = 60;
							wiggleShit.waveSpeed = 0.8;
						*/

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
								var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
								var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
								// Using scale since setGraphicSize() doesnt work???
								waveSprite.scale.set(6, 6);
								waveSpriteFG.scale.set(6, 6);
								waveSprite.setPosition(posX, posY);
								waveSpriteFG.setPosition(posX, posY);
								waveSprite.scrollFactor.set(0.7, 0.8);
								waveSpriteFG.scrollFactor.set(0.9, 0.8);
								// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
								// waveSprite.updateHitbox();
								// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
								// waveSpriteFG.updateHitbox();
								add(waveSprite);
								add(waveSpriteFG);
						*/
			}
			case 'stage':
				{
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);
	
						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);
	
						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;
	
						add(stageCurtains);
				}
			case 'sky': 
				{
						defaultCamZoom = 0.65;
						curStage = 'sky';
			
						var sky = new FlxSprite(-850, -850);
						sky.frames = Paths.getSparrowAtlas('god_bg');
						sky.animation.addByPrefix('sky', "bg", 30);
						sky.setGraphicSize(Std.int(sky.width * 0.8));
						sky.animation.play('sky');
						sky.scrollFactor.set(0.1, 0.1);
						sky.antialiasing = FlxG.save.data.antialiasing;
						add(sky);
			
						var bgcloud = new FlxSprite(-850, -1250);
						bgcloud.frames = Paths.getSparrowAtlas('god_bg');
						bgcloud.animation.addByPrefix('c', "cloud_smol", 30);
						//bgcloud.setGraphicSize(Std.int(bgcloud.width * 0.8));
						bgcloud.animation.play('c');
						bgcloud.scrollFactor.set(0.3, 0.3);
						bgcloud.antialiasing = FlxG.save.data.antialiasing;
						add(bgcloud);
			
						add(new MansionDebris(300, -800, 'norm', 0.4, 1, 0, 1));
						add(new MansionDebris(600, -300, 'tiny', 0.4, 1.5, 0, 1));
						add(new MansionDebris(-150, -400, 'spike', 0.4, 1.1, 0, 1));
						add(new MansionDebris(-750, -850, 'small', 0.4, 1.5, 0, 1));
			
						/*
						add(new MansionDebris(-300, -1700, 'norm', 0.5, 1, 0, 1));
						add(new MansionDebris(-600, -1100, 'tiny', 0.5, 1.5, 0, 1));
						add(new MansionDebris(900, -1850, 'spike', 0.5, 1.2, 0, 1));
						add(new MansionDebris(1500, -1300, 'small', 0.5, 1.5, 0, 1));
						*/
			
						add(new MansionDebris(-300, -1700, 'norm', 0.75, 1, 0, 1));
						add(new MansionDebris(-1000, -1750, 'rect', 0.75, 2, 0, 1));
						add(new MansionDebris(-600, -1100, 'tiny', 0.75, 1.5, 0, 1));
						add(new MansionDebris(900, -1850, 'spike', 0.75, 1.2, 0, 1));
						add(new MansionDebris(1500, -1300, 'small', 0.75, 1.5, 0, 1));
						add(new MansionDebris(-600, -800, 'spike', 0.75, 1.3, 0, 1));
						add(new MansionDebris(-1000, -900, 'small', 0.75, 1.7, 0, 1));
			
						var fgcloud = new FlxSprite(-1150, -2900);
						fgcloud.frames = Paths.getSparrowAtlas('god_bg');
						fgcloud.animation.addByPrefix('c', "cloud_big", 30);
						//bgcloud.setGraphicSize(Std.int(bgcloud.width * 0.8));
						fgcloud.animation.play('c');
						fgcloud.scrollFactor.set(0.9, 0.9);
						fgcloud.antialiasing = FlxG.save.data.antialiasing;
						add(fgcloud);
			
						var bg:FlxSprite = new FlxSprite(-400, -160).loadGraphic(Paths.image('bg_lemon'));
						bg.setGraphicSize(Std.int(bg.width * 1.5));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.95, 0.95);
						bg.active = false;
						add(bg);
			
						var techo = new FlxSprite(0, -20);
						techo.frames = Paths.getSparrowAtlas('god_bg');
						techo.animation.addByPrefix('r', "broken_techo", 30);
						techo.setGraphicSize(Std.int(techo.frameWidth * 1.5));
						techo.animation.play('r');
						techo.scrollFactor.set(0.95, 0.95);
						techo.antialiasing = FlxG.save.data.antialiasing;
						add(techo);
			
						gf_rock = new FlxSprite(20, 20);
						gf_rock.frames = Paths.getSparrowAtlas('god_bg');
						gf_rock.animation.addByPrefix('rock', "gf_rock", 30);
						gf_rock.animation.play('rock');
						gf_rock.scrollFactor.set(0.8, 0.8);
						gf_rock.antialiasing = FlxG.save.data.antialiasing;
						add(gf_rock);
			
						rock = new FlxSprite(20, 20);
						rock.frames = Paths.getSparrowAtlas('god_bg');
						rock.animation.addByPrefix('rock', "rock", 30);
						rock.animation.play('rock');
						rock.scrollFactor.set(1, 1);
						rock.antialiasing = FlxG.save.data.antialiasing;
						add(rock);
			
						rock2 = new FlxSprite(20, 20);
						rock2.frames = Paths.getSparrowAtlas('god_bg');
						rock2.animation.addByPrefix('rock', "rock", 30);
						rock2.animation.play('rock');
						rock2.scrollFactor.set(0.5, 0.5);
						rock2.scale.set(0.3, 0.3);
						rock2.antialiasing = FlxG.save.data.antialiasing;
						add(rock2);
				}
			default:
			{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
			}
		}
	}
		//defaults if no gf was found in chart
		var gfCheck:String = 'gf';
		
		if (SONG.gfVersion == null) {
			switch(storyWeek)
			{
				case 4: gfCheck = 'gf-car';
				case 5: gfCheck = 'gf-christmas';
				case 6: gfCheck = 'gf-pixel';
			}
		} else {gfCheck = SONG.gfVersion;}

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-car':
				curGf = 'gf-car';
			case 'gf-christmas':
				curGf = 'gf-christmas';
			case 'gf-pixel':
				curGf = 'gf-pixel';
			default:
				curGf = 'gf';
		}
		
		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				if (FlxG.save.data.distractions)
					{
						// trailArea.scrollFactor.set();
						if (!PlayStateChangeables.Optimize)
						{
							var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
							// evilTrail.changeValuesEnabled(false, false, false, false);
							// evilTrail.changeGraphic()
							add(evilTrail);
						}
						// evilTrail.scrollFactor.set(1.1, 1.1);
					}
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}


		
		boyfriend = new Boyfriend(770, 450, SONG.player1);





		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if(FlxG.save.data.distractions){
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'sky': 
				//rock2.visible = true;
		}
		redshaggy = new Character(2000, 0, 'redpshaggy');
		yellowshaggy = new Character(2000, 0, 'yellowpshaggy');
		purpleshaggy = new Character(2000, 0, 'purplepshaggy');
		tiky = new Character(2000, 0, 'trickyMask');
		redshaggyT = new FlxTrail(redshaggy, null, 5, 7, 0.3, 0.001);
		yellowshaggyT = new FlxTrail(yellowshaggy, null, 5, 7, 0.3, 0.001);
		purpleshaggyT = new FlxTrail(purpleshaggy, null, 5, 7, 0.3, 0.001);
		shaggyT = new FlxTrail(dad, null, 5, 7, 0.3, 0.001);
		bfT = new FlxTrail(boyfriend, null, 5, 7, 0.3, 0.001);


		if (!PlayStateChangeables.Optimize)
		{
			if (curStage == 'sky')
			{

				add(tiky);
				tiky.scrollFactor.set(0.5, 0.5);
				tiky.scale.set(0.3, 0.3);
				tiky.alpha = 0;
			}


			add(gf);

			if (curStage == 'sky')
			{

				add(redshaggyT);

				add(yellowshaggyT);

				add(purpleshaggyT);

				add(shaggyT);

			}







			// Shitty layering but whatev it works LOL
			if (curStage == 'limo')
				add(limo);

			if (curStage == 'sky')
				add(yellowshaggy);


			add(dad);
			add(boyfriend);
			if (curStage == 'sky')
				{
					add(redshaggy);
					add(purpleshaggy);
				}



		}

		trace('uh ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();


		// startCountdown();

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		/*for(i in unspawnNotes)
			{
				var dunceNote:Note = i;
				notes.add(dunceNote);
				if (executeModchart)
				{
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}
			}
	
			if (startTime != 0)
				{
					var toBeRemoved = [];
					for(i in 0...notes.members.length)
					{
						var dunceNote:Note = notes.members[i];
		
						if (dunceNote.strumTime - startTime <= 0)
							toBeRemoved.push(dunceNote);
						else 
						{
							if (PlayStateChangeables.useDownscroll)
							{
								if (dunceNote.mustPress)
									dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
										+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) - dunceNote.noteYOff;
								else
									dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
										+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) - dunceNote.noteYOff;
							}
							else
							{
								if (dunceNote.mustPress)
									dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
										- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) + dunceNote.noteYOff;
								else
									dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
										- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) + dunceNote.noteYOff;
							}
						}
					}
		
					for(i in toBeRemoved)
						notes.members.remove(i);
				}*/

		trace('generated');

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
				if (PlayStateChangeables.useDownscroll)
					songPosBG.y = FlxG.height * 0.9 + 45; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				add(songPosBar);
	
				var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5),songPosBG.y,0,SONG.song, 16);
				if (PlayStateChangeables.useDownscroll)
					songName.y -= 3;
				songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				add(songName);
				songName.cameras = [camHUD];
			}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " - " + CoolUtil.difficultyFromInt(storyDifficulty) + (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		originalX = scoreTxt.x;


		scoreTxt.scrollFactor.set();
		
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);

		add(scoreTxt);

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if(PlayStateChangeables.botPlay) add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		iconShag = new HealthIcon('shaggys', false);
		iconShag.y = healthBar.y - (iconShag.height / 2);
		add(iconShag);
		iconShag.visible = false;

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		iconShag.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];

		var curcontrol:HitboxType = DEFAULT;

		switch (SONG.song.toLowerCase())
		{
			default:
				curcontrol = NINE;
		}
		_hitbox = new Hitbox(curcontrol);

		var camcontrol = new FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		_hitbox.cameras = [camcontrol];

		_hitbox.visible = false;
		
		add(_hitbox);

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		trace('starting');

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong," ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case "godspeed":
					if (!Main.skipDes)
						{
							godIntro();
							Main.skipDes = true;
						}
						else
						{
							godCutEnd = true;
							godMoveGf = true;
							godMoveSh = true;
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								startCountdown();
							});
						}
				case "where-are-you":
					if (!Main.skipDes)
						{
							godIntro();
							Main.skipDes = true;
						}
						else
						{
							godCutEnd = true;
							godMoveGf = true;
							godMoveSh = true;
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								startCountdown();
							});
						}
				default:
					startCountdown();
			}
		}
		else
		{
			var cs = curSong.toLowerCase();
			switch (cs)
			{		
				case 'godspeed':
					if (!Main.skipDes)
						{
							godIntro();
							Main.skipDes = true;
						}
						else
						{
							godCutEnd = true;
							godMoveGf = true;
							godMoveSh = true;
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								startCountdown();
							});
						}
				case 'where-are-you':
					if (!Main.skipDes)
						{
							godIntro();
							Main.skipDes = true;
						}
						else
						{
							godCutEnd = true;
							godMoveGf = true;
							godMoveSh = true;
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								startCountdown();
							});
						}
				default:
					startCountdown();
			}
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();
	}

	function godIntro():Void //stupid fucking cutscene wont fucking work
		{
			inCutscene = true;
			dad.playAnim('back', true);
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				dad.playAnim('snap', true);
				new FlxTimer().start(0.85, function(tmr2:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('snap'));
					FlxG.sound.play(Paths.sound('undSnap'));
					sShake = 10;
					//pon el sonido con los efectos circulares
					new FlxTimer().start(0.06, function(tmr3:FlxTimer)
					{
						dad.playAnim('snapped', true);
					});
					new FlxTimer().start(1.5, function(tmr4:FlxTimer)
					{
						//la camara tiembla y puede ser que aparezcan rocas?
						new FlxTimer().start(0.001, function(shkUp:FlxTimer)
						{
							sShake += 0.51;
							if (!godCutEnd) shkUp.reset(0.001);
						});
						new FlxTimer().start(1, function(tmr5:FlxTimer)
						{
							add(new MansionDebris(-300, -120, 'ceil', 1, 1, -4, -40));
							add(new MansionDebris(0, -120, 'ceil', 1, 1, -4, -5));
							add(new MansionDebris(200, -120, 'ceil', 1, 1, -4, 40));
	
							sShake += 5;
							FlxG.sound.play(Paths.sound('ascend'));
							boyfriend.playAnim('hit');
							godCutEnd = true;
							new FlxTimer().start(0.4, function(tmr6:FlxTimer)
							{
								godMoveGf = true;
								boyfriend.playAnim('hit');
							});
							new FlxTimer().start(1, function(tmr9:FlxTimer)
							{
								boyfriend.playAnim('scared', true);
							});
							new FlxTimer().start(2, function(tmr7:FlxTimer)
							{
								dad.playAnim('idle', true);
								FlxG.sound.play(Paths.sound('shagFly'));
								godMoveSh = true;
								new FlxTimer().start(1.5, function(tmr8:FlxTimer)
								{
									startCountdown();
								});
							});
						});
					});
				});
			});
			new FlxTimer().start(0.001, function(shk:FlxTimer)
			{
				if (sShake > 0)
				{
					sShake -= 0.5;
					FlxG.camera.angle = FlxG.random.float(-sShake, sShake);
				}
				shk.reset(0.001);
			});
		}
	
		var sShake:Float = 0;

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'roses' || StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
		{
			remove(black);

			if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	public static var luaModchart:ModchartState = null;

	function startCountdown():Void
	{
	    _hitbox.visible = true;
		
		inCutscene = false;

		//appearStaticArrows();
		generateStaticArrows(0);
		generateStaticArrows(1);
		
	    #if sys
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		switch (songLowercase) {
			case 'dad-battle': songLowercase = 'dadbattle';
			case 'philly-nice': songLowercase = 'philly';
		}
		
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start',[songLowercase]);
		}
		#end
		var noticeB:Array<FlxText> = [];
		var nShadowB:Array<FlxText> = [];
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;
		if (curStage == 'sky')
			{

				/*dad.playAnim('snapped', true);

				new FlxTimer().start(0.3, function(tmr6:FlxTimer)
					{
						add(new MansionDebris(-300, -120, 'ceil', 1, 1, -4, -40));
						add(new MansionDebris(0, -120, 'ceil', 1, 1, -4, -5));
						add(new MansionDebris(200, -120, 'ceil', 1, 1, -4, 40));
						FlxG.sound.play(Paths.sound('ascend'));
						boyfriend.playAnim('hit');
						godCutEnd = true;
						camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
					});
				new FlxTimer().start(0.8, function(tmr6:FlxTimer)
				{
					godMoveGf = true;
					boyfriend.playAnim('hit');
					//dad.playAnim('idle', true);
					//FlxG.sound.play(Paths.sound('shagFly'));
					godMoveSh = true;
				});
				new FlxTimer().start(0.9, function(tmr7:FlxTimer)
				{
					camFollow.setPosition(dad.getMidpoint().x + 250, dad.getMidpoint().y - 100);
				});*/
				
				new FlxTimer().start(4, function(redshagflytmr:FlxTimer)
					{
						FlxG.sound.play(Paths.sound('shagFly'));
						redshagfly = 1;
						iconShag.visible = true;
						
		
					});
			}
		
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}
	private function releaseInput(evt:KeyboardEvent):Void // handles releases
		{
			@:privateAccess
			var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
	
			var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
			var data = -1;
			switch(mania)
			{
				case 0: 
					binds = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
					switch(evt.keyCode) // arrow keys // why the fuck are arrow keys hardcoded it fucking breaks the controls with extra keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 1: 
					binds = [FlxG.save.data.L1Bind, FlxG.save.data.U1Bind, FlxG.save.data.R1Bind, FlxG.save.data.L2Bind, FlxG.save.data.D1Bind, FlxG.save.data.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 3;
						case 40:
							data = 4;
						case 39:
							data = 5;
					}
				case 2: 
					binds = [FlxG.save.data.N0Bind, FlxG.save.data.N1Bind, FlxG.save.data.N2Bind, FlxG.save.data.N3Bind, FlxG.save.data.N4Bind, FlxG.save.data.N5Bind, FlxG.save.data.N6Bind, FlxG.save.data.N7Bind, FlxG.save.data.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
	
			}
	
			
			for (i in 0...binds.length) // binds
			{
				if (binds[i].toLowerCase() == key.toLowerCase())
					data = i;
			}
	
			if (data == -1)
				return;
	
			//keys[data] = false;
		}
	
		public var closestNotes:Array<Note> = [];

		private function handleInput(evt:KeyboardEvent):Void { // this actually handles press inputs

			if (PlayStateChangeables.botPlay || paused)
				return;
	
			// first convert it from openfl to a flixel key code
			// then use FlxKey to get the key's name based off of the FlxKey dictionary
			// this makes it work for special characters
	
			@:privateAccess
			var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
			var data = -1;
			var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
			switch(mania)
			{
				case 0: 
					binds = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
					switch(evt.keyCode) // arrow keys // why the fuck are arrow keys hardcoded it fucking breaks the controls with extra keys
					{
						case 37:
							data = 0;
						case 40:
							data = 1;
						case 38:
							data = 2;
						case 39:
							data = 3;
					}
				case 1: 
					binds = [FlxG.save.data.L1Bind, FlxG.save.data.U1Bind, FlxG.save.data.R1Bind, FlxG.save.data.L2Bind, FlxG.save.data.D1Bind, FlxG.save.data.R2Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 3;
						case 40:
							data = 4;
						case 39:
							data = 5;
					}
				case 2: 
					binds = [FlxG.save.data.N0Bind, FlxG.save.data.N1Bind, FlxG.save.data.N2Bind, FlxG.save.data.N3Bind, FlxG.save.data.N4Bind, FlxG.save.data.N5Bind, FlxG.save.data.N6Bind, FlxG.save.data.N7Bind, FlxG.save.data.N8Bind];
					switch(evt.keyCode) // arrow keys
					{
						case 37:
							data = 5;
						case 40:
							data = 6;
						case 38:
							data = 7;
						case 39:
							data = 8;
					}
	
			}
	
				for (i in 0...binds.length) // binds
					{
						if (binds[i].toLowerCase() == key.toLowerCase())
							data = i;
					}
					if (data == -1)
					{
						trace("couldn't find a keybind with the code " + key);
						return;
					}
					/*if (keys[data])
					{
						trace("ur already holding " + key);
						return;
					}
			
					keys[data] = true;*/
			
					var dataNotes = [];
					for(i in closestNotes)
						if (i.noteData == data)
							dataNotes.push(i);
			
					if (dataNotes.length != 0)
					{
						var coolNote = null;
			
						for (i in dataNotes)
							if (!i.isSustainNote)
							{
								coolNote = i;
								break;
							}
			
						if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
						{
							return;
						}
			
						if (dataNotes.length > 1) // stacked notes or really close ones
						{
							for (i in 0...dataNotes.length)
							{
								if (i == 0) // skip the first note
									continue;
			
								var note = dataNotes[i];
			
								if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
								{
									trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
									// just fuckin remove it since it's a stacked note and shouldn't be there
									note.kill();
									notes.remove(note, true);
									note.destroy();
								}
							}
						}
			
						goodNoteHit(coolNote);
						var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
					}
					else if (!FlxG.save.data.ghost && FlxG.keys.justPressed.ANY && songStarted && !grace)
						{
							noteMiss(data, null);
						}
			
		}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5),songPosBG.y,0,SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		
		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
			// pre lowercasing the song name (generateSong)
			var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
				switch (songLowercase) {
					case 'dad-battle': songLowercase = 'dadbattle';
					case 'philly-nice': songLowercase = 'philly';
				}

			var songPath = 'assets/data/' + songLowercase + '/';
			
			for(file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						trace('Found offset file: ' + path);
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else {
						trace('Offset file not found. Creating one @: ' + songPath);
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var mn:Int = keyAmmo[mania];
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % mn);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] >= mn)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var daType = songNotes[3];

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, daType);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daType);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...keyAmmo[mania])
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			//defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';
		
			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null) {
				switch(storyWeek) {case 6: noteTypeCheck = 'pixel';}
			} else {noteTypeCheck = SONG.noteStyle;}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom * Note.pixelnoteScale));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 4:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 5:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 6:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 7:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 8:
							babyArrow.x += Note.swagWidth * i;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						
					}
				
					case 'normal':
						{
							babyArrow.frames = Paths.getSparrowAtlas('noteassets/shaggy/NOTE_assets');
							babyArrow.animation.addByPrefix('green', 'arrowUP');
							babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
							babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
							babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
		
							babyArrow.antialiasing = FlxG.save.data.antialiasing;
							babyArrow.setGraphicSize(Std.int(babyArrow.width * Note.noteScale));
	
							var nSuf:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
							var pPre:Array<String> = ['left', 'down', 'up', 'right'];
								switch (mania)
								{
									case 1:
										nSuf = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
										pPre = ['left', 'up', 'right', 'yel', 'down', 'dark'];
	
									case 2:
										nSuf = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
										pPre = ['left', 'down', 'up', 'right', 'white', 'yel', 'violet', 'black', 'dark'];
										babyArrow.x -= Note.tooMuch;
	
								}
						
						babyArrow.x += Note.swagWidth * i;
						babyArrow.animation.addByPrefix('static', 'arrow' + nSuf[i]);
						babyArrow.animation.addByPrefix('pressed', pPre[i] + ' press', 24, false);
						babyArrow.animation.addByPrefix('confirm', pPre[i] + ' confirm', 24, false);
						}						
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			//babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			
			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;
			
			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}


	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	private var paused:Bool = false;

	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var currentBPM = 0;
	public var updateFrame = 0;



	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (generatedMusic)
			{
				for(i in notes)
				{
					var diff = i.strumTime - Conductor.songPosition;
					if (diff < 2650 && diff >= -2650)
					{
						i.active = true;
						i.visible = true;
					}
					else
					{
						i.active = false;
						i.visible = false;
					}
				}
			}
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		
		#if sys
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos',Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom',FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);
			for (i in luaWiggles)
			{
				trace('wiggle le gaming');
				i.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle','float');

			if (luaModchart.getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				iconShag.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				//iconP2.visible = true;
				iconShag.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...keyAmmo[mania])
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}

		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && !PlayStateChangeables.Optimize)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}

			case 'sky':
				var rotRate = curStep * 0.25;
				var rotRateSh = curStep / 9.5;
				var rotRateGf = curStep / 9.5 / 4;
				var derp = 12;
				var redsh_xpos = -630;
				var yellowsh_xpos = -480;
				var purplesh_xpos = -480;
				if (!songStarted)
				{
					camFollow.x = boyfriend.x - 300;
					camFollow.y = boyfriend.y - 40;
					derp = 20;
					rock2.x = boyfriend.x - 1000;
					rock2.y = boyfriend.y;

				}

				if (godCutEnd)
				{
					if (curStep < 255)
					{
						sh_r = 60;
					}
					else if ((curStep >= 1200 && curStep <= 1500) || (curStep >= 2880))
					{
						sh_r += (60 - sh_r) / 32;
					}
					else
					{
						sh_r = 600;
						redsh_xpos = -330;
						yellowsh_xpos = -480;
						purplesh_xpos = -460;
					}

					if ((curBeat >= 32 && curBeat < 48) || (curBeat >= 116 * 4 && curBeat < 132 * 4))
					{
						if (boyfriend.animation.curAnim.name.startsWith('idle'))
						{
							boyfriend.playAnim('scared', true);
						}
					}

					if ((curBeat >= 248 && curBeat <= 280) || (curBeat >= 375 && curBeat <= 471) || (curBeat >= 560 && curBeat <= 592))
					{
						rotRateSh *= 1.4;
						sh_r = 700;
					}
					else if ((curBeat >= 471 && curBeat <= 479) || (curBeat >= 592))
						{
							rotRateSh *= 1.2;
						}
					else if (curBeat >= 479 && curBeat <= 560)
						{
							rotRateSh *= 1.6;
							sh_r = 1000;
						}
					else if (curBeat < 66 * 4)
					{
						rotRateSh *= 1.2;
					}
					else if (curBeat < 116 * 4)
					{
					}
					else if (curBeat < 132 * 4)
					{
						rotRateSh *= 1.2;
					}
					var bf_toy = -2000 + Math.sin(rotRate) * 20;

					var sh_toy = -2450 + -Math.sin(rotRateSh * 2) * sh_r * 0.45;
					var sh_tox = -330 -Math.cos(rotRateSh) * sh_r;

					var redsh_toy = -2450 - -Math.sin(rotRateSh * 2) * sh_r * 0.45;
					var redsh_tox = redsh_xpos - -Math.cos(rotRateSh) * sh_r;

					var yellowsh_toy = -2950 + -Math.cos(rotRateSh) * sh_r;
					var yellowsh_tox = yellowsh_xpos -Math.sin(rotRateSh * 2) * sh_r * 0.45;

					var purplesh_toy = -1950 - -Math.cos(rotRateSh) * sh_r;
					var purplesh_tox = purplesh_xpos - -Math.sin(rotRateSh * 2) * sh_r * 0.45;

					var gf_tox = 100 + Math.sin(rotRateGf) * 200;
					var gf_toy = -2000 -Math.sin(rotRateGf) * 80;

					if (godMoveBf)
					{
						boyfriend.y += (bf_toy - boyfriend.y) / derp;
						rock.x = boyfriend.x - 200;
						rock.y = boyfriend.y + 200;
						rock.alpha = 1;
						rock2.alpha = 1;
						tiky.x = rock2.x + 900;
						tiky.y = rock2.y + 300;
						rock2.x = boyfriend.x - 100;
						rock2.y = boyfriend.y;

					}

					if (godMoveSh)
					{
						dad.x += (sh_tox - dad.x) / 12;
						dad.y += (sh_toy - dad.y) / 12;
						if (redshagfly == 1)
							{
								redshaggy.x += (redsh_tox - redshaggy.x) / 12;
								redshaggy.y += (redsh_toy - redshaggy.y) / 12;
								yellowshaggy.x += (yellowsh_tox - yellowshaggy.x) / 12;
								yellowshaggy.y += (yellowsh_toy - yellowshaggy.y) / 12;
								purpleshaggy.x += (purplesh_tox - purpleshaggy.x) / 12;
								purpleshaggy.y += (purplesh_toy - purpleshaggy.y) / 12;
								redshaggy.alpha = 1;
								redshaggyT.visible = true;
								yellowshaggy.alpha = 1;
								yellowshaggyT.visible = true;
								purpleshaggy.alpha = 1;
								purpleshaggyT.visible = true;
								tiky.alpha = 1;
								iconP2.visible = false;
								

								
							}
						else if (redshagfly == 0)
						{
							redshaggy.x = dad.x;
							redshaggy.y = dad.y;
							yellowshaggy.x = dad.x;
							yellowshaggy.y = dad.y;
							purpleshaggy.x = dad.x;
							purpleshaggy.y = dad.y;
							redshaggy.alpha = 0;
							redshaggyT.visible = false;
							yellowshaggy.alpha = 0;
							yellowshaggyT.visible = false;
							purpleshaggy.alpha = 0;
							purpleshaggyT.visible = false;
							iconP2.visible = true;
							iconShag.visible = false;
						}
						else if (redshagfly == 2)
							{
								redshaggy.x = dad.x;
								redshaggy.y = dad.y;
								yellowshaggy.x = dad.x;
								yellowshaggy.y = dad.y;
								purpleshaggy.x = dad.x;
								purpleshaggy.y = dad.y;
							}
	

					}

					if (godMoveGf)
					{
						gf.x += (gf_tox - gf.x) / derp;
						gf.y += (gf_toy - gf.y) / derp;

						gf_rock.x = gf.x + 80;
						gf_rock.y = gf.y + 530;
						gf_rock.alpha = 1;
						if (!gf_launched)
						{
							gf.scrollFactor.set(0.8, 0.8);
							gf.setGraphicSize(Std.int(gf.width * 0.8));
							gf_launched = true;
						}
					}
				}
				if (!godCutEnd || !godMoveBf)
				{
					rock.alpha = 0;
					rock2.alpha = 0;
					tiky.alpha = 0;
					purpleshaggy.alpha = 0;
					yellowshaggy.alpha = 0;
					redshaggy.alpha = 0;
					tiky.x = 4000;
				}
				if (!godMoveGf)
				{
					gf_rock.alpha = 0;
				}

				//for (i in 0...18)
				//	{
						//var note_toy = 0 + -Math.sin(rotRateSh * 2) * sh_r * 0.45;
						//var note_tox = ((Note.swagWidth * i) + 80) -Math.cos(rotRateSh) * sh_r;
						//strumlineNotes.members[i].x += (note_tox - strumlineNotes.members[i].x) / 12;
				//	}
	
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE#if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}


		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			cannotDie = true;
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			Main.editor = true;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if sys
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		iconShag.setGraphicSize(Std.int(FlxMath.lerp(150, iconShag.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();
		iconShag.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		iconShag.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconShag.width - iconOffset);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			{
				iconP2.animation.curAnim.curFrame = 1;
				iconShag.animation.curAnim.curFrame = 1;
			}

		else
			{
				iconP2.animation.curAnim.curFrame = 0;
				iconShag.animation.curAnim.curFrame = 0;
			}


		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if sys
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if sys
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			closestNotes = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					closestNotes.push(daNote);
			}); // Collect notes that can be hit

			closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (closestNotes.length != 0)
				FlxG.watch.addQuick("Current Note",closestNotes[0].strumTime - Conductor.songPosition);
			// Make sure Girlfriend cheers only for certain songs
			if(allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch(curSong)
					{
						case 'Philly Nice':
						{
							// General duration of the song
							if(curBeat < 250)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 184 && curBeat != 216)
								{
									if(curBeat % 16 == 8)
									{
										// Just a garantee that it'll trigger just once
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Bopeebo':
						{
							// Where it starts || where it ends
							if(curBeat > 5 && curBeat < 130)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
						case 'Blammed':
						{
							if(curBeat > 30 && curBeat < 190)
							{
								if(curBeat < 90 || curBeat > 128)
								{
									if(curBeat % 4 == 2)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Cocoa':
						{
							if(curBeat < 170)
							{
								if(curBeat < 65 || curBeat > 130 && curBeat < 145)
								{
									if(curBeat % 16 == 15)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Eggnog':
						{
							if(curBeat > 10 && curBeat != 111 && curBeat < 220)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
					}
				}
			}
			
			#if sys
			if (luaModchart != null)
				luaModchart.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if sys
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				//camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if sys
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				//if (!endingzoom)
					//FlxG.camera.zoom = 0.65;
				//else
					//FlxG.camera.zoom = 0.9;
				if (isredshaggy == true)
					camFollow.setPosition(redshaggy.getMidpoint().x + 250, dad.getMidpoint().y - 100);

				else if (isgreenshaggy == true)
				{
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				
					// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
	
					switch (dad.curCharacter)
					{
						case 'mom':
							camFollow.y = dad.getMidpoint().y;
						case 'senpai':
							camFollow.y = dad.getMidpoint().y - 430;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'senpai-angry':
							camFollow.y = dad.getMidpoint().y - 430;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'dad':
							camFollow.y = dad.getMidpoint().y - 100;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'pshaggy':
							camFollow.y = dad.getMidpoint().y + 0;
							camFollow.x = dad.getMidpoint().x + 100;
					}
				}
				else if (isyellowshaggy == true)
					{
						camFollow.setPosition(yellowshaggy.getMidpoint().x + 150, yellowshaggy.getMidpoint().y + 200);
					}
				else if (ispurpleshaggy == true)
					{
						camFollow.setPosition(purpleshaggy.getMidpoint().x + 150, purpleshaggy.getMidpoint().y - 200);
					}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if sys
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				//camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if sys
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
				//if (!endingzoom)
					//FlxG.camera.zoom = 0.65;
				//else
				//	FlxG.camera.zoom = 0.9;

				if (tikyactive)
					camFollow.setPosition(boyfriend.getMidpoint().x + 600, boyfriend.getMidpoint().y - 300);
				else
					camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}
			}
		}

		if (camZooming)
		{
			if (!executeModchart)
				{
					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
					camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
	
					camNotes.zoom = camHUD.zoom;
					camSustains.zoom = camHUD.zoom;
				}
				else
				{
					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
					camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
	
					camNotes.zoom = camHUD.zoom;
					camSustains.zoom = camHUD.zoom;
				}
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (health <= 0 && !cannotDie)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
 		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if(FlxG.keys.justPressed.R)
				{
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;
		
					vocals.stop();
					FlxG.sound.music.stop();
		
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
					#if windows
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
					#end
		
					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		switch(mania)
		{
			case 0: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
			case 1: 
				sDir = ['LEFT', 'UP', 'RIGHT', 'LEFT', 'DOWN', 'RIGHT'];
			case 2: 
				sDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP', 'LEFT', 'DOWN', 'UP', 'RIGHT'];
		}

		if (generatedMusic)
			{
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

				switch(mania)
				{
					case 0: 
						holdArray = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
					case 1: 
						holdArray = [controls.L1, controls.U1, controls.R1, controls.L2, controls.D1, controls.R2];
					case 2: 
						holdArray = [controls.N0, controls.N1, controls.N2, controls.N3, controls.N4, controls.N5, controls.N6, controls.N7, controls.N8];
				}
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					
					if (!daNote.modifiedByLua)
						{
							if (PlayStateChangeables.useDownscroll)
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
										+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) - daNote.noteYOff;
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) - daNote.noteYOff;
								if (daNote.isSustainNote)
								{
									// Remember = minus makes notes go up, plus makes them go down
									if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
										daNote.y += daNote.prevNote.height;
									else
										daNote.y += daNote.height / 2;
		
									// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
									if (!PlayStateChangeables.botPlay)
									{
										if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit || holdArray[Math.floor(Math.abs(daNote.noteData))] && !daNote.tooLate)
											&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
											swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
												+ Note.swagWidth / 2
												- daNote.y) / daNote.scale.y;
											swagRect.y = daNote.frameHeight - swagRect.height;
		
											daNote.clipRect = swagRect;
										}
									}
									else
									{
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
											+ Note.swagWidth / 2
											- daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;
		
										daNote.clipRect = swagRect;
									}
								}
							}
							else
							{
								if (daNote.mustPress)
									daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
										- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) + daNote.noteYOff;
								else
									daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
											2)) + daNote.noteYOff;
								if (daNote.isSustainNote)
								{
									daNote.y -= daNote.height / 2;
		
									if (!PlayStateChangeables.botPlay)
									{
										if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit || holdArray[Math.floor(Math.abs(daNote.noteData))] && !daNote.tooLate)
											&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
										{
											// Clip to strumline
											var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
											swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
												+ Note.swagWidth / 2
												- daNote.y) / daNote.scale.y;
											swagRect.height -= swagRect.y;
		
											daNote.clipRect = swagRect;
										}
									}
									else
									{
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
											+ Note.swagWidth / 2
											- daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;
		
										daNote.clipRect = swagRect;
									}
								}
							}
						}
		
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;

						var altAnim:String = "";
	
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}
							if (switchtimer)
								{
									new FlxTimer().start(2.5, function(tmr:FlxTimer)
										{
											switchtimer = false;
										});
								}
							if (daNote.noteType == 0)
							{
								if (!switchtimer)
									{
										isgreenshaggy = true;
										switchtimer = true;
										isredshaggy = false;
										isyellowshaggy = false;
										ispurpleshaggy = false;
									}
								dad.playAnim('sing' + sDir[daNote.noteData], true);
								dad.holdTimer = 0;
							}
							else if (daNote.noteType == 1)
								{
									if (!switchtimer)
										{
											isredshaggy = true;
											switchtimer = true;
											isgreenshaggy = false;
											isyellowshaggy = false;
											ispurpleshaggy = false;
										}
									redshaggy.playAnim('sing' + sDir[daNote.noteData], true);
									redshaggy.holdTimer = 0;
									}
							else if (daNote.noteType == 2)
								{
									if (!switchtimer)
										{
											isyellowshaggy = true;
											switchtimer = true;
											isgreenshaggy = false;
											isredshaggy = false;
											ispurpleshaggy = false;
										}
									yellowshaggy.playAnim('sing' + sDir[daNote.noteData], true);
									yellowshaggy.holdTimer = 0;
									}
							else if (daNote.noteType == 3)
								{
									if (!switchtimer)
										{
											ispurpleshaggy = true;
											switchtimer = true;
											isgreenshaggy = false;
											isyellowshaggy = false;
											isredshaggy = false;
										}
									purpleshaggy.playAnim('sing' + sDir[daNote.noteData], true);
									purpleshaggy.holdTimer = 0;
									}
							else if (daNote.noteType == 4)
								{
									tiky.playAnim('sing' + sDir[daNote.noteData], true);
									tiky.holdTimer = 0;
								}
							if (curSong.toLowerCase() == 'where-are-you')
								{
									if (daNote.isSustainNote)
										{
											health -= 0.005;
										} 
										else
											health -= 0.017;
								}
	
	
							
						
						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();

									if (SONG.mania == 0)
										{
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
									else if (SONG.mania == 1)
										{
											spr.offset.x -= 16;
											spr.offset.y -= 16;
										}
									else if (SONG.mania == 2)
										{
											spr.offset.x -= 22;
											spr.offset.y -= 22;
										}
								}
								else
									spr.centerOffsets();
							});
						}
	
						#if sys
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end


	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;


						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if (daNote.mustPress && !daNote.modifiedByLua)
						{
							daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
							daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
							if (!daNote.isSustainNote)
								daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
							if (daNote.sustainActive)
							{
								if (executeModchart)
									if (daNote.isSustainNote)
										daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha * 0.6;
									else
										daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
							}
							daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						}
						else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
						{
							daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
							daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
							if (!daNote.isSustainNote)
								daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
							if (daNote.sustainActive)
							{
								if (executeModchart)
									if (daNote.isSustainNote)
										daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha * 0.6;
									else
										daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
									
							}
							daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						}
		
						if (daNote.isSustainNote)
						{
							daNote.x += daNote.width / 2 + 20;
							if (SONG.noteStyle == 'pixel')
								daNote.x -= 11;
						}
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	

					if (daNote.burning)
						daNote.x -= 70;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
					if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}

	
					else if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
						&& PlayStateChangeables.useDownscroll)
						&& daNote.mustPress)
					{

						switch (daNote.noteType)
						{
					
							case 0: //normal
							{
								if (daNote.isSustainNote && daNote.wasGoodHit)
									{
										daNote.kill();
										notes.remove(daNote, true);
									}
									else
									{
										vocals.volume = 0;
										if (theFunne && !daNote.isSustainNote)
										{
											if (PlayStateChangeables.botPlay)
											{
												daNote.rating = "bad";
												goodNoteHit(daNote);
											}
											else
												noteMiss(daNote.noteData, daNote);
										}
			
										if (daNote.isParent)
										{
											health -= 0.15; // give a health punishment for failing a LN
											trace("hold fell over at the start");
											for (i in daNote.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
												trace(i.alpha);
										    }
										}
										else
										{
											if (!daNote.wasGoodHit
												&& daNote.isSustainNote
												&& daNote.sustainActive
												&& daNote.spotInLine != daNote.parent.children.length)
											{
												health -= 0.25; // give a health punishment for failing a LN
												trace("hold fell over at " + daNote.spotInLine);
												for (i in daNote.parent.children)
												{
													i.alpha = 0.3;
													i.sustainActive = false;
													trace(i.alpha);
												}
												if (daNote.parent.wasGoodHit)
													misses++;
												updateAccuracy();
											}
											else
											{
												health -= 0.15;
											}
										}
									}
			
									daNote.visible = false;
									daNote.kill();
									notes.remove(daNote, true);

							}
							case 5: 

								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
								//if (daNote.noteType == 5)
									//daNote.fireT.destroy();
							case 6: 
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							case 7: 
								health -= 1;
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							case 8: 
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							case 9: 
								HealthDrain();
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();

						}
					}
					if(PlayStateChangeables.useDownscroll && daNote.y > strumLine.y ||
						!PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
						{
								// Force good note hit regardless if it's too late to hit it or not as a fail safe
								if(PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress ||
								PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
								{
									switch (daNote.noteType)
									{
										case 0: 
											goodNoteHit(daNote);
											boyfriend.holdTimer = daNote.sustainLength;
										case 7: 
											goodNoteHit(daNote);
											boyfriend.holdTimer = daNote.sustainLength;
									}
									if (FlxG.save.data.cpuStrums)
									{
										playerStrums.forEach(function(spr:FlxSprite)
										{
										    if (Math.abs(daNote.noteData) == spr.ID)
											{
												spr.animation.play('confirm', true);
											}
												if (spr.animation.curAnim.name == 'confirm' && SONG.noteStyle != 'pixel')
												{
													spr.centerOffsets();
													switch(mania)
													{
														case 0: 
															spr.offset.x -= 13;
															spr.offset.y -= 13;
														case 1: 
															spr.offset.x -= 16;
															spr.offset.y -= 16;
														case 2: 
															spr.offset.x -= 22;
															spr.offset.y -= 22;
														case 3: 
															spr.offset.x -= 15;
															spr.offset.y -= 15;
														case 4: 
															spr.offset.x -= 18;
															spr.offset.y -= 18;
														case 5: 
															spr.offset.x -= 20;
															spr.offset.y -= 20;
														case 6: 
															spr.offset.x -= 13;
															spr.offset.y -= 13;
														case 7: 
															spr.offset.x -= 13;
															spr.offset.y -= 13;
														case 8:
															spr.offset.x -= 13;
															spr.offset.y -= 13;
													}
												}
												else
													spr.centerOffsets();
										});
									}
										
								}
							}
					
				});
			}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
			if (PlayStateChangeables.botPlay)
				{
					playerStrums.forEach(function(spr:FlxSprite)
						{
							if (spr.animation.finished)
							{
								spr.animation.play('static');
								spr.centerOffsets();
							}
						});
				}
		}

		if (!inCutscene && songStarted)
			keyShit();


		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN,handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (isStoryMode)
			campaignMisses = misses;

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if sys
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);
				
				new FlxTimer().start(0.003, function(fadear:FlxTimer)
					{
						var decAl:Float = 0.01;
						for (i in 0...strumLineNotes.length)
						{
							strumLineNotes.members[i].alpha -= decAl;
						}
						healthBarBG.alpha -= decAl;
						healthBar.alpha -= decAl;
						iconP1.alpha -= decAl;
						iconP2.alpha -= decAl;
						iconShag.alpha -= decAl;
						scoreTxt.alpha -= decAl;
						fadear.reset(0.003);
					});

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (SONG.song.toLowerCase() == 'godspeed')
						{
							finalCutscene();
						}
					else
						{
							if (FlxG.save.data.scoreScreen)
								openSubState(new ResultsScreen());
							else
							{
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
								FlxG.switchState(new MainMenuState());
							}
		
						}
					
					#if sys
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					// if ()
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					FlxG.save.flush();
				}
				else
				{
					
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat) {
						case 'Dad-Battle': songFormat = 'Dadbattle';
						case 'Philly-Nice': songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);

					if (StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;


					PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}

			else
			{
				if (SONG.song.toLowerCase() == 'godspeed')
					{

					}
				else 
					{
						trace('WENT BACK TO FREEPLAY??');

						paused = true;
		
		
						FlxG.sound.music.stop();
						vocals.stop();
		
						if (FlxG.save.data.scoreScreen)
							openSubState(new ResultsScreen());
						else
							FlxG.switchState(new FreeplayState());
					}
				
			}
		}
	}


	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
			var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					combo = 0;
					misses++;
					health -= 0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}
	
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(PlayStateChangeables.botPlay) msTiming = 0;		

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if(!PlayStateChangeables.botPlay) add(currentTimingShown);
			
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if(!PlayStateChangeables.botPlay) add(rating);
	
			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				add(numScore);
	
				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function (tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for(i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
			}
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	
		var l1Hold:Bool = false;
		var uHold:Bool = false;
		var r1Hold:Bool = false;
		var l2Hold:Bool = false;
		var dHold:Bool = false;
		var r2Hold:Bool = false;
	
		var n0Hold:Bool = false;
		var n1Hold:Bool = false;
		var n2Hold:Bool = false;
		var n3Hold:Bool = false;
		var n4Hold:Bool = false;
		var n5Hold:Bool = false;
		var n6Hold:Bool = false;
		var n7Hold:Bool = false;
		var n8Hold:Bool = false;
		// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

		private function keyShit():Void // I've invested in emma stocks
			{
				//var control = PlayerSettings.player1.controls;
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P

				];
				var releaseArray:Array<Bool> = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
				if (SONG.mania == 1)
					{
						holdArray = [controls.L1, controls.U1, controls.R1, controls.L2, controls.D1, controls.R2];
						pressArray = [
							controls.L1_P,
							controls.U1_P,
							controls.R1_P,
							controls.L2_P,
							controls.D1_P,
							controls.R2_P
						];
						releaseArray = [
							controls.L1_R,
							controls.U1_R,
							controls.R1_R,
							controls.L2_R,
							controls.D1_R,
							controls.R2_R
						];
					}
				else if (SONG.mania == 2)
					{
						holdArray = [
						    controls.N0 || _hitbox.buttonLeft.pressed,
						    controls.N1 || _hitbox.buttonDown.pressed,
						    controls.N2 || _hitbox.buttonUp.pressed,
						    controls.N3 || _hitbox.buttonRight.pressed,
						    controls.N4 || _hitbox.buttonUp2.pressed,
						    controls.N5 || _hitbox.buttonRight2.pressed,
						    controls.N6 || _hitbox.buttonLeft2.pressed,
						    controls.N7 || _hitbox.buttonDown2.pressed,
						    controls.N8 || _hitbox.buttonLeft3.pressed
						];
						pressArray = [
							controls.N0_P || _hitbox.buttonLeft.justPressed,
							controls.N1_P || _hitbox.buttonDown.justPressed,
							controls.N2_P || _hitbox.buttonUp.justPressed,
							controls.N3_P || _hitbox.buttonRight.justPressed,
							controls.N4_P || _hitbox.buttonUp2.justPressed,
							controls.N5_P || _hitbox.buttonRight2.justPressed,
							controls.N6_P || _hitbox.buttonLeft2.justPressed,
							controls.N7_P || _hitbox.buttonDown2.justPressed,
							controls.N8_P || _hitbox.buttonLeft3.justPressed
						];
						releaseArray = [
							controls.N0_R || _hitbox.buttonLeft.justReleased,
							controls.N1_R || _hitbox.buttonDown.justReleased,
							controls.N2_R || _hitbox.buttonUp.justReleased,
							controls.N3_R || _hitbox.buttonRight.justReleased,
							controls.N4_R || _hitbox.buttonUp2.justReleased,
							controls.N5_R || _hitbox.buttonRight2.justReleased,
							controls.N6_R || _hitbox.buttonLeft2.justReleased,
							controls.N7_R || _hitbox.buttonDown2.justReleased,
							controls.N8_R || _hitbox.buttonLeft3.justReleased
						];
					}
				#if sys
				if (luaModchart != null){
				
				if (SONG.mania == 0)
					{
						if (controls.LEFT_P){luaModchart.executeState('keyPressed',["left"]);};
						if (controls.DOWN_P){luaModchart.executeState('keyPressed',["down"]);};
						if (controls.UP_P){luaModchart.executeState('keyPressed',["up"]);};
						if (controls.RIGHT_P){luaModchart.executeState('keyPressed',["right"]);};
					}
				else if (SONG.mania == 1)
					{
						if (controls.L1_P){luaModchart.executeState('keyPressed',["left"]);};
						if (controls.U1_P){luaModchart.executeState('keyPressed',["up"]);};
						if (controls.R1_P){luaModchart.executeState('keyPressed',["right"]);};
						if (controls.L2_P){luaModchart.executeState('keyPressed',["left"]);};
						if (controls.D1_P){luaModchart.executeState('keyPressed',["down"]);};
						if (controls.R2_P){luaModchart.executeState('keyPressed',["right"]);};
					}
				else if (SONG.mania == 2)
					{
						if (controls.N0_P || _hitbox.buttonLeft.justPressed){luaModchart.executeState('keyPressed',["left"]);};
						if (controls.N1_P || _hitbox.buttonDown.justPressed){luaModchart.executeState('keyPressed',["down"]);};
						if (controls.N2_P || _hitbox.buttonUp.justPressed){luaModchart.executeState('keyPressed',["up"]);};
						if (controls.N3_P || _hitbox.buttonRight.justPressed){luaModchart.executeState('keyPressed',["right"]);};
						if (controls.N4_P || _hitbox.buttonUp2.justPressed){luaModchart.executeState('keyPressed',["up"]);};
						if (controls.N5_P || _hitbox.buttonRight2.justPressed){luaModchart.executeState('keyPressed',["left"]);};
						if (controls.N6_P || _hitbox.buttonLeft2.justPressed){luaModchart.executeState('keyPressed',["down"]);};
						if (controls.N7_P || _hitbox.buttonDown2.justPressed){luaModchart.executeState('keyPressed',["up"]);};
						if (controls.N8_P || _hitbox.buttonLeft3.justPressed){luaModchart.executeState('keyPressed',["left"]);};
					}
					
				};
				#end
		 
				
				// Prevent player input if botplay is on
				if(PlayStateChangeables.botPlay)
				{
					holdArray = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
					pressArray = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
					releaseArray = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
				}

				// HOLDS, check for sustain notes
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idle');
				}
		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
						spr.animation.play('pressed', false);
					if (!holdArray[spr.ID])
						spr.animation.play('static', false);
						
			
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						if (SONG.mania == 0)
							{
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
						else if (SONG.mania == 1)
							{
								spr.offset.x -= 16;
								spr.offset.y -= 16;
							}
						else if (SONG.mania == 2)
							{
								spr.offset.x -= 22;
								spr.offset.y -= 22;
							}
					}
					else
						spr.centerOffsets();
				});
			}

			public var fuckingVolume:Float = 1;

			public var playingDathing = false;

			public var videoSprite:FlxSprite;

			public function focusOut() {
				if (paused)
					return;
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
		
					if (FlxG.sound.music != null)
					{
						FlxG.sound.music.pause();
						vocals.pause();
					}
		
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			public function focusIn() 
			{ 
				// nada 
			}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			//var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			//var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.playAnim('sing' + sDir[direction] + 'miss', true);

			#if sys
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end


			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	*/
	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

			note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note, (mashing > getKeyPresses(note)));
				
				/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false);*/

			}
		}

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if (note.rating == "miss")
					return;	

				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;

				if (mashViolations < 0)
					mashViolations = 0;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;
	

					boyfriend.playAnim('sing' + sDir[note.noteData], true);
					boyfriend.holdTimer = 0;

		
					#if sys
					if (luaModchart != null)
						luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
					#end
					
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
					if (note.noteType == 5)
						{
							health -= 0.45;
							FlxG.sound.play(Paths.sound("burnSound", 'shared'), 1);
						}
					if (note.noteType == 6)
						{
							health -= 100;
						}
					if (note.noteType == 8)
						{
							HealthDrain();
						}

					if (!note.isSustainNote)
						{
							note.kill();
							notes.remove(note, true);
							note.destroy();
						}
						else
						{
							note.wasGoodHit = true;
						}
					
					updateAccuracy();

					if (FlxG.save.data.gracetmr)
						{
							grace = true;
							new FlxTimer().start(0.15, function(tmr:FlxTimer)
							{
								grace = false;
							});
						}


				}
			}
		

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if(FlxG.save.data.distractions){
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if(FlxG.save.data.distractions){
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if(FlxG.save.data.distractions){
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if(FlxG.save.data.distractions){
			if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
		}

	}

	function trainReset():Void
	{
		if(FlxG.save.data.distractions){
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function HealthDrain():Void //code from vs bob
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				health -= 0.005;
			}, 300);
		}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	var stepOfLast = 0;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
		if (SONG.song.toLowerCase() == "godspeed" && curStep != stepOfLast) //song events
			{
				switch(curStep)
				{
					case 1: 
						camFollow.setPosition(dad.getMidpoint().x + 250, dad.getMidpoint().y - 100);
						dad.playAnim('idle', true);
					case 1119: //1119

					case 1172: 
						add(bfT);
					case 1256: 
						remove(bfT);
					case 1258: //1258
						for (i in 0...9)
							{
								FlxTween.tween(strumLineNotes.members[i], {alpha: 1}, 2);
							}
					case 1992: 
						add(bfT);
					case 2166: 
						remove(bfT);
					case 2367: 

					case 2431: 
						endingzoom = true;
					case 2485:

					case 2560:

					case 2615: 

					case 2688: 

					case 2740: 

					case 2815: 

					case 2870: 

					case 2880:
						endingzoom = true;
					case 3007: 
						FlxG.sound.play(Paths.sound('shagFly'));
						redshagfly = 5;
						FlxTween.tween(redshaggy, {x: dad.x}, 0.3);
						FlxTween.tween(redshaggy, {y: dad.y}, 0.3);
						FlxTween.tween(yellowshaggy, {x: dad.x}, 0.3);
						FlxTween.tween(yellowshaggy, {y: dad.y}, 0.3);
						FlxTween.tween(purpleshaggy, {x: dad.x}, 0.3);
						FlxTween.tween(purpleshaggy, {y: dad.y}, 0.3);
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								purpleshaggyT.visible = false;
								yellowshaggyT.visible = false;
								redshaggyT.visible = false;
								purpleshaggy.visible = false;
								yellowshaggy.visible = false;
								redshaggy.visible = false;
								remove(redshaggy);
								remove(yellowshaggy);
								remove(purpleshaggy);
							});


					case 576: //tiky stuff
						tikyactive = true;
					case 704: //tiky end
						tikyactive = false;
					case 2430: 
						tikyactive = true;
					case 2559:
						tikyactive = false;
				}

			}

		if (SONG.song.toLowerCase() == "where-are-you" && curStep != stepOfLast) //song events
			{
				switch(curStep)
				{
					case 288: 

					case 532: 

					case 992: 
						FlxG.sound.play(Paths.sound("burst"), 1);
						
				}
			}
		#if sys
		if (executeModchart && luaModchart != null)
		{
			
			luaModchart.setVar('curStep',curStep);
			luaModchart.executeState('stepHit',[curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		#end

	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var appearscreen:Bool = true;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if sys
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat',curBeat);
			luaModchart.executeState('beatHit',[curBeat]);
		}
		#end

		if (curSong == 'Tutorial' && dad.curCharacter == 'gf') {
			if (curBeat % 2 == 1 && dad.animOffsets.exists('danceLeft'))
				dad.playAnim('danceLeft');
			if (curBeat % 2 == 0 && dad.animOffsets.exists('danceRight'))
				dad.playAnim('danceRight');
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && dad.curCharacter != 'gf')
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				//FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.05;
			}
	
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		iconShag.setGraphicSize(Std.int(iconShag.width + 30));
			
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		iconShag.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}
		

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				boyfriend.playAnim('hey', true);
				dad.playAnim('cheer', true);
			}
		if (FlxG.save.data.popups)
			{
				if (curSong.toLowerCase() == 'godspeed' && curBeat >= 200 && curBeat <= 592)
					{
						var amount = curBeat/20;
						if (FlxG.random.bool(amount) && appearscreen)
						{
							var randomthing:FlxSprite = new FlxSprite(FlxG.random.int(300, 1077), FlxG.random.int(0, 622));
							FlxG.sound.play(Paths.sound("pop_up"), 1);
							randomthing.loadGraphic(Paths.image('PopUps/popup' + FlxG.random.int(1,9)));
							randomthing.updateHitbox();
							randomthing.alpha = 0;
							randomthing.antialiasing = true;
							add(randomthing);
							randomthing.cameras = [camNotes];
							appearscreen = false;
							FlxTween.tween(randomthing, {width: 1, alpha: 1}, 0.2, {ease: FlxEase.sineOut});
		
							new FlxTimer().start(4.5 , function(tmr:FlxTimer)
							{
								appearscreen = true;
							});
							new FlxTimer().start(3 , function(tmr:FlxTimer)
							{
								remove(randomthing);
							});
						}
					}
				if (curSong.toLowerCase() == 'where-are-you' && curBeat >= 50)
					{
						var amount = curBeat/20;
						if (FlxG.random.bool(amount) && appearscreen)
						{
							var randomthing:FlxSprite = new FlxSprite(FlxG.random.int(300, 1077), FlxG.random.int(0, 622));
							FlxG.sound.play(Paths.sound("pop_up"), 1);
							randomthing.loadGraphic(Paths.image('PopUps/popup' + FlxG.random.int(1,9)));
							randomthing.updateHitbox();
							randomthing.alpha = 0;
							randomthing.antialiasing = true;
							add(randomthing);
							randomthing.cameras = [camNotes];
							appearscreen = false;
							FlxTween.tween(randomthing, {width: 1, alpha: 1}, 0.2, {ease: FlxEase.sineOut});
		
							new FlxTimer().start(4.5 , function(tmr:FlxTimer)
							{
								appearscreen = true;
							});
							new FlxTimer().start(3 , function(tmr:FlxTimer)
							{
								remove(randomthing);
							});
						}
					}
			}
		
		switch (curStage)
		{
			case 'school':
				if(FlxG.save.data.distractions){
					bgGirls.dance();
				}

			case 'mall':
				if(FlxG.save.data.distractions){
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if(FlxG.save.data.distractions){
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});
		
						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
				}
			case "philly":
				if(FlxG.save.data.distractions){
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});
	
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
	
						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
				}

				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if(FlxG.save.data.distractions){
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}


		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if(FlxG.save.data.distractions){
				lightningStrikeShit();
			}
		}
	}
	var cs_time:Int = 0;
	var cs_wait:Bool = false;
	var cs_zoom:Float = 1;
	var cs_slash_dim:FlxSprite;
	var cs_sfx:FlxSound;
	var cs_mus:FlxSound;
	var sh_body:FlxSprite;
	var sh_head:FlxSprite;
	var cs_cam:FlxObject;
	var cs_black:FlxSprite;
	var sh_ang:FlxSprite;
	var sh_ang_eyes:FlxSprite;
	var cs_bg:FlxSprite;
	var curLight:Int = 0;
	var toDfS:Float = 1;
	public function finalCutscene()
		{
			cs_zoom = defaultCamZoom;
			cs_cam = new FlxObject(0, 0, 1, 1);
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			cs_cam.x = camFollow.x;
			cs_cam.y = camFollow.y;
			add(cs_cam);
			remove(camFollow);
			camFollow.destroy();
			FlxG.camera.follow(cs_cam, LOCKON, 0.01);
	
			new FlxTimer().start(0.002, function(tmr:FlxTimer)
			{
				switch (cs_time)
				{
					case 200:
						cs_cam.x -= 500;
						cs_cam.y -= 200;
						
					case 400:
						dad.playAnim('smile');
	
					case 700:
						if (!FlxG.save.data.beatenGodS)
							{
								FlxG.save.data.beatenGodS = true;
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
								FlxG.switchState(new EndThingState());
							}
						else
							{
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
								FlxG.switchState(new MainMenuState());
							}
						


				}
				FlxG.camera.zoom += (cs_zoom - FlxG.camera.zoom) / 12;
				if (!cs_wait)
				{
					cs_time ++;
				}
	
				tmr.reset(0.002);
			});
		}
}

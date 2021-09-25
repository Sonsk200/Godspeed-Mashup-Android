package;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;


using StringTools;

class ResultsScreen extends FlxSubState
{
    public var background:FlxSprite;
    public var text:FlxText;

    public var comboText:FlxText;
    public var contText:FlxText;
    public var settingsText:FlxText;

    public var music:FlxSound;

    public var ranking:String;
    public var accuracy:String;

	override function create()
	{	
        background = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        background.scrollFactor.set();
        add(background);

        music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		music.volume = 0;
		music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));

        background.alpha = 0;

        text = new FlxText(20,-55,0,"Song Cleared!");
        text.size = 34;
        text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        text.color = FlxColor.WHITE;
        text.scrollFactor.set();
        add(text);

        var score = PlayState.instance.songScore;
        if (PlayState.isStoryMode)
        {
            score = PlayState.campaignScore;
            text.text = "Week Cleared!";
        }

        comboText = new FlxText(20,-75,0,'Judgements:\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\n\nScore: ${PlayState.instance.songScore}\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.instance.accuracy,2)}%\n\n${Ratings.GenerateLetterRank(PlayState.instance.accuracy)}
        ');
        comboText.size = 28;
        comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        comboText.color = FlxColor.WHITE;
        comboText.scrollFactor.set();
        add(comboText);

        contText = new FlxText(FlxG.width - 475,FlxG.height + 50,0,'Press to continue.');
        contText.size = 28;
        contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        contText.color = FlxColor.WHITE;
        contText.scrollFactor.set();
        add(contText);

        var sicks = HelperFunctions.truncateFloat(PlayState.sicks / PlayState.goods,1);
        var goods = HelperFunctions.truncateFloat(PlayState.goods / PlayState.bads,1);

        if (sicks == Math.POSITIVE_INFINITY)
            sicks = 0;
        if (goods == Math.POSITIVE_INFINITY)
            goods = 0;

        settingsText = new FlxText(20,FlxG.height + 50,0,'Ratio (SA/GA): ${Math.round(sicks)}:1 ${Math.round(goods)}:1 | Played on ${PlayState.SONG.song} ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}');
        settingsText.size = 16;
        settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
        settingsText.color = FlxColor.WHITE;
        settingsText.scrollFactor.set();
        add(settingsText);


        FlxTween.tween(background, {alpha: 0.5},0.5);
        FlxTween.tween(text, {y:20},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(contText, {y:FlxG.height - 45},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(settingsText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}


    var frames = 0;

	override function update(elapsed:Float)
	{
        if (music.volume < 0.5)
			music.volume += 0.01 * elapsed;

        // keybinds

        if (PlayerSettings.player1.controls.ACCEPT)
        {
            music.fadeOut(0.3);

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Dad-Battle': songHighscore = 'Dadbattle';
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            if (PlayState.isStoryMode)
            {
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
                FlxG.switchState(new MainMenuState());
            }
            else
                FlxG.switchState(new FreeplayState());
        }

		super.update(elapsed);
		
	}
}

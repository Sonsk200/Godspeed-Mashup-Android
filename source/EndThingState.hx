package;
import flixel.*;
class EndThingState extends MusicBeatState
{

	public function new() 
	{
		super();
	}
	override function create() 
	{
		super.create();
		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image("endscreen"));
		add(bg);
		bg.screenCenter();
	}
	override function update(elapsed:Float) 
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER){
			FlxG.switchState(new MainMenuState());
		}
	}
}
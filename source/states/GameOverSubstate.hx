package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

import ui.*;
using StringTools;
class GameOverSubstate extends MusicBeatSubstate
{
	var lines:Array<String> = [
		"heroesalwayslose",
		"laugh1",
		"laugh2",
		"kickyourbutt",
	];
	var bf:Character;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(who:String,x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}
		switch(who){
			case 'crow' | 'crowDeathpod' | 'crowhelmetless' | 'crow-nogf':
				stageSuffix = '-nef';
				daBf = who;
		}

		super();

		Conductor.songPosition = 0;

		bf = new Character(x, y, daBf, true);
		if(!daBf.startsWith("bf")){
			bf.flipX = !bf.flipX;
			bf.flip();
		}

		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if(daBf.startsWith("bf")){
			FlxG.camera.shake(0.01,0.2);
			FlxG.camera.zoom = 2.6;
			FlxG.camera.follow(camFollow, LOCKON, 1);
			FlxG.camera.snapToTarget();
		}

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, Main.adjustFPS(0.01));
		}
		if(bf.animation.curAnim.name!='firstDeath' || bf.animation.curAnim.curFrame >= 8 ){
			if(bf.curCharacter.startsWith("bf"))
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom,1, Main.adjustFPS(0.05));
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			if(bf.curCharacter.startsWith("bf")){
				var voiceLine = lines[FlxG.random.int(0,lines.length-1)];
				FlxG.sound.play(Paths.sound('voices/${voiceLine}'));
			}
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (bf.animation.curAnim.name == 'deathLoop' && bf.animation.curAnim.finished)
		{
			bf.playAnim('deathLoop');
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}

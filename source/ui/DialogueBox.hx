package ui;

import ui.*;
import states.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:TypingText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextLine:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), 0xFFFFFFFF);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		bgFade.setGraphicSize(Std.int(bgFade.width*(1+(1-FlxG.camera.zoom))));
		add(bgFade);

		FlxTween.tween(bgFade, {alpha: 0.3}, 2.075, {
			ease: FlxEase.linear
		});

		box = new FlxSprite(-20, 45);
		var hasDialog = true;
		box.loadGraphic(Paths.image("text_box"));

		if(PlayState.SONG.song.toLowerCase()=='thorns' || PlayState.SONG.song.toLowerCase()=='roses' || PlayState.SONG.song.toLowerCase()=='senpai')
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		else
			box.setGraphicSize(Std.int(box.width*(1+(1-FlxG.camera.zoom))));

		box.updateHitbox();
		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		portraitLeft = new FlxSprite(0, 40);
		portraitLeft.loadGraphic(Paths.image("ports/crow/normal"));
		portraitLeft.updateHitbox();
		portraitLeft.antialiasing=true;
		portraitLeft.scrollFactor.set();
		portraitLeft.visible = false;
		portraitLeft.scale.set(0.8,0.8);

		portraitRight = new FlxSprite(Std.int(FlxG.width/2), 40);
		portraitRight.loadGraphic(Paths.image("ports/bf/normal"));
		portraitRight.updateHitbox();
		portraitRight.antialiasing=true;
		portraitRight.scrollFactor.set();
		portraitRight.visible = false;
		portraitRight.scale.set(0.75,0.75);

		add(box);
		box.screenCenter(XY);
		box.y += 200;
		portraitRight.y += 325;
		portraitRight.x += 285;
		portraitLeft.x -= 75;
		portraitLeft.y += 325;


		add(portraitLeft);
		add(portraitRight);


		if (!talkingRight)
		{
			//box.flipX = true;
		}

		dropText = new FlxText(222, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.setGraphicSize(Std.int(dropText.width*(1+(1-FlxG.camera.zoom))));
		dropText.setFormat(Paths.font("silverage.ttf"), 32);

		dropText.color = 0xFFD89494;
		//add(dropText);

		swagDialogue = new TypingText(220, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.soundChance = 65;
		swagDialogue.setGraphicSize(Std.int(swagDialogue.width*(1+(1-FlxG.camera.zoom))));
		swagDialogue.setFormat(Paths.font("silverage.ttf"), 32);

		swagDialogue.color = 0xFFFFFF;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;
		dialogueOpened=true;

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.E  && dialogueStarted == true)
		{
			remove(dialogue);

			//FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	var curLeft = '';
	var curRight = '';
	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		if(nextLine!=null)
			nextLine();
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.05, true);

		var dir = curCharacter.split("/");

		switch(dir[0]){
			case "crow":
				portraitRight.visible = false;
				if(!portraitLeft.visible){
					portraitLeft.visible=true;
				}
				portraitLeft.loadGraphic(Paths.image('ports/${curCharacter}'));
				portraitLeft.scale.set(0.75,0.75);
			default:
				portraitLeft.visible = false;
				if(!portraitRight.visible){
					portraitRight.visible=true;
				}
				portraitRight.loadGraphic(Paths.image('ports/${curCharacter}'));
				portraitRight.scale.set(0.75,0.75);
		}


		swagDialogue.sounds = [FlxG.sound.load(Paths.sound("soundbytes/" + dir[0]), 1)];
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[0].toLowerCase();
		splitName.shift();
		dialogueList[0] = splitName.join(":");
	}
}

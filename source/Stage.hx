package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxBasic;
import states.*;

import Shaders;

class Stage extends FlxTypedGroup<FlxBasic> {
  public static var songStageMap:Map<String,String> = [
    "test"=>"stage",
    "tutorial"=>"stage",
  ];

  public static var stageNames:Array<String> = [
    "stage",
    "macrocity",
    "deathpod",
    "airship",
    "airshipHero",
    "airshipVillain",
    "blank"
  ];

  public var doDistractions:Bool = true;

  // macro city
  var robotGoinLeft:Bool = false;
  var robotGoin:Bool = false;
  var fuckyoustupidbot:FlxSprite;
  var clouds1:FlxSprite;
  var clouds2:FlxSprite;
  var clouds3:FlxSprite;
  // misc, general bg stuff

  public var bfPosition:FlxPoint = FlxPoint.get(770,450);
  public var dadPosition:FlxPoint = FlxPoint.get(100,100);
  public var gfPosition:FlxPoint = FlxPoint.get(400,130);
  public var camPos:FlxPoint = FlxPoint.get(100,100);
  public var camOffset:FlxPoint = FlxPoint.get(100,100);

  public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
    "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
    "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
    "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
  ];
  public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
  public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still

  public var boppers:Array<Array<Dynamic>> = []; // should contain [sprite, bopAnimName, whichBeats]
  public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

  public var defaultCamZoom:Float = 1.05;

  public var curStage:String = '';

  // other vars
  public var gfVersion:String = 'gf';
  public var gf:Character;
  public var boyfriend:Character;
  public var dad:Character;
  public var currentOptions:Options;
  public var centerX:Float = -1;
  public var centerY:Float = -1;

  override public function destroy(){
    bfPosition = FlxDestroyUtil.put(bfPosition);
    dadPosition = FlxDestroyUtil.put(dadPosition);
    gfPosition = FlxDestroyUtil.put(gfPosition);
    camOffset =  FlxDestroyUtil.put(camOffset);

    super.destroy();
  }

  function robotMove():Void {
    robotGoin=true;
    robotGoinLeft = !robotGoinLeft;
    fuckyoustupidbot.visible=true;
    if(robotGoinLeft){
      fuckyoustupidbot.flipX=true;
      fuckyoustupidbot.x = 1600;
      fuckyoustupidbot.velocity.x = -(FlxG.random.int(30, 60) / FlxG.elapsed) * 0.3;
    }else{
      fuckyoustupidbot.flipX=false;
      fuckyoustupidbot.x = -1600;
      fuckyoustupidbot.velocity.x = (FlxG.random.int(30, 60) / FlxG.elapsed) * 0.3;
    }
    new FlxTimer().start(7, function(tmr:FlxTimer)
    {
      resetRobot();
    });
  }

  function resetRobot() : Void {
    robotGoin = false;
    fuckyoustupidbot.velocity.x = 0;
    fuckyoustupidbot.x = 12600;
    fuckyoustupidbot.visible=false;
  }


  public function setPlayerPositions(?p1:Character,?p2:Character,?gf:Character){

    if(p1!=null)p1.setPosition(bfPosition.x,bfPosition.y);
    if(gf!=null)gf.setPosition(gfPosition.x,gfPosition.y);
    if(p2!=null){
      p2.setPosition(dadPosition.x,dadPosition.y);
      camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
    }

    if(p1!=null){
      switch(p1.curCharacter){

      }
    }

    if(p2!=null){

      switch(p2.curCharacter){
        case 'gf':
          if(gf!=null){
            p2.setPosition(gf.x, gf.y);
            gf.visible = false;
          }
        case 'dad':
          camPos.x += 400;
        case 'pico':
          camPos.x += 600;
        case 'senpai' | 'senpai-angry':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'spirit':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'bf-pixel':
          camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
      }
    }

    if(p1!=null){
      p1.x += p1.posOffset.x;
      p1.y += p1.posOffset.y;
    }
    if(p2!=null){
      p2.x += p2.posOffset.x;
      p2.y += p2.posOffset.y;
    }


  }

  public function new(stage:String,currentOptions:Options){
    super();
    if(stage=='halloween')stage='spooky'; // for kade engine shenanigans
    curStage=stage;
    this.currentOptions=currentOptions;

    overlay.scrollFactor.set(0,0); // so the "overlay" layer stays static

    switch (stage){
      case 'macrocity':
        defaultCamZoom = .9;
        curStage = 'macrocity';
        gfPosition.y += 250;
        bfPosition.y -= 50;
        dadPosition.y -= 50;
        var bg:FlxSprite = new FlxSprite(-300, -50).loadGraphic(Paths.image('macrocity/MC2',"crow"));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.3, 0.3);
        bg.active = false;
        bg.setGraphicSize(Std.int(bg.width * 0.75));
        bg.updateHitbox();
        add(bg);

        var MC1:FlxSprite = new FlxSprite(-600, -300).loadGraphic(Paths.image('macrocity/MC1',"crow"));
        MC1.active = false;
        MC1.antialiasing = true;
        add(MC1);

        var carBlue:FlxSprite = new FlxSprite(1000, 400);
        carBlue.frames = Paths.getSparrowAtlas('macrocity/CarBlue',"crow");
        carBlue.animation.addByPrefix('durdurdur',"CarBlue", 24);
        carBlue.animation.play('durdurdur');
        add(carBlue);

        var TAXI:FlxSprite = new FlxSprite(-100, 400);
        TAXI.frames = Paths.getSparrowAtlas('macrocity/TAXI','crow');
        TAXI.animation.addByPrefix('assassass', "TAXI", 24);
        TAXI.animation.play('assassass');
        add(TAXI);

        fuckyoustupidbot =new FlxSprite(-1000, 75);
        fuckyoustupidbot.frames = Paths.getSparrowAtlas('macrocity/PoliceRobot',"crow");
        fuckyoustupidbot.animation.addByPrefix('fuck', "PoliceRobot", 24);
        fuckyoustupidbot.animation.play('fuck');
        add(fuckyoustupidbot);

        centerX = 775;
        centerY = 300;
      case 'deathpod':
        defaultCamZoom = .6;
        //centerX

        bfPosition.x = 2075;
        bfPosition.y = 700;

        gfPosition.x = 900;
        gfPosition.y = 35;

        dadPosition.x = 350;
        dadPosition.y = 35;

        var baseX:Float = 75;
        var baseY:Float = 0;

        var bg:FlxSprite = new FlxSprite(-1000, -1000).loadGraphic(Paths.image('deathpod/BGSky',"crow"));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.05, 0.05);
        bg.updateHitbox();
        add(bg);

        clouds1 = new FlxSprite(-600, -200).loadGraphic(Paths.image('deathpod/BGClouds',"crow"));
        clouds1.antialiasing = true;
        clouds1.velocity.x = 5000;
        clouds1.scrollFactor.set(0.9, 0.9);
        clouds1.updateHitbox();
        clouds1.scale.set(1.2,1.2);
        clouds1.updateHitbox();
        foreground.add(clouds1);

        clouds2 = new FlxSprite(1900, -300).loadGraphic(Paths.image('deathpod/BGClouds',"crow"));
        clouds2.antialiasing = true;
        clouds2.velocity.x = 4000;
        clouds2.scrollFactor.set(0.25, 0.25);
        clouds2.scale.set(.9,.9);
        clouds2.updateHitbox();
        add(clouds2);

        clouds3 = new FlxSprite(400, -300).loadGraphic(Paths.image('deathpod/BGClouds',"crow"));
        clouds3.antialiasing = true;
        clouds3.velocity.x = 3250;
        clouds3.scrollFactor.set(0.3, 0.3);
        clouds3.updateHitbox();
        add(clouds3);


        var chain:FlxSprite = new FlxSprite(1000,800).loadGraphic(Paths.image("deathpod/Chain","crow"));
        chain.scale.set(-1,1);
        chain.scrollFactor.set(1,1);
        chain.antialiasing = true;
        chain.updateHitbox();
        add(chain);

        var ball:FlxSprite = new FlxSprite(1800,1030).loadGraphic(Paths.image("deathpod/WreckingBall","crow"));
        ball.scale.set(-1,1);
        ball.scrollFactor.set(1,1);
        ball.antialiasing = true;
        ball.updateHitbox();
        add(ball);

        var pod:FlxSprite = new FlxSprite(0,0);
        pod.antialiasing=true;
        pod.frames = Paths.getSparrowAtlas('deathpod/Pod','crow');
        pod.animation.addByPrefix("idle","DeathPod Open",30,true);
        pod.animation.play("idle",true);
        pod.scrollFactor.set(1,1);
        pod.scale.set(-1.3,1.3);
        add(pod);

        var fire:FlxSprite = new FlxSprite(800,700);
        fire.antialiasing=true;
        fire.frames = Paths.getSparrowAtlas('deathpod/FireTHing','crow');
        fire.animation.addByIndices("idle","FireThing", [7,8,9,10,11,12,13], "", 24, true);
        fire.animation.play("idle",true);
        fire.angle=-45;
        fire.scale.set(-1.3,1.3);
        add(fire);

        fire.x += baseX;
        fire.y += baseY;

        pod.x += baseX;
        pod.y += baseY;

        ball.x += baseX;
        ball.y += baseY;

        chain.x += baseX;
        chain.y += baseY;

        bg.x += baseX;
        bg.y += baseY;

        clouds1.x += baseX;
        clouds1.y += baseY;
      case 'airshipVillain':
        dadPosition.y -= 200;
        bfPosition.y -= 200;
        gfPosition.y -= 200;
        dadPosition.x -= 950;
        bfPosition.x -= 175;
        gfPosition.x -= 500;

        defaultCamZoom = 0.7;
        var bg:FlxSprite = new FlxSprite(-400, -250).loadGraphic(Paths.image('airship/villain/BG1','crow'));
        bg.antialiasing = true;
        bg.active = false;
        bg.setGraphicSize(Std.int(bg.width * 0.9));
        bg.scrollFactor.set(.05,.05);
        bg.updateHitbox();
        add(bg);

        var clouds:FlxSprite = new FlxSprite(-800, -300).loadGraphic(Paths.image('airship/villain/BG2','crow'));
        clouds.setGraphicSize(Std.int(clouds.width * 0.9));
        clouds.antialiasing = true;
        clouds.scrollFactor.set(.2,.2);
        clouds.updateHitbox();
        add(clouds);

        var propeller:FlxSprite = new FlxSprite(-600, -300);
        propeller.frames = Paths.getSparrowAtlas('airship/villain/BG3','crow');
        propeller.animation.addByPrefix('twirl', "bg", 24);
        propeller.scrollFactor.set(0.3, 0.3);
        propeller.animation.play('twirl');
        add(propeller);

        var assWind:FlxSprite = new FlxSprite(50, 50);
        assWind.frames = Paths.getSparrowAtlas('airship/villain/AssLookinWind','crow');
        assWind.animation.addByPrefix('asswind', "wind", 30);
        assWind.animation.play('asswind');
        assWind.antialiasing = true;
        assWind.scrollFactor.set(0.3,0.3);
        assWind.setGraphicSize(Std.int(assWind.width * 1.3));
        assWind.updateHitbox();
        add(assWind);

        var assWind2:FlxSprite = new FlxSprite(50, 50);
        assWind2.frames = Paths.getSparrowAtlas('airship/villain/AssLookinWind','crow');
        assWind2.animation.addByPrefix('asswind', "wind", 30);
        assWind2.animation.play('asswind');
        assWind2.antialiasing = true;
        assWind2.scrollFactor.set(0.3,0.3);
        assWind2.setGraphicSize(Std.int(assWind2.width * 1.7));
        assWind2.updateHitbox();
        add(assWind2);

        var floor:FlxSprite = new FlxSprite(-800, -600).loadGraphic(Paths.image('airship/villain/BG4','crow'));
        floor.setGraphicSize(Std.int(floor.width*2));
        floor.active = false;
        floor.antialiasing = true;
        add(floor);

        var lackeys:FlxSprite = new FlxSprite(-1900,-275);
        lackeys.frames = Paths.getSparrowAtlas("airship/villain/MarioCrowdVillain","crow");
        lackeys.animation.addByPrefix("idle","MarioCrowdVillain idle",24,false);
        lackeys.antialiasing=true;
        lackeys.updateHitbox();
        boppers.push([lackeys,"idle",1]);
        add(lackeys);
      case 'airshipHero':
        dadPosition.y -= 200;
        bfPosition.y -= 200;
        gfPosition.y -= 595;
        dadPosition.x -= 950;
        bfPosition.x -= 175;
        gfPosition.x -= 500;

        defaultCamZoom = 0.7;
        var bg:FlxSprite = new FlxSprite(-400, -250).loadGraphic(Paths.image('airship/hero/BG1','crow'));
        bg.antialiasing = true;
        bg.active = false;
        bg.setGraphicSize(Std.int(bg.width * 0.9));
        bg.scrollFactor.set(.05,.05);
        bg.updateHitbox();
        add(bg);

        var clouds:FlxSprite = new FlxSprite(-800, -300).loadGraphic(Paths.image('airship/hero/BG2','crow'));
        clouds.setGraphicSize(Std.int(clouds.width * 0.9));
        clouds.antialiasing = true;
        clouds.scrollFactor.set(.2,.2);
        clouds.updateHitbox();
        add(clouds);

        var propeller:FlxSprite = new FlxSprite(-600, -300);
        propeller.frames = Paths.getSparrowAtlas('airship/hero/BG3','crow');
        propeller.animation.addByPrefix('twirl', "bg", 24);
        propeller.scrollFactor.set(0.3, 0.3);
        propeller.animation.play('twirl');
        add(propeller);

        var assWind:FlxSprite = new FlxSprite(50, 50);
        assWind.frames = Paths.getSparrowAtlas('airship/hero/AssLookinWind','crow');
        assWind.animation.addByPrefix('asswind', "wind", 30);
        assWind.animation.play('asswind');
        assWind.antialiasing = true;
        assWind.scrollFactor.set(0.3,0.3);
        assWind.setGraphicSize(Std.int(assWind.width * 1.3));
        assWind.updateHitbox();
        add(assWind);

        var assWind2:FlxSprite = new FlxSprite(50, 50);
        assWind2.frames = Paths.getSparrowAtlas('airship/hero/AssLookinWind','crow');
        assWind2.animation.addByPrefix('asswind', "wind", 30);
        assWind2.animation.play('asswind');
        assWind2.antialiasing = true;
        assWind2.scrollFactor.set(0.3,0.3);
        assWind2.setGraphicSize(Std.int(assWind2.width * 1.7));
        assWind2.updateHitbox();
        add(assWind2);

        var floor:FlxSprite = new FlxSprite(-800, -600).loadGraphic(Paths.image('airship/hero/BG4','crow'));
        floor.setGraphicSize(Std.int(floor.width*2));
        floor.active = false;
        floor.antialiasing = true;
        add(floor);

        var smonk:FlxSprite = new FlxSprite(-675,-720);
        smonk.frames = Paths.getSparrowAtlas("airship/hero/Smoke","crow");
        smonk.animation.addByPrefix("idle","Smoke",24);
        smonk.animation.play("idle",true);
        smonk.antialiasing=true;
        smonk.updateHitbox();
        add(smonk);

        var brokenPod:FlxSprite = new FlxSprite(-1450,-200).loadGraphic(Paths.image("airship/hero/Deadpod","crow"));
        brokenPod.antialiasing=true;
        add(brokenPod);

        var lackeys:FlxSprite = new FlxSprite(-1900,-500);
        lackeys.frames = Paths.getSparrowAtlas("airship/hero/MarioCrowdHero","crow");
        lackeys.animation.addByPrefix("idle","MarioCrowdVillain idle",24,false);
        lackeys.antialiasing=true;
        lackeys.updateHitbox();
        boppers.push([lackeys,"idle",1]);
        add(lackeys);

      case 'blank':
        centerX = 400;
        centerY = 130;
      default:
        defaultCamZoom = 1;
        curStage = 'stage';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains','shared'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      }
  }


  public function beatHit(beat){
    for(b in boppers){
      if(beat%b[2]==0){
        b[0].animation.play(b[1],true);
      }
    }
    for(d in dancers){
      d.dance();
    }

    if(doDistractions){

      switch(curStage){
        case 'macrocity':
          if (FlxG.random.bool(10) && !robotGoin)
            robotMove();
      }
    }
  }

  override function update(elapsed:Float){
    super.update(elapsed);
    switch(curStage){
      case 'deathpod':
        if(clouds1.x > 10000){
          clouds1.y = FlxG.random.int(-200,-400);
          clouds1.x = -10000;
        }

        if(clouds2.x > 2000){
          clouds2.y = FlxG.random.int(-200,-400);
          clouds2.x = -2600 + FlxG.random.int(-100,100);
        }

        if(clouds3.x > 2400){
          clouds3.y = FlxG.random.int(-200,-400);
          clouds3.x = -2600 + FlxG.random.int(-100,100);
        }
    }

  }

}

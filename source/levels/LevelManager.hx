package levels;

import haxepunk.ParticleManager;
import haxepunk.graphics.TextEntity;
import haxepunk.math.MathUtil;
import entities.Creature;
import haxepunk.utils.Ease;
import haxepunk.tweens.misc.NumTween;
import haxepunk.HXP;
import entities.Player;
import entities.LightMask;
import entities.PushCreature;
import entities.PullCreature;
import entities.BridgeCreature;
import entities.GlueCreature;
import entities.LowGravityCreature;
import entities.JumpCreature;
import haxepunk.math.MinMaxValue;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.utils.BlendMode;

class LevelManager
{
    public var currentLevel:Level;
    public var previousLevel:Level;
    public var player:Player;
    public var particleManager:ParticleManager;
    public var lightMask:Entity;
    public var playerLight:Entity;
    public var currentLevelNum:Int = 1;
    public var switchingLevels:Bool = false;
    public var switchTimer:MinMaxValue;
    public var cameraXSwitchTween:NumTween;

    public var restartTween:NumTween;
    public var restartingLevel:Bool = false;

    public var levelCompleteText:TextEntity;
    //public var findLevelStart:Float;

    public function new() 
    {
        
    }

    public function newGame()
    {
        player = new Player();
		Globals.gameScene.add(player);



        lightMask = new Entity(0, 0, new Image("graphics/LightMask.png"));
        Globals.gameScene.add(lightMask);
        lightMask.layer = -50;
        //lightMask.graphic.scrollX = lightMask.graphic.scrollY = 0;
        //lightMask.graphic.blend = BlendMode.Multiply;

        //playerLight = new Entity(0, 0, new Image("graphics/PlayerLight.png"));
        //Globals.gameScene.add(playerLight);
        //playerLight.layer = -51;
        //playerLight.graphic.blend = BlendMode.Add;

        currentLevelNum = 0;
        currentLevel = new Level();
        currentLevel.loadLevel("maps/level" + Std.string(currentLevelNum) + ".tmx");



        switchTimer = new MinMaxValue(0.0, 0.8, 0.0, 0);
        cameraXSwitchTween = new NumTween();
        restartTween = new NumTween();
        


        ParticleManager.initParticleEmitter("graphics/Particles.png", 1, 1);
        particleManager = new ParticleManager();
        Globals.gameScene.add(particleManager);
        particleManager.initGraphicColorMask();
        particleManager.graphicColorMask.maskAlpha = 1;
        particleManager.layer = -50;
        var smokeParticle = ParticleManager.addType("jumpSmoke", [0]);
        smokeParticle.setScale(0.2, 1.0, 3.0, Ease.quadInOut);
        smokeParticle.setMotion(0, 2, 0.5, 360, 2, 1.0);
        smokeParticle.setAlpha();

        smokeParticle = ParticleManager.addType("landSmoke", [0]);
        smokeParticle.setScale(1.0, 2.0, 1.0, Ease.quadInOut);
        smokeParticle.setMotion(180, 4, 0.5, 180, 2, 1.0);
        smokeParticle.setAlpha();

        smokeParticle = ParticleManager.addType("dashPull", [0]);
        smokeParticle.setScale(0.0, 2.0, 3.0, Ease.quadInOut);
        smokeParticle.setMotion(0, 70, 0.3, 5, 2, 0.2, Ease.circInOut);
        smokeParticle.setColor(0xFFA436, 0xC17B2A);
        smokeParticle.setAlpha();

        smokeParticle = ParticleManager.addType("dashPush", [0]);
        smokeParticle.setScale(0.0, 2.0, 3.0, Ease.quadInOut);
        smokeParticle.setMotion(0, 70, 0.3, 5, 2, 0.2, Ease.circInOut);
        smokeParticle.setColor(0x984643, 0xC15A57);
        smokeParticle.setAlpha();


		//Globals.gameScene.add(new PushCreature(50, 110));
		//Globals.gameScene.add(new PullCreature(100, 110));
		//Globals.gameScene.add(new LowGravityCreature(150, 110));
		//Globals.gameScene.add(new GlueCreature(150, 110));
		//Globals.gameScene.add(new JumpCreature(200, 110));
		//Globals.gameScene.add(new BridgeCreature(150, 110));
    }

    public function loadNextLevel()
    {
        currentLevelNum++;
        if(currentLevelNum > 11)
            return;
        
        player.velocity.x = 0;
        player.velocity.y = 0;

        switchingLevels = true;
        
        //if(currentLevelNum == 11)
        //{
        //    levelCompleteText = new TextEntity(100, 500, "YOU MADE IT\nThank you for playing!");
        //    Globals.gameScene.add(levelCompleteText);
        //}
        previousLevel = currentLevel;
        player.boundCamera = false;

        // Move the previous level by an offset and move the camera accordingly.
        previousLevel.offsetLevel(-Globals.mapWidth, 0);
        HXP.camera.x -= Globals.mapWidth;
        currentLevel = new Level();
        currentLevel.loadLevel("maps/level" + Std.string(currentLevelNum) + ".tmx");
        cameraXSwitchTween.tween(HXP.camera.x, 0, 0.4, Ease.circInOut);
        cameraXSwitchTween.start();

        

    }

    public function update()
    {
        //particleManager.x = HXP.camera.x;
        //particleManager.y = HXP.camera.y;
        lightMask.x = player.x - 640 * 0.5;
        lightMask.y = player.y - 480 * 0.5;
        if(lightMask.y - HXP.camera.y > 0)
            lightMask.y = HXP.camera.y; 
        
        if((lightMask.y + 480) - HXP.camera.y < 240)
            lightMask.y = -(240); 
        cameraXSwitchTween.update(HXP.elapsed);
        restartTween.update(HXP.elapsed);
        if(player.x > Globals.mapWidth)
        {
            loadNextLevel();
        }

        if(switchingLevels)
        {
            // Move the camera 
            HXP.camera.x = cameraXSwitchTween.value;
            if(!cameraXSwitchTween.active)
            {
                // Clean the previous Level
                previousLevel.clean();
                switchingLevels = false;
                player.boundCamera = true;
            }
        }

        checkForRestart();
        if(restartingLevel)
            handlePlayerRestart();
    }

    public function checkForRestart()
    {
        if(player.playerDead && !restartingLevel)
        {
            restartingLevel = true;
            restartTween.tween(0, 1, 1.1, Ease.circInOut);
            restartTween.onComplete.bind(finishRestart);
            restartTween.start();
        }
    }

    public function handlePlayerRestart()
    {
        // Return all the creatures to their spawn pos
        var allCreatures:Array<Creature> = new Array<Creature>();
        Globals.gameScene.getClass(Creature, allCreatures);

        for (creature in allCreatures)
        {
            if(!creature.collected && !(creature.movableCreature || creature.companionCreature))
                continue;
            if(creature.movableCreature || creature.companionCreature)
            {
                creature.x = MathUtil.lerp(creature.x, creature.spawnPos.x, restartTween.value);
                creature.y = MathUtil.lerp(creature.y, creature.spawnPos.y, restartTween.value);
            }
            else
            {
                creature.x = MathUtil.lerp(player.lantern.x, creature.spawnPos.x, restartTween.value);
                creature.y = MathUtil.lerp(player.lantern.y, creature.spawnPos.y, restartTween.value);
            }
            creature.visible = true;
            if(!creature.movableCreature && !creature.companionCreature)
                creature.spriteMap.alpha = MathUtil.lerp(0, 1, restartTween.value);
        }

        // Return the player to the spawn pos.
        player.x = MathUtil.lerp(player.x, player.spawnPos.x, restartTween.value);
        player.y = MathUtil.lerp(player.y, player.spawnPos.y, restartTween.value);
        player.velocity.x = 0;
        player.velocity.y = 0;
        player.spriteMap.angle = MathUtil.lerp(player.spriteMap.angle, 0, restartTween.value);
        player.spriteMap.alpha = MathUtil.lerp(0.5, 1, restartTween.value);
        player.lantern.closestCreature = null;
        player.lantern.creatureBeingPulled = null;
        player.lantern.pullingCreature = false;
    }

    public function finishRestart()
    {

        var allCreatures:Array<Creature> = new Array<Creature>();
        Globals.gameScene.getClass(Creature, allCreatures);

        for (creature in allCreatures)
        {
            creature.collected = false;
        }

        player.playerDead = false;

        restartingLevel = false;
        player.velocity.x = 0;
        player.velocity.y = 0;
        player.x = player.spawnPos.x;
        player.y = player.spawnPos.y;

        player.setHitbox(11, 16);
        player.centerOrigin();


    }
}
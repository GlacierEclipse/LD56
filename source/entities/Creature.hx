package entities;

import haxepunk.HXP;
import haxepunk.math.Vector2;
import entities.Player.PlayerState;
import haxepunk.math.Random;
import haxepunk.math.MathUtil;
import haxepunk.math.MinMaxValue;

class Creature extends GameEntity
{
    public var randDirTimer:MinMaxValue;
    public var player:Player;
    public var movementSpeed:Float;

    public var gravityCreature:Bool = false;
    public var movableCreature:Bool = false;
    public var companionCreature:Bool = false;
    
    public var collected:Bool = false;

    public var moveTarget:Vector2;

    // what..
    public var moveTimer:Float;

    
    public function new(x:Float, y:Float, assetPath:String, gravityCreature:Bool = false) 
    {
        super(x, y, 16, 16, 0, assetPath);

        type = "creature";
        spawnPos = new Vector2(x, y);

        setHitbox(8, 4);

        this.gravityCreature = gravityCreature;

        layer = -100;
    }

    public function initMoveCreature(moveX:Float, moveY:Float)
    {
        this.movableCreature = true;
        moveTarget = new Vector2(moveX, moveY);
    }

    public function initCompanionCreature()
    {
        this.companionCreature = true;
        //moveTarget = new Vector2(moveX, moveY);
    }

    override function init() 
    {
        super.init();
        randDirTimer = new MinMaxValue(0.0, 5.0, 0.0, 1);
        movementSpeed = 2;
        collected = false;
        moveTimer = 0;
    }

    override function handleAnimation() 
    {
        super.handleAnimation();

        if(velocity.x != 0 || velocity.y != 0)
            spriteMap.angle = MathUtil.lerpAngleDeg(spriteMap.angle, MathUtil.angle(0, 0, velocity.x, velocity.y), 0.05);
        
        
    }

    public function updateMovableCreature()
    {
        moveTimer += HXP.elapsed;
        var moveOffset:Float = MathUtil.sin(moveTimer);
        moveOffset = (moveOffset + 1) * 0.5;
        x = MathUtil.lerp(spawnPos.x, moveTarget.x, moveOffset);
        y = MathUtil.lerp(spawnPos.y, moveTarget.y, moveOffset);
    }

    override function handleCollision() 
    {
        super.handleCollision();
        var bounds:Float = 10;
        if(x < spawnPos.x - bounds || x > spawnPos.x + bounds)
        {
            velocity.x = -velocity.x;
        }
        if(y < spawnPos.y - bounds || y > spawnPos.y + bounds)
        {
            velocity.y = -velocity.y;
        }
    }



    override function preFirstUpdate()
    {
        if(player == null)
        {
            player = cast Globals.gameScene.getInstance("player");
        }
    }

    override function update() 
    {
        super.update();

        handleMovement();
        if(movableCreature)
            updateMovableCreature();
        handleCollision();

        handleAnimation();
        applyVelocity();
        

    }

    public function action(dirToCreature:Vector2) : Bool
    {
        graphicColorMask.startMaskOnce(0.2, 0xFFFFFF);
        if(!movableCreature)
            collected = true;
        return false;
    }

    public function proximityAction(dirToCreature:Vector2) : Bool
    {
        if(gravityCreature)
            player.handleLowGravityProximity();
        if(companionCreature)
        {
            dirToCreature.normalize();
            x += dirToCreature.x * 0.5;
            y += dirToCreature.y * 0.5;
        }
        return false;
    }

    public function handleMovement()
    {
        
        randDirTimer.updateWithElapsedTime();
        if(randDirTimer.isMinValue())
        {
            var newAngle:Float = Random.randFloat(360);
            MathUtil.angleXY(velocity, newAngle);
            randDirTimer.initToMax();
            velocity.scale(movementSpeed * 0.5);
        }
        if(Globals.gameScene.levelManager.currentLevelNum == 11)
            velocity.setToZero();

        //if(player.playerState == PlayerState.ONGROUND && player.distanceFrom(this) < 100)
        //{
        //    velocity.x = x - player.x;
        //    velocity.y = y - player.y;
        //    velocity.normalize(movementSpeed);
        //}
    }
}
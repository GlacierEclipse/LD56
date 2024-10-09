package entities;

import haxepunk.Tween.TweenType;
import haxepunk.utils.Ease;
import haxepunk.tweens.misc.NumTween;
import haxepunk.tweens.misc.MultiVarTween;
import haxepunk.tweens.misc.VarTween;
import haxepunk.utils.Draw;
import haxepunk.Camera;
import haxepunk.HXP;
import haxepunk.graphics.Graphiclist;
import haxepunk.graphics.Spritemap;
import haxepunk.math.MinMaxValue;
import haxepunk.math.MathUtil;
import haxepunk.math.Vector2;
import haxepunk.input.Mouse;
import haxepunk.input.Input;
import haxepunk.ParticleManager;

enum PlayerState
{
    DIVING;
    ONWATER;
    ONGROUND;
    FLYING;
    DIVEBOMB;
}
class Player extends GameEntity
{
    public var mouseDir:Vector2 = new Vector2();
    public var mouseDirLength:Float;
    public var newVelocity:Vector2 = new Vector2();
    public var movementSpeed:Float;
    public var dashSpeed:Float;
    public var jumpSpeed:Float;
    public var accelSpeed:MinMaxValue;

    // -2 - Diving
    // -1 - On Water
    // 0 - On Ground
    // 1 - In Air
    public var distToGround:Float;
    public var playerState:PlayerState;

    public var playerShadow:Spritemap;
    public var playerTarget:GameEntity;

    public var flySpeed:Float;
    public var diveBombSpeed:Float;
    public var onGround:Bool;

    public var dashVelocity:Vector2;
    public var dashStartPos:Vector2;
    public var dashTimer:MinMaxValue;

    public var lantern:Lantern;

    public var diveBombing:Bool;
    public var diveBombDistance:Float;
    public var diveBombStartY:Float;
    public var diveBombTime:Float;
    public var maxFlyHeight:Float;
    public var diveBombForceY:Float;

    public var glueTimer:MinMaxValue;
    public var doubleJumpCounter:Int;

    public var gravityMinMax:MinMaxValue;
    public var lowGravityTimer:MinMaxValue;

    public var deathTween:MultiVarTween;
    public var deathTweenVel:MultiVarTween;
    public var playerDeathStart:Bool;
    public var playerDead:Bool;
    public var boundCamera:Bool;

    public var dashTween:NumTween;

    public var squish1Tween:VarTween;
    public var squashTween:VarTween;

    public var lowGravityProximity:Bool = false;

    public var circleThicness:Float = 1;
    public var circleAlpha:Float = 0.5;

    public function new() 
    {
        //playerShadow = new Spritemap("graphics/PlayerShadow.png", 16, 16);
        //playerShadow.alpha = 0.5;
        //playerShadow.centerOrigin();
        //addGraphic(playerShadow);
        ////playerShadow.y = 15;
//
        //playerTarget = new GameEntity(0, 0, 16, 16, 0, "graphics/PlayerTarget.png");
        //playerTarget.spriteMap.alpha = 0.5;
        //playerTarget.centerOrigin();
        //Globals.gameScene.add(playerTarget);

        super(1 * 16, 10 * 16 - 8, 16, 16, 0, "graphics/Player.png");

        layer = -5;

        name = "player";

        lantern = new Lantern(this);
        Globals.gameScene.add(lantern);
        lantern.layer = -7;

        deathTween = new MultiVarTween();
        addTween(deathTween);

        deathTweenVel = new MultiVarTween();
        addTween(deathTweenVel);

        squish1Tween = new VarTween();
        addTween(squish1Tween);

        squashTween = new VarTween();
        addTween(squashTween);

        dashTween = new NumTween();
        addTween(dashTween);
        
        setHitbox(11, 16);
        centerOrigin();

        boundCamera = true;
    }

    override function init() 
    {
        super.init();
        dashVelocity = new Vector2();
        dashStartPos = new Vector2();
        //movementSpeed = new MinMaxValue(0.0, 90.0, 50.0, 0);
        movementSpeed = 120;
        //movementSpeed = new MinMaxValue(0.0, 80.0, 80.0, 0);
        dashSpeed = 80;
        jumpSpeed = 240;
        accelSpeed = new MinMaxValue(0.0, 10.0, 2.0, 0);
        playerState = PlayerState.ONGROUND;
        distToGround = 0;
        
        flySpeed = 3;
        diveBombSpeed = 2;
        gravity = 5.5;
        onGround = false;
        
        diveBombing = false;
        
        //velocity.x = 150;
        
        maxFlyHeight = 20;
        diveBombForceY = 0;
        diveBombTime = 0;
        glueTimer = new MinMaxValue(0.0, 10.0, 0.0, 0);
        dashTimer = new MinMaxValue(0.0, 0.1, 0.0, 0);
        lowGravityTimer = new MinMaxValue(0.0, 5.0, 0.0, 0);
        gravityMinMax = new MinMaxValue(1.5, 5.5, 5.5, 0);
        doubleJumpCounter = 0;
        playerDeathStart = false;
        playerDead = false;
        //doubleJumpTimer = new MinMaxValue(0.0, 5.0, 2.0, 0);
    }

    public function deathStart()
    {
        if(playerDeathStart)
            return;

        graphicColorMask.startMaskOnce(0.2);
        playerDeathStart = true;
        deathTween.tween(spriteMap, {angle : -90}, 0.4);
        deathTween.onComplete.bind(deathEnd);
        deathTween.start();
        deathTweenVel.tween(this.velocity, {x : 0}, 0.4);
        deathTweenVel.start();
        velocity.x = 0;
        velocity.y = 0;
        setHitbox(15, 4);
        centerOrigin();
        //active = false;
    }

    public function deathEnd()
    {
        playerDeathStart = false;
        playerDead = true;
    }

    override function handleAnimation() 
    {
        super.handleAnimation();

        
        //if(velocity.x != 0 || velocity.y != 0)
        //    spriteMap.angle = MathUtil.lerpAngleDeg(spriteMap.angle,  MathUtil.angle(0, 0, velocity.x, velocity.y), 0.05);
        //else
        //    spriteMap.angle = MathUtil.lerpAngleDeg(spriteMap.angle,  MathUtil.angle(0, 0, mouseDir.x, mouseDir.y), 0.05);

        //spriteMap.scale = MathUtil.lerp(1, 2.5, distToGround);

        //playerShadow.y = MathUtil.lerp(2, 25, distToGround);

        //playerShadow.angle = spriteMap.angle;
        //playerShadow.scale = spriteMap.scale;
        

        //lantern.x = x + 4;
        if(velocity.x > 0)
        {
            lantern.spriteMap.flipX = spriteMap.flipX = false; 
            
        }
        else if(velocity.x < 0)
        {
            lantern.spriteMap.flipX = spriteMap.flipX = true; 
        }

        if(spriteMap.flipX)
        {
            lantern.x = MathUtil.lerp(lantern.x, x + getDeltaVelocityX() - 4, 0.2);
        }
        else
        {
            lantern.x = MathUtil.lerp(lantern.x, x + getDeltaVelocityX() + 4, 0.2);
        }
        //if(!playerDeathStart && !playerDead)
        {
            lantern.y = y + 9;
        }
        //else
        //{
        //    lantern.velocity.y += gravity;
        //    lantern.handleCollision();
        //    lantern.applyVelocity();
        //}

    }

    override function update() 
    {
        super.update();
        lowGravityProximity = false;
        if(!playerDeathStart && !playerDead && !Globals.gameScene.levelManager.switchingLevels)
            handleInput();
        if(!Globals.gameScene.levelManager.restartingLevel)
            handleDash();
        handleGlue();
        //handleLowGravity();
        //handleDoubleJump();
        handleGravity();
        if(!Globals.gameScene.levelManager.restartingLevel)
            handleCollision();

        handleAnimation();
        applyVelocity();

        handleCamera();

        
    }

    //public function dashAction()
    //{
        //if(Input.check("right"))
        //{
        //    dashVelocity.x = dashSpeed;
        //}
        //else if(Input.check("left"))
        //{
        //    dashVelocity.x = -dashSpeed;
        //}
        //else
        //{
        //    dashVelocity.x = dashSpeed;
        //}
        
    //}

    public function pullAction(dirToCreature:Vector2, dashSpeed:Float = -1, dashTimer:Float = 0.1)
    {
        graphicColorMask.startMaskOnce(0.4, 0xFFA436);
        ParticleManager.particleEmitter.emitAmount("dashPull", 10, x, y + halfHeight, MathUtil.angle(0,0,dirToCreature.x, dirToCreature.y));
        dashTween.tween(0, 1, 0.5, Ease.circOut);
        dashTween.start();
        if(dashSpeed < 0)
            dashSpeed = this.dashSpeed;
        dashStartPos.setTo(x, y);
        dashVelocity.x = dirToCreature.x;
        dashVelocity.y = dirToCreature.y;
        dashVelocity.normalize(dashSpeed);
        //this.dashTimer.currentValue = dashTimer;
    }

    public function pushAction(dirToCreature:Vector2, dashSpeed:Float = -1, dashTimer:Float = 0.1)
    {
        graphicColorMask.startMaskOnce(0.4, 0xE08B7B);
        ParticleManager.particleEmitter.emitAmount("dashPush", 10, x, y + halfHeight, MathUtil.angle(0,0,-dirToCreature.x, -dirToCreature.y));
        dashTween.tween(0, 1, 0.5, Ease.circOut);
        dashTween.start();
        if(dashSpeed < 0)
            dashSpeed = this.dashSpeed;
        dashStartPos.setTo(x, y);
        dashVelocity.x = -dirToCreature.x;
        dashVelocity.y = -dirToCreature.y;
        dashVelocity.normalize(dashSpeed);
        //this.dashTimer.currentValue = dashTimer;
    }

    public function glueAction()
    {
        glueTimer.initToMax();
    }

    public function lowGravityAction()
    {
        lowGravityTimer.initToMax();
    }

    public function doubleJumpAction()
    {
        doubleJumpCounter++;
    }

    public function handleInput()
    {
        mouseDir.x = Mouse.mouseX - x;
        mouseDir.y = Mouse.mouseY - y;
        mouseDirLength = mouseDir.length;
        mouseDir.normalize();
        
        //handleStates();
        handleMovement();

        lantern.handleProximity();
        lantern.handleCollect();

        if(Input.check("collect") && !isDashing())
        {
            lantern.startCollect();
        }
//
        //if(Input.pressed("use"))
        //{
        //    lantern.handleAction();
        //}
    }

    public function handleCamera()
    {
        if(!boundCamera)
            return;

        HXP.camera.x = MathUtil.lerp(HXP.camera.x, x - HXP.halfWidth, 0.04);
        HXP.camera.y = MathUtil.lerp(HXP.camera.y, y - HXP.halfHeight, 0.04);



        if(HXP.camera.x < 0)
            HXP.camera.x = 0;

        if(HXP.camera.x + HXP.width > Globals.mapWidth)
            HXP.camera.x = Globals.mapWidth - HXP.width;

        if(HXP.camera.y < 0)
            HXP.camera.y = 0;

        if(HXP.camera.y + HXP.height > Globals.mapHeight)
            HXP.camera.y = Globals.mapHeight - HXP.height;
    }

    override function handleCollision() 
    {
        super.handleCollision();

        onGround = false;
        var collidedEntity = collideSweep("tile", x, y, x + getDeltaVelocityX(), y);
        if(collidedEntity != null)
        {
            if(velocity.x > 0)
            {
                x = collidedEntity.x - collidedEntity.halfWidth - (halfWidth + 1);
                
            }
            else if(velocity.x < 0)
            {
                x = collidedEntity.x + collidedEntity.halfWidth + halfWidth;
            }
            if(isGlueing())
            {
                //onGround = true;
                velocity.x = -velocity.x * 0.05;
                velocity.y = -jumpSpeed * 0.05;
                //velocity.perpendicular();

                pullAction(velocity.normalize(), 600, 0.09);
            }
            else
                velocity.x = 0;
        }

        collidedEntity = collideSweep("tile", x, y, x, y + getDeltaVelocityY());
        if(collidedEntity != null)
        {
            if(velocity.y > 0)
            {
                y = collidedEntity.y - collidedEntity.halfHeight - halfHeight;
                onGround = true;

                if(!squashTween.active && velocity.y > 10)
                {
                    ParticleManager.particleEmitter.emitInRectangleAmount("landSmoke", x, y + halfHeight, width, 5, 5);
                    squashTween.tween(spriteMap, "scaleY", 0.7, 0.03);
                    squashTween.onComplete.bind(function name() 
                    {
                        var squashPongTween = new VarTween();
                        squashPongTween.tween(spriteMap, "scaleY", 1.0, 0.03);
                        addTween(squashPongTween, true);
                    });
                    squashTween.start();
                }
            }
            else if(velocity.y < 0)
            {
                y = collidedEntity.y + collidedEntity.halfHeight + halfHeight;
                if(isGlueing())
                    velocity.y = 0;
                
            }
            velocity.y = 0;
        }

        if(x + getDeltaVelocityX() < 1)
        {
            velocity.x = 0;
            x = 1;
        }

        if(y + getDeltaVelocityX() > Globals.mapHeight)
        {
            deathStart();
        }

        handleSpikesCollision();
        
        /*
        if((playerState == PlayerState.DIVEBOMB || playerState == PlayerState.ONGROUND) && distToGround < 0.1)
        {
            var collidedEntity = collide("creature", x + getDeltaVelocityX(), y + getDeltaVelocityY());
            if(collidedEntity != null)
            {
                Globals.gameScene.remove(collidedEntity);
                //if(playerState == PlayerState.DIVEBOMB)
                    
            }
        }
        */
    }

    public function handleSpikesCollision()
    {
        var collidedEntity = collide("spikes", x + getDeltaVelocityX(), y + getDeltaVelocityY());
        if(collidedEntity != null)
        {
            deathStart();
        }
    }

    public function isDashing() : Bool
    {
        //return dashVelocity.x != 0 || dashVelocity.y != 0;
        return dashTween.active;
    }

    public function isGlueing() : Bool
    {
        return glueTimer.currentValue > 0;
    }

    public function isLowGravity() : Bool
    {
        return lowGravityTimer.currentValue > 0;
    }

    public function isDoubleJump() : Bool
    {
        return doubleJumpCounter > 0;
    }
    
    public function handleMovement()
    {
        if(!isDashing())
        {
            velocity.x = 0;
            gravity = 5.0;
        }
        else
        {
            gravity = 0;
            //velocity.x = velocity.y = 0;
            //velocity.x += dashVelocity.x;
            //velocity.y += dashVelocity.y;
        }
        if(Input.check("right") && !isDashing())
        {
            velocity.x = movementSpeed;
        }
        if(Input.check("left") && !isDashing())
        {
            velocity.x = -movementSpeed;
        }
        if(Input.pressed("jump") && (onGround || isDoubleJump()))
        {
            ParticleManager.particleEmitter.emitInRectangleAmount("jumpSmoke", x, y, width, height, 5);
            if(!squish1Tween.active)
            {
                squish1Tween.tween(spriteMap, "scaleX", 0.8, 0.08);
                squish1Tween.onComplete.bind(function name() 
                {
                    var squishPongTween = new VarTween();
                    squishPongTween.tween(spriteMap, "scaleX", 1.0, 0.08);
                    addTween(squishPongTween, true);
                });
                squish1Tween.start();
            }
            
            velocity.y = -jumpSpeed;
            if(doubleJumpCounter > 0 && !onGround)
                doubleJumpCounter--;
        }
    }

    public function handleDash()
    {
        if(!dashTween.active)
            return;

        velocity.x = (MathUtil.lerp(dashStartPos.x, dashStartPos.x + dashVelocity.x, dashTween.value) - x) * 60;
        velocity.y = (MathUtil.lerp(dashStartPos.y, dashStartPos.y + dashVelocity.y, dashTween.value) - y) * 60;
    }

    public function handleGlue()
    {
        glueTimer.updateWithElapsedTime();
    }

    public function handleLowGravity()
    {
        gravity = gravityMinMax.maxValue;
        lowGravityTimer.updateWithElapsedTime();
        if(lowGravityTimer.currentValue > 0)
        {
            gravity = gravityMinMax.minValue;
        }
        
    }

    public function handleLowGravityProximity()
    {
        lowGravityProximity = true;
        velocity.y = 2.4;
    }

    public function handleGravity()
    {
        velocity.y += gravity;
    }

    override function render(camera:Camera) 
    {
        super.render(camera);
        if(lowGravityProximity)
        {
            circleThicness = MathUtil.lerp(circleThicness, 5, 0.08);
            circleAlpha = MathUtil.lerp(circleAlpha, 0.9, 0.08);
            Draw.setColor(0x75B5D0, circleAlpha);
            Draw.lineThickness = circleThicness;
            Draw.circle(x - HXP.camera.x, y - HXP.camera.y, lantern.lanternPullDistance * 1.9);
        }
        else
        {
            circleThicness = MathUtil.lerp(circleThicness, 1, 0.08);
            circleAlpha = MathUtil.lerp(circleAlpha, 0.2, 0.08);
            Draw.lineThickness = circleThicness;
            Draw.setColor(0xFFFFFF, circleAlpha);
            Draw.circle(x - HXP.camera.x, y - HXP.camera.y, lantern.lanternPullDistance * 1.9);
        }
        

        if(lantern.closestCreature != null)
            Draw.line(lantern.x - HXP.camera.x, lantern.y - HXP.camera.y, lantern.closestCreature.x  - HXP.camera.x, lantern.closestCreature.y - HXP.camera.y);
    }
}
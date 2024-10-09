package entities;

import haxepunk.math.Vector2;
import haxepunk.HXP;
import haxepunk.graphics.Spritemap;
import haxepunk.Entity;

class GameEntity extends Entity
{
    public var spriteMap:Spritemap;
    public var preFirstUpdateOnce:Bool = true;
    public var gravity:Float;
    public var spawnPos:Vector2;
    public var restarting:Bool = false;

    public function new(x:Float, y:Float, width:Int, height:Int, frameSpacing:Int, assetPath:String) 
    {
        super(x, y);

        spawnPos = new Vector2(x, y);
        if(assetPath != "")
            spriteMap = new Spritemap(assetPath, width, height, frameSpacing, frameSpacing);

        setHitbox(width, height);
        spriteMap.centerOrigin();
        centerOrigin();

        init();

        addGraphic(spriteMap);

        initGraphicColorMask();

        //graphic = spriteMap;
    }

    public function cleanUp()
    {

    }

    public function preFirstUpdate()
    {

    }

    override function update() 
    {
        super.update();

        if(preFirstUpdateOnce)
        {
            preFirstUpdate();
            preFirstUpdateOnce = false;
        }

    }

    public function init()
    {

    }

    public function handleAnimation()
    {

    }

    public function handleCollision()
    {

    }

    public function getDeltaVelocityX() : Float
    {
        return velocity.x * HXP.elapsed;
    }

    public function getDeltaVelocityY() : Float
    {
        return velocity.y * HXP.elapsed;
    }

    public function applyVelocity()
    {
        x += getDeltaVelocityX();
        y += getDeltaVelocityY();
    }
}
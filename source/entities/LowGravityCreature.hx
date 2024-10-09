package entities;

import haxepunk.math.Vector2;

class LowGravityCreature extends Creature
{
    public function new(x:Float, y:Float)
    {
        super(x, y, "graphics/LowGravityCreature.png");

        //name = "lowGravityCreature";
        type = "creature";

        spriteMap.add("fly", [2, 0, 1], 12);
    }

    override function handleAnimation() 
    {
        super.handleAnimation();
        spriteMap.play("fly");
    }
    override function update() 
    {
        super.update();
        handleAnimation();
    }

    override function proximityAction(dirToCreature:Vector2) : Bool
    {
        super.action(dirToCreature);
        player.handleLowGravityProximity();
        return true;
        
    }

    override function action(dirToCreature:Vector2) : Bool
    {
        super.action(dirToCreature);
        player.pullAction(dirToCreature);
        return true;
        
    }
}
package entities;

import haxepunk.math.Vector2;

class GlueCreature extends Creature
{
    public function new(x:Float, y:Float)
    {
        super(x, y, "graphics/GlueCreature.png");

        name = "glueCreature";
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

    override function action(dirToCreature:Vector2) : Bool
    {
        super.action(dirToCreature);
        player.glueAction();
        return true;
        
    }
}
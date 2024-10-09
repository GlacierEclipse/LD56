package entities;

import haxepunk.math.Vector2;

class PushCreature extends Creature
{
    public function new(x:Float, y:Float, gravityCreature:Bool = false, movable:Bool = false)
    {
        var assetPath:String = "graphics/PushCreature.png";
        if(gravityCreature)
            assetPath = "graphics/PushCreatureGravity.png";
        if(movable)
            assetPath = "graphics/PushCreatureMove.png";
        super(x, y, assetPath, gravityCreature);

        name = "pushCreature";
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

    override function action(dirToCreature:Vector2) 
    {
        super.action(dirToCreature);
        player.pushAction(dirToCreature);
        return true;

    }
}
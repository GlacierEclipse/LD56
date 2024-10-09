package entities;

class BridgeCreature extends Creature
{
    public function new(x:Float, y:Float)
    {
        super(x, y, "graphics/BridgeCreature.png");

        name = "bridgeCreature";
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

   // override function action() : Bool
   // {
   //     super.action();
//
   //     var playerGridX:Float = Std.int(player.x / Globals.tileWidth) * Globals.tileWidth;
   //     var playerGridY:Float = Std.int((player.y + Globals.halfTileHeight) / Globals.tileHeight) * Globals.tileHeight;
//
   //     if(collide("tile", playerGridX, playerGridY) == null && player.onGround)
   //     {
   //         // Create a new tile here.
   //         Globals.gameScene.add(new Tile(playerGridX, playerGridY, 2));
//
   //         return true;
   //     }
   //     return false;
   // }
}
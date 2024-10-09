package entities;

class Tile extends GameEntity
{
    public function new(x:Float, y:Float, tileInd:Int) 
    {
        super(x, y, 16, 16, 1, "graphics/Tiles.png");
        type = "tile";

        spriteMap.frame = tileInd - 1;
    }
}
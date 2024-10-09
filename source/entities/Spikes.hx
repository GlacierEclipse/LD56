package entities;

class Spikes extends GameEntity
{
    public function new(x:Float, y:Float, tileInd:Int) 
    {
        super(x, y, 16, 16, 1, "graphics/Tiles.png");
        type = "spikes";

        spriteMap.frame = tileInd - 1;

        if(tileInd == 5)
            setHitbox(10, 4, 5, -5);

        if(tileInd == 21)
            setHitbox(10, 4, 5, 7);

        if(tileInd == 12)
            setHitbox(4, 10, -4, 5);

        if(tileInd == 14)
            setHitbox(4, 10, 7, 5);
        //centerOrigin();
    }

    override function update() 
    {
        super.update();
    }
}
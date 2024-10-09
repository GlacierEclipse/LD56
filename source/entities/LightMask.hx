package entities;

import haxepunk.Entity;
import haxepunk.graphics.Image;

class LightMask extends Entity
{
    public function new() 
    {
        super(0, 0, new Image("graphics/LightMask.png"));
        
    }
}
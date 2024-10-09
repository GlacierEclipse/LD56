package entities;

import haxepunk.math.Vector2;
import haxepunk.math.MathUtil;
import haxepunk.HXP;

class Lantern extends GameEntity
{
    public var listOfCreatures:List<Creature>;
    public var player:Player;
    public var lanternPullDistance:Float;
    public var lanternPullSpeed:Float;
    public var pullingCreature:Bool;
    public var creatureBeingPulled:Creature;
    public var pullingDir:Vector2;
    public var closestCreature:Creature = null;

    public function new(player:Player) 
    {
        super(0, 0, 16, 16, 0, "graphics/Lantern.png");
        listOfCreatures = new List<Creature>();
        pullingDir = new Vector2();
        this.player = player;

        lanternPullDistance = 40;
        pullingCreature = false;
        lanternPullSpeed = 0.1;
    }

    public function handleProximity()
    {
        var listOfCreaturesInScene:Array<Creature> = new Array<Creature>();
        HXP.scene.getType("creature", listOfCreaturesInScene);

        for(creature in listOfCreaturesInScene)
        {
            if(creature.distanceFrom(player) < lanternPullDistance && creature.visible)
            {
                if(!pullingCreature)
                {
                    pullingDir.setTo(creature.x - player.x, creature.y - player.y);
                }
                creature.proximityAction(pullingDir);
            }
        }

        closestCreature = null;
        var minDist:Float = 100000;
        for(creature in listOfCreaturesInScene)
        {
            var dist:Float = creature.distanceFrom(player);
            if(((creature.companionCreature) ? (dist < lanternPullDistance + 50) : (dist < lanternPullDistance)) && dist < minDist && creature.visible && (creatureBeingPulled == null || creatureBeingPulled == creature))
            {
                minDist = dist;
                closestCreature = creature;
                
            }
        }
    }

    override function handleCollision() 
    {
        super.handleCollision();

        var collidedEntity = collide("tile", x + getDeltaVelocityX(), y);
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
            velocity.x = 0;
        }

        collidedEntity = collide("tile", x, y + getDeltaVelocityY());
        if(collidedEntity != null)
        {
            if(velocity.y > 0)
            {
                y = collidedEntity.y - collidedEntity.halfHeight - halfHeight;
            }
            else if(velocity.y < 0)
            {
                y = collidedEntity.y + collidedEntity.halfHeight + halfHeight;
                velocity.y = 0;
                
            }
            velocity.y = 0;
        }
    }

    public function handleCollect()
    {
        if(!pullingCreature || closestCreature == null)
            return;

        if(!closestCreature.movableCreature && !closestCreature.companionCreature)
        {
            closestCreature.x = MathUtil.lerp(closestCreature.x, this.x, lanternPullSpeed);
            closestCreature.y = MathUtil.lerp(closestCreature.y, this.y, lanternPullSpeed);
        }
        //if(closestCreature.distanceFrom(this) < 15)
        {
            //listOfCreatures.add(creature);
            if(!closestCreature.movableCreature && !closestCreature.companionCreature)
                closestCreature.visible = false;
            closestCreature.action(pullingDir);
            pullingCreature = false;
            creatureBeingPulled = null;
        }
    }

    public function startCollect()
    {
        var listOfCreaturesInScene:Array<Creature> = new Array<Creature>();
        HXP.scene.getType("creature", listOfCreaturesInScene);

        closestCreature = null;
        var minDist:Float = 100000;
        for(creature in listOfCreaturesInScene)
        {
            var dist:Float = creature.distanceFrom(player);
            if((creature.companionCreature ? dist < lanternPullDistance + 50 : dist < lanternPullDistance) && dist < minDist && creature.visible && (creatureBeingPulled == null || creatureBeingPulled == creature))
            {
                minDist = dist;
                closestCreature = creature;
                
            }
        }

        
        if(closestCreature == null)
            return;
        if(!pullingCreature)
        {
            pullingDir.setTo(closestCreature.x - player.x, closestCreature.y - player.y);
        }
        creatureBeingPulled = closestCreature;
        pullingCreature = true;
    }

    public function handleAction()
    {
        //if(listOfCreatures.length > 0)
        //{
        //    var poppedCreature:Creature = listOfCreatures.first();
        //    if(poppedCreature.action())
        //    {
        //        if(poppedCreature.name == "dashCreature")
        //        {
        //            player.dashAction();
        //        }
        //        listOfCreatures.pop();
        //    }
        //}
    }
}
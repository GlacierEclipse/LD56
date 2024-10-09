package levels;

import haxepunk.Entity;
import haxepunk.utils.TiledParser;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.graphics.Image;
import haxepunk.graphics.TextEntity;
import entities.Tile;
import entities.Spikes;
import entities.PushCreature;
import entities.PullCreature;
import entities.LowGravityCreature;

class Level
{
    public var tileMap:Tilemap;
    public var tiledParser:TiledParser;

    public var levelEntities:Array<Entity>;

    public function new() 
    {
        levelEntities = new Array<Entity>();
    }

    public function offsetLevel(xOffset:Float, yOffset:Float)
    {
        var allEntities:Array<Entity> = new Array<Entity>();
        Globals.gameScene.getAll(allEntities);

        for (entity in allEntities)
        {
            entity.x += xOffset;
            entity.y += yOffset;
        }
    }

    public function clean()
    {
        Globals.gameScene.removeList(levelEntities);
    }

    public function loadLevel(levelToLoad:String)
    {
        tiledParser = new TiledParser(levelToLoad);
        Globals.mapWidth = tiledParser.mapWidthInTiles * Globals.tileWidth;
        Globals.mapHeight = tiledParser.mapHeightInTiles * Globals.tileHeight;
        for(layer in tiledParser.map2DTileLayers)
        {
            
            for(row in 0...layer.rows)
            {
                for(col in 0...layer.columns)
                {
                    var tileInd:Int = layer.arr2DTileLayer[row][col];
                    var xWorld:Float = col * 16;
                    var yWorld:Float = row * 16;
                    // Spikes
                    if(tileInd == 5 || tileInd == 12 || tileInd == 14 || tileInd == 21)
                    {
                        levelEntities.push(new Spikes(xWorld + Globals.halfTileWidth, yWorld + Globals.halfTileHeight, tileInd));
                    }
                    // Tiles
                    else if(tileInd != 0 && tileInd != 36 && tileInd != 35)
                    {
                        levelEntities.push(new Tile(xWorld + Globals.halfTileWidth, yWorld + Globals.halfTileHeight, tileInd));
                    }
                    
                    // BG Tiles
                    if(tileInd == 35 || tileInd == 36)
                    {
                        levelEntities.push(new Tile(xWorld + Globals.halfTileWidth, yWorld + Globals.halfTileHeight, tileInd));
                        levelEntities[levelEntities.length - 1].collidable = false;
                    }
                }
            }
        }

        for(objectGroup in tiledParser.mapObjectLayers)
        {
            for(object in objectGroup.arrTiledObjects)
            {
                if(object.name == "player")
                {
                    Globals.gameScene.levelManager.player.spawnPos.x = object.x;
                    Globals.gameScene.levelManager.player.spawnPos.y = object.y - Globals.halfTileHeight;
                }
                if(object.name == "pull")
                {
                    levelEntities.push(new PullCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight));
                }
                if(object.name == "pullGravity")
                {
                    levelEntities.push(new PullCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, true));
                }

                if(object.name == "pullMove")
                {
                    var pullCreature:PullCreature = new PullCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, false, true);
                    var xOffset:Float = object.properties.get("moveX");
                    var yOffset:Float = object.properties.get("moveY");
                    pullCreature.initMoveCreature(pullCreature.x + xOffset, pullCreature.y + yOffset);
                    levelEntities.push(pullCreature);
                    
                }

                if(object.name == "companionPull")
                {
                    var pullCreature:PullCreature = new PullCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, true, false);
                    pullCreature.initCompanionCreature();
                    levelEntities.push(pullCreature);
                }

                if(object.name == "companionPush")
                {
                    var pushCreature:PushCreature = new PushCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, true, false);
                    pushCreature.initCompanionCreature();
                    levelEntities.push(pushCreature);
                }

                if(object.name == "pullGravityMove")
                {
                    var pullCreature:PullCreature = new PullCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, true, true);
                    var xOffset:Float = object.properties.get("moveX");
                    var yOffset:Float = object.properties.get("moveY");
                    pullCreature.initMoveCreature(pullCreature.x + xOffset, pullCreature.y + yOffset);
                    levelEntities.push(pullCreature);
                    
                }
            
                if(object.name == "push")
                {
                    levelEntities.push(new PushCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight));
                }
            
                if(object.name == "pushGravity")
                {
                    levelEntities.push(new PushCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, true));
                }
            
                if(object.name == "pushMove")
                {
                    var pushCreature:PushCreature = new PushCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, false, true);
                    var xOffset:Float = object.properties.get("moveX");
                    var yOffset:Float = object.properties.get("moveY");
                    pushCreature.initMoveCreature(pushCreature.x + xOffset, pushCreature.y + yOffset);
                    levelEntities.push(pushCreature);
                    
                }
            
                if(object.name == "pushGravityMove")
                {
                    var pushCreature:PushCreature = new PushCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight, true, true);
                    var xOffset:Float = object.properties.get("moveX");
                    var yOffset:Float = object.properties.get("moveY");
                    pushCreature.initMoveCreature(pushCreature.x + xOffset, pushCreature.y + yOffset);
                    levelEntities.push(pushCreature);
                    
                }
            
                if(object.name == "gravity")
                {
                    Globals.gameScene.add(new LowGravityCreature(object.x + Globals.halfTileWidth, object.y - Globals.tileHeight + Globals.halfTileHeight));
                }
            }
        }

        if(Globals.gameScene.levelManager.currentLevelNum == 0)
        {
            var eMainMenuScreen:Entity = new Entity(0, 0, new Image("graphics/main_menu.png"));
            levelEntities.push(eMainMenuScreen);
            eMainMenuScreen = new TextEntity(12, 100, "Move", 22);
            levelEntities.push(eMainMenuScreen);
            eMainMenuScreen = new TextEntity(122, 95, "Action", 22);
            levelEntities.push(eMainMenuScreen);
        }

        Globals.gameScene.addList(levelEntities);
    }

}
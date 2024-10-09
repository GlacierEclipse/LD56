package scenes;

import haxepunk.math.Random;
import haxepunk.Scene;
import entities.Player;
import entities.Tile;
import entities.Creature;
import levels.LevelManager;

class GameScene extends Scene
{
	public var levelManager:LevelManager;
	override public function begin()
	{
		Globals.gameScene = this;

		levelManager = new LevelManager();
		levelManager.newGame();
		
	}

	override function update() 
	{
		super.update();
		levelManager.update();
	}
}

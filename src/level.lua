GameSettings = require('src.gameSettings')
Class = require('lib.hump.class')

local Level = Class {
    init = function(self, levelString, world, player, Wall, Enemy, WallManager,
                    EnemyManager)
        self.levelString = levelString
        self.world = world
        self.player = player
        self.Wall = Wall
        self.Enemy = Enemy
        self.WallManager = WallManager
        self.EnemyManager = EnemyManager
        self.wallManager, self.enemyManager = self:processLevelString()
    end,

    processLevelString = function(self)
        local lineCount = 0;
        local columnCount = 0;
        local walls = {};
        local enemies = {};
        for block in self.levelString:gmatch "." do
            if block == '\n' then
                columnCount = -1;
                lineCount = lineCount + 1;
            elseif block == '#' then
                table.insert(walls,
                             self.Wall(columnCount * GameSettings.TILE_SIZE,
                                       lineCount * GameSettings.TILE_SIZE,
                                       self.world))
            elseif block == 'P' then
                self.player.positionX = columnCount * GameSettings.TILE_SIZE
                self.player.positionY = lineCount * GameSettings.TILE_SIZE
            elseif block == 'X' then
                table.insert(enemies,
                             self.Enemy(columnCount * GameSettings.TILE_SIZE,
                                        lineCount * GameSettings.TILE_SIZE,
                                        self.world))
            end
            columnCount = columnCount + 1;
        end
        local wallManager = self.WallManager(walls)
        local enemyManager = self.EnemyManager(enemies)
        return wallManager, enemyManager;
    end
}

return Level

Class = require('lib.hump.class')

local Level = Class {
    init = function (self, levelString, world, Wall, WallManager)
        self.levelString = levelString
        self.world = world
        self.Wall = Wall
        self.WallManager = WallManager
        self.wallManager = self:generateWallManager()
    end,

    generateWallManager = function (self)
        local lineCount = 0;
        local columnCount = 0;
        local walls = {};
        for block in self.levelString:gmatch "." do
            if block == '\n' then
                columnCount = -1;
                lineCount = lineCount + 1;
            elseif block == '#' then
                table.insert(walls, self.Wall(columnCount * TILE_SIZE,
                                             lineCount * TILE_SIZE, self.world))
            end
            columnCount = columnCount + 1;
        end
        local wallManager = self.WallManager(walls)
        return wallManager;
    end
}

return Level
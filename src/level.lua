local Level = {}

function Level:new(o, levelString, world, Wall, WallManager)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.levelString = levelString
    o.world = world
    o.Wall = Wall
    o.WallManager = WallManager
    o.wallManager = o.generateWallManager(o, o)
    return o
end

function Level:generateWallManager(o)
    local lineCount = 0;
    local columnCount = 0;
    local walls = {};
    for block in o.levelString:gmatch "." do
        if block == '\n' then
            columnCount = -1;
            lineCount = lineCount + 1;
        elseif block == '#' then
            table.insert(walls, o.Wall:new(nil, columnCount * TILE_SIZE,
                                         lineCount * TILE_SIZE, o.world))
        end
        columnCount = columnCount + 1;
    end
    local wallManager = o.WallManager:new(nil, walls)
    return wallManager;
end

return Level
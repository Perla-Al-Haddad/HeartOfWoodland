local WallManager = {}

function WallManager:new(o, walls)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.walls = walls
    return o
end

function WallManager:loadWalls(o)
    for _, wall in pairs(o.walls) do
        wall:load(wall)
    end
end

function WallManager:renderWalls(o)
    for _, wall in pairs(o.walls) do
        wall:render(wall)
    end
end

return WallManager
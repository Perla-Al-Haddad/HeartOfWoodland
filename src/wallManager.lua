Class = require('lib.hump.class')

local WallManager = Class {
    init = function(self, walls) self.walls = walls end,

    loadWalls = function(self)
        for _, wall in pairs(self.walls) do wall:load() end
    end,

    renderWalls = function(self)
        for _, wall in pairs(self.walls) do wall:render() end
    end
}

return WallManager

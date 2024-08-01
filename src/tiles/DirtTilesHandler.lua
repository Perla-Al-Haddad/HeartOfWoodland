local Class = require("lib.hump.class")

local DirtTile = require("src.tiles.DirtTile")

local DirtTilesHandler = Class {

    init = function(self)
        self.dirtTiles = {}
    end,

    addTile = function(self, positionX, positionY, world)
        local dirtTile = DirtTile(positionX, positionY, world)
        table.insert(self.dirtTiles, dirtTile)

        for _, tile in pairs(self.dirtTiles) do
            tile:setNeighbors(self.dirtTiles)
        end

        for _, tile in pairs(self.dirtTiles) do
            tile:setTileSprite()
        end
    end,

    draw = function(self)
        for _, tile in pairs(self.dirtTiles) do
            tile:draw()
        end
    end
}

return DirtTilesHandler

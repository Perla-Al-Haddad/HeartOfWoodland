GameSettings = require("src.gameSettings")
Class = require("lib.hump.class")

local Wall = Class {
    init = function(self, positionX, positionY, world)
        self.type = 'wall'
        self.collisionW = GameSettings.TILE_SIZE
        self.collisionH = GameSettings.TILE_SIZE
        self.world = world
        self.positionX = positionX
        self.positionY = positionY
    end,

    render = function(self)
        love.graphics.setColor(GameSettings:getBlueColor(0.65))
        love.graphics.rectangle("fill", self.positionX, self.positionY,
                                self.collisionW, self.collisionH)
        love.graphics.setColor(GameSettings:getBlueColor(1))
        love.graphics.rectangle("line", self.positionX, self.positionY,
                                self.collisionW, self.collisionH)

        love.graphics.setColor(255, 255, 255)
    end,

    load = function(self)
        self.world:add(self, self.positionX, self.positionY, self.collisionW,
                       self.collisionH)
    end
}

return Wall

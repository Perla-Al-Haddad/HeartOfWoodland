Class = require("lib.hump.class")

local Wall = Class {
    init = function(self, positionX, positionY, world)
        self.collisionW = 16
        self.collisionH = 16
        self.world = world
        self.positionX = positionX
        self.positionY = positionY
    end,

    render = function (self)
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle("line", self.positionX - self.collisionW / 2,
                                self.positionY - self.collisionH / 2,
                                self.collisionW, self.collisionH)
        love.graphics.setColor(255, 255, 255)
    end,

    load = function (self)
        local block = {self.positionX, self.positionY, self.collisionW, self.collisionH}
        self.world:add(block, self.positionX, self.positionY, self.collisionW,
                       self.collisionH)
    end
}

return Wall

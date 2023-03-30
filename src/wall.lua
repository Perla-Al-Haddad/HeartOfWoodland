GameSettings = require("src.gameSettings")
Class = require("lib.hump.class")

local Wall = Class {
    init = function(self, positionX, positionY, world)
        self.type = 'wall'
        self.collisionW = GameSettings.TILE_SIZE
        self.collisionH = GameSettings.TILE_SIZE
        self.world = world
        self.collider = self.world:newRectangleCollider(positionX, positionY,
                                                           self.collisionW,
                                                           self.collisionH);
        self.collider:setType('static');
        self.collider:setCollisionClass("Wall");
        self.collider:setFixedRotation(true);
    end,

    render = function(self)
        love.graphics.setColor(GameSettings:getBlueColor(0.65))
        love.graphics.rectangle("fill",
                                self.collider:getX() - self.collisionW / 2,
                                self.collider:getY() - self.collisionH / 2,
                                self.collisionW, self.collisionH)
        love.graphics.setColor(GameSettings:getBlueColor(1))
        love.graphics.rectangle("line",
                                self.collider:getX() - self.collisionW / 2,
                                self.collider:getY() - self.collisionH / 2,
                                self.collisionW, self.collisionH)

        love.graphics.setColor(255, 255, 255)
    end,

    load = function(self) end
}

return Wall

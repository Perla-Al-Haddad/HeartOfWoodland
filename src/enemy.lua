GameSettings = require("src.gameSettings")
Class = require("lib.hump.class")

Enemy = Class {
    init = function(self, positionX, positionY, world)
        self.positionX = positionX;
        self.positionY = positionY;
        self.collisionW = GameSettings.TILE_SIZE;
        self.collisionH = GameSettings.TILE_SIZE;

        self.world = world;
    end,

    load = function(self)
        self.world:add(self, self.positionX, self.positionY, self.collisionW,
                       self.collisionH)
    end,

    render = function(self)
        love.graphics.setColor(GameSettings:getPinkColor(0.75));
        love.graphics.rectangle('fill', self.positionX - self.collisionW / 2,
                                self.positionY - self.collisionH / 2,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(GameSettings:getPinkColor(1));
        love.graphics.rectangle('line', self.positionX - self.collisionW / 2,
                                self.positionY - self.collisionH / 2,
                                self.collisionW, self.collisionH);

        love.graphics.setColor(255, 255, 255);
    end
}

return Enemy

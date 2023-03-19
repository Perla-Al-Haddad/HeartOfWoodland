GameSettings = require("src.gameSettings")
Class = require("lib.hump.class")

Enemy = Class {
    init = function(self, positionX, positionY, world)
        self.type = 'enemy'
        self.state = 0

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
        if self.state == -1 then return end
        love.graphics.setColor(GameSettings:getPinkColor(0.75));
        love.graphics.rectangle('fill', self.positionX, self.positionY,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(GameSettings:getPinkColor(1));
        love.graphics.rectangle('line', self.positionX, self.positionY,
                                self.collisionW, self.collisionH);

        love.graphics.setColor(255, 255, 255);
    end,

    die = function(self)
        self.world:remove(self)
        self.state = -1
    end
}

return Enemy

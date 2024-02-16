local Class = require("lib.hump.class")
local anim8 = require('lib.anim8.anim8')

WaveEffect = Class {
    init = function(self, positionX, positionY)
        self.positionX = positionX
        self.positionY = positionY

        self.dead = false
        self.scaleX = 1
        self.scaleY = 1

        self.spriteSheet = love.graphics.newImage(
            '/assets/sprites/particles/wave.png')
        self.width = 16
        self.height = 16
        self.grid = anim8.newGrid(self.width, self.height,
            self.spriteSheet:getWidth(),
            self.spriteSheet:getHeight())
        self.anim = anim8.newAnimation(self.grid('1-17', 1), 0.1)

        self.layer = -1
    end
}

return WaveEffect

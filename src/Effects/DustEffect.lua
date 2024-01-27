local Class = require("lib.hump.class")
local anim8 = require('lib.anim8.anim8')

DustEffect = Class {
    init = function(self, positionX, positionY)
        self.positionX = positionX
        self.positionY = positionY

        self.dead = false
        self.scaleX = 1
        self.scaleY = 1

        self.spriteSheet = love.graphics.newImage(
                               '/assets/sprites/particles/dust_particles_01.png')
        self.width = 12
        self.height = 12
        self.grid = anim8.newGrid(self.width, self.height,
                                  self.spriteSheet:getWidth(),
                                  self.spriteSheet:getHeight())
        self.anim = anim8.newAnimation(self.grid('1-4', 1), 0.1,
                                       function() self.dead = true end)

        self.layer = -1

        self.positionX = self.positionX
        self.positionY = self.positionY + 4
    end
}

return DustEffect
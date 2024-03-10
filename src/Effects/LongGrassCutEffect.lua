local Class = require("lib.hump.class")
local anim8 = require('lib.anim8.anim8')

LongGrassCutEffect = Class {
    init = function(self, positionX, positionY)
        self.positionX = positionX
        self.positionY = positionY

        self.dead = false
        self.scaleX = 1
        self.scaleY = 1

        self.spriteSheet = love.graphics.newImage(
            '/assets/sprites/particles/longgrass_cut_effect.png')
        self.width = 27
        self.height = 25
        self.grid = anim8.newGrid(self.width, self.height,
            self.spriteSheet:getWidth(),
            self.spriteSheet:getHeight())
        self.anim = anim8.newAnimation(self.grid('1-7', 1), 0.1,
            function() self.dead = true end)

        self.layer = -1

        self.positionX = self.positionX
        self.positionY = self.positionY + 4
    end
}

return LongGrassCutEffect

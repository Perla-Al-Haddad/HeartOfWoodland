local Class = require("lib.hump.class")
local anim8 = require('lib.anim8.anim8')

love.graphics.setDefaultFilter("nearest", "nearest")
local SPRITE = love.graphics.newImage('/assets/sprites/particles/hoeSwing.png')

local HoeSwingEffect = Class {
    init = function(self, positionX, positionY, isFlipped)
        self.positionX = positionX
        self.positionY = positionY

        self.dead = false
        self.scaleX = 1
        self.scaleY = 1

        self.spriteSheet = SPRITE
        self.width = 48
        self.height = 40
        self.grid = anim8.newGrid(self.width, self.height,
            self.spriteSheet:getWidth(),
            self.spriteSheet:getHeight())
        self.anim = anim8.newAnimation(self.grid('1-17', 1), 0.05,
            function(animation)
                self.dead = true; animation:pauseAtEnd()
            end)
        
        if isFlipped then
            self.anim:flipH()
        end

        self.layer = 1

        self.positionX = self.positionX
        self.positionY = self.positionY - 15
    end,

    update = function(self, dt)
        self.anim:update(dt)
    end
}

return HoeSwingEffect

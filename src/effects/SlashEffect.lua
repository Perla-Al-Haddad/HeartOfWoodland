local Class = require("lib.hump.class")
local anim8 = require('lib.anim8.anim8')

love.graphics.setDefaultFilter("nearest", "nearest")
local SPRITE = love.graphics.newImage('/assets/sprites/particles/sliceanim.png')

local SlashEffect = Class {
    init = function(self, positionX, positionY, isFlipped, attackDir)
        self.positionX = positionX
        self.positionY = positionY

        self.dead = false
        self.scaleX = 1
        self.scaleY = 1

        self.spriteSheet = SPRITE
        self.width = 23
        self.height = 39
        self.grid = anim8.newGrid(self.width, self.height,
            self.spriteSheet:getWidth(),
            self.spriteSheet:getHeight())
        self.anim = anim8.newAnimation(self.grid('1-5', 1), 0.03,
            function(animation)
                self.dead = true; animation:pauseAtEnd()
            end)

        self.rot = math.atan2(attackDir.y, attackDir.x)

        if self.rot >= 0 and self.rot <= math.pi / 2 then
            self.anim:flipV()
        end

        self.layer = 1

        self.positionX = self.positionX + attackDir.x * 12
        self.positionY = self.positionY + attackDir.y * 12
    end,

    update = function(self, dt)
        self.anim:update(dt)
    end
}

return SlashEffect

local Class = require("lib.hump.class")
local anim8 = require('lib.anim8.anim8')

SwingEffect = Class {
    init = function(self, positionX, positionY, attackDir, comboCount)
        self.positionX = positionX
        self.positionY = positionY

        self.dead = false
        self.scaleX = 1
        self.scaleY = 1

        self.attackDir = attackDir
        self.spriteSheet = love.graphics.newImage(
                               '/assets/sprites/particles/sliceAnim.png')
        self.width = 23
        self.height = 39
        self.grid = anim8.newGrid(self.width, self.height,
                                  self.spriteSheet:getWidth(),
                                  self.spriteSheet:getHeight())
        self.anim = anim8.newAnimation(self.grid('1-2', 1), 0.06,
                                       function() self.dead = true end)
        self.rot = math.atan2(self.attackDir.y, self.attackDir.x)

        if comboCount % 2 == 0 then self.scaleY = -1 end

        self.layer = 0

        self.positionX = self.positionX + self.attackDir.x * 15
        self.positionY = self.positionY + self.attackDir.y * 15 - 4
    end
}

return SwingEffect

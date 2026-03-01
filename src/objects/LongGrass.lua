local SPRITES = {
    top = love.graphics.newImage("/assets/sprites/objects/longgrass_top.png"),
    bottom = love.graphics.newImage("/assets/sprites/objects/longgrass_bottom.png"),
    smallTop = love.graphics.newImage("/assets/sprites/objects/longgrass_small_top.png"),
    smallBottom = love.graphics.newImage("/assets/sprites/objects/longgrass_small_bottom.png")
}

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")
local tween = require('lib.tween.tween')


local LongGrass = Class {
    init = function(self, x, y)
        self.positionX = x
        self.positionY = y

        self.width = 28
        self.height = 20

        self.angleLimit = math.pi / 12

        self.tweenTarget = { angle = 0 }
        self.angleTweenRight = tween.new(0.4, self.tweenTarget, { angle = self.angleLimit }, 'inOutSine')
        self.angleTweenLeft = tween.new(0.4, self.tweenTarget, { angle = -self.angleLimit }, 'inOutSine')

        self.activeTween = self.angleTweenRight

        SPRITES.smallTop:setFilter("nearest", "nearest")
        self.animationSheetTop = SPRITES.smallTop

        self.gridTop = anim8.newGrid(self.width, self.height,
            self.animationSheetTop:getWidth(),
            self.animationSheetTop:getHeight())

        self.animations = {}
        self.animations.idleTop = anim8.newAnimation(self.gridTop('1-1', 1), 1,
            function(animation) animation:pauseAtEnd(1) end)

        self.currentAnimationTop = self.animations.idleTop;
    end,

    update = function(self, dt)
        if self.tweenTarget.angle >= self.angleLimit then
            self.activeTween = self.angleTweenLeft
            self.angleTweenRight = tween.new(0.4, self.tweenTarget, { angle = self.angleLimit }, 'inSine')
            -- self.angleLimit = self.angleLimit / 1.048
        elseif self.tweenTarget.angle <= -self.angleLimit then
            self.activeTween = self.angleTweenRight
            self.angleTweenLeft = tween.new(0.4, self.tweenTarget, { angle = -self.angleLimit }, 'inSine')
            -- self.angleLimit = self.angleLimit / 1.048
        end
        self.activeTween:update(dt)
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        self.currentAnimationTop:draw(self.animationSheetTop, self.positionX,
            self.positionY, self.tweenTarget.angle, 1, 1, self.width / 2, self.height - 4)
        love.graphics.rectangle("fill", self.positionX, self.positionY, 2, 2)
    end
}


return LongGrass

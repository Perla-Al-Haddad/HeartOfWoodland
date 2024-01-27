local Class = require("lib.hump.class")
local Vector = require("lib.hump.vector")
local anim8 = require("lib.anim8.anim8")
local sone = require("lib.sone.sone")

local settings = require("src.utils.settings")


Entity = Class {

    init = function(self, positionX, positionY, width, height, speed,
                    hitCollisionClass, hurtCollisionClass, 
                    hitBoxWidth, hitBoxHeight,
                    hurtBoxWidth, hurtBoxHeight,
                    heightOffset, animationSheet, world)
        self.dir = "down"
        self.dirX = 1
        self.dirY = 1
        self.prevDirX = 1
        self.prevDirY = 1
        self.speed = speed

        self.state = "default"

        self.hitBoxWidth = hitBoxWidth
        self.hitBoxHeight = hitBoxHeight

        self.hurtBoxWidth = hurtBoxWidth
        self.hurtBoxHeight = hurtBoxHeight

        self.heightOffset = heightOffset

        self.width = width
        self.height = height

        if self.hitBoxHeight ~= nil and self.hitBoxWidth ~= nil then
            self.hitCollider = world:newBSGRectangleCollider(positionX, positionY,
                                                             self.hitBoxWidth,
                                                             self.hitBoxHeight, 0, {
                collision_class = hitCollisionClass
            })
        end

        self.hurtCollider = world:newBSGRectangleCollider(positionX, positionY,
                                                         self.hurtBoxWidth,
                                                         self.hurtBoxHeight, 3, {
            collision_class = hurtCollisionClass
        })

        self.animationTimer = 0
        self.animationSheet = love.graphics.newImage(animationSheet)
        self.grid = anim8.newGrid(self.width, self.height,
                                  self.animationSheet:getWidth(),
                                  self.animationSheet:getHeight())

        self.animations = self:_getAnimationsAbs()
        self.currentAnimation = self:_getCurrentAnimationAbs()

        self.sounds = {}
        self.sounds.hurt = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/hitHurt.wav"))
        self.sounds.death = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/death.wav"))
    end,

    drawAbs = function(self)
        if settings.DEBUG.HURT_BOXES then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("fill", 
                self.hurtCollider:getX() - (self.hurtBoxWidth/2), 
                self.hurtCollider:getY() - (self.hurtBoxHeight/2), 
                self.hurtBoxWidth, self.hurtBoxHeight)
        end

        if settings.DEBUG.HIT_BOXES and self.hitBoxHeight ~= nil and self.hitBoxWidth ~= nil and self.hitCollider ~= nil then
            love.graphics.setColor(0, 0, 1, 0.5)
            love.graphics.rectangle("fill", 
                self.hitCollider:getX() - (self.hitBoxWidth/2), 
                self.hitCollider:getY() - (self.hitBoxHeight/2), 
                self.hitBoxWidth, self.hitBoxHeight)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end,

    updateAbs = function(dt)
        error("updateAbs method was not implemented in subclass")
    end,

    _getAnimationsAbs = function()
        error("_getAnimationsAbs method was not implemented in subclass")
    end,

    _getCurrentAnimationAbs = function()
        error(
            "_getCurrentAnimationAbs method was not implemented in subclass")
    end,
    
    _distanceBetween = function(self, x1, y1, x2, y2)
        return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    end,

    _getCenterPosition = function(self)
        local px, py = self.hurtCollider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2 - self.heightOffset

        return px, py
    end,

    _setDirFromVector = function(self, vec)
        local rad = math.atan2(vec.y, vec.x)
        if rad >= self.rotateMargin * -1 and rad < math.pi / 2 then
            self.dirX = 1
            self.dirY = 1
        elseif (rad >= math.pi / 2 and rad < math.pi) or
            (rad < (math.pi - self.rotateMargin) * -1) then
            self.dirX = -1
            self.dirY = 1
        elseif rad < 0 and rad > math.pi / -2 then
            self.dirX = 1
            self.dirY = -1
        else
            self.dirX = -1
            self.dirY = -1
        end
    end,

    _toMouseVector = function(self, camera)
        local px, py = self:_getCenterPosition()

        local mx, my = camera:mousePosition()
        return Vector.new(mx - px, my - py):normalized()
    end,

}

return Entity
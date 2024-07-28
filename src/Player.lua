local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")



local Player = Class {
    init = function(self, world, positionX, positionY, hurtCollisionClass, animationSheet)
        self._world = world

        self.dirX = 1
        self.dirY = 1

        self.speed = 120

        self.state = "default"

        self.hurtBoxWidth = 10
        self.hurtBoxHeight = 10

        self.hurtCollider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.hurtBoxWidth,
            self.hurtBoxHeight, 3, {
                collision_class = hurtCollisionClass
            })

        self.width = 32
        self.height = 32

        self.animationSheet = love.graphics.newImage(animationSheet)
        self.grid = anim8.newGrid(self.width, self.height,
            self.animationSheet:getWidth(),
            self.animationSheet:getHeight())

        self.animations = self:_getAnimationsAbs()
        self.currentAnimation = self:_getCurrentAnimationAbs()
    end,

    update = function(self, dt)
        self.currentAnimation:update(dt)
        self:__handlePlayerMovement(dt)
    end,

    draw = function (self)
        local px, py = self:_getSpriteTopPosition()
        self.currentAnimation:draw(self.animationSheet, px, py, nil,
        self.hurtCollider.dirX, 1, 0, 0)
    end,

    _getSpriteTopPosition = function(self)
        if not self.hurtCollider then
            return self.lastX, self.lastY
        end

        local px, py = self.hurtCollider:getPosition()
        px = px - self.width / 2
        py = py - self.height + self.hurtBoxHeight / 2

        return px, py
    end,

    __handlePlayerMovement = function(self, dt)
        if self.state ~= 'default' then return end
        self.hurtCollider:setLinearDamping(0)

        self.pressedDirX, self.pressedDirY = 0, 0

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            self.dirX = 1
            self.pressedDirX = 1
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            self.dirX = -1
            self.pressedDirX = -1
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            self.dirY = 1
            self.pressedDirY = 1
        end
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            self.dirY = -1
            self.pressedDirY = -1
        end

        local vec = Vector(self.pressedDirX, self.pressedDirY):normalized() * self.speed
        self.hurtCollider:setLinearVelocity(vec.x, vec.y)

        if vec.x ~= 0 or vec.y ~= 0 then
            self.currentAnimation = self.animations.walk
        else
            self.currentAnimation = self.animations.idle
        end
        
        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end
    end,

    _getAnimationsAbs = function(self)
        local animations = {}
        animations.idle = anim8.newAnimation(self.grid('1-6', 1), 0.15)
        animations.walk = anim8.newAnimation(self.grid('8-12', 1), 0.15)
        animations.swing = anim8.newAnimation(self.grid('1-1', 1), 0.15)
        animations.stunned = anim8.newAnimation(self.grid('6-6', 1), 0.15)

        return animations
    end,

    _getCurrentAnimationAbs = function(self) return self.animations.idle end,
}


return Player

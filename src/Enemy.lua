local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local Entity = require("src.Entity")

local settings = require("src.utils.settings")

local ENEMY_COLLISION_CLASS = "Enemy"

local onLoop = function(animation)
    animation:pauseAtEnd(3)
end

Enemy = Class {
    __includes = {Entity},

    init = function(self, positionX, positionY, width, height, speed,
                    collisionWidth, collisionHeight, heightOffset,
                    animationSheet, world)
        Entity.init(self, positionX, positionY, width, height, speed,
                    ENEMY_COLLISION_CLASS, collisionWidth, collisionHeight,
                    heightOffset, animationSheet, world)

        self.collider:setLinearDamping(10)

        self.health = 5

        self.startX = positionX + 30
        self.startY = positionY + 30
        self.wanderRadius = 30

        self.wanderSpeed = 15
        self.wanderTimer = 0.5 + math.random() * 2
        self.wanderBufferTimer = 0
        self.wanderDir = Vector(1, 1)
    end,

    updateAbs = function(self, dt)
        self.currentAnimation:update(dt);
        self:_wander(dt);
    end,

    drawAbs = function(self)
        local px, py = self:_getCenterPosition()

        love.graphics.setColor(1, 1, 1, 1)
        self.currentAnimation:draw(self.animationSheet, px, py, nil,
                                   self.collider.dirX, 1, 0, 0)
        
        Entity.drawAbs(self)
    end,

    hit = function(self, damage, dir)
        self.health = self.health - damage;
        
        if self.health <= 0 then 
            self.currentAnimation = self.animations.dead
            return;
        end

        local mag = 50

        self.collider:applyLinearImpulse((dir:normalized()*mag):unpack())
    end,

    _getAnimationsAbs = function(self)
        animations = {}
        animations.idle = anim8.newAnimation(self.grid('1-4', 1), 0.25)
        animations.dead = anim8.newAnimation(self.grid('1-5', 5), 0.25, onLoop)

        return animations
    end,

    _getCurrentAnimationAbs = function(self) return self.animations.idle end,

    _wander = function(self, dt)
        canWander = (self.state ~= "wandering-moving" or self.state ~=
                        "wandering-stopped") and (self.health > 0)

        if not canWander then return end

        if self.wanderTimer > 0 then
            self.wanderTimer = self.wanderTimer - dt
        end
        if self.wanderBufferTimer > 0 then
            self.wanderBufferTimer = self.wanderBufferTimer - dt
        end

        if self.wanderTimer < 0 then
            self.state = "wandering-moving"
            self.wanderTimer = 0

            local ex = self.collider:getX()
            local ey = self.collider:getY()

            if ex < self.startX and ey < self.startY then
                self.wanderDir = Vector(0, 1)
            elseif ex > self.startX and ey < self.startY then
                self.wanderDir = Vector(-1, 0)
            elseif ex < self.startX and ey > self.startY then
                self.wanderDir = Vector(1, 0)
            else
                self.wanderDir = Vector(0, -1)
            end

            self.wanderBufferTimer = 0.2
            self.wanderDir:rotateInplace(math.pi / -2 * math.random())
        end

        if self.state == "wandering-moving" then
            self.collider:setX(self.collider:getX() + self.wanderDir.x *
                                   self.wanderSpeed * dt)
            self.collider:setY(self.collider:getY() + self.wanderDir.y *
                                   self.wanderSpeed * dt)

            if self:_distanceBetween(self.collider:getX(), self.collider:getY(),
                                     self.startX, self.startY) >
                self.wanderRadius and self.wanderBufferTimer <= 0 then
                self.state = "wandering-stopped"
                self.wanderTimer = 1 + math.random(0.1, 0.8)
            end
        end
    end,

}

return Enemy

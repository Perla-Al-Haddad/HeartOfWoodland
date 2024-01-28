local ENEMY_HIT_COLLISION_CLASS = "EnemyHit"
local ENEMY_HURT_COLLISION_CLASS = "EnemyHurt"

local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local Entity = require("src.Entity")
local HealthDrop = require("src.HealthDrop")

local settings = require("src.utils.settings")
local shaders = require("src.utils.shaders")


Enemy = Class {
    __includes = {Entity},
    _dropsHandler = nil,

    init = function(self, positionX, positionY, width, height, speed,
                    hitBoxWidth, hitBoxHeight, 
                    hurtBoxWidth, hurtBoxHeight, 
                    heightOffset, animationSheet, world, dropsHandler)
        Entity.init(self, positionX, positionY, width, height, speed,
                    ENEMY_HIT_COLLISION_CLASS,
                    ENEMY_HURT_COLLISION_CLASS,
                    hitBoxWidth, hitBoxHeight, 
                    hurtBoxWidth, hurtBoxHeight,
                    heightOffset, animationSheet, world)
        _dropsHandler = dropsHandler

        self.hurtCollider:setLinearDamping(10)

        self.hitCollider:setType("static")

        self.health = 3

        self.startX = positionX + 30
        self.startY = positionY + 30
        
        self.wanderRadius = 30
        self.wanderSpeed = 15
        self.wanderTimer = 0.5 + math.random() * 2
        self.wanderBufferTimer = 0
        self.wanderDir = Vector(1, 1)
        
        self.flashTimer = 0
    end,

    updateAbs = function(self, dt)
        self.currentAnimation:update(dt);
        self:_wander(dt);

        self.flashTimer = self.flashTimer - dt

        if self.hitCollider ~= nil then
            self.hitCollider:setX(self.hurtCollider:getX())
            self.hitCollider:setY(self.hurtCollider:getY())
        end
    end,

    drawAbs = function(self)
        local px, py = self:_getCenterPosition()

        love.graphics.setColor(1, 1, 1, 1)
        if self.flashTimer > 0 then love.graphics.setShader(shaders.whiteout) end
        self.currentAnimation:draw(self.animationSheet, px, py, nil,
                                   self.hurtCollider.dirX, 1, 0, 0)
        love.graphics.setShader()
        
        Entity.drawAbs(self)
    end,

    hit = function(self, damage, dir, shake)
        self.health = self.health - damage;
        
        if self.health <= 0 then 
            self:_die(dir)
            return;
        end

        self.flashTimer = 0.1

        self.sounds.hurt:play()
        
        -- shake:start(0.02, 0.9, 0.01);
        local mag = 50
        self.hurtCollider:applyLinearImpulse((dir:normalized()*mag):unpack())
    end,

    _die = function(self, dir)
        self.currentAnimation = self.animations.dead
        if self.hitCollider == nil then return end;
        self.hitCollider:destroy()
        self.hitCollider = nil
        
        local px, py = self.hurtCollider:getX(), self.hurtCollider:getY()
        self.hurtCollider:destroy()
        self.hurtCollider = _world:newBSGRectangleCollider(
            px, py,
            self.hurtBoxWidth, self.hurtBoxHeight, 3, 
            {collision_class = "Dead"}
        );
        self.hurtCollider:applyLinearImpulse((dir:normalized()*100):unpack())
        self.hurtCollider:setLinearDamping(10)
        self.hurtCollider:setFixedRotation(true)

        self.sounds.death:play()

        if math.random(1,10) > 5 then _dropsHandler:addDrop(HealthDrop(px, py, _world)) end
    end,

    _getAnimationsAbs = function(self)
        animations = {}
        animations.idle = anim8.newAnimation(self.grid('1-4', 1), 0.25)
        animations.dead = anim8.newAnimation(self.grid('1-5', 5), 0.25, function(animation) animation:pauseAtEnd(3) end)

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

            local ex = self.hurtCollider:getX()
            local ey = self.hurtCollider:getY()

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
            self.hurtCollider:setX(self.hurtCollider:getX() + self.wanderDir.x *
                                   self.wanderSpeed * dt)
            self.hurtCollider:setY(self.hurtCollider:getY() + self.wanderDir.y *
                                   self.wanderSpeed * dt)
            self.hitCollider:setX(self.hitCollider:getX() + self.wanderDir.x *
                                   self.wanderSpeed * dt)
            self.hitCollider:setY(self.hitCollider:getY() + self.wanderDir.y *
                                   self.wanderSpeed * dt)

            if self:_distanceBetween(self.hurtCollider:getX(), self.hurtCollider:getY(),
                                     self.startX, self.startY) >
                self.wanderRadius and self.wanderBufferTimer <= 0 then
                self.state = "wandering-stopped"
                self.wanderTimer = 1 + math.random(0.1, 0.8)
            end
        end
    end,

}

return Enemy

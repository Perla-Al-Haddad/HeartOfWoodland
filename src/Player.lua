local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local Entity = require("src.Entity")
local SwingEffect = require("src.Effects.SwingEffect")

local PLAYER_COLLISION_CLASS = "Player"
local PLAYER_SPRITE_SHEET_PATH = "/assets/sprites/characters/player.png"

local funcs = require("src.utils.funcs")
local settings = require("src.utils.settings")

Player = Class {
    __includes = {Entity},
    _world = nil,
    _polygon = nil,

    init = function(self, positionX, positionY, width, height, speed,
                    collisionWidth, collisionHeight, heightOffset, world)
        Entity.init(self, positionX, positionY, width, height, speed, PLAYER_COLLISION_CLASS,
                    collisionWidth, collisionHeight, heightOffset,
                    PLAYER_SPRITE_SHEET_PATH, world)

        _world = world
        self.rotateMargin = 0.25
        self.comboCount = 0
        self.buffer = {}
    end,

    updateAbs = function(self, dt, effectsHandler, enemiesHander)
        self.currentAnimation:update(dt)

        self:_handlePlayerMovement(dt)
        self:_handleSwordSwing(dt, effectsHandler, enemiesHander)
    end,

    drawAbs = function(self)
        local px, py = self:_getCenterPosition()

        love.graphics.setColor(1, 1, 1, 1)

        self.currentAnimation:draw(self.animationSheet, px, py, nil,
                                    self.collider.dirX, 1, 0, 0)
        
        if _polygon ~= nil and settings.DEBUG.HIT_BOXES then
            love.graphics.setColor(0, 0, 1, 0.5)
            love.graphics.polygon("fill", _polygon)
        end

        Entity.drawAbs(self)

        love.graphics.setColor(1, 1, 1, 1)
    end,

    useItem = function(self, item, camera)
        if item == "sword" then self:_swingSword(camera) end
    end,

    _getAnimationsAbs = function(self)
        animations = {}
        animations.idle = anim8.newAnimation(self.grid('1-2', 1), 0.25)
        animations.walk = anim8.newAnimation(self.grid('8-12', 1), 0.15)
        animations.swing = anim8.newAnimation(self.grid('1-1', 1), 0.15)

        return animations
    end,

    _getCurrentAnimationAbs = function(self) return self.animations.idle end,

    _addToBuffer = function(self, action)
        table.insert(self.buffer, {action, 0.25})
    end,

    _swingSword = function(self, camera)
        canSwing = (self.state == "swing" or self.state == "swinging")
        if canSwing then
            self:_addToBuffer("sword")
            return
        end

        self.comboCount = self.comboCount + 1

        self.attackDir = self:_toMouseVector(camera)
        self:_setDirFromVector(self.attackDir)

        self.state = "swing"

        self.currentAnimation = self.animations.swing
        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end

        self.animationTimer = 0.075
    end,

    _swordDamage = function(self, dt, enemiesHander)
        local px, py = self.collider:getPosition()
        local dir = player.attackDir:normalized()
        local rightDir = dir:rotated(math.pi/2)
        local leftDir = dir:rotated(math.pi/-2)
        _polygon = {
            px + dir.x*30,
            py + dir.y*30,
            px + dir:rotated(math.pi/8).x*30,
            py + dir:rotated(math.pi/8).y*30,
            px + dir:rotated(math.pi/4).x*30,
            py + dir:rotated(math.pi/4).y*30,
            px + dir:rotated(3*math.pi/8).x*30,
            py + dir:rotated(3*math.pi/8).y*30,
            px + rightDir.x*15,
            py + rightDir.y*15,
            px + rightDir.x*15 + rightDir:rotated(math.pi/2).x,
            py + rightDir.y*15 + rightDir:rotated(math.pi/2).y,
            px + leftDir.x*15 + leftDir:rotated(math.pi/-2).x,
            py + leftDir.y*15 + leftDir:rotated(math.pi/-2).y,
            px + leftDir.x*15,
            py + leftDir.y*15,
            px + dir:rotated(3*math.pi/-8).x*30,
            py + dir:rotated(3*math.pi/-8).y*30,
            px + dir:rotated(math.pi/-4).x*30,
            py + dir:rotated(math.pi/-4).y*30,
            px + dir:rotated(math.pi/-8).x*30,
            py + dir:rotated(math.pi/-8).y*30,
        }

        local range = math.random()/4

        local hitEnemies = _world:queryPolygonArea(_polygon, {'Enemy'})

        for _, enemyCollider in ipairs(hitEnemies) do
            local knockbackDir = self:_getPlayerToSelfVector(enemyCollider:getX(), enemyCollider:getY())
            enemy = enemiesHander:getEnemyByCollider(enemyCollider)
            enemy:hit(1, knockbackDir)
        end
    end,

    _getPlayerToSelfVector = function(self, x, y)
        return Vector(x - self.collider:getX(), y - self.collider:getY()):normalized()
    end,

    _handleSwordSwing = function(self, dt, effectsHandler, enemiesHander)
        isNotSwinging = not (self.state == 'swing' or self.state == 'swinging')
        if isNotSwinging then return end

        self.animationTimer = self.animationTimer - dt

        if self.state == "swing" then
            self.collider:setLinearVelocity((self.attackDir * 200):unpack())
        elseif self.state == "swinging" then
            self.collider:setLinearDamping(35)
        end

        stillSwinging = self.animationTimer >= 0
        if stillSwinging then return end

        if self.state == "swing" then
            self.state = "swinging"

            -- animationTimer for finished sword swing stance
            self.animationTimer = 0.25
            local swingEffect = SwingEffect(self.collider:getX(),
                                            self.collider:getY(),
                                            self.attackDir, self.comboCount)
            effectsHandler:addEffect(swingEffect)
            self:_swordDamage(dt, enemiesHander)
        elseif self.state == "swinging" then
            _polygon = nil
            self.state = "default"
        end
    end,

    _handlePlayerMovement = function(self, dt)
        if self.state ~= 'default' then return end

        self.collider:setLinearDamping(0)

        self.prevDirX = self.dirX
        self.prevDirY = self.dirY

        local dirX = 0
        local dirY = 0

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            dirX = 1
            self.dirX = 1
        end

        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            dirX = -1
            self.dirX = -1
        end

        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            dirY = 1
            self.dirY = 1
        end

        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            dirY = -1
            self.dirY = -1
        end

        if dirY == 0 and dirX ~= 0 then self.dirY = 1 end

        local vec = Vector(dirX, dirY):normalized() * self.speed
        self.collider:setLinearVelocity(vec.x, vec.y)

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

    end

}

return Player

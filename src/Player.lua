local KNOCKBACK_STRENGTH = 120
local KNOCKBACK_TIMER = 0.075
local STUN_TIMER = 0.075
local PLAYER_COLLISION_CLASS = "Player"
local PLAYER_SPRITE_SHEET_PATH = "/assets/sprites/characters/player.png"

local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")
local Gamestate = require("lib.hump.gamestate");

local Entity = require("src.Entity")
local SwingEffect = require("src.effects.SwingEffect")

local funcs = require("src.utils.funcs");
local settings = require("src.utils.settings");


Player = Class {
    __includes = {Entity},
    _world = nil,
    _polygon = nil,

    init = function(self, positionX, positionY, width, height, speed,
                    hurtBoxWidth, hurBoxHeight, heightOffset, world)
        Entity.init(self, positionX, positionY, width, height, speed, nil, PLAYER_COLLISION_CLASS,
                    nil, nil, hurtBoxWidth, hurBoxHeight, heightOffset,
                    PLAYER_SPRITE_SHEET_PATH, world)

        _world = world

        self.health = 15

        self.pressedDirY = 0
        self.pressedDirX = 0

        self.rotateMargin = 0.25
        self.comboCount = 0
        self.buffer = {}
        self.knockbackTimer = 0
        self.stunTimer = 0
    end,

    updateAbs = function(self, dt, effectsHandler, enemiesHandler, shake)
        self.currentAnimation:update(dt)

        self:_handlePlayerMovement(dt)
        self:_handleSwordSwing(dt, effectsHandler, enemiesHandler, shake)
        self:_handleEnemyCollision(dt, shake)
        self:_handleStunnedDuration(dt)
    end,

    drawAbs = function(self)
        local px, py = self:_getCenterPosition()
        love.graphics.setColor(1, 1, 1, 1)

        self.currentAnimation:draw(self.animationSheet, px, py, nil,
                                    self.hurtCollider.dirX, 1, 0, 0)
        
        if _polygon ~= nil and settings.DEBUG.HIT_BOXES then
            love.graphics.setColor(0, 0, 1, 0.5)
            love.graphics.polygon("fill", _polygon)
        end

        Entity.drawAbs(self)
    end,

    useItem = function(self, item, camera)
        if item == "sword" then self:_swingSword(camera) end
    end,

    _getAnimationsAbs = function(self)
        animations = {}
        animations.idle = anim8.newAnimation(self.grid('1-6', 1), 0.15)
        animations.walk = anim8.newAnimation(self.grid('8-12', 1), 0.15)
        animations.swing = anim8.newAnimation(self.grid('1-1', 1), 0.15)
        animations.stunned = anim8.newAnimation(self.grid('6-6', 1), 0.15)

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

    _swordDamage = function(self, dt, enemiesHandler, shake)
        local px, py = self.hurtCollider:getPosition()
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

        local hitEnemies = _world:queryPolygonArea(_polygon, {'EnemyHurt'})

        for _, enemyCollider in ipairs(hitEnemies) do
            local knockbackDir = self:_getPlayerToSelfVector(enemyCollider:getX(), enemyCollider:getY())
            enemy = enemiesHandler:getEnemyByCollider(enemyCollider)
            enemy:hit(1, knockbackDir, shake)
        end
    end,

    _getPlayerToSelfVector = function(self, x, y)
        return Vector(x - self.hurtCollider:getX(), y - self.hurtCollider:getY()):normalized()
    end,

    _handleSwordSwing = function(self, dt, effectsHandler, enemiesHandler, shake)
        isNotSwinging = not (self.state == 'swing' or self.state == 'swinging')
        if isNotSwinging then return end

        self.animationTimer = self.animationTimer - dt

        if self.state == "swing" then
            self.hurtCollider:setLinearVelocity((self.attackDir * 200):unpack())
        elseif self.state == "swinging" then
            self.hurtCollider:setLinearDamping(35)
        end

        stillSwinging = self.animationTimer >= 0
        if stillSwinging then return end

        if self.state == "swing" then
            self.state = "swinging"

            -- animationTimer for finished sword swing stance
            self.animationTimer = 0.25
            local swingEffect = SwingEffect(self.hurtCollider:getX(),
                                            self.hurtCollider:getY(),
                                            self.attackDir, self.comboCount)
            effectsHandler:addEffect(swingEffect)
            self:_swordDamage(dt, enemiesHandler, shake)
        elseif self.state == "swinging" then
            _polygon = nil
            self.state = "default"
        end
    end,

    _handlePlayerMovement = function(self, dt)
        if self.state ~= 'default' then return end

        self.hurtCollider:setLinearDamping(0)

        self.prevDirX = self.dirX
        self.prevDirY = self.dirY

        self.pressedDirX = 0
        self.pressedDirY = 0

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            self.pressedDirX = 1
            self.dirX = 1
        end

        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            self.pressedDirX = -1
            self.dirX = -1
        end

        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            self.pressedDirY = 1
            self.dirY = 1
        end

        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            self.pressedDirY = -1
            self.dirY = -1
        end

        if self.pressedDirY == 0 and self.pressedDirX ~= 0 then self.dirY = 1 end

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

    _handleEnemyCollision = function(self, dt, shake)
        if self.state == "damage" then
            self.knockbackTimer = self.knockbackTimer - dt
        
            if self.knockbackTimer <= 0 then
                self.state = "stunned"
            end
            self.stunTimer = STUN_TIMER
        end

        if not self.hurtCollider:enter('EnemyHit') then return end
        
        self.state = "damage"

        self.health = self.health - 1;

        if self.health <= 0 then
            local menu = require("src.states.menu")
            Gamestate.switch(menu)
        end

        collision_data = self.hurtCollider:getEnterCollisionData('EnemyHit')

        knockbackDir = Vector(-self.pressedDirX, -self.pressedDirY):normalized()
        self.hurtCollider:applyLinearImpulse((knockbackDir:normalized()*KNOCKBACK_STRENGTH):unpack())

        shake:start(0.1, 2, 0.02);

        self.knockbackTimer = KNOCKBACK_TIMER
    end,

    _handleStunnedDuration = function(self, dt)
        if self.state ~= "stunned" then return end; 

        self.currentAnimation = self.animations.stunned
        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end

        self.hurtCollider:setLinearVelocity(0, 0)
        self.stunTimer = self.stunTimer - dt

        if self.stunTimer <= 0 then
            self.state = "default"
        end
    end
}

return Player

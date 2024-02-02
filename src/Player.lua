local KNOCKBACK_STRENGTH = 120
local KNOCKBACK_TIMER = 0.075
local STUN_TIMER = 0.075
local PLAYER_COLLISION_CLASS = "Player"
local PLAYER_SPRITE_SHEET_PATH = "/assets/sprites/characters/player.png"

local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")
local Gamestate = require("lib.hump.gamestate");
local sone = require("lib.sone.sone")

local Entity = require("src.Entity")
local SwingEffect = require("src.Effects.SwingEffect")
local DustEffect = require("src.Effects.DustEffect")

local funcs = require("src.utils.funcs");
local conf = require("src.utils.conf");
local audio = require("src.utils.audio");


Player = Class {
    __includes = {Entity},

    init = function(self, positionX, positionY, width, height, speed,
                    hurtBoxWidth, hurBoxHeight, heightOffset, world, handlers)
        Entity.init(self, positionX, positionY, width, height, speed, nil, PLAYER_COLLISION_CLASS,
                    nil, nil, hurtBoxWidth, hurBoxHeight, heightOffset,
                    PLAYER_SPRITE_SHEET_PATH, world)
        self._handlers = handlers

        self.polygon = nil
        self.health = 3

        self.pressedDirY = 0
        self.pressedDirX = 0

        self.rotateMargin = 0.25
        self.comboCount = 0
        self.buffer = {}

        self.knockbackTimer = 0
        self.stunTimer = 0
        self.flashTimer = 0
        self.dustEffectTimer = 0
        self.walkSoundTimer = 0
        
        self.sounds.sword = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/sword.wav"), "static")
        self.sounds.walk = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/walk.wav"), "static")
    end,

    updateAbs = function(self, dt, shake)
        self.currentAnimation:update(dt)
        self:_handlePlayerMovement(dt)
        self:_handleSwordSwing(dt, shake)
        self:_handleEnemyCollision(dt, shake)
        self:_handleStunnedDuration(dt)
        self:_handleDropCollision(dt)
    end,

    drawAbs = function(self)
        local px, py = self:_getCenterPosition()

        love.graphics.setColor(0.1, 0, 0.15, 0.5)
        love.graphics.ellipse("fill", px + self.width/2, py+self.height, self.width/5, 1.5)

        love.graphics.setColor(1, 1, 1, 1)

        if self.flashTimer > 0 then love.graphics.setShader(shaders.whiteout) end
        self.currentAnimation:draw(self.animationSheet, px, py, nil,
                                    self.hurtCollider.dirX, 1, 0, 0)
        love.graphics.setShader()

        if self.polygon ~= nil and conf.DEBUG.HIT_BOXES then
            love.graphics.setColor(0, 0, 1, 0.5)
            love.graphics.polygon("fill", self.polygon)
        end
        if conf.DEBUG.HIT_BOXES then
            love.graphics.setColor(0, 0, 1, 0.5)
            love.graphics.rectangle("fill", px, py + self.heightOffset, self.width, self.height)
        end

        Entity.drawAbs(self)

    end,

    useItem = function(self, item, camera)
        if item == "sword" then self:_swingSword(camera) end
    end,

    interact = function(self)
        local px, py = self:_getCenterPosition()
        local hitChests = self._world:queryRectangleArea(px, py + self.heightOffset, self.width, self.height, {'Objects'});

        for _, objectCollider in ipairs(hitChests) do
            local obj = self._handlers.objects:getObjectByCollider(objectCollider)
            if obj.type == "chest" then obj:open() end
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

    _addToBuffer = function(self, action)
        table.insert(self.buffer, {action, 0.25})
    end,

    _swingSword = function(self, camera)
        local canSwing = (self.state == "swing" or self.state == "swinging")
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

    _swordDamage = function(self, dt, shake)
        local px, py = self.hurtCollider:getPosition()
        local dir = self.attackDir:normalized()
        local rightDir = dir:rotated(math.pi/2)
        local leftDir = dir:rotated(math.pi/-2)
        self.polygon = {
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

        -- local range = math.random()/4

        local hitEnemies = self._world:queryPolygonArea(self.polygon, {'EnemyHurt'})

        for _, enemyCollider in ipairs(hitEnemies) do
            local enemy = self._handlers.enemies:getEnemyByCollider(enemyCollider)
            local knockbackDir = self:_getPlayerToSelfVector(enemyCollider:getX(), enemyCollider:getY())
            if enemy then enemy:hit(1, knockbackDir, shake) end
        end
    end,

    _getPlayerToSelfVector = function(self, x, y)
        return Vector(x - self.hurtCollider:getX(), y - self.hurtCollider:getY()):normalized()
    end,

    _handleSwordSwing = function(self, dt, shake)
        local isNotSwinging = not (self.state == 'swing' or self.state == 'swinging')
        if isNotSwinging then return end

        self.animationTimer = self.animationTimer - dt

        if self.state == "swing" then
            self.sounds.sword:play()
            self.hurtCollider:setLinearVelocity((self.attackDir * 125):unpack())
        elseif self.state == "swinging" then
            self.hurtCollider:setLinearDamping(35)
        end

        local stillSwinging = self.animationTimer >= 0
        if stillSwinging then return end

        if self.state == "swing" then
            self.state = "swinging"

            -- animationTimer for finished sword swing stance
            self.animationTimer = 0.25
            local swingEffect = SwingEffect(self.hurtCollider:getX(),
                                            self.hurtCollider:getY(),
                                            self.attackDir, self.comboCount)
            self._handlers.effects:addEffect(swingEffect)
            self:_swordDamage(dt, shake)
        elseif self.state == "swinging" then
            self.polygon = nil
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

        self.dustEffectTimer = self.dustEffectTimer - dt
        self.walkSoundTimer = self.walkSoundTimer - dt

        if vec.x ~= 0 or vec.y ~= 0 then
            self.currentAnimation = self.animations.walk

            if self.dustEffectTimer <= 0 then
                self.dustEffectTimer = 0.25
                local dustEffect = DustEffect(self.hurtCollider:getX(), self.hurtCollider:getY()-1)
                self._handlers.effects:addEffect(dustEffect)
            end

            if self.walkSoundTimer <= 0 then 
                self.walkSoundTimer = 0.38
                self.sounds.walk:play()
            end
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
        self.flashTimer = self.flashTimer - dt

        if self.state == "damage" then
            self.knockbackTimer = self.knockbackTimer - dt
        
            if self.knockbackTimer <= 0 then
                self.state = "stunned"
            end
            self.stunTimer = STUN_TIMER
        end

        if not self.hurtCollider:enter('EnemyHit') then return end
        
        self.sounds.hurt:play()

        self.state = "damage"
        self.health = self.health - 1;
        if self.health <= 0 then
            self.sounds.death:play()
            audio.gameMusic:stop()
            local menu = require("src.states.menu")
            -- ! AAAAAAAAAAAAAAAAAAAAAAAAH 
            local game = require("src.states.game")
            game:initEntities()
            Gamestate.switch(menu)
        end
        
        local knockbackDir = Vector(-self.pressedDirX, -self.pressedDirY):normalized()
        self.hurtCollider:applyLinearImpulse((knockbackDir:normalized()*KNOCKBACK_STRENGTH):unpack())

        shake:start(0.1, 1, 0.02);

        self.knockbackTimer = KNOCKBACK_TIMER
        self.flashTimer = 0.15
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
    end,

    _handleDropCollision = function(self, dt)
        if not self.hurtCollider:enter('Drops') then return end

        local px, py = self:_getCenterPosition()
        local hitDrops = self._world:queryRectangleArea(px, py + self.heightOffset, self.width, self.height, {'Drops'});

        for _, dropCollider in ipairs(hitDrops) do
            local drop = self._handlers.drops:getDropByCollider(dropCollider)
            drop:pickUp()
            if drop.type == "heart" then self.health = self.health + 1 end
        end

    end
}

return Player

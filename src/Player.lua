local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")
local funcs = require("src.utils.funcs")

local EffectsHandler = require("src.effects.EffectsHandler")
local DigEffect = require("src.effects.DigEffect")
local HoeSwingEffect = require("src.effects.HoeSwingEffect")

local funcs = require("src.utils.funcs")
local conf = require("src.utils.conf")

local Player = Class {
    init = function(self, world, positionX, positionY, hurtCollisionClass, animationSheet, dirtTilesHandler,
                    farmGroundTiles)
        self._world = world

        self.dirX = 1
        self.dirY = 1
        self.attackDir = Vector(self.dirX, self.dirY)

        self.speed = 120

        self.state = conf.PLAYER.STATES.DEFAULT
        self.lastOrientation = conf.PLAYER.ORIENTATION.HORIZONTAL

        self.hurtBoxWidth = 10
        self.hurtBoxHeight = 10

        self.hurtCollider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.hurtBoxWidth,
            self.hurtBoxHeight, 3, {
                collision_class = hurtCollisionClass
            })

        self.width = 32
        self.height = 32

        self.buffer = {}

        self.animationSheet = love.graphics.newImage(animationSheet)
        self.grid = anim8.newGrid(self.width, self.height,
            self.animationSheet:getWidth(),
            self.animationSheet:getHeight())

        self.animations = self:_getAnimationsAbs()
        self.currentAnimation = self:_getCurrentAnimationAbs()

        self.dirtTilesHandler = dirtTilesHandler
        self.farmGroundTiles = farmGroundTiles

        self.effectsHandler = EffectsHandler()
        self.tillingOverlay = nil
    end,

    update = function(self, dt)
        self.currentAnimation:update(dt)
        self:__handlePlayerMovement(dt)
        self:__handleHoeSwing(dt)
        self:__updateTillingOverlayPosition()

        self:useItem()

        self.effectsHandler:updateEffects(dt)
    end,

    draw = function(self)
        self.effectsHandler:drawEffects(-1)

        self:__drawTillingOverlay()

        local px, py = self:_getSpriteTopPosition()
        self.currentAnimation:draw(self.animationSheet, px, py, nil, self.hurtCollider.dirX, 1, 0, 0)

        self.effectsHandler:drawEffects(1)
    end,

    useItem = function(self)
        local item = table.remove(self.buffer, 1)
        if item == "hoe" then self:__swingHoe() end
    end,

    _setDirFromVector = function(self, vec)
        local rad = math.atan2(vec.y, vec.x)
        if rad < math.pi / 2 then
            self.dirX = 1
            self.dirY = 1
        elseif rad >= math.pi / 2 and rad < math.pi then
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

    _getSpriteTopPosition = function(self)
        if not self.hurtCollider then
            return self.lastX, self.lastY
        end

        local px, py = self.hurtCollider:getPosition()
        px = px - self.width / 2
        py = py - self.height + self.hurtBoxHeight / 2

        return px, py
    end,

    _addToBuffer = function(self, action)
        table.insert(self.buffer, action)
    end,

    _getAnimationsAbs = function(self)
        local animations = {}
        animations.idle = anim8.newAnimation(self.grid('1-6', 1), 0.15)
        animations.walk = anim8.newAnimation(self.grid('8-12', 1), 0.15)
        animations.swing = anim8.newAnimation(self.grid('1-1', 1), 0.15)
        animations.swingHoe = anim8.newAnimation(self.grid('1-17', 3), 0.05)
        animations.stunned = anim8.newAnimation(self.grid('6-6', 1), 0.15)

        return animations
    end,

    _getCurrentAnimationAbs = function(self) return self.animations.idle end,

    __setAttackDir = function(self)
        if self.pressedDirX == 0 and self.pressedDirY == 0 then
            if self.lastOrientation == conf.PLAYER.ORIENTATION.HORIZONTAL then
                self.attackDir = Vector(self.dirX, 0)
            else
                self.attackDir = Vector(0, self.dirY)
            end
        else
            self.attackDir = Vector(self.pressedDirX, self.pressedDirY)
        end
    end,

    __swingHoe = function(self)
        local swinging = funcs.hasValue({ conf.PLAYER.STATES.SWING, conf.PLAYER.STATES.SWINGING }, self.state)
        if swinging then
            self:_addToBuffer("hoe")
            return
        end

        self.currentAnimation = self.animations.swingHoe

        self:__setAttackDir()
        self:_setDirFromVector(self.attackDir)

        self.state = conf.PLAYER.STATES.SWING
        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end

        local px, py = self.hurtCollider:getPosition()
        self.effectsHandler:addEffect(HoeSwingEffect(px, py, self.currentAnimation.flippedH))

        self.animationTimer = conf.PLAYER.HOE_SWING_ANIMATION_TIMER
    end,

    __handleHoeSwing = function(self, dt)
        local isNotSwinging = not funcs.hasValue({ conf.PLAYER.STATES.SWING, conf.PLAYER.STATES.SWINGING }, self.state)
        if isNotSwinging then return end

        self.animationTimer = self.animationTimer - dt

        if self.state == conf.PLAYER.STATES.SWING then
            self.hurtCollider:setLinearVelocity(0, 0)
        end

        local stillSwinging = self.animationTimer >= 0
        if stillSwinging then return end

        if self.state == conf.PLAYER.STATES.SWING then
            self.state = conf.PLAYER.STATES.SWINGING
            local px, py = self.hurtCollider:getPosition()
            local dir = self.attackDir:normalized()
            for _, farmGroundTile in pairs(self.farmGroundTiles) do
                if funcs.isPointInRectangle(
                        px + dir.x * conf.TILE_SIZE,
                        py + dir.y * conf.TILE_SIZE,
                        farmGroundTile.positionX, farmGroundTile.positionY,
                        farmGroundTile.width, farmGroundTile.height) and not farmGroundTile.tiled then
                    self.effectsHandler:addEffect(DigEffect(farmGroundTile.positionX + farmGroundTile.width / 2,
                        farmGroundTile.positionY + farmGroundTile.height / 2))
                    farmGroundTile.tiled = true
                    self.dirtTilesHandler:addTile(farmGroundTile.positionX, farmGroundTile.positionY, self._world)
                    break
                end
            end

            self.animationTimer = conf.PLAYER.HOE_SWING_HIT_DELAY
        elseif self.state == conf.PLAYER.STATES.SWINGING then
            self.animations.swingHoe:gotoFrame(1)
            self.hoeHitPoint = nil
            self.state = conf.PLAYER.STATES.DEFAULT
        end
    end,

    __drawTillingOverlay = function(self)
        if not self.tillingOverlay then
            return
        end
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("line", self.tillingOverlay.x, self.tillingOverlay.y, conf.TILE_SIZE, conf.TILE_SIZE)
        love.graphics.setColor(1, 1, 1, 1)
    end,

    __updateTillingOverlayPosition = function(self)
        self:__setAttackDir()

        local dir = self.attackDir:normalized()
        local px, py = self.hurtCollider:getPosition()

        for _, farmGroundTile in pairs(self.farmGroundTiles) do
            if funcs.isPointInRectangle(
                    px + dir.x * conf.TILE_SIZE,
                    py + dir.y * conf.TILE_SIZE,
                    farmGroundTile.positionX, farmGroundTile.positionY,
                    farmGroundTile.width, farmGroundTile.height) and not farmGroundTile.tiled then
                self.tillingOverlay = { x = farmGroundTile.positionX, y = farmGroundTile.positionY }
                return
            end
            self.tillingOverlay = nil
        end
    end,

    __handlePlayerMovement = function(self, dt)
        if self.state ~= conf.PLAYER.STATES.DEFAULT then return end
        self.hurtCollider:setLinearDamping(0)

        self.pressedDirX, self.pressedDirY = 0, 0

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            self.dirX = 1
            self.pressedDirX = 1
            self.lastOrientation = conf.PLAYER.ORIENTATION.HORIZONTAL
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            self.dirX = -1
            self.pressedDirX = -1
            self.lastOrientation = conf.PLAYER.ORIENTATION.HORIZONTAL
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            self.dirY = 1
            self.pressedDirY = 1
            self.lastOrientation = conf.PLAYER.ORIENTATION.VERTICAL
        end
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            self.dirY = -1
            self.pressedDirY = -1
            self.lastOrientation = conf.PLAYER.ORIENTATION.VERTICAL
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

}


return Player

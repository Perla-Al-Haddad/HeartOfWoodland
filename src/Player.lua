local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local EffectsHandler = require("src.effects.EffectsHandler")
local DigEffect = require("src.effects.DigEffect")
local HoeSwingEffect = require("src.effects.HoeSwingEffect")

local Player = Class {
    init = function(self, world, positionX, positionY, hurtCollisionClass, animationSheet, dirtTilesHandler,
                    farmGroundTiles)
        self._world = world

        self.dirX = 1
        self.dirY = 1
        self.attackDir = Vector(self.dirX, self.dirY)

        self.speed = 120

        self.state = "default"
        self.lastPressed = "horizontal"

        self.hurtBoxWidth = 10
        self.hurtBoxHeight = 10

        self.hurtCollider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.hurtBoxWidth,
            self.hurtBoxHeight, 3, {
                collision_class = hurtCollisionClass
            })

        self.width = 32
        self.height = 32

        self.rotateMargin = 0.25

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

        self.effectsHandler:updateEffects(dt)
    end,

    draw = function(self)
        self.effectsHandler:drawEffects(-1)

        self:__drawTillingOverlay()

        local px, py = self:_getSpriteTopPosition()
        self.currentAnimation:draw(self.animationSheet, px, py, nil,
            self.hurtCollider.dirX, 1, 0, 0)

        self.effectsHandler:drawEffects(1)
    end,

    useItem = function(self, item, camera)
        if item == "hoe" then self:__swingHoe(camera) end
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
        table.insert(self.buffer, { action, 0.25 })
    end,

    __swingHoe = function(self)
        local canSwing = (self.state == "swing" or self.state == "swinging")
        if canSwing then
            self:_addToBuffer("hoe")
        end

        self.currentAnimation = self.animations.swingHoe

        if self.pressedDirX == 0 and self.pressedDirY == 0 then
            if self.lastPressed == "horizontal" then
                self.attackDir = Vector(self.dirX, 0)
            else
                self.attackDir = Vector(0, self.dirY)
            end
        else
            self.attackDir = Vector(self.pressedDirX, self.pressedDirY)
        end

        self:_setDirFromVector(self.attackDir)

        self.state = "swing"
        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end

        local px, py = self.hurtCollider:getPosition()
        self.effectsHandler:addEffect(HoeSwingEffect(px, py, self.currentAnimation.flippedH))

        self.animationTimer = 0.6
    end,

    __handleHoeSwing = function(self, dt)
        local isNotSwinging = not (self.state == 'swing' or self.state == 'swinging')
        if isNotSwinging then return end

        self.animationTimer = self.animationTimer - dt

        local px, py = self.hurtCollider:getPosition()

        if self.state == "swing" then
            self.hurtCollider:setLinearVelocity(0, 0)
        end

        local stillSwinging = self.animationTimer >= 0
        if stillSwinging then return end

        if self.state == "swing" then
            self.state = "swinging"

            local dir = self.attackDir:normalized()

            self.hoeHitPoint = {
                x = px + dir.x * 16,
                y = py + dir.y * 16
            }

            for _, farmGroundTile in pairs(self.farmGroundTiles) do
                if self:__isPointInRectangle(
                        self.hoeHitPoint.x, self.hoeHitPoint.y,
                        farmGroundTile.positionX, farmGroundTile.positionY,
                        farmGroundTile.width, farmGroundTile.height) and not farmGroundTile.tiled then
                    self.effectsHandler:addEffect(DigEffect(farmGroundTile.positionX + farmGroundTile.width / 2,
                        farmGroundTile.positionY + farmGroundTile.height / 2))
                    farmGroundTile.tiled = true
                    self.dirtTilesHandler:addTile(farmGroundTile.positionX, farmGroundTile.positionY, self._world)
                    break
                end
            end

            self.animationTimer = 0.2
        elseif self.state == "swinging" then
            self.animations.swingHoe:gotoFrame(1)
            self.hoeHitPoint = nil
            self.state = "default"
        end
    end,

    __drawTillingOverlay = function(self)
        if not self.tillingOverlay then
            return
        end
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("line", self.tillingOverlay.x, self.tillingOverlay.y, 16, 16)
        love.graphics.setColor(1, 1, 1, 1)
    end,

    __updateTillingOverlayPosition = function(self)
        if self.pressedDirX == 0 and self.pressedDirY == 0 then
            if self.lastPressed == "horizontal" then
                self.attackDir = Vector(self.dirX, 0)
            else
                self.attackDir = Vector(0, self.dirY)
            end
        else
            self.attackDir = Vector(self.pressedDirX, self.pressedDirY)
        end
        local dir = self.attackDir:normalized()
        local px, py = self.hurtCollider:getPosition()
        for _, farmGroundTile in pairs(self.farmGroundTiles) do
            if self:__isPointInRectangle(
                    px + dir.x * 16,
                    py + dir.y * 16,
                    farmGroundTile.positionX, farmGroundTile.positionY,
                    farmGroundTile.width, farmGroundTile.height) and not farmGroundTile.tiled then
                self.tillingOverlay = { x = farmGroundTile.positionX, y = farmGroundTile.positionY }
                return
            end
            self.tillingOverlay = nil
        end
    end,

    __isPointInRectangle = function(self, px, py, rx, ry, rw, rh)
        return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
    end,

    __handlePlayerMovement = function(self, dt)
        if self.state ~= 'default' then return end
        self.hurtCollider:setLinearDamping(0)

        self.pressedDirX, self.pressedDirY = 0, 0

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            self.dirX = 1
            self.pressedDirX = 1
            self.lastPressed = "horizontal"
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            self.dirX = -1
            self.pressedDirX = -1
            self.lastPressed = "horizontal"
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            self.dirY = 1
            self.pressedDirY = 1
            self.lastPressed = "vertical"
        end
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            self.dirY = -1
            self.pressedDirY = -1
            self.lastPressed = "vertical"
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
        animations.swingHoe = anim8.newAnimation(self.grid('1-17', 3), 0.05)
        animations.stunned = anim8.newAnimation(self.grid('6-6', 1), 0.15)

        return animations
    end,

    _getCurrentAnimationAbs = function(self) return self.animations.idle end,
}


return Player

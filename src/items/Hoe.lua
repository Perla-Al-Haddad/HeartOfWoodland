local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local DigEffect = require("src.effects.DigEffect")
local HoeSwingEffect = require("src.effects.HoeSwingEffect")

local conf = require("src.utils.conf")
local funcs = require("src.utils.funcs")

local Hoe = Class {
    init = function(self, player)
        self.uiSheet = love.graphics.newImage("/assets/sprites/GUI/GUI_1x.png");
        self.grid16x16 = anim8.newGrid(16, 16,
            self.uiSheet:getWidth(),
            self.uiSheet:getHeight());

        self.name = conf.PLAYER.ITEMS.HOE
        self.icon = anim8.newAnimation(self.grid16x16('6-6', 7), 1);
        self.player = player
    end,

    handleUse = function (self, dt)
        local isNotSwinging = not funcs.hasValue({ conf.PLAYER.STATES.SWING, conf.PLAYER.STATES.SWINGING }, self.player.state)
        if isNotSwinging then return end

        self.player.animationTimer = self.player.animationTimer - dt

        if self.player.state == conf.PLAYER.STATES.SWING then
            self.player.hurtCollider:setLinearVelocity(0, 0)
        end

        local stillSwinging = self.player.animationTimer >= 0
        if stillSwinging then return end

        if self.player.state == conf.PLAYER.STATES.SWING then
            self.player.state = conf.PLAYER.STATES.SWINGING
            local px, py = self.player.hurtCollider:getPosition()
            local dir = self.player.attackDir:normalized()
            for _, farmGroundTile in pairs(self.player.farmGroundTiles) do
                if funcs.isPointInRectangle(
                        px + dir.x * conf.TILE_SIZE,
                        py + dir.y * conf.TILE_SIZE,
                        farmGroundTile.positionX, farmGroundTile.positionY,
                        farmGroundTile.width, farmGroundTile.height) and not farmGroundTile.tiled then
                    self.player.effectsHandler:addEffect(DigEffect(farmGroundTile.positionX + farmGroundTile.width / 2,
                        farmGroundTile.positionY + farmGroundTile.height / 2))
                    farmGroundTile.tiled = true
                    self.player.dirtTilesHandler:addTile(farmGroundTile.positionX, farmGroundTile.positionY, self.player._world)
                    break
                end
            end

            self.player.animationTimer = conf.PLAYER.HOE_SWING_HIT_DELAY
        elseif self.player.state == conf.PLAYER.STATES.SWINGING then
            self.player.animations.swingHoe:gotoFrame(1)
            self.player.hoeHitPoint = nil
            self.player.state = conf.PLAYER.STATES.DEFAULT
        end
    end,
    
    trigger = function(self)
        local swinging = funcs.hasValue({ conf.PLAYER.STATES.SWING, conf.PLAYER.STATES.SWINGING }, self.player.state)
        if swinging then
            self.player:_addToBuffer(self.name)
            return
        end

        self.player.currentAnimation = self.player.animations.swingHoe

        self.player:__setAttackDir()

        self.player.state = conf.PLAYER.STATES.SWING
        if self.player.dirX == -1 and not self.player.currentAnimation.flippedH then
            self.player.currentAnimation:flipH()
        elseif self.player.dirX == 1 and self.player.currentAnimation.flippedH then
            self.player.currentAnimation:flipH()
        end

        local px, py = self.player.hurtCollider:getPosition()
        self.player.effectsHandler:addEffect(HoeSwingEffect(px, py, self.player.currentAnimation.flippedH))

        self.player.animationTimer = conf.PLAYER.HOE_SWING_ANIMATION_TIMER
    end,
}

return Hoe

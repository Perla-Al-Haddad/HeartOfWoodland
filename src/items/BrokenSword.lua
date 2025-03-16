local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local SlashEffect = require("src.effects.SlashEffect")

local conf = require("src.utils.conf")
local funcs = require("src.utils.funcs")

local BrokenSword = Class {
    init = function(self, player, grassHandler)
        self.uiSheet = love.graphics.newImage("/assets/sprites/GUI/GUI_1x.png");
        self.grid16x16 = anim8.newGrid(16, 16,
            self.uiSheet:getWidth(),
            self.uiSheet:getHeight());

        self.name = conf.PLAYER.ITEMS.BROKEN_SWORD
        self.icon = anim8.newAnimation(self.grid16x16('5-5', 7), 1);
        self.player = player
        self.grassHandler = grassHandler
    end,
    
    handleUse = function (self, dt)
        local isNotSlashing = not funcs.hasValue({ conf.PLAYER.STATES.SLASH, conf.PLAYER.STATES.SLASHING }, self.player.state)
        if isNotSlashing then return end

        self.player.animationTimer = self.player.animationTimer - dt

        if self.player.state == conf.PLAYER.STATES.SLASH and self.player.animationTimer < 0.02 then
            self.player.hurtCollider:setLinearDamping(300)
            self.player.hurtCollider:setLinearVelocity((self.player.attackDir * 200):unpack())
        end

        local stillSlashing = self.player.animationTimer >= 0
        if stillSlashing then return end

        if self.player.state == conf.PLAYER.STATES.SLASH then
            self.player.state = conf.PLAYER.STATES.SLASHING
            self.player.animationTimer = 0.02
            
            self:__swordDamage()
            local px, py = self.player.hurtCollider:getPosition()
            self.player.effectsHandler:addEffect(SlashEffect(px, py, self.player.currentAnimation.flippedH, self.player.attackDir))
        elseif self.player.state == conf.PLAYER.STATES.SLASHING then
            self.player.animations.slash:gotoFrame(1)
            self.player.state = conf.PLAYER.STATES.DEFAULT
        end
    end,
    
    trigger = function(self)
        local slashing = funcs.hasValue({ conf.PLAYER.STATES.SLASH, conf.PLAYER.STATES.SLASHING }, self.player.state)
        if slashing then
            self.player:_addToBuffer(self.name)
            return
        end

        self.player.hurtCollider:setLinearVelocity(0, 0)

        self.player.currentAnimation = self.player.animations.slash

        self.player:__setAttackDir()
        self.player:_setDirFromVector(self.player.attackDir)

        self.player.state = conf.PLAYER.STATES.SLASH
        if self.player.dirX == -1 and not self.player.currentAnimation.flippedH then
            self.player.currentAnimation:flipH()
        elseif self.player.dirX == 1 and self.player.currentAnimation.flippedH then
            self.player.currentAnimation:flipH()
        end

        self.player.animationTimer = conf.PLAYER.SLASH_ANIMATION_TIMER
    end,

    __swordDamage = function(self)
        local px, py = self.player.hurtCollider:getPosition()
        local dir = self.player.attackDir:normalized()
        px = px + dir.x * 5
        py = py + dir.y * 5
        local rightDir = dir:rotated(math.pi / 2)
        local leftDir = dir:rotated(math.pi / -2)
        self.polygon = {
            px + dir.x * 20,
            py + dir.y * 20,
            px + dir:rotated(math.pi / 8).x * 20,
            py + dir:rotated(math.pi / 8).y * 20,
            px + dir:rotated(math.pi / 4).x * 20,
            py + dir:rotated(math.pi / 4).y * 20,
            px + dir:rotated(3 * math.pi / 8).x * 20,
            py + dir:rotated(3 * math.pi / 8).y * 20,
            px + rightDir.x * 10,
            py + rightDir.y * 10,
            px + rightDir.x * 10 + rightDir:rotated(math.pi / 2).x,
            py + rightDir.y * 10 + rightDir:rotated(math.pi / 2).y,
            px + leftDir.x * 10 + leftDir:rotated(math.pi / -2).x,
            py + leftDir.y * 10 + leftDir:rotated(math.pi / -2).y,
            px + leftDir.x * 10,
            py + leftDir.y * 10,
            px + dir:rotated(3 * math.pi / -8).x * 20,
            py + dir:rotated(3 * math.pi / -8).y * 20,
            px + dir:rotated(math.pi / -4).x * 20,
            py + dir:rotated(math.pi / -4).y * 20,
            px + dir:rotated(math.pi / -8).x * 20,
            py + dir:rotated(math.pi / -8).y * 20,
        }
        -- local range = math.random()/4
        local hitGrass = self.player._world:queryPolygonArea(self.polygon, { conf.OBJECTS.COLLISION_CLASS })

        for _, grassCollider in ipairs(hitGrass) do
            local grass = self.grassHandler:getByCollider(grassCollider)
            if grass then
                grass:destroy()
            end
        end
    end
}

return BrokenSword

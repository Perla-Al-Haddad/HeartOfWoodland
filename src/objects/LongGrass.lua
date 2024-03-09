local SPRITES = {
    top = love.graphics.newImage("/assets/sprites/objects/longgrass_top.png"),
    bottom = love.graphics.newImage("/assets/sprites/objects/longgrass_bottom.png")
}

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")
local sone = require("lib.sone.sone")

LongGrass = Class {

    init = function(self, positionX, positionY, width, height, collisionWidth, collisionHeight, world)
        self._world = world

        self.type = "longgrass"

        self.width = width
        self.height = height
        self.collisionWidth = collisionWidth
        self.collisionHeight = collisionHeight

        self.position = "bottom"

        self.collider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.collisionWidth,
            self.collisionHeight, 0,
            { collision_class = "LongGrass" })
        self.collider:setType("static")

        self.animationSheetTop = SPRITES.top
        self.gridTop = anim8.newGrid(self.width, 20,
            self.animationSheetTop:getWidth(),
            self.animationSheetTop:getHeight())

        self.animationSheetBottom = SPRITES.bottom
        self.gridBottom = anim8.newGrid(self.width, 5,
            self.animationSheetBottom:getWidth(),
            self.animationSheetBottom:getHeight())

        self.animations = {}
        self.animations.idleTop = anim8.newAnimation(self.gridTop('1-1', 1), 0.5,
            function(animation) animation:pauseAtEnd(1) end)
        self.animations.moveTop = anim8.newAnimation(self.gridTop('1-2', 1), 0.25,
            function(_) self.currentAnimationTop = self.animations.idleTop end)
        self.animations.idleBottom = anim8.newAnimation(self.gridBottom('1-1', 1), 0.5,
            function(animation) animation:pauseAtEnd(1) end)
        self.animations.moveBottom = anim8.newAnimation(self.gridBottom('1-2', 1), 0.25,
            function(_) self.currentAnimationBottom = self.animations.idleBottom end)

        self.currentAnimationTop = self.animations.idleTop;
        self.currentAnimationBottom = self.animations.idleBottom;

        self.sounds = {}
        self.sounds.move = love.audio.newSource(
            sone.fadeInOut(sone.copy(love.sound.newSoundData("/assets/sounds/effects/longgrass.mp3")), 0.5), "static")
        self.sounds.move:setVolume(0.2)
    end,

    update = function(self, dt)
        self.currentAnimationTop:update(dt)
        self.currentAnimationBottom:update(dt)

        if self.collider:enter('Player') or self.collider:enter("EnemyHurt") then
            self.currentAnimationTop = self.animations.moveTop
            self.currentAnimationBottom = self.animations.moveBottom
            self.sounds.move:play()
            self.position = "top"
        elseif self.collider:exit('Player') or self.collider:exit("EnemyHurt") then
            self.position = "bottom"
        end
    end,

    drawTop = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local px, py = self:_getCenterPosition()
        self.currentAnimationTop:draw(self.animationSheetTop, px, py, nil, self.collider.dirX, 1, 0, 0)
    end,

    drawBottom = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local px, py = self:_getCenterPosition()
        self.currentAnimationBottom:draw(self.animationSheetBottom, px, py + 20, nil, self.collider.dirX, 1, 0, 0)
    end,

    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2 + 6

        return px, py
    end,
}

return LongGrass

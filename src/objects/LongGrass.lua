local SPRITES = {
    top = love.graphics.newImage("/assets/sprites/objects/longgrass_top.png"),
    bottom = love.graphics.newImage("/assets/sprites/objects/longgrass_bottom.png"),
    smallTop = love.graphics.newImage("/assets/sprites/objects/longgrass_small_top.png"),
    smallBottom = love.graphics.newImage("/assets/sprites/objects/longgrass_small_bottom.png")
}
local SOUNDS = {
    move = love.sound.newSoundData("/assets/sounds/effects/longgrass.mp3")
}

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")
local sone = require("lib.sone.sone")

LongGrass = Class {
    init = function(self, positionX, positionY, width, height, collisionWidth, collisionHeight, isSmall, world)
        self._world = world

        self.type = "longgrass"
        self.isSmall = isSmall

        self.isCut = false

        self.width = width
        self.height = height
        self.collisionWidth = collisionWidth
        self.collisionHeight = collisionHeight

        self.positionX = positionX
        self.positionY = positionY

        self.position = "bottom"

        if self.isSmall then
            self.animationSheetTop = SPRITES.smallTop
            self.animationSheetBottom = SPRITES.smallBottom
        else
            self.animationSheetTop = SPRITES.top
            self.animationSheetBottom = SPRITES.bottom
        end

        self.gridTop = anim8.newGrid(self.width, 20,
            self.animationSheetTop:getWidth(),
            self.animationSheetTop:getHeight())
        self.gridBottom = anim8.newGrid(self.width, 5,
            self.animationSheetBottom:getWidth(),
            self.animationSheetBottom:getHeight())

        self.animations = {}
        self.animations.idleTop = anim8.newAnimation(self.gridTop('1-1', 1), 1,
            function(animation) animation:pauseAtEnd(1) end)
        self.animations.moveTop = anim8.newAnimation(self.gridTop('1-2', 1), 0.15,
            function(_) self.currentAnimationTop = self.animations.idleTop end)
        self.animations.idleBottom = anim8.newAnimation(self.gridBottom('1-1', 1), 1,
            function(animation) animation:pauseAtEnd(1) end)
        self.animations.moveBottom = anim8.newAnimation(self.gridBottom('1-2', 1), 0.15,
            function(_) self.currentAnimationBottom = self.animations.idleBottom end)

        self.currentAnimationTop = self.animations.idleTop;
        self.currentAnimationBottom = self.animations.idleBottom;

        self.sounds = {}
        self.sounds.move = love.audio.newSource(
            sone.fadeInOut(sone.copy(SOUNDS.move), 0.5), "static")
        self.sounds.move:setVolume(0.2)
    end,

    update = function(self, dt, camera)
        if self.isCut then return end
        local isOnScreen = camera:isOnScreen(self.positionX, self.positionY)
        if self.collider == nil and isOnScreen then
            self.collider = self._world:newBSGRectangleCollider(
                self.positionX, self.positionY,
                self.collisionWidth,
                self.collisionHeight, 0,
                { collision_class = "LongGrass" })
            self.collider:setType("static")
        elseif self.collider and not isOnScreen then
            self.collider:destroy()
            self.collider = nil
            return
        end

        if self.collider and isOnScreen then
            self.currentAnimationTop:update(dt)
            self.currentAnimationBottom:update(dt)

            if self.collider:enter('Player') or self.collider:enter("EnemyHurt") or self.collider:enter("Dead") then
                self.currentAnimationTop = self.animations.moveTop
                self.currentAnimationBottom = self.animations.moveBottom
                self.sounds.move:play()
                self.position = "top"
            elseif self.collider:exit('Player') or self.collider:exit("EnemyHurt") or self.collider:exit("Dead") then
                self.position = "bottom"
            end
        elseif self.collider == nil and isOnScreen then
            self.isCut = true
        end
    end,

    drawTop = function(self)
        if self.isCut then return end
        love.graphics.setColor(1, 1, 1, 1)
        self.currentAnimationTop:draw(self.animationSheetTop, self.positionX, self.positionY, nil, 1, 1, 0, 0)
    end,

    drawBottom = function(self)
        if self.isCut then return end
        love.graphics.setColor(1, 1, 1, 1)
        self.currentAnimationBottom:draw(self.animationSheetBottom, self.positionX, self.positionY + 20, nil, 1, 1, 0, 0)
    end,

    cut = function(self)
        self.isCut = true
        self.collider:destroy()
        self.collider = nil
    end
}

return LongGrass

love.graphics.setDefaultFilter("nearest", "nearest") -- disable blurry scaling

local SPRITES = {
    default = love.graphics.newImage("/assets/sprites/objects/objects.png")
}

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local conf = require("src.utils.conf")

Rock = Class {

    init = function(self, positionX, positionY, world)
        self._world = world

        self.type = "tree"

        self.width = 16
        self.height = 16

        self.positionX = positionX
        self.positionY = positionY

        self.collider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.width,
            self.height, 0,
            { collision_class = conf.OBJECTS.COLLISION_CLASS })
        self.collider:setType("static")

        self.animationSheet = SPRITES.default
        self.grid = anim8.newGrid(self.width, self.height,
            self.animationSheet:getWidth(),
            self.animationSheet:getHeight())

        self.animations = {}
        self.animations.default = anim8.newAnimation(self.grid('1-1', 5), 1)

        self.currentAnimation = self.animations.default;
    end,

    update = function(self)
    end,

    updateOnScreen = function(self, camera)
        local rockIsOnScreen = camera:isOnScreen(self.positionX, self.positionY)
        if self.collider == nil and rockIsOnScreen then
            self.collider = self._world:newBSGRectangleCollider(self.positionX, self.positionY,
                self.width,
                self.height, 0,
                { collision_class = conf.OBJECTS.COLLISION_CLASS })
            self.collider:setType("static")
        elseif self.collider and not rockIsOnScreen then
            self.collider:destroy()
            self.collider = nil
        end
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local px, py = self:_getCenterPosition()
        self.currentAnimation:draw(self.animationSheet, px, py, nil, self.collider.dirX, 1, 0, 0)
    end,

    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2

        return px, py
    end,
}

return Rock

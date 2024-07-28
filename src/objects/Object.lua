love.graphics.setDefaultFilter("nearest", "nearest") -- disable blurry scaling

local SPRITES = {
    default = love.graphics.newImage("/assets/sprites/tilesets/base.png")
}

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local conf = require("src.utils.conf")


local Object = Class {
    init = function(self, positionX, positionY, world)
        self._world = world

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

return Object

love.graphics.setDefaultFilter("nearest", "nearest") -- disable blurry scaling

local SPRITES = {
    default = love.graphics.newImage("/assets/sprites/tilesets/base.png")
}

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local conf = require("src.utils.conf")


local Object = Class {
    init = function(self, positionX, positionY, world, collisionClass)
        self.collisionClass = collisionClass or conf.OBJECTS.COLLISION_CLASS

        self._world = world

        self.width = 16
        self.height = 16

        self.positionX = positionX
        self.positionY = positionY

        self.collider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.width,
            self.height, 0,
            { collision_class = self.collisionClass })
        self.collider:setType("static")

        self.dirX = self.collider.dirX

        self.animationSheet = SPRITES.default
        self.grid = anim8.newGrid(self.width, self.height,
            self.animationSheet:getWidth(),
            self.animationSheet:getHeight())

        self.animations = {}
    end,

    update = function (self, dt) 
        self.currentAnimation:update(dt)
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        self.currentAnimation:draw(self.animationSheet, self.positionX, self.positionY, nil, self.dirX, 1, 0, 0)
    end,
}

return Object

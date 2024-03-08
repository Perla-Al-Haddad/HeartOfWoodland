local OBJECTS_SHEET = "/assets/sprites/objects/objects.png"

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local dialogueHandler = require("src.dialogueHandler")
local dialogueList = require("src.dialogueList")

local conf = require("src.utils.conf")

Sign = Class {

    init = function(self, positionX, positionY, width, height, world, name)
        self._world = world

        self.type = "sign"
        self.name = name

        self.width = width
        self.height = height

        self.collider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.width,
            self.height, 0,
            { collision_class = conf.OBJECTS.COLLISION_CLASS })
        self.collider:setType("static")

        self.animationSheet = love.graphics.newImage(OBJECTS_SHEET)
        self.grid = anim8.newGrid(self.width, self.height,
            self.animationSheet:getWidth(),
            self.animationSheet:getHeight())

        self.animations = {}
        self.animations.default = anim8.newAnimation(self.grid('1-1', 6), 1)

        self.currentAnimation = self.animations.default;
    end,

    update = function(self, dt)
        self.currentAnimation:update(dt)
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local px, py = self:_getCenterPosition()
        self.currentAnimation:draw(self.animationSheet, px, py, nil, self.collider.dirX, 1, 0, 0)
    end,

    display = function(self)
        if #dialogueHandler.lines == 0 and dialogueHandler.currentlyDisplaying then
            return
        end
        if #dialogueHandler.lines == 0 then
            dialogueHandler:insertLines(dialogueList[self.name])
        end
    end,

    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2

        return px, py
    end,

}

return Sign

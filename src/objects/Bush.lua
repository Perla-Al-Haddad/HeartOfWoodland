love.graphics.setDefaultFilter("nearest", "nearest") -- disable blurry scaling

local SPRITES = {
    top = love.graphics.newImage("/assets/sprites/objects/bush_top.png"),
    bottom = love.graphics.newImage("/assets/sprites/objects/bush_bottom.png"),
    default = love.graphics.newImage("/assets/sprites/objects/bush.png")
}

local Class = require("lib.hump.class")

local conf = require("src.utils.conf")

Bush = Class {
    init = function(self, positionX, positionY, offsetX, offsetY, width, height, world)
        self._world = world

        self.type = "bush"

        self.width = width
        self.height = height

        self.positionX = positionX
        self.positionY = positionY

        self.positionXDisplay = positionX + offsetX
        self.positionYDisplay = positionY + offsetY

        self.sprite = SPRITES.default
    end,

    update = function(self, camera)
        local bushIsOnScreen = camera:isOnScreen(self.positionXDisplay, self.positionYDisplay)
        if self.collider == nil and bushIsOnScreen then
            self.collider = self._world:newBSGRectangleCollider(self.positionX, self.positionY,
                self.width,
                self.height, 0,
                { collision_class = conf.OBJECTS.COLLISION_CLASS })
            self.collider:setType("static")
        elseif self.collider and not bushIsOnScreen then
            self.collider:destroy()
            self.collider = nil
        end
    end,

    draw = function(self)
       love.graphics.setColor(1,1,1,1)
       
       local px, py = self:_getCenterPosition()
       love.graphics.draw(self.sprite, px, py)
    end,

    _getCenterPosition = function(self)
        local px, py = self.positionXDisplay, self.positionYDisplay
        return px, py
    end,
}

return Bush
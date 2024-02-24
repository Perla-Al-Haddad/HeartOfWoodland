local SPRITES = {
    top = "/assets/sprites/objects/tree_top.png",
    bottom = "/assets/sprites/objects/tree_bottom.png"
}

local Class = require("lib.hump.class")

local conf = require("src.utils.conf")

Tree = Class {

    init = function(self, positionX, positionY, offsetX, offsetY, width, height, world, hasCollider)
        self._world = world

        self.type = "tree"

        self.width = width
        self.height = height

        self.positionX = positionX
        self.positionY = positionY

        self.positionXDisplay = positionX + offsetX
        self.positionYDisplay = positionY + offsetY

        self.spriteBottom = love.graphics.newImage(SPRITES.bottom)
        self.spriteTop = love.graphics.newImage(SPRITES.top)

        self.hasCollider = hasCollider
    end,

    update = function(self, camera)
        if not self.hasCollider then return end
        local treeIsOnScreen = camera:isOnScreen(self.positionXDisplay, self.positionYDisplay)
        if self.collider == nil and treeIsOnScreen then
            self.collider = self._world:newBSGRectangleCollider(self.positionX, self.positionY,
                self.width,
                self.height, 0,
                { collision_class = conf.OBJECTS.COLLISION_CLASS })
            self.collider:setType("static")
        elseif self.collider and not treeIsOnScreen then
            self.collider:destroy()
            self.collider = nil
        end
    end,

    drawBottom = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local px, py = self:_getCenterPosition()
        love.graphics.draw(self.spriteBottom, px - 12, py - 40)
    end,

    drawTop = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local px, py = self:_getCenterPosition()
        love.graphics.draw(self.spriteTop, px - 12, py - 40)
    end,

    _getCenterPosition = function(self)
        local px, py = self.positionXDisplay, self.positionYDisplay
        return px, py
    end,
}

return Tree

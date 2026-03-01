local Class = require("lib.hump.class")


local FarmGroundTile = Class {
    init = function(self, positionX, positionY, world)
        self._world = world

        self.width = 16
        self.height = 16

        self.positionX = positionX
        self.positionY = positionY

        self.tiled = false

        self.collider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.width,
            self.height, 0,
            { collision_class = "FarmGround" })
        self.collider:setType("static")
    end,
}

return FarmGroundTile

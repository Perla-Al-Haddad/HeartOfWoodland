local Class = require("lib.hump.class")

Wall = Class {
    init = function(self, positionX, positionY, width, height, world)
        self.width = width
        self.height = height
        self.collider = world:newRectangleCollider(positionX, positionY, width, height, {collision_class="Wall"})
        self.collider:setType('static')
    end,

    draw = function(self)
        local px, py = self.collider:getPosition()
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", px-self.width/2, py-self.height/2, self.width, self.height)
    end
}

return Wall
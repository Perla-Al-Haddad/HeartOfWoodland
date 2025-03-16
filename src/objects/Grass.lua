local Class  = require("lib.hump.class")
local anim8  = require("lib.anim8.anim8")

local Object = require("src.objects.Object")


local Grass = Class {
    __includes = { Object },

    init = function(self, positionX, positionY, world)
        Object.init(self, positionX, positionY, world)

        self.type = "grass"

        self.animations.default = anim8.newAnimation(self.grid('4-4', 1), 1)
        self.animations.cut = anim8.newAnimation(self.grid('4-8', 1), 0.05, function(animation) animation:pauseAtEnd(1) end)

        self.currentAnimation = self.animations.default;
    end,

    destroy = function(self)
        self.currentAnimation = self.animations.cut
        self.collider:destroy()
        self.collider = nil
    end
}


return Grass

local Class  = require("lib.hump.class")
local anim8  = require("lib.anim8.anim8")

local Object = require("src.objects.Object")


local Grass = Class {
    __includes = { Object },

    init = function(self, positionX, positionY, world)
        Object.init(self, positionX, positionY, world)

        self.type = "grass"

        self.animations.default = anim8.newAnimation(self.grid('4-4', 1), 1)
        self.animations.cut = anim8.newAnimation(self.grid('4-8', 1), 1)

        self.currentAnimation = self.animations.default;
    end,

    update = function(self, dt)
        self.currentAnimation:update(dt)
    end,
}


return Grass

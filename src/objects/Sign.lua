local Class  = require("lib.hump.class")
local anim8  = require("lib.anim8.anim8")

local Object = require("src.objects.Object")


local Sign = Class {
    __includes = { Object },

    init = function(self, positionX, positionY, world)
        Object.init(self, positionX, positionY, world)

        self.type = "sign"

        self.animations.default = anim8.newAnimation(self.grid('2-2', 8), 1)

        self.currentAnimation = self.animations.default;
    end,
}


return Sign

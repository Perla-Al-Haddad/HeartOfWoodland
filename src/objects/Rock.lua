local Class  = require("lib.hump.class")
local anim8  = require("lib.anim8.anim8")

local Object = require("src.objects.Object")


local Rock = Class {
    __includes = { Object },

    init = function(self, positionX, positionY, world, version, sx)
        Object.init(self, positionX, positionY, world)

        self.type = "rock"

        local tilesetIndex = "3-3"
        if version == 185 then
            tilesetIndex = "4-4"
        end
        self.animations.default = anim8.newAnimation(self.grid(tilesetIndex, 8), 1)
        self.currentAnimation = self.animations.default;

        if sx == -1 then
            self.currentAnimation:flipH()
        end
    end,
}

return Rock

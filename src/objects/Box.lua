local Class  = require("lib.hump.class")
local anim8  = require("lib.anim8.anim8")

local Object = require("src.objects.Object")


local Box = Class {
    __includes = { Object },

    init = function(self, positionX, positionY, world)
        Object.init(self, positionX, positionY, world)

        self.type = "box"

        self.animations.default = anim8.newAnimation(self.grid('14-14', 12), 1)
        self.animations.broken = anim8.newAnimation(self.grid('14-17', 12), 0.1, function(animation) animation:pauseAtEnd(1) end)

        self.currentAnimation = self.animations.default;
    end,

    destroy = function(self)
        self.currentAnimation = self.animations.broken
        local flip = math.random(0, 1)
        if flip == 1 then
            self.currentAnimation:flipH()
        end
        self.collider:destroy()
        self.collider = nil
    end
}


return Box

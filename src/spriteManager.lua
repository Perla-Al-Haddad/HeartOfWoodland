local Class = require('lib.hump.class')


local SpriteManager = Class{
    init = function(self)
    end,

    load = function(self)
        self.effects = {}
        self.effects.slice = love.graphics.newImage('sprites/effects/slice.png')
        self.effects.sliceAnim = love.graphics.newImage('sprites/effects/sliceAnim.png')
    end
}

return SpriteManager
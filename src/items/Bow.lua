local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local conf = require("src.utils.conf")

local Bow = Class {
    init = function(self, player)
        self.uiSheet = love.graphics.newImage("/assets/sprites/GUI/GUI_1x.png");
        self.grid16x16 = anim8.newGrid(16, 16,
            self.uiSheet:getWidth(),
            self.uiSheet:getHeight());

        self.name = conf.PLAYER.ITEMS.BOW
        self.icon = anim8.newAnimation(self.grid16x16('7-7', 7), 1);
        self.player = player
    end,
    
    handleUse = function (self, dt)
    end,

    trigger = function (self)
    end
}

return Bow
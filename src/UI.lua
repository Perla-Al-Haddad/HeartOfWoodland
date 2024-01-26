local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

UI = Class {
    init = function(self)
        self.assetsSheet = love.graphics.newImage("/assets/sprites/GUI/GUI_1x.png");
        self.grid = anim8.newGrid(8, 8,
                                  self.assetsSheet:getWidth(),
                                  self.assetsSheet:getHeight());

        self.heart = anim8.newAnimation(self.grid("9-9", 9), 1);
    end,

    drawPlayerLife = function(self, player)
        for i = 1, player.health, 1 do
            i = i - 1
            line_no = math.floor(i / 11)
            i = i - (line_no * 11)
            self.heart:draw(self.assetsSheet, 7 + (i) * 9, 7 + 9 * line_no, nil, 1, 1, 0, 0)
        end
    end
}

return UI
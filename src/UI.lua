local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local fonts = require("src.utils.fonts")
local conf = require("src.utils.conf")
local funcs = require("src.utils.funcs")

UI = Class {
    init = function(self, player)
        self.uiSheet = love.graphics.newImage("/assets/sprites/GUI/GUI_1x.png");
        self.grid8x8 = anim8.newGrid(8, 8,
            self.uiSheet:getWidth(),
            self.uiSheet:getHeight());
        self.grid16x16 = anim8.newGrid(16, 16,
            self.uiSheet:getWidth(),
            self.uiSheet:getHeight());

        self.bagText = "Bag"
        self.itemText = "Item"

        -- self.brokenSword = anim8.newAnimation(self.grid16x16('5-5', 7), 1);
        -- self.hoe = anim8.newAnimation(self.grid16x16('6-6', 7), 1);
        -- self.bow = anim8.newAnimation(self.grid16x16('7-7', 7), 1);

        self.leftArrow = anim8.newAnimation(self.grid8x8('17-17', 9), 1);
        self.rightArrow = anim8.newAnimation(self.grid8x8('18-18', 9), 1);
        self.upArrow = anim8.newAnimation(self.grid8x8('17-17', 10), 1);
        self.downArrow = anim8.newAnimation(self.grid8x8('18-18', 10), 1);

        self.heart = anim8.newAnimation(self.grid8x8("9-9", 9), 1);
        self.player = player
    end,

    draw = function(self)
        love.graphics.push()
        love.graphics.scale(conf.CAMERA.SCALE)
        self:__drawPlayerLife()
        self:__drawItemSwitcher()
        self:__drawBagItemSwitcher()
        love.graphics.pop()
    end,

    __drawItemSwitcher = function(self)
        local yOffset = conf.gameHeight / conf.CAMERA.SCALE
        local lineColor, bgColor = { 1, 1, 1 }, { 0, 0, 0.1, 0.5 }

        local items = funcs.shallow_copy(self.player.items)
        local activeItem = table.remove(items, self.player.itemIndex)

        for index, item in ipairs(items) do
            item.icon:draw(item.uiSheet, 4 + (16 + 4) * (index - 1), yOffset - 16 - 4, nil, 1, 1, 0, 0)
        end 

        self:__drawItemBox(4, yOffset - 16 - 4, 16, 16, { 1, 1, 1, 0 }, bgColor)
        self:__drawItemBox(4 + 16 + 4, yOffset - 16 - 4, 16, 16, { 1, 1, 1, 0 }, bgColor)
        self:__drawItemBox(4 + 8, yOffset - 16 - 4 - 16 - 8, 20, 20, lineColor, bgColor)

        self.leftArrow:draw(self.uiSheet, 3, yOffset - 16 - 4 - 8 - 2, nil, 1, 1, 0, 0)
        self.rightArrow:draw(self.uiSheet, 3 + 8 + 20 + 2, yOffset - 16 - 4 - 8 - 2, nil,
            1, 1, 0, 0)

        activeItem.icon:draw(activeItem.uiSheet, 4 + 8 + 2, yOffset - 16 - 4 - 16 - 8 + 2, nil, 1, 1, 0, 0)
    end,

    __drawBagItemSwitcher = function(self)
        local lineColor, bgColor = { 1, 1, 1 }, { 0, 0, 0.1, 0.5 }
        local yOffset = conf.gameHeight / conf.CAMERA.SCALE / 2

        love.graphics.setFont(fonts.dialogueS)
        love.graphics.setColor(unpack(lineColor))
        love.graphics.printf(self.bagText, 5, yOffset - 12, fonts.dialogueS:getWidth(self.bagText), "center")

        self:__drawItemBox(4, yOffset, 16, 16, lineColor, bgColor)
        self:__drawItemBox(4, yOffset + 16 + 4, 16, 16, lineColor, bgColor)
        self:__drawItemBox(4, yOffset + (16 + 4) * 2, 16, 16, lineColor, bgColor)

        self.upArrow:draw(self.uiSheet, 3 + 16 + 2, yOffset+ 16, nil, 1, 1, 0, 0)
        self.downArrow:draw(self.uiSheet, 3 + 16 + 2, yOffset+ 16 + 16, nil,
            1, 1, 0, 0)
    end,

    __drawItemBox = function(self, x, y, w, h, lineColor, bgColor)
        love.graphics.setColor(unpack(bgColor))
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(unpack(lineColor))
        love.graphics.rectangle("line", x, y, w, h)
    end,

    __drawPlayerLife = function(self)
        for i = 1, self.player.health, 1 do
            i = i - 1
            local line_no = math.floor(i / 11)
            i = i - (line_no * 11)
            self.heart:draw(self.uiSheet, 7 + (i) * 9, 7 + 9 * line_no, nil, 1, 1, 0, 0)
        end
    end,
}

return UI

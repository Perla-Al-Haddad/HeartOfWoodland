local Class = require("lib.hump.class")

local fonts = require("src.utils.fonts")
local conf = require("src.utils.conf")


SettingsOverlay = Class {
    init = function(self)
        self.options = {"Back"}

        self.active = false;
        self.cursor = {
            x = 0,
            y = 0,
            current = 1
        }
    end,

    draw = function(self)
        if not self.active then return end;

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)

        local title = "Settings"
        local titleWidth = fonts.title:getWidth(title)
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(91/255, 169/255, 121/255)
        love.graphics.printf(title, conf.gameWidth/2 - titleWidth/2, conf.gameHeight/6, titleWidth, "center")

        love.graphics.setFont(fonts.small)
        love.graphics.setColor(1, 1, 1)
        local textHeight;
        for i, option in ipairs(self.options) do
            textHeight = fonts.small:getHeight(option)
            love.graphics.print(
                option, 
                conf.gameWidth/2 - titleWidth/2, 
                conf.gameHeight * 2/3 + (textHeight + fonts.OPTIONS_MARGIN) * (i - 1))
        end

        love.graphics.circle(
            "fill",
            conf.gameWidth/2 - titleWidth/2 - 20, 
            conf.gameHeight * 2/3 + textHeight/2 + (textHeight + fonts.OPTIONS_MARGIN) * (self.cursor.current - 1), 
            textHeight/3)
    end,

    keypressed = function(self, key, parentOverlay)
        if not self.active then return false end;
        if key == "q" or key == "Q" then 
            self.active = false
            return true
        end;
        if key == "e" or key == "E" then
            if self.cursor.current == 1 then
                self.active = false
                if parentOverlay then parentOverlay:setActive(true) end
            end
            return true
        end
        if key == "down" then
            if self.cursor.current >= #self.options then return end;
            self.cursor.current = self.cursor.current + 1
            sounds.select:play()
            return true
        end
        if key == "up" then
            if self.cursor.current <= 1 then return end;
            self.cursor.current = self.cursor.current - 1
            sounds.select:play()
            return true
        end
        return false
    end
}

return SettingsOverlay
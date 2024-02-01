local Gamestate = require("lib.hump.gamestate");
local Class = require("lib.hump.class")

local SettingsOverlay = require("src.overlays.SettingsOverlay")
local fonts = require("src.utils.fonts")

PauseOverlay = Class {
    init = function(self)
        self.title = "-- Paused --"
        self.text = "Press [E] to select"
        self.options = {"Settings", "Main Menu"}
        self.windowWidth, self.windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
        
        self.settingsOverlay = SettingsOverlay();

        self.active = false;
        self.cursor = {
            x = 0,
            y = 0,
            current = 1
        }
    end,

    draw = function(self)
        print("settings active", self.settingsOverlay.active)
        if self.settingsOverlay.active then
            self.settingsOverlay:draw();
            return;
        end 

        if not self.active then return end;

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)

        titleWidth = fonts.title:getWidth(self.title)
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(91/255, 169/255, 121/255)
        love.graphics.printf(self.title, self.windowWidth/2 - titleWidth/2, self.windowHeight/6, titleWidth, "center")

        love.graphics.setFont(fonts.small)
        love.graphics.setColor(1, 1, 1)
        for i, option in ipairs(self.options) do
            textHeight = fonts.small:getHeight(option)
            love.graphics.print(
                option, 
                self.windowWidth/2 - titleWidth/2, 
                self.windowHeight - self.windowHeight/3 + (textHeight + fonts.OPTIONS_MARGIN) * (i - 1))
        end
    
        love.graphics.circle(
            "fill", 
            self.windowWidth/2 - titleWidth/2 - 20, 
            self.windowHeight - self.windowHeight/3 + textHeight/2 + (textHeight + fonts.OPTIONS_MARGIN) * (self.cursor.current - 1), 
            textHeight/3)
    
        love.graphics.setFont(fonts.smaller)
        love.graphics.setColor(1, 1, 1, 0.5)
        textWidth = fonts.smaller:getWidth(self.text)
        love.graphics.print(
            self.text, 
            self.windowWidth/2 - textWidth/2, 
            self.windowHeight - self.windowHeight/6)
    end,

    setActive = function(self, active)
        self.active = active
    end,

    handleCursor = function(self, key)
        alreadyHandled = false;

        if not self.active or alreadyHandled then return end;
        
        if key == "e" or key == "E" then
            if self.cursor.current == 1 then -- Settings
                print("settings active", self.settingsOverlay.active)
                self.active = false;
                self.settingsOverlay.active = true;
            elseif self.cursor.current == 2 then -- Main menu
                local menu = require("src.states.menu")
                Gamestate.switch(menu)
            end
        end
        if key == "down" and not self.settingsOverlay.active then
            if self.cursor.current >= #self.options then return end;
            self.cursor.current = self.cursor.current + 1
            sounds.select:play()
        end
        if key == "up" and not self.settingsOverlay.active then
            if self.cursor.current <= 1 then return end;
            self.cursor.current = self.cursor.current - 1
            sounds.select:play()
        end
    end
}

return PauseOverlay
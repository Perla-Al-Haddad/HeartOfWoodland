local Class = require("lib.hump.class")
local Gamestate = require("lib.hump.gamestate")

local MenuState = require("src.states.menuStates.MenuState")
local Level = require("src.states.Level")

local conf = require("src.utils.conf")
local fonts = require("src.utils.fonts")


local MainMenu = Class {
    __includes = { MenuState },

    init = function(self)
        MenuState.init(self, "HEART\nOF\nWOODLAND")
        
        self.options = {
            {
                text = "PLAY",
                state = Level():initExternal("forestRuins", "menu"),
                method = Gamestate.switch
            },
            {
                text = "SETTINGS",
                state = require("src.states.menuStates.Settings")(),
                method = Gamestate.switch
            },
            {
                text = "CREDITS",
                state = require("src.states.menuStates.Credits")(),
                method = Gamestate.switch
            },
            {
                text = "EXIT",
                state = false,
                method = love.event.quit
            }
        }
        self.hintText = "PRESS [E] TO SELECT"

        self.optionHeight = fonts.small:getHeight(self.options[1].text)
        self.hintTextWidth = fonts.smaller:getWidth(self.hintText)
    end,

    _drawAbs = function(self)
        love.graphics.setFont(fonts.smaller)
        love.graphics.setColor(1, 1, 1, 0.7)

        love.graphics.print(
            self.hintText,
            conf.gameWidth / 2 - self.hintTextWidth / 2,
            conf.gameHeight - conf.gameHeight / 8)
    end
}

return MainMenu

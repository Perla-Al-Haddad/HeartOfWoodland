local Class = require("lib.hump.class")
local Gamestate = require("lib.hump.gamestate")

local MenuState = require("src.states.menuStates.MenuState")

local fonts = require("src.utils.fonts")


local Controls = Class {
    __includes = {MenuState},

    init = function (self)
        MenuState.init(self, "CONTROLS")
    end,

    enter = function (self)
        self.options = {
            {
                text = "BACK",
                state = self.prevState or require("src.states.menuStates.Settings")(),
                method = Gamestate.switch
            },
            {
                text = "KEYBOARD",
            }
        }

        self.optionHeight = fonts.small:getHeight(self.options[1].text)
    end
}

return Controls
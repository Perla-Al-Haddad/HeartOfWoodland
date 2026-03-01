local Class = require("lib.hump.class")
local Gamestate = require("lib.hump.gamestate")

local MenuState = require("src.states.menuStates.MenuState")

local fonts = require("src.utils.fonts")


local Credits = Class {
    __includes = { MenuState },

    init = function(self)
        MenuState.init(self, "CREDITS")
    end,

    enter = function(self, prevState)
        self.options = {
            {
                text = "BACK",
                state = prevState,
                method = Gamestate.switch
            }
        }
        self.optionHeight = fonts.small:getHeight(self.options[1].text)
    end
}

return Credits

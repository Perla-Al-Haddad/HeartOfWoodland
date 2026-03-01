local Class = require("lib.hump.class")
local Gamestate = require("lib.hump.gamestate")

local MenuState = require("src.states.menuStates.MenuState")

local fonts = require("src.utils.fonts")


local Audio = Class {
    __includes = { MenuState },

    init = function(self)
        MenuState.init(self, "AUDIO")
    end,

    enter = function(self)
        self.options = {
            {
                text = "BACK",
                state = self.prevState or require("src.states.menuStates.Settings")(),
                method = Gamestate.switch
            },
            {
                text = "GENERAL",
            },
            {
                text = "MUSIC",
            },
            {
                text = "EFFECTS",
            }
        }

        self.optionHeight = fonts.small:getHeight(self.options[1].text)
    end,
}

return Audio

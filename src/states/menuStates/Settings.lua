local Class = require("lib.hump.class")
local Gamestate = require("lib.hump.gamestate")

local MenuState = require("src.states.menuStates.MenuState")

local fonts = require("src.utils.fonts")


local Settings = Class {
    __includes = { MenuState },

    init = function (self)
        MenuState.init(self, "SETTINGS")
    end,

    initExternal = function(self, prevState, hasQuit)
        self.prevState = prevState
        self.hasQuit = hasQuit or false
        return self
    end,

    enter = function(self)
        self.options = {
            {
                text = "BACK",
                state = self.prevState or require("src.states.menuStates.MainMenu"),
                method = Gamestate.switch
            },
            {
                text = "AUDIO",
                state = require("src.states.menuStates.Audio")():initExternal(self),
                method = Gamestate.switch
            },
            {
                text = "CONTROLS",
                state = require("src.states.menuStates.Controls")():initExternal(self),
                method = Gamestate.switch
            },
            {
                text = "DISPLAY",
                state = require("src.states.menuStates.Display")():initExternal(self),
                method = Gamestate.switch
            }
        }

        if self.hasQuit then
            table.insert(self.options, {
                text = "BACK TO MAIN MENU",
                state = require("src.states.menuStates.MainMenu"),
                method = Gamestate.switch
            })
            table.insert(self.options, {
                text = "EXIT TO DESKTOP",
                state = false,
                method = love.event.quit
            })
        end

        self.optionHeight = fonts.small:getHeight(self.options[1].text)
    end,
}

return Settings

local push = require("lib.push")
local Class = require("lib.hump.class")

local conf = require("src.utils.conf")
local fonts = require("src.utils.fonts")


local MenuState = Class {
    init = function(self, title)
        self.cursor = { x = 0, y = 0, current = 1 }
        self.options = {}
        self.title = title

        self.titleWidth = fonts.title:getWidth(self.title)
    end,

    initExternal = function(self, prevState)
        self.prevState = prevState

        return self
    end,

    keypressed = function(self, key)
        if string.lower(key) == "e" then
            local cursorIndex = self.cursor.current
            if not cursorIndex then return end

            local option = self.options[cursorIndex]
            option.method(option.state)
        elseif key == "down" then
            if self.cursor.current >= #self.options then
                self.cursor.current = 1
                return
            end
            self.cursor.current = self.cursor.current + 1
        elseif key == "up" then
            if self.cursor.current <= 1 then
                self.cursor.current = #self.options
                return
            end
            self.cursor.current = self.cursor.current - 1
        end
    end,

    draw = function(self)
        push:start()

        self:_drawBackground()

        self:__drawTitle()
        self:__drawOptions()
        self:__drawCursor()

        self:_drawAbs()

        push:finish()
    end,

    _drawBackground = function(self)
        if self.prevState and self.prevState.prevState then
            self.prevState.prevState:drawInternal()
        elseif self.prevState and self.prevState.drawInternal then
            self.prevState:drawInternal()
        end
        self:__drawOverlay()
    end,

    _drawAbs = function(_) end,

    __drawOverlay = function(_)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
    end,

    __drawTitle = function(self)
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(91 / 255, 169 / 255, 121 / 255)
        love.graphics.printf(self.title, conf.gameWidth / 2 - self.titleWidth / 2, conf.gameHeight / 12, self.titleWidth,
            "center")
    end,

    __drawCursor = function(self)
        love.graphics.circle(
            "fill",
            conf.gameWidth / 2 - self.titleWidth / 2 - 20,
            conf.gameHeight / 2 + 20 + (self.optionHeight + fonts.OPTIONS_MARGIN) * (self.cursor.current - 1),
            self.optionHeight / 4
        )
    end,

    __drawOptions = function(self)
        love.graphics.setFont(fonts.small)
        love.graphics.setColor(1, 1, 1)

        for i, option in ipairs(self.options) do
            love.graphics.print(
                option.text,
                conf.gameWidth / 2 - self.titleWidth / 2,
                conf.gameHeight / 2 + 12 + (self.optionHeight + fonts.OPTIONS_MARGIN) * (i - 1)
            )
        end
    end
}

return MenuState

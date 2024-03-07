local push = require("lib.push")
local Gamestate = require("lib.hump.gamestate")

local ForestGenerator = require("src.states.ForestGenerator")

local conf = require("src.utils.conf")
local fonts = require("src.utils.fonts")


local loading = {
    level = nil,
    levelCoRoutine = nil,
    step = "",
    timer = 0
}

function loading:enter()
    self.timer = 0

    self.level = ForestGenerator()
    self.levelCoRoutine = self.level:initCoRoutine()
end

function loading:update(dt)
    local status, value = coroutine.resume(self.levelCoRoutine)
    self.step = value
    self.timer = self.timer + dt
    if not status then
        Gamestate.switch(self.level)
    end
end

function loading:draw()
    push:start()

    love.graphics.print(self.timer, 0, 0)

    local title = "LOADING..."
    local titleWidth = fonts.title:getWidth(title)
    love.graphics.setFont(fonts.title)
    love.graphics.printf(title, conf.gameWidth / 2 - titleWidth / 2, conf.gameHeight / 2, titleWidth, "center")

    if self.step then
        local stepWidth = fonts.title:getWidth(self.step)
        love.graphics.setFont(fonts.small)
        love.graphics.printf(self.step, conf.gameWidth / 2 - stepWidth / 2, conf.gameHeight / 3, stepWidth, "center")
    end

    push:finish()
end

return loading

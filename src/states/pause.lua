local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local playerStateHandler = require("src.playerStateHandler")

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");

local settings = {
    options,
    cursor,
    sounds,
    prevState,
    gameMap,
    player,
    camera,
    levelState
}


function settings:enter(prevState, camera, gameMap, player, levelState)
    self.levelState = levelState
    self.prevState = prevState
    self.camera = camera
    self.gameMap = gameMap
    self.player = player
    self.handlers = self.player._handlers

    self.options = { "BACK", "QUIT TO DESKTOP", "MAIN MENU", "SETTINGS" }

    self.cursor = {
        x = 0,
        y = 0,
        current = 1
    }

    self.sounds = {}
    self.sounds.select = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/click.wav"), "static")
end

function settings:draw()
    push:start()

    self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

    if self.gameMap then
        self.levelState:_drawGameMap()
    end

    self.camera.camera:detach();

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
    love.graphics.setColor(1, 1, 1, 1)

    local title = "PAUSE"
    local titleWidth = fonts.title:getWidth(title)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(91 / 255, 169 / 255, 121 / 255)
    love.graphics.printf(title, conf.gameWidth / 2 - titleWidth / 2, conf.gameHeight / 6, titleWidth, "center")

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1)
    local textHeight;
    for i, option in ipairs(self.options) do
        textHeight = fonts.small:getHeight(option)
        love.graphics.print(
            option,
            conf.gameWidth / 2 - titleWidth / 2,
            conf.gameHeight - conf.gameHeight / 3 - (textHeight + fonts.OPTIONS_MARGIN) * (i - 1))
    end

    love.graphics.circle(
        "fill",
        conf.gameWidth / 2 - titleWidth / 2 - 20,
        conf.gameHeight - conf.gameHeight / 3 + textHeight / 2 -
        (textHeight + fonts.OPTIONS_MARGIN) * (self.cursor.current - 1),
        textHeight / 3)

    push:finish()
end

function settings:keypressed(key)
    if key == "q" or key == "Q" then
        local state;
        if self.levelState ~= nil then
            state = self.levelState
        else
            state = self.prevState
        end
        Gamestate.switch(state)
    end;
    if key == "e" or key == "E" then
        local state;
        if self.levelState ~= nil then
            state = self.levelState
        else
            state = self.prevState
        end
        if self.cursor.current == 1 then
            Gamestate.switch(state)
        elseif self.cursor.current == 2 then
            love.event.quit()
        elseif self.cursor.current == 3 then
            self.player:destroySelf()
            local menu = require("src.states.menu")
            Gamestate.switch(menu)
            playerStateHandler.health = conf.PLAYER.DEFAULT_HEALTH
        elseif self.cursor.current == 4 then
            local settings = require("src.states.settings")
            Gamestate.switch(settings, self.camera, self.gameMap, self.player, self.prevState)
        end
    end
    if key == "down" then
        if self.cursor.current <= 1 then return end;
        self.cursor.current = self.cursor.current - 1
        self.sounds.select:play()
    end
    if key == "up" then
        if self.cursor.current >= #self.options then return end;
        self.cursor.current = self.cursor.current + 1
        self.sounds.select:play()
    end
end

return settings

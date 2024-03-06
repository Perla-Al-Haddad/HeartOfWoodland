local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");

local settings = {
    options = { "BACK", "AUDIO", "DISPLAY", "CONTROLS" },
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

    if self.camera ~= nil then
        self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

        if self.gameMap then
            self.levelState:_drawGameMap()
        end

        self.camera.camera:detach();

        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
        love.graphics.setColor(1, 1, 1, 1)
    end

    local title = "SETTINGS"
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
        Gamestate.switch(self.prevState, self.camera, self.gameMap, self.player, self.levelState)
    end;
    if key == "e" or key == "E" then
        if self.cursor.current == 1 then
            Gamestate.switch(self.prevState, self.camera, self.gameMap, self.player, self.levelState)
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

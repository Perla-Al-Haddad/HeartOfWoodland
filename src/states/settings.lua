local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");

local settings = {
    options = { "BACK", "AUDIO", "DISPLAY", "CONTROLS" }
}
local _prevState = nil;

local cursor, sounds, _gameMap, _player, _camera, _levelState;


function settings:enter(prevState, camera, gameMap, player, levelState)
    _levelState = levelState
    _prevState = prevState
    _camera = camera
    _gameMap = gameMap
    _player = player



    cursor = {
        x = 0,
        y = 0,
        current = 1
    }

    sounds = {}
    sounds.select = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/click.wav"), "static")
end

function settings:draw()
    push:start()

    if _camera ~= nil then
        _camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

        if gameMap then
            for _, layer in ipairs(_gameMap.layers) do
                if layer.visible and layer.opacity > 0 then
                    if layer.name == "Player" then
                        _player._handlers.enemies:drawEnemies();
                        _player._handlers.effects:drawEffects(-1);
                        _player._handlers.objects:drawObjects();
                        _player._handlers.drops:drawDrops();
                        _player:drawAbs();
                        _player._handlers.effects:drawEffects(0);
                    else
                        if layer.type == "tilelayer" then
                            _gameMap:drawLayer(layer)
                        end
                    end
                end
            end
        end

        _camera.camera:detach();

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
        (textHeight + fonts.OPTIONS_MARGIN) * (cursor.current - 1),
        textHeight / 3)

    push:finish()
end

function settings:keypressed(key)
    if key == "q" or key == "Q" then
        Gamestate.switch(_prevState, _camera, _gameMap, _player, _levelState)
    end;
    if key == "e" or key == "E" then
        if cursor.current == 1 then
            Gamestate.switch(_prevState, _camera, _gameMap, _player, _levelState)
        end
    end
    if key == "down" then
        if cursor.current <= 1 then return end;
        cursor.current = cursor.current - 1
        sounds.select:play()
    end
    if key == "up" then
        if cursor.current >= #self.options then return end;
        cursor.current = cursor.current + 1
        sounds.select:play()
    end
end

return settings

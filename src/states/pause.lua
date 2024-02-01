local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");

local settings = {}

local options, cursor, sounds, _gameState, _gameMap, _player, _camera;


function settings:enter(gameState, camera, gameMap, player)
    _gameState = gameState
    _camera = camera
    _gameMap = gameMap
    _player = player

    options = {"BACK", "QUIT TO DESKTOP", "MAIN MENU", "SETTINGS"}

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

    _camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

    _gameMap:drawLayer(_gameMap.layers["ground"]);
    _gameMap:drawLayer(_gameMap.layers["mountains"]);
    _gameMap:drawLayer(_gameMap.layers["walls"]);
    _gameMap:drawLayer(_gameMap.layers["decor"]);

    _player._handlers.enemies:drawEnemies();
    _player._handlers.effects:drawEffects(-1);
    _player._handlers.objects:drawObjects();
    _player._handlers.drops:drawDrops();
    _player:drawAbs();
    _player._handlers.effects:drawEffects(0);

    _gameMap:drawLayer(_gameMap.layers["upperWalls"]);

    _camera.camera:detach();

    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill", 0,0,conf.gameWidth, conf.gameHeight)
    love.graphics.setColor(1,1,1,1)

    local title = "PAUSE"
    local titleWidth = fonts.title:getWidth(title)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(91/255, 169/255, 121/255)
    love.graphics.printf(title, conf.gameWidth/2 - titleWidth/2, conf.gameHeight/6, titleWidth, "center")

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1)
    local textHeight;
    for i, option in ipairs(options) do
        textHeight = fonts.small:getHeight(option)
        love.graphics.print(
            option, 
            conf.gameWidth/2 - titleWidth/2, 
            conf.gameHeight - conf.gameHeight/3 - (textHeight + fonts.OPTIONS_MARGIN) * (i - 1))
    end

    love.graphics.circle(
        "fill",
        conf.gameWidth/2 - titleWidth/2 - 20, 
        conf.gameHeight - conf.gameHeight/3 + textHeight/2 - (textHeight + fonts.OPTIONS_MARGIN) * (cursor.current - 1), 
        textHeight/3)

    push:finish()
end

function settings:keypressed(key)
    if key == "q" or key == "Q" then 
        local game = require("src.states.game")
        Gamestate.switch(game)
    end;
    if key == "e" or key == "E" then
        if cursor.current == 1 then 
            local game = require("src.states.game")
            Gamestate.switch(game)
        elseif cursor.current == 2 then
            love.event.quit()
        elseif cursor.current == 3 then
            local menu = require("src.states.menu")
            local game = require("src.states.game")
            game:initEntities()
            Gamestate.switch(menu)
        elseif cursor.current == 4 then
            local settings = require("src.states.settings")
            Gamestate.switch(settings, _camera, _gameMap, _player)
        end
    end
    if key == "down" then
        if cursor.current <= 1 then return end;
        cursor.current = cursor.current - 1
        sounds.select:play()
    end
    if key == "up" then
        if cursor.current >= #options then return end;
        cursor.current = cursor.current + 1
        sounds.select:play()
    end
end

return settings

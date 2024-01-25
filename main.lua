local Gamestate = require("lib.hump.gamestate");

local game = require("src.states.game")

function love.load()
    love.graphics.setBackgroundColor(26 / 255, 26 / 255, 26 / 255);
    love.window.setMode(0, 0, {fullscreen = true});
    love.graphics.setDefaultFilter("nearest", "nearest");

    Gamestate.registerEvents()
    Gamestate.switch(game)
end

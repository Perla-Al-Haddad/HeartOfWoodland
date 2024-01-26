local Gamestate = require("lib.hump.gamestate");

local game = require("src.states.game")
local menu = require("src.states.menu")

function love.load()
    love.graphics.setBackgroundColor(26 / 255, 26 / 255, 26 / 255);
    love.window.setMode(0, 0, {fullscreen = true});
    love.graphics.setDefaultFilter("nearest", "nearest");

    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.keypressed(key) 
    if key == "escape" then love.event.quit(); end 
end

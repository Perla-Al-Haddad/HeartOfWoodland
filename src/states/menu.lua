local Gamestate = require("lib.hump.gamestate");

local audio = require("src.utils.audio");

local menu = {}


function menu:enter()
    audio.menuMusic:play()
end


function menu:draw() 
    love.graphics.print("Heart of woodland", 500, 350, 0, 5, 5)
    love.graphics.print("Press space to play", 500, 450, 0, 3, 3)
end


function menu:keypressed(key)
    local game = require("src.states.game")
    if key == "space" then
        Gamestate.switch(game)
        audio.menuMusic:stop()
    end
end


return menu;
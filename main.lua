local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local menu = require("src.states.menu");
local conf = require("src.utils.conf");


function love.load()
    math.randomseed(os.time())

    local windowWidth, windowHeight = love.window.getDesktopDimensions();
    push:setupScreen(conf.gameWidth, conf.gameHeight, windowWidth, windowHeight, {
        fullscreen = true,
      })

    love.graphics.setDefaultFilter("nearest", "nearest");

    Gamestate.registerEvents()
    Gamestate.switch(menu)
end


local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local menu = require("src.states.menu");

local conf = require("src.utils.conf");

function love.load()
    if arg[2] == "debug" then require("lldebugger").start() end
    math.randomseed(os.time())

    love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest", "nearest") -- disable blurry scaling

    -- push:setupScreen(conf.gameWidth, conf.gameHeight, conf.windowWidth, conf.windowHeight, {
    --     fullscreen = false,
    --     resizable = true,
    --     pixelperfect = true
    -- })

    if conf.FULLSCREEN then
        love.window.setMode(0, 0, {fullscreen = true});
    end

    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.keypressed(key)
    if (key) == "back" then
        conf.FULLSCREEN = not conf.FULLSCREEN
    end
end

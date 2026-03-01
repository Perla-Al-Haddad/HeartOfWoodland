local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local MainMenu = require("src.states.menuStates.MainMenu");

local conf = require("src.utils.conf");


function love.load()
    if arg[2] == "debug" then require("lldebugger").start() end
    math.randomseed(os.time())
    -- math.randomseed(2)

    love.mouse.setVisible(false)
    love.graphics.setDefaultFilter("nearest", "nearest") -- disable blurry scaling

    if conf.FULLSCREEN then
        love.window.setMode(0, 0, {fullscreentype  = "exclusive"});
    end

    push:setupScreen(conf.gameWidth, conf.gameHeight, conf.windowWidth, conf.windowHeight, {
        pixelperfect = true,
        fullscreen = conf.FULLSCREEN
    })

    Gamestate.registerEvents()
    Gamestate.switch(MainMenu())
end

function love.keypressed(key)
end

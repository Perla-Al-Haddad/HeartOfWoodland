local globalFuncs = {}

local dialogueHandler = require("src.dialogueHandler")

local conf = require("src.utils.conf")

function globalFuncs.keypressed(key)
    if key == "backspace" then
        conf.FULLSCREEN = not conf.FULLSCREEN
        love.window.setFullscreen(conf.FULLSCREEN)
    elseif key == "e" and #dialogueHandler.lines > 0 then
        dialogueHandler:popLine()
    elseif key == "f5" then
        conf.DEBUG.DRAW_WORLD = not conf.DEBUG.DRAW_WORLD
        conf.DEBUG.ENEMY_RADIUS = not conf.DEBUG.ENEMY_RADIUS
        conf.DEBUG.HIT_BOXES = not conf.DEBUG.HIT_BOXES
        conf.DEBUG.HURT_BOXES = not conf.DEBUG.HURT_BOXES
    end
end

return globalFuncs;
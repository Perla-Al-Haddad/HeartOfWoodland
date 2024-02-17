local globalFuncs = {}

local dialogueHandler = require("src.dialogueHandler")

local conf = require("src.utils.conf")

function globalFuncs.keypressed(key)
    if key == "backspace" then
        conf.FULLSCREEN = not conf.FULLSCREEN
        love.window.setFullscreen(conf.FULLSCREEN)
    elseif key == "e" and #dialogueHandler.lines > 0 then
        dialogueHandler:popLine()
    end
end

return globalFuncs;
local globalFuncs = {}

local conf = require("src.utils.conf")

function globalFuncs.keypressed(key)
    if key == "backspace" then
        conf.FULLSCREEN = not conf.FULLSCREEN
        love.window.setFullscreen(conf.FULLSCREEN)
    end
end

return globalFuncs;
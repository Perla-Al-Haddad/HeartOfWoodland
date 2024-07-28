local I_PIXEL_U_PATH = "assets/fonts/I-pixel-u.ttf";


local conf = require("src.utils.conf")

local fonts = {}


local createFont = function(fontSize, filterType, lineHeight)
    local font = love.graphics.newFont(I_PIXEL_U_PATH, fontSize)
    font:setFilter(filterType, filterType)
    font:setLineHeight(lineHeight)
    return font
end


fonts.title = createFont(36 * conf.CAMERA.SCALE, "nearest", 0.7)
fonts.small = createFont(12 * conf.CAMERA.SCALE, "nearest", 0.3)
fonts.smaller = createFont(8 * conf.CAMERA.SCALE, "nearest", 0.7)
fonts.dialogue = createFont(8 * conf.CAMERA.SCALE, "nearest", 0.7)

fonts.OPTIONS_MARGIN = 1;

return fonts

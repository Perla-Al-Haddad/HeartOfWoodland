local GEORGIA_PATH = "assets/fonts/Pixel Georgia.ttf";
local GEORGIA_PATH_BOLD_PATH = "assets/fonts/Pixel Georgia Bold.ttf";
local I_PIXEL_U_PATH = "assets/fonts/I-pixel-u.ttf";

local fonts = {}

fonts.title = love.graphics.newFont(I_PIXEL_U_PATH, 32)
fonts.title:setFilter("nearest", "nearest")
fonts.title:setLineHeight(0.7)

fonts.small = love.graphics.newFont(I_PIXEL_U_PATH, 12)
fonts.small:setFilter("nearest", "nearest")

fonts.smaller = love.graphics.newFont(I_PIXEL_U_PATH, 8)
fonts.smaller:setFilter("nearest", "nearest")

fonts.OPTIONS_MARGIN = 2;

return fonts;

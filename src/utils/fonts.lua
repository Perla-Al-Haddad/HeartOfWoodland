local GEORGIA_PATH = "assets/fonts/Pixel Georgia.ttf";
local GEORGIA_PATH_BOLD_PATH = "assets/fonts/Pixel Georgia Bold.ttf";
local DOGICA_PIXEL_PATH = "assets/fonts/dogicapixel.ttf";
local DOGICA_BOLD_PATH = "assets/fonts/dogicabold.ttf";
local RETRO_GAMING_PATH = "assets/fonts/Retro Gaming.ttf";
local I_PIXEL_U_PATH = "assets/fonts/I-pixel-u.ttf";

local fonts = {}

fonts.title = love.graphics.newFont(I_PIXEL_U_PATH, 36)
fonts.title:setFilter("nearest", "nearest")
fonts.title:setLineHeight(0.7)

fonts.small = love.graphics.newFont(I_PIXEL_U_PATH, 12)
fonts.small:setFilter("nearest", "nearest")
fonts.small:setLineHeight(0.3)

fonts.smaller = love.graphics.newFont(I_PIXEL_U_PATH, 8)
fonts.smaller:setFilter("nearest", "nearest")
fonts.smaller:setLineHeight(0.7)

fonts.dialogue = love.graphics.newFont(I_PIXEL_U_PATH, 8)
fonts.dialogue:setFilter("nearest", "nearest")
fonts.dialogue:setLineHeight(0.7)

fonts.OPTIONS_MARGIN = 1;

return fonts;

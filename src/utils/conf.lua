local conf = {}

conf.DEBUG = {}
conf.DEBUG.HURT_BOXES = false
conf.DEBUG.HIT_BOXES = false
conf.DEBUG.DRAW_WORLD = false

conf.MUSIC = false
conf.FULLSCREEN = true

local dpi_scale = love.window.getDPIScale()
local windowWidth, windowHeight = love.window.getDesktopDimensions();
conf.windowWidth = windowWidth/dpi_scale
conf.windowHeight = windowHeight/dpi_scale

local ratio = conf.windowWidth / conf.windowHeight

conf.gameWidth, conf.gameHeight = math.floor(288 * (tonumber(tostring(ratio):match("%d*%.?%d."))-0.1)), 288 --fixed game resolution

return conf
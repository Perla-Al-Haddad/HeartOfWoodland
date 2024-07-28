local conf = {}

conf.DEBUG = {}
conf.DEBUG.SHOW_FPS = true

conf.FULLSCREEN = false

local windowWidth, windowHeight = love.window.getDesktopDimensions()

conf.OBJECTS = {}
conf.OBJECTS.COLLISION_CLASS = "Objects"

conf.CAMERA = {}
conf.CAMERA.SCALE = 4

conf.windowWidth = windowWidth
conf.windowHeight = windowHeight

if (conf.windowWidth == 1366 and conf.windowHeight == 768) then
    conf.CAMERA.SCALE = 3
    conf.gameWidth, conf.gameHeight = 444 * conf.CAMERA.SCALE, 256 * conf.CAMERA.SCALE
elseif (conf.windowWidth == 1536 and conf.windowHeight == 864) then
    conf.CAMERA.SCALE = 3
    conf.gameWidth, conf.gameHeight = 444 * conf.CAMERA.SCALE, (256 + 16 * 2) * conf.CAMERA.SCALE
else
    conf.gameWidth, conf.gameHeight = (444) * conf.CAMERA.SCALE, (256 + 14) * conf.CAMERA.SCALE
end


return conf

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

conf.TILE_SIZE = 16

conf.PLAYER = {}
conf.PLAYER.STATES = {
    DEFAULT = "default",
    SWING = "swing",
    SWINGING = "swinging",
    SLASH = "slash",
    SLASHING = "slashing"
}
conf.PLAYER.ORIENTATION = {
    HORIZONTAL = "horizontal",
    VERTICAL = "vertical"
}
conf.PLAYER.ITEMS = {
    HOE = "hoe",
    BROKEN_SWORD = "broken sword",
    BOW = "bow"
}
conf.PLAYER.ITEM_MAX = 3
conf.PLAYER.SLASH_ANIMATION_TIMER = 0.4
conf.PLAYER.HOE_SWING_ANIMATION_TIMER = 0.6
conf.PLAYER.HOE_SWING_HIT_DELAY = 0.2

return conf

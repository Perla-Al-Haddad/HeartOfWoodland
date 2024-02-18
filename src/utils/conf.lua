local conf = {}

conf.DEBUG = {}
conf.DEBUG.HURT_BOXES = false
conf.DEBUG.HIT_BOXES = false
conf.DEBUG.ENEMY_RADIUS = flase
conf.DEBUG.DRAW_WORLD = false

conf.MUSIC = false
conf.FULLSCREEN = false

conf.PLAYER = {}
conf.PLAYER.TILE_SIZE = 32
conf.PLAYER.SPEED = 140
conf.PLAYER.SPRITE_SHEET_PATH = "/assets/sprites/characters/player.png"
conf.PLAYER.HURT_BOX_WIDTH = 12
conf.PLAYER.HURT_BOX_HEIGHT = 12
conf.PLAYER.HEIGHT_OFFSET = 10
conf.PLAYER.COLLISION_CLASS = "Player"
conf.PLAYER.KNOCKBACK_STRENGTH = 120
conf.PLAYER.KNOCKBACK_TIMER = 0.075
conf.PLAYER.STUN_TIMER = 0.075
conf.PLAYER.INVINCIBILITY_FLICKER_SPEED = 5.5
conf.PLAYER.INVINCIBILITY_LENGTH = 2
conf.PLAYER.DEFAULT_HEALTH = 3

conf.OBJECTS = {}
conf.OBJECTS.COLLISION_CLASS = "Objects"

conf.DIALOGUE = {}
conf.DIALOGUE.FLICKER_SPEED = 0.5

conf.CAMERA = {}
conf.CAMERA.SCALE = 1

local dpi_scale = love.window.getDPIScale()
local windowWidth, windowHeight = love.window.getDesktopDimensions()

conf.windowWidth = windowWidth / dpi_scale
conf.windowHeight = windowHeight / dpi_scale

if conf.windowHeight == 1366 and conf.windowHeight == 768 then
    conf.gameWidth, conf.gameHeight = 444, 256
else
    conf.gameWidth, conf.gameHeight = 444, 256 + 14
end

return conf

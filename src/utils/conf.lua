local conf = {}

conf.DEBUG = {}
conf.DEBUG.HURT_BOXES = false
conf.DEBUG.HIT_BOXES = false
conf.DEBUG.DRAW_WORLD = false

conf.MUSIC = true
conf.FULLSCREEN = true

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

conf.CAMERA = {}
conf.CAMERA.SCALE = 1

local dpi_scale = love.window.getDPIScale()
local windowWidth, windowHeight = 1366, 768;

conf.windowWidth = windowWidth / dpi_scale
conf.windowHeight = windowHeight / dpi_scale

conf.gameWidth, conf.gameHeight = 444, 256

return conf

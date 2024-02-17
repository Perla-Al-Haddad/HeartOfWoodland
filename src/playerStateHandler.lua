local conf = require("src.utils.conf")

local playerStateHandler = {}

playerStateHandler.health = conf.PLAYER.DEFAULT_HEALTH

return playerStateHandler
local GameSettings = {
    TILE_SIZE = 32,

    PLAYER_SPEED = 20000,
    INITIAL_PLAYER_DIR = "right"
}

function GameSettings:getWhiteColor(opactiy)
    return 244 / 255, 244 / 255, 244 / 255, opactiy
end
function GameSettings:getBlueColor(opactiy)
    return 65 / 255, 166 / 255, 246 / 255, opactiy
end
function GameSettings:getDarkColor(opactiy)
    return 26 / 255, 28 / 255, 44 / 255, opactiy
end
function GameSettings:getGreenColor(opactiy)
    return 56 / 255, 183 / 255, 100 / 255, opactiy
end
function GameSettings:getPinkColor(opactiy)
    return 204 / 255, 90 / 255, 204 / 255, opactiy
end

return GameSettings

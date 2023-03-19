local GameSettings = {
    TILE_SIZE = 16,
    
    PLAYER_SPEED = 150,
    INITIAL_PLAYER_DIR = "right",

}

function GameSettings:getWhiteColor()
    return 244/255, 244/255, 244/255
end
function GameSettings:getBlueColor(opactiy)
    return 65/255, 166/255, 246/255, opactiy
end
function GameSettings:getDarkColor()
    return 26/255, 28/255, 44/255
end
function GameSettings:getGreenColor()
    return 56/255, 183/255, 100/255
end

return GameSettings
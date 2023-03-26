local Camera = require('lib.hump.camera')

local GameSettings = require("src.gameSettings")
local window = require("src.window")

local GameCamera = {camera = nil, scale = 1}

function GameCamera:load(player)
    GameCamera.camera = Camera(player.collider:getX(), player.collider:getY(),
                               GameCamera.scale)
    GameCamera.smoother = Camera.smooth.damped(8)
end

function GameCamera:update(dt, player, level)

    local camX = player.collider:getX();
    local camY = player.collider:getY();

    -- -- This section prevents the camera from viewing outside the background
    -- -- First, get width/height of the game window, divided by the game scale
    -- local windowWidth = love.graphics.getWidth()
    -- local windowHeigth = love.graphics.getHeight()
    -- local w = windowWidth / GameCamera.scale
    -- local h = windowHeigth / GameCamera.scale

    -- -- Get width/height of background
    -- local mapW = level.levelW * GameSettings.TILE_SIZE
    -- local mapH = level.levelH * GameSettings.TILE_SIZE

    -- -- Left border
    -- if camX < w / 2 - windowWidth * window.WINDOW_LIMITS_WIDTH_RATIO then
    --     camX = w / 2 - windowWidth * window.WINDOW_LIMITS_WIDTH_RATIO
    -- end

    -- -- Top border
    -- if camY < h / 2 then camY = h / 2 end

    -- -- Right border
    -- if camX > (mapW - (w) / 2 + windowWidth * window.WINDOW_LIMITS_WIDTH_RATIO +
    --     GameSettings.TILE_SIZE * 2) then
    --     camX =
    --         (mapW - (w) / 2 + windowWidth * window.WINDOW_LIMITS_WIDTH_RATIO +
    --             GameSettings.TILE_SIZE * 2)
    -- end
    -- -- Bottom border
    -- if camY > (mapH - (h) / 2 + GameSettings.TILE_SIZE * 2) then
    --     camY = (mapH - (h) / 2 + GameSettings.TILE_SIZE * 2)
    -- end

    GameCamera.camera:lockPosition(camX, camY)

    -- cam.x and cam.y keep track of where the camera is located
    -- the lookAt value may be moved if a screenshake is happening, so these
    -- values know where the camera should be, regardless of lookAt
    GameCamera.camera.x, GameCamera.camera.y = GameCamera.camera:position()

end

return GameCamera

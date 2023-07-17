local HumpCamera = require("lib/hump/camera")
local Class = require("lib.hump.class")

Camera = Class {
    init = function(self, scale, originX, originY)
        self.scale = scale
        self.camera = HumpCamera(originX, originY, self.scale)
        -- self.camera.smoother = HumpCamera.smooth.damped(10)
    end,

    update = function(self, dt, player, gameMap)

        local camX, camY = player.collider:getPosition()

        -- This section prevents the camera from viewing outside the background
        -- First, get width/height of the game window, divided by the game scale
        local w = love.graphics.getWidth() / self.scale
        local h = love.graphics.getHeight() / self.scale

        -- Get width/height of background
        local mapW = gameMap.width * gameMap.tilewidth
        local mapH = gameMap.height * gameMap.tileheight

        -- Left border
        if camX < w / 2 then camX = w / 2 end

        -- Right border
        if camY < h / 2 then camY = h / 2 end

        -- Right border
        if camX > (mapW - w / 2) then camX = (mapW - w / 2) end
        -- Bottom border
        if camY > (mapH - h / 2) then camY = (mapH - h / 2) end

        self.camera:lockPosition(camX, camY)

        -- cam.x and cam.y keep track of where the camera is located
        -- the lookAt value may be moved if a screenshake is happening, so these
        -- values know where the camera should be, regardless of lookAt
        self.x, self.y = self.camera:position()

    end
}

return Camera

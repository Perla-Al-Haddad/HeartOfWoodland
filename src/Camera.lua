local HumpCamera = require("lib/hump/camera")
local Class = require("lib.hump.class")

local conf = require("src.utils.conf")
local funcs = require("src.utils.funcs")


Camera = Class {
    init = function(self, scale, originX, originY, levelWidth, levelHeight, levelTileWidth, levelTileHeight)
        self.scale = scale
        self.camera = HumpCamera(originX, originY, self.scale)

        self.levelWidth = levelWidth
        self.levelHeight = levelHeight
        self.levelTileWidth = levelTileWidth
        self.levelTileHeight = levelTileHeight
        -- self.camera.smoother = HumpCamera.smooth.damped(15)
    end,

    update = function(self, player)
        if player.hurtCollider == nil then
            return
        end
        local camX, camY = player.hurtCollider:getPosition()

        -- This section prevents the camera from viewing outside the background
        -- First, get width/height of the game window, divided by the game scale
        local w = conf.gameWidth / self.scale
        local h = conf.gameHeight / self.scale

        -- Get width/height of background
        local mapW = self.levelWidth * self.levelTileWidth
        local mapH = self.levelHeight * self.levelTileHeight

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
    end,

    isOnScreen = function(self, px, py)
        return funcs.pointInRectangle(px, py,
            self.camera.x - conf.gameWidth / 2 - self.levelTileWidth * 2,
            self.camera.y - conf.gameHeight / 2 - self.levelTileHeight * 2,
            self.camera.x + conf.gameWidth / 2 + self.levelTileWidth * 2,
            self.camera.y + conf.gameHeight / 2 + self.levelTileHeight * 2)
    end
}

return Camera

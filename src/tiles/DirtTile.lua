love.graphics.setDefaultFilter("nearest", "nearest") -- disable blurry scaling

local SPRITES = {
    default = love.graphics.newImage("/assets/sprites/tilesets/base.png")
}

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local DirtTile = Class {
    init = function(self, positionX, positionY, world)
        self._world = world

        self.width = 16
        self.height = 16

        self.positionX = positionX
        self.positionY = positionY

        self.collider = self._world:newBSGRectangleCollider(positionX, positionY,
            self.width,
            self.height, 0,
            { collision_class = "Dirt" })
        self.collider:setType("static")

        self.sheet = SPRITES.default
        self.grid = anim8.newGrid(self.width, self.height,
            self.sheet:getWidth(),
            self.sheet:getHeight())

        self.neighbors = {
            { false, false, false },
            { false, nil,   false },
            { false, false, false },
        }

        self:setTileSprite("4-4", 12)
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)

        local px, py = self:_getCenterPosition()
        self.tile:draw(self.sheet, px, py, nil, self.collider.dirX, 1, 0, 0)
    end,

    setTileSprite = function(self)
        local spriteIndex, spriteRow = "4-4", 12

        if self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3] then
            spriteIndex = "2-2"
            spriteRow = 10
        elseif self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] then
            spriteIndex = "5-5"
            spriteRow = 9
        elseif self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[3][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] then
            spriteIndex = "5-5"
            spriteRow = 10
        elseif self.neighbors[1][3] and self.neighbors[1][2] and self.neighbors[3][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[1][1] and self.neighbors[3][2] then
            spriteIndex = "6-6"
            spriteRow = 9
        elseif self.neighbors[1][3] and self.neighbors[1][2] and self.neighbors[3][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] then
            spriteIndex = "6-6"
            spriteRow = 10
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "8-8"
            spriteRow = 9
        elseif (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "8-8"
            spriteRow = 10
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2]) then
            spriteIndex = "9-9"
            spriteRow = 11
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "10-10"
            spriteRow = 11
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2]) then
            spriteIndex = "9-9"
            spriteRow = 12
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "10-10"
            spriteRow = 12
        elseif (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "1-1"
            spriteRow = 13
        elseif (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2]) then
            spriteIndex = "2-2"
            spriteRow = 13
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "1-1"
            spriteRow = 14
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "2-2"
            spriteRow = 14
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[1][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2]) then
            spriteIndex = "3-3"
            spriteRow = 10
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[3][1] and self.neighbors[1][1])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[3][1])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][1])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "1-1"
            spriteRow = 10
        elseif (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][3] and self.neighbors[1][1])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][3])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][1])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "2-2"
            spriteRow = 9
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][3] and self.neighbors[3][1])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3]) then
            spriteIndex = "2-2"
            spriteRow = 11
        elseif (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[1][1] and self.neighbors[1][3])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[1][3])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[1][1])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2]) then
            spriteIndex = "5-5"
            spriteRow = 11
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3]) then
            spriteIndex = "5-5"
            spriteRow = 12
        elseif (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][1] and self.neighbors[1][3])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][1])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][3])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "6-6"
            spriteRow = 11
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3]) then
            spriteIndex = "6-6"
            spriteRow = 12
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2])
            or (self.neighbors[1][1] and self.neighbors[1][3] and self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][2])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "7-7"
            spriteRow = 11
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][2] and self.neighbors[3][3]) then
            spriteIndex = "7-7"
            spriteRow = 12
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[3][2])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][2]) then
            spriteIndex = "8-8"
            spriteRow = 11
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2])
            or (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2]) then
            spriteIndex = "8-8"
            spriteRow = 12
        elseif (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "11-11"
            spriteRow = 12
        elseif (self.neighbors[1][1] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2])
            or (self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2])
            or (self.neighbors[1][1] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2])
            or (self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "7-7"
            spriteRow = 9
        elseif (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][1])
            or (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[2][3]) then
            spriteIndex = "7-7"
            spriteRow = 10
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2])
            or (self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][1] and self.neighbors[3][2])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][2])
            or (self.neighbors[1][2] and self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "9-9"
            spriteRow = 10
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][1] and self.neighbors[3][2])
            or (self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][2]) then
            spriteIndex = "10-10"
            spriteRow = 10
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[1][3] and self.neighbors[3][1])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[1][3])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1] and self.neighbors[3][1])
            or (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[2][1]) then
            spriteIndex = "3-3"
            spriteRow = 11
        elseif (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[1][1] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[1][1])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3] and self.neighbors[3][3])
            or (self.neighbors[1][2] and self.neighbors[1][3] and self.neighbors[2][3]) then
            spriteIndex = "1-1"
            spriteRow = 11
        elseif (self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[1][1])
            or (self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2] and self.neighbors[1][1])
            or (self.neighbors[2][1] and self.neighbors[3][1] and self.neighbors[3][2]) then
            spriteIndex = "3-3"
            spriteRow = 9
        elseif (self.neighbors[2][3] and self.neighbors[3][3] and self.neighbors[3][2] and self.neighbors[3][1] and self.neighbors[1][3])
            or (self.neighbors[2][3] and self.neighbors[3][3] and self.neighbors[3][2] and self.neighbors[1][3])
            or (self.neighbors[2][3] and self.neighbors[3][3] and self.neighbors[3][2] and self.neighbors[3][1])
            or (self.neighbors[2][3] and self.neighbors[3][3] and self.neighbors[3][2]) then
            spriteIndex = "1-1"
            spriteRow = 9
        elseif (self.neighbors[2][3] and self.neighbors[3][2]) then
            spriteIndex = "11-11"
            spriteRow = 10
        elseif (self.neighbors[2][1] and self.neighbors[3][2]) then
            spriteIndex = "12-12"
            spriteRow = 10
        elseif (self.neighbors[1][2] and self.neighbors[2][3]) then
            spriteIndex = "11-11"
            spriteRow = 11
        elseif (self.neighbors[1][2] and self.neighbors[2][1]) then
            spriteIndex = "12-12"
            spriteRow = 11
        elseif (self.neighbors[2][1] and self.neighbors[2][3]) then
            spriteIndex = "2-2"
            spriteRow = 12
        elseif (self.neighbors[2][1] and self.neighbors[1][1] and self.neighbors[3][1])
            or (self.neighbors[2][1] and self.neighbors[3][1])
            or (self.neighbors[2][1] and self.neighbors[1][1])
            or (self.neighbors[2][1]) then
            spriteIndex = "3-3"
            spriteRow = 12
        elseif (self.neighbors[2][3] and self.neighbors[1][3] and self.neighbors[3][3])
            or (self.neighbors[2][3] and self.neighbors[1][3])
            or (self.neighbors[2][3] and self.neighbors[3][3])
            or (self.neighbors[2][3]) then
            spriteIndex = "1-1"
            spriteRow = 12
        elseif (self.neighbors[1][2] and self.neighbors[3][2]) then
            spriteIndex = "4-4"
            spriteRow = 10
        elseif (self.neighbors[1][1] and self.neighbors[1][2] and self.neighbors[1][3])
            or (self.neighbors[1][1] and self.neighbors[1][2])
            or (self.neighbors[1][3] and self.neighbors[1][2])
            or (self.neighbors[1][2]) then
            spriteIndex = "4-4"
            spriteRow = 11
        elseif (self.neighbors[3][2] and self.neighbors[3][3] and self.neighbors[3][1])
            or (self.neighbors[3][2] and self.neighbors[3][3])
            or (self.neighbors[3][2] and self.neighbors[3][1])
            or (self.neighbors[3][2]) then
            spriteIndex = "4-4"
            spriteRow = 9
        end

        self.tile = anim8.newAnimation(self.grid(spriteIndex, spriteRow), 1)
    end,

    setNeighbors = function(self, dirtTiles)
        for _, tile in pairs(dirtTiles) do
            if tile.positionX == self.positionX - self.width and tile.positionY == self.positionY then
                self.neighbors[2][1] = true
            elseif tile.positionX == self.positionX + self.width and tile.positionY == self.positionY then
                self.neighbors[2][3] = true
            elseif tile.positionX == self.positionX and tile.positionY == self.positionY - self.height then
                self.neighbors[1][2] = true
            elseif tile.positionX == self.positionX and tile.positionY == self.positionY + self.height then
                self.neighbors[3][2] = true
            elseif tile.positionX == self.positionX - self.width and tile.positionY == self.positionY - self.height then
                self.neighbors[1][1] = true
            elseif tile.positionX == self.positionX + self.width and tile.positionY == self.positionY + self.height then
                self.neighbors[3][3] = true
            elseif tile.positionX == self.positionX - self.width and tile.positionY == self.positionY + self.height then
                self.neighbors[3][1] = true
            elseif tile.positionX == self.positionX + self.width and tile.positionY == self.positionY - self.height then
                self.neighbors[1][3] = true
            end
        end
    end,

    printNeighbors = function(self)
        print(self.neighbors[1][1] .. self.neighbors[1][2] .. self.neighbors[1][3])
        print(self.neighbors[2][1] .. " " .. self.neighbors[2][3])
        print(self.neighbors[3][1] .. self.neighbors[3][2] .. self.neighbors[3][3])
    end,

    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2

        return px, py
    end,
}

return DirtTile

local Class = require("lib.hump.class")
local Luastar = require("lib.lua-star")

local utils = require("src.utils")
local GameSettings = require("src.gameSettings")

Enemy = Class {
    init = function(self, positionX, positionY, world)
        self.world = world;

        self.speed = GameSettings.PLAYER_SPEED / 2;
        self.collisionW = GameSettings.TILE_SIZE;
        self.collisionH = GameSettings.TILE_SIZE;

        self.type = 'enemy';

        self.state = 0;

        self.path = nil;
        self.currentPoint = 1;

        self.collider = self.world:newBSGRectangleCollider(positionX, positionY,
                                                           self.collisionW,
                                                           self.collisionH, 10);
        self.collider:setCollisionClass("Enemy")
        self.collider:setFixedRotation(true)
    end,

    load = function(self) end,

    render = function(self)
        if self.state == -1 then return end
        -- self:renderPath();

        love.graphics.setColor(GameSettings:getPinkColor(0.75));
        love.graphics.rectangle('fill',
                                self.collider:getX() - self.collisionW / 2,
                                self.collider:getY() - self.collisionH / 2,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(GameSettings:getPinkColor(1));
        love.graphics.rectangle('line',
                                self.collider:getX() - self.collisionW / 2,
                                self.collider:getY() - self.collisionH / 2,
                                self.collisionW, self.collisionH);

        love.graphics.setColor(255, 255, 255);
    end,

    update = function(self, dt)
        if self.state == -1 then return end

        if self.path ~= nil then
            local targetPoint = self.path[self.currentPoint]

            if not targetPoint then return end

            if self.collider:getX() == targetPoint.x and self.collider:getY() ==
                targetPoint.y then
                -- Move on to the next point in the path
                self.currentPoint = self.currentPoint + 1
                if self.currentPoint > #self.path then
                    -- The enemy has reached its destination
                    return
                end
                targetPoint = self.path[self.currentPoint]
            end

            -- Calculate the distance and direction to the target point
            local dx = targetPoint.x - self.collider:getX() + self.collisionW /
                           2
            local dy = targetPoint.y - self.collider:getY() + self.collisionH /
                           2

            -- Move the enemy towards the target point
            -- local moveDistance = math.min(1 * dt, distance)
            self.collider:setLinearVelocity(dx * 10, dy * 10)
            -- self.collider:setLinearVelocity(
            --     self.collider:getX() + moveDistance * math.cos(direction),
            --     self.collider:getY() + moveDistance * math.sin(direction))
        end
    end,

    setPath = function(self, path)
        self.path = path;
        self.currentPoint = 1;
    end,

    renderPath = function(self)
        if self.path then
            for i, p in ipairs(self.path) do
                love.graphics.setColor(GameSettings:getWhiteColor(0.05))
                love.graphics.rectangle("fill", p.x, p.y,
                                        GameSettings.TILE_SIZE,
                                        GameSettings.TILE_SIZE)
                love.graphics.setColor(0, 0, 0)
                love.graphics.print(tostring(i), (p.x), (p.y))
            end
        end
    end,

    canSeePlayer = function(self, player)
        local playerDistance = utils:getDistance(self.collider:getX(),
                                                 self.collider:getY(),
                                                 player.collider:getX(),
                                                 player.collider:getY())
        if playerDistance < player.activeRadius then return true end
        return false
    end,

    generatePath = function(self, player, levelW, levelH, map)
        local positionIsOpenFunc = function(x, y)
            -- should return true if the position is open to walk
            return map[x][y] ~= '#'
        end

        if not self:canSeePlayer(player) then goto continue end
        local pathPoints = {}
        local path = Luastar:find(levelW, levelH, {
            x = math.floor(self.collider:getX() / GameSettings.TILE_SIZE),
            y = math.floor(self.collider:getY() / GameSettings.TILE_SIZE)
        }, {
            x = math.floor(player.collider:getX() / GameSettings.TILE_SIZE),
            y = math.floor(player.collider:getY() / GameSettings.TILE_SIZE)
        }, positionIsOpenFunc, true)
        if path then
            for i, p in ipairs(path) do
                if i == 1 then goto skip_first end
                table.insert(pathPoints, {
                    x = p.x * GameSettings.TILE_SIZE,
                    y = p.y * GameSettings.TILE_SIZE
                })
                ::skip_first::
            end
            self:setPath(pathPoints)
        end
        ::continue::
    end,

    die = function(self)
        self.world:remove(self)
        self.state = -1
    end
}

return Enemy

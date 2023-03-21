GameSettings = require("src.gameSettings")
Class = require("lib.hump.class")

Enemy = Class {
    init = function(self, positionX, positionY, world)
        self.type = 'enemy'
        self.state = 0

        self.speed = GameSettings.PLAYER_SPEED/2;
        self.positionX = positionX;
        self.positionY = positionY;
        self.collisionW = GameSettings.TILE_SIZE;
        self.collisionH = GameSettings.TILE_SIZE;

        self.path = nil;
        self.currentPoint = 1;

        self.world = world;
    end,

    load = function(self)
        self.world:add(self, self.positionX, self.positionY, self.collisionW,
                       self.collisionH)
    end,

    render = function(self)
        if self.state == -1 then return end
        self:renderPath();

        love.graphics.setColor(GameSettings:getPinkColor(0.75));
        love.graphics.rectangle('fill', self.positionX, self.positionY,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(GameSettings:getPinkColor(1));
        love.graphics.rectangle('line', self.positionX, self.positionY,
                                self.collisionW, self.collisionH);

        love.graphics.setColor(255, 255, 255);
    end,

    update = function(self, dt)

        local filter = function(item, other)
            if other.type == 'enemy' or other.type == 'player' then
                return 'cross'
            end
            return 'slide'
        end

        if self.state == -1 then return end

        if self.path ~= nil then
            local targetPoint = self.path[self.currentPoint]

            if not targetPoint then return end

            if self.positionX == targetPoint.x and self.positionY ==
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
            local dx = targetPoint.x - self.positionX
            local dy = targetPoint.y - self.positionY
            local distance = math.sqrt(dx * dx + dy * dy)
            local direction = math.atan2(dy, dx)

            -- Move the enemy towards the target point
            local moveDistance = math.min(self.speed * dt, distance)
            self.positionX, self.positionY, _, _ =
                self.world:move(self, self.positionX + moveDistance *
                                    math.cos(direction), self.positionY +
                                    moveDistance * math.sin(direction), filter)
        end
    end,

    setPath = function(self, path)
        self.path = path
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

    die = function(self)
        self.world:remove(self)
        self.state = -1
    end
}

return Enemy

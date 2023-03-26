local GameSettings = require("src.gameSettings")
local Class = require("lib.hump.class")
local vector = require("lib.hump.vector")

local utils = require('src.utils')
local effects = require('src.effects.effect')

Player = Class {
    init = function(self, positionX, positionY, world, sword)
        self.world = world;
        self.sword = sword;

        self.collisionW = GameSettings.TILE_SIZE;
        self.collisionH = GameSettings.TILE_SIZE;
        self.speed = GameSettings.PLAYER_SPEED;

        self.type = 'player';

        self.dirX = 1;
        self.dirY = 1;
        self.state = 0;
        self.rotateMargin = 0.25;
        self.attackDir = vector(0, 1);

        self.collider = self.world:newBSGRectangleCollider(positionX, positionY,
                                                           self.collisionW,
                                                           self.collisionH, 3);
        self.collider:setCollisionClass("Player")
        self.collider:setFixedRotation(true)

        self.activeRadius = GameSettings.TILE_SIZE * 15;

        self.attackTimer = 0;
        self.attackCoolDown = 0;
    end,

    load = function(self) end,

    handleMovePlayer = function(self, dt)
        local speed = self.speed
        -- local px, py = self.collider:getLinearVelocity();

        if self.state == 1 then
            self.collider:setLinearVelocity(0, 0);
            return
        end

        local dx, dy = 0, 0
        if (love.keyboard.isDown('right') or love.keyboard.isDown("d")) then
            dx = speed * dt
        elseif love.keyboard.isDown('left') or love.keyboard.isDown("a") then
            dx = -speed * dt
        end
        if love.keyboard.isDown('down') or love.keyboard.isDown("s") then
            dy = speed * dt
        elseif love.keyboard.isDown('up') or love.keyboard.isDown("w") then
            dy = -speed * dt
        end

        self.collider:setLinearVelocity(dx, dy);

        if dx ~= 0 or dy ~= 0 then
            self.state = 0.5 -- moving
        else
            self.state = 0
        end
    end,

    update = function(self, dt)
        self:handleMovePlayer(dt);

        if self.attackTimer > 0 then
            self.attackTimer = self.attackTimer - dt
        end

        if self.attackCoolDown > 0 then
            self.attackCoolDown = self.attackCoolDown - dt
        end

        if self.state == 1 and self.attackTimer < 0 then
            -- self.sword:removeSwordFromWorld(self)
            -- self.sword.active = false
            self.state = 0
        end

        self.sword:update(self)
    end,

    render = function(self)
        -- self:renderPlayerField()

        self:swordDamage();

        love.graphics.setColor(GameSettings:getGreenColor(1));
        love.graphics.rectangle('line',
                                self.collider:getX() - self.collisionW / 2,
                                self.collider:getY() - self.collisionH / 2,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(GameSettings:getGreenColor(0.75));
        love.graphics.rectangle('fill',
                                self.collider:getX() - self.collisionW / 2,
                                self.collider:getY() - self.collisionH / 2,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(255, 255, 255);

        self.sword:render(self);
    end,

    renderPlayerField = function(self)
        love.graphics.setColor(GameSettings:getGreenColor(0.25));
        love.graphics.circle("fill", self.collider:getX() - self.collisionW / 2,
                             self.collider:getY() - self.collisionH / 2,
                             self.activeRadius);
    end,

    setDirFromVector = function(self, vec)
        local rad = math.atan2(vec.y, vec.x)
        if rad >= self.rotateMargin * -1 and rad < math.pi / 2 then
            self.dirX = 1
            self.dirY = 1
        elseif (rad >= math.pi / 2 and rad < math.pi) or
            (rad < (math.pi - self.rotateMargin) * -1) then
            self.dirX = -1
            self.dirY = 1
        elseif rad < 0 and rad > math.pi / -2 then
            self.dirX = 1
            self.dirY = -1
        else
            self.dirX = -1
            self.dirY = -1
        end
    end,

    attack = function(self)
        if self.attackCoolDown <= 0 then
            self.attackDir = utils:toMouseVector(self.collider:getX(),
                                                 self.collider:getY())
            self:setDirFromVector(self.attackDir)

            effects:spawn("slice", self.collider:getX(), self.collider:getY(),
                          self.attackDir)
            self.state = 1
            -- self.sword:addSwordToWorld(self)
            -- self.sword.active = true
            self.attackTimer = 0.2
            self.attackCoolDown = 0.4
        end
    end,

    swordDamage = function(self)
        local px, py = self.collider:getX(), self.collider:getY();
        local dir = self.attackDir:normalized()
        local rightDir = dir:rotated(math.pi / 2)
        local leftDir = dir:rotated(math.pi / -2)
        local polygon = {
            px + dir.x * 40, py + dir.y * 40,
            px + dir:rotated(math.pi / 4).x * 40,
            py + dir:rotated(math.pi / 4).y * 40, px + rightDir.x * 44,
            py + rightDir.y * 44,
            px + leftDir.x * 44 + leftDir:rotated(math.pi / -2).x * 12,
            py + leftDir.y * 44 + leftDir:rotated(math.pi / -2).y * 12,
            px + dir:rotated(3 * math.pi / -8).x * 40,
            py + dir:rotated(3 * math.pi / -8).y * 40,
            px + dir:rotated(math.pi / -8).x * 40,
            py + dir:rotated(math.pi / -8).y * 40
        }

        -- love.graphics.polygon("fill", polygon);

        -- local hitEnemies = world:queryPolygonArea(polygon, {'Enemy'})
        -- for _,e in ipairs(hitEnemies) do
        --     local knockbackDir = getPlayerToSelfVector(e:getX(), e:getY())
        --     e.parent:hit(1, knockbackDir, 0.1)
        -- end
    end

}

return Player

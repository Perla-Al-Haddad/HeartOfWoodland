local GameSettings = require("src.gameSettings")
local Class = require("lib.hump.class")

Player = Class {
    init = function(self, positionX, positionY, world, sword)
        self.type = 'player'

        self.positionX = positionX;
        self.positionY = positionY;
        self.speed = GameSettings.PLAYER_SPEED;
        self.collisionW = GameSettings.TILE_SIZE;
        self.collisionH = GameSettings.TILE_SIZE;
        self.state = 0
        self.attackDir = GameSettings.INITIAL_PLAYER_DIR;

        self.activeRadius = GameSettings.TILE_SIZE * 15;

        self.attackTimer = 0;
        self.attackCoolDown = 0;

        self.world = world;
        self.sword = sword;
    end,

    load = function(self)
        self.world:add(self, self.positionX, self.positionY, self.collisionW,
                       self.collisionH)
    end,

    handleMovePlayer = function(self, dt)
        local speed = self.speed

        local filter = function(item, other)
            if other.type == 'enemy' then return 'cross' end
            return 'slide'
        end

        if self.state == 1 then return end

        local dx, dy = 0, 0
        if love.keyboard.isDown('right') then
            self.attackDir = 'right'
            dx = speed * dt
        elseif love.keyboard.isDown('left') then
            self.attackDir = 'left'
            dx = -speed * dt
        end
        if love.keyboard.isDown('down') then
            self.attackDir = 'down'
            dy = speed * dt
        elseif love.keyboard.isDown('up') then
            self.attackDir = 'up'
            dy = -speed * dt
        end

        if dx ~= 0 or dy ~= 0 then
            self.state = 0.5 -- moving 
            self.positionX, self.positionY, _, _ =
                self.world:move(self, self.positionX + dx, self.positionY + dy,
                                filter)
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
            self.sword:removeSwordFromWorld(self)
            self.sword.active = false
            self.state = 0
        end

        self.sword:update(self)
    end,

    render = function(self)
        love.graphics.setColor(GameSettings:getGreenColor(0.25));
        love.graphics.circle("fill", self.positionX + self.collisionW / 2,
                             self.positionY + self.collisionH / 2,
                             self.activeRadius);

        love.graphics.setColor(GameSettings:getGreenColor(1));
        love.graphics.rectangle('line', self.positionX, self.positionY,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(GameSettings:getGreenColor(0.75));
        love.graphics.rectangle('fill', self.positionX, self.positionY,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(255, 255, 255);

        self.sword:render(self);
    end,

    attack = function(self)
        if self.state == 0 and self.attackCoolDown <= 0 then
            self.state = 1
            self.sword:addSwordToWorld(self)
            self.sword.active = true
            self.attackTimer = 0.2
            self.attackCoolDown = 0.4
        end
    end
}

return Player

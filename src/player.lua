Class = require("lib.hump.class")

Player = Class {
    init = function(self, positionX, positionY, world, sword)
        self.positionX = positionX;
        self.positionY = positionY;
        self.speed = 150;
        self.collisionW = 16;
        self.collisionH = 16;
        self.state = 0
        self.attackDir = "right";

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
            self.positionX, self.positionY, _, _ =
                self.world:move(self, self.positionX + dx, self.positionY + dy)
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
            self.sword.active = false
            self.state = 0
        end
    end,

    render = function(self)
        love.graphics.setColor(255, 255, 255);
        love.graphics.rectangle('fill', self.positionX - self.collisionW / 2,
                                self.positionY - self.collisionH / 2,
                                self.collisionW, self.collisionH);
        love.graphics.setColor(255, 255, 255);

        self.sword:render(self.sword, self);
    end,

    attack = function(self)
        if self.state == 0 and self.attackCoolDown <= 0 then
            self.state = 1
            self.sword.active = true
            self.attackTimer = 0.2
            self.attackCoolDown = 0.4
        end
    end
}

return Player

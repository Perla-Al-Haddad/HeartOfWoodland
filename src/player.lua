local Sword = require 'src.sword';

local Player = {};

function Player:new(o, positionX, positionY, world)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.positionX = positionX;
    o.positionY = positionY;
    o.speed = 150;
    o.collisionW = 16;
    o.collisionH = 16;
    o.state = 0
    o.attackDir = "right";

    o.attackTimer = 0;
    o.attackCoolDown = 0;

    o.world = world;
    o.sword = Sword:new(nil);
    
    return o
end

function Player:load(o)
    o.world:add(o, o.positionX, o.positionY, o.collisionW,
                   o.collisionH)
end

function Player:handleQuit() love.event.quit(); end

function Player:handleMovePlayer(o, dt)
    local speed = o.speed

    local dx, dy = 0, 0
    if love.keyboard.isDown('right') then
        o.attackDir = 'right'
        dx = speed * dt
    elseif love.keyboard.isDown('left') then
        o.attackDir = 'left'
        dx = -speed * dt
    end
    if love.keyboard.isDown('down') then
        o.attackDir = 'down'
        dy = speed * dt
    elseif love.keyboard.isDown('up') then
        o.attackDir = 'up'
        dy = -speed * dt
    end

    if dx ~= 0 or dy ~= 0 then
        o.positionX, o.positionY, _, _ =
            o.world:move(o, o.positionX + dx, o.positionY + dy)
    end
end

function Player:handleKeyBoardEvents(o, dt)
    Player:handleMovePlayer(o, dt);

    if love.keyboard.isDown("escape") then o:handleQuit(); end

    if o.attackTimer > 0 then
        o.attackTimer = o.attackTimer - dt
    end

    if o.attackCoolDown > 0 then
        o.attackCoolDown = o.attackCoolDown - dt
    end

    if o.state == 1 and o.attackTimer < 0 then
        o.sword.active = false
        o.state = 0
    end
end

function Player:render(o)
    love.graphics.setColor(255, 255, 255);
    love.graphics.rectangle('fill', o.positionX - o.collisionW / 2,
                            o.positionY - o.collisionH / 2,
                            o.collisionW, o.collisionH);
    love.graphics.setColor(255, 255, 255);

    o.sword:render(o.sword, self);
end

function Player:attack(o)
    if o.state == 0 and o.attackCoolDown <= 0 then
        o.state = 1
        o.sword.active = true
        o.attackTimer = 0.2
        o.attackCoolDown = 0.4
    end
end

return Player

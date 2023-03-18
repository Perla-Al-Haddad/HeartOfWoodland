local Player = {};

function Player:new(o, position_x, position_y, world)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.position_x = position_x;
    o.position_y = position_y;
    o.speed = 150;
    o.collision_w = 16;
    o.collision_h = 16;
    o.world = world;
    return o
end

function Player:load(o)
    o.world:add(o, o.position_x, o.position_y, o.collision_w,
                   o.collision_h)
end

function Player:handleQuit() love.event.quit(); end

function Player:handleMovePlayer(o, dt)
    local speed = o.speed

    local dx, dy = 0, 0
    if love.keyboard.isDown('right') then
        dx = speed * dt
    elseif love.keyboard.isDown('left') then
        dx = -speed * dt
    end
    if love.keyboard.isDown('down') then
        dy = speed * dt
    elseif love.keyboard.isDown('up') then
        dy = -speed * dt
    end

    if dx ~= 0 or dy ~= 0 then
        o.position_x, o.position_y, _, _ =
            o.world:move(o, o.position_x + dx, o.position_y + dy)
    end
end

function Player:handleKeyBoardEvents(o, dt)
    Player:handleMovePlayer(o, dt);

    if love.keyboard.isDown("escape") then o:handleQuit(); end
end

function Player:render(o)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('fill', o.position_x - o.collision_w / 2,
                            o.position_y - o.collision_h / 2,
                            o.collision_w, o.collision_h)
    love.graphics.setColor(255, 255, 255)
end

return Player

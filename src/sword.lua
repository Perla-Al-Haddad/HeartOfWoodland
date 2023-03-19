local Sword = {}

function Sword:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.swordW = 16
    o.swordH = 4
    o.swordOffset = 2
    o.active = false
    return o
end

function Sword:getSwordPosition(o, player)
    local default_position = {
        x = player.positionX + player.collisionW / 2 + o.swordOffset,
        y = player.positionY - o.swordH / 2,
        w = o.swordW,
        h = o.swordH
    };
    if player.attackDir == 'right' then
        return default_position;
    elseif player.attackDir == 'left' then
        return {
            x = player.positionX - player.collisionW / 2 - o.swordOffset -
                o.swordW,
            y = player.positionY - o.swordH / 2,
            w = o.swordW,
            h = o.swordH
        };
    elseif player.attackDir == 'up' then
        return {
            x = player.positionX - o.swordH / 2,
            y = player.positionY - player.collisionH / 2 - o.swordOffset -
                o.swordW,
            w = o.swordH,
            h = o.swordW
        };
    elseif player.attackDir == 'down' then
        return {
            x = player.positionX - o.swordH / 2,
            y = player.positionY + player.collisionH / 2 + o.swordOffset,
            w = o.swordH,
            h = o.swordW
        };
    end
end

function Sword:render(o, player)
    if not o.active then return; end
    love.graphics.setColor(255, 0, 0);
    local position = o.getSwordPosition(o, o, player);

    love.graphics.rectangle("fill", position.x, position.y, position.w,
                            position.h);
    love.graphics.setColor(255, 255, 255)
end

return Sword

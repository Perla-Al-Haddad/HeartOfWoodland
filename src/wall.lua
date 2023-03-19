local Wall = {}

function Wall:new(o, positionX, positionY, world)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.collisionW = 16
    o.collisionH = 16
    o.world = world
    o.positionX = positionX
    o.positionY = positionY
    return o
end

function Wall:render(o)
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle("line", o.positionX - o.collisionW / 2,
                            o.positionY - o.collisionH / 2,
                            o.collisionW, o.collisionH)
    love.graphics.setColor(255, 255, 255)
end

function Wall:load(o)
    local block = {o.positionX, o.positionY, o.collisionW, o.collisionH}
    o.world:add(block, o.positionX, o.positionY, o.collisionW,
                   o.collisionH)
end

return Wall

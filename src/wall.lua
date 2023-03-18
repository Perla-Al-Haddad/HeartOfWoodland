local Wall = {}

function Wall:new(o, position_x, position_y, world)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.collision_w = 16
    o.collision_h = 16
    o.world = world
    o.position_x = position_x
    o.position_y = position_y
    return o
end

function Wall:render(o)
    love.graphics.setColor(0, 0, 255)
    love.graphics.rectangle("line", o.position_x - o.collision_w / 2,
                            o.position_y - o.collision_h / 2,
                            o.collision_w, o.collision_h)
    love.graphics.setColor(255, 255, 255)
end

function Wall:load(o)
    local block = {o.position_x, o.position_y, o.collision_w, o.collision_h}
    o.world:add(block, o.position_x, o.position_y, o.collision_w,
                   o.collision_h)
end

return Wall

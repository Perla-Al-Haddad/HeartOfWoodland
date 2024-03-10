local Class = require("lib.hump.class")

LongGrassHandler = Class {
    init = function(self) self.objects = {} end,

    add = function(self, object) table.insert(self.objects, object) end,

    update = function(self, dt)
        for _, obj in ipairs(self.objects) do obj:update(dt) end
    end,

    updateOnScreen = function(self, dt, camera)
        for _, obj in ipairs(self.objects) do
            obj:update(dt, camera)
        end
    end,

    draw = function(self)
        for _, obj in ipairs(self.objects) do obj:draw(dt) end
    end,

    drawOnScreen = function(self, camera)
        for _, obj in ipairs(self.objects) do
            if camera:isOnScreen(obj.positionX, obj.positionY) then
                obj:draw(dt)
            end
        end
    end,

    getByCollider = function(self, collider)
        for i, obj in ipairs(self.objects) do
            if obj.collider == collider then
                return obj
            end
        end
    end
}

return LongGrassHandler

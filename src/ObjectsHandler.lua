local Class = require("lib.hump.class")

ObjectsHandler = Class {
    init = function(self) self.objects = {} end,

    addObject = function(self, object) table.insert(self.objects, object) end,
    
    updateObjects = function(self, dt)
        for _, obj in ipairs(self.objects) do obj:update(dt) end
    end,
    
    drawObjects = function (self)
        for _, obj in ipairs(self.objects) do obj:draw(dt) end
    end,
    
    getObjectByCollider = function(self, collider)
        for i, obj in ipairs(self.objects) do
            if obj.collider == collider then
                return obj
            end
        end
    end
}

return ObjectsHandler

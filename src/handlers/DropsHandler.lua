local Class = require("lib.hump.class")

DropsHandler = Class {
    init = function(self) self.drops = {} end,
   
    addDrop = function(self, enemy) 
        table.insert(self.drops, enemy)
    end,

    updateDrops = function(self, dt)
        for _, e in ipairs(self.drops) do e:update(dt) end
    end,

    drawDrops = function(self)
        for _, e in ipairs(self.drops) do
            e:draw()
        end
    end,

    getDropByCollider = function(self, collider)
        for i, e in ipairs(self.drops) do
            if e.collider == collider then
                return e
            end
        end
    end
}

return DropsHandler

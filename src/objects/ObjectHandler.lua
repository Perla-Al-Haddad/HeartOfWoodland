local Class = require("lib.hump.class")


local ObjectHandler = Class {
    init = function(self, world, gameMap)
        self.objects = {}
        self.world = world
        self.gameMap = gameMap
    end,

    add = function (self, objCls, layerName)
        local layer = self.gameMap.layers[layerName]
        for i, row in ipairs(layer.data) do
            for key, _ in pairs(row) do
                local obj = objCls((key - 1) * 16, (i - 1) * 16, self.world)
                table.insert(self.objects, obj)
            end
        end
    end,

    update = function (self, dt)
        for _, obj in ipairs(self.objects) do
            obj:update(dt)
        end
    end,

    draw = function(self)
        for _, obj in ipairs(self.objects) do
            obj:draw()
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

return ObjectHandler
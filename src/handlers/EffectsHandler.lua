local Class = require("lib.hump.class")

EffectsHandler = Class {
    init = function(self) self.effects = {} end,

    addEffect = function(self, effect)
        table.insert(self.effects, effect)
    end,

    updateEffects = function(self, dt)
        for _, e in ipairs(self.effects) do e.anim:update(dt) end
        local i = #self.effects
        while i > 0 do
            if self.effects[i].dead then
                table.remove(self.effects, i)
            end
            i = i - 1
        end
    end,

    updateEffectsOnScreen = function(self, dt, camera)
        for _, e in ipairs(self.effects) do
            if camera:isOnScreen(e.positionX, e.positionY) then
                e.anim:update(dt)
            end
        end
        local i = #self.effects
        while i > 0 do
            if self.effects[i].dead then
                table.remove(self.effects, i)
            end
            i = i - 1
        end
    end,

    drawEffects = function(self, layer)
        for _, e in ipairs(self.effects) do
            if e.layer == layer then
                if e.anim then
                    if e.alpha then
                        love.graphics.setColor(1, 1, 1, e.alpha)
                    end
                    e.anim:draw(e.spriteSheet, e.positionX, e.positionY, e.rot,
                        e.scaleX, e.scaleY, e.width / 2, e.height / 2)
                end
                if e.draw then e:draw() end
            end
        end
    end,

    drawEffectsOnScreen = function(self, layer, camera)
        for _, e in ipairs(self.effects) do
            if e.layer == layer then
                if e.anim then
                    if e.alpha then
                        love.graphics.setColor(1, 1, 1, e.alpha)
                    end
                    if camera:isOnScreen(e.positionX, e.positionY) then
                        e.anim:draw(e.spriteSheet, e.positionX, e.positionY, e.rot,
                            e.scaleX, e.scaleY, e.width / 2, e.height / 2)
                    end
                end
                if e.draw then e:draw() end
            end
        end
    end
}

return EffectsHandler

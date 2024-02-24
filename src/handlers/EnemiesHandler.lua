local Class = require("lib.hump.class")

local funcs = require("src.utils.funcs")
local conf = require("src.utils.conf")

EnemiesHandler = Class {
    init = function(self) self.enemies = {} end,

    addEnemy = function(self, enemy)
        table.insert(self.enemies, enemy)
    end,

    updateEnemies = function(self, dt)
        for _, e in ipairs(self.enemies) do e:updateAbs(dt) end
    end,

    updateEnemiesOnScreen = function(self, dt, camera)
        for _, e in ipairs(self.enemies) do
            local ex, ey = e:getSpriteTopPosition()
            local enemyIsOnScreen = camera:isOnScreen(ex, ey)
            if enemyIsOnScreen then
                e:updateAbs(dt)
            end
        end
    end,

    drawEnemies = function(self)
        for _, e in ipairs(self.enemies) do
            e:drawAbs()
        end
    end,

    getEnemyByCollider = function(self, collider)
        for i, e in ipairs(self.enemies) do
            if e.hurtCollider == collider then
                return e
            end
        end
    end
}

return EnemiesHandler

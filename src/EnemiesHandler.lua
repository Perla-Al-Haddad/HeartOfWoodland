local Class = require("lib.hump.class")

EnemiesHandler = Class {
    init = function(self) self.enemies = {} end,
   
    addEnemy = function(self, enemy) 
        table.insert(self.enemies, enemy)
    end,

    updateEnemies = function(self, dt)
        for _, e in ipairs(self.enemies) do e:updateAbs(dt) end
        -- local i = #self.enemies
        -- while i > 0 do
        --     if self.enemies[i].dead then
        --         table.remove(self.enemies, i)
        --     end
        --     i = i - 1
        -- end
    end,

    drawEnemies = function(self)
        for _, e in ipairs(self.enemies) do
            e:drawAbs()
        end
    end,

    getEnemyByCollider = function(self, collider)
        for i, e in ipairs(self.enemies) do
            if e.collider == collider then
                return e
            end
        end
    end
}

return EnemiesHandler

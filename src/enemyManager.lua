Class = require('lib.hump.class')

local EnemyManager = Class {
    init = function(self, enemies) self.enemies = enemies end,

    loadEnemies = function(self)
        for _, enemy in pairs(self.enemies) do enemy:load() end
    end,

    updateEnemies = function(self, dt)
        for _, enemy in pairs(self.enemies) do
            enemy:update(dt)
        end
    end,

    renderEnemies = function(self)
        for _, enemy in pairs(self.enemies) do enemy:render() end
    end
}

return EnemyManager

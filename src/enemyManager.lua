local Class = require('lib.hump.class')
local Timer = require('lib.hump.timer')

local EnemyManager = Class {
    init = function(self, enemies) self.enemies = enemies end,

    loadEnemies = function(self, player, levelW, levelH, map)
        for _, enemy in pairs(self.enemies) do enemy:load() end
        Timer.every(0.25, function()
            self:generateEnemyPaths(player, levelW, levelH, map);
        end)
    end,

    updateEnemies = function(self, dt)
        for _, enemy in pairs(self.enemies) do enemy:update(dt) end
    end,

    generateEnemyPaths = function(self, player, levelW, levelH, map)
        for _, enemy in pairs(self.enemies) do
            enemy:generatePath(player, levelW, levelH, map);
        end
    end,

    renderEnemies = function(self)
        for _, enemy in pairs(self.enemies) do enemy:render() end
    end
}

return EnemyManager

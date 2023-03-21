local Class = require('lib.hump.class')
local Luastar = require("lib.lua-star")

local GameSettings = require("src.gameSettings")

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

    generateEnemyPaths = function(self, player, levelW, levelH, map)
        local positionIsOpenFunc = function(x, y)
            -- should return true if the position is open to walk
            return map[x][y] ~= '#'
        end

        for _, enemy in pairs(self.enemies) do
            local pathPoints = {}
            local path = Luastar:find(levelW, levelH, {
                x = math.floor(enemy.positionX / GameSettings.TILE_SIZE),
                y = math.floor(enemy.positionY / GameSettings.TILE_SIZE)
            }, {
                x = math.floor(player.positionX / GameSettings.TILE_SIZE),
                y = math.floor(player.positionY / GameSettings.TILE_SIZE)
            }, positionIsOpenFunc, true, true)
            if path then
                for i, p in ipairs(path) do
                    table.insert(pathPoints, {
                        x = p.x * GameSettings.TILE_SIZE,
                        y = p.y * GameSettings.TILE_SIZE
                    })
                end
                enemy:setPath(pathPoints)
            end
        end
    end,

    renderEnemies = function(self)
        for _, enemy in pairs(self.enemies) do enemy:render() end
    end
}

return EnemyManager

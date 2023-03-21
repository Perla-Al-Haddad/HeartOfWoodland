GameSettings = require('src.gameSettings')
Class = require('lib.hump.class')
ROT = require 'lib.rot.rot'
Luastar = require("lib.lua-star")

local positionIsOpenFunc = nil;

local Level = Class {
    init = function(self, levelW, levelH, world, player, enemyCount, Wall,
                    Enemy, WallManager, EnemyManager)
        self.map = {}
        self.levelW = levelW
        self.levelH = levelH
        self.enemyCount = enemyCount

        self:generateLevelMap()

        -- self.map = {
        --     {'.', '.', '.', '.', '.', '.', '#', '.'},
        --     {'.', '.', '.', '.', '#', '.', '#', '.'},
        --     {'.', '.', '.', '#', '#', '.', '#', '.'},
        --     {'.', 'E', '.', '#', '#', '.', '#', 'P'},
        --     {'.', '.', '.', '#', '#', '.', '#', '.'},
        --     {'.', '.', '.', '#', '#', '.', '#', '.'},
        --     {'.', '.', '.', '#', '.', '.', '.', '.'},
        --     {'.', '.', '.', '#', '.', '.', '#', '.'}
        -- }

        self.world = world
        self.player = player

        self.Wall = Wall
        self.Enemy = Enemy
        self.WallManager = WallManager
        self.EnemyManager = EnemyManager
        self.wallManager, self.enemyManager = self:processLevelMap()

        positionIsOpenFunc = function(x, y)
            -- should return true if the position is open to walk
            return self.map[x][y] ~= '#'
        end

        for _, enemy in pairs(self.enemyManager.enemies) do
            local pathPoints = {}
            local path = Luastar:find(self.levelW, self.levelH, {
                x = enemy.positionX / GameSettings.TILE_SIZE,
                y = enemy.positionY / GameSettings.TILE_SIZE
            }, {
                x = self.player.positionX / GameSettings.TILE_SIZE,
                y = self.player.positionY / GameSettings.TILE_SIZE
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

    generateLevelMap = function(self)
        local function calbak(x, y, val) end

        local function fillBlob(x, y, m, id)
            m[x][y] = id
            local todo = {{x, y}}
            local dirs = ROT.DIRS.EIGHT
            local size = 1
            repeat
                local pos = table.remove(todo, 1)
                for i = 1, #dirs do
                    local rx = pos[1] + dirs[i][1]
                    local ry = pos[2] + dirs[i][2]
                    if rx < 1 or rx > self.levelW or ry < 1 or ry > self.levelH then

                    elseif m[rx][ry] == 1 then
                        m[rx][ry] = id
                        table.insert(todo, {rx, ry})
                        size = size + 1
                    end
                end
            until #todo == 0
            return size
        end
        local cl = ROT.Map.Cellular:new(self.levelW, self.levelH)
        cl:randomize(.52)
        cl:create(calbak)

        local largest = 2;
        local id = 2;
        local largestCount = 0
        cl:randomize(.52)

        for i = 1, 5 do cl:create(calbak) end
        for x = 1, self.levelW do
            for y = 1, self.levelH do
                if cl._map[x][y] == 1 then
                    local count = fillBlob(x, y, cl._map, id)
                    if count > largestCount then
                        largest = id
                        largestCount = count
                    end
                    id = id + 1
                end
            end
        end

        for x = 1, self.levelW do
            self.map[x] = {}
            for y = 1, self.levelH do
                local block = (cl._map[x][y] == largest and '.' or '#')
                self.map[x][y] = block;
            end
        end

        self:placePlayer()
        for i = 1, self.enemyCount do self:placeEnemy() end
    end,

    placePlayer = function(self) self:placeEntity('P') end,

    placeEnemy = function(self) self:placeEntity('E') end,

    placeEntity = function(self, c)
        while true do
            local y = ROT.RNG:random(1, self.levelH)
            local x = ROT.RNG:random(1, self.levelW)
            if self.map[x][y] == '.' then
                self.map[x][y] = c
                break
            end
        end
    end,

    processLevelMap = function(self)
        local walls = {};
        local enemies = {};
        for x = 1, self.levelW do
            for y = 1, self.levelH do
                if self.map[x][y] == '#' then
                    table.insert(walls, self.Wall(x * GameSettings.TILE_SIZE,
                                                  y * GameSettings.TILE_SIZE,
                                                  self.world))
                elseif self.map[x][y] == 'P' then
                    self.player.positionX = x * GameSettings.TILE_SIZE
                    self.player.positionY = y * GameSettings.TILE_SIZE
                elseif self.map[x][y] == 'E' then
                    table.insert(enemies, self.Enemy(x * GameSettings.TILE_SIZE,
                                                     y * GameSettings.TILE_SIZE,
                                                     self.world))
                end
            end
        end

        local wallManager = self.WallManager(walls)
        local enemyManager = self.EnemyManager(enemies)
        return wallManager, enemyManager;
    end
}

return Level

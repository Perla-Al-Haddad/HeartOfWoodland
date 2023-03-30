local GameSettings = require('src.gameSettings')
local Class = require('lib.hump.class')
local ROT = require 'lib.rot.rot'

local Level = Class {
    init = function(self, levelW, levelH, world, player, enemyCount, Wall,
                    Enemy, WallManager, EnemyManager)
        self.map = {}
        self.levelW = levelW
        self.levelH = levelH
        self.enemyCount = enemyCount

        self:generateLevelMap()

        -- self.map = {
        --     {'.', '.', '.', '.', '.', '.', '.', '.'},
        --     {'.', '.', '.', '#', '.', '.', '.', '.'},
        --     {'.', '.', '.', '#', '.', '.', '.', '.'},
        --     {'.', '.', '.', '#', '.', '.', '.', '.'},
        --     {'.', '.', '.', '#', '.', '.', 'P', '.'},
        --     {'.', '.', '.', '#', '.', '.', '.', '.'},
        --     {'.', 'E', '.', '#', '.', '.', '.', '.'},
        --     {'.', '.', '.', '.', '.', '.', '.', '.'}
        -- }

        self.world = world
        self.player = player

        self.Wall = Wall
        self.Enemy = Enemy
        self.WallManager = WallManager
        self.EnemyManager = EnemyManager
        self.wallManager, self.enemyManager = self:processLevelMap()

        -- self.enemyManager:generateEnemyPaths(self.player, self.levelW,
        --                                      self.levelH, self.map);

        self.boundaries = self:initBoundaries();
    end,

    initBoundaries = function(self)
        local boundaryWidth = 16;
        local leftBoundary = {
            x = GameSettings.TILE_SIZE - boundaryWidth,
            y = GameSettings.TILE_SIZE - boundaryWidth,
            w = boundaryWidth,
            h = self.levelH * GameSettings.TILE_SIZE + boundaryWidth * 2
        }
        local rightBoundary = {
            x = (self.levelW + 1) * GameSettings.TILE_SIZE,
            y = GameSettings.TILE_SIZE - boundaryWidth,
            w = boundaryWidth,
            h = self.levelH * GameSettings.TILE_SIZE + boundaryWidth * 2
        }
        local topBoundary = {
            x = GameSettings.TILE_SIZE - boundaryWidth,
            y = GameSettings.TILE_SIZE - boundaryWidth,
            w = self.levelW * GameSettings.TILE_SIZE + boundaryWidth * 2,
            h = boundaryWidth
        }
        local bottomBoundary = {
            x = GameSettings.TILE_SIZE - boundaryWidth,
            y = (self.levelH + 1) * GameSettings.TILE_SIZE,
            w = self.levelW * GameSettings.TILE_SIZE + boundaryWidth * 2,
            h = boundaryWidth
        }
        local boundaries = {
            leftBoundary, rightBoundary, topBoundary, bottomBoundary
        };
        return boundaries;
    end,

    addLevelBoundary = function(self)
        for _, boundary in pairs(self.boundaries) do
            self.world:add(boundary, boundary.x, boundary.y, boundary.w,
                           boundary.h);
        end
    end,

    renderLevelBoundary = function(self)
        love.graphics.setColor(1, 1, 1, 0.5);
        for _, boundary in pairs(self.boundaries) do
            love.graphics.rectangle("fill", boundary.x, boundary.y, boundary.w,
                                    boundary.h);
        end
        love.graphics.setColor(1, 1, 1);
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
        local rand = 0.59;
        cl:randomize(rand)
        cl:create(calbak)

        local largest = 2;
        local id = 2;
        local largestCount = 0
        cl:randomize(rand)

        for i = 1, 20 do cl:create(calbak) end
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
                                                  self.world));
                elseif self.map[x][y] == 'P' then
                    self.player.collider:setX(x * GameSettings.TILE_SIZE);
                    self.player.collider:setY(y * GameSettings.TILE_SIZE);
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
    end,

    renderBackground = function(self)
        love.graphics.setColor(GameSettings.getDarkColor(1));
        love.graphics.rectangle("fill", GameSettings.TILE_SIZE,
                                GameSettings.TILE_SIZE,
                                self.levelW * GameSettings.TILE_SIZE,
                                self.levelH * GameSettings.TILE_SIZE);
        love.graphics.setColor(1, 1, 1);
    end
}

return Level

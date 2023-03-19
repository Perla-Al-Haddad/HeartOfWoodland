GameSettings = require('src.gameSettings')
Class = require('lib.hump.class')
ROT = require 'lib.rot.rot'

local Level = Class {
    init = function(self, levelW, levelH, world, player, Wall, Enemy,
                    WallManager, EnemyManager)
        self.map = {}
        
        self.levelW = levelW
        self.levelH = levelH
        self:generateLevelString()

        self.world = world
        self.player = player
        
        self.Wall = Wall
        self.Enemy = Enemy
        self.WallManager = WallManager
        self.EnemyManager = EnemyManager
        self.wallManager, self.enemyManager = self:processLevelString()
    end,

    generateLevelString = function(self)
        local function calbak(x, y, val)
            self.map[x .. ',' .. y] = val == 1 and '#' or '.'
        end

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

        local levelString = '';
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
            for y = 1, self.levelH do
                levelString = levelString ..
                                  (cl._map[x][y] == largest and '.' or '#');
            end
            levelString = levelString .. '\n'
        end
        self.levelString = levelString
    end,

    placePlayer = function(self)
        local key = nil
        while true do
            key = ROT.RNG:random(1, self.levelW) .. ',' ..
                      ROT.RNG:random(1, self.levelH)
            if map[key] == 0 then
                pos = key:split(',')
                player.x, player.y = tonumber(pos[1]), tonumber(pos[2])
                f:write('@', player.x, player.y)
                break
            end
        end
    end,

    processLevelString = function(self)
        local lineCount = 0;
        local columnCount = 0;
        local walls = {};
        local enemies = {};
        for block in self.levelString:gmatch "." do
            if block == '\n' then
                columnCount = -1;
                lineCount = lineCount + 1;
            elseif block == '#' then
                table.insert(walls,
                             self.Wall(columnCount * GameSettings.TILE_SIZE,
                                       lineCount * GameSettings.TILE_SIZE,
                                       self.world))
            elseif block == 'P' then
                self.player.positionX = columnCount * GameSettings.TILE_SIZE
                self.player.positionY = lineCount * GameSettings.TILE_SIZE
            elseif block == 'X' then
                table.insert(enemies,
                             self.Enemy(columnCount * GameSettings.TILE_SIZE,
                                        lineCount * GameSettings.TILE_SIZE,
                                        self.world))
            end
            columnCount = columnCount + 1;
        end
        local wallManager = self.WallManager(walls)
        local enemyManager = self.EnemyManager(enemies)
        return wallManager, enemyManager;
    end
}

return Level

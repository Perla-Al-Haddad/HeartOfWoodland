local Class = require("lib.hump.class")
local ROT = require("lib.rot.rot")

local conf = require("src.utils.conf")

local ForestGenerator = Class {
    init = function(self, width, height, enemyCount)
        self.map = {}
        self.width = width
        self.height = height
        self.enemyCount = enemyCount

        self:_generateLevelMap()
        -- self.map = {
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', 'P', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', 'E', '.', '.', '.', '#', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',},
        --     {'.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.','.','.','.','.','.','.','.','.','.','.',}
        -- }
        -- self.width = #self.map[1]
        -- self.height = #self.map

        self.boundaries = self:_initBoundaries()
    end,

    _printMap = function(self)
        for y = 1, self.height do
            for x = 1, self.width do
                local cell = self.map[x][y]
                io.write(cell .. " ")
            end
            print()
        end
    end,

    _initBoundaries = function(self)
        local boundaryWidth = 16;
        local leftBoundary = {
            x = conf.TILE_SIZE - boundaryWidth,
            y = conf.TILE_SIZE - boundaryWidth,
            w = boundaryWidth,
            h = self.height * conf.TILE_SIZE + boundaryWidth * 2
        }
        local rightBoundary = {
            x = (self.width + 1) * conf.TILE_SIZE,
            y = conf.TILE_SIZE - boundaryWidth,
            w = boundaryWidth,
            h = self.height * conf.TILE_SIZE + boundaryWidth * 2
        }
        local topBoundary = {
            x = conf.TILE_SIZE - boundaryWidth,
            y = conf.TILE_SIZE - boundaryWidth,
            w = self.width * conf.TILE_SIZE + boundaryWidth * 2,
            h = boundaryWidth
        }
        local bottomBoundary = {
            x = conf.TILE_SIZE - boundaryWidth,
            y = (self.height + 1) * conf.TILE_SIZE,
            w = self.width * conf.TILE_SIZE + boundaryWidth * 2,
            h = boundaryWidth
        }
        local boundaries = {
            leftBoundary, rightBoundary, topBoundary, bottomBoundary
        };
        return boundaries;
    end,

    _generateLevelMap = function(self)
        local function callback(x, y, val) end

        local function fillBlob(x, y, m, id)
            m[x][y] = id
            local todo = { { x, y } }
            local dirs = ROT.DIRS.EIGHT
            local size = 1
            repeat
                local pos = table.remove(todo, 1)
                for i = 1, #dirs do
                    local rx = pos[1] + dirs[i][1]
                    local ry = pos[2] + dirs[i][2]
                    if rx < 1 or rx > self.width or ry < 1 or ry > self.height then

                    elseif m[rx][ry] == 1 then
                        m[rx][ry] = id
                        table.insert(todo, { rx, ry })
                        size = size + 1
                    end
                end
            until #todo == 0
            return size
        end
        local cl = ROT.Map.Cellular:new(self.width, self.height)
        local rand = 0.535;
        cl:randomize(rand)
        cl:create(callback)

        local largest = 2;
        local id = 2;
        local largestCount = 0
        cl:randomize(rand)

        for i = 1, 20 do cl:create(callback) end
        for x = 1, self.width do
            for y = 1, self.height do
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

        for x = 1, self.width do
            self.map[x] = {}
            for y = 1, self.height do
                local block = (cl._map[x][y] == largest and '.' or '#')
                self.map[x][y] = block;
            end
        end

        self:_generateMisc()

        self:_placePlayer()
        for _ = 1, self.enemyCount do self:_placeEnemy() end

        -- self:_printMap()
    end,

    _generateMisc = function(self)
        for x = 1, self.width do
            for y = 1, self.height do
                local cell = self.map[x][y]
                if cell == '.' then
                    local g = math.random(1, 4)
                    local r = math.random(1, 40)
                    if g == 1 then
                        self.map[x][y] = 'g'
                    end
                    if r == 1 then
                        self.map[x][y] = 'r'
                    end
                    if self:_canAddBush(x, y) then
                        self:_placeEntity('b')
                    end
                end
            end
        end
    end,

    _canAddBush = function(self, row, col)
        local height = #self.map
        local width = #self.map[1]
    
        -- Check if the current tile is a wall
        if self.map[row][col] ~= '#' then
            return false
        end
    
        -- Check if the current tile is adjacent to an empty space
        local adjacent_tiles = {
            {row - 1, col},  -- Top
            {row + 1, col},  -- Bottom
            {row, col - 1},  -- Left
            {row, col + 1}   -- Right
        }

        for _, tile in ipairs(adjacent_tiles) do
            local r, c = tile[1], tile[2]
            if r >= 1 and r <= height and c >= 1 and c <= width and self.map[r][c] ~= '#' then
                return true
            end
        end
    end,

    _placePlayer = function(self) self:_placeEntity('P') end,

    _placeEnemy = function(self) self:_placeEntity('E') end,

    _placeEntity = function(self, c)
        while true do
            local y = ROT.RNG:random(1, self.height)
            local x = ROT.RNG:random(1, self.width)
            if self.map[x][y] == '.' then
                self.map[x][y] = c
                break
            end
        end
    end,
}

return ForestGenerator

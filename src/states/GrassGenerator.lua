local Class = require("lib.hump.class")

local GrassGenerator = Class {
    init = function(self, width, height)
        self.map = {}
        self.width = width
        self.height = height
        self.threshold = 0.8
        self.thresholdSmall = 0.7

        self:_generateGrassMap()
    end,

    _generateGrassMap = function(self)
        local baseX = 10000 * love.math.random()
        local baseY = 10000 * love.math.random()

        for y = 1, self.height do
            self.map[y] = {}
            for x = 1, self.width do
                self.map[y][x] = love.math.noise(baseX + .1 * x, baseY + .1 * y)
            end
        end
    end,

    _printMap = function(self)
        for y = 1, self.height do
            for x = 1, self.width do
                local cell = self.map[x][y]
                if cell > self.threshold then
                    io.write("l")
                else
                    io.write(" ")
                end
            end
            print()
        end
    end,

}

return GrassGenerator

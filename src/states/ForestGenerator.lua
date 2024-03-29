local push = require("lib.push")
local Class = require("lib.hump.class")
local windfield = require("lib.windfield")
local Gamestate = require("lib.hump.gamestate")

local UI = require("src.UI")
local ForestMapGenerator = require("src.states.ForestMapGenerator")
local LongGrassHandler = require("src.handlers.LongGrassHandler")
local EffectsHandler = require("src.handlers.EffectsHandler")
local EnemiesHandler = require("src.handlers.EnemiesHandler")
local ObjectsHandler = require("src.handlers.ObjectsHandler")
local GrassGenerator = require("src.states.GrassGenerator")
local DropsHandler = require("src.handlers.DropsHandler")
local Tree = require("src.objects.Tree")
local Bush = require("src.objects.Bush")
local Rock = require("src.objects.Rock")
local LongGrass = require("src.objects.LongGrass")
local Enemy = require("src.Enemy")
local GrassEffect = require("src.effects.GrassEffect")

local conf = require("src.utils.conf")
local fonts = require("src.utils.fonts")
local globalFuncs = require("src.utils.globalFuncs")
local funcs = require("src.utils.funcs")

MARGIN_X_MIN, MARGIN_X_MAX = -5, 5
MARGIN_Y_MIN, MARGIN_Y_MAX = -5, 5
BUSH_MARGIN_X_MIN, BUSH_MARGIN_X_MAX = -1, 1
BUSH_MARGIN_Y_MIN, BUSH_MARGIN_Y_MAX = -1, 1

local ForestGenerator = Class {
    init = function(self, width, height)
        self.width = width or 250
        self.height = height or 250
        self.collisionTileWidth = 24
        self.collisionTileHeight = 20
        self.enemyCount = 25

        self.ui = UI()
    end,

    initCoRoutine = function(self)
        return coroutine.create(function()
            coroutine.yield("Setting up map")
            self:_setupMap()

            coroutine.yield("Setting up grass map")
            self:_setupGrassMap()

            coroutine.yield("Setting up world")
            self:_setupWorld()

            coroutine.yield("Setting up handlers")
            self:_setHandlers()

            coroutine.yield("Setting up player")
            self:_setupPlayer()

            coroutine.yield("Setting up camera")
            self:_setupCamera()
            self:_setupShake()

            self.trees = {}
            self.bushes = {}
            self.colliderTrees = {}
            self.longGrassOnTop = {}
            self.onScreenLongGrass = {}

            coroutine.yield("Processing map")
            self:_processMapRoutine()

            if conf.MUSIC then audio.gameMusic:play() end
        end)
    end,

    update = function(self, dt)
        self.world:update(dt)
        self.player:updateAbs(dt, self.shake)
        self.camera:update(self.player);
        self.shake:update(dt)

        for _, tree in pairs(self.colliderTrees) do
            tree:update(self.camera)
        end

        for _, bush in pairs(self.bushes) do
            bush:update(self.camera)
        end

        self.handlers.enemies:updateEnemiesOnScreen(dt, self.camera)
        self.handlers.objects:updateObjectsOnScreen(dt, self.camera)
        self.handlers.effects:updateEffectsOnScreen(dt, self.camera)
        self.handlers.longGrass:updateOnScreen(dt, self.camera)
        self.handlers.drops:updateDrops(dt)

        self.longGrassOnTop = funcs.filter(self.handlers.longGrass.objects, function(v, k, t)
            return v.position == 'top'
        end)
        self.onScreenLongGrass = funcs.filter(self.handlers.longGrass.objects, function(v, k, t)
            return self.camera:isOnScreen(v.positionX, v.positionY)
        end)
    end,

    draw = function(self)
        push:start()
        self:_drawBackgroundColor()

        self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

        self:drawLevel()

        self.camera.camera:detach();

        self.ui:drawPlayerLife();

        if conf.DEBUG.SHOW_FPS then
            love.graphics.setFont(fonts.smaller)
            love.graphics.print(love.timer.getFPS(), 0, 0)
        end

        push:finish()
    end,

    keypressed = function(self, key)
        globalFuncs.keypressed(key)

        if key == 'h' or key == 'H' then
            self.player:useItem('sword', self.camera.camera)
        end
        if key == 'e' or key == 'E' then
            self.player:interact()
        end
        if key == "escape" then
            local pause = require("src.states.pause")
            Gamestate.switch(pause, self)
        end
        if key == "tab" then
            local mapPreview = require("src.states.mapPreview")
            Gamestate.switch(mapPreview, self)
        end
    end,

    drawLevel = function(self)
        self.handlers.effects:drawEffectsOnScreen(-1, self.camera)

        for _, tree in pairs(self.trees) do
            if self.camera:isOnScreen(tree.positionX, tree.positionY) then
                tree:drawBottom()
                if not tree.wasSeen then
                    tree.wasSeen = true
                end
            end
        end
        for _, bush in pairs(self.bushes) do
            if self.camera:isOnScreen(bush.positionX, bush.positionY) then
                bush:draw()
            end
        end

        self.handlers.drops:drawDrops()

        for i, grass in pairs(self.onScreenLongGrass) do
            grass:drawTop()
            grass:drawBottom()
        end

        self.handlers.objects:drawObjectsOnScreen(self.camera)
        self.handlers.enemies:drawEnemiesOnScreen(self.camera)

        self.player:drawAbs();

        self.handlers.effects:drawEffects(0)

        for i, grass in pairs(self.longGrassOnTop) do
            grass:drawTop()
        end

        for _, tree in pairs(self.trees) do
            if self.camera:isOnScreen(tree.positionX, tree.positionY) then
                tree:drawTop()
            end
        end

        if conf.DEBUG.DRAW_WORLD then
            self.world:draw()
        end
    end,

    _drawBackgroundColor = function(self)
        love.graphics.setColor(80 / 255, 155 / 255, 102 / 255);
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
        love.graphics.setColor(1, 1, 1);
    end,

    _shouldCreateCollider = function(self, matrix, row, col)
        local height = #matrix
        local width = #matrix[1]
        -- Check if the current tile is a wall
        if matrix[row][col] ~= '#' then
            return false
        end
        -- Check if the current tile is adjacent to an empty space
        local adjacent_tiles = {
            { row - 1, col },     -- Top
            { row + 1, col },     -- Bottom
            { row,     col - 1 }, -- Left
            { row,     col + 1 }  -- Right
        }
        for _, tile in ipairs(adjacent_tiles) do
            local r, c = tile[1], tile[2]
            if r >= 1 and r <= height and c >= 1 and c <= width and matrix[r][c] ~= '#' then
                return true
            end
        end
        return false
    end,

    _setupShake = function(self)
        self.shake = Shake(self.camera.camera);
    end,

    _setupPlayer = function(self)
        self.player = Player(0, 0, self.world, self.handlers)
    end,

    _setupCamera = function(self)
        self.camera = Camera(conf.CAMERA.SCALE,
            self.player.hurtCollider:getX(), self.player.hurtCollider:getY(),
            self.map.width, self.map.height - 2,
            self.collisionTileWidth, self.collisionTileHeight);
    end,

    _setupMap = function(self)
        self.map = ForestMapGenerator(self.width, self.height, self.enemyCount)
    end,

    _setupGrassMap = function(self)
        self.grassMap = GrassGenerator(self.width, self.height)
    end,

    _setupWorld = function(self)
        self.world = windfield.newWorld(0, 0, false);
        self.world:addCollisionClass('Ignore', { ignores = { 'Ignore' } });
        self.world:addCollisionClass('Dead', { ignores = { 'Ignore' } });
        self.world:addCollisionClass('Wall', { ignores = { 'Ignore' } });
        self.world:addCollisionClass('Objects', { ignores = { 'Ignore' } });
        self.world:addCollisionClass('Trees', { ignores = { 'Ignore' } });
        self.world:addCollisionClass('Drops', { ignores = { 'Ignore', "Dead" } });
        self.world:addCollisionClass('EnemyHurt', { ignores = { 'Ignore', "Drops" } });
        self.world:addCollisionClass('Player', { ignores = { 'Ignore', "EnemyHurt" } });
        self.world:addCollisionClass('EnemyHit', { ignores = { 'Ignore', "EnemyHurt", "Drops" } });
        self.world:addCollisionClass('LongGrass',
            { ignores = { 'Ignore', "EnemyHurt", "EnemyHit", "Player", "Dead", "LongGrass" } });
        self.world:addCollisionClass('LevelTransition',
            { ignores = { 'Ignore', "EnemyHurt", "Drops", "Objects", "Wall", "EnemyHit", "Dead" } });
    end,

    _setHandlers = function(self)
        self.handlers = {
            effects = EffectsHandler(),
            drops = DropsHandler(),
            enemies = EnemiesHandler(),
            objects = ObjectsHandler(),
            longGrass = LongGrassHandler()
        }
    end,

    _processMapRoutine = function(self)
        for y = 1, self.map.height do
            for x = 1, self.map.width do
                local cell = self.map.map[x][y]
                local grassCell = self.grassMap.map[x][y]
                if cell == "#" then
                    self:_processTreeCell(x, y)
                elseif cell == "P" then
                    self:_spawnPlayer(x, y)
                elseif cell == 'g' then
                    self:_processGrassCell(x, y)
                elseif cell == 'r' then
                    self:_processRockCell(x, y)
                elseif cell == 'E' then
                    self:_processEnemyCell(x, y)
                end
                if grassCell > self.grassMap.threshold and cell ~= "#" and cell ~= 'r' then
                    local status, err = pcall(self._processLongGrassCell, self, x, y, false)
                    if not status then
                        print(debug.traceback())
                        print(err)
                    end
                elseif grassCell < self.grassMap.threshold and grassCell > self.grassMap.thresholdSmall and cell ~= "#" and cell ~= 'r' then
                    local status, err = pcall(self._processLongGrassCell, self, x, y, true)
                    if not status then
                        print(debug.traceback())
                        print(err)
                    end
                end
            end
            coroutine.yield("Processing map")
        end
        self:_sortTreesByYAxis()
        self:_setColliderTrees()
    end,

    _setColliderTrees = function(self)
        self.colliderTrees = funcs.filter(self.trees, function(v, k, t)
            return v.hasCollider
        end)
    end,

    _sortTreesByYAxis = function(self)
        table.sort(self.trees, function(a, b)
            return a.positionYDisplay < b.positionYDisplay
        end)
        table.sort(self.colliderTrees, function(a, b)
            return a.positionYDisplay < b.positionYDisplay
        end)
        table.sort(self.bushes, function(a, b)
            return a.positionYDisplay < b.positionYDisplay
        end)
    end,

    _processTreeCell = function(self, x, y)
        local shouldCollider = self:_shouldCreateCollider(self.map.map, x, y)
        local tree = Tree(
            (x - 1) * self.collisionTileWidth,
            (y - 1) * self.collisionTileHeight,
            math.random(MARGIN_X_MIN, MARGIN_X_MAX),
            math.random(MARGIN_Y_MIN, MARGIN_Y_MAX),
            24, 20, self.world, shouldCollider)
        if shouldCollider then
            local bushOrTree = math.random(8)
            if bushOrTree == 1 then
                local bush = Bush(
                    (x - 1) * self.collisionTileWidth,
                    (y - 1) * self.collisionTileHeight,
                    math.random(BUSH_MARGIN_X_MIN, BUSH_MARGIN_X_MAX),
                    math.random(BUSH_MARGIN_Y_MIN, BUSH_MARGIN_Y_MAX),
                    32, 32, self.world)
                table.insert(self.bushes, bush)
            else
                table.insert(self.trees, tree)
            end
        else
            local t = math.random(2)
            if t ~= 1 then
                table.insert(self.trees, tree)
            end
        end
    end,

    _spawnPlayer = function(self, x, y)
        self.player.hurtCollider:setX((x - 1) * (self.collisionTileWidth))
        self.player.hurtCollider:setY((y - 1) * (self.collisionTileHeight))
    end,

    _processGrassCell = function(self, x, y)
        local t = (math.random(#conf.GRASS_MAPPING))
        self.handlers.effects:addEffect(GrassEffect(
            (x - 1) * (self.collisionTileWidth),
            (y - 1) * (self.collisionTileHeight),
            conf.GRASS_MAPPING[t]))
    end,

    _processRockCell = function(self, x, y)
        self.handlers.objects:addObject(Rock(
            (x - 1) * (self.collisionTileWidth),
            (y - 1) * (self.collisionTileHeight),
            self.world
        ))
    end,

    _processEnemyCell = function(self, x, y)
        self.handlers.enemies:addEnemy(
            Enemy(
                (x - 1) * (self.collisionTileWidth),
                (y - 1) * (self.collisionTileHeight),
                32, 32, 60, 5, 5, 10, 10, 3,
                '/assets/sprites/characters/slime.png',
                self.world, self.handlers.drops
            )
        )
    end,

    _processLongGrassCell = function(self, x, y, isSmall)
        local grass = LongGrass(
            (x - 1) * (self.collisionTileWidth),
            (y - 1) * (self.collisionTileHeight),
            27, 25, 27, 10, isSmall, self.world
        )

        self.handlers.longGrass:add(grass)
    end
}

return ForestGenerator

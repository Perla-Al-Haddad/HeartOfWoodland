local push = require("lib.push")
local windfield = require("lib.windfield")
local Gamestate = require("lib.hump.gamestate")

local ForestGenerator = require("src.states.ForestGenerator")
local EffectsHandler = require("src.handlers.EffectsHandler")
local EnemiesHandler = require("src.handlers.EnemiesHandler")
local ObjectsHandler = require("src.handlers.ObjectsHandler")
local DropsHandler = require("src.handlers.DropsHandler")
local Tree = require("src.objects.Tree")
local Bush = require("src.objects.Bush")
local Rock = require("src.objects.Rock")
local Enemy = require("src.Enemy")
local GrassEffect = require("src.effects.GrassEffect")

local conf = require("src.utils.conf")
local globalFuncs = require("src.utils.globalFuncs")
local funcs = require("src.utils.funcs")

MARGIN_X_MIN, MARGIN_X_MAX = -5, 5
MARGIN_Y_MIN, MARGIN_Y_MAX = -5, 5
BUSH_MARGIN_X_MIN, BUSH_MARGIN_X_MAX = -1, 1
BUSH_MARGIN_Y_MIN, BUSH_MARGIN_Y_MAX = -1, 1

local minimapScale = 1.75

-- 200 155
local forest = { trees = {}, bushes = {}, width = 100, height = 55 }


function forest:_drawBackgroundColor()
    love.graphics.setColor(80 / 255, 155 / 255, 102 / 255);
    love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
    love.graphics.setColor(1, 1, 1);
end

function forest:_shouldCreateCollider(matrix, row, col)
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
end

function forest:enter()
    self.world = windfield.newWorld(0, 0, false);
    self.world:addCollisionClass('Ignore', { ignores = { 'Ignore' } });
    self.world:addCollisionClass('Dead', { ignores = { 'Ignore' } });
    self.world:addCollisionClass('Wall', { ignores = { 'Ignore' } });
    self.world:addCollisionClass('Objects', { ignores = { 'Ignore' } });
    self.world:addCollisionClass('Drops', { ignores = { 'Ignore', "Dead" } });
    self.world:addCollisionClass('EnemyHurt', { ignores = { 'Ignore', "Drops" } });
    self.world:addCollisionClass('Player', { ignores = { 'Ignore', "EnemyHurt" } });
    self.world:addCollisionClass('EnemyHit', { ignores = { 'Ignore', "EnemyHurt", "Drops" } });
    self.world:addCollisionClass('LevelTransition',
        { ignores = { 'Ignore', "EnemyHurt", "Drops", "Objects", "Wall", "EnemyHit", "Dead" } });

    self.level = ForestGenerator(self.width, self.height, 10)

    self.tileWidth = 32
    self.tileHeight = 64
    self.collisionTileWidth = 24
    self.collisionTileHeight = 20

    self.handlers = {
        effects = EffectsHandler(),
        drops = DropsHandler(),
        enemies = EnemiesHandler(),
        objects = ObjectsHandler()
    }

    self.player = Player(100, 100, self.world, self.handlers)
    self.camera = Camera(conf.CAMERA.SCALE,
        self.player.hurtCollider:getX(), self.player.hurtCollider:getY(),
        self.level.width, self.level.height - 2,
        self.collisionTileWidth, self.collisionTileHeight);
    self.shake = Shake(self.camera.camera);

    for y = 1, self.level.height do
        for x = 1, self.level.width do
            local cell = self.level.map[x][y]
            if cell == "#" then
                local shouldCollider = self:_shouldCreateCollider(self.level.map, x, y)
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
            elseif cell == "P" then
                self.player.hurtCollider:setX((x - 1) * (self.collisionTileWidth))
                self.player.hurtCollider:setY((y - 1) * (self.collisionTileHeight))
            elseif cell == 'g' then
                local t = (math.random(#conf.GRASS_MAPPING))
                self.handlers.effects:addEffect(GrassEffect(
                    (x - 1) * (self.collisionTileWidth),
                    (y - 1) * (self.collisionTileHeight),
                    conf.GRASS_MAPPING[t]))
            elseif cell == 'r' then
                self.handlers.objects:addObject(Rock(
                    (x - 1) * (self.collisionTileWidth),
                    (y - 1) * (self.collisionTileHeight),
                    self.world
                ))
            elseif cell == 'E' then
                self.handlers.enemies:addEnemy(
                    Enemy(
                        (x - 1) * (self.collisionTileWidth),
                        (y - 1) * (self.collisionTileHeight),
                        32, 32, 60, 5, 5, 10, 10, 3,
                        '/assets/sprites/characters/slime.png',
                        self.world, self.handlers.drops
                    )
                )
            end
        end
    end

    self.colliderTrees = funcs.filter(self.trees, function(v, k, t)
        return v.hasCollider
    end)

    table.sort(self.trees, function(a, b)
        return a.positionYDisplay < b.positionYDisplay
    end)
end

function forest:update(dt)
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
    self.handlers.objects:updateObjects(dt)
    self.handlers.effects:updateEffects(dt)
    self.handlers.drops:updateDrops(dt)
end

function forest:draw()
    push:start()
    self:_drawBackgroundColor()

    self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

    self.handlers.effects:drawEffects(-1)
    self.handlers.objects:drawObjects()

    for _, tree in pairs(self.trees) do
        if self.camera:isOnScreen(tree.positionX, tree.positionY) then
            tree:drawBottom()
        end
    end
    for _, bush in pairs(self.bushes) do
        if self.camera:isOnScreen(bush.positionX, bush.positionY) then
            bush:draw()
        end
    end

    self.handlers.enemies:drawEnemies()
    self.handlers.drops:drawDrops()

    self.player:drawAbs();

    self.handlers.effects:drawEffects(0)

    for _, tree in pairs(self.trees) do
        if self.camera:isOnScreen(tree.positionX, tree.positionY) then
            tree:drawTop()
        end
    end

    if conf.DEBUG.DRAW_WORLD then
        self.world:draw()
    end
    self.camera.camera:detach();

    love.graphics.translate(conf.gameWidth - self.width / minimapScale - 5, 5)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, self.width / minimapScale, self.height / minimapScale)

    local px, py = self.player:getSpriteTopPosition()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", px / self.collisionTileWidth / minimapScale,
        py / self.collisionTileHeight / minimapScale, 2, 2)

    love.graphics.setColor(1, 1, 1, 0.5)
    for _, tree in pairs(self.trees) do
        love.graphics.rectangle("fill", tree.positionX / self.collisionTileWidth / minimapScale,
            tree.positionY / self.collisionTileHeight / minimapScale, 1, 1)
    end

    love.graphics.translate(0, 0)

    push:finish()
end

function forest:keypressed(key)
    globalFuncs.keypressed(key)

    if key == 'h' or key == 'H' then
        self.player:useItem('sword', self.camera.camera)
    end
    if key == 'e' or key == 'E' then
        self.player:interact()
    end
    if key == "escape" then
        local pause = require("src.states.pause")
        Gamestate.switch(pause, self.camera, self.gameMap, self.player)
    end
end

return forest

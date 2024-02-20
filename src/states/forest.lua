local push = require("lib.push")
local windfield = require("lib.windfield")
local Gamestate = require("lib.hump.gamestate")

local ForestGenerator = require("src.states.ForestGenerator")
local EffectsHandler = require("src.handlers.EffectsHandler")
local EnemiesHandler = require("src.handlers.EnemiesHandler")
local ObjectsHandler = require("src.handlers.ObjectsHandler")
local DropsHandler = require("src.handlers.DropsHandler")
local Tree = require("src.objects.Tree")
local Rock = require("src.objects.Rock")
local Enemy = require("src.Enemy")
local GrassEffect = require("src.effects.GrassEffect")

local conf = require("src.utils.conf")
local globalFuncs = require("src.utils.globalFuncs")

MARGIN_X_MIN, MARGIN_X_MAX = 0, 0
MARGIN_Y_MIN, MARGIN_Y_MAX = 0, 1

local forest = {
    trees = {}
}

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
        {row - 1, col},  -- Top
        {row + 1, col},  -- Bottom
        {row, col - 1},  -- Left
        {row, col + 1}   -- Right
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

    self.level = ForestGenerator(60, 45, 10)

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
        self.collisionTileWidth + MARGIN_X_MAX, self.collisionTileHeight);
    self.shake = Shake(self.camera.camera);

    for y = 1, self.level.height do
        for x = 1, self.level.width do
            local cell = self.level.map[x][y]
            if cell == "#" then
                local tree = Tree(
                    (x - 1) * (self.collisionTileWidth + math.random(MARGIN_X_MIN, MARGIN_X_MAX)),
                    (y - 1) * self.collisionTileHeight,
                    24, 20, self.world, self:_shouldCreateCollider(self.level.map, x, y))
                table.insert(self.trees, tree)
            elseif cell == "P" then
                self.player.hurtCollider:setX((x - 1) * (self.collisionTileWidth + MARGIN_X_MAX))
                self.player.hurtCollider:setY((y - 1) * (self.collisionTileHeight))
            elseif cell == 'g' then
                local t = (math.random(#conf.GRASS_MAPPING))
                self.handlers.effects:addEffect(GrassEffect(
                    (x - 1) * (self.collisionTileWidth + MARGIN_X_MAX),
                    (y - 1) * (self.collisionTileHeight),
                    conf.GRASS_MAPPING[t]))
            elseif cell == 'r' then
                self.handlers.objects:addObject(Rock(
                    (x - 1) * (self.collisionTileWidth + MARGIN_X_MAX),
                    (y - 1) * (self.collisionTileHeight),
                    self.world
                ))
            elseif cell == 'E' then
                self.handlers.enemies:addEnemy(
                    Enemy(
                        (x - 1) * (self.collisionTileWidth + MARGIN_X_MAX),
                        (y - 1) * (self.collisionTileHeight),
                        32, 32, 60, 5, 5, 10, 10, 3,
                        '/assets/sprites/characters/slime.png',
                        self.world, self.handlers.drops
                    )
                )
            end
        end
    end
end

function forest:update(dt)
    self.world:update(dt)
    self.player:updateAbs(dt, self.shake)
    self.camera:update(self.player);
    self.shake:update(dt)

    self.handlers.enemies:updateEnemies(dt)
    self.handlers.objects:updateObjects(dt)
    self.handlers.effects:updateEffects(dt)
    self.handlers.drops:updateDrops(dt)
end

function forest:draw()
    push:start()
    self:_drawBackgroundColor()

    self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

    self.handlers.effects:drawEffects(-1)
    for _, tree in pairs(self.trees) do
        tree:drawBottom()
    end

    self.handlers.enemies:drawEnemies();
    self.handlers.objects:drawObjects()
    self.handlers.drops:drawDrops()

    self.player:drawAbs();

    self.handlers.effects:drawEffects(0)

    for _, tree in pairs(self.trees) do
        tree:drawTop()
    end

    if conf.DEBUG.DRAW_WORLD then
        self.world:draw()
    end
    self.camera.camera:detach();

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

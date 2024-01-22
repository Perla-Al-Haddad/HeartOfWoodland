TILE_SIZE = 16;
CAMERA_SCALE = 3;

local sti = require("lib/sti/sti");
local windfield = require("lib/windfield");

local Player = require("src.Player");
local Camera = require("src.Camera");
local Wall = require("src.Wall");
local EffectsHandler = require("src.EffectsHandler");
local EnemiesHandler = require("src.EnemiesHandler");
local Enemy = require("src.Enemy");

local settings = require("src.utils.settings")

function love.load()
    love.graphics.setBackgroundColor(26 / 255, 26 / 255, 26 / 255);
    love.window.setMode(0, 0, {fullscreen = false});
    love.graphics.setDefaultFilter("nearest", "nearest");

    world = windfield.newWorld(0, 0, false);

    player = Player(TILE_SIZE * 30, TILE_SIZE * 30, 32, 32, 140, 12, 12, 10, world);
    enemy = Enemy(TILE_SIZE * 32, TILE_SIZE * 32, 32, 32, 60, 10, 9, 2, '/assets/sprites/characters/slime.png', world);
    enemy2 = Enemy(TILE_SIZE * 30, TILE_SIZE * 34, 32, 32, 60, 10, 9, 2, '/assets/sprites/characters/slime.png', world);

    enemiesHandler = EnemiesHandler()
    enemiesHandler:addEnemy(enemy)
    enemiesHandler:addEnemy(enemy2)

    camera =
        Camera(CAMERA_SCALE, player.collider:getX(), player.collider:getY());

    gameMap = sti("maps/village/village.lua");

    effectsHandler = EffectsHandler()

    if gameMap.layers["walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = Wall(obj.x, obj.y, obj.width, obj.height, world);
        end
    end
end

function love.update(dt)
    world:update(dt);
    player:updateAbs(dt, effectsHandler, enemiesHandler);
    enemiesHandler:updateEnemies(dt)
    camera:update(dt, player, gameMap);
    gameMap:update(dt);
    effectsHandler:updateEffects(dt);
end

function love.draw()
    love.graphics.setColor(1, 1, 1);

    camera.camera:attach();

    gameMap:drawLayer(gameMap.layers["ground"]);
    gameMap:drawLayer(gameMap.layers["mountains"]);
    gameMap:drawLayer(gameMap.layers["walls"]);
    gameMap:drawLayer(gameMap.layers["decor"]);

    enemiesHandler:drawEnemies()
    player:drawAbs();
    effectsHandler:drawEffects(0);

    gameMap:drawLayer(gameMap.layers["upperWalls"]);

    if settings.DRAW_WORLD then
        world:draw();
    end

    camera.camera:detach();
end

function love.keypressed(key) if key == "escape" then love.event.quit(); end end

function love.mousepressed(x, y, button)
    if button == 1 then player:useItem('sword', camera.camera) end
end

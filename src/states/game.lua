TILE_SIZE = 16;
CAMERA_SCALE = 3;

local sti = require("lib/sti/sti");
local windfield = require("lib/windfield");
local sone = require("lib.sone.sone")

local Player = require("src.Player");
local Camera = require("src.Camera");
local Wall = require("src.Wall");
local EffectsHandler = require("src.EffectsHandler");
local EnemiesHandler = require("src.EnemiesHandler");
local ObjectsHandler = require("src.ObjectsHandler");
local DropsHandler = require("src.DropsHandler");
local Enemy = require("src.Enemy");
local Chest = require("src.Chest");
local UI = require("src.UI");

local Shake = require("src.utils.Shake");
local conf = require("src.utils.conf");
local audio = require("src.utils.audio");

local game = {}


function game:enter()
    opacity = 1;
    windowWidth, windowHeight = love.graphics:getWidth(), love.graphics:getHeight()

    if conf.music then audio.gameMusic:play() end

    love.graphics.print("Press Enter to continue", 10, 10)

    world = windfield.newWorld(0, 0, false);

    world:addCollisionClass('Ignore', {ignores = {'Ignore'}});
    world:addCollisionClass('Dead', {ignores = {'Ignore'}});
    world:addCollisionClass('Wall', {ignores = {'Ignore'}});
    world:addCollisionClass('Objects', {ignores = {'Ignore'}});
    world:addCollisionClass('Drops', {ignores = {'Ignore', "Dead"}});
    world:addCollisionClass('EnemyHurt', {ignores = {'Ignore', "Drops"}});
    world:addCollisionClass('Player', {ignores = {'Ignore', "EnemyHurt"}});
    world:addCollisionClass('EnemyHit', {ignores = {'Ignore', "EnemyHurt", "Drops"}});
    
    effectsHandler = EffectsHandler();
    dropsHandler = DropsHandler(); 
    enemiesHandler = EnemiesHandler();
    objectsHandler = ObjectsHandler();

    handlers = {
        effects = effectsHandler,
        drops = dropsHandler,
        enemies = enemiesHandler,
        objects = objectsHandler
    }

    player = Player(TILE_SIZE * 30, TILE_SIZE * 30, 32, 32, 140, 12, 12, 10, world, handlers);
    ui = UI()
    
    camera = Camera(CAMERA_SCALE, player.hurtCollider:getX(), player.hurtCollider:getY());
    shake = Shake(camera.camera);

    gameMap = sti("/maps/village/village.lua");
    if gameMap.layers["walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            Wall(obj.x, obj.y, obj.width, obj.height, world);
        end
    end

    if gameMap.layers["Enemies"] then
        for i, obj in pairs(gameMap.layers["Enemies"].objects) do
            enemy = Enemy(obj.x, obj.y, 32, 32, 60, 5, 5, 10, 10, 3, '/assets/sprites/characters/slime.png', world, dropsHandler);
            enemiesHandler:addEnemy(enemy);
        end
    end

    chest = Chest(TILE_SIZE * 35, TILE_SIZE * 8, 16, 16, world);
    objectsHandler:addObject(chest);
end


function game:update(dt)
    if opacity > 0 then opacity = opacity - 0.005 end;

    world:update(dt);
    player:updateAbs(dt, shake);
    camera:update(dt, player, gameMap);
    shake:update(dt);
    gameMap:update(dt);
    enemiesHandler:updateEnemies(dt);
    objectsHandler:updateObjects(dt);
    effectsHandler:updateEffects(dt);
    dropsHandler:updateDrops(dt);
end


function game:draw()
    love.graphics.setColor(1, 1, 1);

    camera.camera:attach();

    gameMap:drawLayer(gameMap.layers["ground"]);
    gameMap:drawLayer(gameMap.layers["mountains"]);
    gameMap:drawLayer(gameMap.layers["walls"]);
    gameMap:drawLayer(gameMap.layers["decor"]);

    enemiesHandler:drawEnemies();
    effectsHandler:drawEffects(-1);
    objectsHandler:drawObjects();
    dropsHandler:drawDrops();
    player:drawAbs();
    effectsHandler:drawEffects(0);

    gameMap:drawLayer(gameMap.layers["upperWalls"]);

    if conf.DEBUG.DRAW_WORLD then
        world:draw();
    end

    camera.camera:detach();

    love.graphics.scale(4, 4)
    ui:drawPlayerLife(player);

    love.graphics.setColor(0, 0, 0, opacity);
    love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
end

function game:mousepressed(x, y, button)
    if button == 1 then player:useItem('sword', camera.camera) end
end

function game:keypressed(key)
    if key == 'e' or key == 'E' then
        player:interact()
    end
end

return game
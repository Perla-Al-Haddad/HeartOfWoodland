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
local settings = require("src.utils.settings");
local audio = require("src.utils.audio");
local settings = require("src.utils.settings");

local game = {}


function game:enter()
    if settings.music then audio.gameMusic:play() end

    love.graphics.print("Press Enter to continue", 10, 10)

    world = windfield.newWorld(0, 0, false);

    world:addCollisionClass('Ignore', {ignores = {'Ignore'}});
    world:addCollisionClass('EnemyHurt', {ignores = {'Ignore'}});
    world:addCollisionClass('Dead', {ignores = {'Ignore'}});
    world:addCollisionClass('Wall', {ignores = {'Ignore'}});
    world:addCollisionClass('Chest', {ignores = {'Ignore'}});
    world:addCollisionClass('Drops', {ignores = {'Ignore'}});
    world:addCollisionClass('Player', {ignores = {'Ignore', "EnemyHurt"}});
    world:addCollisionClass('EnemyHit', {ignores = {'Ignore', "EnemyHurt"}});
    
    effectsHandler = EffectsHandler();
    dropsHandler = DropsHandler(); 
    enemiesHandler = EnemiesHandler();

    player = Player(TILE_SIZE * 30, TILE_SIZE * 30, 32, 32, 140, 12, 12, 10, world, dropsHandler);
    chest = Chest(TILE_SIZE * 35, TILE_SIZE * 8, 16, 16, world);
    ui = UI()

    camera = Camera(CAMERA_SCALE, player.hurtCollider:getX(), player.hurtCollider:getY());
    shake = Shake(camera.camera);

    gameMap = sti("/maps/village/village.lua");
    if gameMap.layers["walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            Wall(obj.x, obj.y, obj.width, obj.height, world);
        end
    end

    chestHandler = ObjectsHandler();
    chestHandler:addObject(chest);

    if gameMap.layers["Enemies"] then
        for i, obj in pairs(gameMap.layers["Enemies"].objects) do
            enemy = Enemy(obj.x, obj.y, 32, 32, 60, 5, 5, 10, 10, 3, '/assets/sprites/characters/slime.png', world, dropsHandler);
            enemiesHandler:addEnemy(enemy);
        end
    end

end


function game:update(dt)
    world:update(dt);
    player:updateAbs(dt, effectsHandler, enemiesHandler, shake);
    camera:update(dt, player, gameMap);
    shake:update(dt);
    gameMap:update(dt);
    enemiesHandler:updateEnemies(dt);
    chestHandler:updateObjects(dt);
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
    chestHandler:drawObjects();
    dropsHandler:drawDrops();
    player:drawAbs();
    effectsHandler:drawEffects(0);

    gameMap:drawLayer(gameMap.layers["upperWalls"]);

    if settings.DEBUG.DRAW_WORLD then
        world:draw();
    end

    camera.camera:detach();

    love.graphics.scale(4, 4)
    ui:drawPlayerLife(player);
end

function game:mousepressed(x, y, button)
    if button == 1 then player:useItem('sword', camera.camera) end
end

function game:keypressed(key)
    if key == 'e' or key == 'E' then
        player:interact(chestHandler)
    end
end

return game
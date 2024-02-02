local CAMERA_SCALE = 1;

local sti = require("lib/sti/sti");
local windfield = require("lib/windfield");
local push = require("lib.push");
local Gamestate = require("lib.hump.gamestate"); 

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
local funcs = require("src.utils.funcs");
local conf = require("src.utils.conf");
local audio = require("src.utils.audio");
local globalFuncs = require("src.utils.globalFuncs");

local forestLevel = {}
local world, opacity, player, ui, camera, shake, gameMap;

local entitesNull = true


function forestLevel:initEntities()
    entitesNull = false

    world = windfield.newWorld(0, 0, false);
    opacity = 1;

    world:addCollisionClass('Ignore', {ignores = {'Ignore'}});
    world:addCollisionClass('Dead', {ignores = {'Ignore'}});
    world:addCollisionClass('Wall', {ignores = {'Ignore'}});
    world:addCollisionClass('Objects', {ignores = {'Ignore'}});
    world:addCollisionClass('Drops', {ignores = {'Ignore', "Dead"}});
    world:addCollisionClass('EnemyHurt', {ignores = {'Ignore', "Drops"}});
    world:addCollisionClass('Player', {ignores = {'Ignore', "EnemyHurt"}});
    world:addCollisionClass('EnemyHit', {ignores = {'Ignore', "EnemyHurt", "Drops"}});

    local effectsHandler, dropsHandler, enemiesHandler,
    objectsHandler, handlers;

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

    gameMap = sti("/maps/forest/forest.lua");
    for i, tileLayer in ipairs(gameMap.tileInstances) do
        for _, tile in ipairs(tileLayer) do
            print(tile.layer.name)
        end
    end

    if gameMap.layers["Player"] then
        for _, obj in pairs(gameMap.layers["Player"].objects) do
            player = Player(obj.x, obj.y, 32, 32, 140, 12, 12, 10, world, handlers);
        end
    end

    ui = UI()

    camera = Camera(CAMERA_SCALE, player.hurtCollider:getX(), player.hurtCollider:getY());
    shake = Shake(camera.camera);

    if gameMap.layers["Walls"] then
        for _, obj in pairs(gameMap.layers["Walls"].objects) do
            Wall(obj.x, obj.y, obj.width, obj.height, world);
        end
    end

    if gameMap.layers["Enemies"] then
        for i, obj in pairs(gameMap.layers["Enemies"].objects) do
            local enemy = Enemy(obj.x, obj.y, 32, 32, 60, 5, 5, 10, 10, 3, '/assets/sprites/characters/slime.png', world, dropsHandler);
            enemiesHandler:addEnemy(enemy);
        end
    end

end


function forestLevel:enter()
    if conf.MUSIC then audio.gameMusic:play() end
    if entitesNull then
        forestLevel:initEntities()
    end
end


function forestLevel:update(dt)
    if opacity > 0 then opacity = opacity - dt end;

    world:update(dt);
    player:updateAbs(dt, shake);
    camera:update(dt, player, gameMap);
    shake:update(dt);
    gameMap:update(dt);
    player._handlers.enemies:updateEnemies(dt);
    player._handlers.objects:updateObjects(dt);
    player._handlers.effects:updateEffects(dt);
    player._handlers.drops:updateDrops(dt);
end


function forestLevel:draw()
    push:start()

    love.graphics.setColor(1, 1, 1);

    camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

    for _, layer in ipairs(gameMap.layers) do
		if layer.visible and layer.opacity > 0 then
            if layer.name == "Player" then
                player._handlers.enemies:drawEnemies();
                player._handlers.effects:drawEffects(-1);
                player._handlers.objects:drawObjects();
                player._handlers.drops:drawDrops();
                player:drawAbs();
                player._handlers.effects:drawEffects(0);
            else
                if layer.type == "tilelayer" then
                    gameMap:drawLayer(layer)
                end
            end 
		end
	end

    if conf.DEBUG.DRAW_WORLD then
        world:draw();
    end

    camera.camera:detach();

    ui:drawPlayerLife(player);

    love.graphics.setColor(0, 0, 0, opacity);
    love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)

    push:finish()
end

function forestLevel:mousepressed(x, y, button)
    if button == 1 then player:useItem('sword', camera.camera) end
end

function forestLevel:keypressed(key)
    globalFuncs.keypressed(key)

    if key == 'e' or key == 'E' then
        player:interact()
    end
    if key == "escape" then
        local pause = require("src.states.pause")
        Gamestate.switch(pause, camera, gameMap, player)
    end
end

return forestLevel
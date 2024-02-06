local CAMERA_SCALE = 1;

local sti = require("lib/sti/sti");
local windfield = require("lib/windfield");
local push = require("lib.push");
local Gamestate = require("lib.hump.gamestate");
local tlfres = require("lib.tlfres");

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
local game = require("src.states.levels.game");

local Shake = require("src.utils.Shake");
local conf = require("src.utils.conf");
local funcs = require("src.utils.funcs");
local audio = require("src.utils.audio");
local globalFuncs = require("src.utils.globalFuncs");

local level = {name=funcs.get_file_name(debug.getinfo(1,'S').source)}
local world, opacity, player, ui, camera, shake, gameMap, playerLayer, handlers;

local entitesNull = true

function level:spawnPlayer(cameFrom)
    if not playerLayer then return end
    for _, obj in pairs(playerLayer.objects) do
        if obj.properties.cameFrom == cameFrom then
            player = Player(obj.x, obj.y, world, handlers);
            break
        end
    end
end

function level:initEntities(cameFrom)
    entitesNull = false

    world = windfield.newWorld(0, 0, false);
    opacity = 1;

    world:addCollisionClass('Ignore', { ignores = { 'Ignore' } });
    world:addCollisionClass('Dead', { ignores = { 'Ignore' } });
    world:addCollisionClass('Wall', { ignores = { 'Ignore' } });
    world:addCollisionClass('Objects', { ignores = { 'Ignore' } });
    world:addCollisionClass('Drops', { ignores = { 'Ignore', "Dead" } });
    world:addCollisionClass('EnemyHurt', { ignores = { 'Ignore', "Drops" } });
    world:addCollisionClass('Player', { ignores = { 'Ignore', "EnemyHurt" } });
    world:addCollisionClass('EnemyHit', { ignores = { 'Ignore', "EnemyHurt", "Drops" } });
    world:addCollisionClass('LevelTransition', { ignores = { 'Ignore', "EnemyHurt", "Drops", "Objects", "Wall", "EnemyHit", "Dead" } });

    handlers = {
        effects = EffectsHandler(),
        drops = DropsHandler(),
        enemies = EnemiesHandler(),
        objects = ObjectsHandler()
    }

    gameMap = sti("/maps/" .. level.name .. "/" .. level.name .. ".lua");
    playerLayer = gameMap.layers["Player"]
    local enemiesLayer = gameMap.layers["Enemies"]
    local wallLayer = gameMap.layers["Walls"]
    local levelTransitionLayer = gameMap.layers["LevelTransition"]

    level:spawnPlayer(cameFrom)

    if wallLayer then
        for _, obj in pairs(wallLayer.objects) do
            Wall(obj.x, obj.y, obj.width, obj.height, world);
        end
    end

    if enemiesLayer then
        for _, obj in pairs(enemiesLayer.objects) do
            handlers.enemies:addEnemy(Enemy(obj.x, obj.y, 32, 32, 60, 5, 5, 10, 10, 3, '/assets/sprites/characters/slime.png', world,
                handlers.drops));
        end
    end

    if levelTransitionLayer then
        for _, obj in pairs(levelTransitionLayer.objects) do
            local transitionCollider = world:newBSGRectangleCollider(obj.x, obj.y, obj.width, obj.height, 0, { collision_class = "LevelTransition" })
            transitionCollider:setType("static")
            transitionCollider.stateName = obj.properties.level
        end
    end

    ui = UI()

    if player.hurtCollider == nil then return end
    
    camera = Camera(CAMERA_SCALE, player.hurtCollider:getX(), player.hurtCollider:getY());
    shake = Shake(camera.camera);
end

function level:enter(_, cameFrom)
    if conf.MUSIC then audio.gameMusic:play() end

    level:spawnPlayer(cameFrom)
    if entitesNull then
        level:initEntities(cameFrom)
    end

    opacity = 1
end

function level:update(dt)
    if player.hurtCollider == nil then
        return
    end
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

function level:draw()
    tlfres.beginRendering(conf.gameWidth, conf.gameHeight)

    love.graphics.setColor(1, 1, 1);

    camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight, true);

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

    love.graphics.setColor(0, 0, 0, opacity);
    love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)

    tlfres.endRendering()
end

function level:keypressed(key)
    globalFuncs.keypressed(key)

    if key == 'h' or key == 'H' then
        player:useItem('sword', camera.camera)
    end
    if key == 'e' or key == 'E' then
        player:interact()
    end
    if key == "escape" then
        local pause = require("src.states.pause")
        Gamestate.switch(pause, camera, gameMap, player)
    end
end

return level


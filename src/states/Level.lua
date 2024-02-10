local Class = require("lib.hump.class")

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
local conf = require("src.utils.conf");
local audio = require("src.utils.audio");
local globalFuncs = require("src.utils.globalFuncs");

local world, overlayOpacity, player, ui, camera, shake, gameMap, gameMapPath, entitiesNull;

local Level = Class {
    init = function(self, gameMapPathArg)
        world = windfield.newWorld(0, 0, false);
        overlayOpacity = 1;
        gameMapPath = gameMapPathArg
        gameMap = sti("/maps/" .. gameMapPath);
        entitiesNull = true;

        local handlers = {
            effects = EffectsHandler(),
            drops = DropsHandler(),
            enemies = EnemiesHandler(),
            objects = ObjectsHandler()
        }

        local playerLayer = gameMap.layers["Player"];
        local enemiesLayer = gameMap.layers["Enemies"];
        local wallsLayer = gameMap.layers["Walls"];

        if playerLayer then
            for _, obj in pairs(playerLayer.objects) do
                player = Player(obj.x, obj.y, world, handlers)
            end
        end
        if enemiesLayer then
            for _, obj in pairs(enemiesLayero.bjects) do
                handlers.enemies:addEnemy(Enemy(obj.x, obj.y, 32, 32, 60, 5, 5, 10, 10, 3, '/assets/sprites/characters/slime.png', world, handlers.drops));
            end
        end
        if wallsLayer then
            for _, obj in pairs(wallsLayer.objects) do
                Wall(obj.x, obj.y, obj.width, obj.height, world);
            end
        end

        ui = UI();
        camera = Camera(conf.CAMERA.SCALE, player.hurtCollider:getX(), player.hurtCollider:getY());
        shake = Shake(camera.camera);

        self.state = self:_createState()
    end,

    _createState = function (self)
        local state = {};
        state.update = self._update;
        state.draw = self._draw;
        state.keypressed = self._keypressed;
        return state;
    end,

    _enter = function (self)
        if conf.MUSIC then audio.gameMusic:play() end
        if entitiesNull then
            self:initEntities()
        end
    end,

    _update = function (self, dt)
        if overlayOpacity > 0 then overlayOpacity = overlayOpacity - dt end;

        world:update(dt);
        player:updateAbs(dt, shake);
        camera:update(dt, player, gameMap);
        shake:update(dt);
        gameMap:update(dt);

        player._handlers.enemies:updateEnemies(dt);
        player._handlers.objects:updateObjects(dt);
        player._handlers.effects:updateEffects(dt);
        player._handlers.drops:updateDrops(dt);
    end,

    _draw = function (self)
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

        -- love.graphics.setColor(0, 0, 0, self.opacityOverlay);
        -- love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)

        push:finish()
    end,

    _keypressed = function (self, key)
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
}

return Level;

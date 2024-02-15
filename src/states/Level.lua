local CAMERA_SCALE = 1

local Class = require("lib.hump.class")

local sti = require("lib.sti.sti")
local windfield = require("lib.windfield")
local push = require("lib.push")
local Gamestate = require("lib.hump.gamestate")

local Player = require("src.Player")
local Camera = require("src.Camera")
local Wall = require("src.Wall")
local EffectsHandler = require("src.EffectsHandler")
local EnemiesHandler = require("src.EnemiesHandler")
local ObjectsHandler = require("src.ObjectsHandler")
local DropsHandler = require("src.DropsHandler")
local Enemy = require("src.Enemy")
local Chest = require("src.Chest")
local UI = require("src.UI")

local Shake = require("src.utils.Shake")
local conf = require("src.utils.conf")
local audio = require("src.utils.audio")
local globalFuncs = require("src.utils.globalFuncs")


local Level = Class {
    initExternal = function(self, name, cameFrom)
        self.name = name
        self.cameFrom = cameFrom
        self.opacity = 1
        self.ui = UI()

        self:_setupWorld()
        self:_setHandlers()
        self:_setGameMap()
        self:_setPlayerLayer()

        self:_spawnPlayer()

        self:_setCamera()
        self:_setShake()

        self:_spawnEnemies()
        self:_spawnWalls()
        self:_spawnLevelTransitionColliders()

        if conf.MUSIC then audio.gameMusic:play() end

        return self
    end,

    update = function(self, dt)
        if self.player.hurtCollider == nil then return end
        if self.opacity > 0 then self.opacity = self.opacity - dt end

        self.world:update(dt)
        self.player:updateAbs(dt, self.shake)
        self.camera:update(dt, self.player, self.gameMap);
        self.shake:update(dt)
        self.gameMap:update(dt)
    end,

    draw = function(self)
        push:start()

        self:_drawBackgroundColor()

        self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

        self:_drawGameMap()
        if conf.DEBUG.DRAW_WORLD then
            self.world:draw();
        end

        self.camera.camera:detach();

        self.ui:drawPlayerLife(self.player);
        self:_drawOverlayLayer()

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
            Gamestate.switch(pause, self.camera, self.gameMap, self.player)
        end
    end,

    -- init functions start
    _setupWorld = function(self)
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
    end,

    _setHandlers = function(self)
        self.handlers = {
            effects = EffectsHandler(),
            drops = DropsHandler(),
            enemies = EnemiesHandler(),
            objects = ObjectsHandler()
        }
    end,

    _setGameMap = function(self)
        self.gameMap = sti("/maps/" .. self.name .. "/" .. self.name .. ".lua")
    end,

    _setPlayerLayer = function(self)
        assert(self.gameMap.layers["Player"] ~= nil, string.format(
            "%s level does not container player layer",
            self.name))
        self.playerLayer = self.gameMap.layers["Player"]
    end,

    _setCamera = function(self)
        self.camera = Camera(CAMERA_SCALE, self.player.hurtCollider:getX(), self.player.hurtCollider:getY());
    end,

    _setShake = function(self)
        self.shake = Shake(self.camera.camera);
    end,

    _spawnPlayer = function(self)
        if not self.playerLayer then return end
        for _, obj in pairs(self.playerLayer.objects) do
            if obj.properties.cameFrom == self.cameFrom then
                self.player = Player(obj.x, obj.y, self.world, self.handlers)
                break
            end
        end
        assert(self.player ~= nil, "Player was not spawned")
    end,

    _spawnEnemies = function(self)
        local enemiesLayer = self.gameMap.layers["Enemies"]
        if enemiesLayer == nil then return end
        for _, obj in pairs(enemiesLayer.objects) do
            self.handlers.enemies:addEnemy(
                Enemy(
                    obj.x, obj.y, 32, 32, 60, 5, 5, 10, 10, 3,
                    '/assets/sprites/characters/slime.png',
                    self.world, self.handlers.drops
                )
            )
        end
    end,

    _spawnWalls = function(self)
        local wallsLayer = self.gameMap.layers["Walls"]
        if wallsLayer == nil then return end
        for _, obj in pairs(wallsLayer.objects) do
            Wall(obj.x, obj.y, obj.width, obj.height, self.world);
        end
    end,

    _spawnLevelTransitionColliders = function(self)
        local levelTransitionLayer = self.gameMap.layers["LevelTransition"]
        if levelTransitionLayer == nil then return end
        for _, obj in pairs(levelTransitionLayer.objects) do
            local transitionCollider = self.world:newBSGRectangleCollider(obj.x, obj.y, obj.width, obj.height, 0,
                { collision_class = "LevelTransition" })
            transitionCollider:setType("static")
            transitionCollider.stateName = obj.properties.level
        end
    end,
    -- init functions end

    _drawBackgroundColor = function(self)
        love.graphics.setColor(91 / 255, 169 / 255, 121 / 255); -- This is not the color of the grass 😞 fix it
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
        love.graphics.setColor(1, 1, 1);
    end,

    _drawOverlayLayer = function(self)
        love.graphics.setColor(0, 0, 0, self.opacity);
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
    end,

    _drawGameMap = function(self)
        for _, layer in ipairs(self.gameMap.layers) do
            if layer.visible ~= true or layer.opacity <= 0 then
                goto continue
            end
            if layer.name == "Player" then
                self.player:drawAbs();
            else
                if layer.type == "tilelayer" then
                    self.gameMap:drawLayer(layer)
                end
            end
            ::continue::
        end
    end
}

return Level

local Class = require("lib.hump.class")

local sti = require("lib.sti.sti")
local windfield = require("lib.windfield")
local push = require("lib.push")
local Gamestate = require("lib.hump.gamestate")

local UI = require("src.UI")
local Wall = require("src.Wall")
local Enemy = require("src.Enemy")
local Camera = require("src.Camera")
local Player = require("src.Player")
local EffectsHandler = require("src.handlers.EffectsHandler")
local EnemiesHandler = require("src.handlers.EnemiesHandler")
local ObjectsHandler = require("src.handlers.ObjectsHandler")
local DropsHandler = require("src.handlers.DropsHandler")
local Chest = require("src.objects.Chest")
local Sign = require("src.objects.Sign")
local WaveEffect = require("src.effects.WaveEffect")
local dialogueHandler = require("src.dialogueHandler")

local Shake = require("src.utils.Shake")
local conf = require("src.utils.conf")
local audio = require("src.utils.audio")
local globalFuncs = require("src.utils.globalFuncs")
local fonts = require("src.utils.fonts")


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

        self:_spawnEffects()
        self:_spawnEnemies()
        self:_spawnWalls()
        self:_spawnObjects()
        self:_spawnLevelTransitionColliders()

        if conf.MUSIC then audio.gameMusic:play() end

        return self
    end,

    update = function(self, dt)
        if self.player.hurtCollider == nil then return end
        if self.opacity > 0 then self.opacity = self.opacity - dt end

        self.world:update(dt)
        self.player:updateAbs(dt, self.shake)
        self.camera:update(self.player);
        self.shake:update(dt)
        self.gameMap:update(dt)

        dialogueHandler:update(dt)

        self.handlers.enemies:updateEnemies(dt)
        self.handlers.objects:updateObjects(dt)
        self.handlers.effects:updateEffects(dt)
        self.handlers.drops:updateDrops(dt)
    end,

    draw = function(self)
        push:start()

        self:_drawBackgroundColor()

        self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

        self:drawGameMap()
        if conf.DEBUG.DRAW_WORLD then
            self.world:draw();
        end

        self.camera.camera:detach();

        self.ui:drawPlayerLife();
        self:_drawOverlayLayer()

        if conf.DEBUG.SHOW_FPS then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(fonts.smaller)
            love.graphics.print(love.timer.getFPS(), 0, 0)
        end

        dialogueHandler:draw()

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
            Gamestate.switch(pause, self.camera, self.player, self)
        end
    end,

    drawGameMap = function(self)
        for _, layer in ipairs(self.gameMap.layers) do
            if layer.visible ~= true or layer.opacity <= 0 then
                goto continue
            end
            if layer.name == "Player" then
                self.handlers.enemies:drawEnemies();
                self.handlers.effects:drawEffects(-1)
                self.handlers.objects:drawObjects()
                self.handlers.drops:drawDrops()

                self.player:drawAbs();

                self.handlers.effects:drawEffects(0)
            else
                if layer.type == "tilelayer" then
                    self.gameMap:drawLayer(layer)
                end
            end
            ::continue::
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
        self.camera = Camera(conf.CAMERA.SCALE,
            self.player.hurtCollider:getX(), self.player.hurtCollider:getY(),
            self.gameMap.width, self.gameMap.height,
            self.gameMap.tilewidth, self.gameMap.tileheight);
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

    _spawnEffects = function(self)
        local wavesLayer = self.gameMap.layers["Waves"]
        if wavesLayer == nil then return end
        for _, obj in pairs(wavesLayer.objects) do
            self.handlers.effects:addEffect(WaveEffect(obj.x, obj.y))
        end
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

    _spawnObjects = function(self)
        local objectsLayer = self.gameMap.layers["Objects"]
        if objectsLayer == nil then return end
        for _, obj in pairs(objectsLayer.objects) do
            if obj.properties.type == "sign" then
                self.handlers.objects:addObject(Sign(obj.x, obj.y, 16, 16, self.world, obj.properties.name))
            elseif obj.properties.type == "chest" then
                self.handlers.objects:addObject(Chest(obj.x, obj.y, 16, 16, self.world))
            end
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
        love.graphics.setColor(80 / 255, 155 / 255, 102 / 255);
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
        love.graphics.setColor(1, 1, 1);
    end,

    _drawOverlayLayer = function(self)
        love.graphics.setColor(0, 0, 0, self.opacity);
        love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
    end
}

return Level

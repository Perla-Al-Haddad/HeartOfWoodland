local Class = require("lib.hump.class")
local Gamestate = require("lib.hump.gamestate")
local push = require("lib.push")
local windfield = require("lib.windfield")
local sti = require("lib.sti.sti")

local Camera = require("src.Camera")
local Wall = require("src.Wall")
local Player = require("src.Player")

local Sign = require("src.objects.Sign")
local Box = require("src.objects.Box")
local Grass = require("src.objects.Grass")
local Rock = require("src.objects.Rock")

local FarmGroundTile = require("src.tiles.FarmGroundTile")
local DirtTilesHandler = require("src.tiles.DirtTilesHandler")

local Settings = require("src.states.menuStates.Settings")

local conf = require("src.utils.conf")
local fonts = require("src.utils.fonts")
local funcs = require("src.utils.funcs")


local Level = Class {
    initExternal = function(self, name, cameFrom)
        self.name = name
        self.cameFrom = cameFrom

        self.gameMap = sti("/maps/" .. self.name .. "/" .. self.name .. ".lua")
        self.gameMap = self:__processMapTileset()

        self.world = self:__createWorld()
        self.farmGroundTiles = self:__createFarmGroundTiles()
        self.dirtTilesHandler = DirtTilesHandler()

        self.player = self:__spawnPlayer()
        self.camera = Camera(conf.CAMERA.SCALE,
            self.player.hurtCollider:getX(), self.player.hurtCollider:getY(),
            self.gameMap.width, self.gameMap.height,
            self.gameMap.tilewidth, self.gameMap.tileheight)

        self.grassObjects = self:__createGrassObjects()
        self.rockObjects = self:__createRockObjects()
        self.boxObjects = self:__createBoxObjects()
        self.signObjects = self:__createSignObjects()

        self:__createWalls()

        return self
    end,

    update = function(self, dt)
        self.world:update(dt)
        self.player:update(dt)
        self.camera:update(self.player)

        for _, grass in ipairs(self.grassObjects) do
            grass:update(dt)
        end
    end,

    keypressed = function(self, key)
        -- TODO handle user presses here instead of in level
    end,

    drawInternal = function(self)
        self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight)

        self:__drawGameMap()
        -- self.world:draw()

        self.camera.camera:detach()
        -- love.graphics.rectangle("fill", conf.gameWidth/2, conf.gameHeight/2, 1,1)

        if conf.DEBUG.SHOW_FPS then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(fonts.smaller)
            love.graphics.print(love.timer.getFPS(), 0, 0)
        end
    end,

    draw = function(self)
        push:start()
        self:drawInternal()
        push:finish()
    end,

    keypressed = function(self, key)
        if key == "escape" then
            Gamestate.switch(Settings():initExternal(self, true))
        end

        if key == 'h' or key == 'H' then
            self.player:useItem('hoe')
        end
    end,

    __createFarmGroundTiles = function(self)
        local layer = self.gameMap.layers["Ground"]
        local tiles = {}
        for i, row in ipairs(layer.data) do
            for key, cell in pairs(row) do
                if cell.objectGroup then
                    for _, object in pairs(cell.objectGroup.objects) do
                        table.insert(tiles,
                            FarmGroundTile((key - 1) * 16 + object.x, (i - 1) * 16 + object.y, self.world))
                    end
                end
            end
        end
        return tiles
    end,

    __processMapTileset = function(self)
        local tilesetObjectMapping = {}
        for _, tile in ipairs(self.gameMap.tilesets[1].tiles) do
            tilesetObjectMapping[tile.id] = tile.objectGroup
        end
        for _, layer in ipairs(self.gameMap.layers) do
            if not layer.data then
                goto continue
            end
            for i, row in ipairs(layer.data) do
                for key, cell in pairs(row) do
                    cell[key] = tilesetObjectMapping[key]
                end
            end
            ::continue::
        end
        return self.gameMap
    end,

    __createGrassObjects = function(self)
        return self:__createObjects("Grass", Grass)
    end,

    __createSignObjects = function(self)
        return self:__createObjects("Signs", Sign)
    end,

    __createBoxObjects = function(self)
        return self:__createObjects("Boxes", Box)
    end,

    __createRockObjects = function(self)
        local layer = self.gameMap.layers["Rocks"]
        local rockObjects = {}
        for i, row in ipairs(layer.data) do
            for key, cell in pairs(row) do
                local rock = Rock((key - 1) * 16, (i - 1) * 16, self.world, cell.id, cell.sx)
                table.insert(rockObjects, rock)
            end
        end
        return rockObjects
    end,

    __createObjects = function(self, layerName, objCls)
        local layer = self.gameMap.layers[layerName]
        local objects = {}
        for i, row in ipairs(layer.data) do
            for key, cell in pairs(row) do
                local obj = objCls((key - 1) * 16, (i - 1) * 16, self.world)
                table.insert(objects, obj)
            end
        end
        return objects
    end,

    __createWorld = function(_)
        local world = windfield.newWorld(0, 0, false);

        world:addCollisionClass('Ignore', { ignores = { 'Ignore' } });
        world:addCollisionClass('Dead', { ignores = { 'Ignore' } });
        world:addCollisionClass('Wall', { ignores = { 'Ignore' } });
        world:addCollisionClass('Objects', { ignores = { 'Ignore' } });
        world:addCollisionClass('Trees', { ignores = { 'Ignore' } });
        world:addCollisionClass('Drops', { ignores = { 'Ignore', "Dead" } });
        world:addCollisionClass('EnemyHurt', { ignores = { 'Ignore', "Drops" } });
        world:addCollisionClass('Player', { ignores = { 'Ignore', "EnemyHurt" } });
        world:addCollisionClass('EnemyHit', { ignores = { 'Ignore', "EnemyHurt", "Drops" } });
        world:addCollisionClass('Dirt',
            { ignores = { 'Ignore', "EnemyHurt", "Player", "Objects", "Drops", "EnemyHit", "Dead" } });
        world:addCollisionClass('FarmGround',
            { ignores = { 'Ignore', "EnemyHurt", "Player", "Objects", "Drops", "EnemyHit", "Dead" } });
        world:addCollisionClass('LevelTransition',
            { ignores = { 'Ignore', "EnemyHurt", "Drops", "Objects", "Wall", "EnemyHit", "Dead" } });

        return world
    end,

    __createWalls = function(self)
        for _, layer in ipairs(self.gameMap.layers) do
            if not layer.data or layer.name == "Ground" then
                goto continue
            end
            for i, row in ipairs(layer.data) do
                for key, cell in pairs(row) do
                    if cell.objectGroup then
                        for _, object in pairs(cell.objectGroup.objects) do
                            Wall((key - 1) * 16 + object.x, (i - 1) * 16 + object.y, object.width, object.height,
                                self.world)
                        end
                    end
                end
            end
            ::continue::
        end
        return self.gameMap
    end,

    __spawnPlayer = function(self)
        local playerLayer = self.gameMap.layers["Player"]
        for _, obj in pairs(playerLayer.objects) do
            return Player(self.world, obj.x, obj.y, "Player", "/assets/sprites/characters/player.png", self.dirtTilesHandler,
                self.farmGroundTiles)
        end
    end,

    __drawGameMap = function(self)
        self.gameMap:drawLayer("Ground")
        self.gameMap:drawLayer("Ground2")
        self.gameMap:drawLayer("Decor")
        self.gameMap:drawLayer("Flowers")
        self.gameMap:drawLayer("Water")
        self.gameMap:drawLayer("Ruin", -1)

        self:__drawObjects(self.grassObjects)
        self:__drawObjects(self.rockObjects)
        self:__drawObjects(self.boxObjects)
        self:__drawObjects(self.signObjects)

        self.dirtTilesHandler:draw()

        self.player:draw()
        self.gameMap:drawLayer("Ruin", 1)
        self.gameMap:drawLayer("CeilingTrees")
    end,

    __drawObjects = function(_, objects)
        for _, obj in ipairs(objects) do
            obj:draw()
        end
    end
}

return Level

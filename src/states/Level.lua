local Class = require("lib.hump.class")
local Gamestate = require("lib.hump.gamestate")
local push = require("lib.push")
local windfield = require("lib.windfield")
local sti = require("lib.sti.sti")

local Camera = require("src.Camera")
local Wall = require("src.Wall")
local Player = require("src.Player")
local UI = require("src.UI")

local Sign = require("src.objects.Sign")
local Box = require("src.objects.Box")
local Grass = require("src.objects.Grass")
local Rock = require("src.objects.Rock")
local ObjectHandler = require("src.objects.ObjectHandler")

local FarmGroundTile = require("src.tiles.FarmGroundTile")
local DirtTilesHandler = require("src.tiles.DirtTilesHandler")

local Settings = require("src.states.menuStates.Settings")

local conf = require("src.utils.conf")


local Level = Class {
    initExternal = function(self, name, cameFrom)
        self.name = name
        self.cameFrom = cameFrom

        self.gameMap = sti("/maps/" .. self.name .. "/" .. self.name .. ".lua")
        self.gameMap = self:__processMapTileset()

        self.world = self:__createWorld()
        self.farmGroundTiles = self:__createFarmGroundTiles()
        self.dirtTilesHandler = DirtTilesHandler()

        self.breakableObjectsHandler = ObjectHandler(self.world, self.gameMap)
        self.breakableObjectsHandler:add(Grass, "Grass")
        self.breakableObjectsHandler:add(Box, "Boxes")

        self.rockHandler = ObjectHandler(self.world, self.gameMap)
        self.rockHandler:add(Rock, "Rocks")
        self.signHandler = ObjectHandler(self.world, self.gameMap)
        self.signHandler:add(Sign, "Signs")

        self.player = self:__spawnPlayer()
        self.ui = UI(self.player)
        self.camera = Camera(conf.CAMERA.SCALE,
            self.player.hurtCollider:getX(), self.player.hurtCollider:getY(),
            self.gameMap.width, self.gameMap.height,
            self.gameMap.tilewidth, self.gameMap.tileheight)

        self:__createWalls()

        return self
    end,

    update = function(self, dt)
        self.world:update(dt)
        self.player:update(dt)
        self.camera:update(self.player)

        self.breakableObjectsHandler:update(dt)
    end,

    drawInternal = function(self)
        self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight)

        self:__drawGameMap()
        -- self.world:draw()

        self.camera.camera:detach()
        -- love.graphics.rectangle("fill", conf.gameWidth/2, conf.gameHeight/2, 1,1)

        -- if conf.DEBUG.SHOW_FPS then
        --     love.graphics.setColor(1, 1, 1, 1)
        --     love.graphics.setFont(fonts.smaller)
        --     love.graphics.print(love.timer.getFPS(), 0, 0)
        -- end

        self.ui:draw()
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

        self.player:keypressed(key)
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

    __createWorld = function(_)
        local world = windfield.newWorld(0, 0, false);

        world:addCollisionClass('Ignore', { ignores = { 'Ignore' } });
        world:addCollisionClass('Dead', { ignores = { 'Ignore' } });
        world:addCollisionClass('Wall', { ignores = { 'Ignore' } });
        world:addCollisionClass(conf.OBJECTS.COLLISION_CLASS, { ignores = { 'Ignore' } });
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
                self.farmGroundTiles, self.breakableObjectsHandler)
        end
    end,

    __drawGameMap = function(self)
        self.gameMap:drawLayer("Ground")
        self.gameMap:drawLayer("Ground2")
        self.gameMap:drawLayer("Decor")
        self.gameMap:drawLayer("Flowers")
        self.gameMap:drawLayer("Water")
        self.gameMap:drawLayer("Ruin", -1)

        self.breakableObjectsHandler:draw()
        self.rockHandler:draw()
        self.signHandler:draw()

        self.dirtTilesHandler:draw()

        self.player:draw()
        self.gameMap:drawLayer("Ruin", 1)
        self.gameMap:drawLayer("CeilingTrees")
    end,
}

return Level

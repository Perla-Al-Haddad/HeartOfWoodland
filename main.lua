local push = require('lib.push');
local bump = require("lib.bump.bump");
local bump_debug = require("lib.bump.bump_debug")
local wf = require("lib.windfield")
local Timer = require('lib.hump.timer')

local window = require('src.window');
local Player = require('src.player');
local Wall = require('src.wall');
local WallManager = require('src.wallManager');
local Level = require('src.level');
local Sword = require('src.sword');
local GameSettings = require("src.gameSettings")
local Enemy = require('src.enemy')
local EnemyManager = require('src.enemyManager')
local SpriteManager = require("src.spriteManager")
local GameCamera = require("src.camera")

local effects = require('src.effects.effect')

-- local world = bump.newWorld(GameSettings.TILE_SIZE)
local world = wf.newWorld(0, 0, false)
world:setQueryDebugDrawing(true)

local sword = Sword(world)
local player = {}
local level = {}

local function createCollisionClasses()
    world:addCollisionClass('Player');
    world:addCollisionClass('Wall');
    world:addCollisionClass('Enemy', {ignores = {"Enemy", "Player"}});
end

function love.load()
    print("Heart of Woodland \003")

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineWidth(2)

    createCollisionClasses()

    player = Player(window.WINDOWS_WIDTH/2, window.WINDOWS_HEIGHT/2, world, sword);
    level = Level(60, 45, world, player, 10, Wall, Enemy, WallManager,
                  EnemyManager)
    GameCamera:load(player);

    window:setUpWindow(push)

    SpriteManager:load()

    -- level:addLevelBoundary();
    level.wallManager:loadWalls()
    level.enemyManager:loadEnemies(player, level.levelW, level.levelH, level.map)
end

function love.update(dt)
    Timer.update(dt)
    world:update(dt)
    player:update(dt)

    GameCamera:update(dt, player, level)

    level.enemyManager:updateEnemies(dt)

    effects:update(dt)
end

function love.draw()
    GameCamera.camera:attach()

    love.graphics.setBackgroundColor(GameSettings:getBlueColor(1))

    level:renderBackground()
    -- level:renderLevelBoundary()

    level.wallManager:renderWalls()
    level.enemyManager:renderEnemies()

    player:render()

    -- world:draw()

    effects:draw(0)
    GameCamera.camera:detach()

    window:drawWindowLimits();
end

function love.quit() print("Thanks for playing! Come back soon!") end

function love.mousepressed(x, y, button) if button == 1 then player:attack() end end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
    if key == "backspace" then
        push:switchFullscreen(window.WINDOWS_WIDTH, window.WINDOWS_HEIGHT);
    end
end

function love.keyreleased(key, scancode, isrepeat) end


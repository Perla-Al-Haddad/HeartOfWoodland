local push = require('lib.push');
local bump = require("lib.bump.bump");
local bump_debug = require("lib.bump.bump_debug")
local Camera = require('lib.hump.camera')

local window = require('src.window');
local Player = require('src.player');
local Wall = require('src.wall');
local WallManager = require('src.wallManager');
local Level = require('src.level');
local Sword = require('src.sword');
local GameSettings = require("src.gameSettings")
local Enemy = require('src.enemy')
local EnemyManager = require('src.enemyManager')

local world = bump.newWorld(GameSettings.TILE_SIZE)
local sword = Sword(world)
local player = Player(window.VIRTUAL_WIDTH / 2, window.VIRTUAL_HEIGHT / 2,
                      world, sword);

local cols_len = 0 -- how many collisions are happening
local function drawDebug()
    bump_debug.draw(world)

    local statistics = ("fps: %d, mem: %dKB, collisions: %d, items: %d"):format(
                           love.timer.getFPS(), collectgarbage("count"),
                           cols_len, world:countItems())
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(statistics, 0, 580, 790, 'right')
end

local level = Level(120, 80, world, player, 10, Wall, Enemy, WallManager,
                    EnemyManager)
local camera;

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineWidth(2)

    camera = Camera(player.positionX, player.positionY, 1.5)

    window:setUpWindow(push)

    level.wallManager:loadWalls()
    level.enemyManager:loadEnemies()

    player:load()

    print("Heart of Woodland \003")
end

function love.update(dt)
    player:update(dt)

    local dx, dy = player.positionX - camera.x, player.positionY - camera.y
    camera:move(dx / 2, dy / 2)

    level.enemyManager:updateEnemies(dt)
    -- level:updateEnemyPaths()
end

function love.draw()
    -- push:apply("start")
    -- push:apply("end")
    camera:attach()

    love.graphics.setBackgroundColor(GameSettings:getDarkColor(1))

    -- drawDebug()
    level.wallManager:renderWalls()
    level.enemyManager:renderEnemies()

    player:render()

    camera:detach()
end

function love.quit() print("Thanks for playing! Come back soon!") end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then player:attack() end
    if key == "escape" then love.event.quit() end
end

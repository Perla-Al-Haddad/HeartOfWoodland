local push = require('lib.push');
local bump = require("lib.bump.bump");
local bump_debug = require("lib.bump.bump_debug")
local Camera = require('lib.hump.camera')
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

local level = Level(50, 30, world, player, 10, Wall, Enemy, WallManager,
                    EnemyManager)
local camera;

function love.load()
    print("Heart of Woodland \003")

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineWidth(2)

    camera = Camera(player.positionX, player.positionY, 1)

    window:setUpWindow(push)

    level:addLevelBoundary();
    level.wallManager:loadWalls()
    level.enemyManager:loadEnemies()

    player:load()

    Timer.every(0.25, function()
        level.enemyManager:generateEnemyPaths(level.player, level.levelW,
                                              level.levelH, level.map);
    end)
end

function love.update(dt)
    Timer.update(dt)
    player:update(dt)

    local dx, dy = player.positionX - camera.x, player.positionY - camera.y
    camera:move(dx / 2, dy / 2)

    level.enemyManager:updateEnemies(dt)

    -- 
end

function love.draw()
    -- push:apply("start")
    -- push:apply("end")
    camera:attach()

    love.graphics.setBackgroundColor(GameSettings:getBlueColor(1))

    level:renderBackground()
    level:drawLevelBoundary()

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
    -- if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
    --     level.enemyManager:generateEnemyPaths(level.player, level.levelW,
    --                                           level.levelH, level.map);
    -- end
end

function love.keyreleased(key, scancode, isrepeat)
    -- if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
    --     level.enemyManager:generateEnemyPaths(level.player, level.levelW,
    --                                           level.levelH, level.map);
    -- end
end


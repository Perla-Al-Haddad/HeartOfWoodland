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
local SpriteManager = require("src.spriteManager")
local GameCamera = require("src.camera")

local effects = require('src.effects.effect')

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

local level = Level(100, 70, world, player, 5, Wall, Enemy, WallManager,
                    EnemyManager)

function love.load()
    print("Heart of Woodland \003")

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineWidth(2)

    GameCamera:load(player);

    window:setUpWindow(push)

    SpriteManager:load()

    level:addLevelBoundary();
    level.wallManager:loadWalls()
    level.enemyManager:loadEnemies(player, level.levelW, level.levelH, level.map)

    player:load()
end

function love.update(dt)
    Timer.update(dt)
    player:update(dt)

    GameCamera:update(dt, player, level)
    -- local dx, dy = player.positionX - GameCamera.camera.x, player.positionY - GameCamera.camera.y
    -- GameCamera.camera:move(dx / 2, dy / 2)

    level.enemyManager:updateEnemies(dt)

    effects:update(dt)
end

function love.draw()
    GameCamera.camera:attach()

    love.graphics.setBackgroundColor(GameSettings:getBlueColor(1))

    level:renderBackground()
    -- level:renderLevelBoundary()

    -- drawDebug()
    level.wallManager:renderWalls()
    level.enemyManager:renderEnemies()

    player:render()

    effects:draw(0)
    GameCamera.camera:detach()

    window:drawWindowLimits();
end

function love.quit() print("Thanks for playing! Come back soon!") end

function love.mousepressed(x, y, button)
    if button == 1 then
        player:attack()
    end
end


function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then love.event.quit() end
    if key == "backspace" then push:switchFullscreen(window.WINDOWS_WIDTH, window.WINDOWS_HEIGHT); end
end

function love.keyreleased(key, scancode, isrepeat)
end


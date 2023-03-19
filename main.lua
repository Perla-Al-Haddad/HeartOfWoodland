local push = require('lib.push');
local bump = require("lib.bump");

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
local sword = Sword()
local player = Player(window.VIRTUAL_WIDTH / 2, window.VIRTUAL_HEIGHT / 2,
                      world, sword);

local levelString = [[
#########################
#########################
###...................###
###...................###
###..###############..###
###...................###
###.............X.....###
###....X..............###
###.............####..###
###................#..###
###................#..###
###................#..###
###.............####..###
###...................###
#######........P......###
#######...............###
#######.........#########
#######.........#########
#########################
#########################
]]

local level = Level(levelString, world, player, Wall, Enemy, WallManager, EnemyManager)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineWidth(2)

    window:setUpWindow(push)

    level.wallManager:loadWalls()
    level.enemyManager:loadEnemies()

    player:load()

    print("Heart of Woodland \003")
end

function love.update(dt) player:update(dt) end

function love.draw()
    push:apply("start")

    level.wallManager:renderWalls()
    level.enemyManager:renderEnemies()

    player:render()

    push:apply("end")
    love.graphics.setBackgroundColor(GameSettings:getDarkColor(1))
end

function love.quit() print("Thanks for playing! Come back soon!") end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then player:attack() end
    if key == "escape" then love.event.quit() end
end

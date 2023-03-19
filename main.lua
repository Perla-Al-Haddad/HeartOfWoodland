local push = require('lib.push')
local bump = require("lib.bump")

local window = require('src.window')
local Player = require('src.player')
local Wall = require('src.wall')
local WallManager = require('src.wallManager')
local Level = require('src.level')
local Sword = require 'src.sword';

TILE_SIZE = 16

local world = bump.newWorld(TILE_SIZE)
local sword = Sword:new(nil)
local player = Player(window.VIRTUAL_WIDTH / 2, window.VIRTUAL_HEIGHT / 2,
                      world, sword);

local levelString = [[
#########################
#########################
###...................###
###...................###
###..###############..###
###...................###
###...................###
###...................###
###.............####..###
###................#..###
###................#..###
###................#..###
###.............####..###
###...................###
#######...............###
#######...............###
#######.........#########
#######.........#########
#########################
#########################
]]

local level = Level:new(nil, levelString, world, Wall, WallManager)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    window:setUpWindow(push)

    level.wallManager:loadWalls(level.wallManager)

    player:load()

    print("Heart of Woodland \003")
end

function love.update(dt) player:update(dt) end

function love.draw()
    push:apply("start")

    level.wallManager:renderWalls(level.wallManager)

    player:render()

    push:apply("end")
end

function love.quit() print("Thanks for playing! Come back soon!") end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then player:attack() end
    if key == "escape" then love.event.quit() end
end

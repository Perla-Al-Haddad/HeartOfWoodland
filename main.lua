local push = require('lib.push')
local bump = require("lib.bump")

local window = require('src.window')
local Player = require('src.player')
local Wall = require('src.wall')
local WallManager = require('src.wallManager')
local Level = require('src.level')

TILE_SIZE = 16

local world = bump.newWorld(TILE_SIZE)

local player = Player:new(nil, window.VIRTUAL_WIDTH / 2,
                          window.VIRTUAL_HEIGHT / 2, world);

local levelString = [[
#########################
#########################
###...................###
###...................###
###...##############..###
###...................###
###...................###
###...................###
###..............###..###
###................#..###
###................#..###
###................#..###
###..............###..###
###...................###
#######...............###
#######...............###
#######...............###
#######...............###
#########################
#########################
]]

local level = Level:new(nil, levelString, world, Wall, WallManager)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    window:setUpWindow(push)

    level.wallManager:loadWalls(level.wallManager)

    player:load(player)

    print("Heart of Woodland \003")
end

function love.update(dt)
    player:handleKeyBoardEvents(player, dt)
end

function love.draw()
    push:apply("start")

    level.wallManager:renderWalls(level.wallManager)

    player:render(player)

    push:apply("end")
end

function love.quit() print("Thanks for playing! Come back soon!") end

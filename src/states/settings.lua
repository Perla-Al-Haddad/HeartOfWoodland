local OPTIONS_MARGIN = 10;

local Gamestate = require("lib.hump.gamestate");
local audio = require("src.utils.audio");
local conf = require("src.utils.conf");

local settings = {}
local _prevState = nil;

function settings:enter(prevState)
    _prevState = prevState

    print(_prevState)

    font = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 80);
    fontSmall = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 25);
    fontSmaller = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 20);

    options = {"Back"}

    cursor = {
        x = 0,
        y = 0,
        current = 1
    }
end

function settings:draw() 
    love.graphics.setBackgroundColor(0,0,0);

    title = "Settings"
    titleWidth = font:getWidth(title)
    love.graphics.setFont(font)
    love.graphics.setColor(91/255, 169/255, 121/255)
    love.graphics.printf(title, windowWidth/2 - titleWidth/2, windowHeight/6, titleWidth, "center")

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(1, 1, 1)
    for i, option in ipairs(options) do
        textHeight = fontSmall:getHeight(option)
        love.graphics.print(
            option, 
            windowWidth/2 - titleWidth/2, 
            windowHeight - windowHeight/3 + (textHeight + OPTIONS_MARGIN) * (i - 1))
    end

    love.graphics.circle(
        "fill", 
        windowWidth/2 - titleWidth/2 - 20, 
        windowHeight - windowHeight/3 + textHeight/2 + (textHeight + OPTIONS_MARGIN) * (cursor.current - 1), 
        textHeight/3)
end

function settings:keypressed(key)
    if key == "q" or key == "Q" then Gamestate.switch(_prevState) end;
    if key == "e" or key == "E" then
        if cursor.current == 1 then 
            Gamestate.switch(_prevState)
        end
    end
    if key == "down" then
        if cursor.current >= #options then return end;
        cursor.current = cursor.current + 1
        sounds.select:play()
    end
    if key == "up" then
        if cursor.current <= 1 then return end;
        cursor.current = cursor.current - 1
        sounds.select:play()
    end
end

return settings

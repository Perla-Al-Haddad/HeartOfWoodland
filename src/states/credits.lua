local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");


local credits = {
    options = {"BACK"},
    credits = {
        {
            section = "-- ART --",
            credit = {"game-endeavor - mystic-woods assets"}
        },
        {
            section = "-- MUSIC --",
            credit = {"Kevin MacLeod"}
        },
        {
            section = "-- LIBRARIES --",
            credit = {
                "hump - utils",
                "sone - music",
                "sti - graphics",
                "anim8 - graphics",
                "windfield - physics",
                "push - resolution handling",
                "rot - random level generation",
            }
        }
    }
}

function credits:enter()
end

function credits:draw()
    push:start()

    local title = "CREDITS"

    local titleWidth = fonts.title:getWidth(title)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(91/255, 169/255, 121/255)
    love.graphics.printf(title, conf.gameWidth/2 - titleWidth/2, conf.gameHeight/12, titleWidth, "center")

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1)
    local titleTextHeight;
    local sectionHeight = 0;
    for i, creditsItem in ipairs(self.credits) do
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.setFont(fonts.small)
        titleTextHeight = fonts.small:getHeight(creditsItem.section) + 5
        love.graphics.printf(creditsItem.section, 0, conf.gameHeight/5 + sectionHeight+ i * titleTextHeight, conf.gameWidth, "center")
        for j, credit in ipairs(creditsItem.credit) do
            love.graphics.setColor(1, 1, 1, 1)
            local textHeight = fonts.smaller:getHeight(credit)
            sectionHeight = sectionHeight + textHeight
            love.graphics.setFont(fonts.smaller)
            love.graphics.printf(string.upper(credit), 0, conf.gameHeight/5 + sectionHeight + i * titleTextHeight + textHeight/2 * j, conf.gameWidth, "center")
        end
    end

    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setFont(fonts.small)
    local textHeight, textWidth;
    for i, option in ipairs(self.options) do
        textHeight = fonts.small:getHeight(option)
        textWidth = fonts.small:getWidth(option)
        love.graphics.print(
            option, 
            conf.gameWidth - textWidth * 1.5,
            conf.gameHeight * (8/9))
    end

    love.graphics.circle(
        "fill",
        conf.gameWidth - textWidth * 1.8,
        conf.gameHeight * (8/9) + textHeight/2,
        textHeight/4)

    push:finish()
end

function credits:keypressed(key)
    if key == "e" or key == "E" then
        local menu = require("src.states.menu")
        Gamestate.switch(menu)
    end
end

return credits
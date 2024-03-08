local sone = require("lib.sone.sone")

local funcs = require("src.utils.funcs")
local conf = require("src.utils.conf")
local fonts = require("src.utils.fonts")

local dialogueHandler = {
    lines = {},
    currentlyDisplaying = false,
    flickerTimer = conf.DIALOGUE.FLICKER_SPEED,
    showFlicker = true,
    currentLineHolder = '',
    currentLetterCounter = 1,
    scrollingSpeed = conf.DIALOGUE.SCROLL_SPEED,
    sounds = {
        writing = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/writing.wav"), "static")
    }
}

function dialogueHandler:insertLines(lines)
    self.lines = funcs.shallow_copy(lines)
    self.currentlyDisplaying = true
end

function dialogueHandler:popLine()
    table.remove(self.lines, 1)
    self.currentLineHolder = ''
    self.currentLetterCounter = 1
end

function dialogueHandler:update(dt)
    if #self.lines <= 0 then
        self.currentlyDisplaying = false
    else
        self.flickerTimer = self.flickerTimer - dt
        if self.flickerTimer < 0 then
            self.flickerTimer = conf.DIALOGUE.FLICKER_SPEED
            self.showFlicker = not self.showFlicker
        end

        self.currentlyDisplaying = true
        self.currentLineHolder = string.sub(self.lines[1], 1, self.currentLetterCounter)
        self.scrollingSpeed = self.scrollingSpeed - dt
        if self.scrollingSpeed < 0 then
            self.scrollingSpeed = conf.DIALOGUE.SCROLL_SPEED
            self.currentLetterCounter = self.currentLetterCounter + 1
        end
        if self.currentLetterCounter >= #self.lines[1] then
            if not self.sounds.writing:isPlaying() then
                self.sounds.writing:stop()
            end
        else
            self.sounds.writing:play()
        end
    end
end

function dialogueHandler:draw()
    if not self.currentlyDisplaying then return end;

    love.graphics.setFont(fonts.dialogue)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 20, conf.gameHeight - 70, conf.gameWidth - 40, 60)

    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 20, conf.gameHeight - 70, conf.gameWidth - 40, 60)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(string.upper(self.currentLineHolder), 30, conf.gameHeight - 60, conf.gameWidth - 40 - 30)

    if #dialogueHandler.lines > 1 and self.showFlicker then
        love.graphics.rectangle("fill", conf.gameWidth - 40, conf.gameHeight - 25, 5, 5)
    end
end

return dialogueHandler

local conf = require("src.utils.conf")
local fonts = require("src.utils.fonts")

local dialogueHandler = {}

dialogueHandler.lines = {}
dialogueHandler.currentlyDisplaying = false
dialogueHandler.flickerTimer = conf.DIALOGUE.FLICKER_SPEED
dialogueHandler.showFlicker = true

function dialogueHandler:insertLines(lines)
    self.lines = lines
    self.currentlyDisplaying = true
end

function dialogueHandler:popLine()
    table.remove(self.lines, 1)
end

function dialogueHandler:update(dt)
    self.flickerTimer = self.flickerTimer - dt
    if self.flickerTimer < 0 then
        self.flickerTimer = conf.DIALOGUE.FLICKER_SPEED
        self.showFlicker = not self.showFlicker
    end
end

function dialogueHandler:draw()
    if #self.lines <= 0 then
        self.currentlyDisplaying = false
        return
    end
    self.currentlyDisplaying = true
    love.graphics.setFont(fonts.dialogue)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 20, conf.gameHeight - 70, conf.gameWidth - 40, 60)

    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", 20, conf.gameHeight - 70, conf.gameWidth - 40, 60)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(string.upper(dialogueHandler.lines[1]), 30, conf.gameHeight - 60, conf.gameWidth - 40 - 30)

    if #dialogueHandler.lines > 1 and self.showFlicker then
        love.graphics.rectangle("fill", conf.gameWidth - 40, conf.gameHeight - 25, 5, 5)
    end
end

return dialogueHandler

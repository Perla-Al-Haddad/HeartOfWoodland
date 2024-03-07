local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");

local mapPreview = {
    prevState,
    player,
    camera,
    levelState,
    minimapScale = 1.75
}

function mapPreview:enter(prevState, levelState)
    self.levelState = levelState
    self.prevState = prevState
    self.camera = levelState.camera
    self.player = levelState.player
end

function mapPreview:draw()
    push:start()

    self.levelState:_drawBackgroundColor()

    self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

    self.levelState:drawLevel()

    self.camera.camera:detach();

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, self.levelState.width / self.minimapScale, self.levelState.height / self.minimapScale)

    local px, py = self.levelState.player:getSpriteTopPosition()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", px / self.levelState.collisionTileWidth / self.minimapScale,
        py / self.levelState.collisionTileHeight / self.minimapScale, 2, 2)

    love.graphics.setColor(1, 1, 1, 0.5)
    for _, tree in pairs(self.levelState.trees) do
        love.graphics.rectangle("fill", tree.positionX / self.levelState.collisionTileWidth / self.minimapScale,
            tree.positionY / self.levelState.collisionTileHeight / self.minimapScale, 1, 1)
    end

    push:finish()
end

function mapPreview:keypressed(key)
    if key == "q" or key == "Q" or key == "escape" then
        local state;
        if self.levelState ~= nil then
            state = self.levelState
        else
            state = self.prevState
        end
        Gamestate.switch(state)
    end
end

return mapPreview
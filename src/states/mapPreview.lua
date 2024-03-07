local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");
local tween = require('lib.tween.tween')

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");

local mapPreview = {
    prevState,
    player,
    camera,
    levelState,
    minimapScale = 1,
    mapTweenTarget = { y = conf.gameHeight, opacity = 0 },
    mapTween
}

function mapPreview:enter(prevState, levelState)
    self.levelState = levelState
    self.prevState = prevState
    self.camera = levelState.camera
    self.player = levelState.player

    self.mapTween = tween.new(0.6, self.mapTweenTarget, { y = 0, opacity = 1 }, 'outBack')
end

function mapPreview:update(dt)
    self.levelState:update(dt)

    self.mapTween:update(dt)
end

function mapPreview:draw()
    push:start()

    self.levelState:_drawBackgroundColor()

    self.camera.camera:attach(nil, nil, conf.gameWidth, conf.gameHeight);

    self.levelState:drawLevel()

    self.camera.camera:detach();

    self:_drawMiniMap()

    push:finish()
end

function mapPreview:keypressed(key)
    if key == "q" or key == "Q" or key == "escape" or key == "tab" then
        self.mapTween:reset()
        local state;
        if self.levelState ~= nil then
            state = self.levelState
        else
            state = self.prevState
        end
        Gamestate.switch(state)
    end
end

function mapPreview:_drawMiniMap()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, conf.gameWidth, conf.gameHeight)
    love.graphics.setColor(1, 1, 1, self.mapTweenTarget.opacity)

    love.graphics.translate(conf.gameWidth / 2 - self.levelState.width / 2, self.mapTweenTarget.y + 10)

    local px, py = self.levelState.player:getSpriteTopPosition()
    love.graphics.setColor(1, 0, 0, self.mapTweenTarget.opacity)
    love.graphics.rectangle("fill", px / self.levelState.collisionTileWidth / self.minimapScale,
        py / self.levelState.collisionTileHeight / self.minimapScale, 2, 2)

    love.graphics.setColor(1, 1, 1, self.mapTweenTarget.opacity)
    for _, tree in pairs(self.levelState.trees) do
        if tree.wasSeen then
            love.graphics.rectangle("fill", tree.positionX / self.levelState.collisionTileWidth / self.minimapScale,
                tree.positionY / self.levelState.collisionTileHeight / self.minimapScale, 1, 1)
        end
    end
end

return mapPreview

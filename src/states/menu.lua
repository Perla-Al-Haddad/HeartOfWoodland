local SCALE = 2
local SWITCH_TIMER = 1.5

local windfield = require("lib.windfield");
local Vector = require("lib.hump.vector")
local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local Player = require("src.Player");
local EffectsHandler = require("src.handlers.EffectsHandler");
local Level = require("src.states.Level")
local ForestGenerator = require("src.states.ForestGenerator")

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");
local fonts = require("src.utils.fonts");
local globalFuncs = require("src.utils.globalFuncs");


local menu = {}

local cursor, options, switchTimer, switch, menuWorld,
effectsHandler, player, sounds, walk;

function menu:enter()
    cursor = {
        x = 0,
        y = 0,
        current = 1
    }

    options = { "PLAY", "SETTINGS", "CREDITS", "EXIT" }

    switchTimer = SWITCH_TIMER;
    switch = false;

    menuWorld = windfield.newWorld(0, 0, false);

    if conf.MUSIC then
        audio.gameMusic:stop()
        audio.menuMusic:play()
    end

    effectsHandler = EffectsHandler();

    player = Player(
        (conf.gameWidth / 2 - conf.PLAYER.TILE_SIZE / 2) / SCALE,
        (conf.gameHeight / 2 + conf.PLAYER.TILE_SIZE / 2) / SCALE + 9,
        menuWorld, { effects = effectsHandler });
    player._handlePlayerMovement = function(_, _) end

    sounds = {}
    sounds.select = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/click.wav"), "static")
end

function menu:update(dt)
    if switch then
        audio:fadeOut(audio.menuMusic, switchTimer)
        switchTimer = switchTimer - dt
    end;

    menuWorld:update(dt);
    player:updateAbs(dt, nil);
    player.currentAnimation = player.animations.walk;
    effectsHandler:updateEffects(dt);

    if switchTimer < 0 then
        -- local level = Level():initExternal("forestRuins", "menu")
        -- local level = ForestGenerator():initExternal()
        local loading = require("src.states.loading")
        Gamestate.switch(loading)
    end
end

function menu:draw()
    push:start()

    local title = "HEART\nOF\nWOODLAND"
    local titleWidth = fonts.title:getWidth(title)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(91 / 255, 169 / 255, 121 / 255)
    love.graphics.printf(title, conf.gameWidth / 2 - titleWidth / 2, conf.gameHeight / 12, titleWidth, "center")

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1)
    local textHeight;
    for i, option in ipairs(options) do
        textHeight = fonts.small:getHeight(option)
        love.graphics.print(
            option,
            conf.gameWidth / 2 - titleWidth / 2,
            conf.gameHeight / 2 - conf.PLAYER.TILE_SIZE / 2 + 12 + (textHeight + fonts.OPTIONS_MARGIN) * (i - 1)
        )
    end

    love.graphics.circle(
        "fill",
        conf.gameWidth / 2 - titleWidth / 2 - 20,
        conf.gameHeight / 2 - conf.PLAYER.TILE_SIZE / 2 + 20 + (textHeight + fonts.OPTIONS_MARGIN) * (cursor.current - 1),
        textHeight / 4)

    love.graphics.setFont(fonts.smaller)
    love.graphics.setColor(1, 1, 1, 0.7)
    local text = "PRESS [E] TO SELECT"
    local textWidth = fonts.smaller:getWidth(text)
    love.graphics.print(
        text,
        conf.gameWidth / 2 - textWidth / 2,
        conf.gameHeight - conf.gameHeight / 8)

    love.graphics.push()
    love.graphics.scale(SCALE)
    love.graphics.setColor(1, 1, 1, 1)
    effectsHandler:drawEffects(-1);
    player:drawAbs()
    effectsHandler:drawEffects(0)
    love.graphics.pop()

    -- love.graphics.line(conf.gameWidth/2, 0, conf.gameWidth/2, conf.gameHeight)

    push:finish()
end

function menu:keypressed(key)
    globalFuncs.keypressed(key)

    if key == "e" or key == "E" then
        if cursor.current == 1 then
            walk()
            switch = true
        elseif cursor.current == 2 then
            local settings = require("src.states.settings")
            Gamestate.switch(settings)
        elseif cursor.current == 3 then
            local credits = require("src.states.credits")
            Gamestate.switch(credits)
        elseif cursor.current == 4 then
            love.event.quit();
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

walk = function()
    player._handlePlayerMovement = function(self, dt)
        if self.state ~= 'default' then return end

        self.hurtCollider:setLinearDamping(0)

        self.prevDirX = self.dirX
        self.prevDirY = self.dirY

        self.pressedDirX = 0
        self.pressedDirY = 0

        self.pressedDirX = 1
        self.dirX = 1

        if self.pressedDirY == 0 and self.pressedDirX ~= 0 then self.dirY = 1 end

        local vec = Vector(self.pressedDirX, self.pressedDirY):normalized() * self.speed
        self.hurtCollider:setLinearVelocity(vec.x, vec.y)

        self.dustEffectTimer = self.dustEffectTimer - dt
        self.walkSoundTimer = self.walkSoundTimer - dt

        if vec.x ~= 0 or vec.y ~= 0 then
            self.currentAnimation = self.animations.walk

            if self.dustEffectTimer <= 0 then
                self.dustEffectTimer = 0.25
                local dustEffect = DustEffect(self.hurtCollider:getX(), self.hurtCollider:getY() - 1)
                self._handlers.effects:addEffect(dustEffect)
            end

            if self.walkSoundTimer <= 0 then
                self.walkSoundTimer = 0.38
                self.sounds.walk:play()
            end
        else
            self.currentAnimation = self.animations.idle
        end

        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end
    end
end

return menu;

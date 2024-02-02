local SCALE = 2
local SWITCH_TIMER = 1.5

local windfield = require("lib/windfield");
local Vector = require("lib.hump.vector")
local Gamestate = require("lib.hump.gamestate");
local push = require("lib.push");

local Player = require("src.Player");
local EffectsHandler = require("src.EffectsHandler");

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

    options = {"PLAY", "SETTINGS", "EXIT"}

    switchTimer = SWITCH_TIMER;
    switch = false;

    menuWorld = windfield.newWorld(0, 0, false);

    if conf.MUSIC then audio.menuMusic:play() end

    effectsHandler = EffectsHandler();

    player = Player((conf.gameWidth/2 - 16)/SCALE, (conf.gameHeight/2 + 16)/SCALE, 32, 32, 160, 12, 12, 10, menuWorld, {effects=effectsHandler});
    player._handlePlayerMovement = function(self, dt) end

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
        local forestLevel = require("src.states.forestLevel")
        Gamestate.switch(forestLevel)
    end
end


function menu:draw()
    push:start()

    local title = "HEART\nOF\nWOODLAND"
    local titleWidth = fonts.title:getWidth(title)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(91/255, 169/255, 121/255)
    love.graphics.printf(title, conf.gameWidth/2 - titleWidth/2, conf.gameHeight/7, titleWidth, "center")

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(1, 1, 1)
    local textHeight;
    for i, option in ipairs(options) do
        textHeight = fonts.small:getHeight(option)
        love.graphics.print(
            option,
            conf.gameWidth/2 - titleWidth/2,
            conf.gameHeight - conf.gameHeight/3 + (textHeight + fonts.OPTIONS_MARGIN) * (i - 1))
    end

    love.graphics.circle(
        "fill",
        conf.gameWidth/2 - titleWidth/2 - 20,
        conf.gameHeight - conf.gameHeight/3 + textHeight/2 + (textHeight + fonts.OPTIONS_MARGIN) * (cursor.current - 1),
        textHeight/3)

    love.graphics.setFont(fonts.smaller)
    love.graphics.setColor(1, 1, 1, 0.7)
    local text = "PRESS [E] TO SELECT"
    local textWidth = fonts.smaller:getWidth(text)
    love.graphics.print(
        text,
        conf.gameWidth/2 - textWidth/2, 
        conf.gameHeight - conf.gameHeight/6)

    love.graphics.push()
    love.graphics.scale(SCALE)
    love.graphics.setColor(1, 1, 1, 1)
    effectsHandler:drawEffects(-1);
    player:drawAbs()
    effectsHandler:drawEffects(0)
    love.graphics.pop()

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
                local dustEffect = DustEffect(self.hurtCollider:getX(), self.hurtCollider:getY()-1)
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
local SCALE = 3
local SWITCH_TIMER = 2
local OPTIONS_MARGIN = 10;

local windfield = require("lib/windfield");
local Vector = require("lib.hump.vector")
local Gamestate = require("lib.hump.gamestate");
local anim8 = require("lib.anim8.anim8")
local sti = require("lib/sti/sti");

local Camera = require("src.Camera");
local Player = require("src.Player");
local EffectsHandler = require("src.EffectsHandler");

local audio = require("src.utils.audio");
local conf = require("src.utils.conf");

local menu = {}

function menu:enter()
    cursor = {
        x = 0,
        y = 0,
        current = 1
    }

    options = {"Play", "Settings", "Exit"}

    switchTimer = SWITCH_TIMER;
    switch = false;

    world = windfield.newWorld(0, 0, false);

    windowWidth, windowHeight = love.graphics:getWidth(), love.graphics:getHeight()

    font = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 80);
    fontSmall = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 25);
    fontSmaller = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 20);
    if conf.music then audio.menuMusic:play() end

    effectsHandler = EffectsHandler();
    
    player = Player((windowWidth/2 - 32/2)/SCALE, (windowHeight/2 + 32)/SCALE, 32, 32, 160, 12, 12, 10, world, {effects=effectsHandler});
    player._handlePlayerMovement = function(self, dt) end

    sounds = {}
    sounds.select = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/click.wav"), "static")
end


function menu:update(dt)
    if switch then 
        audio:fadeOut(audio.menuMusic, switchTimer)
        switchTimer = switchTimer - dt 
    end;

    world:update(dt);
    player:updateAbs(dt, nil);
    player.currentAnimation = player.animations.walk;
    effectsHandler:updateEffects(dt);

    if switchTimer < 0 then
        local game = require("src.states.game")
        Gamestate.switch(game)
    end
end


function menu:draw()
    love.graphics.setBackgroundColor(0,0,0);

    title = "Heart \nof \nWoodland"
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

    love.graphics.setFont(fontSmaller)
    love.graphics.setColor(1, 1, 1, 0.5)
    text = "Press [E] to select"
    textWidth = fontSmaller:getWidth(text)
    love.graphics.print(
        text, 
        windowWidth/2 - textWidth/2, 
        windowHeight - windowHeight/6)

    love.graphics.scale(SCALE,SCALE)
    effectsHandler:drawEffects(-1);
    player:drawAbs()
    effectsHandler:drawEffects(0)
end


function menu:keypressed(key)
    if key == "e" or key == "E" then
        if cursor.current == 1 then 
            walk()
            switch = true
        elseif cursor.current == 2 then
            local settings = require("src.states.settings")
            Gamestate.switch(settings, menu)
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


function walk() 
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
                dustEffect = DustEffect(self.hurtCollider:getX(), self.hurtCollider:getY()-1)
                _handlers.effects:addEffect(dustEffect)
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
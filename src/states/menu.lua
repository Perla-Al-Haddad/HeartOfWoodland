local SCALE = 3
local SWITCH_TIMER = 2

local windfield = require("lib/windfield");
local Vector = require("lib.hump.vector")
local Gamestate = require("lib.hump.gamestate");
local anim8 = require("lib.anim8.anim8")
local sti = require("lib/sti/sti");

local Camera = require("src.Camera");
local Player = require("src.Player");
local EffectsHandler = require("src.EffectsHandler");

local audio = require("src.utils.audio");
local settings = require("src.utils.settings");

local menu = {}


function menu:enter()
    switchTimer = SWITCH_TIMER;
    switch = false;

    world = windfield.newWorld(0, 0, false);

    windowWidth, windowHeight = love.graphics:getWidth(), love.graphics:getHeight()

    font = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 80);
    fontSmall = love.graphics.newFont("assets/fonts/Pixel Georgia Bold.ttf", 25);
    if settings.music then audio.menuMusic:play() end

    effectsHandler = EffectsHandler();
    
    player = Player((windowWidth/2 - 32/2)/SCALE, (windowHeight/2 + 32)/SCALE, 32, 32, 160, 12, 12, 10, world, {effects=effectsHandler});
    player._handlePlayerMovement = function(self, dt) end

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

    pressPlay = "Press space to play"
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(1,1,1)
    love.graphics.print(pressPlay, windowWidth/2 - titleWidth/2, windowHeight - windowHeight/3)

    love.graphics.scale(SCALE,SCALE)
    effectsHandler:drawEffects(-1);
    player:drawAbs()
    effectsHandler:drawEffects(0)
end


function menu:keypressed(key)
    if key == "space" then
        walk()
        switch = true
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
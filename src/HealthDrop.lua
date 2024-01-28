local DROP_COLLISION_CLASS = "Drops"
local HEALTHDROP_ANIMATION_SHEET = "/assets/sprites/objects/heart_drop-Sheet.png"
local SPRITE_HEIGHT = 16
local SPRITE_WIDTH = 8
local HEIGHT_OFFSET = 4
local COLLIDER_DIM = 8

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")


HealthDrop = Class {
    _world = nil,

    init = function(self, positionX, positionY, world) 
        _world = world
        self.type = "heart"

        self.pickedUp = false;

        self.collider = world:newBSGRectangleCollider(positionX, positionY,
                                                    COLLIDER_DIM, COLLIDER_DIM, 0, 
                                                    {collision_class = DROP_COLLISION_CLASS})
        self.collider:setType("static")

        self.width = SPRITE_WIDTH
        self.height = SPRITE_HEIGHT

        self.animationSheet = love.graphics.newImage(HEALTHDROP_ANIMATION_SHEET)
        self.grid = anim8.newGrid(self.width, self.height,
                                    self.animationSheet:getWidth(),
                                    self.animationSheet:getHeight())

        self.animations = {}
        self.animations.heart = anim8.newAnimation(self.grid("1-6", 1), 0.05, function(animation) animation:pauseAtEnd(6) end)

        self.currentAnimation = self.animations.heart;

        self.sounds = {}
        self.sounds.pickup = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/pickup.wav"), "static")
    end,

    pickUp = function(self)
        self.pickedUp = true;
        self.collider:destroy()
        self.sounds.pickup:play()
    end,

    update = function(self, dt)
        if self.pickedUp then return end;
        self.currentAnimation:update(dt)
    end,

    draw = function(self) 
        if self.pickedUp then return end;
        love.graphics.setColor(1, 1, 1, 1)
        
        local px, py = self:_getCenterPosition()
        self.currentAnimation:draw(self.animationSheet, px, py-HEIGHT_OFFSET, nil, self.collider.dirX, 1, 0, 0)
    end,
    
    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2

        return px, py
    end,
}

return HealthDrop
local CHEST_COLLISION_CLASS = "Chest"
local CHEST_ANIMATION_SHEET = "/assets/sprites/objects/chest_01.png"

local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")


Chest = Class {
    _world = nil,

    init = function(self, positionX, positionY, width, height, world) 
        _world = world

        self.width = width
        self.height = height

        self.collider = world:newBSGRectangleCollider(positionX, positionY,
                                                    self.width,
                                                    self.height, 0, 
                                                    {collision_class = CHEST_COLLISION_CLASS})
        self.collider:setType("static")

        self.animationSheet = love.graphics.newImage(CHEST_ANIMATION_SHEET)
        self.grid = anim8.newGrid(self.width, self.height,
                                    self.animationSheet:getWidth(),
                                    self.animationSheet:getHeight())

        self.animations = {}
        self.animations.closed = anim8.newAnimation(self.grid('1-1', 1), 1)
        self.animations.open = anim8.newAnimation(self.grid('1-4', 1), 0.25, function(animation) animation:pauseAtEnd(4) end)

        self.currentAnimation = self.animations.closed;

        self.sounds = {}
        self.sounds.open = love.audio.newSource(love.sound.newSoundData("assets/sounds/effects/open.wav"), "static")
    end,

    update = function(self, dt)
        self.currentAnimation:update(dt)
    end,

    draw = function(self) 
        love.graphics.setColor(1, 1, 1, 1)
        
        local px, py = self:_getCenterPosition()
        self.currentAnimation:draw(self.animationSheet, px, py, nil, self.collider.dirX, 1, 0, 0)
    end,

    open = function(self)
        self.currentAnimation = self.animations.open;
        self.sounds.open:play()
    end,
    
    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2

        return px, py
    end,
}

return Chest
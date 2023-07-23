local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

Enemy = Class {
    init = function(self, positionX, positionY, width, height, collisionWidth,
                    collisionHeight, heightOffset, world)
        self.dir = "down"
        self.dirX = 1
        self.dirY = 1
        self.prevDirX = 1
        self.prevDirY = 1
        self.speed = 60

        self.state = "default"

        self.collisionWidth = collisionWidth
        self.collisionHeight = collisionHeight

        self.heightOffset = heightOffset

        self.width = width
        self.height = height

        self.rotateMargin = 0.25
        self.comboCount = 0

        self.collider = world:newBSGRectangleCollider(positionX, positionY,
                                                      self.collisionWidth,
                                                      self.collisionHeight, 3, {
            collision_class = "Enemy"
        })
        self.collider:setType('static')

        self.animationSheet = love.graphics.newImage(
                                  '/assets/sprites/characters/slime.png')
        self.grid = anim8.newGrid(self.width, self.height,
                                  self.animationSheet:getWidth(),
                                  self.animationSheet:getHeight())

        self.animations = {}
        self.animations.idle = anim8.newAnimation(self.grid('1-4', 1), 0.25)

        self.currentAnimation = self.animations.idle
        self.animationTimer = 0

        self.buffer = {}

        self.startX = positionX + 30
        self.startY = positionY + 30
        self.wanderRadius = 30

        self.wanderSpeed = 15
        self.wanderTimer = 0.5 + math.random() * 2
        self.wanderBufferTimer = 0
        self.wanderDir = Vector(1, 1)
    end,

    update = function(self, dt)
        self.currentAnimation:update(dt);
        self:_wander(dt);
    end,

    draw = function(self)
        local px, py = self:_getCenterPosition()

        love.graphics.setColor(1, 1, 1, 1)

        self.currentAnimation:draw(self.animationSheet, px, py, nil,
                                   self.collider.dirX, 1, 0, 0)
    end,

    _wander = function(self, dt)
        canWander = (self.state ~= "wandering-moving" or self.state ~=
                        "wandering-stopped")
        if not canWander then return end

        -- print(canWander)

        if self.wanderTimer > 0 then
            self.wanderTimer = self.wanderTimer - dt
        end
        if self.wanderBufferTimer > 0 then
            self.wanderBufferTimer = self.wanderBufferTimer - dt
        end

        if self.wanderTimer < 0 then
            self.state = "wandering-moving"
            self.wanderTimer = 0
            
            local ex = self.collider:getX()
            local ey = self.collider:getY()

            if ex < self.startX and ey < self.startY then
                self.wanderDir = Vector(0, 1)
            elseif ex > self.startX and ey < self.startY then
                self.wanderDir = Vector(-1, 0)
            elseif ex < self.startX and ey > self.startY then
                self.wanderDir = Vector(1, 0)
            else
                self.wanderDir = Vector(0, -1)
            end

            self.wanderBufferTimer = 0.2
            self.wanderDir:rotateInplace(math.pi / -2 * math.random())
        end

        if self.state == "wandering-moving" then
            self.collider:setX(self.collider:getX() + self.wanderDir.x *
                                   self.wanderSpeed * dt)
            self.collider:setY(self.collider:getY() + self.wanderDir.y *
                                   self.wanderSpeed * dt)

            if self:_distanceBetween(self.collider:getX(), self.collider:getY(),
                                     self.startX, self.startY) >
                self.wanderRadius and self.wanderBufferTimer <= 0 then
                self.state = "wandering-stopped"
                self.wanderTimer = 1 + math.random(0.1, 0.8)
            end
        end
    end,

    _distanceBetween = function(self, x1, y1, x2, y2)
        return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    end,

    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2 - self.heightOffset

        return px, py
    end

}

return Enemy;

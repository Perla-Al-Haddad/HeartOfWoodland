local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local SwingEffect = require("src.Effects.SwingEffect")

Player = Class {
    init = function(self, positionX, positionY, width, height, collisionWidth,
                    collisionHeight, offsetHeight, world)
        self.dir = "down"
        self.dirX = 1
        self.dirY = 1
        self.prevDirX = 1
        self.prevDirY = 1
        self.speed = 140

        self.state = "default"

        self.collisionWidth = collisionWidth
        self.collisionHeight = collisionHeight

        self.offsetHeight = offsetHeight

        self.width = width
        self.height = height

        self.rotateMargin = 0.25
        self.comboCount = 0

        self.collider = world:newBSGRectangleCollider(positionX, positionY,
                                                      self.collisionWidth,
                                                      self.collisionHeight, 3, {
            collision_class = "Player"
        })
        -- self.collider:setLinearDamping(20)

        self.animationSheet = love.graphics.newImage(
                               '/assets/sprites/characters/player.png')
        self.grid = anim8.newGrid(self.width, self.height,
                                  self.animationSheet:getWidth(),
                                  self.animationSheet:getHeight())
        self.animations = {}
        self.animations.idle = anim8.newAnimation(self.grid('1-6', 2), 0.25)
        self.animations.walk = anim8.newAnimation(self.grid('1-6', 5), 0.12)
        self.animations.swing = anim8.newAnimation(self.grid('4-4', 8), 0.15)

        self.currentAnimation = self.animations.idle
        self.animationTimer = 0

        self.buffer = {}
    end,

    load = function(self) end,

    update = function(self, dt, effectsHandler)
        self.currentAnimation:update(dt)

        self:_handlePlayerMovement(dt)
        self:_handleSwordSwing(dt, effectsHandler)
    end,

    draw = function(self)
        local px, py = self:_getCenterPosition()

        love.graphics.setColor(1, 1, 1, 1)

        self.currentAnimation:draw(self.animationSheet, px, py, nil, self.collider.dirX, 1, 0,
                       0)
    end,

    useItem = function(self, item, camera)
        if item == "sword" then self:_swingSword(camera) end
    end,

    _addToBuffer = function(self, action)
        table.insert(self.buffer, {action, 0.25})
    end,

    _swingSword = function(self, camera)
        canSwing = (self.state == "swing" or self.state == "swinging")
        if canSwing then
            self:_addToBuffer("sword")
            return
        end

        self.comboCount = self.comboCount + 1

        self.attackDir = self:_toMouseVector(camera)
        self:_setDirFromVector(self.attackDir)

        self.state = "swing"

        self.currentAnimation = self.animations.swing
        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end

        self.animationTimer = 0.075
    end,

    _handleSwordSwing = function(self, dt, effectsHandler)
        isNotSwinging = not (self.state == 'swing' or self.state == 'swinging')
        if isNotSwinging then return end

        self.animationTimer = self.animationTimer - dt

        if self.state == "swing" then
            self.collider:setLinearVelocity((self.attackDir * 200):unpack())
        elseif self.state == "swinging" then
            self.collider:setLinearDamping(35)
        end

        stillSwinging = not (self.animationTimer < 0)
        if stillSwinging then return end

        if self.state == "swing" then
            self.state = "swinging"
            -- animationTimer for finished sword swing stance
            self.animationTimer = 0.25
            local swingEffect = SwingEffect(self.collider:getX(),
                                            self.collider:getY(),
                                            self.attackDir, self.comboCount)
            effectsHandler:addEffect(swingEffect)
        elseif self.state == "swinging" then
            self.state = "default"
        end
    end,

    _handlePlayerMovement = function(self, dt)
        if self.state ~= 'default' then return end

        self.collider:setLinearDamping(0)

        self.prevDirX = self.dirX
        self.prevDirY = self.dirY

        local dirX = 0
        local dirY = 0

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            dirX = 1
            self.dirX = 1
        end

        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            dirX = -1
            self.dirX = -1
        end

        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            dirY = 1
            self.dirY = 1
        end

        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            dirY = -1
            self.dirY = -1
        end

        if dirY == 0 and dirX ~= 0 then self.dirY = 1 end

        local vec = Vector(dirX, dirY):normalized() * self.speed
        self.collider:setLinearVelocity(vec.x, vec.y)

        if vec.x ~= 0 or vec.y ~= 0 then
            self.currentAnimation = self.animations.walk
        else
            self.currentAnimation = self.animations.idle
        end

        if self.dirX == -1 and not self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        elseif self.dirX == 1 and self.currentAnimation.flippedH then
            self.currentAnimation:flipH()
        end

    end,

    _getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2 - self.offsetHeight

        return px, py
    end,

    _setDirFromVector = function(self, vec)
        local rad = math.atan2(vec.y, vec.x)
        if rad >= self.rotateMargin * -1 and rad < math.pi / 2 then
            self.dirX = 1
            self.dirY = 1
        elseif (rad >= math.pi / 2 and rad < math.pi) or
            (rad < (math.pi - self.rotateMargin) * -1) then
            self.dirX = -1
            self.dirY = 1
        elseif rad < 0 and rad > math.pi / -2 then
            self.dirX = 1
            self.dirY = -1
        else
            self.dirX = -1
            self.dirY = -1
        end
    end,

    _toMouseVector = function(self, camera)
        local px, py = self:_getCenterPosition()

        local mx, my = camera:mousePosition()
        return Vector.new(mx - px, my - py):normalized()
    end

}

return Player

local Vector = require("lib.hump.vector")
local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

require("src.effects")

Player = Class {
    init = function(self, positionX, positionY, width, height, collisionWidth,
                    collisionHeight, world)
        self.dir = "down"
        self.dirX = 1
        self.dirY = 1
        self.prevDirX = 1
        self.prevDirY = 1
        self.speed = 120

        self.state = "default"

        self.collisionWidth = collisionWidth
        self.collisionHeight = collisionWidth

        self.width = width
        self.height = height

        self.rotateMargin = 0.25
        self.comboCount = 0

        self.collider = world:newBSGRectangleCollider(positionX, positionY,
                                                      self.collisionWidth,
                                                      self.collisionHeight, 3, {
            collision_class = "Player"
        })

        self.playerSheet = love.graphics.newImage(
                               '/assets/sprites/characters/player.png')
        self.grid = anim8.newGrid(self.width, self.height,
                                  self.playerSheet:getWidth(),
                                  self.playerSheet:getHeight())
        self.animations = {}
        self.animations.idle = anim8.newAnimation(self.grid('1-6', 2), 0.25)
        self.animations.walk = anim8.newAnimation(self.grid('1-6', 5), 0.12)
        self.animations.swing = anim8.newAnimation(self.grid('4-4', 8), 0.15)

        self.anim = self.animations.idle
        self.animTimer = 0

        self.buffer = {}
    end,

    load = function(self) end,

    addToBuffer = function(self, action)
        table.insert(self.buffer, {action, 0.25})
    end,

    update = function(self, dt)
        self.anim:update(dt)
        
        self:handlePlayerMovement(dt)
        self:handleSwordSwing(dt)
    end,

    swingSword = function(self, camera)

        -- The player can only swing their sword if the player.state is 0 (regular gameplay)
        if self.state ~= "default" then
            self:addToBuffer("sword")
            return
        end

        player.comboCount = player.comboCount + 1

        self.attackDir = self:toMouseVector(camera)
        self:setDirFromVector(self.attackDir)

        self.state = "swing"

        self.anim = self.animations.swing
        if self.dirX == -1 and not self.anim.flippedH then
            self.anim:flipH()
        elseif self.dirX == 1 and self.anim.flippedH then
            self.anim:flipH()
        end

        self.animTimer = 0.075
    end,

    handleSwordSwing = function(self, dt) 
        if not (self.state == 'swing' or self.state == 'swinging') then
            return
        end

        self.animTimer = self.animTimer - dt

        if self.state == "swing" then
            self.collider:setLinearVelocity((self.attackDir * 90):unpack())
        elseif self.state == "swinging" then
            self.collider:setLinearVelocity(0, 0)
        end

        if self.animTimer < 0 then
            if self.state == "swing" then
                self.state = "swinging"
                -- animTimer for finished sword swing stance
                self.animTimer = 0.25
                effects:spawn("slice", self.collider:getX(),
                              self.collider:getY() + 1, self.attackDir)
            elseif self.state == "swinging" then
                self.state = "default"
            end
        end
    end,

    handlePlayerMovement = function(self, dt)
        if self.state ~= 'default' then return end

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
            self.anim = self.animations.walk
        else
            self.anim = self.animations.idle
        end

        if self.dirX == -1 and not self.anim.flippedH then
            self.anim:flipH()
        elseif self.dirX == 1 and self.anim.flippedH then
            self.anim:flipH()
        end

    end,

    getCenterPosition = function(self)
        local px, py = self.collider:getPosition()
        px = px - self.width / 2
        py = py - self.height / 2 - self.collisionHeight

        return px, py
    end,

    draw = function(self)
        local px, py = self:getCenterPosition()

        love.graphics.setColor(1, 1, 1, 1)

        self.anim:draw(self.playerSheet, px, py, nil, self.collider.dirX, 1, 0,
                       0)
    end,

    setDirFromVector = function(self, vec)
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

    toMouseVector = function(self, camera)
        local px, py = self:getCenterPosition()

        local mx, my = camera:mousePosition()
        return Vector.new(mx - px, my - py):normalized()
    end,

    useItem = function(self, key, camera)
        if key == "sword" then self:swingSword(camera) end
    end

}

return Player

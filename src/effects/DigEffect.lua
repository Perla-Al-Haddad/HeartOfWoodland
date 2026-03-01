local Class = require("lib.hump.class")
local tween = require('lib.tween.tween')

local DigEffect = Class {
    init = function(self, positionX, positionY)
        self.positionX = positionX
        self.positionY = positionY

        self.dead = false
        self.alpha = 1

        self.layer = -1

        self.particles = self:__createParticles()
    end,

    update = function(self, dt)
        self.alpha = self.alpha - dt * 2
        for _, p in pairs(self.particles) do
            p.tween:update(dt)
        end
        if self.alpha < 0 then
            self.dead = true
        end
    end,

    draw = function(self)
        for _, p in pairs(self.particles) do
            love.graphics.setColor(169 / 255, 88 / 255, 60 / 255, self.alpha)
            love.graphics.rectangle("fill", p.x, p.y, p.width, p.width)
            love.graphics.setColor(1, 1, 1)
        end
    end,

    __createParticles = function(self)
        local particles = {}
        for var = 1, math.random(3, 5) do
            local particle = {
                x = self.positionX + math.random(2, 6) * math.random(-1, 1),
                y = self.positionY + math.random(2, 6) * math.random(-1, 1),
                width = math.random(2, 4),
            }
            particle.tween = tween.new(0.4, particle, {
                y = particle.y + particle.width,
                x = particle.x + particle.width * math.random(-1, 1)
            }, 'outBounce')
            table.insert(particles, particle)
        end
        return particles
    end
}

return DigEffect

GameSettings = require("src.gameSettings")
Class = require("lib.hump.class")

local Sword = Class {
    init = function(self, world)
        self.swordW = 16
        self.swordH = 4
        self.swordOffset = 2
        self.active = false

        self.world = world
    end,

    update = function(self, player)
        if self.active then
            local position = self:getSwordPosition(player)
            local _, _, cols, len =
                self.world:move(self, position.x, position.y)
            for i = 1, len do
                local other = cols[i].other
                if other.type == 'enemy' then other:die() end
            end
        end
    end,

    addSwordToWorld = function(self, player)
        local position = self:getSwordPosition(player)
        self.world:add(self, position.x, position.y, position.w, position.h)
    end,

    removeSwordFromWorld = function(self) self.world:remove(self) end,

    render = function(self, player)
        if not self.active then return; end
        love.graphics.setColor(GameSettings:getWhiteColor(1));
        local position = self:getSwordPosition(player);

        love.graphics.rectangle("fill", position.x, position.y, position.w,
                                position.h);
        love.graphics.setColor(255, 255, 255)
    end,

    getSwordPosition = function(self, player)
        local default_position = {
            x = player.positionX + self.swordOffset + self.swordW,
            y = player.positionY + player.collisionH / 2 - self.swordH / 2,
            w = self.swordW,
            h = self.swordH
        };
        if player.attackDir == 'right' then
            return default_position;
        elseif player.attackDir == 'left' then
            return {
                x = player.positionX - self.swordOffset - self.swordW,
                y = player.positionY + player.collisionH / 2 - self.swordH / 2,
                w = self.swordW,
                h = self.swordH
            };
        elseif player.attackDir == 'up' then
            return {
                x = player.positionX + player.collisionW / 2 - self.swordH / 2,
                y = player.positionY - self.swordOffset - self.swordW,
                w = self.swordH,
                h = self.swordW
            };
        elseif player.attackDir == 'down' then
            return {
                x = player.positionX + player.collisionW / 2 - self.swordH / 2,
                y = player.positionY + self.swordOffset + self.swordW,
                w = self.swordH,
                h = self.swordW
            };
        end
    end
}

return Sword

local anim8 = require("lib.anim8.anim8")

local SpriteManager = require("src.spriteManager")

local effects = {}

function effects:spawn(type, x, y, args)

    local effect = {}
    effect.x = x
    effect.y = y
    effect.rot = 0
    effect.dead = false
    effect.scaleX = 3
    effect.scaleY = 3
    effect.layer = 1
    effect.type = type

    if type == "slice" then
        effect.spriteSheet = SpriteManager.effects.sliceAnim
        effect.width = 23
        effect.height = 39
        effect.grid = anim8.newGrid(effect.width, effect.height,
                                    effect.spriteSheet:getWidth(),
                                    effect.spriteSheet:getHeight())
        effect.anim = anim8.newAnimation(effect.grid('1-2', 1), 0.07,
                                         function() effect.dead = true end)
        effect.rot = 0
        effect.layer = 0

        if args then
            effect.rot = math.atan2(args.y, args.x)
            -- if player.comboCount % 2 == 0 then
            --     effect.scaleY = -1
            -- end
        end

        effect.x = effect.x + args.x * 11
        effect.y = effect.y + args.y * 11
    end

    table.insert(effects, effect)
end

function effects:update(dt)
    for _, e in ipairs(effects) do
        if e.anim then e.anim:update(dt) end
        if e.timer then e.timer = e.timer - dt end
        if e.update then e:update(dt) end
    end

    local i = #effects
    while i > 0 do
        if effects[i].dead then table.remove(effects, i) end
        i = i - 1
    end
end

function effects:draw(layer)
    for _, e in ipairs(effects) do
        if e.layer == layer then
            if e.anim then
                if e.alpha then
                    love.graphics.setColor(1, 1, 1, e.alpha)
                end
                e.anim:draw(e.spriteSheet, e.x, e.y, e.rot, e.scaleX, e.scaleY,
                            e.width / 2, e.height / 2)
            end
            if e.draw then e:draw() end
        end
    end
end

return effects

local vector = require("lib.hump.vector")
local GameCamera = require("src.camera")

local utils = {};

function utils:getDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx ^ 2 + dy ^ 2)
end

function utils:toMouseVector(px, py)
    local mx, my = GameCamera.camera:mousePosition()
    return vector.new(mx-px, my-py):normalized()
end

return utils

local push = require("lib.push.push")

test = {}

function test:draw() 
    push:start()
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", 0,0,64,64)
    push:finish()
end

return test
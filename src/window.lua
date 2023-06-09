local window = {}

window.WINDOWS_WIDTH = 1080;
window.WINDOWS_HEIGHT = 720;
window.VIRTUAL_WIDTH = 384;
window.VIRTUAL_HEIGHT = 304;
window.TITLE = "Heart of Woodland ♥";
window.ICON_PATH = 'images/boy-icon-2.png';

window.options = {resizable = true, fullscreen = false, vsync = true}

function window:setUpWindow(push)
    love.window.setTitle(self.TITLE)
    love.window.setIcon(love.image.newImageData(self.ICON_PATH))
    push:setupScreen(self.VIRTUAL_WIDTH, self.VIRTUAL_HEIGHT,
                     self.WINDOWS_WIDTH, self.WINDOWS_HEIGHT, self.options)
end

function window:drawWindowLimits()
    local windowWidth = love.graphics.getWidth();
    local windowHeight = love.graphics.getHeight();
    love.graphics.setColor(0, 0, 0);
    love.graphics.rectangle("fill", 0, 0, windowWidth / 6, windowHeight);
    love.graphics.rectangle("fill", windowWidth - windowWidth / 6, 0,
                            windowWidth / 2, windowHeight);
    love.graphics.setColor(1, 1, 1);
end

return window

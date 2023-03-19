local window = {}

window.WINDOWS_WIDTH = 1280;
window.WINDOWS_HEIGHT = 720;
window.VIRTUAL_WIDTH = 384;
window.VIRTUAL_HEIGHT = 304;
window.TITLE = "Heart of Woodland ♥";
window.ICON_PATH = 'images/boy-icon-2.png';

window.options = {resizable = false, fullscreen = true, vsync = true}

function window:setUpWindow(push)
    love.window.setTitle(self.TITLE)
    love.window.setIcon(love.image.newImageData(self.ICON_PATH))
    push:setupScreen(self.VIRTUAL_WIDTH, self.VIRTUAL_HEIGHT,
                     self.WINDOWS_WIDTH, self.WINDOWS_HEIGHT, self.options)
end

return window

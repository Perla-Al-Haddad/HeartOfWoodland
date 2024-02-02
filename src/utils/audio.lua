audio = {}

local sone = require("lib.sone.sone")

audio.menuMusic = love.audio.newSource(love.sound.newSoundData("/assets/sounds/music/Screen Saver.mp3"), "stream")
audio.gameMusic = love.audio.newSource(sone.fadeInOut(sone.copy(love.sound.newSoundData("/assets/sounds/music/Evening.mp3")), 5), "stream")

audio.gameMusic:setLooping(true)
audio.menuMusic:setLooping(true)

local function linear(t, b, c, d)
    return c * t / d + b
end

function audio:fadeOut(sound, timer)
    local volume = linear(timer, 0, 1, 1)
    sound:setVolume(volume);
    if sound:getVolume() <= 0.01 then
        sound:setVolume(1)
        sound:stop()
    end
end

return audio;
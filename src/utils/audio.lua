audio = {}

local sone = require("lib.sone.sone")

audio.menuMusic = love.audio.newSource(love.sound.newSoundData("/assets/sounds/music/Screen Saver.mp3"), "stream")
audio.gameMusic = love.audio.newSource(sone.fadeInOut(sone.copy(love.sound.newSoundData("/assets/sounds/music/Evening.mp3")), 5), "stream")

audio.gameMusic:setLooping(true)
audio.menuMusic:setLooping(true)

return audio;
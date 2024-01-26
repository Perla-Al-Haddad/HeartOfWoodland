-- This file handles all things related to screenshake
local Class = require("lib.hump.class")

function updateTimer(v, dt)
    if v > 0 then
        v = v - dt
    elseif v < 0 then
        v = 0
    end
    return v
end

Shake = Class {
    init = function(self, camera) 
        self.time = 0;
        self.fade = true;
        self.fadeSpeed = 0;
        self.intensity = 0;
        self.speed = 0;
        self.speedTimer = 0;
        self.dir = 1;
        
        self.camera = camera;
    end,

    start = function(self, t, i, s, f, f_speed)
        self.time = t;
        self.intensity = i;
        self.speed = s;
        self.speedTimer = s;
        self.fade = f or true;
        self.fadeSpeed = f_speed or 10;

        self.count = 0;
        self.dir = 1;
    end,

    stop = function(self) 
        self.time = nil;
        self.intensity = nil;
        self.speed = nil;
        self.fade = true;
        self.fadeSpeed = 10;
    end,

    update = function(self, dt)
        self.time = updateTimer(self.time, dt)

        if self.time > 0 or (self.fade and self.intensity > 0) then
      
          -- offsets the camera based on the shake's intensity and direction
          self.camera:lookAt(self.camera.x + (self.intensity * self.dir), self.camera.y)
      
          if self.speedTimer <= 0 then
            -- When the timer hits zero, change the direction of the camera offset
            self.dir = self.dir * -1
            self.speedTimer = self.speed
          else
            self.speedTimer = updateTimer(self.speedTimer, dt)
          end
      
          -- After shake time is up, start fading the intensity
          if self.time <= 0 and self.fade and self.intensity > 0 then
            self.intensity = self.intensity - (dt * self.fadeSpeed)
          end
      
        else
          self.camera:lookAt(self.camera.x, self.camera.y)
        end
    end
}

return Shake;

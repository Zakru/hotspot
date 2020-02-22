local fade = require('fade')

local Frequency = {}

function Frequency.newFrequency(freq, dist, music)
  local f = {}

  f.frequency = freq
  f.distance = dist
  f.source = love.audio.newSource(music, 'stream')
  f.source:setLooping(true)
  f.source:setVolume(0)
  f.source:play()

  setmetatable(f, { __index = Frequency })

  return f
end

function Frequency:proximity(freq)
  return 1 - math.min(math.abs(freq - self.frequency) / self.distance, 1)
end

function Frequency:snap(freq, speed)
  if self:proximity(freq) == 0 then return freq end

  if freq > self.frequency then
    return math.max(freq - speed, self.frequency)
  elseif freq < self.frequency then
    return math.min(freq + speed, self.frequency)
  else
    return freq
  end
end

function Frequency:update(freq)
  local potVol = self:proximity(freq) * (1 - fade.depth())
  if potVol == 0 then
    if self.source:isPlaying() then
      self.source:setVolume(0)
      self.source:stop()
    end
  else
    if not self.source:isPlaying() then self.source:play() end
    self.source:setVolume(potVol)
  end
end

return Frequency

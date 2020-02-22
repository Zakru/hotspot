local Radio = {}
local sineData

function Radio.load()
  sineData = love.sound.newSoundData('sine.wav')
end

function Radio.newRadio()
  local r = {}

  r.frequency = 1000
  r.source = love.audio.newSource(sineData)
  r.source:setLooping(true)
  r.source:setVolume(0)

  setmetatable(r, { __index = Radio })

  return r
end

function Radio:setFrequency(freq)
  self.frequency = math.min(math.max(freq, 100), 2000)
end

function Radio:getSinePitch()
  return self.frequency / 100
end

function Radio:update()
  self.source:setPitch(self:getSinePitch())
end

return Radio

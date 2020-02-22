local fade = require('fade')

local FrequencySet = {}

local noiseData

function FrequencySet.load()
  noiseData = love.sound.newSoundData('noise.wav')
end

function FrequencySet.newFrequencySet()
  local f = {}

  f.frequencies = f
  f.noiseSource = love.audio.newSource(noiseData)
  f.noiseSource:setVolume(0)
  f.noiseSource:setLooping(true)

  setmetatable(f, { __index = FrequencySet })

  return f
end

function FrequencySet:maxProximity(freq)
  local max = 0

  for i,frequency in ipairs(self.frequencies) do
    max = math.max(max, frequency:proximity(freq))
  end

  return max
end

function FrequencySet:maxProximityFrequency(freq)
  local max = 0
  local maxFrequency = nil

  for i,frequency in ipairs(self.frequencies) do
    local proximity = frequency:proximity(freq)
    if proximity > max then
      max = proximity
      maxFrequency = frequency
    end
  end

  return maxFrequency
end

function FrequencySet:update(freq, multiplier)
  self.noiseSource:setVolume((1-self:maxProximity(freq)) * (1-fade.depth()) * (multiplier or 1))
  for f,frequency in ipairs(self.frequencies) do
    frequency:update(freq)
  end
end

function FrequencySet:drawNoise(globalState, freq)
  globalState.common.drawNoiseTiles(globalState, 1 - self:maxProximity(freq))
end

return FrequencySet

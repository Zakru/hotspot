local fade = {}
fade.epoch = 0
fade.outTime = 1
fade.inTime = 1
fade.fading = 0

local noiseSource

function fade.load()
  noiseSource = love.audio.newSource('noise.wav', 'static')
  noiseSource:setVolume(0)
  noiseSource:setLooping(true)
  noiseSource:play()
end

function fade.depth()
  if fade.fading == 1 then
    return math.min(1, 1 - (fade.epoch - love.timer.getTime()) / fade.outTime)
  elseif fade.fading == -1 then
    return math.max(0, 1 - (love.timer.getTime() - fade.epoch) / fade.inTime)
  end
  return 0
end

function fade.update()
  noiseSource:setVolume(fade.depth())
  if fade.fading == -1 and love.timer.getTime() > fade.epoch + fade.inTime then
    fade.fading = 0
  end
end

function fade.draw(globalState)
  globalState.common.drawNoiseTiles(globalState, fade.depth())
end

function fade.begin(outTime, inTime)
  fade.epoch = love.timer.getTime() + outTime
  fade.outTime = outTime
  fade.inTime = inTime
  fade.fading = 1
end

function fade.isFadedOut()
  return fade.fading == 1 and love.timer.getTime() > fade.epoch
end

return fade

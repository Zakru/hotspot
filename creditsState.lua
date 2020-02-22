local fade = require('fade')

local creditsState = {}

local credits = {
  {
    start = 4,
    stop = 8,
    text = 'HOTSPOT',
    scale = 4,
  },
  {
    start = 8,
    stop = 12,
    text = 'CREATED BY ZAKRU',
    scale = 2,
  },
  {
    start = 12,
    stop = 16,
    text = 'MADE WITH LÖVE *',
    scale = 2,
  },
  {
    start = 16,
    stop = 20,
    text = 'FOR LÖVE JAM 2020',
    scale = 2,
  },
  {
    start = 28,
    stop = 100000000,
    text = 'ESC TO QUIT',
  },
}

local startTime

function creditsState.load(globalState)
  for c,credit in ipairs(credits) do
    credit.text = love.graphics.newText(globalState.common.font, credit.text)
  end
  startTime = love.timer.getTime()
  fade.fading = 0
  fade.update()
end

function creditsState.draw(globalState)
  love.graphics.clear(0,0,0,1)

  local time = love.timer.getTime() - startTime

  local w,h = globalState.common.scaledDimensions(globalState)

  for c,credit in ipairs(credits) do
    if time > credit.start and time < credit.stop then
      love.graphics.draw(credit.text, w/2, h/2, 0, credit.scale or 1, credit.scale or 1, credit.text:getWidth()/2, credit.text:getHeight()/2)
    end
  end
end

function creditsState.keypressed(globalState, k, sc, r)
  if k == 'escape' then
    love.event.quit()
  end
end

return creditsState

local Radio = require('Radio')
local Frequency = require('Frequency')
local FrequencySet = require('FrequencySet')
local fade = require('fade')
local colorStack = require('colorStack')
local gameState = require('gameState')

local introState = {}

local radio
local knob
local directionDecided = false
local introFrequency
local frequencySet
local title
local initialFade = 0
local knobFade = 0
local instructionsFade = 1
local letterJ
local letterK
local instructionText
local menuText

function introState.load(globalState)
  radio = Radio.newRadio()
  radio.frequency = 1050
  radio:update()
  radio.source:play()

  knob = love.graphics.newImage('knob.png')
  love.graphics.setDefaultFilter('nearest', 'nearest')
  title = love.graphics.newImage('title.png')
  love.graphics.setDefaultFilter('linear', 'linear')
  letterJ = love.graphics.newText(globalState.common.font, 'J')
  letterK = love.graphics.newText(globalState.common.font, 'K')
  instructionText = love.graphics.newText(globalState.common.font, 'FIND A FREQUENCY')
  menuText = love.graphics.newText(globalState.common.font, 'ESC TO ENTER MENU')

  frequencySet = FrequencySet.newFrequencySet()
  frequencySet.noiseSource:play()
end

function introState.update(globalState, dt)
  initialFade = math.min(initialFade + dt * 0.25, 1)
  if initialFade == 1 then
    knobFade = math.min(knobFade + dt * 0.5, 1)
  end

  if directionDecided then
    instructionsFade = math.max(instructionsFade - dt, 0)
  end

  local moved = false
  if love.keyboard.isDown('k') then
    moved = true
    radio:setFrequency(radio.frequency + dt * 200)
  end
  if love.keyboard.isDown('j') then
    moved = true
    radio:setFrequency(radio.frequency - dt * 200)
  end

  if directionDecided and not moved then
    radio:setFrequency(introFrequency:snap(radio.frequency, 200 * dt))
  end

  radio:update()
  frequencySet:update(radio.frequency, initialFade)

  fade.update()
  radio.source:setVolume((1 - fade.depth()) * initialFade * radio:pitchVolumeFactor())
  if fade.isFadedOut() then
    globalState.changeState(gameState)
    radio.source:stop()
    fade.fading = -1
  end
end

function introState.draw(globalState)
  love.graphics.clear(1,1,1,1)

  local w,h = globalState.common.scaledDimensions(globalState)
  love.graphics.draw(title, w/2, h/2 - 32, 0, 1, 1, math.floor(title:getWidth()/2), math.floor(title:getHeight()/2))

  frequencySet:drawNoise(globalState, radio.frequency)

  local angle = 3 / 2 * math.pi * (radio.frequency - 100) / 1900 - 3 / 4 * math.pi

  local knobAlpha = 1-frequencySet:maxProximity(radio.frequency)
  if knobFade < 1 then knobAlpha = knobFade end

  colorStack.push(1,1,1, knobAlpha)
    love.graphics.draw(knob, w / 2, h * 3 / 4, angle, 0.125, 0.125, 128, 128)
  colorStack.pop()

  colorStack.push(0.125,0.125,0.125, knobAlpha * instructionsFade)
    love.graphics.draw(instructionText, w / 2, h / 2, 0, 2, 2, instructionText:getWidth()/2, instructionText:getHeight()/2)
    love.graphics.draw(menuText, 8, 8, 0, 2, 2)
    love.graphics.draw(letterJ, w / 2 - 32, h * 3 / 4, 0, 2, 2, letterJ:getWidth()/2, letterJ:getHeight()/2)
    love.graphics.draw(letterK, w / 2 + 32, h * 3 / 4, 0, 2, 2, letterK:getWidth()/2, letterK:getHeight()/2)
  colorStack.pop()

  fade.draw(globalState)

  colorStack.push(0,0,0, 1-initialFade)
    love.graphics.rectangle('fill', 0,0, globalState.common.scaledDimensions(globalState))
  colorStack.pop()
end

function introState.keypressed(globalState, k, sc, r)
  if (k == 'j' or k == 'k') and not directionDecided then
    directionDecided = true
    if k == 'j' then
      introFrequency = Frequency.newFrequency(1568, 300, 'intromusic.wav')
    else
      introFrequency = Frequency.newFrequency(523.28, 300, 'intromusic.wav')
    end
    table.insert(frequencySet.frequencies, introFrequency)
  end

  if k == 'return' and frequencySet:maxProximity(radio.frequency) == 1 and fade.fading == 0 then
    fade.begin(2, 2)
  end
end

return introState

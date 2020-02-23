local introState = require('introState')
local Radio = require('Radio')
local FrequencySet = require('FrequencySet')
local fade = require('fade')
local Map = require('Map')

local startState = {}

function startState.load(globalState)
  Radio.load()
  FrequencySet.load()
  fade.load()
  Map.load()
  globalState.changeState(introState)
end

return startState

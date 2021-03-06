--[[

  * * * * createKernel.lua * * * *

functions that programmatically create test
images.

Authors: Benjamin Garcia and Logan Lembke
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

require "ip"
local viz = require "visual"
local il = require "il"

--[[
  create a 3x3 plus in the center of a 10x10 image.
--]]
function smallPlus()
  local im = image.flat(10, 10, 0) --create a 10x10 black image
  for i = 0, 2 do
    im:at(3,4).rgb[i] = 255
    im:at(4,3).rgb[i] = 255
    im:at(4,4).rgb[i] = 255
    im:at(4,5).rgb[i] = 255
    im:at(5,4).rgb[i] = 255
  end
  return im
end

return {
  smallPlus=smallPlus
}
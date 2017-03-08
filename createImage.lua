--[[
  This file contains functions that will programmatically
  create test images using the lip image.flat function.
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

--[[
  create a 3x3 smoothing filter.
--]]
function smoothingFilter()
  local im = {}
  im[0] = {}
  im[1] = {}
  im[2] = {}
  im[0][0] = 1/16
  im[0][1] = 2/16
  im[0][2] = 1/16
  im[1][0] = 2/16
  im[1][1] = 4/16
  im[1][2] = 2/16
  im[2][0] = 1/16
  im[2][1] = 2/16
  im[2][2] = 1/16
  im.width = 3
  im.height = 3
  return im
end

return {
  smoothingFilter=smoothingFilter,
  smallPlus=smallPlus
}
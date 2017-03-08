--[[
  This file contains functions that will test the correlate
  function of the util.lua file.
--]]
require "util"
require "ip"
local il = require "il"
local tim = require "createImage"

function smoothingTest()
  local smoothFilter = tim.smoothingFilter()
  local im = tim.smallPlus()
  im:write("testSmoothSmallPlusBefore.bmp")
  il.RGB2YIQ(im)
  im:write("afterRGB2YIQ.bmp")
  local operation = function (kernelValue, imageValue)
    return kernelValue*imageValue
  end
  im = correlate(im, smoothFilter, operation)
  im:write("beforeReconvert.bmp")
  il.YIQ2RGB(im)
  im:write("testSmoothSmallPlusAfter.bmp")
end

smoothingTest()

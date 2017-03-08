--[[
  This file contains functions that will test the correlate
  function of the util.lua file.
--]]
require "util"
require "ip"
local il = require "il"
local cim = require "createImage"
local cke = require "createKernel"

function smoothingTest()
  local smoothFilter = cke.smoothingFilter()
  local im = cim.smallPlus()
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

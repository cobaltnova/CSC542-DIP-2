--[[
  This file contains functions that will test the correlate
  function of the util.lua file.
--]]
require "util"
require "ip"
local il = require "il"
local cim = require "createImage"
local cke = require "createKernel"

--[[
  create a sample image and run a smoothing
  operation on it.
--]]
function smoothingTest()
  local smoothFilter = cke.smoothingFilter()
  local im = cim.smallPlus()
  im:write("testSmoothSmallPlusBefore.bmp")
  il.RGB2YIQ(im)
  im:write("afterRGB2YIQ.bmp")
  im = correlate(im, smoothFilter)
  im:write("beforeReconvert.bmp")
  il.YIQ2RGB(im)
  im:write("testSmoothSmallPlusAfter.bmp")
end

-- run the smoothing test.
smoothingTest()

--[[
  using the smoothed image from the smoothing test to sharpen.
  Two of the images are the same as the after images from
  the smoothing test.
--]]
function sharpeningTest()
  local sharpFilter = cke.sharpeningFilter()
  local im = image.open("testSmoothSmallPlusAfter.bmp")
  il.RGB2YIQ(im)
  im = correlate(im, sharpFilter)
  im:write("sharpenBeforeReconvert.bmp")
  il.YIQ2RGB(im)
  im:write("testSharpenSmallPlusAfter.bmp")
end

sharpeningTest()

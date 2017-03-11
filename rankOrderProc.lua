--[[

  * * * * rankOrderProc.lua * * * *

Rank order processes implementation

Authors: Logan Lembke
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

require "ip"
require "util"
local table = require "table"
local il = require "il"

local function roRankOrderFilter(img, kernel, operation)
  local newImage = img:clone()
  -- kernelCenter maps (1,2) -> 0, (3,4) -> 1, (5,6) -> 2 ...
  -- this works if we choose upper left for the kernel center for even kernels
  local kernelCenter = math.floor((kernel.size - 1)/ 2)
  
  -- if the kernel is even sized, then looping stops 1 pixel early in both directions
  local evenOddCorrection = kernel.size % 2 == 0 and 1 or 0
    
  -- the bounds should prevent indexing past the edges of img.
  -- the -1 is added because images are zero indexed, and lua's for is inclusive
  for imRow = kernelCenter, img.height - kernelCenter - evenOddCorrection - 1 do
    for imColumn = kernelCenter, img.width - kernelCenter - evenOddCorrection - 1 do
      -- create a list of values to pass to the operation
      local values = {}
      -- kRow and kColumn represent offsets in image land, hence they are zero based
      for kRow = 0, kernel.size - 1 do
        for kColumn = 0, kernel.size - 1 do
          -- the kernel is a 1 based lua table, so we must add one to our indexes
          for counter = 1, kernel[kRow+1][kColumn+1] do
            table.insert(values, img:at(imRow-kernelCenter+kRow, imColumn-kernelCenter+kColumn).yiq[0])
          end          
        end
      end
      newImage:at(imRow,imColumn).yiq[0] = clip(operation(values), 0, 255)
    end
  end
  return newImage
end

local function roMedian(values)
  table.sort(values)
  return values[math.ceil(table.getn(values) / 2)]
end

local function roMedianFilter(img, n)
  il.RGB2YIQ(img)
  --TODO: Move this to createKernel
  local kernel = {}
  for i = 1, n do
    table.insert(kernel, {})
    for j = 1, n do
      kernel[i][j] = 1
    end
  end
  kernel.size = n
  
  img=roRankOrderFilter(img, kernel, roMedian)
  il.YIQ2RGB(img)
  return img
end


return {
  medianFilter=roMedianFilter
}

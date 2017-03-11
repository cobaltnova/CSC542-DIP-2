--[[

  * * * * rankOrderProc.lua * * * *

Rank order processes implementation

Authors: Logan Lembke
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

require "table"
require "il"

local function rankOrderFilter(img, kernel, operation)
  local newImage = img:clone()
  -- kernelCenter maps (1,2) -> 0, (3,4) -> 1, (5,6) -> 2 ...
  -- this works if we choose upper left for the kernel center for even kernels
  local kernelCenter = math.floor((kernel.size - 1)/ 2)
  
  -- if the kernel is even sized, then looping stops 1 pixel early in both directions
  local evenOddCorrection = if kernel.size % 2 == 0 then 1 else 0
    
  -- the bounds should prevent indexing past the edges of img.
  -- the -1 is added because images are zero indexed, and lua's for is inclusive
  for imRow = kernelCenterRow, img.height - kernelCenterRow - evenOddCorrection - 1 do
    for imColumn = kernelCenterColumn, img.width - kernelCenterColumn - evenOddCorrection - 1 do
      -- create a list of values to pass to the operation
      local values = {}
      -- kRow and kColumn represent offsets in image land, hence they are zero based
      for kRow = 0, kernel.size - 1 do
        for kColumn = 0, kernel.size - 1 do
          -- the kernel is a 1 based lua table, so we must add one to our indexes
          for counter = 1, kernel[kRow+1][kColumn+1] do
            table.insert(values, img:at(imRow-kernelCenter+kRow, imColumn-halfKernelWidth+kColumn).yiq[0]
          end          
        end
      end
      newImage:at(imrow,imcolumn).yiq[0] = clip(operation(values), 0, 255)
    end
  end
end

local function medianFilter(img, n)
  il.RGB2YIQ(img)
  return img
end


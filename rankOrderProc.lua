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
local kernel = require "createKernel"

--[[
  Generate an ordered list of the pixels that lie under the
  kernel. Pass this list of pixel values to an operation
  which will return the value of the "center" pixel.
--]]
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

--[[
  if the mean of the pixels in a neighborhood
  is more than a given threshold from the value of
  the midpoint, return the mean of the pixels.
  otherwise, return the value of the midpoint.
--]]
local function roOutOfRangeMean(threshold)
  return function(values)
    local n = table.getn(values)
    local midPoint = math.ceil(n / 2)
    local sum = 0
    local count = 0
    for i=1, midPoint - 1 do
      sum = values[i] + sum
      count = count + 1
    end
    for i=midPoint + 1, n do
      sum = values[i] + sum
      count = count + 1
    end
    local avg = sum / count
    if (math.abs(avg - values[midPoint]) > threshold) then
      return avg
    end
    return values[midPoint]
  end   
end

--[[
  return the mean of the values of
  the pixels in a neighborhood.
--]]
local function roMean(values)
  local sum = 0
  local count = 0
  for k, v in ipairs(values) do
    sum = v + sum
    count = count + 1
  end
  return sum / count
end

--[[
  return the standard deviation of the
  values of a neighborhood of pixels.
--]]
local function roStdDev(values)
  local sum = 0
  local count = 0
  local mean = roMean(values)
  for k, v in ipairs(values) do
    sum = sum + (v - mean) * (v - mean)
    count = count + 1
  end
  return math.sqrt(sum / (count - 1))
end

--[[
  sort the list of pixel values, and return
  the median value.
--]]
local function roMedian(values)
  table.sort(values)
  return values[math.ceil(table.getn(values) / 2)]
end

--[[
  given a list of pixel values, return
  the minimal value.
--]]
local function roMin(values)
  local min = 100000
  for k, v in ipairs(values) do
    if v < min then
      min = v
    end
  end
  return min
end

--[[
  given a list of pixel values, return
  the maximal value.
--]]
local function roMax(values)
  local max = -100000
  for k, v in ipairs(values) do
    if v > max then
      max = v
    end
  end
  return max
end

--[[
  return the difference between the
  minimal value in the neighborhood
  and the maximal value.
--]]
local function roRange(values)
  local min = 100000
  local max =-100000
  for k, v in ipairs(values) do
    if v > max then
      max = v
    end
    if v < min then
      min = v
    end
  end
  return max - min
end

--[[
  filter the image by replacing pixels that deviate from the mean
  of their neighbors by more than a user provided threshold with
  the mean of their neighbors.
--]]
local function roOutOfRangeFilter(img, threshold)
  il.RGB2YIQ(img)
  img=roRankOrderFilter(img, kernel.oneFilter(3), roOutOfRangeMean(threshold))
  il.YIQ2RGB(img)
  return img
end

--[[
  replace pixels in the image with the mean value of
  themselves and their neighbors.
--]]
local function roMeanFilter(img, n)
  il.RGB2YIQ(img)  
  img=roRankOrderFilter(img, kernel.oneFilter(n), roMean)
  il.YIQ2RGB(img)
  return img
end

--[[
  replace the pixels in the image with the value of the
  standard deviation of their neighborhoods.
--]]
local function roStdDevFilter(img, n)
  il.RGB2YIQ(img)  
  img=roRankOrderFilter(img, kernel.oneFilter(n), roStdDev)
  il.YIQ2RGB(img)
  return img
end

--[[
  replace each pixel with the value of the median
  pixel in its neighborhood.
--]]
local function roMedianFilter(img, n)
  il.RGB2YIQ(img)  
  img=roRankOrderFilter(img, kernel.oneFilter(n), roMedian)
  il.YIQ2RGB(img)
  return img
end

--[[
  replace each pixel with the value of the median
  pixel an a plus-shaped neighborhood.
--]]
local function roMedianPlusFilter(img)
  il.RGB2YIQ(img)  
  img=roRankOrderFilter(img, kernel.medianPlusFilter(), roMedian)
  il.YIQ2RGB(img)
  return img
end

--[[
  replace each pixel in the image with the
  minimal value in its neighborhood.
--]]
local function roMinFilter(img, n)
  il.RGB2YIQ(img)  
  img=roRankOrderFilter(img, kernel.oneFilter(n), roMin)
  il.YIQ2RGB(img)
  return img
end

--[[
  replace each pixel in the image with the
  maximal value in its neighborhood.
--]]
local function roMaxFilter(img, n)
  il.RGB2YIQ(img)  
  img=roRankOrderFilter(img, kernel.oneFilter(n), roMax)
  il.YIQ2RGB(img)
  return img
end

--[[
  replace each pixel by the difference between
  the maximal pixel in the neighborhood and
  the minimal pixel in the neighborhood.
--]]
local function roRangeFilter(img, n)
  il.RGB2YIQ(img)  
  img=roRankOrderFilter(img, kernel.oneFilter(n), roRange)
  il.YIQ2RGB(img)
  return img
end

return {
  meanFilter=roMeanFilter,
  outOfRangeFilter=roOutOfRangeFilter,
  stdDevFilter=roStdDevFilter,
  medianFilter=roMedianFilter,
  medianPlusFilter=roMedianPlusFilter,
  minFilter=roMinFilter,
  maxFilter=roMaxFilter,
  rangeFilter=roRangeFilter,
}

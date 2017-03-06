--[[

  * * * * util.lua * * * *

Util functions which the lua library doesn't have

Authors: Logan Lembke and Benjamin Garcia
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

function round (input) 
  return math.floor(input + .5)
end

function clip (input, low, high) 
  if low == nil then
    low = 0
  end
  if high == nil then
    high = 255
  end

  return math.min(high, math.max(low, input))
end

--[[
  this function creates a histogram table from an image.
  The function is assuming a YIQ image.
--]]
function createHistogram (img)
  --create an array of "size" 256, zero-indexed
  local histogram = {}
  for i = 0, 255 do
    histogram[i] = 0
  end
  img:mapPixels(
    function (y, i, q)
      histogram[y] = histogram[y] + 1
      return y, i, q
    end
  )
  return histogram
end

--[[
  Run a correlation given a kernel and an image to run it on.
--]]
function correlate(img, kernel, operation)
  local newImage = img:clone()
  -- The bounds should prevent indexing past the edges of img.
  for i = 0 + math.floor(kernel.height/2), img.height - math.floor(kernel.height/2) do
    for j = 0 + math.floor(kernel.width/2), img.width - math.floor(kernel.width/2) do
      -- map each pixel in newImage
      newImage:mapPixels(
        function (y, i, q)
          local value = 0
          for k = 0, kernel.height do
            for l = 0, kernel.width do
              -- value stores the intensity value that will be assigned to the pixel.
              value = value + operation(
                kernel:at(k,l).yiq[1],
                img:at(i-(math.floor(kernel.height/2)-k),j-(math.floor(kernel.width/2)-l)).yiq[1]
              )
            end
          end
          return y, value, q
        end
      )
    end
  end
  -- return the correlated image.
  -- NOTE: the copy function I created does not currently copy the metatables, and also it only
  -- copies key-value pairs, this may mean that nested objects are not correctly copied.
  return newImage
end
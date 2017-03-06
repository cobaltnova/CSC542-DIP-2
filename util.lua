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
  TODO: Determine if this function should be called with the
  coordinates in the image, or if it should return a table of
  return values. currently assuming 2-D array return.
--]]
function correlate(img, kernel, operation)
  local output = {}
  -- The bounds should prevent indexing past the edges of img.
  for i = 0 + (kernel.height/2), img.height - (kernel.height/2) do
    local row = {}
    for j = 0 + (kernel.width/2), img.width - (kernel.width/2) do
      row[j] = (
        local value = 0
        for k = 0, kernel.height do
          for l = 0, kernel.width do
            value += operation(kernel[k][l],
              img[i-((kernel.height/2)-k)][j-((kernel.width/2)-l)])
          end
        end
        return value
      )
    end
    output[i] = row
  end
  return output
end
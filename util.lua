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
  for imrow = 0 + math.floor(kernel.height/2), img.height - 1 - math.floor(kernel.height/2) do
    for imcolumn = 0 + math.floor(kernel.width/2), img.width - 1 - math.floor(kernel.width/2) do
      -- map each pixel in newImage
      local value = 0
      for kernelrow = 0, (kernel.height - 1) do
        for kernelcolumn = 0, (kernel.width - 1) do
          -- value stores the intensity value that will be assigned to the pixel.
          value = value + math.floor(operation(
              kernel[kernelrow][kernelcolumn],
              img:at(imrow-(math.floor(kernel.height/2)-kernelrow),imcolumn-(math.floor(kernel.width/2)-kernelcolumn)).yiq[0]
            ))
        end
      end
      newImage:at(imrow,imcolumn).yiq[0] = clip(value, 0, 255)
    end
  end
  -- return the correlated image.
  return newImage
end
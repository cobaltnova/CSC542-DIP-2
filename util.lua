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
function correlate(img, kernel)
  local newImage = img:clone()
  -- kernelCenter maps (1,2) -> 0, (3,4) -> 1, (5,6) -> 2 ...
  -- this works if we choose upper left for the kernel center for even kernels
  local kernelCenter = math.floor((kernel.size - 1)/ 2)

  -- if the kernel is even sized, then looping stops 1 pixel early in both directions
  local evenOddCorrection = if kernel.size % 2 == 0 then 1 else 0

    -- The bounds should prevent indexing past the edges of img.
    -- the -1 is added because images are zero indexed, and lua's for is inclusive
    for imrow = kernelCenter, img.height - kernelCenter - evenOddCorrection - 1 do
      for imcolumn = kernelCenter, img.width - kernelCenter - evenOddCorrection - 1 do
        -- map each pixel in newImage
        local value = 0
        for kernelrow = 0, kernel.size - 1 do
          for kernelcolumn = 0, kernel.size - 1 do
            -- value stores the intensity value that will be assigned to the pixel.
            -- kernel is 1 based but the image is not, the +1 adjusts for this.
            value = value + math.floor(
              kernel[kernelrow+1][kernelcolumn+1]*
              img:at(imrow-kernelCenter+kernelrow,imcolumn-kernelCenter+kernelcolumn).yiq[0]
            )
          end
        end
        newImage:at(imrow,imcolumn).yiq[0] = clip(value, 0, 255)
      end
    end
    -- return the correlated image.
    return newImage
  end
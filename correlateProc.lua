--[[
  This file contains definitions for correlation based
  processes, as well as the definition for the correlate function.
--]]
require "ip"
require "util"


--[[
  Run a correlation given a kernel and an image to run it on.
--]]
function correlate(img, kernel)
  local newImage = img:clone()
  -- kernelCenter maps (1,2) -> 0, (3,4) -> 1, (5,6) -> 2 ...
  -- this works if we choose upper left for the kernel center for even kernels
  local kernelCenter = math.floor((kernel.size - 1)/ 2)

  -- if the kernel is even sized, then looping stops 1 pixel early in both directions
  local evenOddCorrection = kernel.size % 2 == 0 and 1 or 0

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
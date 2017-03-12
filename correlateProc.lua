--[[
  This file contains definitions for correlation based
  processes, as well as the definition for the correlate function.
--]]
require "ip"
require "util"
local il = require "il"
local cke = require "createKernel"

--[[
  Run a correlation given a kernel and an image to run it on.
--]]
function cCorrelate(img, kernel)
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

--[[
  smooth the image using a 3x3 smoothing filter.
--]]
function cSmoothFilter(img)
  return il.YIQ2RGB(cCorrelate(il.RGB2YIQ(img), cke.smoothingFilter()))
end

--[[
  sharpen the image using a 3x3 sharpening filter.
--]]
function cSharpenFilter(img)
  return il.YIQ2RGB(cCorrelate(il.RGB2YIQ(img), cke.sharpeningFilter()))
end

--[[
  use the sobel gradient filter to determine edges in the image.
  to match Weiss' example, return the original, the magnitude,
  and the direction.
--]]
function cSobel(img)
  local gray = il.grayscaleYIQ(img:clone())
  local magX = gray:clone()
  local magY = gray:clone()
  local mag = gray:clone()
  local dir = gray:clone()
  -- convert magX and magY to yiq for the correlation,
  -- they will be left like this to calculate mag.
  magX = cCorrelate(il.RGB2YIQ(magX), cke.sobelX())
  magY = cCorrelate(il.RGB2YIQ(magY), cke.sobelY())
  il.RGB2YIQ(mag)
  il.RGB2YIQ(dir)
  for row=0, img.height - 1 do
    for col=0, img.width - 1 do
      mag:at(row,col).yiq[0] = clip(math.abs(magX:at(row,col).yiq[0])
        + math.abs(magY:at(row,col).yiq[0]), 0, 255)
      dir:at(row,col).yiq[0] = clip(math.atan2(magX:at(row,col).yiq[0], magY:at(row,col).yiq[0]), 0, 255)
    end
  end
  il.YIQ2RGB(mag)
  il.YIQ2RGB(dir)
  il.stretch(dir,"yiq")
  return img, mag, dir
end

--[[
  use the sobel gradient filter to determine edges in the image,
  returning only the magnitude of the edges.
  to match Weiss' example, the image is not converted to grayscale
  first, and the original is not returned.
--]]
function cSobelMag(img)
  local magX = img:clone()
  local magY = img:clone()
  local mag = img:clone()
  -- convert magX and magY to yiq for the correlation,
  -- they will be left like this to calculate mag.
  magX = cCorrelate(il.RGB2YIQ(magX), cke.sobelX())
  magY = cCorrelate(il.RGB2YIQ(magY), cke.sobelY())
  il.RGB2YIQ(mag)
  for row=0, img.height - 1 do
    for col=0, img.width - 1 do
      mag:at(row,col).yiq[0] = clip(math.abs(magX:at(row,col).yiq[0])
        + math.abs(magY:at(row,col).yiq[0]), 0, 255)
    end
  end
  il.YIQ2RGB(mag)
  return mag
end

return {
  sharpen = cSharpenFilter,
  smooth = cSmoothFilter,
  sobel = cSobel,
  sobelMag = cSobelMag
}
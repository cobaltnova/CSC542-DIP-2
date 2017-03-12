--[[
  This file contains definitions for correlation based
  processes, as well as the definition for the correlate function.
--]]
require "ip"
require "util"
local il = require "il"
local cke = require "createKernel"
local table = require "table"

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
  Run a correlation given a kernel and an image to run it on. Store the output
  in a table rather than an image to hold HDR data
--]]
function cCorrelateHDR(img, kernel)
  --build a table to hold our output
  local newImage = {}
  for i=0, img.height - 1 do
    newImage[i] = {}
  end
  
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
      newImage[imrow][imcolumn] = value
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
  Use the sobel gradient filter to determine angle of the edges in the image.
--]]
function cSobelDir(img)
  local ang = image.flat(img.width, img.height, 0)
  il.RGB2YIQ(ang)
  local magX = cCorrelateHDR(il.RGB2YIQ(img), cke.sobelX())
  local magY = cCorrelateHDR(il.RGB2YIQ(img), cke.sobelY())
  local intensityX
  local intensityY
  for r=1, img.height - 2 do
    for c=1, img.width - 2 do
      intensityX = magX[r][c]
      intensityY = magY[r][c]
      angle = math.atan2(intensityY, intensityX)
      if (angle < 0) then
        angle = angle + 2 * math.pi
      end
      
      ang:at(r,c).yiq[0]=clip((255 / (2 * math.pi)) * angle, 0, 255)      
    end
  end
  il.YIQ2RGB(ang)
  return ang
end

--[[
  Use the sobel gradient filter to determine edges in the image,
  returning only the magnitude of the edges.
--]]
function cSobelMag(img)
  local mag = image.flat(img.width, img.height, 0)
  il.RGB2YIQ(mag)
  local magX = cCorrelateHDR(il.RGB2YIQ(img), cke.sobelX())
  local magY = cCorrelateHDR(il.RGB2YIQ(img), cke.sobelY())
  local intensityX
  local intensityY
  for r=1, img.height - 2 do
    for c=1, img.width - 2 do
      intensityX = magX[r][c]
      intensityY = magY[r][c]
      mag:at(r,c).yiq[0] = clip(
        math.sqrt(intensityX * intensityX + intensityY * intensityY), 0, 255
      )
    end
  end
  il.YIQ2RGB(mag)
  return mag
end

function cKirschMagnitude(img)
  local newImg = image.flat(img.width, img.height, 0)

  il.RGB2YIQ(img)  
  il.RGB2YIQ(newImg)

  local kernels = cke.kirsch
  images = {}
  for k, v in ipairs(kernels) do
    table.insert(images, cCorrelate(img, v))
  end
  
  local max
  for r=1, newImg.height - 2 do
    for c=1, newImg.width - 2 do
      max = 0
      for k, v in ipairs(images) do
        if v:at(r,c).yiq[0] > max then
          max = v:at(r,c).yiq[0]
        end
      end
      
      newImg:at(r,c).yiq[0] = max
    end
  end
  il.YIQ2RGB(newImg)
  return newImg
end

return {
  sharpen = cSharpenFilter,
  smooth = cSmoothFilter,
  sobelDir = cSobelDir,
  sobelMag = cSobelMag,
  kirschMagnitude = cKirschMagnitude,
}

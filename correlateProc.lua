--[[

  * * * * correlateProc.lua * * * *

correlation processes implementation. Correlation
was sufficient for these processes due to symmetric kernels.

Authors: Logan Lembke and Benjamin Garcia
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

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
  generate an approximately gaussian smoothing filter, and convert
  the input image to yiq. Run a correlation on the image using the
  smoothing filter and reconvert to rgb.
--]]
function cSmoothFilter(img)
  return il.YIQ2RGB(cCorrelate(il.RGB2YIQ(img), cke.smoothingFilter()))
end

--[[
  generate a 3x3 sharpening filter, and convert the input image to
  yiq. Run a correlation on the image using the sharpening filter
  and reconvert to rgb.
--]]
function cSharpenFilter(img)
  return il.YIQ2RGB(cCorrelate(il.RGB2YIQ(img), cke.sharpeningFilter()))
end

--[[
  create a blank image with the dimensions of the original
  image. Then, create X and Y direction sobel kernels to
  correlate with the input image after conversion to yiq.
  With gradient magnitude information, take the
  arctangent of the intensities and rescale from 0 to 255.
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
  create a blank image with the dimensions of the original
  image. Then, create X and Y direction sobel kernels to
  correlate with the input image after conversion to yiq.
  With gradient magnitude information, take the
  square root of the sum of the squares of the
  magnitudes to retrieve the edges from both
  X and Y directions.
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

--[[
  Using eight rotations of a 3x3 kirsch edge detection
  kernel, compare the strengths of the kernel matches in
  each pixel's neighborhood. record the max intensity
  returned from correlating each kernel at each pixel.
--]]
function cKirschMagnitude(img)
  local newImg = image.flat(img.width, img.height, 0)

  il.RGB2YIQ(img)
  il.RGB2YIQ(newImg)

  local kernels = cke.kirsch
  --changed this to a local
  local images = {}
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

--[[
  Returns the direction of the gradient within 22.5 degrees of
  the nearest cardinal or inter-cardinal direction as an
  intensity image where intensities map to directions.
  this is accomplished by recording the direction of the
  max intensity obtained from correlating the kirsch
  kernels, and then rescaling the value indicating direction
  from 0 to 255.
--]]
function cKirschDirection(img)
  local newImg = image.flat(img.width, img.height, 0)

  il.RGB2YIQ(img)
  il.RGB2YIQ(newImg)

  local kernels = cke.kirsch
  local images = {}
  for k, v in ipairs(kernels) do
    table.insert(images, cCorrelate(img, v))
  end

  local max
  local maxIndex
  for r=1, newImg.height - 2 do
    for c=1, newImg.width - 2 do
      maxIndex = 0
      max = 0
      for k, v in ipairs(images) do
        if v:at(r,c).yiq[0] > max then
          maxIndex = k
          max = v:at(r,c).yiq[0]
        end
      end
      if (max == 0 ) then 
        newImg:at(r,c).yiq[0] = 0
      else
        newImg:at(r,c).yiq[0] = (maxIndex - 1)*(255/7)
      end
    end
  end
  il.YIQ2RGB(newImg)
  return newImg
end

--[[
  convert the input image to yiq and scale intensities
  down by 128, then create a 3x3 embossing filter.
  perform a correlation on the image with this filter,
  and rescale outputs by 128 again to obtain a flat
  background.
--]]
function cEmboss(img)
  il.RGB2YIQ(img)
  img:mapPixels(
    function(y, i, q)
      return clip(y - 128), i, q
    end
  )
  results = cCorrelateHDR(img, cke.embossFilter())
  for r=1, img.height - 2 do
    for c=1, img.width - 2 do
      img:at(r, c).yiq[0] = clip(results[r][c] + 128)
    end
  end
  il.YIQ2RGB(img)
  return img
end

--[[
  apply a smoothing filter to the image, then apply the laplacian
  filter to the image. This will produce an image of edges from
  the smoothed image. rescale by 128 afterwards.
--]]
function cLaplacian(img)
  il.RGB2YIQ(img)
  -- the 3x3 smoothing filter is approximately Gaussian
  img = cCorrelate(img, cke.smoothingFilter())
  img = cCorrelate(img, cke.laplacianFilter())
  img:mapPixels(
    function (y,i,q)
      return clip(y+128,0,255),i,q 
    end
  )
  il.YIQ2RGB(img)
  return il.stretch(img, "yiq")
end

return {
  sharpen = cSharpenFilter,
  smooth = cSmoothFilter,
  sobelDir = cSobelDir,
  sobelMag = cSobelMag,
  kirschMagnitude = cKirschMagnitude,
  kirschDirection = cKirschDirection,
  emboss = cEmboss,
  laplacian = cLaplacian
}

--[[

  * * * * project2.lua * * * *

Lua image processing program: program 2

Authors: Logan Lembke and Benjamin Garcia
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

-- LuaIP image processing routines
require "ip"   -- this loads the packed distributable
local viz = require "visual"
local il = require "il"
local rankOrder = require "rankOrderProc"
local correlate = require "correlateProc"
-----------
-- menus --
-----------

--[[
  point processes from the Lua IP library.
--]]
imageMenu("Point processes", {
    {"Grayscale YIQ\tCtrl-M", il.grayscaleYIQ, hotkey = "C-M"},
    {"Posterize", il.posterize, {{name = "levels", type = "number", displaytype = "spin", default = 4, min = 2, max = 64}, cmarg1}},
  }
)

--[[
  histogram processes from the Lua IP library.
--]]
imageMenu("Histogram processes", {
    {"Display Histogram", il.showHistogram,
      {{name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "rgb"}, default = "yiq"}}},
    {"Contrast Stretch", il.stretch, {{name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}}},

    {"Histogram Equalize", il.equalize,
      {{name = "color model", type = "string", displaytype = "combo", choices = {"ihs", "yiq", "yuv", "rgb"}, default = "ihs"}}},

  }
)

--[[
  Dr. Weiss' implementation of the processes
  implemented in this project.
--]]
imageMenu("Weiss processes", {
    {"Weiss smooth", il.smooth},
    {"Weiss sharpen", il.sharpen},
    {"Weiss abs-sharpen", il.sharpenAbs},
    {"Weiss sobelMag", il.sobelMag},
    {"Weiss sobel", il.sobel},
    {"Kirsch Edge Mag/Dir", il.kirsch},
    {"Weiss posterize", il.posterize, {{name = "n", type = "number", displaytype = "spin", default = 8},{name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}}},
    {"Weiss brighten", il.brighten, {{name = "amount", type = "number", displaytype = "spin", default = 50},{name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}}},
    {"Weiss emboss", il.emboss},
    {"Weiss laplacian", il.laplacian},
    {"Weiss Noise Clean", il.noiseClean,
      {{name = "threshold", type = "number", displaytype = "slider", default = 64, min = 0, max = 256}}},
    {"Weiss Std Dev", il.stdDev,
      {{name = "width", type = "number", displaytype = "spin", default = 3, min = 0, max = 65}}},
    {"Weiss Minimum", il.minimum},
    {"Weiss Maximum", il.maximum},
  }
)

--[[
  calls to our implementations of the neighborhood
  processes required by the project assignment.
--]]
imageMenu("Neighborhood processes", {
    {"Median Plus Filter", rankOrder.medianPlusFilter},
    {"Out Of Range Filter", rankOrder.outOfRangeFilter, 
      {{name = "threshold", type = "number", displaytype="slider", default = 64, min = 0, max = 255}}},
    {"NxN Median Filter", rankOrder.medianFilter,
      {{name = "n", type = "number", displaytype = "spin", default = 3, min = 2, max = 255}}},
    {"NxN Mean Filter", rankOrder.meanFilter,
      {{name = "n", type = "number", displaytype = "spin", default = 3, min = 2, max = 255}}},
    {"NxN Standard Deviation Filter", rankOrder.stdDevFilter,
      {{name = "n", type = "number", displaytype = "spin", default = 3, min = 2, max = 255}}},
    {"NxN Min Filter", rankOrder.minFilter,
      {{name = "n", type = "number", displaytype = "spin", default = 3, min = 2, max = 255}}},
    {"NxN Max Filter", rankOrder.maxFilter,
      {{name = "n", type = "number", displaytype = "spin", default = 3, min = 2, max = 255}}},
    {"NxN Range Filter", rankOrder.rangeFilter,
      {{name = "n", type = "number", displaytype = "spin", default = 3, min = 2, max = 255}}},
    {"3x3 Smooth Filter", correlate.smooth},
    {"3x3 Sharpen Filter", correlate.sharpen},
    {"3x3 Emboss Filter", correlate.emboss}
  }
)

--[[
  calls to our implementations of the edge detection
  processes required by the project assignment. the
  sobel and kirsch processes have been split into their
  magnitude and direction components.
--]]
imageMenu("Edge Detection", {
    {"Sobel Direction", correlate.sobelDir},
    {"Sobel Magnitude", correlate.sobelMag},
    {"Kirsch Edge Magnitude", correlate.kirschMagnitude},
    {"Kirsch Edge Direction", correlate.kirschDirection},
    {"Laplacian Edge Magnitude", correlate.laplacian}
  }
)

--[[
  call to the Lua IP binary thresholding function.
--]]
imageMenu("Segment", {
    {"Binary Threshold", il.threshold,
      {{name = "threshold", type = "number", displaytype = "slider", default = 128, min = 0, max = 255}}},
  }
)

--[[
  call on Lua IP functions to introduce impulse and Gaussian noise.
--]]
imageMenu("Misc.", {
    {"Impulse Noise", il.impulseNoise,
      {{name = "probability", type = "number", displaytype = "slider", default = 64, min = 0, max = 1000}}},
    {"Gaussian noise", il.gaussianNoise,
      {{name = "sigma", type = "number", displaytype = "textbox", default = "16.0"}}},
  }
)

--[[
  display a short help dialog.
--]]
imageMenu("Help/About",
  {
    { "Help", viz.imageMessage( "Help", "- To load an image file, click 'file' then 'open' and navigate to your image.\n"
        .. "- To perform a transformation on a loaded image, click the image, then select a transformation from one of the menus\n"
        .. "- Right-click on an image's tab to duplicate the image in the editor, or to restore it to its initial state.\n"
        .. "- click and drag an image's tab to the edges of the window to divide the window and display the image separately.\n"
        .. "- click the 'x' on an image's tab to close that copy of the image, the original image on disk will be unaffected") },
    { "About", viz.imageMessage( "Digital Image Processing Project 1", "Authors: Logan Lembke and Benjamin Garcia\nClass: CSC442/542 Digital Image Processing\nDate: Spring 2017" ) }
  }
)

start()

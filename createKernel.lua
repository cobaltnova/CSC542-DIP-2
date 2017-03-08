--[[
  This file contains functions that will programmatically
  create kernels for neighborhood operations.
--]]

--[[
  create a 3x3 smoothing filter.
--]]
function smoothingFilter()
  local im = {}
  im[0] = {}
  im[1] = {}
  im[2] = {}
  im[0][0] = 1/16
  im[0][1] = 2/16
  im[0][2] = 1/16
  im[1][0] = 2/16
  im[1][1] = 4/16
  im[1][2] = 2/16
  im[2][0] = 1/16
  im[2][1] = 2/16
  im[2][2] = 1/16
  im.width = 3
  im.height = 3
  return im
end

return {
  smoothingFilter=smoothingFilter
}
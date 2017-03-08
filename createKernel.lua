--[[
  This file contains functions that will programmatically
  create kernels for neighborhood operations.
--]]

--[[
  create a 3x3 smoothing filter.
--]]
function smoothingFilter()
  local filter = {}
  filter[0] = {}
  filter[1] = {}
  filter[2] = {}
  filter[0][0] = 1/16
  filter[0][1] = 2/16
  filter[0][2] = 1/16
  filter[1][0] = 2/16
  filter[1][1] = 4/16
  filter[1][2] = 2/16
  filter[2][0] = 1/16
  filter[2][1] = 2/16
  filter[2][2] = 1/16
  filter.width = 3
  filter.height = 3
  return filter
end

function sharpeningFilter()
  local filter = {}
  filter[0] = {}
  filter[1] = {}
  filter[2] = {}
  filter[0][0] = 0
  filter[0][1] = -1
  filter[0][2] = 0
  filter[1][0] = -1
  filter[1][1] = 5
  filter[1][2] = -1
  filter[2][0] = 0
  filter[2][1] = -1
  filter[2][2] = 0
  filter.width = 3
  filter.height = 3
  return filter
end

function medianPlusFilter()
  local filter = {}
  filter[0] = {}
  filter[1] = {}
  filter[2] = {}
  filter[0][0] = 0
  filter[0][1] = 1
  filter[0][2] = 0
  filter[1][0] = 1
  filter[1][1] = 1
  filter[1][2] = 1
  filter[2][0] = 0
  filter[2][1] = 1
  filter[2][2] = 0
  filter.width = 3
  filter.height = 3
  return filter
end

return {
  smoothingFilter=smoothingFilter
}
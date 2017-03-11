--[[
  This file contains functions that will programmatically
  create kernels for neighborhood operations.
--]]

--[[
  possible kirsch kernels.
--]]
local kirschKernels = {
  {{-3,-3,-3},
    {-3,0,-3},
    {5,5,5}},
  {{-3,-3,-3},
    {5,0,-3},
    {5,5,-3}},
  {{5,-3,-3},
    {5,0,-3},
    {5,-3,-3}},
  {{5,5,-3},
    {5,0,-3},
    {-3,-3,-3}},
  {{5,5,5},
    {-3,0,-3},
    {-3,-3,-3}},
  {{-3,5,5},
    {-3,0,5},
    {-3,-3,-3}},
  {{-3,-3,5},
    {-3,0,5},
    {-3,-3,5}},
  {{-3,-3,-3},
    {-3,0,5},
    {-3,5,5}}
}

--[[
  create a 3x3 Kirsch edge magnitude kernel, orientation
  of the filter is determined by the input.
  1=N,2=NE,3=E,4=SE,5=S,6=SW,7=W,8=NW
--]]
function kirsch(dir)
  return kirschKernels[dir]
end

--[[
  create an nxn filter filled with 1s based on user input.
--]]
function oneFilter(n)
  local filter = {}
  for i = 0, n do
    filter[i] = {}
    for j = 0, n do
      filter[i][j] = 1
    end
  end
  return filter
end

--[[
  create an nxn mean filter based on user input.
--]]
function meanFilter(n)
  local filter = {}
  for i = 0, n do
    filter[i] = {}
    for j = 0, n do
      filter[i][j] = 1/(n*n)
    end
  end
  return filter
end

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

--[[
  create a 3x3 sharpening filter.
--]]
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

--[[
  create a 3x3 plus-shaped median filter.
--]]
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
  kirsch = kirsch,
  oneFilter = oneFilter,
  meanFilter = meanFilter,
  smoothingFilter=smoothingFilter,
  sharpeningFilter=sharpeningFilter,
  medianPlusFilter=medianPlusFilter
}
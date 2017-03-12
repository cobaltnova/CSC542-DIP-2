--[[
  This file contains functions that will programmatically
  create kernels for neighborhood operations.
--]]

--[[
  possible kirsch kernels.
--]]
local kirschKernels = {
  {{5,5,5},
    {-3,0,-3},
    {-3,-3,-3},
    size=3,
  },
  {{-3,5,5},
    {-3,0,5},
    {-3,-3,-3},
    size=3,
  },
  {{-3,-3,5},
    {-3,0,5},
    {-3,-3,5},
    size=3,
  },
  {{-3,-3,-3},
    {-3,0,5},
    {-3,5,5},
    size=3,
  },  
  {{-3,-3,-3},
    {-3,0,-3},
    {5,5,5},
    size=3,
  },
  {{-3,-3,-3},
    {5,0,-3},
    {5,5,-3},
    size=3,
  },
  {{5,-3,-3},
    {5,0,-3},
    {5,-3,-3},
    size=3,
  },
  {{5,5,-3},
    {5,0,-3},
    {-3,-3,-3},
    size=3,
  },
}

--[[
  create an nxn filter filled with 1s based on user input.
--]]
function oneFilter(n)
  local filter = {}
  for i = 1, n do
    filter[i] = {}
    for j = 1, n do
      filter[i][j] = 1
    end
  end
  filter.size = n
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
  filter.size = n
  return filter
end

--[[
  create a 3x3 smoothing filter.
--]]
function smoothingFilter()
  local filter = {
    {1/16,2/16,1/16},
    {2/16,4/16,2/16},
    {1/16,2/16,1/16}
  }
  filter.size = 3
  return filter
end

--[[
  create a 3x3 sharpening filter.
--]]
function sharpeningFilter()
  local filter = {
    {0,-1,0},
    {-1,5,-1},
    {0,-1,0}
  }
  filter.size = 3
  return filter
end

--[[
  create a 3x3 plus-shaped median filter.
--]]
function medianPlusFilter()
  local filter = {
    {0,1,0},
    {1,1,1},
    {0,1,0}
  }
  filter.size = 3
  return filter
end

--[[
  create a 3x3 sobel filter to find vertical edges.
--]]
function sobelX()
  local filter = {
    {-1,0,1},
    {-2,0,2},
    {-1,0,1}
  }
  filter.size = 3
  return filter
end

--[[
  create a 3x3 sobel filter to find horizontal edges.
--]]
function sobelY()
  local filter = {
    {1,2,1},
    {0,0,0},
    {-1,-2,-1}
  }
  filter.size = 3
  return filter
end

--[[
  create a 3x3 embossing filter.
--]]
function embossFilter()
  local filter = {
    {-1,-1,0},
    {-1,0,1},
    {0,1,1}
  }
  filter.size = 3
  return filter
end

return {
  kirsch = kirschKernels,
  oneFilter = oneFilter,
  meanFilter = meanFilter,
  smoothingFilter = smoothingFilter,
  sharpeningFilter = sharpeningFilter,
  medianPlusFilter = medianPlusFilter,
  sobelX = sobelX,
  sobelY = sobelY,
  embossFilter = embossFilter
}
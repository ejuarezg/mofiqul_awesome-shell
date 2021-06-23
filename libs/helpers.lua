local module = {}

module.file_exists = function(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return name else return nil
  end
end

module.sleep = function(n)
  local t = os.clock()
  while os.clock() - t <= n do
    -- nothing
  end
end
return module

#!/usr/bin/env lua

-- Usage:
--     ./convert.lua ~/.zlua
--   You will get a binary file name .zlua.bin
--     ./convert.lua ~/.zlua.bin -r
--   You will be able to check the contents of the binary file

local function split(s, sep)
  assert(sep ~= '')
  local res = {}
  assert(type(s) == "string")
  if s:len() > 0 then
    local n, start = 1, 1
    local first, last = s:find(sep, start)
    while first do
      res[n] = s:sub(start, first - 1)
      n = n + 1
      start = last + 1
      first, last = s:find(sep, start)
    end
    res[n] = s:sub(start)
  else
    res[1] = ''
  end
  return res
end

local filename = arg[1]
if arg[2] == '-r' then
  local before = io.open(filename, "rb")
  assert(before)
  local contents = before:read("a")
  local now
  local name, rank, time
  while not now or now < #contents do
    name, rank, time, now = string.unpack("=zI4I8", contents, now)
    print(string.format("%s|%d|%d", name, rank, time))
  end
  before:close()
else
  local before = io.open(filename, "r")
  local after = io.open(filename..".bin", "wb")
  assert(before)
  assert(after)
  for line in before:lines() do
    local name, rank, time = table.unpack(split(line, '|'))
    rank:gsub(",", ".")
    rank=math.floor(rank)
    after:write(string.pack("=zI4I8", name, rank, time))
  end
  before:close()
  after:close()
end

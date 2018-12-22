local url_count = 0
local tries = 0
local failures = 0
local maxfailures = 5

wget.callbacks.httploop_result = function(url, err, http_stat)
  status_code = http_stat["statcode"]

  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. "  \n")
  io.stdout:flush()

  if status_code == 0
  or status_code > 400
  then
    io.stdout:write("Server returned "..http_stat.statcode.." ("..err.."). Sleeping.\n")
    io.stdout:flush()
    maxtries = 8
    if status_code == 400
    or status_code == 403
    or status_code == 404
    or status_code == 500
    then
      maxtries = 5
    end
    if tries > maxtries then -- try for 256 or 32 (on specific error codes) seconds, then abort download of this url
      if failures > maxfailures then
        io.stdout:write('Too many errors, giving up on this item')
        io.stdout:flush()
        return wget.actions.ABORT
      end
      tries = 0
      failures = failures + 1
      return wget.actions.EXIT
    else
      local backoff = math.floor(math.pow(2, tries)) -- math.pow returns a float, math.floor turns it into an int so the sleep cmd gets an int
      os.execute("sleep " .. backoff)
      tries = tries + 1
      return wget.actions.CONTINUE
    end
  end

  tries = 0
  if failures > 0 then
    failures = failures - 1
  end

  local sleep_time = 0

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end


--require "images"
--alldata={--[[IMAGES["cut_scenes_cut_collect_soul.png"],
--IMAGES["cut_scenes_cut_catch_him.png"],
--IMAGES["cut_scenes_cut_collect_soul.png"],
--IMAGES["cut_scenes_cut_dream.png"],
--IMAGES["cut_scenes_cut_lapie_kose.png"],
--IMAGES["cut_scenes_cut_reaper.png"],
--IMAGES["cut_scenes_cut_work_korpo.png"],
--IMAGES["cut_scenes_cut_work_quit.png"],
--IMAGES["cut_scenes_you_lost.png"],]]
--IMAGES["cut_scenes_opening_screen.png"],
--IMAGES["cut_scenes_opening_screen2.png"]
--}
require "recording"
for i,p in pairs(alldata) do
  local data=p
  local str=""

  local datalength=8*(6*84)/7

  for yb=0,5 do
    for xd=0,11 do
      local tab={}
      for xi=1,7 do
        for yi=1,8 do
          tab[#tab+1]=(data[yb*8+yi][xd*7+xi]==2 and 1) or 0
        end
      end
      for j=0,7 do
        local int = 0
        for i=1,7 do
          int=int+math.pow(2,i-1)*tab[j*7   +i]
        end
        str=str.."0x"..string.format("%x", int)..","
      end
    end
  end
  str=str:sub(1,#str-1)


  os.execute([[powershell $port= new-Object System.IO.Ports.SerialPort COM3,115200,None,8,one; $port.open(); $port.Write(@(]]..str..[[),0,]]..tostring(datalength)..[[); $port.Close();]])
  local clock = os.clock
  function sleep(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
  end
  --sleep(0.01)
end
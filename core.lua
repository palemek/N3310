apple={}
snake_table={}
snake_head=1
snake_direction=0
snake_length_to_add=0
function _LOAD()
  snake_table[1]={83,10}
  snake_table[2]={82,10}
  snake_direction=3
  apple={30,30}
  SETPIXEL(apple[1],apple[2],true);
end
accdt=0
function _LOOP(dt)
  accdt=accdt+dt
  if accdt<0.1 then
    return
  end
  accdt=accdt-0.1
  if ISKEYPRESSED("w") then
    if not (snake_direction==2) then
      snake_direction=0
    end
  elseif ISKEYPRESSED("d") then
    if not (snake_direction==3) then
      snake_direction=1
    end
  elseif ISKEYPRESSED("s") then
    if not (snake_direction==0) then
      snake_direction=2
    end
  elseif ISKEYPRESSED("a") then
    if not (snake_direction==1) then
      snake_direction=3
    end
  else
    --
  end
  --stara pozycja glowy
  local phx,phy=snake_table[snake_head][1],snake_table[snake_head][2]
  
  --ustalenie nowego indexu glowy
  snake_head=snake_head-1
  if snake_head<=0 then
    snake_head=#snake_table
  end
  
  --pozycja ogona od usuniecia
  local x,y = snake_table[snake_head][1],snake_table[snake_head][2]
  
  --o ile nie ma dlugosci do dodania
  if snake_length_to_add==0 then
    --usuniecie pixela za ogonem(czyli ten na którego wskazuje obecnie snake_head)
    SETPIXEL(x,y,false)
  else
    local tl=#snake_table
    for i=0,tl-snake_head do
      snake_table[tl-i+1]=snake_table[tl-i]
    end
    snake_table[snake_head]={x,y}
    snake_head=snake_head+1
    snake_length_to_add=snake_length_to_add-1
  end
  --ustawienie nowej pozycji dla glowy
  snake_table[snake_head]={phx,phy}
  
  if snake_direction==0 then
    snake_table[snake_head][2]=snake_table[snake_head][2]-1
    if snake_table[snake_head][2]<=0 then
      snake_table[snake_head][2]=SCREEN_Y_RES
    end
  elseif snake_direction==1 then
    snake_table[snake_head][1]=snake_table[snake_head][1]+1
    if snake_table[snake_head][1]>SCREEN_X_RES then
      snake_table[snake_head][1]=1
    end
  elseif snake_direction==2 then
    snake_table[snake_head][2]=snake_table[snake_head][2]+1
    if snake_table[snake_head][2]>SCREEN_Y_RES then
      snake_table[snake_head][2]=1
    end
  elseif snake_direction==3 then
    snake_table[snake_head][1]=snake_table[snake_head][1]-1
    if snake_table[snake_head][1]<=0 then
      snake_table[snake_head][1]=SCREEN_X_RES
    end
  end
  --ustawienie pixela w miejscu glowy
  SETPIXEL(snake_table[snake_head][1],snake_table[snake_head][2],true)
  
  --sprawdz czy nie wlazles se na ogon kretynie
  for i,p in pairs(snake_table) do
    if (not (i==snake_head)) and (p[1]==snake_table[snake_head][1]) and (p[2]==snake_table[snake_head][2]) then
      DRAW(30,30,tex_youLost)
    end
  end
  
  --sprawdz czy w miejscu glowy nie ma jablka
  if (snake_table[snake_head][1]==apple[1]) and (snake_table[snake_head][2]==apple[2]) then
    --zrob nowe jablko
    --TRZEBA DODAC SPRAWDZENIE CZY JEST WAZ W MIEJSCU JABLKA!
    apple={math.floor(love.math.random()*SCREEN_X_RES)+1,math.floor(love.math.random()*SCREEN_Y_RES)+1}
    snake_length_to_add=snake_length_to_add+8;
    SETPIXEL(apple[1],apple[2],true)
  end
end
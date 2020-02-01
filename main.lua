require "core"
require "images"
isEditor=false

SCREEN_CELL=5
SCREEN_CELL_MARGIN=1
SCREEN_X_RES=84
SCREEN_Y_RES=48


tex_youLost={
{true,false,false,false,false,false,true,false,false,true,true,true,false,false,true,false,false,false,true,false,false,false,false,false,true,false,false,false,false,false,true,true,true,false,false,false,true,true,true,true,false,true,true,true,true,true,false},
{false,true,false,false,false,true,false,false,true,false,false,false,true,false,true,false,false,false,true,false,false,false,false,false,true,false,false,false,false,true,false,false,false,true,false,true,false,false,false,false,false,false,false,true,false,false,false},
{false,false,true,false,true,false,false,false,true,false,false,false,true,false,true,false,false,false,true,false,false,false,false,false,true,false,false,false,false,true,false,false,false,true,false,false,true,true,true,false,false,false,false,true,false,false,false},
{false,false,false,true,false,false,false,false,true,false,false,false,true,false,true,false,false,false,true,false,false,false,false,false,true,false,false,false,false,true,false,false,false,true,false,false,false,false,false,true,false,false,false,true,false,false,false},
{false,false,false,true,false,false,false,false,true,false,false,false,true,false,true,false,false,false,true,false,false,false,false,false,true,false,false,false,false,true,false,false,false,true,false,false,false,false,false,true,false,false,false,true,false,false,false},
{false,false,false,true,false,false,false,false,false,true,true,true,false,false,false,true,true,true,false,false,false,false,false,false,true,true,true,true,false,false,true,true,true,false,false,false,true,true,true,false,false,false,false,true,false,false,false},
}

function updateWindowSize()
	SCREEN_WIDTH=SCREEN_X_RES*(SCREEN_CELL+SCREEN_CELL_MARGIN)+SCREEN_CELL_MARGIN
	SCREEN_HEIGHT=SCREEN_Y_RES*(SCREEN_CELL+SCREEN_CELL_MARGIN)+SCREEN_CELL_MARGIN
	love.window.setMode(SCREEN_WIDTH,SCREEN_HEIGHT)
end
function love.load(arg)
	if arg[1]=="editor" then
		isEditor=true
	end
	updateWindowSize()
	loadscreen()
	
	if not isEditor then
		_LOAD()
	else
		--kod load editora
	end
end


screenData={}
function loadscreen()
	for i=1,SCREEN_Y_RES do
		screenData[i]={}
		for j=1,SCREEN_X_RES do
			screenData[i][j]=false
		end
	end
end
keypressed={}
function love.keypressed(key)
	print(key)
	if key=="-" then
		SCREEN_CELL=math.max(1,SCREEN_CELL-1)
		updateWindowSize()
	elseif key=="=" then
		SCREEN_CELL=SCREEN_CELL+1
		updateWindowSize()
	elseif key=="[" then
		SCREEN_CELL_MARGIN=math.max(0,SCREEN_CELL_MARGIN-1)
		updateWindowSize()
	elseif key=="]" then
		SCREEN_CELL_MARGIN=SCREEN_CELL_MARGIN+1
		updateWindowSize()
	elseif key=="backspace" then
		SWAPCOLORS=not SWAPCOLORS
	else
		if isEditor then
			if key=="z" and keypressed["lctrl"] then
				loadPrevAction()
			end
		end
	end
	keypressed[key]=true
end
function love.keyreleased(key)
	keypressed[key]=nil
end
--------------------------------------------------[[]]
function ISKEYPRESSED(key)
	return keypressed[key]
end
SWAPCOLORS=false
function SETPIXEL(x,y,v)
	if x<1 or x>SCREEN_X_RES or y<1 or y>SCREEN_Y_RES then
		return
	end
	
	screenData[y][x]=v
end
--CAMERA_X=0
--CAMERA_Y=0
--function SETCAMERAPOS(x,y)
--	CAMERA_X=x
--	CAMERA_Y=y
--end
--function GETCAMERAPOS()
--	return CAMERA_X,CAMERA_Y
--end
function DRAW(x,y,data)
	for i,p in pairs(data) do
		for j,k in pairs(data[i]) do
			local v=data[i][j];
			if v~=0 then
				v= (v==2)
				SETPIXEL(x+j,y+i,v)
			end
		end
	end
end
function DRAWIMG(x,y,imgPath)
	local img=IMAGES[imgPath]
	DRAW(x,y,img)
end
function CLEAR()
	for x=1,SCREEN_X_RES do
		for y=1,SCREEN_Y_RES do
			SETPIXEL(x,y,false)
		end
	end
end
function RECTANGLE(x,y,w,h)
	for i=x,(x+w) do
		for j=y,(y+h) do
			SETPIXEL(i,j,true)
		end
	end
end
--------------------------------------------------[[]]
--[[]]------------------------------------------------

--[[]]------------------------------------------------
function love.update(dt)
	if not isEditor then
		_LOOP(dt)
	else
		--kod loop editora
	end
end
MOUSELISPRESSED=false
MOUSERISPRESSED=false
MOUSEMISPRESSED=false

brushSize=0
function drawWithBrush(x,y,value)
	local x=math.floor(1+x/(SCREEN_CELL+SCREEN_CELL_MARGIN))
	local y=math.floor(1+y/(SCREEN_CELL+SCREEN_CELL_MARGIN))
	for i=math.max(1,x-brushSize),math.min(SCREEN_X_RES,x+brushSize) do
		for j=math.max(1,y-brushSize),math.min(SCREEN_Y_RES,y+brushSize) do
			SETPIXEL(i,j,value)
		end
	end
end
drawingmode="p" -- p is for pixel,l is for line, r is for rectangle
--startmouse x & y
smx=0
smy=0

function love.mousepressed(x,y,button,istouch,presses)
	prevStates[#prevStates+1]=deepcopy(screenData)
	drawingmode="p"
	
	if keypressed["l"] then
		drawingmode="l"
		smx=x
		smy=y
	end
	
	if button==1 then
		MOUSELISPRESSED=true
		drawWithBrush(x,y,true)
	elseif button==2 then
		MOUSERISPRESSED=true
		drawWithBrush(x,y,false)
	elseif button==3 then
		MOUSEMISPRESSED=true
	end
	if not isEditor then
		--hmm
	else
		
	end
end
function love.mousereleased(x,y,button,istouch,presses)
	drawingmode="p"
	if button==1 then
		MOUSELISPRESSED=false
	elseif button==2 then
		MOUSERISPRESSED=false
	elseif button==3 then
		MOUSEMISPRESSED=false
	end
end
function love.mousemoved( x, y, dx, dy, istouch )
	if not isEditor then
		--hmm
	else
		--TODO
		if drawingmode=="p" then
			if MOUSELISPRESSED and (not MOUSERISPRESSED) then
				drawWithBrush(x,y,true)
			elseif MOUSERISPRESSED then
				drawWithBrush(x,y,false)
			end
		elseif drawingmode=="l" then
			local rx,ry=love.mouse.getPosition()
			local smx,smy	=math.floor(1+smx/(SCREEN_CELL+SCREEN_CELL_MARGIN)),math.floor(1+smy/(SCREEN_CELL+SCREEN_CELL_MARGIN))
			local rx,ry		=math.floor(1+rx/(SCREEN_CELL+SCREEN_CELL_MARGIN)),math.floor(1+ry/(SCREEN_CELL+SCREEN_CELL_MARGIN))
			local minx,maxx=math.min(smx,rx),math.max(smx,rx)
			local miny,maxy=math.min(smy,ry),math.max(smy,ry)
			local a=(smx-rx)/(smy-ry)
			local b=(smy*rx-ry*smx)/(smy-ry)
			if maxy==miny then
				return
			end
			screenData=deepcopy(prevStates[#prevStates])
			for j=miny,maxy do
				local lminx,lmaxx=math.floor(((j-0.5)*a+b)+0.5),math.floor(((j+0.5)*a+b)+0.5)+1
				--print("lminx,lmaxx|"..lminx..","..lmaxx)
				for i=math.min(lminx,lmaxx),math.max(lminx,lmaxx) do
					SETPIXEL(i,j,true)
				end
			end
		elseif drawingmode=="r" then
		end
	end
end
function love.wheelmoved(x,y)
	brushSize=math.max(0,brushSize+y)
end
prevStates={}
function loadPrevAction()
	if #prevStates==0 then
		return
	end
	print("cofam z akcji numer: "..#prevStates)
	screenData=prevStates[#prevStates]
	prevStates[#prevStates]=nil
end
function love.draw()
	local setC = function(b)
		if b then
			love.graphics.setColor(0.7804,0.9804,0.847,1)
		else
			love.graphics.setColor(0.2627,0.322,0.239,1)
		end
	end
	love.graphics.setColor(0,0,0,1)
	love.graphics.rectangle("fill",0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
	
	local currcolor=true
	setC(false)
	
	for y,p in pairs(screenData) do--love.graphics.rectangle("fill",100,100,84,48);
		for x,p in pairs(screenData[y]) do
			if SWAPCOLORS then
				setC(not screenData[y][x])
			else
				setC(screenData[y][x])
			end
			--if not (screenData[y][x]==currcolor) then
			--	currcolor=screenData[y][x]
			--	setC(currcolor)
			--end
			--print(x.." "..y)
			love.graphics.rectangle("fill",(x-1)*(SCREEN_CELL+SCREEN_CELL_MARGIN)+SCREEN_CELL_MARGIN,(y-1)*(SCREEN_CELL+SCREEN_CELL_MARGIN)+SCREEN_CELL_MARGIN,SCREEN_CELL,SCREEN_CELL);
		end
	end
end

function deepcopy(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
			end
			setmetatable(copy, deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

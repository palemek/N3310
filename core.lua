require "levels"

function _LOAD()
	CLEAR(true)
	currmode=mode_menu
	mode_menu:init()
	PLAYMUSIC("chopin")
end
function _LOOP(dt)
	if ISKEYPRESSED("1") then
		transition:start(mode_game,{lvl="lvl1"})
	end
	if ISKEYPRESSED("2") then
		transition:start(mode_game,{lvl="lvl2"})
	end
	if ISKEYPRESSED("3") then
		transition:start(mode_game,{lvl="lvl3"})
	end
	if ISKEYPRESSED("4") then
		transition:start(mode_EndGameCredits)
	end
	currmode:update(dt)
	if transition.enabled then
		transition:update(dt)
	end
end
GRAVITY=0.1
transition=
{
	enabled=false;
	progress=0;
	maxProgress=SCREEN_Y_RES;
	nextmode=nil;
	nextmodeData=nil;
	didHalfway=false;
	start=function(self,nextmode,data)
		if self.enabled then
			return
		end
		if data and data.lvl and data.lvl=="won" then
			nextmode=mode_EndGameCredits
			--TUTAJ SPAWNUJEMY END GAME CREDITS
		end
		print("start some mode")
		self.didHalfway=false;
		self.nextmode=nextmode;
		self.enabled=true;
		self.progress=0;
		self.maxProgress=SCREEN_Y_RES;
		self.nextmodeData=data;
	end;
	update=function(self)
		DRAWIMG(SCREEN_Y_RES-4.0*self.progress,0,"transition.png")
		
		self.progress=self.progress+1
		if self.progress>=self.maxProgress then
			self:finished()
		elseif self.progress>=self.maxProgress*(3/8) and (not self.didHalfway) then
			self.didHalfway=true;
			self:halfway()
		end
	end;
	halfway=function(self)
		currmode["finish"](currmode)
		currmode=self.nextmode;
		currmode:init(self.nextmodeData);
		print("some mode init")
	end;
	finished=function(self)
		self.enabled=false
		print("transition finito")
	end;
}


mode_menu=
{
	index=0; -- index jak 0 to ekran startowy, jak wiecej to index z cutsceneList
	menuTime=0;
	whoopsMax=0.8;
	whoops=-1;
	cutsceneList={
		--[[tutaj pathy do cutscenek i czasy - czy robimy przejscia miedzy cutscenkami jakies triki? --DO UZUPELNIENIA!!!!!!!!!!
		TAK, przesuwanie ekranu lewo prawo góra dół w czasie wiec
		{anim=bil--dozrobienia w init'cie,imagePaths,timeBetweenFrames,direction=}]]
		{imagePaths={
			"cut_scenes_cut_work_korpo.png"
			},
			timeBetweenFrames=1.5,direction="left"};
		{imagePaths={
			"cut_scenes_cut_collect_soul.png"
			},
			timeBetweenFrames=2,direction="down"};
		{imagePaths={
			"cut_scenes_cut_dream.png"
			},
			timeBetweenFrames=1.8,direction="top"};
		{imagePaths={
			"cut_scenes_cut_work_korpo.png"
			},
			timeBetweenFrames=1,direction="left"};
		{imagePaths={
			"cut_scenes_cut_work_quit.png"
			},
			timeBetweenFrames=2,direction="left"};
		{imagePaths={
			"cut_scenes_cut_lapie_kose.png"
			},
			timeBetweenFrames=1.5,direction="left"};
		{imagePaths={
			"cut_scenes_cut_catch_him.png"
			}
			,timeBetweenFrames=2.5,direction="left"};
		
	};
	init=function(self)
		--DRAWIMG(0,0,"cut_scenes_cut_reaper.png");
		for i=1,#self.cutsceneList do
			self.cutsceneList[i].anim=CutsceneAnimMaker(self.cutsceneList[i].imagePaths,self.cutsceneList[i].timeBetweenFrames);
		end
	end;
	finish=function(self)
		print("menu finishing")
	end;
	zpressedtime=0;
	update=function(self,dt)
		if ISKEYPRESSED("z") then
			self.zpressedtime=self.zpressedtime+dt
			if self.zpressedtime>1 then
				transition:start(mode_game,{lvl="lvl1"})
			end
		else
			self.zpressedtime=0
		end
		if self.whoops~=-1 then
			--jest przejscie obecnie
			self.whoops=self.whoops+dt
			
			local dir=nil
			local currLastFrame=nil
			if self.index==0 then
				dir="left"
				currLastFrame="cut_scenes_cut_reaper.png"
			else
				dir=self.cutsceneList[self.index].direction
				currLastFrame=self.cutsceneList[self.index].imagePaths[#self.cutsceneList[self.index].imagePaths]
			end
			local nextFirstFrame=self.cutsceneList[self.index+1].imagePaths[1]
			
			local progx=math.floor((self.whoops/self.whoopsMax)*SCREEN_X_RES);
			local progy=math.floor((self.whoops/self.whoopsMax)*SCREEN_Y_RES);
			
			if dir=="top" then
				DRAWIMG(0,-progy,currLastFrame)
				DRAWIMG(0,SCREEN_Y_RES-progy,nextFirstFrame)
			elseif dir=="down" then
				DRAWIMG(0,progy,currLastFrame)
				DRAWIMG(0,-SCREEN_Y_RES+progy,nextFirstFrame)
			elseif dir=="left" then
				DRAWIMG(-progx,0,currLastFrame)
				DRAWIMG(SCREEN_X_RES-progx,0,nextFirstFrame)
			else
				DRAWIMG(progx,0,currLastFrame)
				DRAWIMG(-SCREEN_X_RES+progx,0,nextFirstFrame)
			end
			
			if self.whoops>=self.whoopsMax then
				self.whoops=-1
				self.index=self.index+1
			end
		else
			if self.index==0 then
				--jestesmy w menu
				self.menuTime=self.menuTime+dt
				if ISKEYPRESSED("z") then
					self.whoops=0
				end
				if self.menuTime%1>0.7 then
				DRAWIMG(0,0,"cut_scenes_opening_screen2.png")
				else
				DRAWIMG(0,0,"cut_scenes_opening_screen.png")
				end
			else
				--cutscenki
				local img,fin=self.cutsceneList[self.index].anim(dt)
				
				if fin then --jezeli skonczylismy aktualna animacje
					if self.index==#self.cutsceneList then --jezeli to byla ostatnia animacja
						transition:start(mode_game,{lvl="lvl1"})
					else --jezeli to nie byla ostatnia animacja
						self.whoops=0;--zacznij tranzycje do nastepnej
					end
				end
				DRAWIMG(0,0,img)
			end
			
		end
	end;
}

CutsceneAnimMaker=function(framesPaths,timeBetweenFrames)
	local id=0
	local skipper=0
	local ret=function(dt)
		local justFinished=false
		if skipper>=timeBetweenFrames then
			skipper=0;
			id=id+1;
			if id>#framesPaths then
				justFinished=true
				id =#framesPaths;
			end
		else
			if id==0 then
				id=1
			end
			skipper=skipper+dt;
		end
		return framesPaths[id],justFinished
	end
	return ret
end


mode_game=
{
	cullLvlData=nil;
	init=function(self,data)
		PLAYMUSIC("minorMario")
		--preapare everything
		--spawn everything
		self.currLvlData=LEVELS[data.lvl];
		
		
		playerref=object_player		({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=6,h=13,dox=-6,doy=0,name="player"})
		ogon0=object_ogon			({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=5,h=5,name="ogon0",img="sphere6.png",length=0,parent=playerref,pox=-2,poy=5})
		local ogon1=object_ogon		({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=4,h=4,name="ogon1",img="sphere4.png",length=2,parent=ogon0,poy=1})
		local ogon2=object_ogon		({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=2,h=2,name="ogon2",img="sphere2.png",length=1.5,parent=ogon1,poy=0.7})
		local ogon3=object_ogon		({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=1,h=1,name="ogon3",img="sphere1.png",length=0.5,parent=ogon2,poy=0.5})
		local ogon4=object_ogon		({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=1,h=1,name="ogon4",img="sphere1.png",length=0.4,parent=ogon3})
		kaptur0=object_ogon			({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=4,h=4,name="kaptur0",img="sphere4.png",length=0,parent=playerref,pox=-2.5,poy=-4})
		local kaptur1=object_ogon	({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=3,h=3,name="kaptur1",img="sphere3.png",length=1,parent=kaptur0})
		local kaptur2=object_ogon	({x=LEVELS[data.lvl].px,y=LEVELS[data.lvl].py,w=1,h=1,name="kaptur2",img="sphere1.png",length=0.3,parent=kaptur1})
		
		camera.x=math.max(0,playerref.x-SCREEN_X_RES/2);
		camera.y=math.max(0,playerref.y-SCREEN_Y_RES/2);
		
		
		for y,d in pairs(LEVELS[data.lvl]) do
			if type(y)=="string" then
				break
			end
			for x,v in pairs(d) do
				local px,py=(x-1)*7,(y-1)*7
				if v==0 then
				elseif v==1 then
					object_colliding({x=px,y=py,w=7,h=7,name="obj1"})
				elseif v==2 then
					object_door({x=px,y=py,w=7,h=7,name="door",img="sphere1.png",nextlevel="lvl2"})
				elseif v==3 then
					object_door({x=px,y=py,w=7,h=7,name="door",img="sphere1.png",nextlevel="lvl3"})
				elseif v==4 then
					object_door({x=px,y=py,w=7,h=7,name="door",img="sphere1.png",nextlevel="won"})
				elseif v==5 then
					object({x=px,y=py,name="arrow",img="obiekty_arrows_hor.png"})
				elseif v==6 then
					object({x=px,y=py,name="arrow",img="obiekty_arrows_hor.png",flipx=true})
				elseif v==7 then
					object({x=px,y=py,name="arrow",img="obiekty_arrows_ver.png"})
				elseif v==8 then
					object({x=px,y=py,name="arrow",img="obiekty_arrows_ver2.png"})
				elseif v==10 then
					local liczbakolejnychplat=0
					local xtocheck=x+1
					while d[xtocheck]==11 do
						liczbakolejnychplat=liczbakolejnychplat+1
						xtocheck=xtocheck+1
					end
					object_platform_hor({x=px,y=py,w=15,h=7,name="platform",img="obiekty_tiles_biom1_t1_2x1.png",movementSpeed=0.3,movementMin=px,movementMax=px+liczbakolejnychplat*7})
				elseif v==11 then
					--RESERVED FOR PLATFORM_HOR HELPER
				elseif v==12 then
					local liczbakolejnychplat=0
					local ytocheck=y+1
					while LEVELS[data.lvl][ytocheck][x]==13 do
						liczbakolejnychplat=liczbakolejnychplat+1
						ytocheck=ytocheck+1
					end
					object_platform_ver({x=px,y=py,w=15,h=7,name="platform",img="obiekty_tiles_t2_2x1.png",movementSpeed=0.3,movementMin=py,movementMax=py+liczbakolejnychplat*7})
				elseif v==13 then
					--RESERVED FOR PLATFORM_HOR HELPER
				elseif v==14 then
					
					object_colliding({x=px,y=py,w=7,h=7,name="obj2",img="obiekty_tiles_biom1_t1_1x1.png"})			--14
				elseif v==15 then
					object_colliding({x=px,y=py,w=7,h=14,name="obj2",img="obiekty_tiles_biom1_1x2_chair.png"})		--15
				elseif v==16 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_biom1_t1_2x1.png"})			--16
				elseif v==17 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_biom1_t1_2x1_komp"})		--17
				elseif v==18 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom1_t1_2x2.png"})		--18
				elseif v==19 then
					object_colliding({x=px,y=py,w=21,h=7,name="obj2",img="obiekty_tiles_biom1_t1_3x1_desk.png"})	--19
					
				elseif v==20 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t1_2x1.png"})
				elseif v==21 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t2_2x1.png"})
				elseif v==22 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t3_2x1.png"})
				elseif v==23 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t4_2x1.png"})
				elseif v==24 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t5_2x1.png"})
				elseif v==25 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t6_2x1.png"})
				elseif v==26 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t7_2x1.png"})
				elseif v==27 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t8_2x1.png"})
				elseif v==28 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t9_2x1.png",doy=-2})
				elseif v==29 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t10_2x1.png",dox=-1,doy=-1})
				elseif v==30 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t11_2x1.png"})
				elseif v==31 then
					object_colliding({x=px,y=py,w=14,h=7,name="obj2",img="obiekty_tiles_t12_2x1.png"})
				elseif v==32 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom3_t3w_2x2.png"})
				elseif v==33 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom3_t3b_2x2.png"})
				elseif v==34 then
					object_colliding({x=px,y=py,w=21,h=21,name="obj2",img="obiekty_tiles_biom3_t3b_3x3.png"})
				elseif v==35 then
					object_colliding({x=px,y=py,w=21,h=21,name="obj2",img="obiekty_tiles_biom3_t3w_3x3.png"})
				elseif v==36 then
					object_colliding({x=px,y=py,w=28,h=28,name="obj2",img="obiekty_tiles_biom3_t3_4x4.png",dox=-1})
				elseif v==37 then
					local liczbakolejnychplat=0
					local xtocheck=x+1
					while d[xtocheck]==38 do
						liczbakolejnychplat=liczbakolejnychplat+1
						xtocheck=xtocheck+1
					end
					object_platform_hor({x=px,y=py,w=21,h=7,name="platform",img="obiekty_tiles_biom3_t3_3x1.png",movementSpeed=0.3,movementMin=px,movementMax=px+liczbakolejnychplat*7})
				elseif v==38 then
					--FORBIDDEN
				elseif v==39 then
					local liczbakolejnychplat=0
					local ytocheck=y+1
					while LEVELS[data.lvl][ytocheck][x]==40 do
						liczbakolejnychplat=liczbakolejnychplat+1
						ytocheck=ytocheck+1
					end
					object_platform_ver({x=px,y=py,w=15,h=7,name="platform",img="obiekty_tiles_biom3_t3_3x1.png",movementSpeed=0.2,movementMin=py,movementMax=py+liczbakolejnychplat*7})
				elseif v==40 then
					--FORBIDDEN
				elseif v==42 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom3_t3w_2x2.png",flipx=true})
				elseif v==43 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom3_t3b_2x2.png",flipx=true})
				elseif v==44 then
					object_colliding({x=px,y=py,w=21,h=21,name="obj2",img="obiekty_tiles_biom3_t3b_3x3.png",flipx=true})
				elseif v==45 then
					object_colliding({x=px,y=py,w=21,h=21,name="obj2",img="obiekty_tiles_biom3_t3w_3x3.png",flipx=true})
				elseif v==46 then
					object_colliding({x=px,y=py,w=28,h=28,name="obj2",img="obiekty_tiles_biom3_t3_4x4.png",flipx=true,dox=-1})
				elseif v==51 then
					object_colliding({x=px,y=py,w=21,h=7,name="drzwi tyl",img="obiekty_exit_e1.png",doy=-1})
					object_infront({x=px,y=py,name="drzwi przod",img="obiekty_exit_e1_2.png",doy=-1})
				elseif v==52 then
				elseif v==61 then
				elseif v==62 then
					object_inback({x=px,y=py,name="tlo",img="tla_b3.png"})
				elseif v==63 then
					object_inback({x=px,y=py,name="tlo",img="tla_b1.png"})
				elseif v==64 then
					object_inback({x=px,y=py,name="tlo",img="tla_b2.png"})
				elseif v==70 then
					object_colliding({x=px,y=py,w=7,h=7,name="tile",img="obiekty_tiles_biom2_t2_1x1.png",dox=-1})
				elseif v==71 then
					object_colliding({x=px,y=py,w=14,h=7,name="tile",img="obiekty_tiles_biom2_t2_2x1.png",dox=-1})
				elseif v==72 then
					object_colliding({x=px,y=py,w=14,h=7,name="tile",img="obiekty_tiles_biom2_t2b_2x1.png"})
				elseif v==73 then
					object_colliding({x=px,y=py,w=21,h=7,name="tile",img="obiekty_tiles_biom2_t2_3x1.png"})
				elseif v==74 then
					object_colliding({x=px,y=py,w=21,h=7,name="tile",img="obiekty_tiles_biom2_t2b_3x1.png"})
				elseif v==75 then
					object_colliding({x=px,y=py,w=28,h=7,name="tile",img="obiekty_tiles_biom2_t2_4x1.png"})
				elseif v==76 then
					object_colliding({x=px,y=py,w=28,h=7,name="tile",img="obiekty_tiles_biom2_t2_4x1.png"})
				elseif v==77 then
					object_colliding({x=px,y=py,w=7,h=28,name="tile",img="obiekty_tiles_biom2_t2_1x4.png"})
				elseif v==78 then
					object_colliding({x=px,y=py,w=7,h=42,name="tile",img="obiekty_tiles_biom2_t2_1x6.png",dox=-1})
				elseif v==79 then
					object_colliding({x=px,y=py,w=161,h=3,name="tile",img="obiekty_tiles_biom2_t2_23x1.png"})
				elseif v==80 then
					object_colliding({x=px,y=py,w=35,h=7,name="tile",img="obiekty_tiles_biom2_t2_5x1.png"})
				elseif v==81 then
					object_colliding({x=px,y=py,w=35,h=7,name="tile",img="obiekty_tiles_biom2_t2_5x1.png",flipx=true})
				elseif v==82 then
					object({x=px,y=py,name="tile",img="obiekty_tiles_biom2_d2_1x23.png"})
				elseif v==83 then
					object({x=px,y=py,name="tile",img="obiekty_tiles_biom2_d2_1x23.png",flipx=true})
				elseif v==84 then
					local liczbakolejnychplat=0
					local ytocheck=y+1
					while LEVELS[data.lvl][ytocheck][x]==85 do
						liczbakolejnychplat=liczbakolejnychplat+1 
						ytocheck=ytocheck+1
					end
					object_platform_ver({x=px,y=py,w=21,h=7,name="platform",img="obiekty_tiles_biom2_t2_3x1.png",movementSpeed=0.2,movementMin=py,movementMax=py+liczbakolejnychplat*7})
					
				elseif v==85 then
					--forbidden
				elseif v==86 then
					local liczbakolejnychplat=0
					local xtocheck=x+1
					while d[xtocheck]==87 do
						liczbakolejnychplat=liczbakolejnychplat+1
						xtocheck=xtocheck+1
					end
					object_platform_hor({x=px,y=py,w=21,h=7,name="platform",img="obiekty_tiles_biom2_t2_3x1.png",movementSpeed=0.3,movementMin=px,movementMax=px+liczbakolejnychplat*7})
				elseif v==87 then
					--RESERVED FOR PLATFORM_HOR HELPER
				elseif v==88 then
					object_colliding({x=px,y=py,w=21,h=7,name="obj2",img="obiekty_tiles_biom1_t1_3x2_desk_chair.png",doy=-7})			--88
				elseif v==89 then
					object_colliding({x=px,y=py,w=35,h=7,name="obj2",img="obiekty_tiles_biom1_t1_5x1.png"})
				elseif v==90 then
					object_colliding({x=px,y=py,w=154,h=7,name="obj2",img="obiekty_tiles_biom1_t1_22x1.png"})
				elseif v==91 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom1_t1a_2x2.png"})
				elseif v==92 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom1_t1b_2x2_.png"})
				elseif v==93 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom1_t1c_2x2.png"})
				elseif v==94 then
					object_colliding({x=px,y=py,w=14,h=14,name="obj2",img="obiekty_tiles_biom1_t1w_2x2.png"})							--94
				elseif v==97 then
					object_bat({x=px,y=py,w=8,h=5,name="bat",dox=-3,dox=-1})
				elseif v==98 then
					local zlolx,zloly=px,py-3
					object_zlol({x=zlolx,y=zloly,w=4,h=10,dox=-2,doy=-3,img="postaci_zlol_idle_1.png"})
				elseif v==99 then
					local zlolx,zloly=px,py
					object_faflun({x=zlolx,y=zloly,w=6,h=14,dox=-2,doy=-3,img="postaci_faflun_walk_4.png",dox=-2,doy=-1})
				end
			end
		end
		if data.lvl=="lvl3" then
			object_colliding({x=-7,y=0,w=7,h=48*7,img="sphere1.png"})
			object_colliding({x=84,y=0,w=7,h=48*7,img="sphere1.png"})
		end
	end;
	update=function(self,dt)
		CLEAR(true)
		camera:update(dt)
		allobjects_inback:startupdate(dt)
		allobjects:startupdate(dt)
		allobjects_infront:startupdate(dt)
		alloverlapping:update(dt)
		allobjects_inback:endupdate(dt)
		allobjects:endupdate(dt)
		allobjects_infront:endupdate(dt)
		
	end;
	finish=function(self)
		print("game finishing")
		allobjects:clear()
		allobjects_infront:clear()
		allobjects_inback:clear()
		alloverlapping:clear()
	end;
	lostGame=function(self)
		transition:start(mode_Lost)
	end
}
mode_EndGameCredits=
{
	mytime=0;
	init=function(self)
		PLAYMUSIC("majorMario")
		self.anim=AnimMaker(
			{
				"cut_scenes_you_won1.png",
				"cut_scenes_you_won2.png"
			},5)
	end;
	update=function(self,dt)
		self.mytime=self.mytime+dt
		local imageHeight=2*SCREEN_Y_RES --TRZEBA BEDZIE ZMIENIC
		local img=self.anim()
		DRAWIMG(0,math.min(0,math.max(math.floor(10-self.mytime*5),-SCREEN_Y_RES)),img)
	end;
	finish=function(self)
	end;
}
mode_Lost=
{
	init=function(self)
		PLAYMUSIC("chopin")
	end;
	update=function(self,dt)
		if ISKEYPRESSED("z") then
			transition:start(mode_game,{lvl="lvl1"})
		end
		DRAWIMG(0,0,"cut_scenes_you_lost.png")
	end;
	finish=function(self)
	end;
}
playerref=nil
camera=
{
	x=10;
	y=10;
	update=function(self,dt)
		local lvlHeight=#mode_game.currLvlData*7
		local lvlWidth=#mode_game.currLvlData[1]*7
		
		local plmx,plmy=math.floor(playerref.x+playerref.w/2+0.5),math.floor(playerref.y+playerref.h/2+0.5)
		if plmx-(self.x+SCREEN_X_RES/2)>-10 then
			if self.x+SCREEN_X_RES < lvlWidth then
				self.x=self.x+1
			end
		elseif plmx-(self.x+SCREEN_X_RES/2)<-20 then
			if self.x>0 then
				self.x=self.x-1
			end
		end
		if plmy-(self.y+SCREEN_Y_RES/2)>10 then
			if self.y+SCREEN_Y_RES < lvlHeight then
				self.y=self.y+1
			end
		elseif plmy-(self.y+SCREEN_Y_RES/2)<-10 then
			if self.y>0 then
				self.y=self.y-1
			end
		end
	end;
}

allobjects={
	clear=function(self)
		local size=#self
		for i=1,size do
			self[size-i+1]=nil
		end
	end;
	todelete={};
	delete=function(self,obj)
		self.todelete[#self.todelete+1]=obj
	end;
	startupdate=function(self,dt)
		for i=1,#self do
			local p=self[#self-i+1]
			p:startupdate(dt);
		end
	end;
	endupdate=function(self,dt)
		for i=1,#self do
			local p=self[#self-i+1]
			
			p:endupdate(dt);
		end
		
		--delete todelete
		for i,obj in pairs(self.todelete) do
			for i,p in pairs(self) do
				if p==obj then
					self[i]=self[#self]
					self[#self]=nil
					break
				end
			end
		end
		self.todelete={}
	end
}
allobjects_infront={
	clear=function(self)
		local size=#self
		for i=1,size do
			self[size-i+1]=nil
		end
	end;
	todelete={};
	delete=function(self,obj)
		self.todelete[#self.todelete+1]=obj
	end;
	startupdate=function(self,dt)
		for i=1,#self do
			local p=self[#self-i+1]
			p:startupdate(dt);
		end
	end;
	endupdate=function(self,dt)
		for i=1,#self do
			local p=self[#self-i+1]
			p:endupdate(dt);
		end
		
		--delete todelete
		for i,obj in pairs(self.todelete) do
			for i,p in pairs(self) do
				if p==obj then
					self[i]=self[#self]
					self[#self]=nil
					break
				end
			end
		end
		self.todelete={}
	end
}
allobjects_inback={
	clear=function(self)
		local size=#self
		for i=1,size do
			self[size-i+1]=nil
		end
	end;
	todelete={};
	delete=function(self,obj)
		self.todelete[#self.todelete+1]=obj
	end;
	startupdate=function(self,dt)
		for i=1,#self do
			local p=self[#self-i+1]
			p:startupdate(dt);
		end
	end;
	endupdate=function(self,dt)
		for i=1,#self do
			local p=self[#self-i+1]
			p:endupdate(dt);
		end
		
		--delete todelete
		for i,obj in pairs(self.todelete) do
			for i,p in pairs(self) do
				if p==obj then
					self[i]=self[#self]
					self[#self]=nil
					break
				end
			end
		end
		self.todelete={}
	end
}
alloverlapping={
	clear=function(self)
		local size=#self
		for i=1,size do
			self[size-i+1]=nil
		end
	end;
	isCollisionAt=function(self,x,y,isMovable)
		for i=1,#self do
			if self[i].isMovable==isMovable then
				if self[i].x<=x and self[i].x+self[i].w>x and self[i].y<=y and self[i].y+self[i].h>y then
					return true,self[i]
				end
			end
		end
		return false
	end;
	isCollisionAtWithType=function(self,x,y,othertype)
		for i=1,#self do
			if self[i].type==othertype then
				if self[i].x<=x and self[i].x+self[i].w>x and self[i].y<=y and self[i].y+self[i].h>y then
					return true,self[i]
				end
			end
		end
		return false
	end;
	isSquareCollisionAtWithType=function(self,x,y,w,h,othertype)
		for i=1,#self do
			if self[i].type==othertype then
				if not ((self[i].x+self[i].w<=x) or (x+w<=self[i].x) or (self[i].y+self[i].h<=y) or (y+h<=self[i].y)) then
					return true,self[i]
				end
			end
		end
		return false
	end;
	todelete={};
	delete=function(self,obj)
		self.todelete[#self.todelete+1]=obj
	end;
	update=function(self,dt)
		for i=1,#self do
			for j=i+1,#self do
				if self:areoverlapping(self[i],self[j]) then
					self[i]:onoverlap(self[j])
					self[j]:onoverlap(self[i])
				end
			end
		end
		
		--delete todelete
		for i,obj in pairs(self.todelete) do
			for i,p in pairs(self) do
				if p==obj then
					self[i]=self[#self]
					self[#self]=nil
					break
				end
			end
		end
		self.todelete={}
	end;
	areoverlapping=function(self,obj1,obj2)
		if (obj1.x+obj1.w<=obj2.x) or (obj2.x+obj2.w<=obj1.x) or (obj1.y+obj1.h<=obj2.y) or (obj2.y+obj2.h<=obj1.y) then
			return false
		else
			return true
		end
	end
}
object_infront=setmetatable(
{
	startupdate=function(self,dt)
	end;
	endupdate=function(self,dt)
		DRAWIMG(math.floor(self.x+self.dox+0.5)-camera.x,math.floor(self.y+self.doy+0.5)-camera.y,self.img,self.flipx,self.flipy)
	end;
},
{
	__index=object;
	__call=function(self,props)
		local ret=setmetatable({},{__index=self;});
		ret.type="object_infront";
		ret.name=props.name or "none";
		ret.x=props.x or 0;
		ret.y=props.y or 0;
		ret.dox=props.dox or 0;
		ret.doy=props.doy or 0;
		ret.w=props.w or 10;
		ret.h=props.h or 10;
		
		ret.img=props.img or "default7x7.png";
		allobjects_infront[#allobjects_infront+1]=ret;
		return ret;
	end
})
object_inback=setmetatable(
{
	startupdate=function(self,dt)
	end;
	endupdate=function(self,dt)
		DRAWIMG(math.floor(self.x+self.dox+0.5-camera.x/2),math.floor(self.y+self.doy+0.5-camera.y/2),self.img,self.flipx,self.flipy)
	end;
},
{
	__index=object;
	__call=function(self,props)
		local ret=setmetatable({},{__index=self;});
		ret.type="object_inback";
		ret.name=props.name or "none";
		ret.x=props.x or 0;
		ret.y=props.y or 0;
		ret.dox=props.dox or 0;
		ret.doy=props.doy or 0;
		ret.w=props.w or 10;
		ret.h=props.h or 10;
		
		ret.img=props.img or "default7x7.png";
		allobjects_inback[#allobjects_inback+1]=ret;
		return ret;
	end
})
object=setmetatable(
{
	startupdate=function(self,dt)
	end;
	endupdate=function(self,dt)
		DRAWIMG(math.floor(self.x+self.dox+0.5)-camera.x,math.floor(self.y+self.doy+0.5)-camera.y,self.img,self.flipx,self.flipy)
	end;
},
{
	__index=object;
	__call=function(self,props)
		local ret=setmetatable({},{__index=self;});
		ret.type="object";
		ret.name=props.name or "none";
		ret.x=props.x or 0;
		ret.y=props.y or 0;
		ret.dox=props.dox or 0;
		ret.doy=props.doy or 0;
		ret.flipx=props.flipx;
		ret.flipy=props.flipy;
		ret.w=props.w or 10;
		ret.h=props.h or 10;
		
		ret.img=props.img or "default7x7.png";
		allobjects[#allobjects+1]=ret;
		return ret;
	end
})

object_overlapping=setmetatable(
{
	onoverlap=function(self,other)
	end;
},
{
	__index=object;
	__call=function(self,props)
		local ret = getmetatable(object).__call(self, props);
		ret.type="object_overlapping";
		alloverlapping[#alloverlapping+1]=ret;
		return ret;
	end
})

object_colliding=setmetatable(
{
	tryaddoffset=function(self,dx,dy)
		self.taodx=dx;
		self.taody=dy;
		self.befx=self.x;
		self.befy=self.y;
		self.x=self.x+dx;
		self.y=self.y+dy;
	end;
	onoverlap=function(self,other)
		if self.taodx and other.type=="object_colliding" and (not other.isMovable) then
			local fin=function(ret)
				self.taodx,self.taody,self.befx,self.befy=0,0,0,0;
				return ret;
			end
			
			local a=1
			if self.befy+self.h-a<=other.y then
				self.y=other.y-self.h-a
				self.vy=0
			elseif self.befx>=other.x+other.w-a then
				self.x=other.x+other.w+a
				self.vx=0
			elseif self.befx+self.w-a<=other.x then
				self.x=other.x-self.w-a
				self.vx=0
			elseif self.befy>=other.y+other.h-a then
				self.y=other.y+other.h+a
				self.vy=0
			else 
				--self.y=self.y+1
				--print("dupa")
			end
		end
	end;
},
{
	__index=object_overlapping;
	__call=function(self,props)
		local ret = getmetatable(object_overlapping).__call(self, props);
		ret.isMovable=props.isMovable or false;
		ret.type="object_colliding";
		return ret;
	end
})

object_platform_hor=setmetatable(
{
	startupdate=function(self)
		object_colliding.startupdate(self)
		if self.movementSpeed<0 then
			if self.x <= self.movementMin then
				self.movementSpeed=-self.movementSpeed
			end
		else
			if self.x>= self.movementMax then
				self.movementSpeed=-self.movementSpeed
			end
		end
		self.x=self.x+self.movementSpeed
	end;
},
{
	__index=object_colliding;
	__call=function(self,props)
		local ret = getmetatable(object_colliding).__call(self, props);
		ret.movementMin=props.movementMin or ret.x;
		ret.movementMax=props.movementMax or ret.x;
		ret.movementSpeed=props.movementSpeed or 1;
		ret.type="object_colliding";
		return ret;
	end
})

object_platform_ver=setmetatable(
{
	startupdate=function(self)
		object_colliding.startupdate(self)
		if self.movementSpeed<0 then
			if self.y <= self.movementMin then
				self.movementSpeed=-self.movementSpeed
			end
		else
			if self.y>= self.movementMax then
				self.movementSpeed=-self.movementSpeed
			end
		end
		self.y=self.y+self.movementSpeed
	end;
	onoverlap=function(self,other)
		if self.movementSpeed<0 then
			other.y=other.y+2*self.movementSpeed
		end
	end;
},
{
	__index=object_colliding;
	__call=function(self,props)
		local ret = getmetatable(object_colliding).__call(self, props);
		ret.movementMin=props.movementMin or ret.y;
		ret.movementMax=props.movementMax or ret.y;
		ret.movementSpeed=props.movementSpeed or 1;
		ret.type="object_colliding";
		return ret;
	end
})

object_player=setmetatable(
{
	isStanding=0;
	isStandingMax=6;
	isAttacking=false;
	isRight=true;
	startupdate=function(self)
		object_colliding.startupdate(self)
		if alloverlapping:isCollisionAt(self.x,self.y+self.h+1,false) or alloverlapping:isCollisionAt(self.x+self.w-1,self.y+self.h+1,false) then
			self.isStanding=self.isStandingMax;
		else
			self.isStanding=self.isStanding-1
		end
		
		if self.isStanding>0 then
			if self.isStanding==self.isStandingMax then
			else
				self.vy=self.vy+GRAVITY;
			end
			if ISKEYPRESSED("w") then
				self.vy=-2.3;
				--self.anim=AnimMaker({"postaci_reaper_reaper_jump_2.png"},1);
				self.isStanding=0;
			end
		else
			self.vy=self.vy+GRAVITY;
		end
		
		local dx,dy=0,self.vy;
		if ISKEYPRESSED("d") and not ISKEYPRESSED("a") then
			dx=1;
			if self.flipx then
				if self.isAttacking then
				else
					self.flipx=false
					kaptur0.pox=-kaptur0.pox
					ogon0.pox=-ogon0.pox
				end
			end
		elseif ISKEYPRESSED("a") then
			dx=-1;
			if not self.flipx then
				if self.isAttacking then
				else
					self.flipx=true
					kaptur0.pox=-kaptur0.pox
					ogon0.pox=-ogon0.pox
				end
			end
		end
		if ISKEYPRESSED("z") and (not self.isAttacking) then
			--just started attack
			self.isAttacking=true
				kaptur0.poy=kaptur0.poy+2
			if self.flipx then
				kaptur0.pox=kaptur0.pox-2
			else
				kaptur0.pox=kaptur0.pox+2
			end
		end
		
		if dx~=0 or dy~=0 then
			self:tryaddoffset(dx,dy)
		end
		
		if self.isAttacking then
			local justfin=false;
			self.img,justfin=self.AttackAnim();
			if justfin then
				self.isAttacking=false
					kaptur0.poy=kaptur0.poy-2
				if self.flipx then
					kaptur0.pox=kaptur0.pox+2
				else
					kaptur0.pox=kaptur0.pox-2
				end
				self.img=self.IdleAnim();
			else
				if self.flipx then
					local is,other=alloverlapping:isSquareCollisionAtWithType(self.x-5,self.y+2,4,9,"object_zlol")
					if is then
						other:die()
					end
				else
					local is,other=alloverlapping:isSquareCollisionAtWithType(self.x+self.w,self.y+2,4,9,"object_zlol")
					if is then
						other:die()
					end
				end
			end
		elseif self.isStanding>0 then
			self.img=self.IdleAnim();
		elseif self.vy<-0.8 then
			self.img="postaci_reaper_reaper_jump_up.png";
		elseif self.vy>0.8 then
			self.img="postaci_reaper_reaper_jump_down.png";
		else
			self.img="postaci_reaper_reaper_jump_mid.png";
		end
		if self.y>#mode_game.currLvlData*7 then
			mode_game:lostGame()
		end
	end;
	endupdate=function(self)
		object_colliding.endupdate(self)
	end;
},
{
	__index=object_colliding;
	__call=function(self,props)
		local ret = getmetatable(object_colliding).__call(self, props);
		ret.isMovable=true;
		ret.vy=0;
		ret.flipx=false;
		ret.flipy=false;
		
		ret.AttackAnim=AnimMaker({
			"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_f0.png",
			"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_f1.png",
			"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_f2.png",
			"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_f3.png",
			"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_f4.png",
			"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_f5.png",
			"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_f6.png"
		},5);
		ret.IdleAnim=AnimMaker(
		{
			"postaci_reaper_atak_idle_kosa_idle.png"
		},1);
		
		ret.type="object_player";
		return ret;
	end
})
object_fly=setmetatable(
{
	t=0;
	movementSpeed=1;
	isDead=false;
	die=function(self)
		self.isDead=true
	end;
	startupdate=function(self)
		if self.isDead then
			self.anim=self.DeathAnim
		else
			object_overlapping.startupdate(self)
			self.t=self.t+1
			self:tryaddoffset(20*math.cos(self.t/64.0)+self.startx-self.x,10*math.sin(self.t/32.0)+self.starty-self.y)
			--self.x,self.y=,
			self.anim=self.IdleAnim
		end
		local fin=false
		
		self.img,fin=self.anim()
		
		if fin and self.isDead then
			allobjects:delete(self)
			alloverlapping:delete(self)
		end
	end;
	onoverlap=function(self,other)
		object_colliding.onoverlap(self,other)
		if other.type=="object_player" and (not self.isDead) then
			transition:start(mode_Lost)
		end
	end
},
{
	__index=object_colliding;
	__call=function(self,props)
		local ret = getmetatable(object_colliding).__call(self, props);
		ret.type="object_zlol";
		ret.isMovable=true
		ret.startx=props.x
		ret.starty=props.y
		ret.movementSpeed=(ret.x*0.123+ret.y*1.783)%1.3
		ret.t=(ret.x+ret.y)*(-13.127)
		self.anim=nil;
		return ret;
	end
})
object_bat=setmetatable(
{
},
{
	__index=object_fly;
	__call=function(self,props)
		local ret = getmetatable(object_fly).__call(self, props);
		self.IdleAnim=AnimMaker({
			"postaci_nietoperz_idle_f0.png",
			"postaci_nietoperz_idle_f1.png",
			"postaci_nietoperz_idle_f2.png",
			"postaci_nietoperz_idle_f3.png",
			"postaci_nietoperz_idle_f4.png",
			"postaci_nietoperz_idle_f5.png",
			"postaci_nietoperz_idle_f6.png",
			"postaci_nietoperz_idle_f7.png"
		},13);
		self.DeathAnim=AnimMaker({
			"postaci_nietoperz_death_f.0000.png",
			"postaci_nietoperz_death_f.0001.png",
			"postaci_nietoperz_death_f.0002.png",
			"postaci_nietoperz_death_f.0003.png",
			"postaci_nietoperz_death_f.0004.png",
			"postaci_nietoperz_death_f.0005.png",
			"postaci_nietoperz_death_f.0006.png",
			"postaci_nietoperz_death_f.0007.png",
			"postaci_nietoperz_death_f.0008.png",
			"postaci_nietoperz_death_f.0009.png",
			"postaci_nietoperz_death_f.0010.png",
			"postaci_nietoperz_death_f.0011.png",
			"postaci_nietoperz_death_f.0012.png",
			"postaci_nietoperz_death_f.0013.png",
			"postaci_nietoperz_death_f.0014.png",
			"postaci_nietoperz_death_f.0015.png",
			"postaci_nietoperz_death_f.0016.png",
			"postaci_nietoperz_death_f.0017.png",
			"postaci_nietoperz_death_f.0018.png",
			"postaci_nietoperz_death_f.0019.png",
			"postaci_nietoperz_death_f.0020.png"
		},3,true);
		return ret;
	end
})
object_zlol=setmetatable(
{
	isThinking=50;
	maxThinking=100;
	isDead=false;
	movementSpeed=0.5;
	die=function(self)
		self.isDead=true;
		self.anim=self.DeathAnim
	end;
	startupdate=function(self)
		if self.isDead then
		else
			object_colliding.startupdate(self)
			if self.isThinking>0 then
				self.isThinking=self.isThinking-1
				self.anim=self.IdleAnim
			else
				if self.isThinking==0 then
					--just got here
					self.isThinking=-1
					self.flipx=not self.flipx
				end
				--sprawdzmy czy ma po czym chodzic przed soba i czy moze isc przed siebie
				local czyPrzedNimJestPodloga=false
				local czyPrzedNimJestSciana =false
				if self.flipx then
					czyPrzedNimJestPodloga=alloverlapping:isCollisionAt(self.x-2,self.y+self.h+1,false)
					czyPrzedNimJestSciana=alloverlapping:isCollisionAt(self.x-2,self.y+3,false) or alloverlapping:isCollisionAt(self.x-2,self.y+8,false)
				else
					czyPrzedNimJestPodloga=alloverlapping:isCollisionAt(self.x+self.w+1,self.y+self.h+1,false)
					czyPrzedNimJestSciana=alloverlapping:isCollisionAt(self.x+self.w+1,self.y+3,false) or alloverlapping:isCollisionAt(self.x+self.w+1,self.y+8,false)
				end
				
				if (not czyPrzedNimJestPodloga) or czyPrzedNimJestSciana then
					self.isThinking=self.maxThinking
				else
					self:tryaddoffset((self.flipx and -self.movementSpeed) or self.movementSpeed,0);
					self.anim=self.RunAnim
				end
				
			end
		end
		local fin=false
		self.img,fin=self.anim()
		if self.isDead and fin then
			allobjects:delete(self)
			alloverlapping:delete(self)
		end
	end;
	endupdate=function(self)
		object_colliding.endupdate(self)
	end;
	onoverlap=function(self,other)
		object_colliding.onoverlap(self,other)
		if other.type=="object_player" and (not self.isDead) then
			transition:start(mode_Lost)
		end
	end
},
{
	__index=object_colliding;
	__call=function(self,props)
		local ret = getmetatable(object_colliding).__call(self, props);
		ret.type="object_zlol";
		ret.isMovable=true;
		ret.vy=0;
		ret.flipx=false;
		ret.flipy=false;
		
		ret.RunAnim=AnimMaker({
			"postaci_zlol_run_1.png",
			"postaci_zlol_run_2.png",
			"postaci_zlol_run_3.png",
			"postaci_zlol_run_4.png",
			"postaci_zlol_run_5.png",
			"postaci_zlol_run_6.png",
			"postaci_zlol_run_7.png",
			"postaci_zlol_run_8.png"
		},5)
		ret.DeathAnim=AnimMaker({
			"postaci_zlol_death__.0000.png",
			"postaci_zlol_death__.0001.png",
			"postaci_zlol_death__.0002.png",
			"postaci_zlol_death__.0003.png",
			"postaci_zlol_death__.0004.png",
			"postaci_zlol_death__.0005.png",
			"postaci_zlol_death__.0006.png",
			"postaci_zlol_death__.0007.png",
			"postaci_zlol_death__.0008.png",
			"postaci_zlol_death__.0009.png",
			"postaci_zlol_death__.0010.png",
			"postaci_zlol_death__.0011.png",
			"postaci_zlol_death__.0012.png",
			"postaci_zlol_death__.0013.png",
			"postaci_zlol_death__.0014.png",
			"postaci_zlol_death__.0015.png",
			"postaci_zlol_death__.0016.png",
			"postaci_zlol_death__.0017.png",
			"postaci_zlol_death__.0018.png",
			"postaci_zlol_death__.0019.png",
			"postaci_zlol_death__.0020.png",
			"postaci_zlol_death__.0021.png",
			"postaci_zlol_death__.0022.png",
			"postaci_zlol_death__.0023.png",
			"postaci_zlol_death__.0024.png",
			"postaci_zlol_death__.0025.png",
			"postaci_zlol_death__.0026.png",
			"postaci_zlol_death__.0027.png",
			"postaci_zlol_death__.0028.png",
			"postaci_zlol_death__.0029.png",
			"postaci_zlol_death__.0030.png",
			"postaci_zlol_death__.0031.png"
		},6,true);
		ret.IdleAnim=AnimMaker({
			"postaci_zlol_idle_0.png",
			"postaci_zlol_idle_1.png",
			"postaci_zlol_idle_2.png",
			"postaci_zlol_idle_3.png",
			"postaci_zlol_idle_4.png",
			"postaci_zlol_idle_5.png",
			"postaci_zlol_idle_6.png",
			"postaci_zlol_idle_7.png",
			"postaci_zlol_idle_8.png",
			"postaci_zlol_idle_9.png"
		},8);
		
		return ret;
	end
})


object_faflun=setmetatable(
{
},
{
	__index=object_zlol;
	__call=function(self,props)
		local ret = getmetatable(object_zlol).__call(self, props);
		ret.type="object_zlol";
		ret.maxThinking=0;
		ret.movementSpeed=0.3;
		ret.RunAnim=AnimMaker({
			"postaci_faflun_walk_1.png",
			"postaci_faflun_walk_2.png",
			"postaci_faflun_walk_3.png",
			"postaci_faflun_walk_4.png",
			"postaci_faflun_walk_5.png",
			"postaci_faflun_walk_6.png",
			"postaci_faflun_walk_7.png",
			"postaci_faflun_walk_8.png"
		},5)
		ret.DeathAnim=AnimMaker({
			"postaci_faflun_death_f.0000.png",
			"postaci_faflun_death_f.0001.png",
			"postaci_faflun_death_f.0002.png",
			"postaci_faflun_death_f.0003.png",
			"postaci_faflun_death_f.0004.png",
			"postaci_faflun_death_f.0005.png",
			"postaci_faflun_death_f.0006.png",
			"postaci_faflun_death_f.0007.png",
			"postaci_faflun_death_f.0008.png",
			"postaci_faflun_death_f.0009.png",
			"postaci_faflun_death_f.0010.png",
			"postaci_faflun_death_f.0011.png",
			"postaci_faflun_death_f.0012.png",
			"postaci_faflun_death_f.0013.png",
			"postaci_faflun_death_f.0014.png",
			"postaci_faflun_death_f.0015.png",
			"postaci_faflun_death_f.0016.png",
			"postaci_faflun_death_f.0017.png",
			"postaci_faflun_death_f.0018.png",
			"postaci_faflun_death_f.0019.png",
			"postaci_faflun_death_f.0020.png",
			"postaci_faflun_death_f.0021.png"
		},6,true);
		ret.IdleAnim=AnimMaker({
			"postaci_faflun_walk_3.png",
		},2);
		
		return ret;
	end
})


clamp=function(a,mi,ma)
	return math.max(mi,math.min(ma,a))
end
object_ogon=setmetatable(
{
	startupdate=function(self)
		object_colliding.startupdate(self)
		
		local sdx,sdy=self.x+self.w/2-self.parent.x-self.parent.w/2-self.pox,self.y+self.h/2-self.parent.y-self.parent.h/2-self.poy
		local dl=math.sqrt(sdx*sdx+sdy*sdy)
		local dx,dy=0,0
		if dl~=0 then
			dx,dy=sdx/dl,sdy/dl
		end
		--local accstr=1.2
		--local mmin=-0
		--local mmax=5
		--self.vx,self.vy=self.vx-dx*clamp(dl-self.length,mmin,mmax)*accstr,self.vy-dy*clamp(dl-self.length,mmin,mmax)*accstr
		--local dumping=0.5
		--self.vx,self.vy=self.vx*dumping,self.vy*dumping
		--self.vy=self.vy+GRAVITY
		--self:tryaddoffset(self.vx,self.vy)
		local newdx,newdy=0,0
		if dl>self.length then
			newdx,newdy=dx*self.length,dy*self.length
			self:tryaddoffset(newdx-sdx,newdy-sdy+GRAVITY)
		else
			self:tryaddoffset(0,GRAVITY)
		end
		
	end;
	onoverlap=function(self,other)
		object_colliding.onoverlap(self,other)
	end;
},
{
	__index=object_colliding;
	__call=function(self,props)
		local ret = getmetatable(object_colliding).__call(self, props);
		ret.isMovable=true;
		ret.length=props.length or 5;
		ret.vy=0;
		ret.vx=0;
		ret.pox=props.pox or 0;
		ret.poy=props.poy or 0;
		
		ret.parent=props.parent;
		ret.type="object_ogon";
		return ret;
	end
})


object_door=setmetatable(
{
	onoverlap=function(self,other)
		object_colliding.onoverlap(self,other)
		if other.type=="object_player" then
			transition:start(mode_game,{lvl=self.nextlevel})
		end
	end;
},
{
	__index=object_overlapping;
	__call=function(self,props)
		local ret = getmetatable(object_overlapping).__call(self, props);
		ret.type="object_door";
		ret.nextlevel=props.nextlevel;
		return ret;
	end
})



AnimMaker=function(framesPaths,speed,singlerun)
	local id=0
	local skipper=1
	local ret=function()
		local justFinished=false
		if skipper>=speed then
			skipper=1;
			id=id+1;
			if id>#framesPaths then
				justFinished=true
				if not singlerun then
					id=1;
				else
					id =#framesPaths;
				end
			end
		else
			if id==0 then
				id=1
			end
			skipper=skipper+1;
		end
		return framesPaths[id],justFinished
	end
	return ret
end









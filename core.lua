require "levels"
function _LOAD()
	currmode=mode_menu
	transition:start(mode_game,{lvl="lvl1"})
end
function _LOOP(dt)
	currmode:update()
	if transition.enabled then
		transition:update()
	end
end
GRAVITY=0.1
transition=
{
	enabled=false;
	progress=0;
	maxProgress=84;
	nextmode=nil;
	nextmodeData=nil;
	start=function(self,nextmode,data)
		self.nextmode=nextmode;
		self.enabled=true;
		self.progress=0;
		self.nextmodeData=data;
	end;
	update=function(self)
		for y=1,SCREEN_Y_RES do
			for x=1,SCREEN_X_RES do
				--dla kazdego piksela mamy dodatkowa wartoscia: gdzie jest teraz na teksturze
				local var=x+(self.progress/self.maxProgress)*336
				if var >252 then
				elseif var>190 then
					--gradient
					--SETPIXEL(x,y,(x%(var-190)==0 and 2) or 0)
					SETPIXEL(x,y,1);
				elseif var>126 then
					SETPIXEL(x,y,1);
				elseif var>84 then
					--SETPIXEL(x,y,(x%(126-var)==0 and 2) or 0)
					SETPIXEL(x,y,1);
				end
			end
		end
		self.progress=self.progress+1
		if self.progress>=self.maxProgress then
			self:finished()
		elseif self.progress>=self.maxProgress/2 and currmode~=self.nextmode then
			self:halfway()
		end
	end;
	halfway=function(self)
		currmode=self.nextmode;
		currmode:init(self.nextmodeData);
	end;
	finished=function(self)
		self.enabled=false
	end;
}






mode_menu=
{
	init=function(self)
	end;
	update=function(self)
		CLEAR(true)
		DRAWIMG(0,0,"cut_scenes_cut_reaper.png");
	end;
}
mode_game=
{
	init=function(self,data)
		--preapare everything
		--spawn everything
		for y,d in pairs(LEVELS[data.lvl]) do
			for x,v in pairs(d) do
				if v==0 then
				elseif v==1 then
					object_colliding({x=x*7,y=y*7,w=7,h=7,name="obj1"})
				elseif v==2 then
					object_colliding({x=x*7,y=y*7,w=14,h=7,name="obj2",img="default14x7.png"})
				end
			end
		end
	end;
	update=function(self)
		CLEAR(true)
		camera:update()
		allobjects:startupdate()
		alloverlapping:update()
		allobjects:endupdate()
	end;
}
mode_cutscene=
{
	init=function(self)
	end;
	update=function(self)
	end;
}
local playerref=nil
camera=
{
	x=10;
	y=10;
	update=function(self)
		
		local plmx,plmy=math.floor(playerref.x+playerref.w/2+0.5),math.floor(playerref.y+playerref.h/2+0.5)
		if plmx-(self.x+SCREEN_X_RES/2)>-10 then
			self.x=self.x+1
		elseif plmx-(self.x+SCREEN_X_RES/2)<-20 then
			self.x=self.x-1
		end
		if plmy-(self.y+SCREEN_Y_RES/2)>12 then
			self.y=self.y+1
		elseif plmy-(self.y+SCREEN_Y_RES/2)<-20 then
			self.y=self.y-1
		end
	end;
}

allobjects={
	delete=function(self,obj)
		for i,p in pairs(self) do
			if p==obj then
				self[i]=self[#self]
				self[#self]=nil
				break
			end
		end
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
	end
}
alloverlapping={
	isCollisionAt=function(self,x,y,isMovable)
		for i=1,#self do
			if self[i].isMovable==isMovable then
				if self[i].x<=x and self[i].x+self[i].w>x and self[i].y<=y and self[i].y+self[i].h>y then
					return true
				end
			end
		end
		return false
	end;
	delete=function(self,obj)
		for i,p in pairs(self) do
			if p==obj then
				self[i]=self[#self]
				self[#self]=nil
				break
			end
		end
	end;
	update=function(self,dt)
		for i=1,#self do
			for j=i+1,#self do
				if self:areoverlapping(self[i],self[j]) then
					--print(self[i].name.." overlapped "..self[j].name);
					self[i]:onoverlap(self[j])
					self[j]:onoverlap(self[i])
				end
			end
		end
	end;
	areoverlapping=function(self,obj1,obj2)
		if (obj1.x+obj1.w<=obj2.x) or (obj2.x+obj2.w<=obj1.x) or (obj1.y+obj1.h<=obj2.y) or (obj2.y+obj2.h<=obj1.y) then
			return false
		else
			return true
		end
	end
}
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
				print(self.name.." ret:"..ret)
				return ret;
			end
			if self.type=="object_player" then
				print("other.y "..other.y..",self.y"..self.y)
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
				print("dupa")
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

object_player=setmetatable(
{
	isStanding=0;
	isStandingMax=6;
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
				self.flipx=false
				kaptur0.pox=-kaptur0.pox
				ogon0.pox=-ogon0.pox
			end
		elseif ISKEYPRESSED("a") then
			dx=-1;
			if not self.flipx then
				self.flipx=true
				kaptur0.pox=-kaptur0.pox
				ogon0.pox=-ogon0.pox
			end
		end
		
		if dx~=0 or dy~=0 then
			self:tryaddoffset(dx,dy)
		end
		if self.vy<0 then
			self.img="postaci_reaper_reaper_jump_2.png";
		elseif self.vy>0 then
			self.img="postaci_reaper_reaper_jump_3.png";
		else
			self.img=self.anim();
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
		ret.anim=AnimMaker({"postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_1.png","postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_2.png","postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_3.png","postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_4.png","postaci_reaper_atak_idle_kosa_reaper_atak_kosa_idle_5.png"},5)
		ret.type="object_player";
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

AnimMaker=function(framesPaths,speed)
	local id=0
	local skipper=1
	local ret=function()
		if skipper==speed then
			skipper=1;
			id=id+1;
			if id>#framesPaths then
				id=1;
			end
		else
			if id==0 then
				id=1
			end
			skipper=skipper+1;
		end
		
		return framesPaths[id]
	end
	return ret
end

--object_colliding({x=20,y=40,w=120,name="obj1"})
--object_colliding({x=30,y=10,name="obj1"})
playerref=object_player({x=25,y=21,w=7,h=13,dox=-6,doy=0,name="player"})
ogon0=object_ogon({x=25,y=21,w=6,h=6,name="ogon0",img="sphere6.png",length=0,parent=playerref,pox=-2,poy=4})
ogon1=object_ogon({x=25,y=21,w=4,h=4,name="ogon1",img="sphere4.png",length=2,parent=ogon0})
ogon2=object_ogon({x=25,y=21,w=2,h=2,name="ogon2",img="sphere2.png",length=1.5,parent=ogon1})
ogon3=object_ogon({x=25,y=21,w=1,h=1,name="ogon3",img="sphere1.png",length=0.7,parent=ogon2})
ogon4=object_ogon({x=25,y=21,w=1,h=1,name="ogon4",img="sphere1.png",length=0.7,parent=ogon3})

kaptur0=object_ogon({x=25,y=21,w=4,h=4,name="kaptur0",img="sphere4.png",length=0,parent=playerref,pox=-3,poy=-4})
kaptur1=object_ogon({x=25,y=21,w=3,h=3,name="kaptur1",img="sphere3.png",length=2,parent=kaptur0})
kaptur2=object_ogon({x=25,y=21,w=1,h=1,name="kaptur2",img="sphere1.png",length=1.1,parent=kaptur1})








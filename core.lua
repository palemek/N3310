
function _LOOP(dt)
	CLEAR()
	camera:update()
	allobjects:startupdate()
	alloverlapping:update()
	allobjects:endupdate()
end
function _LOAD()
end
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
		for i,p in ipairs(self) do
			p:startupdate(dt);
		end
	end;
	endupdate=function(self,dt)
		for i,p in ipairs(self) do
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
					print(self[i].name.." overlapped "..self[j].name);
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
		DRAWIMG(math.floor(self.x+self.dox+0.5)-camera.x,math.floor(self.y+self.doy+0.5)-camera.y,self.img)
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
		
		ret.img=props.img or "default";
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
			
			--no dobra, teraz szukamy jak daleko byl od kolizji przed kolizja
			local mdxl,mdxr=self.befx-(other.x+other.w-1),other.x-(self.befx+self.w-1)
			local mdyd,mdyu=self.befy-(other.y+other.h-1),other.y-(self.befy+self.h-1)
			if (mdxl>0 or mdxr>0) and (mdyd>0 or mdyu>0) then
				if mdxl>0 and mdyd>0 then
					if mdx1>mdyd then
						self.y=other.y+other.h
					else
						self.x=other.x+other.w
					end
				elseif mdxl>0 and mdyu>0 then
					if mdx1>mdyu then
						self.y=other.y-self.h
					else
						self.x=other.x+other.w
					end
				elseif mdxr>0 and mdyd>0 then
					if mdxr>mdyd then
						self.y=other.y+other.h
					else
						self.x=other.x-self.w
					end
				elseif mdxr>0 and mdyu>0 then
					if mdxr>mdyu then
						self.y=other.y-self.h
					else
						self.x=other.x-self.w
					end
				end
			elseif mdxl>0 then
				self.x=other.x+other.w
			elseif mdxr>0 then
				self.x=other.x-self.w
			elseif mdyu>0 then
				self.y=other.y-self.h
			elseif mdyd>0 then
				self.y=other.y+other.h
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
	startupdate=function(self)
		object_colliding.startupdate(self)
		local isStanding=false;
		if alloverlapping:isCollisionAt(self.x,self.y+self.h,false) or alloverlapping:isCollisionAt(self.x+self.w-1,self.y+self.h,false) then
			isStanding=true
		end
		
		if isStanding then
			self.vy=0;
			if ISKEYPRESSED("w") then
				self.vy=-2.3;
			end
		else
			self.vy=self.vy+0.1;
		end
		
		local dx,dy=0,self.vy;
		if ISKEYPRESSED("d") and not ISKEYPRESSED("a") then
			dx=1;
		elseif ISKEYPRESSED("a") then
			dx=-1;
		end
		--if ISKEYPRESSED("s") and not ISKEYPRESSED("w") then
		--	dy=2;
		--else
		
		if dx~=0 or dy~=0 then
			self:tryaddoffset(dx,dy)
		end
	end;
},
{
	__index=object_colliding;
	__call=function(self,props)
		local ret = getmetatable(object_colliding).__call(self, props);
		ret.isMovable=true;
		self.vy=0;
		ret.type="object_player";
		
		return ret;
	end
})

object_colliding({x=20,y=40,w=120,name="obj1"})
object_colliding({x=20,y=20,w=10,name="obj2"})
playerref=object_player({x=25,y=21,name="player",img="player"})















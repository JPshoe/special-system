pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- minefield v7
-- by shyfu
-------------------------------

-- game over wind isn't center

function _init()
	version=7
	cartdata("shyfu_minefield_p8")
	slot_1,slot_2=10,41
	
	
	debug={}
	--showdebugline=true
	--hidetopgrid=true
	
	poke(0x5f2e,1)
	dirx=split"-1,1,0,0,1,1,-1,-1"
	diry=split"0,0,-1,1,-1,1,1,-1"
	palettes={
		{[0]=0,1,2,3,4,5,6,7,8,9,10,11,12,134,131,129},
		{[0]=0,1,130,3,4,133,5,134,136,9,10,139,12,134,131,129}
	}
	
	tick=0
	
	doors={}
	doors_open=true
	new_door()
	
	fakegrid=split2d("1,1,1,1,1,1,1,1,1,1,1,1,1,1|1,1,1,1,1,1,1,1,1,1,1,1,1,1|1,1,0,0,0,0,0,0,0,0,0,0,1,1|1,1,0,0,0,0,0,0,0,0,0,0,1,1|1,1,0,0,0,0,0,0,0,0,0,0,1,1|1,1,0,0,0,0,0,0,0,0,0,0,1,1|1,1,0,0,0,0,0,0,0,0,0,0,1,1|1,1,0,0,0,0,0,0,0,0,0,0,1,1|1,1,0,0,0,0,0,0,0,0,0,0,1,1|1,1,1,1,1,1,1,1,1,1,1,1,1,1|1,1,1,1,1,1,1,1,1,1,1,1,1,1")
	shakex,shakey=0,0
	grid_ox,grid_oy=8,27
	
	grid=new_grid(0)
	top_grid=fakegrid
	
	cur={x=1,y=1}
	
	mines=20
	mines_min,mines_max=10,40
	flags=mines
	
	theme=1
	
	seconds=0
	minutes=0
	
	gameover_t=0
	
	nextstate=""
	butt_x,butt_o=false,false
 --menuitem(1,"reset data",reset_data)
	
	--winds={}
	--new_wind()
	
	upd=upd_title
	drw=drw_title
	
end

function _update60()
	tick+=1
	upd()
	is_butt()
	shk()
	foreach(doors,upd_doors)
	foreach(parts,upd_parts)
	foreach(winds,upd_winds)
end

function _draw()
	cls()
	plt()
	drw()
	
	----------debug-----------
	
	if partgrid then
		for x=1,14 do 
			for y=1,11 do 
				--print(partgrid[x][y],x*8-8+grid_ox+2,y*8-8+grid_oy+1,0)
			end
		end
	end
	
	for i=1,#debug do 
		print(debug[i])
	end
	if showdebugline then
		fillp(▤)
		line(63,0,63,127,2)
		fillp(▥)
		line(0,70,127,70,2)
		fillp()
	end
	--------------------------
end

function startgame()
	parts,winds={},{}
	init_grid()
	
	player={x=1,y=1}
	
	highscore=false
	gameover,gamewin=false,false
	first=true
	flags=mines
	
	upd=upd_game
	drw=drw_game
end

function init_grid(x,y)
	grid=new_grid(0)
	place_mines(mines,x,y)
	fill_numbers()
	top_grid=new_grid(1)
end
-->8
-- tools
-------------------------------

function rect2(x,y,w,h,z)
	local c1=z=="in" and 7 or 5
	local c2=z=="in" and 5 or 7
	rect(x,y,w,h,c1)
	line(x,y,x,h-1,c2)
	line(x,y,w,y,c2)
end

function rect3(x,y,flg)
	rectfill(x+1,y+1,x+5,y+5,6)
	rect(x,y,x+6,y+6,5)
	line(x,y,x+6,y,7)
	line(x,y,x,y+5,7)
	if flg then
		-- red flag
		line(x+2,y+2,x+2,y+4,1)
		rect(x+3,y+2,x+4,y+3,8)
	end
end

function rivet(x,y)
	rect(x,y,x+1,y+1,5)
	pset(x,y,6)
end

function plt()
	pal()
	pal(palettes[theme],1)
end

function ospr(sp,x,y,w,h)
	pal(8,2)
	spr(sp,x,y+1,w,h)
	plt()
	spr(sp,x,y,w,h)
end

function movetoward(current_value,target,amount)
	local new_value=0
	if current_value==target then
		new_value=current_value
	elseif current_value<target then
		new_value=current_value+amount
		if new_value>target then 
			new_value=target 
			shakey=8
			sfx(58)
		end
	elseif current_value>target then
		new_value=current_value-amount
		if new_value<target then 
			new_value=target 
			shakey=8
			sfx(58)
		end 
	end
	return new_value
end

--split 2d array
function split2d(s)
	local arr=split(s,"|",false)
	for k,v in pairs(arr) do
		arr[k]=split(v)
	end
	return arr
end

function move_menu(c)
	if btnp(⬆️) then
		c.y-=1
		sfx(63)
	elseif btnp(⬇️) then
		c.y+=1
		sfx(63)
	end
	c.y=(c.y-1)%3+1
end

function get_button()
	for i=4,5 do 
		if btnp(i) then
			return i
		end
	end
end

function shk()
	local sx=rnd(shakex)-(shakex/2)
	local sy=rnd(shakey)-(shakey/2)
	camera(sx,sy)
	shakex-=1
	shakey-=1
	if shakex<1 then
		shakex=0
	end
	if shakey<1 then
		shakey=0
	end
end

function inbounds(x,y)
	return x>=1 and x<=14 and y>=1 and y<=11
end

function wait(f)
	while f>0 do 
		flip()
		f-=1
	end
end


function is_butt()
	if btn(❎) then
		butt_x=true
	else 
		butt_x=false
	end
	if btn(🅾️) then
		butt_o=true
	else 
		butt_o=false
	end
end

function reset_data()
	for i=0,64 do 
		dset(i,0)
	end
end


-->8
-- updates / draws
-------------------------------

function upd_game()
	if not first then
		upd_timer()
	end
	move_cursor(player)
	do_buttons(get_button())
end

	function upd_gameover()
	local mn=minutes*60
	local sc=flr(seconds)+mn
	local smn=dget(slot_1)*60
	local ssc=dget(slot_2)+smn
	if #parts==0 then
		if #winds==0 then
			
			if not butt_x and btnp(❎) 
			or not butt_o and btnp(🅾️) then
				
				sfx(57)
				wait(25)
				
				if gameover then
					sfx(55)
					gameover_t=50
				else
					music(0)
					gameover_t=120
					if sc<ssc 
					or dget(slot_1)==0 and dget(slot_2)==0 then
						highscore=true
					end
				end
				
				tick=0
				new_wind()
				
			end
			
		else
			if gameover_t>0 then
				gameover_t-=1 
			else
				if btnp(❎) and not butt_x or btnp(🅾️) and not butt_o then
					
					sfx(57)
					wait(20)
					
					for d in all(doors) do 
						d.ty=d.cy
					end
					
					if gamewin then
						
						if dget(slot_1)==0 and dget(slot_2)==0 then
							dset(slot_1,minutes)
							dset(slot_2,flr(seconds))
						else
							if sc<ssc then
								dset(slot_1,minutes)
								dset(slot_2,flr(seconds))
							end
							
						end
					end
					seconds,minutes=0,0
					nextstate="menu"
					highscore=false
					upd=upd_curtain
					gameover_t=0
				end
			end
		end
	end
end

function upd_title()
	if btnp(❎) or btnp(🅾️) then
		for d in all(doors) do 
			d.ty=d.cy
		end
		sfx(57)
		wait(20)
		tick=0
		nextstate="menu"
		upd=upd_curtain
	end
end

function upd_menu()
	if doors_open then
		
		if not butt_x and btnp(❎) 
		or not butt_o and btnp(🅾️) then
			if cur.y==1 then
				-- close doors and startgame
				for d in all(doors) do 
					d.ty=d.cy
				end
				sfx(57)
				tick=0
				wait(20)
				nextstate="game"
				upd=upd_curtain
			else
				if cur.y!=2 then
					sfx(61)
				end
			end
		end
		move_menu(cur)
		local n=(butt_x or butt_o) and 10 or 1
		if btnp(⬅️) then
			if cur.y==2 then
				mines-=n
				slot_1-=n
				slot_2-=n
			elseif cur.y==3 then
				theme-=1
			end
			if cur.y!=1 then sfx(62) end
		elseif btnp(➡️) then
			if cur.y==2 then
				mines+=n
				slot_1+=n
				slot_2+=n
			elseif cur.y==3 then
				theme+=1
			end
			if cur.y!=1 then sfx(62) end
		end
		theme=(theme-1)%2+1
		mines=mid(mines_min,mines,mines_max)
		slot_1=mid(0,slot_1,30)
		slot_2=mid(31,slot_2,61)
		flags=mines
	end
end

function upd_curtain()
	
	for d in all(doors) do 
		if not d.open then
			d.t+=1
			if d.t>=30 then
				
				d.ty=d.oy
				
				if nextstate=="menu" then
					top_grid=fakegrid
					upd=upd_menu
					drw=drw_menu
				else
					startgame()
				end
				
				d.t=0
			end
		end
	end
end

function drw_game()
	drw_grid()
	
	foreach(parts,drw_parts)
	foreach(winds,drw_winds)
	rect(7,26,119,114,0)
	
	if upd==upd_game then
		drw_cursor(player.x*8-8+grid_ox,player.y*8-8+grid_oy,player.ox,player.oy,player.at)
	end
	
	-- grid frame
	rect2(6,25,120,115,"in")
	foreach(doors,drw_doors)
	camera()
	rect(0,13,127,127,0)
	drw_ui()
end


function drw_title()
	
	drw_fakegrid()
	
	rectfill(16,35,110,105,6)
	line(16,82,110,82,0)
	rectfill(23,42,103,74,0)
	local tik=tick\12%2
	for i=0,15 do
		line(24,43+i*2+tik,102,43+i*2+tik,15)
	end
	rect2(23,42,103,74,"in")
	
	-- title
	local sox,soy=0,0
	ospr(64,26,54,10,1)
	if tick%120>=100 and rnd()>.85 then
		sox=rnd()>.5 and -1-rnd(1) or 1+rnd(1)
		for i=0,14 do
			line(24,43+i*2+tik,102,43+i*2+tik,0)
		end
	end
	ospr(64,26+sox,54,10,1)
	
	line(22,90,41,90,5)
	print("❎/🅾️",23,92,5)
	line(22,98,41,98,5)
	
	rectfill(44,90,82,98,0)
	print("▮▮▮▮▮▮▮▮▮",46,92,15)
	rect2(44,90,82,98,"in")
	
	print("press x",50,92,2)
	if tick\12%8<4 then
		print("press x",50,92,8)
	end
	-- stripes
	sspr(80,16,21,9,85,90)
	
	-- rivets
	local rx={17,108}
	local ry={36,79,84,103}
	for x=1,2 do 
		for y=1,4 do 
			rivet(rx[x],ry[y])
		end
	end
	--foreach(winds,drw_winds)
	foreach(doors,drw_doors)
	
	camera()
	rect(0,13,127,127,0)
	drw_ui()
end


function drw_menu()
	drw_fakegrid()
	rectfill(24,43,102,97,6)
	line(24,58,102,58,0)
	local rx={25,100}
	for i=1,2 do 
		rivet(rx[i],44)
		rivet(rx[i],55)
		rivet(rx[i],60)
		rivet(rx[i],95)
	end
	
	local txt=split"❎/🅾️,mines,theme"
	
	local btc=theme==1 and 5 or 9
	rectfill(52,46,74,54,0)
	rect2(52,46,74,54,"in")
	line(33,46,49,46,btc)
	line(33,54,49,54,btc)
	print("best",34,48,btc)
	line(77,46,93,46,btc)
	line(77,54,93,54,btc)
	print("time",78,48,btc)
	
	print("▮▮▮▮▮",54,48,15)
	print("  :  ",54,48,8)
	local m=dget(slot_1)
	local s=dget(slot_2)
	if s==0 and m==0 then
		print("-- --",54,48,8)
	else
		print(m<10 and "0"..m or m,54,48,8)
		print(s<10 and "0"..s or s,66,48,8)
	end
	
	local oy=11
	local ry=63
	for i=0,2 do 
		rectfill(28,ry+i*oy,34,ry+i*oy+8,0) 
		rectfill(30,ry+2+i*oy,32,ry-2+i*oy+8,15)
		rect2(28,ry+i*oy,34,ry+i*oy+8,"in") 
		
		local txtc=theme==1 and 5 or 9
		line(37,ry+i*oy,57,ry+i*oy,txtc)
		line(37,ry+8+i*oy,57,ry+8+i*oy,txtc)
		print(txt[i+1],38,ry+2+i*oy,txtc)
		
		local sx={78,86,98}
		rectfill(60,ry+i*oy,sx[i+1],ry+8+i*oy,0)
		rect2(60,ry+i*oy,sx[i+1],ry+8+i*oy,"in")
		
		local stx={62,70,70}
		local thtxt=theme==1 and "light" or "dark"
		local txt1={"▮▮▮▮","▮▮▮▮▮▮","▮▮▮▮▮▮▮▮▮"}
		local txt3={"","◀    ▶","◀       ▶"}
		local txt2={"play",mines<10 and "0"..mines or mines,thtxt}
		print(txt1[i+1],62,ry+2+i*oy,15)
		print(txt2[i+1],stx[i+1],ry+2+i*oy,8)
		print(txt3[i+1],62,ry+2+i*oy,2)
		
		print("▶",30,ry+2+i*oy,2)
		if cur.y-1==i then
			print("▶",30,ry+2+i*oy,8)
			if tick\12%2==0 then
				print(txt3[i+1],62,ry+2+i*oy,8)
			end
		end
	end
	
	if cur.y==1 then
		if tick\12%2==0 then
			print("play",62,ry+2,2)
		end
	end
	
	if theme==2 then
		pal(5,9)
	end
	sspr(81,16,18,9,81,ry)
	sspr(81,16,10,9,89,ry+11)
	plt()
	
	foreach(doors,drw_doors)
	
	camera()
	rect(0,13,127,127,0)
	drw_ui()
end

function check_close(d)
	if d.y==d.ty then
		tick=0
		upd=upd_curtain
	end
end
-->8
-- grid
-------------------------------

function new_grid(n)
	local g={}
	for x=1,14 do 
		g[x]={}
		for y=1,11 do 
			g[x][y]=n
		end
	end
	return g
end


function drw_grid()
	
	-- grid
	for x=1,14 do 
		for y=1,11 do 
			local gx,gy=x*8+grid_ox-8,y*8+grid_oy-8
			
			-- empty
			local ec=13
			if upd!=upd_game then
				if top_grid[x][y]>0 then
					ec=5
				end
			end
			
			rectfill(gx,gy,gx+6,gy+6,ec)
			
			-- mines / numbers
			pal(1,0)
			if grid[x][y]=="m" then
				spr(1,gx,gy)
			elseif grid[x][y]=="r" then
				spr(2,gx,gy)
			elseif grid[x][y]=="g" then
				spr(3,gx,gy)
			else
				if grid[x][y]!=0 then
					local c=split"1,3,8,15,2,14,0,5" 
					plt()
					print(grid[x][y],gx+2,gy+1,c[grid[x][y]])
				end
			end
			
			-- top grid
			if upd==upd_game then
				if not hidetopgrid then
					pal(1,0)
					if top_grid[x][y]==1 then
						rect3(gx,gy)
					elseif top_grid[x][y]==2 then
						rect3(gx,gy,1)
					end
				end
			else
				if top_grid[x][y]==2 
				and grid[x][y]!="g" then
					if flr(time()*2)%2>=1 then
						spr(4,gx,gy)
					end
				end
			end
		end
	end
end

function drw_fakegrid()
	-- used in title screen / menu
	rect2(6,25,120,115,"in")
	for x=1,14 do 
		for y=1,11 do 
			local gx,gy=x*8+grid_ox-8,y*8+grid_oy-8
			rectfill(gx,gy,gx+6,gy+6,6)
			if top_grid[y][x]==1 then
				rect3(gx,gy)
			end
		end
	end
end

function place_mines(n,px,py)
	repeat
		local x,y=ceil(rnd(14)),ceil(rnd(11))
		if grid[x][y]==0 then
			if px then
				if not ((x-1 <= px and px <= x+1) and (y-1 <= py and py <= y+1)) then
					grid[x][y]="m"
					n-=1
				end
			else
				grid[x][y]="m"
				n-=1
			end
		end
	until n==0
end

function fill_numbers()
	for x=1,14 do 
		for y=1,11 do
			if grid[x][y]=="m" then
				for i=1,8 do 
					local dx,dy=x+dirx[i],y+diry[i]
					if inbounds(dx,dy) then
						for j=1,8 do 
							if grid[dx][dy]==j-1 then
								grid[dx][dy]=j
								break
							end
						end
					end
				end
			end
		end
	end 
end

function set_zones()
	local cur=1
	zones=new_grid(0)
	for x=1,14 do 
		for y=1,11 do 
			if grid[x][y]==0 
			and zones[x][y]==0 then
				grow_zones(x,y,cur)
				cur+=1
			end
		end
	end
end

function calcdist(tx,ty)
	local cand,step={},0
	add(cand,{x=tx,y=ty})
	partgrid[tx][ty]=1
	repeat
		step+=1
		candnew={} 
		for c in all(cand) do
			for i=1,4 do
				local dx=c.x+dirx[i]
				local dy=c.y+diry[i]
				if inbounds(dx,dy) then
					if top_grid[dx][dy]==0 
					and partgrid[dx][dy]==0 then
						partgrid[dx][dy]=step
						if top_grid[dx][dy]==0 then
							add(candnew,{x=dx,y=dy})
						end
					end
				end
			end
		end
		cand=candnew
	until #cand==0
end

function grow_zones(x,y,zone)
	local cand,candnew={{x=x,y=y}},{}
	repeat 
		candnew={}
		for c in all(cand) do
			if zones[c.x][c.y]!=zone then
				zones[c.x][c.y]=zone
				for i=1,8 do 
					local dx,dy=c.x+dirx[i],c.y+diry[i]
					if inbounds(dx,dy) then 
						if grid[dx][dy]==0 
						and zones[dx][dy]!=zone then
							add(candnew,{x=dx,y=dy})
						end
					end
				end
			end
			cand=candnew
		end
	until #cand==0
end

function extend_zones()
	for x=1,14 do 
		for y=1,11 do
			if zones[x][y]==0 then
				for i=1,8 do 
					local dx,dy=x+dirx[i],y+diry[i]
					if inbounds(dx,dy) then
						if zones[dx][dy]==1 
						and grid[dx][dy]==0 then
							zones[x][y]=zones[dx][dy]
						end
					end
				end
			end
		end
	end 
end

function del_zone(zone)
	for x=1,14 do 
		for y=1,11 do
			if zones[x][y]==zone then
				if top_grid[x][y]==2 then
					flags+=1
				end
				if top_grid[x][y]!=0 then
					
					top_grid[x][y]=0
				end
			end
		end
	end
end



-->8
-- doors
-------------------------------

function new_door()
	local d={
		x=6,
		y=-26,
		cy=20,
		oy=-26,
		ty=-26,
		w=115,
		h=51,
		t=0,
		open=true,
		pos="top"
	}
	add(doors,d)
	
	d={
		x=6,
		y=116,
		cy=70,
		oy=116,
		ty=116,
		w=115,
		h=51,
		t=0,
		open=true,
		pos="bot"
	}
	add(doors,d)
end

function upd_doors(d)
	d.y=movetoward(d.y,d.ty,5)
	if abs(d.ty-d.y)<.5 then
		d.y=d.ty
		if d.ty==d.cy then
			doors_open=false
			d.open=false
		elseif d.ty==d.oy then
			d.open=true
			doors_open=true
			
		end
	end
end

function drw_doors(d)
	
	local dx,dy,dw,dh=d.x,d.y,d.w,d.h
	rectfill(dx,dy,dx+dw-1,dy+dh-1,6)
	local sp=theme==1 and 11 or 14
	
	if d.pos=="top" then
		
		-- top left pannel
		rectfill(dx+1,dy+1,dx+71,dy+21,6)
		rect2(dx+1,dy+1,dx+71,dy+21)
		
		-- // // // 
		clip(dx+3,dy,67,20)
		for i=0,8 do
			spr(sp,dx+3+i*8,dy+3)
			spr(sp,dx+3+i*8,dy+11)
			spr(sp,dx+3+i*8,dy+19)
		end
		clip()
		
		-- bottom left pannel
		rectfill(dx+1,dy+23,dx+71,dy+43,6)
		rect2(dx+1,dy+23,dx+71,dy+43)
		-- rivets
		local rx={3,68}
		for i=1,2 do 
			rivet(dx+rx[i],dy+25)
			rivet(dx+rx[i],dy+40)
		end
		-- screen
		rectfill(dx+9,dy+29,dx+63,dy+37,0)
		rect2(dx+9,dy+29,dx+63,dy+37,"in")
		plt()
		for i=0,12 do 
			print("▮",dx+11+i*4,dy+31,15)
		end
		print("!! warning !!",dx+11,dy+31,2)
		if tick%20>=10 then
			print("!! warning !!",dx+11,dy+31,8)
		end
		-- top right pannel (hazard logo)
		rectfill(dx+73,dy+1,dx+113,dy+43,6)
		rect2(dx+73,dy+1,dx+113,dy+43)
		-- rivets
		rx={75,110}
		for i=1,2 do 
			rivet(dx+rx[i],dy+3)
			rivet(dx+rx[i],dy+40)
		end
		
		pal(1,0)
		
		-- hazard logo 
		spr(76,dx+77,dy+6,4,4)
		line(dx+109,dy+19,dx+109,dy+25,7)
		line(dx+90,dy+38,dx+96,dy+38,7)
		
		-- yellow stripes
		for i=0,14 do
			spr(12,dx+i*8,dy+dh-7)
		end
		
	else
		-- top pannel
		rectfill(dx+1,dy+7,dx+113,dy+27,6)
		rect2(dx+1,dy+7,dx+113,dy+27)
		-- rivets
		local rx={3,110}
		for i=1,2 do 
			rivet(dx+rx[i],dy+9)
			rivet(dx+rx[i],dy+24)
		end
		
		-- bottom pannels
		-- left pannel
		rectfill(dx+1,dy+29,dx+41,dy+49,6)
		rect2(dx+1,dy+29,dx+41,dy+49)
		-- rivets
		rx={3,38}
		for i=1,2 do 
			rivet(dx+rx[i],dy+31)
			rivet(dx+rx[i],dy+46)
		end
		
		-- grill / loading ?
		rectfill(dx+6,dy+34,dx+36,dy+44,0)
		rect2(dx+6,dy+34,dx+36,dy+44,"in")
		for i=0,10 do 
			spr(13,dx+8+i*2,dy+36)
		end
		
		-- right pannel
		rectfill(dx+43,dy+29,dx+113,dy+49,6)
		rect2(dx+43,dy+29,dx+113,dy+49)
		
		-- // // // 
		clip(dx+45,dy+31,67,17)
		for i=0,8 do
			spr(sp,dx+45+i*8,dy+31)
			spr(sp,dx+45+i*8,dy+39)
			spr(sp,dx+45+i*8,dy+47)
		end
		clip()
		
		pal(1,0)
		for i=0,14 do
			spr(12,dx+i*8,dy-1)
		end
	end
	
end

-->8
-- ui / juice
-------------------------------

function drw_ui()
	
	--- big frame and fill ---
	rect2(0,14,126,126)
	-- top fill
	rectfill(1,15,125,17,6)
	-- bottom fill
	rectfill(1,123,125,125,6)
	-- left fill
	rectfill(1,18,3,122,6)
	-- right fill
	rectfill(123,18,125,122,6)
	-- inlines
	rect2(4,18,122,122,"in")
	rect(5,19,121,121,0)
	--------------------------
	
	-- top ui
	rectfill(0,0,126,12,6)
	line(31,0,31,12,0)
	line(95,0,95,12,0)
	
	-- top left ui
	rect2(0,0,30,12)
	
	rectfill(15,2,25,10,0)
	rect2(15,2,25,10,"in")
	
	local mine=mines<10 and "0"..mines or mines
	local mtxt=drw==drw_title and "p8" or mine
	plt()
	print("▮▮",17,4,15)
	
	print(mtxt,17,4,8)
	
	-- top center / timer
	rect2(32,0,94,12)
	
	--rectfill(45,3,81,9,0)
	rectfill(48,2,78,10,0)
	rect2(48,2,78,10,"in")
	print("▮▮▮▮▮▮▮",50,4,15)
	local m=minutes<10 and "0"..minutes or minutes
	local s=seconds<10 and "0"..flr(seconds) or flr(seconds)
	
	if drw==drw_title then
		print("shyfu",54,4,8)
	else
		local tc=highscore==true and 11 or 8
		if upd==upd_gameover and #winds==0 and #parts==0 then
			if tick%120>=60 then
				print(m..":"..s,54,4,tc)
			else
				print("press x",50,4,8)
			end
		else
			print(m..":"..s,54,4,tc)
			if seconds%1>=.5 then
				print("  :  ",54,4,tc)
			end
		end
	end
	
	-- top right ui
	rect2(96,0,126,12)
	
	rectfill(101,2,111,10,0)
	rect2(101,2,111,10,"in")
	print("▮▮",103,4,15)
	local flg=flags<10 and "0"..flags or flags
	local ftxt=drw==drw_title and "V"..version or flg
	print(ftxt,103,4,8)
	
	-- sprites
	pal(1,0)
	spr(1,4,3)
	spr(10,116,3)
	
end

-- particles

function create_parts(typ)
	for x=1,14 do 
		for y=1,11 do 
			if top_grid[x][y]>0 then
				new_part(x,y,typ)
			end
		end
	end
end

function create_part2(g)
	for x=1,14 do 
		for y=1,11 do 
			if g[x][y]!=0 
			and top_grid[x][y]==0 then
				new_part(x,y,3,g[x][y])
				top_grid[x][y]=-1
			end
		end
	end
end

function new_part(x,y,typ,d)
	d=d and d or 0
	local p={
		typ=typ,
		x=x-1,
		y=y-1,
		dy=-.25-rnd(.25),
		ani={5,6,7,8},
		at=0,
		af=1,
		delay=d/2
	}
	add(parts,p)
end

function upd_parts(p)
	if p.typ==1 then
		p.dy+=.03
		p.y+=p.dy
	elseif p.typ==2 then
		p.at+=1
		if p.at%5==0 then
			p.af+=1
		end
		if p.af>=#p.ani then
			del(parts,p)
		end
	elseif p.typ==3 then
		p.at+=1
		if p.at%p.delay\2==0 then
			p.af+=1
		end
		if p.af>=#p.ani then
			del(parts,p)
		end
	end
	
	if p.y*8>128 then
		if #parts==1 then
			tick=0
		end
		del(parts,p)
	end
	
end

function drw_parts(p)
	rect(p.x*8+grid_ox,p.y*8+grid_oy,p.x*8+grid_ox+7,p.y*8+grid_oy+7,0)
	spr(p.ani[p.af],p.x*8+grid_ox,p.y*8+grid_oy)
	--spr(21,p.x*8+grid_ox,p.y*8+grid_oy)
end

-- windows

function new_wind()
	local w={
		x=grid_ox-128,
		tx=grid_ox,
		y=grid_oy+32,
		w=grid_ox+14*8-grid_ox-1,
		h=39
	}
	add(winds,w)
	return w
end

function upd_winds(w)
	w.x+=(w.tx-w.x)/5
	if abs(w.tx-w.x)<.5 then
		w.x=w.tx
	end
end

function drw_winds(w)
	local lc=theme==1 and 5 or 9
	rectfill(w.x,w.y-16,w.x+w.w-1,w.y-2,6)
	
	rectfill(w.x,w.y,w.x+w.w-1,w.y+w.h-1,6)
	line(w.x,w.y+23,w.x+110,w.y+23,0)
	rectfill(w.x+17,w.y+4,w.x+w.w-1-16,w.y+18,0)
	
	rectfill(w.x+44,w.y-13,w.x+66,w.y-5,0)
	rect2(w.x+44,w.y-13,w.x+66,w.y-5,"in")
	print("▮▮▮▮▮",w.x+46,w.y-11,15)
	line(w.x+25,w.y-13,w.x+41,w.y-13,lc)
	line(w.x+25,w.y-5,w.x+41,w.y-5,lc)
	print("best",w.x+26,w.y-11,lc)
	line(w.x+69,w.y-13,w.x+85,w.y-13,lc)
	line(w.x+69,w.y-5,w.x+85,w.y-5,lc)
	print("time",w.x+70,w.y-11,lc)
	
	
	local mn=dget(slot_1)<10 and "0"..dget(slot_1) or dget(slot_1)
	local sc=dget(slot_2)<10 and "0"..dget(slot_2) or dget(slot_2)
	
	if dget(slot_1)==0 and dget(slot_2)==0 then
		mn="--"
		sc="--"
	end
	print(mn..":"..sc,w.x+46,w.y-11,8)
	for x=0,2 do 
		line(w.x+11+x*2,w.y+4,w.x+11+x*2,w.y+18,5)
	end
	for x=0,2 do 
		line(w.x+97+x*2,w.y+4,w.x+97+x*2,w.y+18,5)
	end
	-- rivets
	local ry={-15,-4,1,20,25,36}
	for i=1,6 do 
		rivet(w.x+1,w.y+ry[i])
		rivet(w.x+108,w.y+ry[i])
	end
	
	local tik=tick\12%2
	plt()
	for i=0,6 do
		line(w.x+17,w.y+5+i*2+tik,w.x+93,w.y+5+i*2+tik,15)
	end
	
	local sox,soy=0,0
	local winspr=48
	
	-- ★
	if gameover then
		pal(8,2)
		spr(32,w.x+25+sox,w.y+8,8,1)
		plt()
		spr(32,w.x+25+sox,w.y+7,8,1)
	else
		pal(11,3)
		spr(winspr,w.x+25+sox,w.y+8,8,1)
		plt()
		spr(winspr,w.x+25+sox,w.y+7,8,1)
	end
	
	local tim=60
	if tick%tim>=tim-20 and rnd()>.7 then
		sox=rnd()>.5 and -1-rnd(1) or 1+rnd(1)
		for i=0,6 do
			line(w.x+17,w.y+5+i*2+tik,w.x+93,w.y+5+i*2+tik,0)
		end
	end
	
	rect2(w.x+17,w.y+4,w.x+w.w-1-15,w.y+18,"in")
	
	-- ★
	if gameover then
		pal(8,2)
		spr(32,w.x+25+sox,w.y+8,8,1)
		plt()
		spr(32,w.x+25+sox,w.y+7,8,1)
	else
		pal(11,3)
		spr(winspr,w.x+25+sox,w.y+8,8,1)
		plt()
		spr(winspr,w.x+25+sox,w.y+7,8,1)
	end
	
	rectfill(w.x+24,w.y+27,w.x+86,w.y+35,0)
	rect2(w.x+24,w.y+27,w.x+86,w.y+35,"in")
	
	print("▮▮▮▮▮▮▮▮▮▮▮▮▮▮▮",w.x+26,w.y+29,15)
	--print("new highscore",w.x+30,w.y+29,1)
	if highscore then
		print("new highscore",w.x+30,w.y+29,tick%20>=10 and 8 or 2)
	end
	if theme==2 then
		pal(5,9)
	end
	sspr(80,16,12,9,w.x+10,w.y+27)
	sspr(80,16,12,9,w.x+89,w.y+27)
	sspr(80,16,12,9,w.x+11,w.y-13)
	sspr(80,16,12,9,w.x+88,w.y-13)
	plt()
end
-->8
-- player / timer
-------------------------------

function move_cursor(c)
	for i=0,3 do 
		if btnp(i) then
			c.x+=dirx[i+1]
			c.y+=diry[i+1]
			sfx(59)
		end
	end
	c.x=(c.x-1)%14+1
	c.y=(c.y-1)%11+1
end

function do_buttons(butt)
	--place flag check
	if btn(❎) and not butt_x and not btn(🅾️) and first==false then
		--debug[2]="🅾️"
		if top_grid[player.x][player.y]==1 then
			
			if flags>0 then
			 --place flag
				sfx(57)
				top_grid[player.x][player.y]=2
				flags-=1
				if grid[player.x][player.y]=="m" then
					grid[player.x][player.y]="g"
				end
			else
				--no flags
				sfx(47)
			end
		--remove flag
		elseif top_grid[player.x][player.y]==2 then
			sfx(49)
			top_grid[player.x][player.y]=1
			flags+=1
			if grid[player.x][player.y]=="g" then
				grid[player.x][player.y]="m"
			end
		else
		 --clear
			--nope sfx
			sfx(47)
		end
		return
	end
	--end flagging
	
	if btn(🅾️) and not butt_o and not btn(❎) then
		--debug[2]="❎"
		if top_grid[player.x][player.y]==1 then
			sfx(60)
			if first then
					init_grid(player.x,player.y)
			end
			-- mine
			if grid[player.x][player.y]=="m" then
				sfx(-1)
				grid[player.x][player.y]="r"
				gameover=true
				shakex,shakey=10,10
				sfx(56)
				create_parts(1)
				upd=upd_gameover
			end
			-- delete blocks
			if grid[player.x][player.y]==0 then
				zones=new_grid(0)
				grow_zones(player.x,player.y,1)
				extend_zones()
				if zones[player.x][player.y]!=0 then
					del_zone(zones[player.x][player.y])
				end
			end
			top_grid[player.x][player.y]=0
			
			partgrid=new_grid(0)
			calcdist(player.x,player.y)
			create_part2(partgrid)
			
		elseif top_grid[player.x][player.y]==2 then
			-- nope sfx
			sfx(47)
		else
			-- chording
			local number=grid[player.x][player.y]
			local flg=0
			for i=1,8 do 
				local dx,dy=player.x+dirx[i],player.y+diry[i]
				if inbounds(dx,dy) 
				and top_grid[dx][dy]==2 then
					flg+=1
				end
			end
			if flg==number and number>0 then
				sfx(47)
				for i=1,8 do 
					local dx,dy=player.x+dirx[i],player.y+diry[i]
					if inbounds(dx,dy) then
						if top_grid[dx][dy]==1 then
							top_grid[dx][dy]=0
							sfx(-1)
							sfx(60)
							if grid[dx][dy]==0 then
								zones=new_grid(0)
								grow_zones(dx,dy,1)
								extend_zones()
								if zones[dx][dy]!=0 then
									del_zone(zones[dx][dy])
									sfx(-1)
									sfx(48)
								end
							else
								
							end
						end
										partgrid=new_grid(0)
						calcdist(dx,dy)
						create_part2(partgrid)
					end
				end
				
				for i=1,8 do 
					local dx,dy=player.x+dirx[i],player.y+diry[i]
					if inbounds(dx,dy) then
						if grid[dx][dy]=="m" then
							-- gameover
							grid[dx][dy]="r"
							sfx(-1)
							gameover=true
							shakex,shakey=10,10
							sfx(56)
							create_parts(1)
							upd=upd_gameover
							return
						end
					end
				end
			else
				-- nope sfx
				sfx(47)
			end
		end
		
		first=false
		return
	end
	
	
	if check_win()==mines then
		create_parts(1)
		gamewin=true
		upd=upd_gameover
	end
	
end

function check_win()
	local n=0
	for x=1,14 do 
		for y=1,11 do 
			if top_grid[x][y]>0 then
				n+=1
			end
		end
	end
	return n
end

function drw_cursor(x,y)
	rect(x-1,y-1,x+7,y+7,8)
end

function upd_timer()
	if minutes<100 then
		seconds+=1/60
		if flr(seconds)>=60 then
			minutes+=1
			seconds=0
		end
	end
end
__gfx__
000000000001000088818880bbb1bbb0820002807777777077777770777777707777777077777770618888605556666500000000505050509996666900000000
000000000011100088111880bb111bb0282028207666665076666650766666507000005076666650618888605566665511111111606060609966669900000000
007007000171110081711180b17111b00282820076666650766666507600065070000050761886506188886056666555aa11aa11606060609666699900000000
00077000111111101111111011111110002820007666665076606650760006507000005076188650618888606666555591199119606060606666999900000000
000770000111110081111180b11111b0028282007666665076666650760006507000005076166650616666606665555611991199606060606669999600000000
007007000011100088111880bb111bb0282028207666665076666650766666507000005076666650616666606655556614411441606060606699996600000000
000000000001000088818880bbb1bbb0820002805555555055555550555555505555555055555550616666606555566611111111707070706999966600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555666600000000000000009999666600000000
0000000000000000000000000000000000000000aaaaaaa000000000000000000000000077777770000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a999994000000000000000000000000076666650000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a999994000000000000000000000000076133650000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a999994000000000000000000000000076133650000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a999994000000000000000000000000076166650000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a999994000000000000000000000000076666650000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000004444444000000000000000000000000055555550000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880888888008800088008888800888880088000880088888088888000000000000000000000555566665555666655550000000000000000000000000000
88888880888888808880888088888808888888088000880888888088888800000000000000000000555666655556666555560000000000000000000000000000
88000000880008808888888088000008800088088000880880000088008800000000000000000000556666555566665555660000000000000000000000000000
88088880888888808888888088880008800088088000880888800088888800000000000000000000566665555666655556660000000000000000000000000000
88088880888888808808088088880008800088088000880888800088888000000000000000000000666655556666555566660000000000000000000000000000
88000880880008808800088088000008800088088808880880000088008800000000000000000000666555566665555666650000000000000000000000000000
88888880880008808800088088888808888888008888800888888088008800000000000000000000665555666655556666550000000000000000000000000000
08888800880008808800088008888800888880000888000088888088008800000000000000000000655556666555566665550000000000000000000000000000
000000bbbbbb000bbbbb0bbbbb000bbbbb00bbbbb00bbbbb0bbbbbb0000000000000000000000000555566665555666655550000000000000000000000000000
000000bbbbbbb0bbbbbb0bbbbbb0bbbbbb0bbbbbb0bbbbbb0bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000
000000bb000bb0bb00000bb00bb0bb00000bb00000bb0000000bb000000000000000000000000000000000000000000000000000000000000000000000000000
000000bbbbbbb0bbbb000bbbbbb0bbbb000bbbb000bb0000000bb000000000000000000000000000000000000000000000000000000000000000000000000000
000000bbbbbb00bbbb000bbbbb00bbbb000bbbb000bb0000000bb000000000000000000000000000000000000000000000000000000000000000000000000000
000000bb000000bb00000bb00bb0bb00000bb00000bb0000000bb000000000000000000000000000000000000000000000000000000000000000000000000000
000000bb000000bbbbbb0bb00bb0bb00000bbbbbb0bbbbbb000bb000000000000000000000000000000000000000000000000000000000000000000000000000
000000bb0000000bbbbb0bb00bb0bb000000bbbbb00bbbbb000bb000000000000000000000000000000000000000000000000000000000000000000000000000
88000880880880008800888880088888088000880088888008888808888800088888088888000000000000000000000000000000000005555555000000000000
88808880880888008808888880888888088000880888888088888808888880888888088888800000000000000000000000000000005551111111555000000000
88888880880888808808800000880000088000880880000088000008800880880000088008800000000000000000000000000000551114444444111550000000
88888880880888888808888000888880088080880888800088880008888880888800088888800000000000000000000000000005114449999999444115000000
88080880880880888808888000088888088888880888800088880008888800888800088888000000000000000000000000000051149999999999999411500000
88000880880880088808800000000088088888880880000088000008800000880000088088800000000000000000000000000514499999999999999944150000
88000880880880008808888880888888088808880888888088888808800000888888088008800000000000000000000000005149999999999999999999417000
880008808808800088008888808888800880008800888880088888088000000888880880088000000000000000000000000514999119999999999911999a1700
0000bbbbbb000bbbbb00bbbbb0bbbbbb000bbbbbb0bb0bb000bb00bbbbb0000000000000000000000000000000000000005114991119999999999911199a1170
0000bbbbbbb0bbbbbb0bbbbbb0bbbbbb000bbbbbb0bb0bbb0bbb0bbbbbb00000000000000000000000000000000000000051499111119999999991111199a170
0000bb000bb0bb00000bb0000000bb0000000bb000bb0bbbbbbb0bb0000000000000000000000000000000000000000005149911111199999999911111199a17
0000bbbbbbb0bbbb000bbbbb0000bb0000000bb000bb0bbbbbbb0bbbb00000000000000000000000000000000000000005149911111119999999111111199a17
0000bbbbbb00bbbb0000bbbbb000bb0000000bb000bb0bb0b0bb0bbbb00000000000000000000000000000000000000005149111111111999991111111119a17
0000bb000bb0bb000000000bb000bb0000000bb000bb0bb000bb0bb00000000000000000000000000000000000000000514991111111119999911111111199a1
0000bbbbbbb0bbbbbb0bbbbbb000bb0000000bb000bb0bb000bb0bbbbbb0000000000000000000000000000000000000514991111111199111991111111199a1
0000bbbbbb000bbbbb0bbbbb0000bb0000000bb000bb0bb000bb00bbbbb0000000000000000000000000000000000000514991111111191111191111111199a1
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000514991111111191111191111111199a1
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000514999999999991111199999999999a1
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000514999999999999111999999999999a1
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000514999999999999999999999999999a1
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005149999999999111119999999999a17
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005149999999999111119999999999a17
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005149999999991111111999999999a17
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051499999999111111199999999a170
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005114999999111111111999999a1170
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000514999999111111111999999a1700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005149999111111111119999a17000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051aa999911111119999aa170000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000711a9999999999999a11700000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000711aaa9999999aaa117000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077111aaaaaaa111770000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007771111111777000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050500000053000500005300052000500005000a50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010400000c54500500185350050024525005003051500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010400000c545005000c535005000c525005000c51500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010500001561421611006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
310300001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0508000013550185000000018500135501850017550000001355018500175501c50018550185501855018550185521855218552185522450018500305000000013755185000c7550000000000000000000000000
010800001855018500000001850018550185001a5500000018550185001a5501c5001c5501c5501c5501c5501c5521c5521c5521c5522450018500305000000030755185003c7550000000000000000000000000
010200000c53500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
05060000032500f200022500e200012500d2000025000250002500025000250002500025200252002520025200202002000020000200002000020000200002000020000200002000020000200002000020000200
03050000306703067525650006001e65000600146500a600106500d63009610086100060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400001854500500185350050018525005001851500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300000c6201f6300c63010610146000e6300162006610016000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
020300001871024721007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400000c54500500185350050024525005002451500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
040500000053000500005300053000520005100a50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0505000018520185150c5000050000500005000a50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
040500000c5300c5250c5000050000500005000a50000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
__music__
00 34354344


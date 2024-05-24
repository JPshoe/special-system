pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--checkers

--[[
todo:
	- only show lvl if cpu
	- settings menu
		- mandatory jumps
		- anim speed
		- palette
		- cursor mode
		- kings can long jump?
		- particles?
	- transposition table?
]]--

cartdata("jpshoe_checkers_1")

--states
title=0
setup=1
play=2
paused=3
game_over=4

anim_time=40

levels={"beginner","easy",
	"medium","hard","very hard",
	"master","grandmaster"}
	
info={
{"⬆️⬇️: navigate",
	"🅾️: select",
	"❎: back"},
{"⬆️⬇️⬅️➡️: move cursor",
	"🅾️: select",
	"❎: menu"},
{"⬆️⬇️⬅️➡️: move cursor",
	"🅾️: make move",
	"❎: deselect"},
{"🅾️: continue",},
{"  ! warning !  ",
	"twofold repetition"}
}

▒x=16
▒y=18
█=12

function _init()
	palt(15,true)
	palt(0,false)
	
	init_zobrist()
	b=setup_board()
	
	cx=1
	cy=0
	sel_p=nil
	moves={}
	wait=0
	winner=0
	state=title
	red_hum=true
	blk_hum=false
	red_lvl=1
	blk_lvl=1
	show_all_moves=false
	info_str=info[1]
	history={}
	debug_str=""
	⧗=0
	title_y=37
	title_toy=37
	
	--only for drawing, not scoring
	jumped_reds=0
	jumped_blks=0
	
	--init main menu
	main_menu=make_menu(
		"★main menu★",32,72,64)
	add_button(main_menu,"play",
		function ()
			state=setup
			sfx(0)
		end)
	--add_button(main_menu,"settings",
	--	function () sfx(2) end)
	--add_button(main_menu,"credits",
		--function () sfx(2) end)
		
	--init play menu
	play_menu=make_menu(
		"✽game setup✽",27,50,74,title)
	play_menu.sel=1
	--add_switch(play_menu,"black",
	--"cpu","hum")
	add_selector(play_menu,"lvl",
		levels)
	--add_switch(play_menu,"red",
	--	"cpu","hum")
	--play_menu[3].val=true
	--add_selector(play_menu,"lvl",
	--	levels)
	add_button(play_menu,"play",
		function ()
			state=play
			blk_hum=false
			blk_lvl=play_menu[1].val
			red_hum=true
			red_lvl="beginner"
			award=2
			sfx(0)
			if red_hum then
				info_str=info[2]
			else
				info_str={""}
			end
			title_toy=-30
		end)
		
	--init win menu
	end_menu=make_menu("●game over●",
		32,72,64,play)
	add_button(end_menu,"play again",
		function ()
			b=setup_board()
			state=play
			winner=0
			info_str=info[2]
			award=2
			sfx(0)
		end)
	add_button(end_menu,"main menu",
		function ()
			state=title
			b=setup_board()
			winner=0
			info_str=info[1]
			sfx(0)
		end)
			
	--init pause menu
	pause_menu=make_menu("◆paused◆",
		32,58,64,play)
	add_button(pause_menu,"resume",
		function ()
			state=play
			info_str=info[2]
			sfx(1)
		end)
	add_button(pause_menu,"show moves",
		function ()
			show_all_moves=true
			state=play
			info_str=info[2]
			sfx(0)
		end)
	add_button(pause_menu,"take back",
		function ()
			if #history==0 then
				sfx(2)
				return
			end
			repeat
			local h=deli(history)
				if h.jump then
					if h.jump.col==1 then
						jumped_reds-=1
						if h.jump.king then
							jumped_reds-=1
						end
					else
						jumped_blks-=1
						if h.jump.king then
							jumped_blks-=1
						end
					end
				end
				if not h.piece.king
				and (h.toy==0 or h.toy==7) then
					if h.piece.col==1 then
						jumped_reds+=1
					else
						jumped_blks+=1
					end
				end
				undo_move(b,h)
			until
				(b.turn==1 and red_hum) or
				(b.turn==-1 and blk_hum)
			state=play
			sfx(1)
			if #history==0 then
				award=2
			else
				award=1
			end
		end)
	--add_button(pause_menu,"settings",
	--	function ()
	--		sfx(2)
	--	end)
	add_button(pause_menu,"resign",
		function ()
			winner=-1*b.turn
			state=play
			info_str=info[4]
			sfx(6)
		end)
		
	--piece animations
	anim_piece=nil
	anim_fromx=0
	anim_fromy=0
	anim_tox=0
	anim_toy=0
	anim_t=0
	anim_move=nil
	
	--[[
	--background particles
	make_part_float(rnd(128),rnd(128),rnd(20)+20,6)
	make_part_float(rnd(128),rnd(128),rnd(20)+20,7)
	make_part_float(rnd(128),rnd(128),rnd(20)+20,12)
	make_part_float(rnd(128),rnd(128),rnd(20)+20,7)
	make_part_float(rnd(128),rnd(128),rnd(20)+20,6)
	make_part_float(rnd(128),rnd(128),rnd(20)+20,14)
	make_part_float(rnd(128),rnd(128),rnd(20)+20,12)
	make_part_float(rnd(128),rnd(128),rnd(20)+20,14)
	]]
end

function begin_anim(move)
	anim_move=move
	if not move then stop("nil move",1) end
	anim_fromx=▒x+move.piece.x*█+2
	anim_fromy=▒y+move.piece.y*█+2
	anim_tox=▒x+move.tox*█+2
	anim_toy=▒y+move.toy*█+2
	anim_t=0
	anim_piece=get_piece(b,
		move.piece.x,move.piece.y)
	if not anim_piece then
		stop(trace(),-32,0,1)
	end
	sfx(3)
end
-->8
--update

function _update60()
	⧗+=1
	for p in all(fore_parts) do
		update_part(p)
	end
	for p in all(back_parts) do
		update_part(p)
	end
	title_y+=0.1*(title_toy-title_y)

	if state==title then
		title_toy=37
		update_menu(main_menu)
	elseif state==setup then
		title_toy=20
		update_menu(play_menu)
	elseif state==paused then
		update_menu(pause_menu)
	elseif state==game_over then
		update_menu(end_menu)
	elseif state==play then
		if winner!=0 then
			if btnp(🅾️) then
				state=game_over
				info_str=info[1]
				sfx(0)
			end
			return
		end
			
		--animate pieces
		if anim_piece then
			anim_t+=1
			if anim_t>anim_time then
				--actually make the move
				if anim_move.jump then
					sfx(min(7+jump_count,11))
					if jump_count>0 then
						make_part_text(
							(jump_count+1).."x jump!",
							anim_tox+4,
							anim_toy-4)
					end
					if anim_piece.col==1 then
						jumped_blks+=1
						if anim_move.jump.king then
							jumped_blks+=1
						end
					else
						jumped_reds+=1
						if anim_move.jump.king then
							jumped_reds+=1
						end
					end
				end
				if not anim_move.piece.king
				and (anim_move.toy==0
				or anim_move.toy==7) then
					if anim_piece.col==1 then
						jumped_reds-=1
					else
						jumped_blks-=1
					end
					make_part_text("king me!",
						anim_tox+4,anim_toy+4)
					sfx(12)
				end
				do_move(b,anim_move)
				add(history,anim_move)
				anim_piece=nil
				sel_p=b.chain
				if sel_p then
					jump_count+=1
				else
					jump_count=0
				end
				if (b.turn==-1 and blk_hum)
				or (b.turn==1 and red_hum) then
					info_str=info[2]
				end
			end
			return
		end
		
		--check for win
		moves=get_all_moves(b)
		if #moves==0 then
			winner=b.turn*-1
			info_str=info[4]
			if(winner==-1 and red_hum
			and not blk_hum)
			or(winner==1 and blk_hum
			and not red_hum) then
				sfx(6)
			else
				sfx(5)  
			end
			return
		end
	
		--check for draw
		if b.hist[b.hash] then
			if b.hist[b.hash]>1 then
				winner=2
				info_str=info[4]
				sfx(13)
				return
			elseif b.hist[b.hash]>0 then
				info_str=info[5]
			end
		end
	
		--computer move
		if (b.turn==1 and not red_hum)
		or (b.turn==-1 and not blk_hum) then
			if cor then
				if costatus(cor)!="dead" then
					local act,err=coresume(cor)
					if err then
						stop(trace(cor,err),-32,0,10)
					end
					return
				else
					cor=nil
				end
			else
				cor=cocreate(do_cpu)
			end
			return
		end
		
		if btnp()>0 then
			show_all_moves=false
		end

		--human move
--[[
		if btnp(⬅️) then
			cx=max(0,cx-1)
		elseif btnp(➡️) then
			cx=min(7,cx+1)
		elseif btnp(⬆️) then
			cy=max(0,cy-1)
		elseif btnp(⬇️) then
			cy=min(7,cy+1)
]]--
		if btnp(⬅️) then
			if cx>1-cy%2 then
				cx-=1
				sfx(4)
			else
				sfx(2)
			end
		elseif btnp(➡️) then
			if cx<7-cy%2 then
				cx+=1
				sfx(4)
			else
				sfx(2)
			end
		elseif btnp(⬆️) then
			if cy>0 then
				cy-=1
				sfx(4)
			else
				sfx(2)
			end
		elseif btnp(⬇️) then
			if cy<7 then
				cy+=1
				sfx(4)
			else
				sfx(2)
			end
		elseif btnp(🅾️) then
			if sel_p then
				local move=find_move(moves,
					sel_p,cx,cy)
				if move then
					begin_anim(move)
					moves={}
					info_str={""}
				else
					sel_p = nil
				end
			end
			if not sel_p then
				local p=get_piece(b,cx,cy)
				if p and p.col==b.turn then
					sel_p=p
					info_str=info[3]
					sfx(0)
				else
					sfx(2)
				end
			end
		elseif btnp(❎) then
			if sel_p then
				if b.chain then
					sfx(2)
				else
					sel_p=nil
					info_str=info[2]
					sfx(1)
				end
			else
				state=paused
				info_str=info[1]
				sfx(0)
			end
		end
	end
end
-->8
--draw

function _draw()
	cls(13)

	--background particles
	for p in all(back_parts) do
		draw_part(p)
	end

	--board
	rect(▒x-1,▒y-1,▒x+█*8,
		▒y+█*8,5)
	for x=0,7 do
		for y=0,7 do
			if (x+y)%2==0 then c=8
			else c=1 end
			rectfill(▒x+x*█,▒y+y*█,
				▒x+x*█+█-1,
				▒y+y*█+█-1,c)
		end
	end
	
	--non-animating pieces
	for p in all(b.pieces) do
		if p!=anim_piece then
			if p.king then
				spr(16.5+.5*p.col,
					▒x+p.x*█+2,▒y+p.y*█+2)
			else
				spr(.5+.5*p.col,
					▒x+p.x*█+2,▒y+p.y*█+2)
			end
		end
	end
	
	--jumped pieces
	for i=1,jumped_reds do
		spr(1,3,▒y+i*8-8)
	end
	for i=1,jumped_blks do
		spr(0,117,▒y+8*(█-i))
	end
	
	if anim_piece then
		local a=anim_t/anim_time
		--animating shadow
		draw_shadow(24,0,8,8,
			lerp(anim_fromx,anim_tox,a),
			lerp(anim_fromy,anim_toy,a))
			
		--animating piece
		if anim_piece.king then
			spr(16.5+.5*anim_piece.col,
				lerp(anim_fromx,anim_tox,a),
				lerp(anim_fromy,anim_toy,a)+
				para(.025,anim_t,anim_time))
		else
			spr(.5+.5*anim_piece.col,
				lerp(anim_fromx,anim_tox,a),
				lerp(anim_fromy,anim_toy,a)+
				para(.025,anim_t,anim_time))
		end
	else
		if (b.turn==1 and red_hum)
		or (b.turn==-1 and blk_hum) then
			if show_all_moves then
				for m in all(moves) do
					sspr(16,8,10,9,
						▒x+m.piece.x*█+1,
						▒y+m.piece.y*█+2)
					spr(2,▒x+m.tox*█+2,
						▒y+m.toy*█+2)
				end
			else
				if sel_p!=nil then
					--selection indicator
					sspr(16,8,10,9,▒x+sel_p.x*
						█+1,▒y+sel_p.y*█+2)
					--move indicators
					for m in all(moves) do
						if m.piece.x==sel_p.x
						and m.piece.y==sel_p.y then
							spr(2,▒x+m.tox*█+2,
								▒y+m.toy*█+2)
						end
					end
				end
			end
		else
			if cpu_move!=nil then
				--selection indicator
				sspr(16,8,10,9,
					▒x+cpu_move.piece.x*█+1,
					▒y+cpu_move.piece.y*█+2)
				--move indicators
				spr(2,▒x+cpu_move.tox*█+2,
					▒y+cpu_move.toy*█+2)
			end
		end
	end
	
	--info string
	local str,l,i=info_str[1],0,2
	while i<=#info_str do
		if measure(str.." | "..
		info_str[i])>128 then
			print_cent(str,64,116+l,
				ui_pal.txt)
			str=info_str[i]
			l+=6
		else
			str=str.." | "..info_str[i]
		end
		i+=1
	end
	print_cent(str,64,116+l,
		ui_pal.txt)
	
	--title	
	for i=0,7 do
		sspr(i*12,42,12,18,16+i*12,
			title_y+min(2,2.3*sin((⧗-
			i*10)/100)))
	end
	sspr(0,31,64,11,16,title_y-13)
	print_out("pico-8",88,title_y
		+21,12,ui_pal.out)
		
	--main menu
	if state==title then
		draw_menu(main_menu)
		return
	elseif state==setup then
		draw_menu(play_menu)
		--beaten tag
		local beaten_val = dget(play_menu[1].val)
		if beaten_val == 1 then
			print_out("level defeated ",33,87,12,ui_pal.txt)
		elseif beaten_val == 2 then
			print_out("level defeated★",33,87,12,ui_pal.txt)
		end
		return
	elseif state==paused then
		draw_menu(pause_menu)
		return
	end
	
	--text
	if winner==0 then
		if b.turn==1 then
			print_out_cent("red to move",
				64,10,8,ui_pal.out)
		else
			print_out_cent("black to move",
				64,10,0,ui_pal.out)
		end
	elseif winner==1 then
		print_out_cent("red wins!",
			64,10,8,ui_pal.out)
		dset(blk_lvl, max(dget(blk_lvl), award))
	elseif winner==-1 then
		print_out_cent("black wins!",
			64,10,0,ui_pal.out)
	else
		print_out_cent("draw",64,10,
			ui_pal.txt,ui_pal.out)
	end
	if not blk_hum then
		if not red_hum then
			print_out_cent(
				levels[red_lvl].." vs "..
				levels[blk_lvl],64,2,
				ui_pal.txt,ui_pal.out)
		else
			print_out_cent(
				levels[blk_lvl],64,2,
				ui_pal.txt,ui_pal.out)
		end
	elseif not red_hum then
		print_out_cent(
			levels[red_lvl],64,2,
			ui_pal.txt,ui_pal.out)
	end

	--game over menu
	if state==game_over then
		draw_menu(end_menu)
		return
	end

	--cursor
	if (b.turn==1 and red_hum)
	or (b.turn==-1 and blk_hum) then
		rect(▒x+cx*█-1,▒y+cy*█-1,
			▒x+cx*█+█,▒y+cy*█+█,10)
	end
	
	--foreground particles
	for p in all(fore_parts) do
		draw_part(p)
	end
	--[[
	local y=0
	for m in all(history) do
		local str="("..
			m.piece.x..","..
			m.piece.y..") to ("..
			m.tox..","..
			m.toy..")"
		if m.chain then
			str=str.." chain"
		end
		print(str,0,y,10)
		y+=8
	end
	
	print_piece(b.chain,64,120,10)

	print(debug_str,1,1,0)

	print_board(b,0,0,10,12)
	if cpu_move then
		local str="("..
			cpu_move.piece.x..","..
			cpu_move.piece.y..") to ("..
			cpu_move.tox..","..
			cpu_move.toy..")"
		print(str,64,122,10)
	end
	]]
end
-->8
--tools

shadow_cols={0,0,5,2,0,13,6,2,
	4,9,3,1,5,8,9}

function clamp(n,lo,hi)
	return max(min(n,hi),lo)
end

function valid_square(x,y)
	return x>=0 and x<=7 and y>=0
		and y<=7
end

function lerp(from,to,a)
	return from+(to-from)*a
end

function para(a,t,tt)
	return a*t*(t-tt)
end

function draw_shadow(sx,sy,sw,sh,dx,dy)
	for x=0,sw do
		for y=0,sh do
			if sget(sx+x,sy+y)==5 then
				pset(dx+x,dy+y,
					shadow_cols[pget(dx+x,dy+y)])
			end
		end
	end
end

function rrectfill2(x1,y1,x2,y2,oc,ic)
	rectfill(x1+1,y1+1,x2-1,y2-1,oc)
	rectfill(x1+2,y1,x2-2,y2,oc)
	rectfill(x1,y1+2,x2,y2-2,oc)
	rectfill(x1+1,y1+2,x2-1,y2-2,ic)
	rectfill(x1+2,y1+1,x2-2,y2-1,ic)
end

function print_out(text,x,y,tcol,ocol)
	for i=-1,1 do
		for j=-1,1 do
			print(text,x+i,y+j,ocol)
		end
	end
	print(text,x,y,tcol)
end

function measure(str)
	local sum=0
	for i=1,#str do
		if ord(sub(str,i,i))<128 then
			sum+=4
		else
			sum+=8
		end
	end
	return sum
end

function shuffle(table)
	for i=1,#table do
		local r=flr(rnd(#table))+1
		local temp=table[i]
		table[i]=table[r]
		table[r]=temp
	end
end

function print_cent(str,x,y,c)
	w=measure(str)
	print(str,x-w/2,y,c)
end

function print_out_cent(str,x,y,tcol,ocol)
	w=measure(str)
	print_out(str,x-w/2,y,tcol,ocol)
end

function bin_ins(table,item)
	local lo,hi=1,#table
	local md=flr((hi+lo)/2)
	while lo<=hi do
		if table[md].val>item.val then
			lo=md+1
		elseif table[md].val<item.val then
			hi=md-1
		else
			if rnd(2)>1 then
				add(table,item,md)
			else
				add(table,item,md+1)
			end
			return
		end
		md=flr((hi+lo)/2)
	end
	add(table,item,md+1)
end
--[[
function merge(t1,t2)
	local tr={}
	while #t1+#t2>0 do
		if #t1==0 then
			add(tr,deli(t2,1))
		elseif #t2==0 then
			add(tr,deli(t1,1))
		else
			if t1[1].val>t2[1].val then
				add(tr,deli(t1,1))
			elseif t1[1].val<t2[1].val then
				add(tr,deli(t2,1))
			else
				if rnd(2)>1 then
					add(tr,deli(t1,1))
				else
					add(tr,deli(t2,1))
				end
			end
		end
	end
	return tr
end
]]

function rnd32()
	return rnd()<<16 | rnd()
end
-->8
--board
function setup_board()
	local b={}
	b.turn=1
	b.chain=nil
	b.pieces={}
	for y=0,2 do --0,2
		for x=0,7,2 do --0,7,2
			add(b.pieces,
				make_piece(x-y%2+1,y,-1))
			add(b.pieces,
				make_piece(x+y%2,7-y,1))
		end
	end
	b.hist={}
	b.hash=hash(b)
	
	jumped_reds=0
	jumped_blks=0
	history={}
	return b
end

function copy_board(board)
	local n_board={}
	n_board.turn=board.turn
	n_board.pieces={}
	for p in all(board.pieces) do
		add(n_board.pieces,
			copy_piece(p))
	end
	if board.chain then
		n_board.chain=get_piece(
			n_board,board.chain.x,
			board.chain.y)
	end
	n_board.hist={}
	for k,v in pairs(board.hist) do
		n_board.hist[k]=v
	end
	n_board.hash=board.hash
	return n_board
end

function print_board(▒,x,y,c,c_sel)
	local xx,yy=x,y
	for p in all(▒.pieces) do
		if p==sel_p then
			print_piece(p,xx,yy,c_sel)
		else
			print_piece(p,xx,yy,c)
		end
		yy+=6
		if yy>122 then
			xx+=64
			yy=y
		end
	end
end

--pieces
function make_piece(x,y,c)
	local p={}
	p.x=x
	p.y=y
	p.col=c
	p.king=false
	return p
end

function get_piece(board,x,y)
	for p in all(board.pieces) do
		if p.x==x and p.y==y then
			return p
		end
	end
end

function copy_piece(piece)
	if not piece then return end
	local n_piece={}
	n_piece.x=piece.x
	n_piece.y=piece.y
	n_piece.col=piece.col
	n_piece.king=piece.king
	return n_piece
end

function print_piece(p,x,y,c)
	if not p then
		print(nil,x,y,c)
		return
	end
	local str="("..p.x..","..p.y..
		") "..p.col
	if p.king then
		str=str.." king"
	end
	print(str,x,y,c)
end

--moves
function make_move(p,x,y,jump,chain)
	local m={}
	m.piece=copy_piece(p)
	m.chain=chain
	m.tox=x
	m.toy=y
	m.jump=copy_piece(jump)
	if p.y==0 or p.y==7 then
		if p.king then
			m.val=10
		else
			m.val=-10
		end
	else
		if p.col==-1 then
			m.val=p.y
		else
			m.val=(7-p.y)
		end
	end
	return m
end

function find_move(moves,p,x,y)
	for	m in all(moves) do
		if m.piece.x==p.x
		and m.piece.y==p.y
		and m.tox==x
		and m.toy==y then
			return m
		end
	end
end

function get_all_moves(b)
	local jumps,quiet={},{}
	for p in all(b.pieces) do
		if p.col==b.turn
		and (p==b.chain
		or not b.chain) then
			for m in all(get_moves(b,p)) do
				if m.jump then
					bin_ins(jumps,m)
				else
					bin_ins(quiet,m)
				end
			end
		end
	end
	if #jumps>0 then return jumps end
	return quiet
end

function get_moves(board,p)
	local jumps,quiet={},{}
	local l=check_move(board,p,-1,
		-p.col)
	if l then
		if l.jump then
			add(jumps,l)
		else
			add(quiet,l)
		end
	end
	local r=check_move(board,p,1,
		-p.col)
	if r then
		if r.jump then
			add(jumps,r)
		else
			add(quiet,r)
		end
	end
	if p.king then
		local bl=check_move(board,p,
			-1,p.col)
		if bl then
			if bl.jump then
				add(jumps,bl)
			else
				add(quiet,bl)
			end
		end
		local br=check_move(board,p,
			1,p.col)
		if br then
			if br.jump then
				add(jumps,br)
			else
				add(quiet,br)
			end
		end
	end
	if #jumps>0 then	return jumps end
	return quiet
end

function check_move(▒,p,dx,dy)
	local x,y=p.x+dx,p.y+dy
	if not valid_square(x,y) then
		return
	end
	
	local jump=get_piece(▒,x,y)
	if jump==nil then
		if not ▒.chain then
			return make_move(p,x,y)
		end
		return
	end
	x+=dx
	y+=dy
	if jump.col!=p.col
	and valid_square(x,y)
	and	not get_piece(▒,x,y) then
		return make_move(p,x,y,jump,
			▒.chain)
	end
end

function do_move(▒,move)
	local piece=get_piece(▒,
		move.piece.x,move.piece.y)
	if not piece then
		print_board(▒,0,0,14)
		print_piece(move.piece,64,
			122,14)
		stop()
	end
	if ▒.hist[▒.hash] then
		▒.hist[▒.hash]+=1
	else
		▒.hist[▒.hash]=1
	end
	--hash old piece out
	▒.hash^^=hash_piece(piece)
	piece.x=move.tox
	piece.y=move.toy
	if move.toy==
	3.5-3.5*piece.col then
		piece.king=true
	end
	--hash new piece in
	▒.hash^^=hash_piece(piece)
	if move.jump then
		local jpiece=get_piece(▒,
			move.jump.x,move.jump.y)
		if not jpiece then
			print_board(▒,0,0,7)
			print_piece(move.jump,64,0,7)
			stop()
		end
		del(▒.pieces,jpiece)
		--hash jumped piece out
		▒.hash^^=hash_piece(jpiece)
		▒.chain=piece
		if #get_moves(▒,piece)==0 then
			▒.turn*=-1
			▒.chain=nil
		end
	else
		▒.turn*=-1
		▒.chain=nil
	end
	wait=20
end

function undo_move(▒,move)
	local piece=get_piece(▒,
		move.tox,move.toy)
	if not piece then
		print_board(▒,0,0,10)
		print_piece(move.jump,64,0,10)
		stop()
	end
	--hash new piece out
	▒.hash^^=hash_piece(piece)
	piece.x=move.piece.x
	piece.y=move.piece.y
	piece.king=move.piece.king
	--hash old piece in
	▒.hash^^=hash_piece(piece)
	if move.jump then
		--stop(move.jump.x,0,10,10)
		add(▒.pieces,copy_piece(
			move.jump))
		--hash jumped piece in
		▒.hash^^=hash_piece(move.jump)
	end
	▒.turn=piece.col
	if move.chain then
		▒.chain=piece
	else
		▒.chain=nil
	end
	▒.hist[▒.hash]-=1
end

function pass_turn()
	moves={}
	sel_p=nil
end
-->8
--minimax

trans={}
upper_bound=0
lower_bound=1
exact=2

function do_cpu()
	local lvl
	if b.turn==1 then
		lvl=red_lvl
	elseif b.turn==-1 then
		lvl=blk_lvl
	end
	get_move(copy_board(b),lvl)
	begin_anim(cpu_move)
	cpu_move=nil
end

function get_move(▒,depth)
	local moves=get_all_moves(▒)
	cpu_move=moves[1]
	if #moves<2 then
		return cpu_move
	end
	--shuffle(moves)
	--[[
	local a,b=-999,999
	if #▒.pieces<10 then
		a=999
		b=-999
		depth*=2
	end
	]]
	
	if ▒.turn==1 then
		local best_val=-999
		for m in all(moves) do
			do_move(▒,m)
			local val=search(▒,depth,
				-999,999)
			undo_move(▒,m)
			if val>best_val then
				best_val=val
				cpu_move=m
			end
		end
		--debug_str=tostr(best_val)
	else
		local best_val=999
		for m in all(moves) do
			do_move(▒,m)
			local val=search(▒,depth,
				-999,999)
			undo_move(▒,m)
			if val<best_val then
				best_val=val
				cpu_move=m
			end
		end
		--debug_str=tostr(best_val)
	end
	return cpu_move
end

function search(▒,depth,a,b)
	if stat(1)>.8 then
		yield()
	end
	--[[
	local tr=trans[▒.hash]
	if tr then
		if tr.depth>=depth then
			if (tr.flag==upper_bound
			and tr.val<=a)
			or (tr.flag==lower_bound
			and tr.val>=b)
			or tr.flag==exact then
				return tr.val
			end
		end
	end
	]]
	if depth<=0 then
		--trans[▒.hash]=trans_entry(
			--bv,exact,0)
		return evaluate(▒)
	end
	local bv
	if ▒.turn==1 then
		bv=-999
		for move in all(
			get_all_moves(▒)) do

			do_move(▒,move)
			bv=max(bv,search(▒,depth-1,
				a,b))
			undo_move(▒,move)
			a=max(a,bv)
			if bv>=b then
				--trans[▒.hash]=trans_entry(
					--bv,lower_bound,depth)
				return bv
			end
		end
	else
		bv=999
		for move in all(
			get_all_moves(▒)) do
			
			do_move(▒,move)
			bv=min(bv,search(▒,depth-1,
				a,b))
			undo_move(▒,move)
			b=min(b,bv)
			if bv<=a then
				--trans[▒.hash]=trans_entry(
					--bv,upper_bound,depth)
				return bv
			end
		end
	end
	--trans[▒.hash]=trans_entry(
		--bv,exact,depth)
	return bv
end

function evaluate(board)
	if board.hist[board.hash]
	and board.hist[board.hash]>1 then
		return 0
	end
	local sum=0
	for p in all(board.pieces) do
		sum+=10*p.col
		if #board.pieces<=10 then
			if p.king then
				sum+=5*p.col
			end
			sum+=0.01*(min(p.x,7-p.x)
				+min(p.y,7-p.y))*p.col
		else
			if p.king then
				sum+=5*p.col
				if p.y==0
				or p.y==7 then
					sum-=p.col
				end
			else
				if p.col==-1 then
					sum-=0.01*p.y
				else
					sum+=0.01*(7-p.y)
				end
				if p.y==0
				or p.y==7 then
					sum+=p.col
				end
			end
		end
	end
	return sum
end

function init_zobrist()
	zob={}
	for i=0,63 do
		zob[i]={}
		--zob[i][0]=rnd32() --empty
		zob[i][1]=rnd32() --red king
		zob[i][2]=rnd32() --red man
		zob[i][-1]=rnd32() --blk king
		zob[i][-2]=rnd32() --blk man
	end
end

function hash(▒)
	local h=0
	for p in all(▒.pieces) do
		h^^=hash_piece(p)
	end
	return h
end

function hash_piece(p)
	if p.king then
			return zob[p.x+p.y*7][2*p.col]
		else
			return zob[p.x+p.y*7][p.col]
		end
end

function trans_entry(val,flag,depth)
	local entry={}
	entry.val=val
	entry.flag=flag
	entry.depth=depth
	return entry
end
-->8
--ui

ui_pal={}
ui_pal.bkg=7
ui_pal.bor=0
ui_pal.txt=1
ui_pal.out=6
ui_pal.sel=10
ui_pal.uns=5

function make_menu(name,x,y,w,back)
	local menu={}
	menu.title=name
	menu.x=x
	menu.y=y
	menu.w=w
	menu.h=17
	menu.sel=1
	menu.back=back or title
	return menu
end

function add_button(menu,text,action)
	local opt={}
	opt.text=text
	opt.🅾️=action
	
	opt.type="button"
	add(menu,opt)
	menu.h+=8
end

function add_switch(menu,text,ftext,ttext)
	local opt={}
	opt.text=text
	opt.ftext=ftext
	opt.ttext=ttext
	
	opt.type="switch"
	opt.val=false
	opt.🅾️=function ()
		opt.val=not opt.val
		if opt.val then
			sfx(0)
		else
			sfx(1)
		end
	end
	opt.⬅️=function ()
		if opt.val then
			sfx(1)
		else
			sfx(2)
		end
		opt.val=false
	end
	opt.➡️=function ()
		if opt.val then
			sfx(2)
		else
			sfx(0)
		end
		opt.val=true
	end
	add(menu,opt)
	menu.h+=10
end

function add_selector(menu,text,items)
	local opt={}
	opt.text=text
	opt.items=items
	
	opt.type="selector"
	opt.val=1
	opt.tw=0
	for str in all(items) do
		opt.tw=max(opt.tw,measure(str))
	end
	opt.tw+=4
	opt.⬅️=function ()
		if opt.val>1 then
			opt.val=opt.val-1
			sfx(1)
		else
			sfx(2)
		end
	end
	opt.➡️=function ()
		if opt.val<#opt.items then
			opt.val=opt.val+1
			sfx(0)
		else
			sfx(2)
		end
	end
	opt.🅾️=function ()
		opt.val+=1
		if opt.val>#opt.items then
			opt.val=1
		end
		sfx(0)
	end
	add(menu,opt)
	menu.h+=10
end

function update_menu(menu)
	if btnp(❎) then
		state=menu.back
		if menu.back == play then
			info_str=info[2]
		end
		sfx(1)
	elseif btnp(⬆️) then
		menu.sel-=1
		if menu.sel<1 then
			menu.sel=#menu
		end
		sfx(4)
	elseif btnp(⬇️) then
		menu.sel+=1
		if menu.sel>#menu then
			menu.sel=1
		end
		sfx(4)
	elseif btnp(🅾️)
	and menu[menu.sel].🅾️ then
		menu[menu.sel]:🅾️()
	elseif btnp(⬅️)
	and menu[menu.sel].⬅️ then
		menu[menu.sel]:⬅️()
	elseif btnp(➡️)
	and menu[menu.sel].➡️ then
		menu[menu.sel]:➡️()
	end
end

function draw_menu(m)
	--background
	rrectfill2(m.x,m.y,m.x+m.w-1,
		m.y+m.h-1,m.bcol,ui_pal.bkg)
		
	--title
	print_out_cent(m.title,m.x+
		m.w/2,m.y+4,ui_pal.txt,
		ui_pal.out)
	line(m.x+5,m.y+12,m.x+m.w-6,
		m.y+12,ui_pal.txt)

	--options
	oy=m.y+14
	for i=1,#m do
		local opt=m[i]
		if opt.type=="button" then
			if i==m.sel then
				rrectfill2(m.x+5,oy,
					m.x+m.w-6,oy+8,ui_pal.sel,
					ui_pal.out)
			end
			print_cent(opt.text,
				m.x+m.w/2,oy+2,ui_pal.txt)
			oy+=8
		elseif opt.type=="switch" then
			print(opt.text,m.x+5,oy+2,
				ui_pal.txt)
			local tw=measure(opt.ttext)+
				measure(opt.ftext)+7
			rrectfill2(m.x+m.w-6-tw,oy,
				m.x+m.w-6,oy+8,ui_pal.uns,
				ui_pal.bkg)
			local c=ui_pal.txt
			if i==m.sel then c=ui_pal.sel end
			local c1,c2,l,r
			if opt.val then
				l=m.x+m.w-10-
					measure(opt.ftext)
				r=m.x+m.w-6
				c1=ui_pal.out
				c2=ui_pal.txt
			else
				l=m.x+m.w-6-tw
				r=m.x+m.w-9-
					measure(opt.ftext)
				c1=ui_pal.txt
				c2=ui_pal.out
			end
			rrectfill2(l,oy,r,oy+8,c,
				ui_pal.out)
			print(opt.ftext,m.x+m.w-3-
				tw,oy+2,c1)
			print(opt.ttext,m.x+m.w-7-
				measure(opt.ftext),oy+2,c2)
			oy+=10
		elseif opt.type=="selector" then
			local c=ui_pal.txt
			if i==m.sel then c=ui_pal.sel end
			print(opt.text,m.x+5,oy+2,
				ui_pal.txt)
			rrectfill2(m.x+m.w-6-opt.tw,
				oy,m.x+m.w-6,oy+8,c,
				ui_pal.out)
			print_cent(
				opt.items[opt.val],m.x+m.w-
				5-opt.tw/2,oy+2,ui_pal.txt)
			oy+=10
		end
	end
end
-->8
--particles

back_parts={}
fore_parts={}

function make_part_text(text,x,y)
	local p={}
	p.type="text"
	p.x=x
	p.y=y
	p.text=text
	p.⧗=60
	p.vx=0
	p.vy=-0.3
	add(fore_parts,p)
	return p
end

function make_part_float(x,y,r,c)
	local p={}
	p.type="float"
	p.x=x
	p.y=y
	p.r=r
	p.c=c
	p.⧗=-1
	p.vx=rnd(1)-.5
	p.vy=rnd(1)-.5
	add(back_parts,p)
	return p
end

function update_part(p)
	if p.⧗>=0 then
		p.⧗-=1
		if p.⧗<0 then
			del(fore_parts,p)
			del(back_parts,p)
		end
	end
	p.x+=p.vx
	p.y+=p.vy
	if p.type=="float" then
		if p.x>128+p.r then
			p.x=-p.r
		end
		if p.x<-p.r then
			p.x=128+p.r
		end
		if p.y>128+p.r then
			p.y=-p.r
		end
		if p.y<-p.r then
			p.y=128+p.r
		end
	end
end

function draw_part(p)
	if p.type=="text" then
		if p.⧗%8>4 then
			print_out_cent(p.text,p.x,
				p.y,ui_pal.txt,ui_pal.out)
		else
			print_out_cent(p.text,p.x,
				p.y,12,ui_pal.out)
		end
	elseif p.type=="float" then
		circfill(p.x,p.y,p.r,p.c)
	end
end
__gfx__
ffffffffffffffffffffffffffffffff88888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff5555ffff8888ffffffffffff5555ff88888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f555555ff888888ffffaaffff555555f88888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5555555588888888ffaaaaff555555558888882211fffffffafff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5555555588888888ffaaaaff55555555888822221111fffff99eb6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0555555028888882fffaafff55555555888822221111ffffc4483dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f055550ff288882ffffffffff555555f8882222211111fff122255ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff0000ffff2222ffffffffffff5555ff8882222211111fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff5555ffff8888fffffaaaaffffffffffff1111122222888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f500005ff822228fffaffffafffffffffff1111122222888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5055550582888828faffffffafffffffffff111122228888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
5055550582888828affffffffaffffffffff111122228888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0500005028222282affffffffaffffffffffff1122888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
0055550022888822affffffffaffffffffffffff88888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f000000ff222222ffaffffffafffffffffffffff88888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff0000ffff2222ffffaffffaffffffffffffffff88888888ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffaaaafffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff66666fffffffffffffffffff666ffffffffffffffff666fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff66ccc6fffffffffffffffffff6c6fffffffffffff6666c6666666666666fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f66c6666ffffffffffffffffff66c6fffffffffffff6cccccccccccccccc6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
66c66ffff66666666666666f666c666666666666f666666c6666666666666fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
6c66666666ccc66ccc6ccc666ccc6cc6cc66ccc666cc66c666cc666ccc6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
6c66ccc66c66c6c66c6c66c6c66c6c6c6c6c66c66c6c66c66c6c66c66c6fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
6c6666c6c66c6c66c6c66c6c66c6c666c6c66c66c66c6cc66cc66c66c666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
66cc6c6cc66cc6ccccc66ccccc6cc6f6cc6cccccccc6c66ccc6ccc66ccc6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f6666c666666666666666666666666f66666666666666666666666666666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff6c6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f6666666666f666666666666666666666666f6666666666f66666666666666666666666666666666666ff6666666666fffffffffffffffffffffffffffffffff
661111111166611116611116611111111116661111111166611116611116611111111116611111111166661111111166ffffffffffffffffffffffffffffffff
611111111116611116611116611111111116611111111116611116611116611111111116611111111116611111111116ffffffffffffffffffffffffffffffff
611111111116611116611116611111111116611111111116611116111116611111111116611111111116611111111116ffffffffffffffffffffffffffffffff
611111111116611116611116611111111116611111111116611116111166611111111116611111111116611111111116ffffffffffffffffffffffffffffffff
61111661111661111661111661111666666661111661111661111611116f611116666666611116611116611116611116ffffffffffffffffffffffffffffffff
611116611116611116611116611116666fff61111661111661111111116f611116666fff611116611116611116661116ffffffffffffffffffffffffffffffff
611116666666611111111116611111116fff61111666666661111111166f611111116fff611111111116611111166666ffffffffffffffffffffffffffffffff
6111166ffff6611111111116611111116fff6111166ffff66111111116ff611111116fff61111111116666111111166fffffffffffffffffffffffffffffffff
6111166ffff6611111111116611111116fff6111166ffff66111111116ff611111116fff61111111166ff66111111166ffffffffffffffffffffffffffffffff
611116666666611111111116611111116fff61111666666661111111166f611111116fff61111111166f666661111116ffffffffffffffffffffffffffffffff
611116611116611116611116611116666fff61111661111661111111116f611116666fff61111111116f611166611116ffffffffffffffffffffffffffffffff
61111661111661111661111661111666666661111661111661111611116f61111666666661111611116f611116611116ffffffffffffffffffffffffffffffff
611111111116611116611116611111111116611111111116611116111166611111111116611116111166611111111116ffffffffffffffffffffffffffffffff
611111111116611116611116611111111116611111111116611116111116611111111116611116111116611111111116ffffffffffffffffffffffffffffffff
611111111116611116611116611111111116611111111116611116611116611111111116611116611116611111111116ffffffffffffffffffffffffffffffff
661111111166611116611116611111111116661111111166611116611116611111111116611116611116661111111166ffffffffffffffffffffffffffffffff
f6666666666f666666666666666666666666f6666666666f666666666666666666666666666666666666f6666666666fffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaafaaaffaaffaafffffaaafffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafaffaffafffafafffffafafffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaaaffaffafffafafaaafaaafffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaffffaffafffafafffffafafffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafffaaaffaafaaffffffaaafffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
__sfx__
000c00001a7701f770000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001f7701a770180000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000c4400c4400c4400c4000c4000c4400c4400c440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000c5540d5510e5510f551105511155112571135711257111571105710f5710e5710d5710c5710967107651046310262100611006110050100501005010050100501005010050100501005010050100500
000600001704019040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c170181701c1701f1701c1701f1702417024170241702417000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000000
011000001a1701a1701a1701910019170191701917000100181701817018170181701817018170001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
01100000180701c0701f0700000000000000001c0001f000240000000000000000001f000240002800000000000000000024000280002b000000000000000000280002b000300000000000000000000000000000
011000001c0701f070240700000000000000001f000240002800000000000000000024000280002b000000000000000000280002b000300000000000000000000000000000000000000000000000000000000000
011000001f070240702807000000000000000024000280002b000000000000000000280002b000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000024070280702b0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000280702b070300700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001816013150181601c1601f160241702417000100241702417000100241702417024170241000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000800001f0501f0500000024050000000000000000000001f0501f050000001c0500000000000000000000018050180500000000000000000000000000000000000000000000000000000000000000000000000

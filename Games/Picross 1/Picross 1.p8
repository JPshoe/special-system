pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
dev=0
dev_preview=0
ver="1.04"
latest_update="2022/09/19"

poke(0x5f5c, 12) poke(0x5f5d, 3) -- input delay(default 15, 4)
poke(0x5f2d, 0x1) -- use mouse input

-- [qr code] bit.ly/33xv3zm
qr_data_zip="レクトレへキfbケアつはケオjはケオjはケへにはへゃタbレょょレajゅaセまeコリnラヤへホソ(cうxやハミゅdハミゅdハ^(!oテq^bいフeヘナxシa#ミほレやク^へアあふケエハサケゆえdケゆえdケるgスへエらにレカラツ"
qr_data=""
qr_size=28

-- メ▥⬆️ミたひ マぬ█ミすひ ミˇ😐 ム⧗ま メ😐そメ░ひ(ムき…ムき… ムせ░メˇ▤マの😐)
cover_pattern_str=[[
0b1111111111111111.1,
0b1111011111111101.1,
0b1111010111110101.1,
0b1011010111100101.1,
0b1010010110100101.1,
0b0010010110000101.1,
0b0000010100000101.1,
0b0000010000000001.1,
0b0000000000000000.1
]]

-- particla data(x,y,colorミしも メ⬆️░ミき☉ムお░ ミ⬅️そムう░ミくう ミにまミすて マは░ム🐱ぬメˇう マぬ★)
-- メ●きメ▒ぬ ムˇ░ミ▒もミきさマはき ム⌂さメ⌂まミせ▒ムうもミくう ムお➡️ム░ね, ム⬅️さメ∧웃 ムせ▒メい░ム❎… ミぬぬム❎ひミくう ミは█メ▥▤メˇそ
p_data={}
p_str=[[
3,1,7,4,1,7,5,1,7,6,1,7,6,1,10,7,1,10,8,2,10,9,2,9,9,2,9,10,2,4,10,2,5,11,2,5,11,2,2,11,2,2/
2,2,7,2,2,7,2,3,7,3,3,7,3,3,7,4,4,7,4,4,7,4,5,10,5,5,10,5,5,10,5,6,10,6,6,10,6,6,9,6,7,9,6,7,9,7,7,4,7,7,4,7,8,4,7,8,5/
1,3,7,1,4,7,1,4,7,1,5,7,2,6,10,2,7,10,2,7,10,2,8,10,2,9,9,2,9,9,3,10,4,3,10,5,3,11,5,3,11,2,3,11,2/
-1,3,7,-1,3,7,-1,4,7,-2,5,7,-2,6,10,-2,6,10,-2,7,10,-2,7,10,-3,8,9,-3,9,9,-3,9,4,-3,10,4,-3,10,5,-3,10,5,-3,11,2,-4,11,2/
-2,1,7,-3,1,7,-4,1,7,-4,2,7,-5,2,7,-5,2,7,-6,2,10,-6,3,10,-7,3,10,-7,3,10,-8,3,10,-8,3,9,-9,3,9,-9,4,4,-9,4,4,-10,4,4,-10,4,5,-10,4,5,-11,4,2/
-3,-1,7,-4,-1,7,-4,-1,7,-5,-1,7,-6,-1,10,-7,-1,10,-7,-1,10,-8,-2,10,-9,-2,9,-9,-2,9,-10,-2,4,-10,-2,4,-11,-2,5,-11,-2,5,-11,-2,2,-11,-2,2/
-1,-3,7,-2,-3,7,-2,-4,7,-3,-5,7,-3,-5,10,-3,-6,10,-4,-7,10,-4,-7,10,-4,-8,9,-5,-8,9,-5,-9,4,-5,-9,5,-5,-10,5,-5,-10,2,-6,-10,2/
0,-3,7,0,-3,7,0,-4,7,-1,-4,7,-1,-5,7,-1,-5,7,-1,-6,10,-1,-6,10,-1,-7,10,-1,-7,10,-1,-8,10,-1,-8,9,-1,-9,9,-1,-9,9,-1,-10,4,-1,-10,4,-1,-10,4,-1,-11,5,-1,-11,5/
2,-2,7,2,-3,7,3,-4,7,3,-5,7,4,-6,10,4,-6,10,4,-7,10,5,-7,9,5,-8,9,5,-9,4,6,-9,5,6,-9,5,6,-10,2,6,-10,2/
2,-1,7,3,-1,7,3,-1,7,4,-1,7,4,-1,7,5,-2,7,5,-2,7,6,-2,10,6,-2,10,7,-2,10,7,-2,10,8,-3,10,8,-3,9,9,-3,9,9,-3,9,9,-3,4,10,-3,4,10,-3,4,10,-3,5
]]



-- puzzle data ------------------------------------------------
--pz_for_init={2,2,"y"} -- 2x2ムせうミすて マもてミせ☉ ミ♪ぬムえひメ⬇️█
pz={}
pz_decoded={} -- ム⬅️さメ∧웃 メい░ム❎… ミ⬆️⬆️ムや⬆️ミ⬆️たメˇう ミ♪ぬムえひメ⬇️█ ミはひマひ█(cpu ムき☉ムˇやムあた)
pz_cleared={} -- メ▒ひミすてム∧ひメˇう メ♪もムす… マまぬミくえ(マぬ▥ムえ█ idxム❎… 1ムえひ ムお☉ムうもミたひ メ▒ひミすてム∧ひ)
pz_str=[[
9,9,%pメレiホ%レやレミお/
13,11,lヒしフなミサヨよメ%ノえキoキなコサコa/
5,8,ねふキ&むy/
9,9,%pメレiスzえハふらを/
11,13,pフモ%dヒコrるpヒレもサなbモhサ%ヒ/
9,9,cbdリレメふリも%cへ/
13,13,iqなフレメレラなヤホレふヤ$レモレサほcriba/
11,10,ヒのaツソレeゆねほモらるaモ@/
12,14,jaaeへa^あaa%モわユレ%ラハリレみラhサ/
13,8,ふリめしかケょラきハレdaea/
13,15,aへ&qっいけオフちくユゅ#なlへ@aibルbモbサba/
9,9,opムえクリユアbナハヒ/
15,15,@a%ya$@p%ta@i%o%ハコレヤsひれケあわそハよtレレへ/
12,15,レレホレわヤわチのチたzホ%るレわルふレラアてよレラ/
10,10,aへesうxナリかめjqeba/
15,15,レレレクリネはとふせレモメキつゅれムえルにレaレo%pやhシレレへ/
15,11,cqdキdレdレセさエやmレルヨとケえイレをレa/
8,7,なちpxホヒヒq/
15,15,ひ%ふコヤヌせチエセnリレルひaa%pコハラムなヒなヒなルふレふへ/
9,9,ふイハpヨリレレハコしヒ/
15,7,@o!pコト@fコヨリヤルなょ/
13,10,aniえヒn^しレpルhルkuあいri/
8,13,q*ebc^q@#%しメヤモな/
11,11,haゅhサてrスコ(キ%シノpヒひa/
8,8,むひvhbbスユケa/
12,14,zんレしルモねトハa%ユふマdケろモねレニルもち/
8,11,レサとカネムd(ユテすxヒ/
12,5,ふヨふモユムひヒヒ/
13,11,hapサtモ^ヒへしaノbラ$ヒキbモbサ/
9,10,レヒnニaニyhレナミしル/
10,13,gaサ$dサルmセててハ%レス^あnへ/
11,7,caなhサaeiフハコ/
15,14,ararariレeレセチなふレsっるd(くhレceddへaき/
9,9,ehセリレレヒへquha/
9,15,edほウひnみフルノヒi^ihbサラ%a/
15,11,レレサaとぬオvこきgメくabレツへuamaea/
13,13,な#yろレふセメdへヒ(フリふふムょけavきやルa/
15,9,pのi&eqめほゅノチpみネともウコレへ/
12,12,aサda@bシハヤふタレxモコスレibサa/
13,15,レレコリふホふセふdラbサbacaobメみわhケo@ふラ/
9,9,ヘよユ#スajくさエs^/
13,13,aヒdヒpフハメハレレレルふモi&uっらかいuっa/
11,13,@b^kaをfモきヘょレけoツケiお*^q/
15,15,ふへふヒzykeecくdふセろヨス%サcpへゆqkむekdリbaへ/
11,10,bモr$tユ%はとラふぬモzへモ/
13,13,gamすyセレメレセmgymせレヨレフもdmaya/
12,14,pラ^r@むsrゆへ*rieふフなやルきっょ%モ/
11,9,^tdxトaらuむけゃ^vルへ/
13,13,hサふフレホレノレモフヨよレねないasa(dbモa/
13,11,$aむcしヒを(しナへやレe^%へ*hラa/
15,15,abへbセレホレヨレレレリモiリノなク@ねノaxみヨテ^メモyea/
9,11,oh&モひhaへラあをpレレへ/
11,11,むルおきオちr$aiろネnきスもtへ/
13,13,@なリヨクひ@ひクニイo@ぬミノコo%さメハやoa/
10,11,qわレレヒgススネめむカlaふラ/
11,12,ふfキあフレaすコやpiテルkよおえラ/
]]



--------------------------------------------------
-- class helper
function class(base)
	local nc={}
	if (base) setmetatable(nc,{__index=base}) 
	nc.new=function(...) 
		local no={}
		setmetatable(no,{__index=nc})
		local cur,q=no,{}
		repeat
			local mt=getmetatable(cur)
			if not mt then break end
			cur=mt.__index
			add(q,cur,1)
		until cur==nil
		for i=1,#q do
			if (rawget(q[i],'init')) rawget(q[i],'init')(no,...)
		end
		return no
	end
	return nc
end

-- event dispatcher
event=class()
function event:init()
	self._evt={}
end
function event:on(event,func,context)
	self._evt[event]=self._evt[event] or {}
	-- only one handler with same function
	self._evt[event][func]=context or self
end
function event:remove_handler(event,func,context)
	local e=self._evt[event]
	if (e and (context or self)==e[func]) e[func]=nil
end
function event:emit(event,...)
	for f,c in pairs(self._evt[event]) do
		f(c,...)
	end
end

-- sprite class for scene graph
sprite=class(event)
function sprite:init()
	self.children={}
	self.parent=nil
	self.x=0
	self.y=0
end
function sprite:set_xy(x,y)
	self.x=x
	self.y=y
end
function sprite:get_xy()
	return self.x,self.y
end
function sprite:add_child(child)
	child.parent=self
	add(self.children,child)
end
function sprite:remove_child(child)
	del(self.children,child)
	child.parent=nil
end
function sprite:remove_self()
	if self.parent then
		self.parent:remove_child(self)
	end
end
-- logical xor
function lxor(a,b) return not a~=not b end
-- common draw function
function sprite:_draw(x,y,fx,fy)
	spr(self.spr_idx,x+self.x,y+self.y,self.w or 1,self.h or 1,lxor(fx,self.fx),lxor(fy,self.fy))
end
function sprite:show(v)
	self.draw=v and self._draw or nil
end
function sprite:render(x,y,fx,fy)
	if (self.draw) self:draw(x,y,fx,fy)
	for i=1,#self.children do
		self.children[i]:render(x+self.x,y+self.y,lxor(fx,self.fx),lxor(fy,self.fy))
	end
end
function sprite:emit_update()
	self:emit("update")
	for i=1,#self.children do
		local child=self.children[i]
		if child then child:emit_update() end
	end
end



-- common functions ------------------------------------------------
function rou(n) return flr(n+.5) end -- math.round
function swap(v) if v==0 then return 1 else return 0 end end -- 1 0 swap
function clamp(a,min_v,max_v) return min(max(a,min_v),max_v) end



-- data encoder/decoder ------------------------------------------------
-- <0,1ミくう マふてム░ねミ…う ミ♪ぬムえひメ⬇️█ミしも ムˇˇムへˇメˇ▤マねぬミ🐱▤ メˇひムきう>
-- ムえまムや⬆️ミ⬆️た: ミ♪ぬムえひメ⬇️█ミしも 7ムお…ミすてム⬆️た ミ▒⌂ム∧ひム░う "0010100" -> 20ムうもミくう ミは█メ▥▤ メい░, encode_strムえ▤ 4ミの☉ ミてまムお…ミくう ムき█ムおし
-- ミ⬆️⬆️ムや⬆️ミ⬆️た: ミてまムお…ム❎ひムえ░ メˇ▤ミ🐱▤ム⬆️た ミはひマはき ムう░ムみ▤ミしも ミや➡️ミ⌂⬆️ミ♪ぬ, 20ミの☉ムせま ミてまムお…ミえもミたひ ムえひ 20ムえ░ ミ⬅️さム⬅️う "0010100"ムうもミくう ミは█メ▥▤
--encode_str="abcdefghijklmnopqrstuvwxyz)!@#$%^&*(abcdefghijklmnopqrstuvwxyzあいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんっゃゅょアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンッャュョ"
encode_str="abcdefghijklmnopqrstuvwxyz)!@#$%^&*(あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんっゃゅょアイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンッャュョ"
function data_encode(data,is_v2)
	local r=""
	for i=1,ceil(#data/7) do
		local n=(i-1)*7+1
		local num=bit2num(sub(data,n,n+7))+1 -- 7マま█ムお…ム⬆️た ムお▤ミえもム░う ム☉つムお…ミくう ミは█メ▥▤
		local str=encode_str[num] -- マほま ム☉つムお…ム❎… メˇひミ⬅️みメˇ▤ミ⌂⬆️ ミてまムお… ムぬゆマまぬ
		r=r..str
	end
	return r
end
function data_decode(data)
	local r=""
	for i=1,#data do
		local t=split(encode_str,data[i]) -- マぬ▒ ミてまムお…マぬ█ ムˇˇムへˇミてまムお…ム❎ひムえ▤ ミち♥ ミの☉ムせまムえまムせ█ ムぬゆマまぬ
		r=r..num2bit(#t[1]) -- ムぬゆムえ█ ム☉つムお…ミしも ミみ░メ⌂ま ミてまムお…ム❎ひミくう ミぬ⬆️マよ⬆️ム░う メˇたムみそ
	end
	return r
end
function bit2num(s)
	if #s<7 then
		for i=#s+1,7 do s=s.."0" end
	end
	local result=0
	for i=7,1,-1 do
		result+=s[i]*2^(7-i)
	end
	return result
end
function num2bit(num)
	s=""
	while num>0 do
		s=(num%2)..s
		num=num\2
	end
	if #s<7 then
		for i=#s+1,7 do s="0"..s end
	end
	return s
end



-- puzzle ------------------------------------------------
puzzle=class(sprite)
function puzzle:init(idx,v)
	local _s=self
	_s.is_visible=0
	_s:set_puzzle(idx)

	_s.cursor=cursor.new(v)
	_s:add_child(_s.cursor)

	_s:on("update",_s.on_update)
	if(v) _s:set_visible(v)
end

function puzzle:set_visible(v)
	self:show(v==1)
	self.cursor:show(v==1)
	self.is_visible=v
	if v==1 then
		music(13,2000,2)
		set_menu(1,1,1,1,2)
	end
end

function puzzle:set_puzzle(idx)
	local _s=self
	_s.play_mode=0 -- 0:play, 1:make
	
	-- メ♪もムす… ム⌂さメ⌂まミせ▒ムえ░ ミぬぬム❎ひミくう ミは█メ▥▤
	-- > todo: マふはムえひ ミぬぬム❎ひミくう ミせ😐ミ⧗さ メˇ░ムあ⬆️マみ😐ムせ█ミ⌂⬆️ ム❎●ミ⌂⬆️ミ♪ぬ
	-- > ムひ☉マまぬ マふてメ▤░ムえひ ミぬぬム❎ひ ミぬたム⬅️えムえひミえも マねぬマまぬ ミせおムへぬム░う ムおてマふてム░ねメˇ▤ミ⌂⬆️ ムさ➡️
	local pz_w,pz_h=pz[idx][1],pz[idx][2]
	local pz_str=pz_decoded[idx]
	if not pz_str then
		pz_str=data_decode(pz[idx][3])
		pz_decoded[idx]=pz_str
	end

	local pz_t={}
	for i=1,pz_h do
		pz_t[i]={}
		for j=1,pz_w do
			local n=(i-1)*pz_w+j
			pz_t[i][j]=tonum(pz_str[n])
		end
	end
	_s.puzzle_data=pz_t
	_s.map_tile_w=pz_w -- ミせふ マぬ█ミくう ムみま ム☉▤
	_s.map_tile_h=pz_h -- ミせふ ム░まミくう ムみま ム☉▤
	_s.map_data={} -- メ⬆️😐ミき☉ムえひ ムさ➡️ムえま ミせふムえ▤ ミちそミ⧗き ムみま ムきˇミはひ(0 ミみ☉ムみま, 1 ムみき, 2 ミせ☉メ🐱み)
	_s.map_data_uncleared=nil -- ムˇ☉ メ★█ミすてミ⌂⬆️ メ♪もムす… マぬ█ムえひミ⧗うムあた ミ♪ぬムえひメ⬇️█(1 メ⬅️█ミすぬ ムみま)
	_s.is_clear=0
	_s.is_forced_clear=0
	
	-- マぬ█ミくうム░まミくう ミせふ メ▒てマまぬ px
	_s.width=_s.map_tile_w*tile_size
	_s.height=_s.map_tile_h*tile_size

	-- ミせふムえ░ ムぬ♪ムえ░ ムけ😐ム⬇️▒ミ⬅️そ マまぬムさ█ ムけ😐メ➡️う ム░さムきˇ
	-- 15x15 ミせふムえ█ 1,1ム❎… メ➡️うム⬅️う, ムお➡️ムえ░ム☉▤ミくえ メ▥⬆️ミたひ マぬ█ムあひミ♪ぬ メ➡️うム⬅️う
	-- _s:set_xy(
	-- 	1+(15-_s.map_tile_w)/2*tile_size,
	-- 	1+(15-_s.map_tile_h)/2*tile_size
	-- )
	-- ムあぬメˇ▤ミ⬅️そ マまぬムさ█ ムきˇミきて
	_s:set_xy(
		1+(15-_s.map_tile_w)*tile_size,
		1+(15-_s.map_tile_h)*tile_size
	)

	-- ミせふムえ░ メ▥⬆️ミたひ ムきˇムさ➡️ムˇ▥ム❎… メ➡️うム⬅️うメˇき ムけ😐ム⬇️▒ミ⬅️そ ムけ😐メ➡️う ミにまミすて マは░ム🐱ぬ(メ▒ひミすてム∧ひメˇ▤ミたひ ム▤なマのそ マぬ…)
	_s.center_x=(128-_s.map_tile_w*tile_size)/2
	_s.center_y=(128-_s.map_tile_h*tile_size)/2-8
	
	-- マぬ█ミくうム░まミくう ムさ░ムえ▤ メ♪もムす… ム☉つムお…ミ⧗さ
	-- + ム☉つムお…ミ⧗さムえひ マほま ムさ░ム❎… メ▥ˇムきˇムき▒ムえま マぬ★ムえまムせ█ミしも マまぬミくえ(ム☉つムお…ミしも ミ⬅️さミしま ム⬇️웃ムうもミくう メ➡️うム⬅️う)
	_s.numbers_h={}
	_s.numbers_v={}
	_s.numbers_h_is_definite={}
	_s.numbers_v_is_definite={}

	-- ミせさムみ▤ミ♪ぬムえひメ⬇️█(マぬ▒ ムさ░ム❎… ムみきメˇう メ▤ˇメ⬇️うマぬ█ ム☉つムお…ム▥█ マの웃ミはひマまぬム❎… マぬ▥ムえ█ムせ█?)
	_s.matchdata_h={}
	_s.matchdata_v={}

	_s:reset(true,idx)
end

function puzzle:_draw()
	self:draw_map()
	if(self.is_clear==1) return

	if self.play_mode==1 then self:draw_preview(96,96)
	else
		--self:draw_qr(96,96)
		local x,y=self.x+self.width+2,self.y+self.height+2
		--rectfill(x,y,x+34,y+10+24,5)
		rectfill(x,y,x+27,y+27,5)
		-- local s,h="\^w\^t"..self.map_tile_w.."\n",self.map_tile_h
		-- s=s..(h<10 and " " or "").."\x13"..h
		-- print(s,x+3,y+3,0)
		print("\^w\^t"..self.map_tile_w.."\n\x13"..self.map_tile_h,x+3,y+3,0)
	end

	if self.play_mode==1 then
		?"\f8🐱\f6puzzle create mode",2,121
	end
end

playing_map_data={}
function puzzle:load_playing_map(idx)
	if playing_map_data[idx]!=nil then
		for i=1,self.map_tile_h do
			self.map_data[i]={}
			for j=1,self.map_tile_w do
				self.map_data[i][j]=playing_map_data[idx][i][j]
			end
		end
	end
end
function puzzle:save_playing_map(idx)
	playing_map_data[idx]={}
	for i=1,self.map_tile_h do
		playing_map_data[idx][i]={}
		for j=1,self.map_tile_w do
			playing_map_data[idx][i][j]=self.map_data[i][j]
		end
	end
end

function puzzle:force_clear()
	for i=1,self.map_tile_h do
		for j=1,self.map_tile_w do
			local d=self.puzzle_data[i][j]
			self.map_data[i][j]=d
		end
	end
	self.is_forced_clear=1
end

function puzzle:reset(is_init,idx)
	self:clear_map(0)

	-- initムえも ミˇ😐ミ⌂⬆️ メ♪もムす… ミ♪ぬムえひメ⬇️█ミしも ミはひマはき メ➡️うム⬅️うメˇき ム☉つムお…ミ⧗さムえ░ マは░ム🐱ぬ+マまぬミくえメˇひ ミ➡️⬆️ミ⬅️さ
	-- + ムき█ムおしミ…う メ⬆️😐ミき☉ムえひ ミ♪ぬムえひメ⬇️█マぬ█ ムお☉ムうもミたひ ミへ☉ミかてム▤そミ⬅️さ
	if is_init then
		self:update_puzzle_numbers()
		self:load_playing_map(idx)
	end

	-- ミせさムみ▤ミ♪ぬムえひメ⬇️█ ムひ☉マまぬメ▥⬆️ + ミせさムみと マの█ム🐱て 1メあ😐 ミ◆😐ミきさム░う マまぬミくえ
	for i=1,self.map_tile_w do self:update_matchdata(i,1) end
	for i=1,self.map_tile_h do self:update_matchdata(1,i) end

	if self.cursor then
		self.cursor:move(20,20)
		self.cursor.color=11
	end

	-- todo: ムえひマねま ムえひ ミˇ😐 ミへ▥ムえひミ⌂⬆️ マの😐 ミせおミ🐱▤? メ❎ほマぬ☉ミすも...
	self:on("update",self.on_update)
end

function puzzle:change_playmode(to)
	self.play_mode=to or swap(self.play_mode)
	if self.play_mode==0 then
		self.cursor.color=11
		set_menu(1,1,1,1,2)
	else
		self.cursor.color=6
		set_menu(0,1,2,1,1) -- メ♪もムす… ム❎…ミ⬆️⬆️メ░ぬ
	end
end

-- メ♪もムす… ムみま ム☉つムお… マは░ム🐱ぬ
function puzzle:update_puzzle_numbers()
    local _s=self
	local function is_definite(arr,num)
		local n=#arr-1
		for i=1,#arr do n+=arr[i] end
		return (num==n) and 1 or 0
	end

	local h,w=_s.map_tile_h,_s.map_tile_w
	local data=_s.puzzle_data
	for i=1,h do
		local nums=data_to_nums(data[i])
		_s.numbers_h[i]=nums
		_s.numbers_h_is_definite[i]=is_definite(nums,w)
	end
	for i=1,w do
		local t={}
		for j=1,_s.map_tile_h do t[j]=data[j][i] end
		local nums=data_to_nums(t)
		_s.numbers_v[i]=nums
		_s.numbers_v_is_definite[i]=is_definite(nums,h)
	end
end

function puzzle:draw_map()
	local _s=self
	local mx,my=_s.x,_s.y
	local th,tw,ts=_s.map_tile_h,_s.map_tile_w,tile_size

	-- メ▒ひミすてム∧ひメ∧☉ムうもミたひ ムき░メ▥⬆️ミたひ メ😐そメ░ひ
	if _s.is_clear==1 then
		fillp(cover_pattern[2])
		rectfill(0,0,127,127,5)
		
		local x,y=rou(mx+_s.width/2),rou(my+_s.height/2)
		local function c() return flr(1+rnd(5)) end
		fillp(cover_pattern[3])
		circ(x,y,20+f*1.2%100,c())
		circ(x,y,20+(f*1.2+50)%100,c())
		
		fillp()
		--rectfill(mx,my,mx+tw*tile_size,my+th*tile_size,0)
	else
		-- ム❎てミぬね ミせさマゆまマまぬ
		local function c() return flr(1+rnd(4)) end
		fillp(cover_pattern[3])
		--puzzle circles
		--circ(63,63,10+f*0.4%180,c())
		--circ(63,63,10+(f*0.4+60)%180,c())
		--circ(63,63,10+(f*0.4+120)%180,c())
		fillp()

		for i=1,15 do
			for j=1,15 do
				spr(12,1+j*ts-ts,1+i*ts-ts)
			end
		end
		rectfill(mx,my,15*ts+2,15*ts+2,0)
	end
	
	for i=1,th do
		for j=1,tw do
			local s=_s.map_data[i][j]
			local sxx=_s.map_data_uncleared and _s.map_data_uncleared[i][j] or 0
			local dx,dy=0,0
			if s==1 then
				if (sxx==1) s=9
				if flr(i*.7+j*1.5)==f\4%300 then
					s=sxx==1 and 10 or 4
				end
			elseif _s.play_mode==1 then
				if s==0 then s=5 elseif s==2 then s=6 end
			elseif s==0 or s==2 then
				if flr(i*.7+j*1.5)==(f+5)\4%300 then
					s=s==0 and 3 or 11
				end
			end
			-- メ▒ひミすてム∧ひメ∧☉ムうもミたひ ミみ☉ ムみま ムˇ☉ マほまミすも
			if not (s!=1 and s!=4 and _s.is_clear==1) then
			 --draw grid
				spr(s,mx+j*ts-ts,my+i*ts-ts)
				--spr(s,mx+j*ts-ts,my+i*ts-ts)
			end
		end
	end
	
	if(_s.is_clear==1) return -- メ▒ひミすてム∧ひメ∧☉ムうもミたひ ム❎てマまぬマみ😐ムせ█ミせ😐

	-- 5ムみまミせ☉ミ⬅️さ ムき… ムぬ♪マまぬ(ムめさム░う マほもムの▤ミえもミたひ ムˇ☉ ムぬ♪ムえ😐) + ム░き マま⬅️マまぬ
	for i=1,1+th\5 do
		local y=my+(i-1)*ts*5-1
		for j=1,1+tw\5 do
			local x=mx+(j-1)*ts*5-1
			-- if(i==1 and j>1) line(x+1,y+2,x+1,y+th*ts,2)
			-- if(i>1 and j==1) line(x+2,y+1,x+tw*ts,y+1,2)
			if abs(_s.cursor.x-x+3)>6 or abs(_s.cursor.y-y+3)>6 then
				rect(x,y,x+2,y+2,0)
				rect(x+1,y+1,x+1,y+1,4)
			end
		end
	end

	-- ム☉つムお… メ✽😐ムえひミま⬆️ 1マぬう ミぬいムˇ░ ムぬ♪マまぬ
	-- todo: custom font
	local function draw_numbers(t,x,y,c,is_side,on_cursor)
		if #t==0 then t={0} end
		if on_cursor then
			c=(c==5) and 11 or (c==2) and 14 or c
		end
		if is_side then
			for i=1,#t do
				local n=t[i]
				if n>9 then
					?"|",x-1,y,c
					if n%10==1 then ?"|",x+1,y,c
					else
						?n%10,x+2,y,c
						x+=2
					end
				else
					if n==1 then
						?"|",x-1,y,c
						x-=2
					else
						?n,x,y,c
					end
				end
				x+=6
			end
		else
			for i=1,#t do
				local n=t[i]
				if n==11 then
					?"|",x-1,y,c
					?"|",x+1,y,c
				elseif n>9 then
					?"|",x-2,y,c
					?n%10,x+1,y,c
				elseif n==1 then
					?"|",x,y,c
				else
					?t[i],x,y,c
				end
				y+=6
			end
		end
	end

	-- ム☉つムお…ミ⧗さ マほまミすてマまぬ
	-- > メ♪もムす… メ✽😐ムえひミま⬆️ム❎… マまぬミくえミ…う マぬ★ == ミせさムみ▤ミ♪ぬムえひメ⬇️█: ム⬇️웃 9
	-- > numbers_h_is_definite メ✽😐ムえひミま⬆️ムえ▤ マぬ★ムえひ 1: ム⬇️웃 2
	local ts=tile_size
	if _s.play_mode==0 then
		for i=1,th do -- ム▤さミしまムちや
			local c=(_s.matchdata_h[i]==1) and 9 or
				(_s.numbers_h_is_definite[i]==1) and 2 or 5
			draw_numbers(_s.numbers_h[i],mx+tw*ts+3,my+i*ts-5,c,1,i==_s.cursor.tile_y)
		end
		for i=1,tw do -- ムˇ░ミお▤
			local c=(_s.matchdata_v[i]==1) and 9 or
				(_s.numbers_v_is_definite[i]==1) and 2 or 5
			draw_numbers(_s.numbers_v[i],mx+i*ts-4,my+th*ts+3,c,nil,i==_s.cursor.tile_x)
		end
	else
		-- ミせ😐ミ⧗さマまぬ ミちそミ⧗うム❎…ム░うミ⌂⬆️ ミせさメ⬆️░ミき☉ムお░ ミ✽まミお█ムみま ムぬ♪メお😐 ミちそム∧➡️ムえ░ ム☉つムお…ミくう メ➡️うム⬅️う
		-- todo: ムえひマねま ミせさ メ⬆️░ミき☉ムお░ ムき░ミへ█ マは░ム🐱ぬ ムさ➡️
		for i=1,th do
			draw_numbers(data_to_nums(_s.map_data[i]),mx+tw*ts+3,my+i*ts-5,2,1)
		end
		for i=1,tw do
			local t={}
			for j=1,th do t[j]=_s.map_data[j][i] end
			draw_numbers(data_to_nums(t),mx+i*ts-4,my+th*ts+2,2)
		end
	end
end

function puzzle:draw_preview(x,y)
	local w=puzzle_line_max*2
	fillp(0b0101101001011010.1)
	rectfill(x,y,x+w-1,y+w-1,2)
	fillp()
	for i=1,self.map_tile_h do
		for j=1,self.map_tile_w do
			local c=2
			if(self.map_data[i][j]==1) c=9
			rect(x+j*2-2,y+i*2-2,x+j*2-1,y+i*2-1,c)
		end
	end
end

function puzzle:draw_qr(x,y,dot_size,hide_bg)
	if(not hide_bg) rectfill(x,y,x+qr_size+4,y+qr_size+4,6)
	draw_preview(x+2,y+2,qr_size,qr_size,qr_data,dot_size,0)
end

function puzzle:set_tile(x,y,v)
	self.map_data[y][x]=v
	self.cursor.last_fill=v
	self.cursor.moved=0
 end
function puzzle:get_tile(x,y) return self.map_data[y][x] end

function puzzle:clear_map(v)
	for i=1,self.map_tile_h do
		self.map_data[i]={}
		for j=1,self.map_tile_w do
			self.map_data[i][j]=v or 0
		end
	end
end

function puzzle:export()
	local w,h,md=self.map_tile_w,self.map_tile_h,self.map_data
	-- crop(include x check)
	local arr_v,arr_h={},{}
	for i=1,h do
		local j=1
		while j<=w do
			if md[i][j]!=0 then
				arr_v[i]=0
				j=w+1
			end
			j+=1
		end
		if(arr_v[i]==nil) arr_v[i]=1
	end
	for i=1,w do
		local j=1
		while j<=h do
			if md[j][i]!=0 then
				arr_h[i]=0
				j=h+1
			end
			j+=1
		end
		if(arr_h[i]==nil) arr_h[i]=1
	end
	local cut_t,cut_b,cut_l,cut_r=0,0,0,0
	local arr_h2=data_to_nums(arr_h)
	local arr_v2=data_to_nums(arr_v)
	if #arr_v2>0 then
		if(arr_v[1]==1) cut_t=arr_v2[1]
		if(arr_v[#arr_v]==1) cut_b=arr_v2[#arr_v2]
	end
	if #arr_h2>0 then
		if(arr_h[1]==1) cut_l=arr_h2[1]
		if(arr_h[#arr_h]==1) cut_r=arr_h2[#arr_h2]
	end

	local s=""
	for i=1+cut_t,h-cut_b do
		for j=1+cut_l,w-cut_r do
			s=s..(md[i][j]==1 and "1" or "0")
		end
	end
	s=data_encode(s,true)

	local w=self.map_tile_w-cut_l-cut_r
	local h=self.map_tile_h-cut_t-cut_b
	s=w..","..h..","..s.."/"
	printh(s,"@clip")
	_popup:open("exported")
end

-- ムせ█ムきˇメˇう メ⬇️█ムえも ムけ😐メ➡️う メ∧웃/ム❎ひムえ▤ ミせさムみ▤ミ♪ぬムえひメ⬇️█ ム❎✽ミ♪ぬムえひメ⌂ま(マの웃ミはひマまぬム❎… ミせおミ⌂⬆️ムせ█ミせ😐 メ😐…ミ⬅️そ)
function puzzle:update_matchdata(tile_x,tile_y)
	-- メ∧웃
	local t1=data_to_nums(self.map_data[tile_y])
	local t2=self.numbers_h[tile_y]
	local m,c=0,0
	if #t1==#t2 then
		for i=1,#t1 do
			if(t1[i]==t2[i]) c+=1
		end
		if(c==#t1) m=1
	end
	self.matchdata_h[tile_y]=m
	-- ム❎ひ
	local tt={}
	for i=1,self.map_tile_h do
		tt[i]=self.map_data[i][tile_x]
	end
	local t1=data_to_nums(tt)
	local t2=self.numbers_v[tile_x]
	local m,c=0,0
	if #t1==#t2 then
		for i=1,#t1 do
			if(t1[i]==t2[i]) c+=1
		end
		if(c==#t1) m=1
	end
	self.matchdata_v[tile_x]=m
end

-- メ▒ひミすてム∧ひ ム❎てミへ█ メ😐…ミは░
-- 1ムぬそ: マぬ█ミくう/ム░まミくうムさ░ ム☉つムお… ミちそミ➡️… ミ✽みム⬇️웃ムえまムせ█?
-- 2ムぬそ: ミちそミ➡️… ミ✽みム⬇️웃ムえひミえもミたひ ミ♪ぬムえひメ░ぬミ◆░ ミみ░マふ…
function puzzle:check_is_clear()
	local _s,c=self,0
	for i=1,#_s.matchdata_h do c+=_s.matchdata_h[i] end
	for i=1,#_s.matchdata_v do c+=_s.matchdata_v[i] end
	if #_s.matchdata_h+#_s.matchdata_v==c then
		local d1,d2=_s.puzzle_data,_s.map_data
		for i=1,#d1 do
			for j=1,#d1[i] do
				if not((d1[i][j]==1 and d2[i][j]==1) or (d1[i][j]!=1 and d2[i][j]!=1)) then
					self:update_uncleared_data()
					return false
				end
			end
		end
		return true
	else return false end
end

-- メ♪もムす…ムえひ ムˇ☉ メ★█ミすてミ⌂⬆️ ム⬇️▒メ▥たム❎…ム░う マぬ█ムえひミ⧗うムあた ミ♪ぬムえひメ⬇️█ マぬねム⬅️き(ミみそマぬ░ ムみまムうもミくう メ➡️うム⬅️う)
function puzzle:update_uncleared_data()
	local is_new=not self.map_data_uncleared
	if(is_new) self.map_data_uncleared={}
	local d1,d2=self.puzzle_data,self.map_data
	for i=1,#d1 do
		if(is_new) self.map_data_uncleared[i]={}
		for j=1,#d1[i] do
			local v1,v2,v3=d1[i][j],d2[i][j],self.map_data_uncleared[i][j]
			if v3 and v3==1 then
				-- (1ムえま ムね░ミくう ミ➡️⬆️ミ⬅️さ. ミぬ▤ミはふメˇひム░う ム⬅️さメ😐そメˇ▤ミたひ ミみそマぬ░ ムみまムえひ ミ⌂▤ム∧ひミ🐱▤ミ⬅️さ マのぬマふと メ★█マの😐ミ▒⬆️ ムうきミ◆░)
			elseif not((v1==1 and v2==1) or (v1!=1 and v2!=1)) then
				self.map_data_uncleared[i][j]=(v2==1) and 1 or 0
			else
				self.map_data_uncleared[i][j]=0
			end
		end
	end
end

function puzzle:on_clear()
	local _s=self
	if _s.clear_count>0 then
		-- todo:ムけ█ ムきˇミすてメˇき ム☉▤ ムお☉ムせ█ ム⬅️へムえ█ミ♪ぬ... ミ░☉ミてひ ミせ웃 ム♪そミ●そムえ😐
		_s.spd_x=(_s.center_x-(_s.to_x or _s.x))*.05+(_s.spd_x or 0)*.18
		_s.spd_y=(_s.center_y-(_s.to_y or _s.y))*.05+(_s.spd_y or 0)*.18
		_s.to_x=(_s.to_x or _s.x)+_s.spd_x
		_s.to_y=(_s.to_y or _s.y)+_s.spd_y
		_s:set_xy(rou(_s.to_x),rou(_s.to_y))
		_s.clear_count-=1
	else
		_s:set_xy(_s.center_x,_s.center_y)
		_popup:open("clear")
		_s:remove_handler("update",_s.on_clear)
	end
end

function puzzle:on_update()
	if(_popup.is_visible==1) return
	if(self.is_visible!=1) return

	local _s=self
	local _c=_s.cursor
	local dx,dy=0,0
	if(btnp(0)) dx-=1
	if(btnp(1)) dx+=1
	if(btnp(2)) dy-=1
	if(btnp(3)) dy+=1
	if(dx!=0 or dy!=0) _c:move(dx,dy)

	local cx,cy=_c.tile_x,_c.tile_y
	local cm,cf,v=_c.moved,_c.last_fill,_s:get_tile(cx,cy)
	if btn(4) then -- z:fill
		if cm==1 and (cf==0 or cf==1) then
			if cf==1 then _c:show_eff_fill() else _c:show_eff_clear() end
			_s:set_tile(cx,cy,cf)
			_s:update_matchdata(cx,cy)
		elseif cf==-1 or cf==2 then
			if v==1 then
				_s:set_tile(cx,cy,0)
				_c:show_eff_clear()
			else
				_s:set_tile(cx,cy,1)
				_c:show_eff_fill()
			end
			_s:update_matchdata(cx,cy)
		end
	elseif btn(5) then -- x:marking
		if cm==1 and (cf==0 or cf==2) then
			_s:set_tile(cx,cy,cf)
			_s:update_matchdata(cx,cy)
			sfx(2,-1)
		elseif cf==-1 or cf==1 then
			if v==0 or v==1 then
				_s:set_tile(cx,cy,2)
				_s:update_matchdata(cx,cy)
				sfx(2,-1)
				if(v==1) _c:show_eff_clear()
			else _s:set_tile(cx,cy,0) end
		end
	elseif cm==0 and cf!=-1 then
		_s.cursor.last_fill=-1 -- ミた☉ムへ▤ ムね░ミくう zxメ🐱さ ミちそミ➡️… upミ…▤ミたひ ミせ웃ムみきマぬ★ ムせ█ムい█
	end

	-- メ⬆️😐ミき☉ムえひ ムさ➡️ムえも ミˇ😐, ムめさム░う ムみまムえ▤ ム⬇️웃ムえひ ミぬ⬆️ミ█😐ム❎☉ムうもミたひ メ▒ひミすてム∧ひ ム❎てミへ█ ムのひメ▒て
	if (v!=_s:get_tile(cx,cy) and _s.play_mode==0) or _s.is_forced_clear==1 then
		-- メ▒ひミすてム∧ひ!
		if _s.is_forced_clear==1 or _s:check_is_clear() then
			set_menu(0,0,0,0,0)
			_s.is_clear=1
			_s.clear_count=150
			_s.to_x,_s.to_y=_s.x,_s.y
			_s:on("update",_s.on_clear)
			_s:remove_handler("update",_s.on_update)
			_s.cursor:show(false)
			music(6,1000,2)

			-- メ▒ひミすてム∧ひ マまぬミくえ, ムき█ムおし
			pz_cleared[_selector.selected]=1
			cartdata_save()
		end
	end

	-- メ⬆️😐ミき☉ムえひ ムさ➡️ムえも ミˇ😐, qr メ░ぬムみ▤メˇ▤ミたひ メ▒てマの😐
	--[[ 
	if _s.play_mode==0 then
		if stat(34)==1 and stat(32)>90 and stat(33)>90 then
			_popup:open("qr")
		end
	end
 	]]
end



--- cursor -----------------------------------------------
cursor=class(sprite)
function cursor:init(v)
	local _s=self
	_s.x=0
	_s.y=0
	_s.tile_x=1
	_s.tile_y=1
	_s.to_x=0
	_s.to_y=0
	_s.spd_x=0
	_s.spd_y=0
	_s.color=11
	_s.moved=1 -- ムえひミ◆▥ ムせ█ム⬅️う メい░(ミ▤…ミ⌂⬆️ ム⬇️웃ムみき メい░)ム❎… ム⬅️さムきうミくう ムえひミ◆▥ムえ░ メ∧☉ミ⌂⬆️ムせ█?
	_s.last_fill=-1 -- ミせ☉ムせ█ミせ웃ム❎… ムめさム░うマぬ█ ムみきメˇう ム⬇️웃
	_s.eff_list={} -- メ➡️うム⬅️うメˇき ムえひメ🅾️▥メ⌂まミ⧗さ {effect type,timer}
	if(v) _s:show(v)
end

function cursor:_draw()
	local _s=self
	local _p=_s.parent
	local mx,my=_p.x,_p.y
	local ts,cs,css=tile_size,cursor_size,cursor_size/2
	local c=_s.color
	
	_s.to_x=mx+_s.tile_x*ts-css-3
	_s.to_y=my+_s.tile_y*ts-css-3
	_s.spd_x=(_s.to_x-_s.x)*.4
	_s.spd_y=(_s.to_y-_s.y)*.4
	_s.x+=_s.spd_x
	_s.y+=_s.spd_y

	local x0,y0=rou(_s.x),rou(_s.y)
	local x1,y1=rou(_s.to_x),rou(_s.to_y)
	local x2,y2=min(x0,x1),min(y0,y1)
	local x3,y3=max(x0+cs,x1+cs),max(y0+cs,y1+cs)

	-- ムき…ム░き(ムけ😐ム⬇️▒)
	draw_dotline_h(mx-3,y0+css,x2-1,c,1)
	draw_dotline_v(x0+css,my-3,y2-1,c,1)

	-- ムめさム░う:ムのうムのうメお☉ ミ⬆️ぬミえもマぬ█ミ⌂⬆️ ムお⬆️ム⬇️▒(ミ⬆️⬆️ミの░マほまムあた)
	--rect_shadowed(x0,y0,x0+cs,y0+cs,12)

	-- ムめさム░う:ミちそム✽▤ ム❎●ムえひ ミちたメ➡️う ムけ😐メ➡️うミくう ムす웃ム⬅️う ムえひミ◆▥(ミ⬆️⬆️ミの░マほまムあた)
	--rect_shadowed(x1,y1,x1+cs,y1+cs,14)

	-- ムめさム░う+ムお⬆️ム⬇️▒ メ▒てマまぬムえ▤ ムめさム░う(ム●♪ミ◆░マぬ█ ミみきミしも ム☉▤ミくえ ムめさムせ…)
	rect_shadowed(x2,y2,x3,y3,c)

	--ムき…ム░き(ムあぬメˇ▤)
	draw_dotline_h(x3+1,y0+css,mx+_p.map_tile_w*ts+2,c,-1)
	draw_dotline_v(x0+css,y3+1,my+_p.map_tile_h*ts+3,c,-1)

	_s:draw_eff()
end

function cursor:move(dx,dy)
	local _s=self
	local _p=_s.parent
	local ox,oy=_s.tile_x,_s.tile_y
	-- local tx=clamp(_s.tile_x+dx,1,_p.map_tile_w)
	-- local ty=clamp(_s.tile_y+dy,1,_p.map_tile_h)	
	local tx=_s.tile_x+dx
	local ty=_s.tile_y+dy
	if tx<1 then tx=_p.map_tile_w
	elseif tx>_p.map_tile_w then tx=1 end
	if ty<1 then ty=_p.map_tile_h
	elseif ty>_p.map_tile_h then ty=1 end
	_s.tile_x=tx
	_s.tile_y=ty

	if ox!=tx or oy!=ty then
		_s.moved=1
		sfx(3,-1)
	else
		_s.moved=0
		_s.x+=dx*2
		_s.y+=dy*2
		_s:show_eff_cant_move()
		sfx(4,-1)
	end
end

function cursor:draw_eff()
	if(#self.eff_list<1) return
	for i in all(self.eff_list) do
		if i[1]==1 then -- ミちめムい█ムせ▒ム❎て ムえひメ🅾️▥メ⌂ま
			local c=flr(rnd(15))
			local x1,y1=rou(self.x),rou(self.y)
			local x2,y2=x1+cursor_size,y1+cursor_size
			rect(x1,y1,x2,y2,c)
		elseif i[1]==2 or i[1]==3 then -- 2:マま☉ムみき, 3:マま☉ムみき ムせ█ムい█
			local css=cursor_size/2
			local x1,y1=rou(i[3][1]+css),rou(i[3][2]+css)
			local t=(20-i[2])*3
			if(i[1]==3) t=(20-i[2])*3
			for k=1,#p_data do
				local d=p_data[k]
				if t<#d then
					local dx,dy=d[t+1]+k%3-1,d[t+2]+k%3-2
					if(i[1]==3) dx,dy=dx*.7,dy*.7 -- ムせ█ムあま ミˇ😐ミ⌂⬆️ ムˇやメˇ▤マの😐
					do -- 1ムみまミせ☉ミ⬅️さ ムえひメ🅾️▥メ⌂まミしも 90ミ◆░ム⬆️た メあ😐ムき░
						local xy=i[3][3]+i[3][4]
						if(xy%2==1) dx*=-1.5
						if(xy%4<2) dy*=-1.5
					end
					local x,y,c=x1+dx,y1+dy,d[t+3]
					pset(x,y,c)
					if c==7 or c==7 then -- マぬ⧗ ミ🐱▤ム▤そ ムえひメ🅾️▥メ⌂まミ⌂⬆️ メ▒てマの😐
						pset(x+1,y,c)
						pset(x+1,y+1,c)
						pset(x,y+1,c)
					end
				end
			end
		end
		i[2]-=1
	end
	for i in all(self.eff_list) do
		if i[2]<=0 then del(self.eff_list,i) end
	end
end

function cursor:show_eff_cant_move() add(self.eff_list,{1,8}) end
function cursor:show_eff_fill()
	add(self.eff_list,{2,20,{self.to_x,self.to_y,self.tile_x,self.tile_y}})
	sfx(0,-1)
end
function cursor:show_eff_clear()
	add(self.eff_list,{3,16,{self.to_x,self.to_y,self.tile_x,self.tile_y}})
	sfx(1,-1)
end



-- popup ------------------------------------------------
popup=class(sprite)
function popup:init()
    local _s=self
	_s.x,_s.y,_s.y_def=64,58,58
	_s.w,_s.h=0,0
	_s.to_w,_s.to_h=0,0
	_s.tw_counter=0
	_s.content_type=nil
	_s.show_content=0	
	_s.content_cover_counter=0
	_s.color=9
	_s.is_visible=0
	_s.use_dim=0
	_s.dim_counter=0
	_s.dim_pal="1212114522311110"
end
function popup:set_visible(v)
	self:show(v==1)
	self.is_visible=v
end
function popup:set_size(w,h)
	self.to_w,self.to_h=w,h
	self.tw_counter=20
	self.show_content=0
	self:on("update",self.on_resize)
end
function popup:open(content_type)
	local _s=self
	if content_type=="clear" then
		_s.to_w,_s.to_h,_s.y_def=110,34,92
		_s.color=9
	elseif content_type=="qr" then
		_s.to_w,_s.to_h,_s.y_def=76,88,58
		_s.color=6
	elseif content_type=="reset" then
		_s.to_w,_s.to_h,_s.y_def=90,38,58
		_s.color=8
	elseif content_type=="exported" then
		_s.to_w,_s.to_h,_s.y_def=60,44,58
		_s.color=9
	end
	_s.w,_s.h=50,30
	_s.spd_w,_s.spd_h=0,0
	_s.tw_counter=20
	_s.show_content=0
	_s.visible=1
	_s.content_type=content_type
	_s.use_dim=1
	_s.dim_counter=16
	_s:set_visible(1)
	_s:on("update",_s.on_resize)
	_s:on("update",_s.on_dim_change)
	sfx(5,-1)
end

function popup:close()
	self.to_w,self.to_h=24,22
	self.spd_w,self.spd_h=8,8
	self.tw_counter=20
	self.content_type=nil
	self.show_content=0
	self.use_dim=0
	self.dim_counter=16
	self:on("update",self.on_resize)
	self:on("update",self.on_dim_change)
	sfx(6,-1)
end

function popup:on_dim_change()
	if self.dim_counter>0 then
		for i=1,16-self.dim_counter do
			if self.use_dim==1 then
				dim_pal[i]=self.dim_pal[i]
			else dim_pal[i]=i end
		end
		self.dim_counter-=0.8
	else
		if(self.use_dim==0) dim_pal={}
		self:remove_handler("update",self.on_dim_change)
	end
end

function popup:on_resize()
    local _s=self
	_s.spd_w=(_s.to_w-_s.w)*.2+_s.spd_w*.65
	_s.spd_h=(_s.to_h-_s.h)*.2+_s.spd_h*.65
	_s.w+=_s.spd_w
	_s.h+=_s.spd_h
	_s.tw_counter-=1
	-- open/close ミ◆▥ムお➡️ムえひ ミ▒えミ🐱▤ミたひ?
	if _s.tw_counter<=0 then
		_s.w,_s.h=_s.to_w,_s.to_h
		if _s.content_type then
			_s:on("update",_s.on_update)
			_s.show_content=1
			_s.content_cover_counter=10
		else -- close
			_s.visible=0
			_s:set_visible(0)
			_s:remove_handler("update",_s.on_update)
		end
		_s:remove_handler("update",_s.on_resize)
	end
end

function popup:_draw()
	pal()
	
	-- ミ➡️しム⬅️さミ➡️しム⬅️さ(qr ムきうム▥ま)
	local dx,dy=0,0
	if self.content_type!="qr" then
		dy=rou(cos(f*.012)*12)
		dx=rou(sin(f*.012)*5)
	end
	self.y=self.y_def+dy
	self.x=64+dx
	
	local x0,y0=rou(self.x-self.w/2),rou(self.y-self.h/2)
	local x1,y1=rou(x0+self.w-1),rou(y0+self.h-1)
	local function draw_r_box(x0,y0,x1,y1,r,c)
		rectfill(x0+r,y0,x1-r,y1,c)
		rectfill(x0,y0+r,x1,y1-r,c)
		circfill(x0+r,y0+r,r,c)
		circfill(x1-r,y0+r,r,c)
		circfill(x0+r,y1-r,r,c)
		circfill(x1-r,y1-r,r,c)
	end
	fillp(0b0101101001011010.1)
	draw_r_box(x0+2,y1-10,x1-2,y1+4,7,0)
	fillp()
	local c1,c2,c3=9,10,4
	if(self.color==8) c1,c2,c3=8,14,2
	if(self.color==6) c1,c2,c3=6,7,13
	draw_r_box(x0-1,y0-1,x1+1,y1+1,7,0)
	draw_r_box(x0,y1-14,x1,y1,7,c3)
	draw_r_box(x0,y0,x1,y0+14,7,c2)
	draw_r_box(x0,y0+1,x1,y1-3,7,c1)
	pset(x0+2,y0+2,7)
	pset(x0+3,y0+1,7)
	pset(x0+1,y0+3,7)

	if(self.show_content==1) self:draw_content()
end

function popup:draw_content()
	local t=self.content_type
	local x,y,w,h=self.x,self.y,self.to_w,self.to_h
	if t=="clear" then
		local s1,s2="puzzle clear",""
		local function ff(d) return flr((f/3-d)%#s1+1) end
		local col={"e","a","b","c","e"}
		for i=1,#s1 do
			local c=col[ff(i)]
			if c then s2=s2.."\f"..c..sub(s1,i,i).."\f8"
			else s2=s2..sub(s1,i,i) end
		end
		print("\^w\^t"..s2,x-47,y-10,8)
		?"\f3❎\f8🅾️\f4exit",x-15,y+5
	elseif t=="reset" then
		local s="reset save data???"
		print(s,x-36,y-8,0)
		?"\fb❎\f2reset \fa🅾️\f2cancel",x-31,y+7
	elseif t=="qr" then
		puzzle:draw_qr(x-qr_size-2,y-qr_size-7,2,1)
		?"\f3❎\f4🅾️\fdclose",x-17,y+32
	elseif t=="exported" then
		print("exported to",x-22,y-11,0)
		print("clipboard!",x-19,y-5,0)
		?"\f3❎\f8🅾️\f4close",x-18,y+10
	end

	-- マぬ█ミすもメ😐…ムうもミくう ミ♪なム❎☉ミ⬅️さマぬ█ ム░うム░うメお☉ ムせ█ムあぬマまぬ
	if self.content_cover_counter>0 then
		fillp(cover_pattern[self.content_cover_counter])
		rectfill(x-w/2+5,y-h/2+3,x+w/2-5,y+h/2-5,self.color)
		fillp()
		self.content_cover_counter-=2
	end
end

function popup:on_update()
	local t=self.content_type
	if t=="clear" then
		if btn(4) or btn(5) then
			self:close()
			_cover:cover(function() -- メ▥☉ムうもミくう ミ🐱▤マぬ█マまぬ
					_puzzle:set_visible(0)
					_home:set_visible(1)
					_selector:set_visible(1)
				end)
		end
	elseif t=="qr" or t=="exported" then
		if(btn(4) or btn(5)) self:close()
	elseif t=="reset" then
		if btn(5) then
			cartdata_reset()
			self:close()
		end
		if(btn(4)) self:close()
	end
end


-- cover ------------------------------------------------
cover=class(sprite)
function cover:init(v)
	self.is_visible=0
	self.visible_count=0
	self.next_func=nil
	if v then self:show(v) end
end
function cover:cover(next_func)
	self:show(true)
	self.next_func=next_func
	self.is_visible=1
	self.visible_count=9*2
	self:on("update",self.on_cover)
end
function cover:cover_intro()
	self:show(true)
	self.is_visible=1
	self.visible_count=9
	self:on("update",self.on_cover)
end
function cover:on_cover()
	self.visible_count-=.2
	if self.next_func and self.visible_count<=9 then
		self.next_func()
		self.next_func=nil
	end
	if self.visible_count<=0 then
		self.is_visible=0
		self:remove_handler("update",self.on_cover)
		self:show(false)
	end
end
function cover:_draw()
	local i=clamp(rou(9-abs(self.visible_count-9)),1,9)
	fillp(cover_pattern[i])
	rectfill(0,0,127,127,0)
	fillp()
end



-- home ------------------------------------------------
home=class(sprite)
function home:init(v)
	self.is_visible=0
	self.title_x_list={-11,-5,1,10,19,25,34,40,46,55,61,67,76,82,88,97,103,109}
	self.title_data={
		"110101111110011011",
		"101110101101100100",
		"110110110101010010",
		"100110101101001001",
		"100101101011110110"}
	-- todo: ム⌂さメ✽😐ムえひムせ█ メ▒ひミすてム∧ひ ミ♪ぬムえひメ⬇️█ ムお░ム⬅️うミくう ムね░ムい😐ミ➡️⬆️ ム⬇️▒メ⬇️う
	-- (メ▒ひミすてム∧ひメˇう ム⌂さメ✽😐ムえひム❎… メˇひミ⬅️みメˇ▤ミ⌂⬆️ ムみまムえ█ ミ✽みム⬇️웃ムうもミくう メ➡️うム⬅️うミ…そ)
	self.clear_data={
		"000010000200011002",
		"000000000000100000",
		"100000010000010000",
		"100100000000000001",
		"200101000001000110"}

	self:on("update",self.on_update)
	if(v) self:set_visible(v)
end
function home:set_visible(v)
	self:show(v==1)
	self.is_visible=v
	if self.is_visible==1 then
		set_menu(2,0,1,0,0)
		music(0,2000,2)
	end
end
function home:_draw()
	rectfill(0,0,127,127,5)

	-- qr
	-- spr(14,113,2,8,8)
	-- ?"🅾️",104,2,14

	self:draw_title(13,24)

	-- ムふうメˇ▤ミ⬅️そ
	rectfill(0,119,127,127,0)
	?"▒nemo v"..ver,2,121,5
	?"music by gruber",68,121,5
	
end
function home:draw_title(x,y)
	local function draw_nemo(x,y,is_shadow,rect_only)
		for i=1,#self.title_data do
			local y1=y+(i-1)*6
			local d1=self.title_data[i]
			local d2=self.clear_data[i]
			for j=1,#d1 do
				local s=sub(d1,j,j)
				if s=="1" then
					-- ミくうマはき ミ➡️しム⬅️さミ➡️しム⬅️さ~
					local x1=x+self.title_x_list[j]-2
					local dy=sin((f-j+i*4)/150)
					if is_shadow then
						local dy=dy-1
						rectfill(x1,y1+dy,x1+6,y1+6+dy+1,0)
					else
						local s=1
						local is_clear=sub(d2,j,j)
						if(is_clear=="1") s=7
						if(is_clear=="2") s=9
						if flr(i*.7+j*1.5)==f\3%80 then
							s=4
							if(is_clear=="1") s=8
							if(is_clear=="2") s=10
						end
						local dy=dy*3-3
						rectfill(x1,y1+dy,x1+6,y1+6+dy+1,0)
						if not rect_only then spr(s,x1,y1+dy) end
					end
					
				end
			end
		end
	end
	local x2,y2=x+56,y+33
	fillp(0b0101101001011010.1)
	rectfill(x2+3,y2+3,x2+47,y2+9,0)
	draw_nemo(x+4,y+4,true)
	fillp()
	draw_nemo(x+1,y+1,false,true)
	draw_nemo(x,y)

	y2+=sin(f/150)*2
	rectfill(x2,y2,x2+44,y2+6,0)
	?"by   seimon",x2+1,y2+1,6
	?"🐱",x2+13,y2+1,4
	local s1="by 🐱seimon"
	local s2,s3="",""
	for i=1,#s1 do
		if rou(f/6)%(#s1+30)+1==i then
			s2=s2..sub(s1,i,i)
			s3=(i==4) and s3..sub(s1,i,i) or s3.." "
		else
			s2=(i==4) and s2.."  " or s2.." "
			s3=(i==4) and s3.."  " or s3.." "
		end
	end
	?s2,x2+1,y2+1,7
	?s3,x2+1,y2+1,9
end
function home:on_update()
	if(_popup.is_visible==1 or self.is_visible==0) return
	if(_cover.is_visible==1) return

	-- x:play
	-- if btn(5) and pz_cleared[_selector.selected]!=1 then
	if btn(5) then
		sfx(0,-1)
		_cover:cover(function()
			_home:set_visible(0)
			_selector:set_visible(0)
			_puzzle:set_puzzle(_selector.selected)
			_puzzle:set_visible(1)
		end)
	end

	-- ミせ☉ムあぬム⌂さミくう メ✽😐ム⌂さメ⌂ま ****************************
	-- if(dev!=1) return
	-- if(stat(34)==1) _popup:open("reset")
	-- if(stat(34)==2) _popup:open("exported")
	-- if(stat(34)==4) _popup:open("clear")
end



-- selector ------------------------------------------------

selector=class(sprite)
function selector:init(num)
    local _s=self
	_s.is_visible=1
	_s.selected=1
	_s.spacing=6

	local x=64-rou(pz[1][1]/2+4)
	_s.x=x
	_s.to_x=x
	_s.base_x=x
	_s.base_y=92

	-- マぬ▒ メ♪もムす…ムえ▤ xムけ😐メ➡️うミしも ミにまミすて マまぬミくえ
	_s.pz_list_x={}
	local x=1
	for i=1,#pz do
		_s.pz_list_x[i]=x
		x+=pz[i][1]+8+_s.spacing
	end

	_s.to_x=_s.base_x
	_s.spd_x=0

	_s:show(true)
	_s:on("update",_s.on_update)
end
function selector:set_visible(v)
	self:show(v==1)
	self.is_visible=v
end
function selector:on_update()
	if(_popup.is_visible==1 or self.is_visible==0) return
	if(_cover.is_visible==1) return
	local s=self.selected
	if(btnp(0)) self.selected-=1
	if(btnp(1)) self.selected+=1
	if(btnp(2)) self.selected-=3
	if(btnp(3)) self.selected+=3
	self.selected=clamp(self.selected,1,#pz)
	if s!=self.selected then
		self.to_x=64-pz[self.selected][1]/2-self.pz_list_x[self.selected]-4
		sfx(3,-1)
	end
	self.spd_x=(self.to_x-self.x)*0.1+self.spd_x*0.6
	self.x+=self.spd_x
	self.base_x=rou(self.x)
end
function selector:_draw()
	for i=1,#pz do
		local x=self.pz_list_x[i]+self.base_x

		-- ミはひムえひミ⌂⬆️ ム▤▒ム❎とミせ😐 マほまミすてマまぬ
		if x>-26 and x<128 then
			local w,h=pz[i][1]+8,pz[i][2]+8
			local dy=sin((f-i*4)/150)*3
			local is_cleared=(pz_cleared[i]==1)
			self:draw_puzzle_box(i,x,self.base_y-h+dy,w,h,is_cleared)
			
			-- ム░きメ⬇️えミ…う メˇとミちたム❎… ムめさム░う
			if i==self.selected then
				local x=x-1
				local y=self.base_y-h+dy-1
				local x2=x+w+1
				local y2=y+h+1
				local is_cleared=(pz_cleared[i]==1)
				local c=is_cleared and 12 or 11
				rect_shadowed(x,y,x2,y2,c)
				
				local to_x=rou(x+w/2)
				if not self.t_x then
					self.t_x=to_x
					self.t_spd_x=0
				end
				self.t_spd_x=(to_x-self.t_x)*0.1+self.t_spd_x*0.4
				self.t_x+=self.t_spd_x

				local y3=104
				draw_dotline_v(rou(self.t_x),y2+1,y3,c,-1)
				if is_cleared then
					local x1,y1=rou(self.t_x-14),y3
					prints("cleared!",x1,y1,c)
				else
					local x1,y1=rou(self.t_x-33+5),y3
					local x2,y2=x1+64,y1+6
					prints("press ❎ to play",x1+1,y1,7)
					?"❎",x1+25,y1,c
				end
			end
		end
	end
end

function selector:draw_puzzle_box(i,x,y,w,h,is_cleared)
	local x2,y2=x+w,y+h
	fillp(0b0101101001011010.1)
	rectfill(x+3,y+3,x2+2,y2+2,0)
	fillp()
	rectfill(x,y,x+w-1,y+h-1,is_cleared and 2 or 5)
	rect(x,y,x+w-1,y+h-1,0)
	
	if is_cleared or dev_preview==1 then
		if is_cleared then
			line(x+2,y+1,x+w-3,y+1,8)
			line(x+1,y+2,x+1,y+h-3,8)
			pset(x+1,y+1,9)
		end
		local data=pz_decoded[i]
		if data==nil then
			data=data_decode(pz[i][3])
			pz_decoded[i]=data
		end
		local c=(dev_preview==1 and not is_cleared) and 9 or 6
		draw_preview(x+4,y+4,w-8,h-8,data,1,c)
	else
		if i==self.selected then
			?(w-8).."\n\x13"..(h-8),x+2,y+2,0
		else
			?"?",x+2,y+2,0
		end
	end
end



-- etc. functions ------------------------------------------------

-- マま█ムお…ム❎… マほまミすもムお…
function prints(s,x,y,c)
	?s,x+1,y+1,0
	?s,x,y,c
end

-- data(str)ミしも ミ◆░メ⌂まミくう ムぬ♪マまぬ
function draw_preview(x,y,w,h,data,dot_size,c)
	if(not dot_size) dot_size=1
	for i=1,h do
		for j=1,w do
			if data[(i-1)*w+j]=="1" then
				if dot_size==1 then
					pset(x+(j-1),y+(i-1),c)
				else
					local x1=x+(j-1)*dot_size
					local y1=y+(i-1)*dot_size
					local x2,y2=x1+dot_size-1,y1+dot_size-1
			 		rect(x1,y1,x2,y2,c)
				end
			end
		end
	end
end

-- ムきˇミはひ メ✽😐ムえひミま⬆️ムえ░ ム☉つムお… メ✽😐ムえひミま⬆️ミくう ミは█メ▥▤(0,1ミせ😐 ム🐱てムあた / 111010 -> 3,1)
function data_to_nums(t)
	local function is1(n) if n==1 then return 1 else return 0 end end
	local tt={}
	local counting_num=is1(t[1]) -- ムみひムあひメ⌂まムさ➡️ムえま ム☉つムお…
	local count_times=1 -- ムう░ ム☉つムお…ミしも ムみひムあひメ⌂まメˇう ム☉▤
	for i=2,#t do
		local n=is1(t[i])
		if counting_num==n then
			count_times+=1
			if i==#t and n==1 then tt[#tt+1]=count_times end
		else
			if n==0 then tt[#tt+1]=count_times
			elseif n==1 and i==#t then tt[#tt+1]=1 end
			counting_num=n
			count_times=1
		end
	end
	return tt
end

function rect_shadowed(x0,y0,x1,y1,c)
	local w,h=x1-x0,y1-y0
	rect(x0,y0,x1,y1,c)
	line(x1+1,y0+1,x1+1,y1+1,0)
	line(x0+1,y1+1,x1,y1+1,0)
end

-- ムき…ム░き
function draw_dotline_h(x1,y1,x2,c,d)
	local w=x2-x1
	if (w<5) return
	for i=0,w\4-1 do
		local x=x1+i*4+3+(f/5)%4*d
		pset(x+1,y1+1,0) pset(x,y1,c)
	end
end
function draw_dotline_v(x1,y1,y2,c,d)
	local h=y2-y1
	if (h<5) return
	for i=0,h\4-1 do
		local y=y1+i*4+3+(f/5)%4*d
		pset(x1+1,y+1,0) pset(x1,y,c)
	end
end

-- log, system info
log_d=nil
log_counter=0
function log(...)
	local s=""
	for i,v in pairs{...} do
		s=s..v..(i<#{...} and "," or "")
	end
	if log_d==nil then log_d=s
	else log_d=sub(s.."\n"..log_d,1,200) end
	log_counter=3000
end
function print_log()
	if(log_d==nil or log_counter<=1) log_d=nil return
	log_counter-=1
	?log_d,2,2,0
	?log_d,1,1,8
end
function print_system_info()
	local cpu=rou(stat(1)*10000)
	local mem=stat(0)
	local s=(cpu\100).."."..(cpu%100\10)..(cpu%10).."%"
	print(s,104,2,0) print(s,103,1,8)
	local x=255-print(mem,128,1,0)
	print(mem,x+1,8,0) print(mem,x,7,8)
end

function draw_popup(w,h)
	local function draw_r_box(x0,y0,x1,y1,r,c)
		rectfill(x0+r,y0,x1-r,y1,c)
		rectfill(x0,y0+r,x1,y1-r,c)
		circfill(x0+r,y0+r,r,c)
		circfill(x1-r,y0+r,r,c)
		circfill(x0+r,y1-r,r,c)
		circfill(x1-r,y1-r,r,c)
	end
	local x0,y0=64-w/2,64-h/2-10
	local x1,y1=x0+w,y0+h
	fillp(0b0101101001011010.1)
	draw_r_box(x0+2,y1-10,x1-2,y1+4,7,0)
	fillp()
	draw_r_box(x0-1,y0-1,x1+1,y1+1,7,0)
	draw_r_box(x0,y0,x1,y1,7,4)
	draw_r_box(x0,y0,x1,y1-2,7,9)
end

function set_menu(m1,m2,m3,m4,m5)
	for i=1,5 do menuitem(i) end
	-- ミた⬆️ミ웃ひ ムへ⬆️マぬ█
	if(m1==1) menuitem(1,"restart",function() _puzzle:reset() end)
	--if(m1==2) menuitem(1,"reset save data",function() _popup:open("reset") end)

	if m2==1 then menuitem(2,"back to menu",function()
			_cover:cover(function()
				_puzzle:save_playing_map(_selector.selected)
				_puzzle:set_visible(0)
				_home:set_visible(1)
				_selector:set_visible(1)
			end)
		end)
	end

	--if(m3==1) menuitem(3,"▒qr code",function() _popup:open("qr") end)

	if dev==1 then
		if(m3==2) menuitem(3,"🐱clear",function() _puzzle:reset() end)
		if(m4==1) menuitem(4,"🐱change mode",function() _puzzle:change_playmode() end)
		if(m5==1) menuitem(5,"🐱export puzzle",function() _puzzle:export() end)
		if(m5==2) menuitem(5,"🐱force clear",function() _puzzle:force_clear() end)
	end
end

-- save/load
-- > todo: ミてまムお…ム❎ひ ムˇˇムへˇメˇひム░う ムき█ムおし/ミくうミ⧗うメˇ▤マまぬ
-- > ム🐱てムあた マぬ█ミ⌂し ミてまムお…: a~z, 0~9, _
function cartdata_load()
	for i=1,63 do
		pz_cleared[i]=dget(i)
	end
end
function cartdata_save()
	for i=1,63 do
		local v=pz_cleared[i]==1 and 1 or 0
		dset(i,v)
	end
end
function cartdata_reset()
	for i=1,63 do
		dset(i,nil)
		pz_cleared[i]=nil
	end
	
end



-- constants ------------------------------------------------
tile_size=6
cursor_size=8
puzzle_line_max=15

--------------------------------------------------
f=0 -- every frame +1
dim_pal={} -- ムえひマの😐 ムお☉ムうもミたひ stage ミき😐ミ♪⬆️ミせ▒ ム⬅️うムお➡️メˇき ミˇ😐 メ😐⬆️ミき☉メ⌂ま マふ…ムのひ
stage=sprite.new() -- scene graph top level object

function _init()
	cartdata("nemonemo_seimon")
	cartdata_load()

	-- ムˇˇムへˇ メ★█ム∧ひミ➡️…マまぬ
	qr_data=data_decode(qr_data_zip)

	-- ムめさミの░ メ😐そメ░ひ ミぬぬム❎ひミくう ミは█メ▥▤
	cover_pattern=split(cover_pattern_str,",")

	-- メ😐😐メ⬅️ぬメ▒ひ ミ♪ぬムえひメ⬇️█ ミぬぬム❎ひミくう ミは█メ▥▤
	local p=split(p_str,"/")
	for i=1,10 do
		p_data[i]=split(p[i],",")
	end
	
	-- メ♪もムす… ミ♪ぬムえひメ⬇️█ ミぬぬム❎ひミくう ミは█メ▥▤
	pz_pre=split(pz_str,"/")
	for i=1,#pz_pre do
		local a=split(pz_pre[i],",")
		if(#a==3) pz[i]={tonum(a[1]),tonum(a[2]),a[3]}
	end
	pz_pre=nil

	-- メ▥⬆️ミたひ マふてム░ね
	_puzzle=puzzle.new(1)
	_home=home.new(1)
	_selector=selector.new(1)
	_cover=cover.new(false)
	_popup=popup.new()
	stage:add_child(_puzzle)
	stage:add_child(_home)
	stage:add_child(_selector)
	stage:add_child(_cover)
	stage:add_child(_popup)

	_cover:cover_intro()
end
function _update60()
	f+=1
	stage:emit_update()
end
function _draw()
	cls(0)
	pal()

	if(#dim_pal>0) pal(dim_pal,0)
	stage:render(0,0)

	-- マぬうミぬうムあた
	if dev==1 then
		print_log()
		print_system_info()
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050000000006666666666666000
0555550007aaa900055555000555550007777700022222000222220007bbb300077777000a999800007aaaa00555550000000000000000006666666666666000
055555000a999900058585000555550007777a0002222200028282000b33330007777b000988880000aaaaa00585850000000000000000006655565655566000
055555000a999900055855000555550007777a0002222200022822000b33330007777b000988880000aaaaa00558550000000000000000006656566656566000
055555000a999900058585000555550007777a0002222200028282000b33330007777b000988880000aaaaa00585850000000000000000006655565655566000
0555550009999400055555000555550007aaaa0002222200022222000333310007bbbb000888820000aaaa900555550000000000000000006666666666666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050000000006655656556566000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666665566666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006655565656566000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006656566565666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006655565556566000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666666000
__map__
0000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000500000b01017020230302903024020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000215201e5201d5201651004510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001b730127300b7200472002710007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00030000115200b520055100951000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400000973005720027100071009500015000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00020000017100271004710057200672007730097400b7400d75012750187601d7702277025770267702677025770227601e750167300b7200371003700007000270000700007000070000700007000070000700
00030000307302d7402a750277502575020750137500e750097400674004730037200272002710027100270002700007000070000700007000070000700007000070000700007000070000700007000070000700
010e000005145185111c725050250c12524515185150c04511045185151d515110250c0451d5151d0250c0450a0451a015190150a02505145190151a015050450c0451d0151c0150012502145187150414518715
010e000021745115152072521735186152072521735186052d7142b7142971426025240351151521035115151d0451c0051c0251d035186151c0251d035115151151530715247151871524716187160c70724717
010e000002145185111c72502125091452451518515090250e045185151d5150e025090451d5151d025090450a0451a015190150a02505045190151a015050450c0451d0151c0150012502145187150414518715
010e000002145185112072521025090452451518515090450e04521515265150e025090451d5151d01504045090451d01520015210250414520015210250404509045280152d0150702505145187150414518715
010e000029045000002802529035186152802529035000001a51515515115150e51518615000002603500000240450000023025240351861523025240350000015515185151c51521515186150c615280162d016
010c00200c0330f13503130377140313533516337140c033306150c0330313003130031253e5153e5150c1430c043161340a1351b3130a1353a7143a7123a715306153e5150313003130031251b3130c0331b313
010c002013035165351b0351d53513025165251b0251d52513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165151b0151d51513015165251b0351d545
010c00200c0331413508130377140813533516337140c033306150c0330813008130081253e5153e5150c1330c0430f134031351b313031353a7143a7123a715306153e5150313003130031251b3130c0333e515
011800001d5351f53516525275151d5351f53516525275151f5352053518525295151f5352053518525295151f5352053517525295151f5352053517525295151d5351f53516525275151d5351f5351652527515
011800001f5452253527525295151f5452253527525295151f5452253527525295151f5452253527525295151f5452353527525295151f5452353527525295151f5452253527525295151f545225352752529515
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400002c7252c0152c7152a0252a7152a0152a7152f0152c7252c0152c7152801525725250152a7252a0152072520715207151e7251e7151e7151e715217152072520715207151e7251e7151e7151e7151e715
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020725200152071520015217252101521715210152c7252c0152c7152c0152a7252a0152a7152a015257252501525715250152672526015267153401532725310152d715280152672525015217151c015
__music__
01 07084344
00 07084344
00 09084344
00 09084344
00 0a0b4344
02 090b4344
01 0c0d4344
00 0e0d4344
00 0c0d4344
00 0e0d4344
00 0c0f4344
00 0c0f4344
02 0e104344
01 11124344
00 11124344
00 11134344
00 14134344
02 14154344


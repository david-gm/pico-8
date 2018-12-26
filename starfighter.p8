pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- star-fighter
-- by david gmeindl
function _init()
	debug_msg=true
	debug_invince=false
	⧗={
		g={f=0,s=0,m=0,t="0:0:0"},
		lvl_init=nil
	}
	score=0
	stars={}
	for i=1,16 do
		add(stars,{
			x=rnd(128),
			y=rnd(128),
			s=rnd(5)/5+1,
			c=get★c()
		})
	end
 
	setup()
	lvl=1
	reinit_lvl()
	change_gamestate("start")
end

function _update60()
end

function _draw()
end

function update_game()
	controls()
	update_stars()
  
	update_player_states()  
	update_create_enemies()
	update_enemy_states()
 
	collision_detect()
	update_timers()
end

function draw_game()
	cls(0)
	--debugtxt(⧗.g.t)
	--debugtxt(#e_swarm[2][2],22)
	--[[
	local _off_=0
	for c in all(e_swarm[1][2]) do
		debugpos(c,22+_off_)
		_off_+=7
	end
	--]]
	for s in all(stars) do
		pset(s.x,s.y,s.c)
	end
	draw_map()
	draw_enemies()
	draw_player()
	draw_ui()
	time_printer()
end

function update_start()
	if btnp(🅾️) then
	 _draw=draw_lvl_init
	 _update60=update_lvl_init
	end
end

function draw_start()
	cls(1)
	debugtxt(⧗.g.t)
	for s in all(stars) do
		pset(s.x,s.y,s.c)
	end
	--draw starship
	rectfill(0,64-27,127,64+12,0)
	spr(pl.spr_,32,64-15)
	print_mids("starfighter",64-15,8,2)
	print_mids("press 🅾️ to start",64-4,12,1)
end

function update_lvl_init()
 if (not ⧗.lvl_init) ⧗.lvl_init=0
 ⧗.lvl_init+=1
	if ⧗.lvl_init>60 then
	 ⧗.lvl_init=nil
		change_gamestate('game')
	end
end

function draw_lvl_init()
	cls(0)
	print_mids("level "..lvl,64-4,3,5)
end

function update_gameover()
	if btnp(🅾️) then
		reinit_lvl()
		change_gamestate('game')
	end
	update_timers()
end

function draw_gameover()
	cls(1)
	debugtxt(⧗.g.t)
	print_mids("your score: "..score,64-15,8)
	print_mids("press 🅾️ to restart",64-4,12)
end

function change_gamestate(state)
	reset_timers()
	if state=="start" then
		_draw=draw_start
		_update60=update_start
	elseif state=="game" then
		_draw=draw_game
		_update60=update_game
	elseif state=="gameover" then
		_draw=draw_gameover
		_update60=update_gameover
	end
end

function reinit_lvl()
	--reset_timers()
	if lvl==1 then
		init_lvl1()		
	end
end

function init_lvl1()
	score=0
	pl=pl:new((127-7)/2,ui_s.y1-6)
	enemies={}
	local _c8=cf_circ(25,8,4)
	local _arcb5=cf_arc(25,5,4,"b")
	local _arct5=cf_arc(25,5,4,"t")
	e_swarm={
		{"met1",cf_line(9,3,4,"v"),"linear","0:0:0",{64,-64}},
		{"met1",cf_line(9,5,4,"h"),"linear","0:2:0",{64,-64}},
		{"met1",cf_line(9,5,4,"dtlbr"),"linear","0:4:0",{64,-64}},
		{"met1",cf_line(9,5,4,"dtrbl"),"linear","0:4:0",{64,-64}},
		{"met1",_arcb5,"linear","0:6:0",{64,-64}},
		{"met1",_arct5,"linear","0:8:0",{96,-64}},
		{"met1",_arct5,"linear","0:8:0",{32,-64}},
		{"met1",_c8,"linear","0:12:0",{96,-64}},
		{"met1",_c8,"linear","0:12:0",{32,-64}},
		{"met2",_arcb5,"sinus","0:17:0",{32,-64}},
		{"met2",_arcb5,"sinus","0:17:0",{96,-64}}
	}
end
-->8
-- game, classes and general functions
function setup()
	--ui_size
	ui_s={
		x1=0,
		y1=121,
		x2=127,
		y2=127,
	}

	--vector_state
	vec_st={}
	function vec_st:new(x_,y_,vx_,vy_)
		local v={}
		setmetatable(v, self)
		self.__index = self
		v.x = x_
		v.y = y_
		v.vx = vx_ --velocity x
		v.vy = vy_ --velocity y
		return v
	end

	pl={}
	function pl:new(x_,y_)
		local p={}
		setmetatable(p, self)
		self.__index = self
		p.w = 6
		p.h = 7
		p.st = vec_st:new(x_,y_,2,2)
		p.spr_ = 1 --sprite number
		p.hp = 3
		p.dmg = 1
		p.shotfrq_init=10
		p.shotfrq=0
		p.shot_enable=true
		p.shots={}
		return p
	end
 
	enemy={}
	function enemy:new(w,h,spr_,vec_st_,hp,dmg,p)
		local e={}
		setmetatable(e, self)
		self.__index = self
		e.w = w
		e.h = h
		e.st = vec_st_
		e.spr_ = spr_ --sprite number
		e.hp = hp
		e.dmg = dmg
		e.points = p
		return e
	end
end

function update_timers()
	⧗.g.f+=1
	if ⧗.g.f==60 then
		⧗.g.f=0
		⧗.g.s+=1
	end
	if ⧗.g.s==60 then
		⧗.g.s=0
		⧗.g.m+=1
	end
	⧗.g.t=⧗.g.m..":"..⧗.g.s..":"..⧗.g.f
end

function reset_timers()
	⧗={
		g={f=0,s=0,m=0,t="0:0:0"}
	}
end

function controls()
	if(btn(⬅️))pl.st.x-=pl.st.vx
	if(btn(➡️))pl.st.x+=pl.st.vx
	if(btn(⬆️))pl.st.y-=pl.st.vy
	if(btn(⬇️))pl.st.y+=pl.st.vy
	if btn(❎) and pl.shot_enable then
		add_shot(pl.st.x+pl.w/2,pl.st.y)
		pl.shotfrq=pl.shotfrq_init
		pl.shot_enable=false
		sfx(0)
	end
end

function collision_detect()
	player_cd()
	enemy_cd()
end

function general_cd(a,e)
-- general collision detection
-- a: player or shot
-- e: enemy
 
	-- compare from bottom up to top
	if (a.st.y <= e.st.y+e.h  --cmp a top edge
		and a.st.y+a.h >= e.st.y) --cmp a bottom edge
 	-- compare from left to right
		and (a.st.x+a.w >= e.st.x  --cmp a right edge
 		and  a.st.x <= e.st.x+e.w) --cmp a left edge
 	then
			return true
	end
	return false
end

function update_stars()
	for s in all(stars) do
		s.y+=s.s
		if s.y > 128 then
			s.x=rnd(128)
			s.y=0
			s.s=rnd(5)/5+1
			s.c=get★c()
	 	end
	end
end

function get★c()
	local	r=flr(rnd(2))
	if (r == 0) return 7
	return 15
end

function draw_map()
	--map( celx, cely, sx, sy, celw, celh, [layer] )
	--map(0,0, mapc.x,mapc.y, 16,16, 0)
	--map(0,0, mapc.x,mapc.y-127, 16,16, 0)
end

function draw_ui()
	-- draw black rect at the bottom
	rectfill(ui_s.x1,ui_s.y1,ui_s.x2,ui_s.y2,0)
	-- draw health
	rect(110,122,127,127,7)
	for l=0,pl.hp-1 do
		local fact = l*5
		rectfill(112+fact,124,115+fact,125,12)
	end
	print(score,2,122,12)
end

function print_mid(txt,y,col)
 	local col=col or 7
	print(txt,64-(#txt*4)/2,y,col)
end

-- print mid with shadow
function print_mids(txt,y,col,col_shadow)
	local col_shadow=col_shadow or 0
	print_mid(txt,y-1,col_shadow)
	print_mid(txt,y,col)
end

function debugtxt(txt,y)
	if (not debug_msg) return
	local y_=y or 0
	print(txt,0,y_,2)
end

function debugpos(coords,y)
	debugtxt(coords[1].." "..coords[2],y)
end

function time_printer()
	if (not debug_msg) return
	print(⧗.g.t,127-6*5,0,11)
end
-->8
--player specifics
function add_shot(x_,y_)
	local s = {
 	h=4,w=1,
		st=vec_st:new(x_,y_,0,-3)
	}
	add(pl.shots,s)
end

function update_player_states()
	-- update shot frequency
	if not pl.shot_enable then
		pl.shotfrq-=1
		-- enable shot again
		if pl.shotfrq<0 then
			pl.shot_enable=true
			-- prevent underflow
			pl.shotfrq=-1
		end
	end
 
	pl.st.x=mid(0,pl.st.x,127-pl.w)
	pl.st.y=mid(0,pl.st.y,ui_s.y1-pl.h)
	for s in all(pl.shots) do
		s.st.y+=s.st.vy
 	end
end

function player_cd()
	-- detect if shots collided
	-- with border
	for i=#pl.shots,1,-1 do
		local s=pl.shots[i]
		if (s.st.y<0) del(pl.shots,s)
		-- check shot collision with 
		-- ememy
		for e in all(enemies) do
			if general_cd(s,e) then
				update_enemy_health(e,pl.dmg)
				del(pl.shots,s)
			end
		end
	end
 
	-- check player collison with
	-- enemy
	if (debug_invince) return
	for e in all(enemies) do
		if general_cd(pl,e) then
			update_player_hp(e.dmg)
			update_enemy_health(e,pl.dmg)
		end
	end
end

function update_player_hp(dmg)
	pl.hp-=dmg
	if pl.hp<=0 then
		change_gamestate("gameover")
	end
end

function draw_player()
	spr(pl.spr_,pl.st.x,pl.st.y)
 	-- draw shots
	for s in all(pl.shots) do
		line(s.st.x,s.st.y,s.st.x,s.st.y+s.h,12)
 	end
end
-->8
-- enemy specifics

function update_enemy_states()
	for e in all(enemies) do
		e.st.x+=e.st.vx
		e.st.y+=e.st.vy
 	end
end

function enemy_cd()
	for e in all(enemies) do
		--check whether screen boundaries
		--are reached
		if e.st.x-e.w>128 or
	    	e.st.y>ui_s.y1 then
			del(enemies,e)
		end
	end
end

function update_enemy_health(e,dmg)
	e.hp-=dmg
	if e.hp<=0 then
		del(enemies,e)
		score+=e.points
		sfx(1)
	end
end

function draw_enemies()
	for e in all(enemies) do
		if e.spr_ then
			spr(e.spr_,e.st.x,e.st.y)
		end
	end
	--debugtxt('#e: '..#enemies)
end

function update_create_enemies()
	for s in all(e_swarm) do
		if ⧗.g.t==s[4] then
			local _form=s[2]
			-- path: todo
			local _path=s[3]
			for coords_f in all(_form) do
				local _x=s[5][1]+coords_f[1]
				local _y=s[5][2]+coords_f[2]
				enemy_templates(s[1],_x,_y)
			end
		end
	end
end

function enemy_templates(e_str,_x,_y)
	if e_str=="met1" then
		add(enemies,enemy:new(8,8,16,
			--state,life,dmg,points
			vec_st:new(_x,_y,0,0.5),1,1,10))
	elseif e_str=="met2" then
		add(enemies,enemy:new(8,8,17,
			--state,life,dmg,points
			vec_st:new(_x,_y,0,1.0),2,1,20))
	end
end

-->8
-- enemy formations

function cf_circ(r,n,xy_off)
	local _a=1/n
	local circ_f={}
	for i=0,n-1 do
		add(circ_f,{r*-sin(_a*i)-xy_off,r*cos(_a*i)-xy_off})
	end
	return circ_f
end

-- s: spacing
-- n: number
-- xy_off: offset in x/y (enemy width,height/2)
-- d: direction
-- 	v: vertical
--		h: horizontal
--		dtlbr: diagonal top left bottom right
--		dtrbl: diagonal top right bottom left
function cf_line(s,n,xy_off,d)
	local _line={}
	for i=0,n-1 do
		local _v=n*s*(i/n-1/2)
	 if d=="v" then
	 	add(_line,{-xy_off,i*s})
	 elseif d=="h" then
	 	add(_line,{_v,-xy_off})
	 elseif d=="dtlbr" then
			add(_line,{_v,_v})
	 elseif d=="dtrbl" then
	 	add(_line,{-_v-xy_off*2-1,_v})
	 end
	end
	return _line
end

-- r: radius
-- n: number
-- xy_off: offset in x/y (enemy width,height/2)
-- d: direction
--		t: top arc
--		b: bottom arc
function cf_arc(r,n,xy_off,d)
	local _a=0.5/(n-1)
	local _arc={}
	for i=0,n-1 do
		local _v=0.25
		if d=="b" then
			_v=_a*i-0.25 --90 deg offset
		else
			_v=_a*i+0.25 --90 deg offset
		end
		add(_arc,{r*sin(_v)-xy_off,r*cos(_v)-xy_off})
	end
	return _arc
end
__gfx__
00000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700706760700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000766166700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000771117700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700075557000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55dd5555557755550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55d55dd5557551150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555d55555551550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555cc55555599550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0555c550055595500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002a0301a0401e0400e0600c2000c20023520185400c2000c20004100000000000000000000000000000000293002730025300010001d30014300093000330002300011000000000000000000000000000
000300000b6400b6300a630096400f630096200663004610046200c61006610046100260003600016000460002600016000000000000000000000000000000000000000000000000000000000000000000000000

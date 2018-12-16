pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- star-fighter
-- by david gmeindl
function _init()
	debug_msg=true
	
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
			c=get_★_c()
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
	for s in all(stars) do
		pset(s.x,s.y,s.c)
	end
	draw_map()
	draw_player() 
	draw_enemies()
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
	spr(player.spr_,32,64-15)
	print_mids("starfighter",64-15,8,2)
	print_mids("press 🅾️ to start",64-4,12,1)
end

function update_lvl_init()
 if (not ⧗.lvl_init) ⧗.lvl_init=0
 ⧗.lvl_init+=1
	if ⧗.lvl_init>90 then
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
	player=player:new(127/2-5/2,ui_s.y1-6)
	enemies={}
	e_swarm={
		{"meteor_l1",form.vline,"linear","0:0:0",{64,-64}},
		{"meteor_l1",form.arc,"linear","0:2:0",{64,-64}},
		{"meteor_l1",form.arc_top,"linear","0:4:0",{96,-64}},
		{"meteor_l2",form.arc,"sinus","0:7:0",{32,-64}}
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

	player={}
	function player:new(x_,y_)
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
	--formations & paths
	--note: 4 pxls moved to the
	-- left (x) because of size of enemy
	form={
		vline={{-4,0},{-4,-10},{-4,-20},{-4,-30}},
		arc={{-29,0},{-19,10},{-4,15},{11,10},{21,0}},
		arc_top={{-29,0},{-19,-10},{-4,-15},{11,-10},{21,0}}
	}
end

function update_timers()
	⧗.g.t=⧗.g.m..":"..⧗.g.s..":"..⧗.g.f
	⧗.g.f+=1
	if ⧗.g.f==60 then
		⧗.g.f=0
		⧗.g.s+=1
	end
	if ⧗.g.s==60 then
		⧗.g.s=0
		⧗.g.m+=1
	end
end

function reset_timers()
	⧗={
		g={f=0,s=0,m=0,t="0:0:0"}
	}
end

function controls()

	if(btn(⬅️))player.st.x-=player.st.vx
	if(btn(➡️))player.st.x+=player.st.vx
	if(btn(⬆️))player.st.y-=player.st.vy
	if(btn(⬇️))player.st.y+=player.st.vy
	if btn(❎) and player.shot_enable then
		add_shot(player.st.x+player.w/2,player.st.y)
		player.shotfrq=player.shotfrq_init
		player.shot_enable=false
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
   s.c=get_★_c()
	 end
	end
end

function get_★_c()
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
	for l=0,player.hp-1 do
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

function debugtxt(txt)
	if (not debug_msg) return
	print(txt,0,0,2)
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
	add(player.shots,s)
end

function update_player_states()
	-- update shot frequency
	if not player.shot_enable then
		player.shotfrq-=1
  	-- enable shot again
  	if player.shotfrq<0 then
			   player.shot_enable=true
				-- prevent underflow
				player.shotfrq=-1
			end
	end
 
	player.st.x=mid(0,player.st.x,127-player.w)
	player.st.y=mid(0,player.st.y,ui_s.y1-player.h)
	for s in all(player.shots) do
		s.st.y+=s.st.vy
 end
end

function player_cd()
	-- detect if shots collided
	-- with border
	for i=#player.shots,1,-1 do
		local s=player.shots[i]
		if (s.st.y<0) del(player.shots,s)
		-- check shot collision with 
		-- ememy
		for e in all(enemies) do
			if general_cd(s,e) then
				update_enemy_health(e,player.dmg)
				del(player.shots,s)
			end
		end
	end
 
	-- check player collison with
	-- enemy
	for e in all(enemies) do
		if general_cd(player,e) then
			update_player_hp(e.dmg)
			update_enemy_health(e,player.dmg)
		end
	end
end

function update_player_hp(dmg)
	player.hp-=dmg
	if player.hp<=0 then
		change_gamestate("gameover")
	end
end

function draw_player()
	spr(player.spr_,player.st.x,player.st.y)
 -- draw shots
	for s in all(player.shots) do
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
	if e_str=="meteor_l1" then
		add(enemies,enemy:new(8,8,16,
			--state,life,dmg,points
			vec_st:new(_x,_y,0,0.8),1,1,10))
	elseif e_str=="meteor_l2" then
		add(enemies,enemy:new(8,8,17,
			--state,life,dmg,points
			vec_st:new(_x,_y,0,1.0),2,1,20))
	end
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

pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- star-fighter
-- by david gmeindl
function _init()
 debug=true
 
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
 player=player:new(127/2-5/2,ui_s.y1-6)
 enemies={}
 local hp=3
 local is_spr=true
 
 add(enemies,enemy:new(8,8,is_spr,16,
     vec_st:new(8,8,0,0.8),hp,1))
 add(enemies,enemy:new(8,8,is_spr,16,
     vec_st:new(16,16,0,0.8),hp,1))
end

function _update60()
 controls()
 
 -- update stars
 for s in all(stars) do
  s.y+=s.s
 	if s.y > 128 then
 	 s.x=rnd(128)
 	 s.y=0
 	 s.s=rnd(5)/5+1
 	 s.c=get_★_c()
 	end
 end
 
 -- update states
 update_player_states()  
 update_enemy_states()
 
 collision_detect()
end

function _draw()
 cls(0)
 for s in all(stars) do
  pset(s.x,s.y,s.c)
 end
 draw_map()
 draw_player() 
 draw_enemies()
 draw_ui()
end
-->8
-- classes and general functions

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
 function enemy:new(w,h,is_spr,spr_,vec_st_,hp,dmg)
  local e={}
  setmetatable(e, self)
  self.__index = self
  e.w = w
  e.h = h
  e.st = vec_st_
  e.is_spr = is_spr --whether spr is used
  e.spr_ = spr_ --sprite number
  e.hp = hp
  e.dmg = dmg
  return e
 end
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
 -- compar from left to right
 and (a.st.x+a.w >= e.st.x  --cmp a right edge
 and  a.st.x <= e.st.x+e.w) --cmp a left edge
 then
  return true
 end
 return false
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
 rect(113,122,127,127,12) 
 for l=0,player.hp-1 do
  local fact = l*4
	 rectfill(115+fact,124,117+fact,125,7)
	end
end

function debugtxt(txt)
 --if (not debug) return
 print(txt,0,0,2)
end
-->8
--player specifics
function add_shot(x_,y_)
 local s = {
  h=4,
  w=1,
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
 		del(enemies,e)
 	end
 end
end

function update_player_hp(dmg)
	player.hp-=dmg
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
  if (e.st.x-e.w>128) del(enemies,e)
  if (e.st.y+e.h>ui_s.y1) del(enemies,e)  
 end
end

function update_enemy_health(e,dmg)
 e.hp-=dmg
 if e.hp<=0 then
  del(enemies,e)
 end
end

function draw_enemies()
 for e in all(enemies) do 
  if e.is_spr then
   spr(e.spr_,e.st.x,e.st.y)
  end
 end
 --debugtxt('#e: '..#enemies)
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
00555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55dd5555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55d55dd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55550055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05550550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002a0502405020050180400a030060200302001010010100110004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

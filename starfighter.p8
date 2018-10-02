pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- star-fighter
-- by david gmeindl
function _init()
 debug=true
 
 setup()
 player=ship:new(127/2-5/2,127-6)
 enemies={}
 local hp=3
 local is_spr=true
 add(enemies,enemy:new(8,8,8,8,is_spr,16,
     0,0.3,hp))
 add(enemies,enemy:new(16,16,8,8,is_spr,16,
     0,0.4,hp))
end

function _update60()
 controls()
 
 -- update states
 update_player_states()  
 update_enemy_states()
 
 collision_detect()
end

function _draw()
 cls(0)

 draw_player() 
 draw_enemies()
 
 --debugtxt(#enemies)
end
-->8
-- classes and general functions

function setup()
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

 ship={}
 function ship:new(x_,y_)
  local s={}
  setmetatable(s, self)
  self.__index = self
  s.w = 6
  s.h = 6
  s.st = vec_st:new(x_,y_,1.5,1.5)
  s.spr_ = 1 --sprite number
  s.dmg = 1
  s.shotfrq_init=10
  s.shotfrq=0
  s.shot_enable=true
  s.shots={}
  return s
 end
 
 enemy={}
 function enemy:new(x,y,w,h,is_spr,spr_,vx,vy,hp)
  local e={}
  setmetatable(e, self)
  self.__index = self
  e.w = w
  e.h = h
  e.st = vec_st:new(x,y,vx,vy)
  e.is_spr = is_spr --whether spr is used
  e.spr_ = spr_ --sprite number
  e.hp = hp
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
 player.st.y=mid(0,player.st.y,127-player.h)
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
  -- check collision with ememy
  for e in all(enemies) do
   if general_cd(s,e) then
    update_enemy_health(e,player.dmg)
    del(player.shots,s)
   end
  end
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
  if (e.st.x-e.w>128) del(enemies,e)
  if (e.st.y-e.h>128) del(enemies,e)  
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
 debugtxt(#enemies)
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

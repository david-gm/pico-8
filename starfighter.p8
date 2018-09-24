pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- star-fighter
-- by david gmeindl
function _init()
 debug=true
 
 setup()
 player=ship:new(127/2-5/2,127-7)
end

function _update60()
 controls()
 
 -- update states
 if not player.shot_enable then
 	player.shotfrq-=1
 	if player.shotfrq<0 then
 	 player.shot_enable=true
 	 -- prevent underflow
 	 player.shotfrq=-1
 	end
 end
 
 player.x=mid(0,player.x,128-player.w)
 for s in all(player.shots) do
	 s.y-=s.vel
	end
 
 collision_detect()
end

function _draw()
 cls(1)

	spr(player.spr_,player.x,player.y)
	-- draw shots
	for s in all(player.shots) do
	 line(s.x,s.y,s.x,s.y+s.h,12)
	 debugtxt(s.y)
	end
end
-->8
-- creates classes and jazz
 
function setup()
	ship={}
 function ship:new(x_,y_)
  local s={}
  setmetatable(s, self)
  self.__index = self
  s.w = 7
  s.h = 6
  s.x = x_
  s.y = y_
  s.vel=2
  s.spr_ = 1 --sprite number
  s.shotfrq_init=10
  s.shotfrq=0
  s.shot_enable=true
  s.shots={}
  return s
 end
 
end

function controls()

 if btn(⬅️) then 
  player.x-=player.vel
 elseif btn(➡️) then
	 player.x+=player.vel
 end
 
 if btn(❎) and player.shot_enable then
  add_shot(player.x+player.w/2,player.y)
  player.shotfrq=player.shotfrq_init
  player.shot_enable=false
 end

end

function collision_detect()
 player_cd()
end

function debugtxt(txt)
 if (not debug) return
	print(txt,0,0,2)
end
-->8
--player specifics
function add_shot(x_,y_)

 local s={
  h=4,
  x=x_,
  y=y_,
  vel=3
 }
	add(player.shots,s)
end

function player_cd()
 -- detect if shots collided
 -- border

 for i=#player.shots,1,-1 do
  local s=player.shots[i]
  if (s.y<0) del(player.shots,s)
 end

end
__gfx__
00000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077177000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000777177700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700771117700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000771117700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

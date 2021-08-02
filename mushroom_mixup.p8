pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--variables
function _init()
	player={
		sp=1,
		x=59,
		y=59,
		w=8,
		h=8,
		flp=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=3,
		acc=0.5,
		boost=4,
		anim=0,
		running=false,
		jumping=false,
		falling=false,
		sliding=false,
		landed=false,
	}
	
	gravity=0.3
	friction=0.85
	
	--simple camera
	cam_x=0
	
	--map limits
	map_start=0
	map_end=1024
	
	mush={
			red={	
			sp=64,
			x=8,
			y=72,
			w=2,
			h=1,
			flg=0
		}}

	
	------------test--------
	x1r=0 y1r=0 x2r=0 y2r=0
	collide_l="no"
	collide_r="no"
	collide_u="no"
	collide_d="no"

	-----------------------
end


-->8
--update and draw
function _update()
	player_update()
	player_animate()
	
	--simple camera
	cam_x=player.x-64+player.w/2
	if cam_x<map_start then
			cam_x=map_start
	end
	if cam_x>map_end-128 then
			cam_x=map_end-128
	end
	camera(cam_x,0)
end

function _draw()
	cls()
	map(0,0)
	draw_mushrooms()
	spr(player.sp,player.x,player.y,1,1,player.flp)
	--------test------------
	rect(x1r,y1r,x2r,y2r,7)
	print("⬅️= "..collide_l,player.x,player.y-10)
	print("➡️= "..collide_r,player.x,player.y-16)
	print("⬆️= "..collide_u,player.x,player.y-22)
	print("⬇️= "..collide_d,player.x,player.y-28)

	print(mush.red.sp,player.x,player.y-35)
	------------------------
end

function draw_mushrooms()
	spr(mush.red.sp, mush.red.x,mush.red.y,
					mush.red.w, mush.red.h)
end
-->8
--collisions
function collide_map(obj,aim,flag)
	--obj=table needs x,y,w,h
	
	local x=obj.x local y=obj.y
	local w=obj.w local h=obj.h
	
	local x1=0 local y1=0
	local x2=0 local y2=0
	
	if aim=="left" then
		x1=x-1 			y1=y
		x2=x   			y2=y+h-1
	
	elseif aim=="right" then
		x1=x+w-1 			y1=y
		x2=x+w   			y2=y+h-1
	
	elseif aim=="up" then
		x1=x+2				y1=y-1
		x2=x+w-3		y2=y
		
	elseif aim=="down" then
		x1=x+2						y1=y+h
		x2=x+w-3				y2=y+h
	end
	
	-----------test-----------
	x1r=x1		y1r=y1
	x2r=x2		y2r=y2
	-----------------------------
	
	--pixels to tiles
	x1/=8				y1/=8
	x2/=8				y2/=8
	
	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag) then
			return true
	else return false
	end
end
-->8
--player

function player_update()
	
	if collide_map(player, "down",2) then
	  --sand=flag 2
	  friction=0.5
	  player.boost=2
	elseif collide_map(player,"down",3) then
			--ice=flag 3
			friction=0.95
	else
	--default
	  friction=0.85
	  player.boost=4
	end  
	--physics
	player.dy+=gravity
	player.dx*=friction
	
	--controls
	if btn(⬅️) then
		player.dx-=player.acc
		player.running=true
		player.flp=true
	end
	if btn(➡️) then
		player.dx+=player.acc
		player.running=true
		player.flp=false
	end
	
	--slide
	if player.running
	and not btn(⬅️)
	and not btn(➡️)
	and not player.falling
	and not player.jumping then
		player.running=false
		player.sliding=true
	end
	
	--jump
	if btnp(❎)
	and player.landed then
		player.dy-=player.boost
		player.landed=false
	end
	
	
	--check collision up and down
	if player.dy>0 then
			player.falling=true
			player.landed=false
			player.jumping=false
			
				
			if collide_map(player,"down",0) then
				player.landed=true
				player.falling=false
				player.dy=0
				player.y-=((player.y+player.h+1)%8)-1
				
				------test---------
				collide_d="yes"
				else collide_d="no"
				--------------------
				
			end
	elseif player.dy<0 then
			player.jumping=true
			if collide_map(player,"up",1) then
				player.dy=0
				
				------test---------
				collide_u="yes"
				else collide_u="no"
				--------------------
			end
	end
	
	-- check collision left and right
	if player.dx<0 then
				if collide_map(player,"left",1) then
							player.dx=0
						------test---------
						collide_l="yes"
						else collide_l="no"
						--------------------
				end
	elseif player.dx>0 then
				if collide_map(player,"right",1) then
							player.dx=0
							
							------test---------
							collide_r="yes"
							else collide_r="no"
							--------------------
				end
	end
	
	
	-- stop sliding
	if player.sliding then
				if abs(player.dx)<.2
				or player.running then
						player.dx=0
						player.sliding=false
				end
	end
	
	player.x+=player.dx
	player.y+=player.dy
	
	--limit player to map
	if player.x<map_start then
			player.x=map_start
	end
	if player.x>map_end-player.w then
			player.x=map_end-player.w
	end
end

function player_animate()
		if player.jumping then
				player.sp=7
		elseif player.falling then
				player.sp=8
		elseif player.sliding then
				player.sp=9
		elseif player.running then
				if time()-player.anim>.1 then
						player.anim=time()
						player.sp+=1
						if player.sp>6 then
								player.sp=3
				end
		end
		else -- player idle
				if time()-player.anim>.3 then
						player.anim=time()
						player.sp+=1
						if player.sp>2 then
								player.sp=1
						end
				end
		end
end
-->8
--mushroom variables
function init_mushrooms()
		red={
			sp=64,
			x=1,
			y=9,
			w=2,
			h=1
		}
		add(mush, red)
end

__gfx__
0000000000444440004444400004444400044444000444440004444400044444b004444400000000000000000000000000000000000000000000000000000000
0000000000bbbbb000bbbbb00bbbbbbb0b0bbbbb0bbbbbbb0b0bbbbb00bbbbbb0bbbbbbb04444400000000000000000000000000000000000000000000000000
007007000bf71f100bf71f10b00ff71fb0bff71fb00ff71fb0bff71f0b0ff71f000ff71f0bbbbb00000000000000000000000000000000000000000000000000
000770000bfffff00bfffef0000ffffe000ffffe000ffffe000ffffeb00ffffe000ffffebf71f100000000000000000000000000000000000000000000000000
00077000000bb00000bbbb000fbbb0000fbbb0000fbbb0000fbbb00000bbb0000000bb00bfffef00000000000000000000000000000000000000000000000000
0070070000bbbb000f0bb0f0000bb000000bb000000bb000000bb0000f0bb0000000bb0000bbbbf0000000000000000000000000000000000000000000000000
000000000f0b30f0000b30000bb0300000b300000330b000003b0000003b000000000b300f0bb300000000000000000000000000000000000000000000000000
0000000000b0030000b003000000300000b300000000b000003b000003b00000000000b00000bb33000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fff88888ff888888fff88888fff33333ff333333fff33333fff99999ff999999fff99999fff11111ff111111fff11111fff44444ff444444fff44444fffeeeee
ff888888ff888888ff888888ff333333ff333333ff333333ff999999ff999999ff999999ff111111ff111111ff111111ff444444ff444444ff444444ffeeeeee
888888888888888888888888333333333333333333333333999999999999999999999999111111111111111111111111444444444444444444444444eeeeeeee
8888f888888ff888888ff8883333f333333ff333333ff3339999f999999ff999999ff9991111f111111ff111111ff1114444f444444ff444444ff444eeeffeee
88888888888f888f888ff88f33333333333f333f333ff33f99999999999f999f999ff99f11111111111f111f111ff11f44444444444f444f444ff44feeeffeef
8888888f888888ff888888ff3333333f333333ff333333ff9999999f999999ff999999ff1111111f111111ff111111ff4444444f444444ff444444ffeeeeeeff
ff8888888f88888fff88888fff3333333f33333fff33333fff9999999f99999fff99999fff1111111f11111fff11111fff4444444f44444fff44444fffeeeeef
fff88888fff88888fff88888fff33333fff33333fff33333fff99999fff99999fff99999fff11111fff11111fff11111fff44444fff44444fff44444fffeeeee
000000777f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000f77f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ff7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000f7ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000f7ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000f7ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000fff70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1cc6cc61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c166611c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc111ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c6ccccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccc661000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1166111c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c11cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c66cccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000046470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000004344005051004a4b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000050510050510050510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000004041005051005051005051004d4e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000004344004647004a4b004d4e0000000050510050510050510050510050510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050510050510050510050510050510000000050510050510050510050510050510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050510050510050510050510050510000000050510050510050510050510050510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050510050510050510050510050510000000050510050510050510050510050510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050510050510050510050510050510000000050510050510050510050510050510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707000007070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070707070707070707000007070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	cls()
	create_board()
	create_selector()
end

function _update()
	sel:update()
end

function _draw()
	cls()
	draw_board()
	sel:draw()
	draw_pieces()
end
-->8
-- board
cell_size=16

-- logic
function create_board()
	mtx={}
	for i=1,8 do
		mtx[i]={}
	end
	-- draw pawns
	for i=1,8 do
		create_pawn(false,7,i)
		create_pawn(true,2,i)
	end
	
	moves={}
end

sel_spot={
	x=-1,
	y=-1
}
sel_piece=nil
function create_selector()
	sel={
		bl=false,
		x=1,
		y=1,
		update=function(s)
			if (btnp(➡️)) then s.x=s.x+1 end
			if (btnp(⬅️)) then s.x=s.x-1 end
			if (btnp(⬆️)) then s.y=s.y-1 end
			if (btnp(⬇️)) then s.y=s.y+1 end
			if s.y>8 then s.y=8
			elseif s.y<1 then s.y=1 end
			if s.x>8 then s.x=8
			elseif s.x<1 then s.x=1 end
			
			if (btnp(❎)) then
				if sel_piece==nil then
					select_at(s.y,s.x)
				else
					local o=sel_piece:move(s.y,s.x)
					if not o then
						select_at(s.y,s.x)
					end
				end
			end
		end,
		draw=function(s)
			local colour=8
			if s.bl then colour=2 end
			rectfill(
				(s.x-1)*16,
				(s.y-1)*16,
				(s.x-1)*16+15,
				(s.y-1)*16+15,
				colour)
			spr(colour,s.x*16+4,s.y*16+4)
			if sel_spot.x!=-1 then
				rectfill(
					(sel_spot.x-1)*16,
					(sel_spot.y-1)*16,
					(sel_spot.x-1)*16+15,
					(sel_spot.y-1)*16+15,
					10)
			end
		end 
	}	
end

function select_at(y,x)
	sel_piece=mtx[y][x]
	sel_spot.x=x
	sel_spot.y=y
	moves={}
	if sel_piece!=nil then
		sel_piece:get_moves()
	end
end

-- draw
function draw_board()
	for i=0,7 do
		local black=true
		if i%2==0 then
			black=false
		end
		for j=0,7 do
			local rb=i*cell_size
			local re=i*cell_size+cell_size-1
			local cb=j*cell_size
			local ce=j*cell_size+cell_size-1
			local colour=9
			if black then colour=4 end 
			rectfill(
				rb,cb,re,ce,colour
			)
			black=not black
		end
	end
end

function draw_pieces()
	for i=0,7 do
		for j=0,7 do
			local p=mtx[i+1][j+1]
			if p!=nil then
				p:draw(i*cell_size+4,j*cell_size+4)
			end
		end
	end
end
-->8
-- pieces
function create_pawn(black,row,col)
	local sprite=1
	if black then sprite=2 end
	local p={
		bl=black,
		sp=sprite,
		draw=function(self,ypos,xpos)
			spr(self.sp,xpos,ypos)
		end,
		get_moves=function(s)
			local x=sel_spot.x
			local y=sel_spot.y
			moves={}
			local limit=1
			if s.bl then limit=8 end
			local adv=-1
			if s.bl then adv=1 end
			
			if y==limit then return end
			
			add(moves,{y=y+adv,x=x})
			if x!=1 then
				add(moves,{y=y+adv,x=x-1})
			end
			if x!=8 then
				add(moves,{y=y+adv,x=x+1})
			end
		end,
		move=function(s,y,x)
			return do_move(s,sel_spot.y,sel_spot.x,y,x)
		end
	}
	mtx[row][col]=p
end

function do_move(s,curr_y,curr_x,y,x)
	for m in all(moves) do
		if m.y==y and m.x==x then
			mtx[curr_y][curr_x]=nil
			mtx[y][x]=s
			sel_spot.x=-1
			sel_spot.y=-1
			sel_piece=nil
			return true
		end
	end
	return false
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007777000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000770000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000770000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777700111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999999998888888822222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

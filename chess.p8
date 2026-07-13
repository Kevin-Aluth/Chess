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
	draw_possible_moves()
--	if sel_spot != nil then
--		print(sel_spot.x.." "..sel_spot.y,0)
--	end
--	for move in all(moves) do
--		print(move.x.." "..move.y,11)
--	end
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
	-- create pawns
	for i=1,8 do
		create_pawn(false,7,i)
		create_pawn(true,2,i)
	end
	-- create rooks
	create_rook(true,1,1)
	create_rook(true,1,8)
	create_rook(false,8,1)
	create_rook(false,8,8)
	
	-- create bishops
	create_bishop(true,1,3)
	create_bishop(true,1,6)
	create_bishop(false,8,3)
	create_bishop(false,8,6)
	
	-- create horses
	create_horse(true,1,2)
	create_horse(true,1,7)
	create_horse(false,8,2)
	create_horse(false,8,7)
	
	-- create queens
	create_queen(true,1,4)
	create_queen(false,8,4)
	
	-- create kings
	create_king(true,1,5)
	create_king(false,8,5)
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
					local o=do_move(sel_piece,s.y,s.x)
					if not o then
						select_at(s.y,s.x)
					end
				end
			end
		end,
		draw=function(s)
			--draw selector
			local colour=8
			if s.bl then colour=2 end
			rectfill(
				(s.x-1)*16,
				(s.y-1)*16,
				(s.x-1)*16+15,
				(s.y-1)*16+15,
				colour)
			--draw selected spot
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
				draw_piece(p,i*cell_size+4,j*cell_size+4)
			end
		end
	end
end

function draw_possible_moves()
	for m in all(moves) do
		rectfill(
			(m.x-1)*16+8,
			(m.y-1)*16+8,
			(m.x-1)*16+15-8,
			(m.y-1)*16+15-8,
			3)
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
		first_turn=true,
		en_passant=false,
		get_moves=function(s)
			local x=sel_spot.x
			local y=sel_spot.y
			moves={}
			local limit=1
			if s.bl then limit=8 end
			local adv=-1
			if s.bl then adv=1 end
			
			if y==limit then return end
			
			if not 
			has_someone(y+adv,x) then
				add(moves,{y=y+adv,x=x})
				if s.first_turn and not
				has_someone(y+(adv*2),x) then
					add(moves,{y=y+(adv*2),x=x,double=true})
				end
			end
			
			if x!=1 then
				if mtx[y][x-1]!=nil and
				mtx[y][x-1].bl!=s.bl and
				mtx[y][x-1].en_passant then
					add(moves,{y=y+adv,x=x-1,passant="left"})
				end
				if has_enemy(s,y+adv,x-1) then 
					add(moves,{y=y+adv,x=x-1})
				end
			end
			
			if x!=8 then
				if mtx[y][x+1]!=nil and
				mtx[y][x+1].bl!=s.bl and
				mtx[y][x+1].en_passant then
					add(moves,{y=y+adv,x=x+1,passant="right"})
				end
				if has_enemy(s,y+adv,x+1) then
					add(moves,{y=y+adv,x=x+1})
				end
			end
		end
	}
	mtx[row][col]=p
end

function create_rook(black,row,col)
	local sprite=3
	if black then sprite=4 end
	local p={
		bl=black,
		sp=sprite,
		get_moves=function(s)
			local x=sel_spot.x
			local y=sel_spot.y
			moves={}
			for i=x+1,8 do
				if i>8 then break end
				if check_eat_spot(s,y,i) then
					break
				end
			end
			for i=x-1,1,-1 do
				if i<1 then break end
				if check_eat_spot(s,y,i) then
					break
				end
			end
			for i=y+1,8 do
				if i>8 then break end
				if check_eat_spot(s,i,x) then
					break
				end
			end
			for i=y-1,1,-1 do
				if i<1 then break end
				if check_eat_spot(s,i,x) then
					break
				end
			end
		end
	}
	mtx[row][col]=p
end

function create_bishop(black,row,col)
	local sprite=5
	if black then sprite=6 end
	local p={
		bl=black,
		sp=sprite,
		get_moves=function(s)
			local x=sel_spot.x
			local y=sel_spot.y
			moves={}
			for i=1,8 do
				local x1,y1=x+i,y+i
				if x1>8 or y1>8 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
			for i=1,8 do
				local x1,y1=x-i,y+i
				if x1<1 or y1>8 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
			for i=1,8 do
				local x1,y1=x-i,y-i
				if x1<1 or y1<1 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
			for i=1,8 do
				local x1,y1=x+i,y-i
				if x1>8 or y1<1 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
		end
	}
	mtx[row][col]=p
end

function create_horse(black,row,col)
	local sprite=7
	if black then sprite=8 end
	local p={
		bl=black,
		sp=sprite,
		get_moves=function(s)
			local x=sel_spot.x
			local y=sel_spot.y
			moves={}
			check_eat_spot(s,y+1,x+2)
			check_eat_spot(s,y-1,x+2)
			check_eat_spot(s,y+1,x-2)
			check_eat_spot(s,y-1,x-2)
			check_eat_spot(s,y+2,x+1)
			check_eat_spot(s,y+2,x-1)
			check_eat_spot(s,y-2,x+1)
			check_eat_spot(s,y-2,x-1)
		end
	}
	mtx[row][col]=p
end

function create_queen(black,row,col)
	local sprite=9
	if black then sprite=10 end
	local p={
		bl=black,
		sp=sprite,
		get_moves=function(s)
			local x=sel_spot.x
			local y=sel_spot.y
			moves={}
			for i=x+1,8 do
				if i>8 then break end
				if check_eat_spot(s,y,i) then
					break
				end
			end
			for i=x-1,1,-1 do
				if i<1 then break end
				if check_eat_spot(s,y,i) then
					break
				end
			end
			for i=y+1,8 do
				if i>8 then break end
				if check_eat_spot(s,i,x) then
					break
				end
			end
			for i=y-1,1,-1 do
				if i<1 then break end
				if check_eat_spot(s,i,x) then
					break
				end
			end
			for i=1,8 do
				local x1,y1=x+i,y+i
				if x1>8 or y1>8 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
			for i=1,8 do
				local x1,y1=x-i,y+i
				if x1<1 or y1>8 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
			for i=1,8 do
				local x1,y1=x-i,y-i
				if x1<1 or y1<1 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
			for i=1,8 do
				local x1,y1=x+i,y-i
				if x1>8 or y1<1 then break end
				if check_eat_spot(s,y1,x1) then
					break
				end
			end
		end
	}
	mtx[row][col]=p
end

function create_king(black,row,col)
	local sprite=11
	if black then sprite=12 end
	local p={
		bl=black,
		sp=sprite,
		get_moves=function(s)
			local x=sel_spot.x
			local y=sel_spot.y
			moves={}
			check_eat_spot(s,y+1,x+1)
			check_eat_spot(s,y-1,x-1)
			check_eat_spot(s,y+1,x-1)
			check_eat_spot(s,y-1,x+1)
			check_eat_spot(s,y,x+1)
			check_eat_spot(s,y,x-1)
			check_eat_spot(s,y+1,x)
			check_eat_spot(s,y-1,x)
		end
	}
	mtx[row][col]=p
end

function do_move(s,y,x)
	local curr_y,curr_x=sel_spot.y,sel_spot.x
	for m in all(moves) do
		if m.y==y and m.x==x then
			mtx[curr_y][curr_x]=nil
			mtx[y][x]=s
			sel_spot.x=-1
			sel_spot.y=-1
			sel_piece=nil
			if s.first_turn then
				s.first_turn=false
			end
			
			if m.passant=="left" then
				mtx[curr_y][curr_x-1]=nil
			elseif m.passant=="right" then
				mtx[curr_y][curr_x+1]=nil
			end
			
			for i=1,8 do
				for j=1,8 do
					local cell=mtx[i][j]
					if cell!=nil 
					and cell.en_passant then
						cell.en_passant=false
					end
				end
			end
			
			if m.double then
				s.en_passant=true
			end
			
			moves={}
			return true
		end
	end
	return false
end

function draw_piece(self,ypos,xpos)
	spr(self.sp,xpos,ypos)
end

function has_enemy(s,y,x)
	return
		mtx[y][x]!=nil and
		mtx[y][x].bl!=s.bl
end

function has_ally(s,y,x)
	return
		mtx[y][x]!=nil and
		mtx[y][x].bl==s.bl
end

function has_someone(y,x)
	return mtx[y][x]!=nil
end

function check_eat_spot(s,y,x)
	if y<1 or y>8 or x<1 or x>8 then
		return false
	end
	if has_ally(s,y,x) then 
		return true 
	elseif has_enemy(s,y,x) then
		add(moves,{y=y,x=x})
		return true
	end
	add(moves,{y=y,x=x})
	return false
end
__gfx__
00000000000000000000000007077070010110100077770000111100007777000011110007777770011111100007700000011000000000000000000000000000
00000000000770000001100007777770011111100707707001011010077777700111111007777770011111100077770000111100000000000000000000000000
00700700007777000011110000777700001111000007700000011000777777701111111070777707101111010007700000011000000000000000000000000000
00077000007777000011110000777700001111000007700000011000777777701111111070077007100110010077770000111100000000000000000000000000
00077000000770000001100000777700001111000007700000011000770777701101111000077000000110000077770000111100000000000000000000000000
00700700000770000001100000777700001111000007700000011000000777000001110000077000000110000077770000111100000000000000000000000000
00000000007777000011110000777700001111000077770000111100000777000001110000077000000110000007700000011000000000000000000000000000
00000000077777700111111007777770011111100777777001111110077777700111111007777770011111100777777001111110000000000000000000000000

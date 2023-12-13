local Player = Object:extend()

function Player:new(x,y,w,h)
	self.x = x - w/2
	self.y = y - h/2
	self.w = w
	self.h = h
	self.grav = 1
	self.xspd = 20
	self.moveLeft = true
	self.moveRight = true
	self.isMoving = false
	self.dir = 1
	self.txt = ""
	self.maxT = 2
	self.t = self.maxT
	self.dead = false
	self.img = Images.player_idle
	self.visible = true
	self.state = "normal"
	self.right = false
	self.left = false
	self.android = 0
end

function Player:update(dt)
	local state = gamestates.getState()
	if ending_leave == false then
		if self.y < HEIGHT - 20 - self.h then
			self.y = self.y + self.grav
		end
	end
	if state == "main" then
		if self.x <= 8 then
			self.moveLeft = false
		else self.moveLeft = true end

		if self.x >= WIDTH - 24 + self.w then
			self.moveRight = false
		else self.moveRight = true end
	end

	if pushing_anim == true then
		player_push:update(dt)
	end

	if ending_animate == true then
		if reload_animate == true then
			reload_anim:update(dt)
		end
		if shoot_pose_animate == true then
			shoot_pose_anim:update(dt)
		end
		--route 2
		if leave_animate == true then
			leave_anim:update(dt)
		end
		if wait_animate == true then
			wait_anim:update(dt)
		end
		if ending_final == -1 then
			player_panic:update(dt)
		elseif ending_final == -2 then
			player_killed:update(dt)
		end
	end

	idle:update(dt)
	walk_right:update(dt)
	walk_left:update(dt)
	child:update(dt)

	if ON_MOBILE and self.android == 0 then
		self.isMoving = false
	end
end

function Player:draw()
	love.graphics.setColor(1, 1, 1)
	--love.graphics.rectangle("fill", self.x,self.y, self.w, self.h)
	if self.visible == true then
		if self.dead == false then
			--if image based
			if ending_animate == false  then
				if ghost_event ~= "flashback" then
					if player_color == false then
						if self.isMoving == false then
							-- idle:pauseAtStart()
							idle:draw(Images.player_sheet,self.x,self.y)
						else
							if self.right == true then
								walk_right:resume()
								walk_right:draw(Images.player_sheet,self.x,self.y)
							elseif self.left == true then
								walk_left:resume()
								walk_left:draw(Images.player_sheet,self.x,self.y)
							end
						end
					else
						if self.isMoving == false then
							-- idle:pauseAtStart()
							idle:draw(Images.player_sheet_color,self.x,self.y)
						else
							if self.right == true then
								walk_right:resume()
								walk_right:draw(Images.player_sheet_color,self.x,self.y)
							elseif self.left == true then
								walk_left:resume()
								walk_left:draw(Images.player_sheet_color,self.x,self.y)
							end
						end
					end
				else
					if final_flashback == false then
						if pushing_anim == false then
							if self.isMoving == false then
								child:pauseAtStart()
								child:draw(Images.player_child_sheet,self.x,self.y)
							else
								child:resume()
								child:draw(Images.player_child_sheet,self.x,self.y)
							end
						else
							player_push:draw(Images.player_child_push,self.x,self.y)
						end
					else
						--nothing
					end
				end
			else
				if ending_final == 0 then
					if reload_animate == true then
						reload_anim:draw(Images.reload_sheet,self.x,self.y)
					end
					if shoot_pose_animate == true then
						shoot_pose_anim:draw(Images.shoot_pose_sheet,self.x,self.y)
					end
					if leave_animate == true then
						leave_anim:draw(Images.leave_sheet,player.x,player.y)
					end
					if wait_animate == true then
						wait_anim:draw(Images.shoot_pose_sheet,player.x,player.y)
					end
				elseif ending_final == -1 then
					player_panic:draw(Images.player_panic_sheet,self.x,self.y)
				elseif ending_final == -2 then
					player_killed:draw(Images.player_killed_sheet,self.x,self.y)
				end
			end
		else
			--
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(self.img,self.x,self.y)
		end
	else
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(self.img,self.x,self.y)
	end

	-- love.graphics.setColor(1, 0, 0, 1)
	-- love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

function Player:moveRoom(posX,nextRoom)
	local posX = posX
	local nextRoom = nextRoom

	if ending_leave == false then
		fade.state = true
	end
	self.x = posX
	currentRoom = nextRoom

	if currentRoom == Images["hallwayRight"] then
		l = 6
		r = 14
	else
		l = 12
		r = 7
	end
	leaveRoom()
end

function Player:checkDoors()
	local checkLeft = self.x <= 8 and self.dir == -1
	local checkRight = self.x >= WIDTH -  16 and self.dir == 1
	local checkMid = self.x + Images.player_idle:getWidth() >= WIDTH/2 - 6 and self.x <= WIDTH/2 + 4
	local left = 8
	local right = WIDTH - 16

	--main room
	if currentRoom == Images["mainRoom"] then
		if checkLeft then
			player:moveRoom(right,Images["livingRoom"])
		elseif checkRight then
			if ending_leave == false then
				if locked["mainRoom_right"] == false then
					player:moveRoom(left,Images["kitchen"])
				else
					doorTxt("It's locked from the other side","Maybe I should go around")
					Sounds.locked:play()
				end
			else
				doorTxt("I must not go there","I have to go to work")
			end
		elseif checkMid then
			if ending_leave == false then
				if ghost_event == "flashback" then
					doorTxt("I've just got home","I have to find mom and dad")
				else
					doorTxt("I've just got home","and it's raining outside.")
				end
				Sounds.locked:play()
			else
				LIGHT_VALUE = 1
				player:moveRoom(8,Images["endRoom"])
				player.y = 22
			end
		end
	--living room
	elseif currentRoom == Images["livingRoom"] then
		if checkLeft then
			if ending_leave == false and ending_shoot == false then
				player:moveRoom(right,Images["stairRoom"])
			else
				doorTxt("I must not go there","I have to go to work")
			end
		elseif checkRight then
			player:moveRoom(left,Images["mainRoom"])
		elseif checkMid then
			if ending_leave == false or ending_shoot == false or ending_shoot == false then
				if obtainables["chest"] == false then
					if basement_unlocked == true then
						if ending == false then
							if ammo_available == true then
								if gun_obtained == true then
									table.insert(ending_options,"Shoot Him")
									table.insert(ending_options,"Wait")
									route = 1
								else
									doorTxt("","I must rebuild the gun first.")
								end
							else
								table.insert(ending_options,"Leave Him")
								table.insert(ending_options,"Wait")
								route = 2

								--insert broken revolver
								local br_d = Interact(false,{"It's a revolver","the cylinder is broken","I can't open it","I can' tell","if its loaded","Take it?"},{"Yes","No"},"","revolver2")
								table.insert(dialogue,br_d)
								local br_i = Items(Images.br,Images["leftRoom"],41,34,"revolver2")
						  		table.insert(obj,br_i)
							end
							if route ~= 0 then
								player:moveRoom(player.x,Images["basementRoom"])
								Sounds.rain:stop()
								thunder_play = false
								lightning_flash = false
							end
						end
					else
						Sounds.unlock:play()
						Sounds.unlock:setLooping(false)
						doorTxt("You've used the key","It's unlocked now")
						basement_unlocked = true
					end
				else
					doorTxt("It's locked","I need a key")
					Sounds.locked:play()
				end
			else
				doorTxt("I must not go there","I have to go to work")
			end
		end
	--basement room
	elseif currentRoom == Images["basementRoom"] then
		if checkMid then
			if ending_leave == false and ending_shoot == false then
				if basement_lock == true then
					doorTxt("It's locked from the other side","I Guess there's no turning back")
					Sounds.locked:play()
				else
					player:moveRoom(self.x,Images["livingRoom"])
				end
			elseif ending_shoot == true then
				doorTxt("It's locked from the other side","I Guess there's no turning back")
					Sounds.locked:play()
			elseif ending_leave == true then
				player:moveRoom(self.x,Images["livingRoom"])
			end
		elseif checkLeft then
			if ending_leave == false and ending_shoot == false then
				player:moveRoom(right,Images["leftRoom"])
			elseif ending_shoot == true then
				player:moveRoom(right,Images["leftRoom"])
			elseif ending_leave == true then
				doorTxt("I must not go there","I have to go to work")
			end

			if lr_event == 0 then
				lr_event = 1
			end
		elseif checkRight then
			if ending_leave == false and ending_shoot == false and ending_wait == false then
				if rightroom_unlocked == true then
					player:moveRoom(left,Images["rightRoom"])
				else
					Sounds.locked:play()
					Sounds.locked:setLooping(false)
					doorTxt("","It's locked from the other side")
				end
			elseif ending_shoot == true then
				player:moveRoom(left,Images["rightRoom"])
			elseif ending_leave == true then
				doorTxt("I have to hurry","I have to go to work")
			elseif ending_wait == true then
				player:moveRoom(left,Images["rightRoom"])
			end
		end
	--leftRoom
	elseif currentRoom == Images["leftRoom"] then
		if checkRight then
			if ending_shoot == true or ending_wait == true then
				LIGHT_ON = true
				player:moveRoom(left,Images["basementRoom"])
			else
				player:moveRoom(left,Images["basementRoom"])
			end
		end
	elseif currentRoom == Images["rightRoom"] then
		if checkLeft then
			--locked
			-- player:moveRoom(right,images["basementRoom"])
			doorTxt("","It's locked from the other side")
			Sounds.locked:play()
			Sounds.locked:setLooping(false)
		end

	--stair room
	elseif currentRoom == Images["stairRoom"] then
		if checkLeft then
			player:moveRoom(left,Images["hallwayLeft"])
		elseif checkRight then
			player:moveRoom(left,Images["livingRoom"])
		end
	--hallway left
	elseif currentRoom == Images["hallwayLeft"] then
	     if checkLeft then
	     	player:moveRoom(left,Images["stairRoom"])
	     elseif checkRight then
	     	player:moveRoom(left,Images["masterRoom"])
	     elseif checkMid then
	     	player:moveRoom(player.x,Images["storageRoom"])
	     end
	--storage room
	elseif currentRoom == Images["storageRoom"] then
		if checkMid then
			player:moveRoom(player.x,Images["hallwayLeft"])
		end
	--master room
	elseif currentRoom == Images["masterRoom"] then
		if checkLeft then
			player:moveRoom(right,Images["hallwayLeft"])
		elseif checkRight then
			player:moveRoom(left,Images["hallwayRight"])
		elseif checkMid then
			if mid_dial == 0 then
				if locked["masterRoom_mid"] == true then
					doorTxt("It's locked","I need to find the key")
					Sounds.locked:play()
				end
			elseif mid_dial == 1 then
				Sounds.item_got:play()
				doorTxt("You've used the key","It's open now.")
				mid_dial = -1
				locked["masterRoom_mid"] = false
				do return end
			elseif mid_dial == -1 then
				player:moveRoom(player.x,Images["secretRoom"])
				move = true
			end
		end
	--secret room
	elseif currentRoom == Images["secretRoom"] then
		if checkMid then
			if event_find == false then
				player:moveRoom(player.x,Images["masterRoom"])
			else
				if screamed ~= -1 then
					doorTxt("I'm scared..","")
				else
					player:moveRoom(player.x,Images["masterRoom"])
				end
			end
		end
	--hallway right
	elseif currentRoom == Images["hallwayRight"] then
		if checkLeft then
			player:moveRoom(right,Images["masterRoom"])
		elseif checkRight then
			player:moveRoom(right,Images["kitchen"])
		elseif checkMid then
			player:moveRoom(player.x - 8,Images["daughterRoom"])
		end
	--daughter room
	elseif currentRoom == Images["daughterRoom"] then
		if checkMid then
			player:moveRoom(player.x + 8,Images["hallwayRight"])
		end
	--kitchen
	elseif currentRoom == Images["kitchen"] then
		if checkLeft then
			player:moveRoom(right,Images["mainRoom"])
			if locked["mainRoom_right"] == true then
				move = false
			end
			locked["mainRoom_right"] = false
			door_locked = false

			SaveData.data.door_locked = door_locked
			SaveData.save()

			for k,v in pairs(dialogue) do
				v.maxT = 2.5
			end

		elseif checkRight then
			player:moveRoom(right,Images["hallwayRight"])
		end
	end
end

function Player:checkItems()
	for _,v in ipairs(obj) do
		if self.x >= v.x and self.x + self.w <= v.x + v.w or
			self.x + self.w >= v.x + v.w/6 and self.x + self.w <= v.x + v.w or
			self.x >= v.x and self.x <= v.x + v.w - v.w/6
		then
			if self.state == "normal" and v.visible then
				if event_find == false then
					if door_locked == false then
						v:returnTag()
					else
						v:stillLocked()
					end
				else
					v:specialTag()
				end
			else
				if (v.tag == "chair" or v.tag == "chair_final") and v.visible then
					if event_find == false then
						if door_locked == false then
							v:returnTag()
						else
							v:stillLocked()
						end
					else
						v:specialTag()
					end
				end
			end
		end
	end
end

function Player:checkGlow()
	for _,v in ipairs(obj) do
		if self.x >= v.x and self.x + self.w <= v.x + v.w or
			self.x + self.w >= v.x + v.w/6 and self.x + self.w <= v.x + v.w or
			self.x >= v.x and self.x <= v.x + v.w - v.w/6
			then
			if self.state == "normal" then
				if v.visible == true then
					v:glow()
				end
			else
				if v.tag == "chair" or v.tag == "chair_final" then
					if v.visible == true then
						v:glow()
					end
				end
			end
		end
	end
end

function doorTxt(str1,str2)
	local str1 = str1
	local str2 = str2
	for _,v in ipairs(dialogue) do
		v:special_text(str1,str2)
		move = false
	end
end

function leaveRoom()
	for _,v in ipairs(dialogue) do
		if v.state == true then v.state = false end
		if v.option == true then v.option = false end
		if v.specialTxt == true then v.specialTxt = false end
		if v.simpleMessage == true then v.simpleMessage = false end
	end

	enemy_check()

	local doorSound = math.floor(math.random(0,1))
	if doorSound == 1 then
		Sounds.door_fast:play()
	else
		Sounds.squeak_fast:play()
	end

	if Sounds.tv_loud:isPlaying() == true then
		Sounds.tv_loud:stop()
	end
end

function Player:movement(dt)
	if love.keyboard.isDown("a") or self.android == -1 then
		if self.x >= 8 then
			self.isMoving = true
			self.x = self.x - self.xspd * dt
			self.left = true
			self.right = false
		end
	elseif love.keyboard.isDown("d") or self.android == 1 then
		if self.x <= WIDTH - 24 + self.w then
			self.isMoving = true
			self.x = self.x + self.xspd * dt
			self.right = true
			self.left = false
		end
	else
		self.isMoving = false
	end
end

return Player

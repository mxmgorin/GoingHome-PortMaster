local timer = 2
local maxTimer = 2
local minTimer = 1
local n = 1
local timer_to_use = maxTimer
local ts_vol = 0.25 --ts_theme starting volume
local start = 30
local last = 72
local credits_txt
local ending_got = ""

function credit_set_ending(ending) ending_got = ending end

function credits_load()
	SOUNDS.ts_theme:play()
	SOUNDS.ts_theme:setLooping(true)
	credits_flag = true
	random_breathe_flag = false

	--check previous endings achieved
	--if debug == false then
	--if love.filesystem.exists("save.lua") then
	--for line in love.filesystem.lines("save.lua") do
	--if credits ~= line then
	--love.filesystem.append("save.lua",credits .. "\n")
	--if credits == line then
	--break
	--end
	--end
	--end
	--end
	--end

	credits_txt = {
		"",
		"",
		"Ending: " .. ending_got,
		"Total Play time: ",
		tostring(final_clock),
		"",

		"'Going Home: Revisited'",
		"a game by:",
		"flamendless",

		"Programmer:",
		"Brandon Blanker Lim-it",

		"Arts:",
		"Conrad Reyes",

		"QA:",
		"Ian Plaus",
		"Kurt Russell De Asis",

		"Dedicated to:",
		"Hannah Daniella Tamayo",

		"",
		"Special Thanks to",
		"LOVE community",
		"Open-source community",
		"",
		"",
		"Going Home: Revisited",
		"flamendless",
		"Thank you for playing",
		""
	}
end

function credits_update(dt)
	if n < #credits_txt then
		if timer > 0 then
			timer = timer - 1 * dt
			if timer <= 0 then
				timer = timer_to_use
				n = n + 1
			end
		end
	else
		local ts = SOUNDS.ts_theme
		if ts:isPlaying() == true then
			if ts_vol > 0 then
				ts_vol = ts_vol - 0.05 * dt
				if ts_vol <= 0 then
					ts:setLooping(false)
					ts:stop()
					gamestates.nextState("title")
					RESET_STATES()
				end
			end
			ts:setVolume(ts_vol)
		end
	end
end

local function dynamic_print(s)
	for i = 1, 5 do
		local txt = credits_txt[s + i]
		love.graphics.print(
			txt,
			WIDTH_HALF - DEF_FONT:getWidth(txt) / 2,
			10 * i - DEF_FONT_HALF
		)
	end
end

function credits_draw()
	love.graphics.setColor(1, 1, 1, 1)
	local t = credits_txt[n]
	local tw = DEF_FONT:getWidth(t)

	if n < 18 then
		love.graphics.print(t, WIDTH_HALF - tw / 2, HEIGHT_HALF - DEF_FONT_HALF)
	elseif n >= 18 and n <= 23 then
		timer_to_use = minTimer
		local s = 18
		for i = 1, 5 do
			local tn = credits_txt[s + i]
			love.graphics.print(
				tn,
				WIDTH_HALF - DEF_FONT:getWidth(tn) / 2,
				10 * i - DEF_FONT_HALF
			)
		end
	elseif n >= 24 and n < 29 then
		timer_to_use = maxTimer
		love.graphics.print(t, WIDTH_HALF - tw / 2, HEIGHT_HALF - DEF_FONT_HALF)

		--start
		-- elseif n >= 30 and n < 34 then
		-- 	timer_to_use = minTimer
		-- 	dynamic_print(29)
		-- elseif n >= 35 and n < 39 then
		-- 	dynamic_print(34)
		-- elseif n >= 40 and n < 44 then
		-- 	dynamic_print(39)
		-- elseif n >= 45 and n < 49 then
		-- 	dynamic_print(44)
		-- elseif n >= 50 and n < 54 then
		-- 	dynamic_print(49)
		-- elseif n >= 55 and n < 59 then
		-- 	dynamic_print(54)
		-- elseif n >= 60 and n < 64 then
		-- 	dynamic_print(59)
		-- elseif n >= 65 and n < 69 then
		-- 	dynamic_print(64)
		-- elseif n >= 70 and n < 72 then
		-- 	dynamic_print(69)
		-- elseif n >= 72 then
		-- 	love.graphics.print(t,width/2 - tw/2, height/2 - th/2)
		-- 	timer_to_use = maxTimer
		-- end

	elseif n >= start and n < (start + 5 - 1) then
		timer_to_use = minTimer
		dynamic_print(29)
	elseif n >= start + 5 and n < (start - 1) + 10 then
		dynamic_print(34)
	elseif n >= start + 10 and n < (start - 1) + 15 then
		dynamic_print(39)
	elseif n >= start + 15 and n < (start - 1) + 20 then
		dynamic_print(44)
	elseif n >= start + 20 and n < (start - 1) + 25 then
		dynamic_print(49)
	elseif n >= start + 25 and n < (start - 1) + 30 then
		dynamic_print(54)
	elseif n >= start + 30 and n < (start - 1) + 35 then
		dynamic_print(59)
	elseif n >= start + 35 and n < (start - 1) + 40 then
		dynamic_print(64)
	elseif n >= start + 40 and n < last then
		dynamic_print(69)
	elseif n >= last then
		love.graphics.print(t, WIDTH_HALF - tw / 2, HEIGHT_HALF - DEF_FONT_HALF)
		timer_to_use = maxTimer
	end
end

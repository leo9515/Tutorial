local Config = nil
local Master = nil
local ChangingKeyVariable = nil
local MenuIndex = nil
local LastKeyState = nil
local ChangingKeyInstance = nil
local HeaderSprite = nil
local SelectorConfig = nil
local Background = nil
local Foreground = nil
local FontColor = nil
local White = nil
local Gray = nil
local DarkGreen = nil
local DarkRed = nil
local LightGray = nil

local MenuKey = 16
local GameEnemyCount = 0

local InitConfig = true
local InitDraw = true
local InitOnDraw = true
local InitOnMsg = true

local ChangingKey = false
local ChangingKeyMenu = false
local Moving = false
local SliceInstance = false
local ListInstance = false

local Instances = { }
local GameHeroes = { }


local Draw = {
	Width = 374, -- even number or separator lines on params will be off by one
	Padding = 3,
	FontSize = 14,
	Opacity = 60,
    ColorOpacity = 100,
    FontOpacity = 255,
	Row4x = 0.8,
	Row3x = 0.7,
	CellHeight = 20,
	HeaderHeight = 30,
	DetailWidth = 35, -- ex: number beside slider
}
local Global = {
	TS_SetFocus = _G.TS_SetFocus,
	TS_SetHeroPriority = _G.TS_SetHeroPriority,
	TS_Ignore = TS_Ignore,
}
local MouseOffset = {
	x = 0,
	y = 0,
}
local Modifying = {
	Width = false,
}
local Colors = {
	Background = { 23, 32, 33 },
	Foreground = { 38, 76, 72 },
	FontColor = { 255, 255, 255 },
	White = { 255, 255, 255 },
	Gray = { 128, 128, 128 },
	DarkGreen = { 0, 128, 0 },
	DarkRed = { 128, 0, 0 },
	LightGray = { 211, 211, 211 },
}

function Class(name)
	local o = { }
	o.__index = o
	setmetatable(o, {
		__call = function(_, ...)
			local i = { }
			setmetatable(i, o)
			if (i.__init) then
				i.__init(i, table.unpack({ ... }))
			end
			return i
		end
	})
	_ENV[name] = o
end
function SensitiveMerge(base, mergeTable)
	for i, v in pairs(mergeTable) do
		if (type(base[i]) == type(v)) then
			if (type(v) == "table") then
				SensitiveMerge(base[i], v)
			else
				base[i] = v
			end
		end
	end
	return base
end
function MergeExisting(t1, t2)
	local output = t1
	if (t2) then
		for k1, v in pairs(t2) do
			for k2, _ in pairs(t1) do
				if (k2 == k1) then
					output[k1] = v
					break
				end
			end
		end
	end
	return output
end
function GetKeyAsString(key)
	if (key == 46) then
		return "n/a"
	end
	return ((key > 32) and (key < 96) and string.char(key) or tostring(key))
end

function LoadSettings(name)
	if (not GetSave("scriptConfig")[name]) then
		GetSave("scriptConfig")[name] = { }
	end
    return GetSave("scriptConfig")[name]
end
function SaveSettings(name, content)
    if (not GetSave("scriptConfig")[name]) then
		GetSave("scriptConfig")[name] = { }
	end
    table.clear(GetSave("scriptConfig")[name])
    table.merge(GetSave("scriptConfig")[name], content, true)
	GetSave("scriptConfig"):Save()
end
function RemoveSettings(name)
    if not GetSave("scriptConfig")[name] then 
        GetSave("scriptConfig")[name] = {} 
    end
    table.clear(GetSave("scriptConfig")[name])
end

function UpdateMaster()
	Master = LoadSettings("Master")
    MasterY, MasterYp = 1, 0
    MasterY = (Master.useTS and 1 or 0)
    for i = 1, MasterIndex - 1 do
        MasterY = MasterY + Master["I" .. i]
        MasterYp = MasterYp + Master["PS" .. i]
    end
    local size, sizep = (Master.useTS and 2 or 1), 0
    for i = 1, Master.iCount do
        size = size + Master["I" .. i]
        sizep = sizep + Master["PS" .. i]
    end
	Draw.x = Master.x or Draw.x
	Draw.y = Master.y or Draw.y

end
function SaveMaster()
	local settings = {
		x = Draw.x,
		y = Draw.y,
        px = Draw.px,
        py = Draw.py,
	}
    local P, PS, I = 0, 0, 0
    for _, instance in pairs(Instances) do
        I = I + 1
        P = P + #instance._param
        PS = PS + #instance._permaShow
    end
    Master["I" .. MasterIndex] = I
    Master["P" .. MasterIndex] = P
    Master["PS" .. MasterIndex] = PS
    if not Master.useTS and SelectorConfig then Master.useTS = true end
    for var, value in pairs(Master) do
        settings[var] = value
    end
	SaveSettings("Master", settings)
end
function SaveMenu()
	GetSave("scriptConfig").Menu.menuKey = MenuKey
	GetSave("scriptConfig"):Save()
	SaveMaster()
end

function GetGameHero(target)
    if (type(target) == "string") then
		for i = 1, #GameHeroes do
			local gameHero = GameHeroes[i]
            if ((gameHero.hero.charName == target) and (gameHero.hero.team ~= player.team)) then
                return gameHero.hero
            end
        end
    elseif (type(target) == "number") then
        return heroManager:getHero(target)
    elseif (target == nil) then
        return GetTarget()
    else
        return target
    end
end
function GetGameHeroIndex(target)
	if (type(target) == "string") then
		for i = 1, #GameHeroes do
			local gameHero = GameHeroes[i]
            if ((gameHero.hero.charName == target) and (gameHero.hero.team ~= player.team)) then
                return gameHero.index
            end
        end
    elseif (type(target) == "number") then
        return target
    else
        return GetGameHeroIndex(target.charName)
    end
end

function InitializeConfig(name)
	if (name == nil) then
		return (InitConfig or InitializeDraw())
	end
    local gameStart = GetGame()
	if (InitConfig) then
		InitConfig = nil
		InitializeDraw()
		MergeExisting(Draw, LoadSettings("Master"))
        Master = LoadSettings("Master")
        RemoveSettings("Master")
        MasterIndex = 1
        Master.useTS = false
        Master.x = Draw.x
        Master.y = Draw.y
        Master.px = Draw.px
        Master.py = Draw.py
        Master.osTime = gameStart.osTime
        Master.name1 = name
        Master.iCount = 1
		SaveMaster()
	end
	UpdateMaster()
end
function InitializeDraw()
	if (InitDraw) then
		InitDraw = nil
		UpdateWindow()
		Draw.x = WINDOW_W and math.floor(WINDOW_W / 50) or 20
		Draw.y = WINDOW_H and math.floor(WINDOW_H / 4) or 20
        Draw.px = WINDOW_W and math.floor(WINDOW_W * 0.66) or 675
        Draw.py = WINDOW_H and math.floor(WINDOW_H * 0.8) or 608
        Draw.PermashowFontSize = WINDOW_H and math.round(WINDOW_H / 60) -2 or 14
        Draw.midSize = Draw.PermashowFontSize / 2
        Draw.border = 1
        Draw.cellSize = Draw.border + Draw.PermashowFontSize
		Draw.Width = WINDOW_W and math.round(WINDOW_W / 4.8) or 213
        Draw.row = Draw.Width * 0.7
		Draw.Row4 = Draw.Width * Draw.Row4x
		Draw.Row3 = Draw.Width * Draw.Row3x
		--Draw.CellHeight = Draw.FontSize * 1.3
		--Draw.HeaderHeight = math.round(Draw.CellHeight * 1.4)
		--Draw.DetailWidth = Draw.FontSize * 2.2
		Background = ARGB(Draw.Opacity, Colors.Background[1], Colors.Background[2], Colors.Background[3])
		Foreground = ARGB(Draw.Opacity, Colors.Foreground[1], Colors.Foreground[2], Colors.Foreground[3])
		FontColor = ARGB(Draw.FontOpacity, Colors.FontColor[1], Colors.FontColor[2], Colors.FontColor[3])
		White = ARGB(Draw.FontOpacity, Colors.White[1], Colors.White[2], Colors.White[3])
		Gray = ARGB(Draw.FontOpacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3])
		DarkGreen = ARGB(Draw.Opacity, Colors.DarkGreen[1], Colors.DarkGreen[2], Colors.DarkGreen[3])
		DarkRed = ARGB(Draw.ColorOpacity, Colors.DarkRed[1], Colors.DarkRed[2], Colors.DarkRed[3])
		LightGray = ARGB(Draw.FontOpacity, Colors.LightGray[1], Colors.LightGray[2], Colors.LightGray[3])
		MenuKey = LoadSettings("Menu").menuKey or 16
		if ((WINDOW_H < 500) or (WINDOW_W < 500)) then
			return true
		end
	end
	return InitDraw
end
function InitializeGameHeroes()
	for i = 1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if (hero and hero.valid) then
			GameEnemyCount = GameEnemyCount + 1
			GameHeroes[#GameHeroes + 1] = {
				hero = hero,
				index = i,
				tIndex = GameEnemyCount,
				ignore = false,
				priority = 1,
				enemy = true,
			}
		end
	end
end

function LoadConfig()
	if (InitOnDraw) then
		InitOnDraw = nil
		AddDrawCallback(ConfigOnDraw)
	end
	if (InitOnMsg) then
		InitOnMsg = nil
		AddMsgCallback(ConfigOnWndMsg)
	end
end

function StartMoveWithMouse()
	Moving = true
	local pos = GetCursorPos()
	MouseOffset.x = pos.x - Draw.x
	MouseOffset.y = pos.y - Draw.y
end

function ConfigOnDraw()
	if (InitializeConfig() or Console__IsOpen or GetGame().isOver) then return end
        local y1 = Draw.py + (Draw.cellSize * MasterYp)
------------------------------Function------------------------------
local function DrawPermaShows(instance)
    --print("permashownum:",#instance._permaShow)
if #instance._permaShow > 0 then
    for _, varIndex in ipairs(instance._permaShow) do
        --if(type(instance[instance._param[_].var]) == "number") then
        local pVar = instance[instance._param[_].var] 
        --print(type(pVar))
        --local var = self[self._param[i].var]
        DrawLine(Draw.px - Draw.border, y1 + Draw.midSize, Draw.px + Draw.row - Draw.border, y1 + Draw.midSize, Draw.cellSize, ARGB(Draw.Opacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3]))
        for i, v in pairs(instance._param) do
            if (v.var == varIndex) then
                DrawTextA(v.text, Draw.PermashowFontSize, Draw.px, y1, White, "left", "left")
                if v.pType == SCRIPT_PARAM_SLICE or v.pType == SCRIPT_PARAM_LIST or v.pType == SCRIPT_PARAM_INFO then
                DrawLine(Draw.px + Draw.row, y1 + Draw.midSize, Draw.px + Draw.Width + Draw.border, y1 + Draw.midSize, Draw.cellSize, ARGB(Draw.Opacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3]))
                    if v.pType == SCRIPT_PARAM_LIST then
                        local text = tostring(v.listTable[pVar])
                        local maxWidth =(Draw.Width - Draw.row) * 0.8
                        local textWidth = GetTextArea(text, Draw.FontSize).x
                        if textWidth > maxWidth then
                            text = text:sub(1, math.floor(text:len() * maxWidth / textWidth)) .. ".."
                        end
                        DrawTextA(text, Draw.FontSize, Draw.px + Draw.row, y1, White,"left","left")
                    else
                        DrawTextA(tostring(pVar), Draw.FontSize, Draw.px + Draw.row + Draw.border, y1, White,"left","left")
                    end
                else
                DrawLine(Draw.px + Draw.row, y1 + Draw.midSize, Draw.px + Draw.Width + Draw.border, y1 + Draw.midSize, Draw.cellSize,(pVar and DarkGreen or DarkRed))
                DrawText((pVar and "      ON" or "      OFF"), Draw.FontSize, Draw.px + Draw.row + Draw.border, y1, White)
                end
            end
        end

        y1 = y1 + Draw.cellSize
    end
end
end
------------------------------DrawPermaShow-------------------------
    for _, instance in ipairs(Instances) do
        DrawPermaShows(instance)
    end
----------------------------End DrawPermaShow-----------------------

	if (IsKeyDown(MenuKey) or ChangingKey or Moving) then
		if (Moving) then
			local pos = GetCursorPos()
			Draw.x = math.min(math.max(pos.x - MouseOffset.x, 0), WINDOW_W - Draw.Width)
			Draw.y = math.min(math.max(pos.y - MouseOffset.y, 0), WINDOW_H - Draw.HeaderHeight)
		end
		DrawMainHeaderSprite()
		Draw.y1 = Draw.y + Draw.HeaderHeight - 1
		if (SelectorConfig) then
			SelectorConfig._y1 = Draw.y1
			DrawMenuSprite(Draw.x, Draw.y1, SelectorConfig.header, (MenuIndex == 0))
			if (MenuIndex == 0) then
				SelectorConfig:OnDraw()
			end
			Draw.y1 = Draw.y1 + Draw.CellHeight - 1
		end
		for i = 1, #Instances do
			local selected = (MenuIndex == i)
			Instances[i]._y1 = Draw.y1
			DrawMenuSprite(Draw.x, Draw.y1, Instances[i].header, selected)
			if (selected) then
				Instances[i]:OnDraw()
			end
			Draw.y1 = Draw.y1 + Draw.CellHeight - 1
		end
	end
end
function ConfigOnWndMsg(message, key)
	if (InitializeConfig() or Console__IsOpen) then return end
	if (ChangingKey) then
		if (message == KEY_DOWN) then
			if (ChangingKeyMenu) then return end
			ChangingKey = false
			if (ChangingKeyVariable == nil) then
				if (key == 46) then
					PrintLocal("Cannot set delete as the menu key!", true)
				else
					MenuKey = key
					SaveMenu()
				end
			else
				ChangingKeyInstance._param[ChangingKeyVariable].key = key
				ChangingKeyInstance:save()
			end
			return
		elseif (ChangingKeyMenu and (key == MenuKey)) then
			ChangingKeyMenu = false
		end
	end
	if ((message == WM_LBUTTONDOWN) and IsKeyDown(MenuKey)) then
		if (CursorIsUnder(Draw.x + Draw.Padding + Draw.Width - (Draw.Padding * 2) - 2 - Draw.DetailWidth, Draw.y + Draw.Padding + 2, Draw.DetailWidth, Draw.HeaderHeight - 4)) then
			ChangingKey = true
			ChangingKeyVariable = nil
			ChangingKeyMenu = true
			return
		elseif (CursorIsUnder(Draw.x + Draw.Padding + 1, Draw.y + Draw.Padding + 1, Draw.Width - (Draw.Padding * 2) - 2, Draw.HeaderHeight - (Draw.Padding * 2) - 2)) then
			StartMoveWithMouse()
		else
			if (MenuIndex) then
				if (MenuIndex == 0) then
					if (CursorIsUnder(SelectorConfig._x + Draw.Padding + 1, Draw.y, Draw.Width - (Draw.Padding * 2) - 2, Draw.HeaderHeight)) then
						StartMoveWithMouse()
						return
					else
						for i = 1, #SelectorConfig._subInstances do
							if (CursorIsUnder(SelectorConfig._subInstances[i]._x + Draw.Padding + 1, Draw.y, Draw.Width - (Draw.Padding * 2) - 2, Draw.HeaderHeight)) then
								StartMoveWithMouse()
								return
							end
						end
					end
					CheckOnWndMsg(SelectorConfig)
				else
					local function CheckForMove(instance)
						if (CursorIsUnder(instance._x + Draw.Padding + 1, Draw.y, Draw.Width - (Draw.Padding * 2) - 2, Draw.HeaderHeight)) then
							StartMoveWithMouse()
							return true
						elseif (#instance._subInstances > 0) then
							for i = 1, #instance._subInstances do
								if (CheckForMove(instance._subInstances[i])) then
									return true
								end
							end
						end
						return false
					end
					if (CheckForMove(Instances[MenuIndex])) then return end
					CheckOnWndMsg(Instances[MenuIndex])
				end
			end
			if (SelectorConfig and CursorIsUnder(Draw.x, SelectorConfig._y1, Draw.Width, Draw.CellHeight)) then
				if (MenuIndex == 0) then
					SelectorConfig:ResetSubIndexes()
					MenuIndex = nil
				else
					if (MenuIndex) then
						Instances[MenuIndex]:ResetSubIndexes()
					end
					MenuIndex = 0
				end
			end
			for i = 1, #Instances do
				if (CursorIsUnder(Draw.x, Instances[i]._y1, Draw.Width, Draw.CellHeight)) then
					if (MenuIndex and (i == MenuIndex)) then
						Instances[MenuIndex]:ResetSubIndexes()
						MenuIndex = nil
					else
						if (MenuIndex) then
							if (MenuIndex == 0) then
								SelectorConfig:ResetSubIndexes()
							else
								Instances[MenuIndex]:ResetSubIndexes()
							end
						end
						MenuIndex = i
					end
					break
				end
			end
		end
	elseif (message == WM_LBUTTONUP) then
		if (Moving) then
			Moving = false
			return
		elseif (SliceInstance) then
			SliceInstance:save()
			SliceInstance._slice = false
			SliceInstance = false
			return
		elseif (ListInstance) then
			ListInstance:save()
			ListInstance._list = false
			ListInstance = false
		end
	elseif (key ~= 46) then
		for i = 1, #Instances do
			CheckForWndMsg(message, key, Instances[i])
		end
	end
end

function CheckOnWndMsg(instance)
	if (CursorIsUnder(instance._x, Draw.y, Draw.Width, instance._height)) then
		instance:OnWndMsg()
	elseif (instance._subMenuIndex > 0) then
		CheckOnWndMsg(instance._subInstances[instance._subMenuIndex])
	end
end
function CheckForWndMsg(message, key, instance)
	for i = 1, #instance._param do
		local param = instance._param[i]
		if ((param.pType == SCRIPT_PARAM_ONKEYTOGGLE) and (key == param.key) and (message == KEY_DOWN)) then
			instance[param.var] = not instance[param.var]
		elseif ((param.pType == SCRIPT_PARAM_ONKEYDOWN) and (key == param.key)) then
			instance[param.var] = (message == KEY_DOWN)
		end
	end
	for i = 1, #instance._subInstances do
		CheckForWndMsg(message, key, instance._subInstances[i])
	end
end

function DrawMainHeaderSprite()
	local padding = Draw.Padding + 1
	local moveWidth = Draw.Width - (Draw.Padding * 2) - 2
	local moveHeight = Draw.HeaderHeight - (Draw.Padding * 2) - 2
	local text = ChangingKey and not ChangingKeyVariable and "Press new key for menu..." or "脚本设置"
	local keyx = Draw.x + Draw.Padding + moveWidth - Draw.DetailWidth
	local keyy = Draw.y + Draw.Padding + 2
	local fullHeight = Draw.HeaderHeight + ((Draw.CellHeight - 1) * #Instances) + (SelectorConfig and (Draw.CellHeight - 1) or 0)
	DrawRectangle(Draw.x, Draw.y, Draw.Width, fullHeight, ARGB(Draw.Opacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3]))
	--DrawRectangle(Draw.x + 1, Draw.y + 1, Draw.Width - 2, Draw.HeaderHeight - 2, Background)
	--DrawRectangle(Draw.x + padding, Draw.y + padding, moveWidth, moveHeight, FontColor)
	--DrawRectangle(Draw.x + padding + 1, Draw.y + padding + 1, moveWidth - 2, moveHeight - 2, Foreground)
	DrawTextA(text, Draw.FontSize, Draw.x + padding , Draw.y + padding + (moveHeight / 2), FontColor, "left", "center")
	DrawRectangle(keyx, keyy, Draw.DetailWidth, moveHeight - 2, ARGB(Draw.Opacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3]))
	--DrawLines2({ D3DXVECTOR2(keyx - 1, keyy), D3DXVECTOR2(keyx - 1, keyy + Draw.HeaderHeight - 4 - (Draw.Padding * 2)) }, 1, FontColor)
	DrawTextA("("..GetKeyAsString(MenuKey)..")", Draw.FontSize, keyx + (Draw.DetailWidth / 2), keyy + ((moveHeight - 2) / 2), FontColor, "center", "center")
end
function DrawMenuSprite(x, y, header, selected)
	--DrawRectangle(x, y, Draw.Width, Draw.CellHeight, LightGray)
    --print("UsedDrawMenu!header =",header)
    local  newheader
    if(header ~= nil and header ~= "") then            
        --print("header text:",header)
        newheader = translationchk(header) 
        else
        newheader = header
        end
	DrawRectangle(x + 1, y + 1, Draw.Width - 2, Draw.CellHeight - 2, selected and Foreground or Background)
	DrawTextA(newheader, Draw.FontSize, x + (Draw.Padding * 2), y + (Draw.CellHeight / 2), selected and White or FontColor, nil, "center")
	DrawTextA(">>", Draw.FontSize, x + Draw.Width - (Draw.Padding * 2), y + (Draw.CellHeight / 2), selected and White or FontColor, "right", "center")
end
function DrawHeaderSprite(x, y, header, items)
	local moveWidth = Draw.Width - (Draw.Padding * 2) - 2
	local moveHeight = Draw.HeaderHeight - (Draw.Padding * 2) - 2
	local movex = x + Draw.Padding + 1
	local movey = y + Draw.Padding + 1
	local fullHeight = Draw.HeaderHeight + ((Draw.CellHeight - 1) * items)
    --print("UsedDrawHeader!header =",header)
	DrawRectangle(x, y, Draw.Width, fullHeight, ARGB(Draw.Opacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3]))
	--DrawRectangle(x + 1, y + 1, Draw.Width - 2, Draw.HeaderHeight - 2, Background)
	--DrawRectangle(movex, movey, moveWidth, moveHeight, FontColor)
	--DrawRectangle(movex + 1, movey + 1, moveWidth - 2, moveHeight - 2, Foreground)
    local  newheader
    if(header ~= nil and header ~= "") then            
        --print("header text:",header)
        newheader = translationchk(header) 
        else
        newheader = header
        end
	DrawTextA(newheader, Draw.FontSize, movex + (moveWidth / 2), movey + (moveHeight / 2), FontColor, "center", "center")
end
function DrawToggleSprite(x, y, text, active)
   -- print("UsedToggleSprite!text=",text)
	local buttonx = x + Draw.Row3 - 1
	local buttony = y + 1
	--DrawRectangle(x, y, Draw.Width, Draw.CellHeight, FontColor)
	DrawRectangle(x + 1, y + 1, Draw.Width - 2, Draw.CellHeight - 2, Background)
    --print("In drawtoggle text=",text)
	DrawTextA(text, Draw.FontSize, x + (Draw.Padding * 2), y + (Draw.CellHeight / 2), FontColor, nil, "center")
	--DrawLines2({ D3DXVECTOR2(x + Draw.Row3 - 2, y + 1), D3DXVECTOR2(x + Draw.Row3 - 2, y + Draw.CellHeight) }, 1, FontColor)
	DrawRectangle(buttonx, buttony, Draw.Width - Draw.Row3, Draw.CellHeight - 2, active and DarkGreen or DarkRed)
	DrawTextA(active and "ON" or "OFF", Draw.FontSize, buttonx + ((Draw.Width - Draw.Row3) / 2) + Draw.Padding, buttony + (Draw.CellHeight / 2), LightGray, "center", "center")
end
function DrawInfoSprite(x, y, text, info)
    local info = info and ((type(info) == "number") and tostring(info)) or info
	--DrawRectangle(x, y, Draw.Width, Draw.CellHeight, FontColor)
	DrawRectangle(x + 1, y + 1, Draw.Width - 2, Draw.CellHeight - 2, Background)
     --print("UsedDrawInfo!text =",text)
	DrawTextA(text, Draw.FontSize, x + (Draw.Padding * 2), y + (Draw.CellHeight / 2), FontColor, nil, "center")
	if (info and (info:len() > 0)) then
		--DrawLines2({ D3DXVECTOR2(x + Draw.Row3 - 2, y + 1), D3DXVECTOR2(x + Draw.Row3 - 2, y + Draw.CellHeight) }, 1, FontColor)
		DrawRectangle(x + Draw.Row3 - 1, y + 1, Draw.Width - Draw.Row3, Draw.CellHeight - 2, Foreground)
		DrawTextA(info, Draw.FontSize, x + Draw.Row3 - 1 + ((Draw.Width - Draw.Row3) / 2), y + 1 + ((Draw.CellHeight - 2) / 2), FontColor, "center", "center")
	end
end
function DrawColorSprite(x, y, text, color)
	--DrawRectangle(x, y, Draw.Width, Draw.CellHeight, FontColor)
	DrawRectangle(x + 1, y + 1, Draw.Width - 2, Draw.CellHeight - 2, Background)
	DrawTextA(text, Draw.FontSize, x + (Draw.Padding * 2), y + (Draw.CellHeight / 2), FontColor, nil, "center")
	--DrawLines2({ D3DXVECTOR2(x + Draw.Row3 - 2, y + 1), D3DXVECTOR2(x + Draw.Row3 - 2, y + Draw.CellHeight) }, 1, FontColor)
	DrawRectangle(x + Draw.Row3 - 1, y + 1, Draw.Width - Draw.Row3, Draw.CellHeight - 2, ARGB(Draw.ColorOpacity, color[2], color[3], color[4]))
end
function DrawKeyToggleSprite(x, y, text, active, key)
	local buttonWidth = Draw.Width - Draw.Row3
	local keyx = x + Draw.Width - buttonWidth - Draw.DetailWidth - 2
	local keyy = y + 1
	DrawToggleSprite(x, y, text, active)
	--DrawLines2({ D3DXVECTOR2(x + Draw.Width - buttonWidth - Draw.DetailWidth - 3, y + 1), D3DXVECTOR2(x + Draw.Width - buttonWidth - Draw.DetailWidth - 3, y + Draw.CellHeight - 1) }, 1, FontColor)
	DrawRectangle(keyx, keyy, Draw.DetailWidth, Draw.CellHeight - 2, ARGB(Draw.Opacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3]))
	DrawTextA("("..GetKeyAsString(key)..")", Draw.FontSize, keyx + (Draw.DetailWidth / 2), keyy + ((Draw.CellHeight - 2) / 2), FontColor, "center", "center")
end
function DrawSliderSprite(x, y, text, value, cursor)
	local valuex = x + Draw.Width - (Draw.Width - Draw.Row3) - Draw.DetailWidth - 2
	local valuey = y + 1
	local sliderx = x + Draw.Row3 - 1
	local slidery = y + 1
	--DrawRectangle(x, y, Draw.Width, Draw.CellHeight, FontColor)
	DrawRectangle(x + 1, y + 1, Draw.Width - 2, Draw.CellHeight - 2, Background)
	DrawTextA(text, Draw.FontSize, x + (Draw.Padding * 2), y + (Draw.CellHeight / 2), FontColor, nil, "center")
	--DrawLines2({ D3DXVECTOR2(x + Draw.Width - (Draw.Width - Draw.Row3) - Draw.DetailWidth - 3, y + 1), D3DXVECTOR2(x + Draw.Width - (Draw.Width - Draw.Row3) - Draw.DetailWidth - 3, y + Draw.CellHeight - 1) }, 1, FontColor)
	DrawRectangle(valuex, valuey, Draw.DetailWidth, Draw.CellHeight - 2, ARGB(Draw.Opacity, Colors.Gray[1], Colors.Gray[2], Colors.Gray[3]))
	DrawTextA(tostring(value), Draw.FontSize, valuex + (Draw.DetailWidth / 2), valuey + ((Draw.CellHeight - 2) / 2), FontColor, "center", "center")
	--DrawLines2({ D3DXVECTOR2(x + Draw.Row3 - 2, y + 1), D3DXVECTOR2(x + Draw.Row3 - 2, y + Draw.CellHeight) }, 1, FontColor)
	DrawRectangle(sliderx, slidery, Draw.Width - Draw.Row3, Draw.CellHeight - 2, Foreground)
	DrawLines2({ D3DXVECTOR2(sliderx + (Draw.Padding * 2), slidery + ((Draw.CellHeight - 2) / 2)), D3DXVECTOR2(x + Draw.Width - (Draw.Padding * 2) - 2, slidery + ((Draw.CellHeight - 2) / 2)) }, 4, ARGB(200, Colors.Background[1], Colors.Background[2], Colors.Background[3]))
	DrawLines2({ D3DXVECTOR2(sliderx + (Draw.Padding * 2) + cursor, slidery + ((Draw.CellHeight - 2) / 2) - (Draw.Padding * 2)), D3DXVECTOR2(sliderx + (Draw.Padding * 2) + cursor, slidery + ((Draw.CellHeight - 2) / 2) + (Draw.Padding * 2)) }, 4, FontColor)
end
function DrawListSprite(x, y, text, currentOption)
    local optionsx = x + Draw.Row3 - 1
	local optionsy = y + 1
	--DrawRectangle(x, y, Draw.Width, Draw.CellHeight, FontColor)
    --print("UsedDrawList!text =",text)
	--DrawRectangle(x + 1, y + 1, Draw.Width - 2, Draw.CellHeight - 2, Background)
	DrawTextA(text, Draw.FontSize, x + (Draw.Padding * 2), y + (Draw.CellHeight / 2), FontColor, nil, "center")
	--DrawLines2({ D3DXVECTOR2(x + Draw.Row3 - 2, y + 1), D3DXVECTOR2(x + Draw.Row3 - 2, y + Draw.CellHeight) }, 1, FontColor)
	DrawRectangle(optionsx, optionsy, Draw.Width - Draw.Row3, Draw.CellHeight - 2, Foreground)
	local text = translationchk(currentOption)
	local maxWidth = (Draw.Width - Draw.Row3) * 0.8
	local textWidth = GetTextArea(text, Draw.FontSize).x
	if (textWidth > maxWidth) then
		text = text:sub(1, math.floor(text:len() * maxWidth / textWidth))
		if (text:sub(text:len(), text:len()) == " ") then
			text = text:sub(1, text:len() - 1)
		end
		text = text.."..."
	end
	DrawTextA(text, Draw.FontSize, optionsx + ((Draw.Width - Draw.Row3) / 2), optionsy + ((Draw.CellHeight - 2) / 2), FontColor, "center", "center")
end
function DrawListDropDownSprite(x, y, index, listTable)
	local width = 0
	local height = 1
    --print("UsedDrawListDropDown!text =",text)
	for i = 1, #listTable do
		width = math.max(width, GetTextArea(listTable[i], Draw.FontSize).x)
		height = height + Draw.CellHeight - 1
	end
	width = width + (Draw.Padding * 6)
	--DrawRectangle(x, y, width, height, FontColor)
	DrawRectangle(x + 1, y + 1, width - 2, height - 2, Background)
	for i = 1, #listTable do
		local optiony = y + 1 + ((Draw.CellHeight - 1) * (i - 1))
        local trtext = translationchk(listTable[i])
		DrawRectangle(x + 1, optiony, width - 2, Draw.CellHeight - 2, (index == i) and ARGB(200, 255, 0, 0) or Background)
		DrawTextA(trtext, Draw.FontSize, x + (Draw.Padding * 2), optiony + ((Draw.CellHeight - 2) / 2), FontColor, nil, "center")
		if (i < #listTable) then
			--DrawLines2({ D3DXVECTOR2(x + 1, optiony + Draw.CellHeight - 2), D3DXVECTOR2(x + width - 1, optiony + Draw.CellHeight - 2) }, 1, FontColor)
		end
	end
end

function _G.scriptConfig:__init(header, name, parent)
	if (parent) then
		self._parent = parent
	else
		InitializeConfig(name)
		LoadConfig()
	end
	self.header = header
	self.name = name
    --print("configheader:",header)
    --WriteFile(('["'.. header ..'"]'.. ' = '.. '" ",').."\n", SCRIPT_PATH .. "results.txt","a")
    translateheaderchk(header)
	self._param = { }
	self._subInstances = { }
	self._tsInstances = { }
    self._permaShow = { }
	self._sprite1 = nil
	self._sprite2 = nil
	self._subMenuIndex = 0
	self._list = 0
	self._x = parent and (parent._x + Draw.Width) or Draw.x + Draw.Width
	self._y = 0
	self._y1 = 0
	self._height = Draw.HeaderHeight
    self._slice = false
	if (parent) then
		parent._subInstances[#parent._subInstances + 1] = self
	elseif (name ~= "MainTargetSelector") then
		Instances[#Instances + 1] = self
	end
end

function _G.scriptConfig:OnDraw()
	self._x = (self._parent and (self._parent._x + Draw.Width) or Draw.x + Draw.Width) - 1
	if (self._slice and SliceInstance) then
		local cursorX = math.min(math.max(0, GetCursorPos().x - self._x - Draw.Row3), Draw.Width - Draw.Row3)
		self[self._param[self._slice].var] = math.round(self._param[self._slice].min + cursorX / (Draw.Width - Draw.Row3) * (self._param[self._slice].max - self._param[self._slice].min), self._param[self._slice].idc)
	end
	self._y = Draw.y
	DrawHeaderSprite(self._x, self._y, ChangingKey and ChangingKeyVariable and ChangingKeyInstance and (ChangingKeyInstance.name == self.name) and "Press new key for: "..self._param[ChangingKeyVariable].text or self.header, #self._subInstances + #self._param)
	self._y = self._y + Draw.HeaderHeight - 1
	for i = 1, #self._subInstances do
		local variable = self._subInstances[i].name
		local selected = (self._subMenuIndex == i)
		self._subInstances[i]._y1 = self._y
            --print("self subinstances:",self._subInstances[i])
		DrawMenuSprite(self._x, self._y, self._subInstances[i].header, selected)
		self._y = self._y + Draw.CellHeight - 1
		if (selected) then
			self._subInstances[i]:OnDraw()
		end
	end
	for i = 1, #self._param do
		self._param[i]._y1 = self._y
		local var = self[self._param[i].var]
        local trantext
        --print("start to draw param:",self._param[i].text)
        if(self._param[i].text ~= nil and self._param[i].text ~= "") then            
        --print("self param text:",self._param[i].text)
        trantext = translationchk(self._param[i].text) 
        else
        trantext = self._param[i].text
        end
        --print(self._param)
        --[[if(type(self._param[i].listTable) ~= nil and self._param[i].listTable ~= nil) then
        print(self._param[i].listTable[var])
        end]]--
		if (self._param[i].pType == SCRIPT_PARAM_ONOFF) then
			DrawToggleSprite(self._x, self._y, trantext, var)
		elseif (self._param[i].pType == SCRIPT_PARAM_INFO) then
            DrawInfoSprite(self._x, self._y, trantext, var)
		elseif (self._param[i].pType == SCRIPT_PARAM_COLOR) then
			DrawColorSprite(self._x, self._y, trantext, var)
		elseif (self._param[i].pType == SCRIPT_PARAM_SLICE) then
			self._param[i].cursor = (var - self._param[i].min) / (self._param[i].max - self._param[i].min) * ((Draw.Width - Draw.Row3) - (Draw.Padding * 4))
            --print(self._param[i].cursor)
			DrawSliderSprite(self._x, self._y, trantext, var, self._param[i].cursor)
		elseif ((self._param[i].pType == SCRIPT_PARAM_ONKEYDOWN) or (self._param[i].pType == SCRIPT_PARAM_ONKEYTOGGLE)) then
			DrawKeyToggleSprite(self._x, self._y, trantext, var, self._param[i].key)
		elseif (self._param[i].pType == SCRIPT_PARAM_LIST) then
			DrawListSprite(self._x, self._y, trantext, self._param[i].listTable[var])
			if (i == self._list) then
				local cursorY = math.min(GetCursorPos().y - self._y, Draw.CellHeight * (self._param[i].max))
				if (cursorY >= 0) then
					self[self._param[i].var] = math.min(math.round(self._param[i].min + cursorY / ((Draw.CellHeight - 4) * (self._param[i].max)) * (self._param[i].max - self._param[i].min)), #self._param[i].listTable)
				end
				DrawListDropDownSprite(self._x + Draw.Width - 1, self._y, self[self._param[i].var], self._param[i].listTable)
			end
		else
			PrintLocal("Unable to draw param type '"..self._param[i].pType.."'!", true)
		end
		self._y = self._y + Draw.CellHeight - 1
	end
	self._height = self._y - Draw.y
end
function _G.scriptConfig:OnWndMsg()
	for i = 1, #self._subInstances do
		if (CursorIsUnder(self._x, self._subInstances[i]._y1, Draw.Width, Draw.CellHeight)) then
			if (i == self._subMenuIndex) then
				self._subMenuIndex = 0
			else
				self._subMenuIndex = i
			end
			return
		end
	end
	for i = 1, #self._param do
		local param = self._param[i]
		if ((param.pType == SCRIPT_PARAM_ONKEYDOWN) or (param.pType == SCRIPT_PARAM_ONKEYTOGGLE)) then
			if (CursorIsUnder(self._x + Draw.Width - (Draw.Width - Draw.Row3) - Draw.DetailWidth - 2, param._y1, Draw.Width, Draw.CellHeight)) then
				ChangingKey = true
				ChangingKeyVariable = i
				ChangingKeyMenu = true
				ChangingKeyInstance = self
				self:ResetSubIndexes()
				return
			end
		end
		if (not changed and ((param.pType == SCRIPT_PARAM_ONOFF) or (param.pType == SCRIPT_PARAM_ONKEYTOGGLE))) then
			if (CursorIsUnder(self._x + Draw.Row3 - 1, param._y1, Draw.Width, Draw.CellHeight)) then
				self[param.var] = not self[param.var]
				self:save()
				self:ResetSubIndexes()
				return
			end
		end
		if (not changed and (param.pType == SCRIPT_PARAM_SLICE)) then
			if (CursorIsUnder(self._x + Draw.Row3 - 1, param._y1, Draw.Width, Draw.CellHeight)) then
				self._slice = i
				SliceInstance = self
				self:ResetSubIndexes()
				return
			end
		end
		if (not changed and (param.pType == SCRIPT_PARAM_LIST)) then
			if (CursorIsUnder(self._x + Draw.Row3 - 1, param._y1, Draw.Width, Draw.CellHeight)) then
				self._list = i
				ListInstance = self
				self:ResetSubIndexes()
				return
			end
		end
		if (not changed and (param.pType == SCRIPT_PARAM_COLOR)) then
			if (CursorIsUnder(self._x + Draw.Row3 - 1, param._y1, Draw.Width, Draw.CellHeight)) then
				__CP(nil, nil, self[param.var][1], self[param.var][2], self[param.var][3], self[param.var][4], self[param.var])
				self:save()
				self:ResetSubIndexes()
			end
		end
	end
end
function _G.scriptConfig:addParam(variable, text, ptype, value, param1, param2, param3)
	local newParam = {
		var = variable,
		text = text,
		pType = ptype,
		_y1 = self._y,
	}
    --print("param text:",text)
    --[[if(text ~= "") then
    WriteFile(('["'.. text ..'"]'.. ' = '.. '" ",').."\n", SCRIPT_PATH .. "results.txt","a")
    end]]--
	if ((ptype == SCRIPT_PARAM_ONKEYDOWN) or (ptype == SCRIPT_PARAM_ONKEYTOGGLE)) then
        newParam.key = param1
    elseif (ptype == SCRIPT_PARAM_SLICE) then
        newParam.min = param1
        newParam.max = param2
        newParam.idc = param3 or 0
        newParam.cursor = 0
    elseif (ptype == SCRIPT_PARAM_LIST) then
        
        --[[for i,v in pairs(param1) do
            print("param list:",param1)
            WriteFile(('["'.. v ..'"]'.. ' = '.. '" ",').."\n", SCRIPT_PATH .. "results.txt","a")
        end]]--

        newParam.listTable = param1
        newParam.min = 1
        newParam.max = #param1
        newParam.cursor = 0
	end
	local index = #self._param + 1
    self[variable] = value
	self._param[index] = newParam
	self._height = self._height + Draw.CellHeight
    SaveMaster()
	self:load()
end
function _G.scriptConfig:load()
    local config = LoadSettings(self.name)
    for var, value in pairs(config) do
        if (type(value) == "table") then
            if (self[var]) then
				self[var] = SensitiveMerge(self[var], value)
			end
        else
			self[var] = value
        end
    end
end
function _G.scriptConfig:save()
    local content = { }
    content._param = content._param or { }
	for i = 1, #self._param do
		local param = self._param[i]
        if (param.pType ~= SCRIPT_PARAM_INFO) then
            content[param.var] = self[param.var]
            if ((param.pType == SCRIPT_PARAM_ONKEYDOWN) or (param.pType == SCRIPT_PARAM_ONKEYTOGGLE)) then
                content._param[i] = { key = param.key }
            end
        end
    end
    content._tsInstances = content._tsInstances or { }
	for i = 1, #self._tsInstances do
        content._tsInstances[i] = { mode = self._tsInstances[i].mode }
    end
    SaveSettings(self.name, content)
end
function _G.scriptConfig:addTS(tsInstance)
    if (not SelectorConfig) then
		SelectorConfig = scriptConfig("Target Selector", "MainTargetSelector")
		InitializeGameHeroes()
		if (#GameHeroes == 0) then
			SelectorConfig:addParam("Note", "No enemy heroes were found!", SCRIPT_PARAM_INFO, "")
		else
			for i = 1, #GameHeroes do
				local name = GameHeroes[i].hero.charName
				SelectorConfig:addParam(name, name, SCRIPT_PARAM_SLICE, GameHeroes[i].priority, 0, 5)
				SelectorConfig:setCallback(name, function(value)
					if (value == 0) then
						Global.TS_Ignore(name, true)
					else
						Global.TS_SetHeroPriority(math.min(value, GameEnemyCount), name, true)
					end
				end)
				if (SelectorConfig[name] == 0) then
					Global.TS_Ignore(name, true)
				else
					Global.TS_SetHeroPriority(math.min(SelectorConfig[name], GameEnemyCount), name, true)
				end
			end
		end
	end
	local index = #self._tsInstances + 1
	self._tsInstances[index] = tsInstance
	self:addParam("TSMode", "Target Selector Mode:", SCRIPT_PARAM_LIST, tsInstance.mode, { "Low HP", "Most AP", "Most AD", "Less Cast", "Near Mouse", "Priority", "Low HP Priority", "Less Cast Priority", "Dead", "Closest" })
	self:setCallback("TSMode", function(mode)
		self._tsInstances[index].mode = mode
	end)
	self._tsInstances[index]._config = self.TSMode
    SaveMaster()
    self:load()
end
function _G.scriptConfig:permaShow(variable)
	for i = 1, #self._param do
        if (self._param[i].var == variable) then
			self._permaShow[#self._permaShow + 1] = variable
            --print("index:",index)
        end
    --print("self perma:",self._permaShow)
    end
    SaveMaster()
end

function _G.TS_SetFocus(target, enemyTeam)
	local target = GetGameHero(target)
	if (target and target.team and (target.team ~= myHero.team)) then
		for i = 1, #GameHeroes do
			if (GameHeroes[i].hero.networkID == target.networkID) then
				GameHeroes[i].priority = 1
			else
				GameHeroes[i].priority = GameEnemyCount
			end
			if (SelectorConfig) then
				SelectorConfig[GameHeroes[i].hero.charName] = GameHeroes[i].priority
			end
		end
	end
	Global.TS_SetFocus(target, enemyTeam)
end
function _G.TS_SetHeroPriority(priority, target, enemyTeam)
	local index = GetGameHeroIndex(target)
	if (index) then
		local oldPriority = GameHeroes[index].priority
		if ((oldPriority == nil) or (oldPriority == priority)) then return end
		for i = 1, #GameHeroes do
			if (i == index) then
				GameHeroes[i].priority = priority
			else
				GameHeroes[i].priority = GameEnemyCount
			end
			if (SelectorConfig) then
				SelectorConfig[GameHeroes[i].hero.charName] = GameHeroes[i].priority
			end
		end
	end
	Global.TS_SetHeroPriority(priority, target, enemyTeam)
end
function _G.TS_Ignore(target, enemyTeam)
    local target = GetGameHero(target, "TS_Ignore")
    if (target and target.valid and (target.type == "obj_AI_Hero") and (target.team ~= player.team)) then
        for i = 1, #GameHeroes do
            if (GameHeroes[i].hero.networkID == target.networkID) then
                GameHeroes[i].ignore = not GameHeroes[i].ignore
				if (SelectorConfig) then
					SelectorConfig[GameHeroes[i].hero.charName] = 0
				end
                break
            end
        end
    end
	Global.TS_Ignore(target, enemyTeam)
end

local tranTable = {
["Evadeee"] = "躲避",
["Enemy Spells"] = "敌人技能",
["Evading Spells"] = "躲避技能",
["Advanced Settings"] = "高级设置",
["Traps"] = "陷阱",
["Buffs"] = "增益",
["Humanizer"] = "拟人化",
["Combat/Chase Mode"] = "连招/追击模式",
["Controls"] = "控制",
["Visual Settings"] = "视觉设置",
["Performance Settings"] = "性能设置",
["Q - Decisive Strike"] = "Q技能",
["W - Courage"] = "W技能",
["Summoner Spell: Flash"] = "召唤师技能：闪现",
["Item: Youmuu's Ghostblade"] = "幽梦之灵",
["Item: Locket of the Iron Solari"] = "钢铁烈阳之匣",
["Item: Zhonya / Wooglet"] = "中娅沙漏",
["Item: Shurelya / Talisman"] = "舒瑞亚的狂想曲/护符",
["Dodge/Cross Settings"] = "躲避或穿过技能设置",
["Evading Settings"] = "躲避设置",
["Collision Settings"] = "碰撞设置",
["Script Interaction (API)"] = "脚本互动（API）",
["Reset Settings"] = "重置设置",
["Nidalee and Teemo Traps"] = "豹女和提莫的陷阱",
["Caitlyn and Jinx Traps"] = "女警和金克斯的陷阱",
["Banshee's Veil"] = "女妖面纱",
["Delays"] = "延迟",
["Movement"] = "移动",
["Anchors"] = "定位",
["Evading"] = "躲避",
["Dashes and blinks"] = "瞬移和突进",
["Special Actions"] = "特殊动作",
["Override - Anchor Settings"] = "覆盖定位设置",
["Override - Humanizer"] = "覆盖拟人化",
["League of Legends Version"] = "英雄联盟版本",
["Danger Level: "] = "危险等级",
["Danger level info:"] = "危险等级信息",
["    0 - Off"] = "0 - 关闭",
["    1 - Use vs Normal Skillshots"] = "1 - 遇到一般技能攻击使用",
["2..4 - Use vs More Dangerous / CC"] = "2..4 - 遇到较危险技能及团控使用",
["    5 - Use vs Very Dangerous"] = "5 - 遇到非常危险技能时使用",
["Use after-move delay in calcs"] = "在计算的延迟后移动",
["Extra hit box radius: "] = "额外的弹道直径",
["Evading points max distance"] = "改变潜在安全躲避地点的最大距离",
["Evade only spells closer than:"] = "只在法术距离接近值的时候躲避",
["Global skillshots as exception"] = "躲避全球大招时忽略其他设置",
["Attempt to DODGE linear spells"] = "尝试在直线弹道法术内的时候躲避",
["Attempt to CROSS linear spells"] = "尝试在直线弹道法术外时安全穿过",
["Attempt to DODGE rectangular spells"] = "尝试在矩形弹道法术内的时候躲避",
["Attempt to CROSS rectangular spells"] = "尝试在矩形弹道法术外时安全穿过",
["Attempt to DODGE circular spells"] = "尝试在圆形弹道法术内的时候躲避",
["Attempt to CROSS circular spells"] = "尝试在圆形弹道法术外时安全穿过",
["Attempt to DODGE triangular spells"] = "尝试在三角形弹道法术内的时候躲避",
["Attempt to CROSS triangular spells"] = "尝试在三角形弹道法术外时安全穿过",
["Attempt to DODGE conic spells"] = "尝试在锥形弹道法术内的时候躲避",
["Attempt to CROSS conic spells"] = "尝试在锥形弹道法术外时安全穿过",
["Attempt to dodge arc spells"] = "尝试在锥形弹道法术内的时候躲避",
["Collision for minions"] = "小兵的碰撞",
["Collision for heroes"] = "英雄的碰撞",
["Here you can allow other scripts"] = "这里你可以使用其他脚本",
["to enable/disable and control Evadeee."] = "启用/禁用和控制EVADEEE",
["Allow enabling/disabling evading"] = "允许启用/禁用躲避",
["Allow enabling/disabling Bot Mode"] = "允许启用/禁用机器人模式",
["WARNING:"] = "警告",
["By switching this ON/OFF - Evadeee"] = "转换开和关",
["will reset all your settings:"] = "重置所有设定",
["Restore default settings"] = "恢复默认设置",
["Enabled"] = "启用",
["Ignore with dangerLevel >="] = "忽略危险等级",
["    1 - Use vs everything"] = "1 - 任何时候都使用",
["2..4 - Use only vs More Dangerous / CC"] = "2..4 - 仅在较危险技能及团控使用",
["    5 - Use only vs Very Dangerous"] = "5 - 仅在遇到非常危险技能时使用",
["Delay before evading (ms)"] = "躲避前延迟（毫秒）",
["Ignore evading delay if you move"] = "如果你在移动忽略躲避前延迟",
["Server Tick Buffer (ms)"] = "服务器缓存计时（毫秒）",
["Pathfinding:"] = "寻路",
["Move extra distance after evade"] = "躲避后移动额外的距离",
["Randomize that extra distance"] = "随机生成躲避后移额外的距离值",
["Juke when entering danger area"] = "假装进入危险区域",
["Move this distance during jukes"] = "假动作距敌人法术的距离",
["Allow changing path while evading"] = "允许在躲避时改变路线",
["Delay between each path change"] = "改变路线时延迟的时间",
["\"Smooth\" Diagonal Evading"] = "平滑斜线躲避",
["Max Range Limit:"] = "最远距离限制",
["Anchor Type:"] = "定位方法",
["Safe Evade (Ignore Anchor):"] = "安全躲避（忽略定位）",
["Safe evade from enemy team"] = "安全躲避敌人",
["Do that with X enemies nearby: "] = "在附近有X名敌人时",
["How far enemies should be: "] = "对敌人的警戒距离",
["Safe evade during Panic Mode"] = "在使用强制闪现模式时安全躲避",
["Explanation (Safe Evade):"] = "解释（安全躲避）",
["This setting will force evade in the"] = "这个设置会朝着远离",
["direction away from enemy team."] = "敌人移动方向强制躲避",
["This will ignore your main anchor"] = "这会忽略你的主定位",
["only when there are enemies nearby."] = "只在附近有敌人时",
["Attempt to dodge spells from FoW"] = "尝试躲避从没有视野的地方攻击你的法术",
["Dodge if your HP <= X%: "] = "在你的血量小于X%时躲避",
["Dodge <= X normal spells..."] =	 "在小于等于X个普通法术攻击你时躲避",
["... in <= X seconds"] =	 "在小于等于X秒内",
["Disable evading by idling X sec:"] = "在你挂机X秒后自动禁用躲避",
["Better dodging near walls"] = "墙附近更好的躲避路线",
["Better dodging near turrets"] = "敌人防御塔附近更好的躲避路线",
["Handling danger blinks and dashes:"] = "瞬移和突进时躲避危险",
["Angle of the modified cast area"] = "躲避危险的角度",
["Blink/flash over missile"] = "瞬移或突进到小兵身边躲避攻击",
["Delay between dashes/blinks (ms):"] = "瞬移或猛冲的延迟(ms)",
["Dash/Blink/Flash Mode:"] = "瞬移或突进或闪现的模式",
["Note:"] = "注意",
["While activated, this mode overrides some of"] = "当你激活这个功能时可能会覆盖",
["the settings, which you can modify here."] = "一些你其他的在这里修改的设置",
["Usually this is used together with SBTW."] = "一般情况下和自动走砍开关",
["To change the hotkey go to \"Controls\"."] = "在控制设置中设置热键",
["Dodge \"Only Dangerous\" spells"] = "仅躲避危险技能",
["Evade towards anchor only"] = "躲避时只向前定位",
["Ignore circular spells"] = "忽略圆形技能",
["Use dashes more often"] = "更多的使用瞬移",
["To change controls just click here   \\/"] = "点这里来改变控制设置",
["Evading        | Hold"] = "按住躲避",
["Evading        | Toggle"] = "按下躲避开关启用直到在次按下停止",
["Combat/Chase Mode | Hold 1"] = "战斗和追击模式按键1",
["Combat/Chase Mode | Hold 2"] = "战斗和追击模式按键2",
["Combat/Chase Mode | Toggle"] = "战斗和追击模式开关",
["Panic Mode     | Refresh"] = "惊恐模式刷新",
["Panic Mode Duration (seconds)"] = "惊恐模式时间（秒）",
["Remove spells with doubleclick"] = "双击移除技能绘图",
["Quick Menu:"] = "快捷菜单",
["Open Quick Menu with LMB and:"] = "用鼠标左键和:开启快速菜单",
["Replace Panic Mode"] = "替换惊恐模式",
["Explanation (Quick Menu):"] = "说明（快捷菜单）",
["If you choose 1 key for Quick Menu"] = "如果你选择按键1作为快捷键",
["then make sure it doesn't overlap"] = "菜单快捷键，请确认不会和",
["with League's Quick Ping menu!"] = "游戏显示PING的快捷键重叠",
["Draw Skillshots"] = "技能绘图表示",
["Spell area line width"] = "技能区域线的粗细",
["Spell area color"] = "技能区域颜色",
["Draw Dangerous Area"] = "危险区域绘图表示",
["Danger area line width"] = "危险区域线的粗细",
["Danger area color"] = "危险区域颜色",
["Display Evading Direction"] = "显示躲避方向",
["Show \"Doubleclick to remove!\""] = "显示双击移除（图）",
["Display Evadeee status"] = "显示EVADEEE状态",
["Status display Y offset"] = "状态显示纵轴并列",
["Status display text size"] = "状态显示字体大小",
["Print Evadeee status"] = "显示EVADEEE状态",
["Show Priority Menu"] = "显示优先菜单",
["Priority Menu X offset"] = "优先菜单横轴并列",
["Preset"] = "预设",
["Change this on your own risk:"] = "如果改变此项风险自负",
["Update Frequency [Times per sec]"] = "刷新数据频率次/秒",
-----------------SAC-----------------------
["Script Version"] = "脚本版本",
["Generate Support Report"] = "生成援助报告",
["Clear Chat When Enabled"] = "当开启时清空对话框",
["Show Click Marker (Broken)"] = "功能已坏",
["Click Marker Colour"] = "点击预测颜色",
["Minimum Time Between Clicks"] = "点击最小间隔",
["Maximum Time Between Clicks"] = "点击最大间隔",
["translation button"] = "翻译键",
["Harass mode"] = "骚扰模式",
["Cast Mode"] = "施法模式",
["Collision buffer"] = "碰撞体积",
["Normal minions"] = "一般小兵",
["Jungle minions"] = "野怪",
["Others"] = "其他",
["Check if minions are about to die"] = "如果小兵快死了点击",
["Check collision at the unit pos"] = "检查物体间位置碰撞",
["Check collision at the cast pos"] = "检查施法位置碰撞",
["Check collision at the predicted pos"] = "检查预计法术位置碰撞",
["Enable debug"] = "开启排除故障模式",
["Show collision"] = "显示碰撞",
["Version"] = "版本",
["No enemy heroes were found!"] = "未发现敌方英雄",
["Target Selector Mode:"] = "目标选择模式",
["*LessCastPriority Recommended"] = "推荐的最不要攻击的有限度",
["Hold Left Click Action"] = "按住鼠标左键的动作",
["Focus Selected Target"] = "聚焦选中的目标",
["Attack Selected Buildings"] = "攻击选中的建筑",
["Disable Toggle Mode On Recall"] = "在回城时禁用开关模式",
["Disable Toggle Mode On Right Click"] = "鼠标右键点击禁用开关模式",
["Mouse Over Hero To Stop Move"] = "鼠标悬停在英雄上方时停止移动",
["      Against Champions"] = "与你战斗的地方英雄",
["Use In Auto Carry"] = "在自动连招输出模式使用",
["Use In Mixed Mode"] = "在混合模式使用",
["Use In Lane Clear"] = "在清线模式使用",
["Killsteal"] = "抢人头",
["Auto Carry minimum % mana"] = "如果魔法少于%则不开启自动连招输出模式",
["Mixed Mode minimum % mana"] = "如果魔法少于%则不开启混合模式",
["Lane Clear minimum % mana"] = "如果魔法少于%则不开启清线模式",
["      Skill Farm"] = "技能刷兵",
["Lane Clear Farm"] = "清线刷兵",
["Jungle Clear"] = "刷野",
["TowerFarm"] = "塔下刷兵?",
["Skill Farm Min Mana"] = "使用技能刷兵魔法不低于",
["(when enabled)"] = "当启用时",
["Stick To Target"] = "紧盯目标",
["   Stick To Target will mirror "] = "紧盯目标输出",
["   enemy waypoints so you stick"] = "跟紧敌人行进路线",
["   to him like glue!"] = "就像盖伦贴脸打",
["Outer Turret Farm"] = "外塔刷兵",
["Inner Turret Farm"] = "内塔刷兵",
["Inhib Turret Farm"] = "水晶刷兵",
["Nexus Turret Farm"] = "门牙刷兵",
["Lane Clear Method"] = "清线方式",
["Double-Edged Sword"] = "双刃剑天赋",
["Savagery"] = "野蛮天赋",
["Toggle mode (requires reload)"] = "开关模式（需要2XF9）",
["Movement Enabled"] = "允许移动",
["Attacks Enabled"] = "允许攻击",
["Anti-farm/harass (attack back)"] = "骚扰敌人补刀（反击）",
["Attack Enemies"] = "攻击敌人",
["Prioritise Last Hit Over Harass"] = "补刀优先于骚扰",
["Attack Wards"] = "攻击眼",
["           Main Hotkeys"] = "主要快捷键",
["Auto Carry"] = "自动连招攻击模式",
["Last Hit"] = "补刀模式",
["Mixed Mode"] = "混合模式",
["Lane Clear"] = "清线",
["           Other Hotkeys"] = "其他快捷键",
["Target Lock"] = "目标锁定",
["Enable/Disable Skill Farm"] = "开启或关闭技能刷兵",
["Lane Freeze (Default F1)"] = "F1下防守补刀",
["Support Mode (Default F6)"] = "辅助模式",
["Toggle Streaming Mode with F7"] = "F7开关滑动模式",
["Use Blade of the Ruined King"] = "使用破败",
["Use Bilgewater Cutlass"] = "使用比尔吉沃特弯刀",
["Use Hextech Gunblade"] = "使用海克斯科技枪刃",
["Use Frost Queens Claim"] = "使用冰霜女皇的指令",
["Use Talisman of Ascension"] = "使用飞升护符",
["Use Ravenous Hydra"] = "使用贪婪九头蛇",
["Use Tiamat"] = "使用提亚马特",
["Use Entropy"] = "使用冰霜战锤",
["Use Youmuu's Ghostblade"] = "使用幽梦之灵",
["Use Randuins Omen"] = "使用兰顿之兆",
["Use Muramana"] = "使用魔切",
["Save BotRK for max heal"] = "保留BotRK获得最大治疗",
["Use Muramana [Champions]"] = "对英雄使用魔切",
["Use Muramana [Minions]"] = "对小兵使用魔切",
["Use Tiamat/Hydra to last hit"] = "使用提亚马特或者九头蛇完成最后一击",
["Use Muramana [Jungle]"] = "对野怪使用魔切",
["Champion Range Circle"] = "英雄范围圆形图",
["Colour"] = "颜色",
["Circle Around Target"] = "目标圆形图",
["Draw Target Lock Circle"] = "显示目标锁定圆形图",
["Target Lock Colour"] = "目标锁定颜色",
["Target Lock Reminder Text"] = "目标锁定文字提示",
["Show Pet/Clone target scan range"] = "显示宠物/克隆目标扫描范围",
["Use Low FPS Circles"] = "使用低FPS圆",
["Show PermaShow box"] = "显示永久显示框",
["Show AA reminder on script load"] = "读取脚本时显示AA提醒",
["Enable Pet Orbwalking:"] = "开启宠物走砍",
["Tibbers"] = "火女提伯斯",
["Shaco's Clone"] = "小丑克隆",
["Target Style:"] = "目标方式",
["When To Orbwalk:"] = "什么时候走砍",
["Target Scan Range"] = "目标扫描范围",
["Push Lane In LaneClear"] = "在清线时使用推线模式",
["Delay Between Movements"] = "移动间隔延迟",
["Randomize Delay"] = "随机延迟",
["Humanize Movement"] = "拟人化移动",
["Last Hit Adjustment:"] = "补刀调整",
["Adjustment Amount:"] = "调整量",
["Animation Cancel Adjustment:"] = "普攻动画取消调整",
["Mouse Over Hero AA Cancel Fix:"] = "鼠标悬停在英雄上方取消普攻",
["Mouse Over Hero Stop Distance:"] = "鼠标悬停在英雄上方停止距离",
["Server Delay (don't touch): 100ms"] = "服务器延迟100毫秒",
["Disable AA Cancel Detection"] = "禁用普攻取消侦测",
["By Role:"] = "按角色",
["    Draw ADC"] = "ADC绘图",
["    Draw AP Carry"] = "AP绘图",
["    Draw Support"] = "辅助绘图",
["    Draw Bruiser"] = "刺客绘图",
["    Draw Tank"] = "坦克绘图",
["By Champion:"] = "按英雄",
["Modify Minion Health Bars"] = "调整小兵血条",
["Maximum Health Bars To Modify"] = "最大血条调整",
["Draw Last Hit Arrows"] = "最后一击图形提醒",
["Always Draw Modified Health Bars"] = "一直显示血条调整",
["Always Draw Last Hit Arrows"] = "一直显示最后一击图形提醒",
["Sida's Auto Carry"] = "Sida走砍",
["Setup"] = "设置",
["Hotkeys"] = "快捷键",
["Configuration"] = "配置",
["Target Selector"] = "目标选择",
["Skills"] = "技能",
["Items"] = "物品",
["Farming"] = "刷兵",
["Melee"] = "团战",
["Drawing"] = "绘图",
["Pets/Clones"] = "宠物/克隆",
["Streaming Mode"] = "开关滑动模式",
["Advanced / Fixes"] = "高级/调整",
["VPrediction"] = "V预判",
["Collision"] = "碰撞体积",
["Developers"] = "开发者",
["Circles"] = "圆圈",
["Enemy AA Range Circles"] = "敌人普攻范围圈",
["Minion Drawing"] = "小兵标记",
["Other"] = "其他",
["Auto Carry Mode"] = "自动连招攻击",
["Last Hit Mode"] = "最后一击补刀模式",
["Lane Clear Mode"] = "清线模式",
["Auto Carry Items"] = "自动连招使用的物品",
["Mixed Mode Items"] = "混合模式使用的物品",
["Lane Clear Items"] = "清线使用的物品",
["Q (Decisive Strike)"] = "Q",
["E (Judgment)"] = "E",
["R (Demacian Justice)"] = "R",
["Masteries"] = "天赋",
["Damage Prediction Settings"] = "伤害预估设置",
["Turret Farm"] = "塔下刷兵",
["Activator"] = "活化剂",
["Activator Version : "] = "活化剂版本号",
["Debug Mode Setting"] = "调试模式设置",
["Zhonya Debug"] = "调试中亚",
["Debug Mode (shields,zhonya): "] = "调试模式(护盾,中亚)",
["Font Size Zhonya"] = "中亚字体大小",
["X Axis Draw Zhonya Debug"] = "中亚显示X轴位置",
["Y Axis Draw Zhonya Debug"] = "中亚显示Y轴位置",
["QSS Debug "] = "水银饰带调试",
["Debug Mode (qss): "] = "调试模式(水银饰带)",
["Font Size QSS"] = "水银饰带字体大小",
["X Axis Draw QSS Debug"] = "水银饰带显示X轴位置",
["Y Axis Draw QSS Debug"] = "水银饰带显示Y轴位置",
["Cleanse Debug"] = "净化调试",
["Debug Mode (Cleanse): "] = "调试模式(净化)",
["Font Size Cleanse"] = "净化字体大小",
["X Axis Draw Cleanse Debug"] = "净化显示X轴位置",
["Y Axis Draw Cleanse Debug"] = "净化显示Y轴位置",
["Mikael Debug"] = "坩埚调试",
["Debug Mode (Mikael): "] = "调试模式(坩埚)",
["Font Size Mikael"] = "坩埚字体大小",
["X Axis Draw Mikael Debug"] = "坩埚显示X轴位置",
["Y Axis Draw Mikael Debug"] = "坩埚显示Y轴位置",
["Tower Damage"] = "防御塔伤害",
["Calculate Tower Damage"] = "计算防御塔伤害",
["Auto Spells"] = "自动使用技能",
["Auto Shield Spells"] = "自动护盾技能",
["Use Auto Shield Spells"] = "使用自动护盾技能",
["Max percent of hp"] = "最大生命值百分比",
["Shield Ally Oriana"] = "对奥利安娜使用护盾",
["Auto Pot Settings"] = "自动药水设置",
["Use Auto Pots"] = "使用自动药水",
["Use Health Pots"] = "自动吃血瓶",
["Use Mana Pots"] = "自动吃蓝瓶",
["Use Flask"] = "自动吃魔瓶",
["Use Biscuit"] = "自动吃饼干",
["Min Health Percent"] = "最小生命值百分比",
["Health Lost Percent"] = "损失生命值百分比",
["Min Mana Percent"] = "最小蓝量百分比",
["Min Flask Health Percent"] = "魔瓶-最小生命值百分比",
["Min Flask Mana Percent"] = "魔瓶-最小蓝量百分比",
["Offensive Items Settings"] = "进攻物品设置",
["Button Mode"] = "按键模式",
["Use Button Mode"] = "使用按键模式",
["Button Mode Key"] = "按键",
["AP Items"] = "AP物品",
["Use AP Items"] = "使用AP物品",
["Use Bilgewater Cutlass"] = "使用比尔吉沃特弯刀",
["Use Blackfire Torch"] = "使用黯炎火炬",
["Use Deathfire Grasp"] = "使用冥火之拥",
["Use Hextech Gunblade"] = "使用海克斯科技枪刃",
["Use Twin Shadows"] = "使用双生暗影",
["Use Odyn's Veil"] = "使用奥戴恩的面杀",
["AP Item Mode: "] = "AP物品模式",
["Burst Mode"] = "爆发模式",
["Combo Mode"] = "连招模式",
["KS Mode"] = "抢人头模式",
["AD Items"] = "AD物品",
["Use AD Items On Auto Attack"] = "在平A的时候使用AD物品",
["Use AD Items"] = "使用AD物品",
["Use Blade of the Ruined King"] = "使用破败王者之刃",
["Use Entropy"] = "使用冰霜战锤",
["Use Ravenous Hydra"] = "使用九头蛇",
["Use Sword of the Divine"] = "使用神圣之剑",
["Use Tiamat"] = "使用提亚马特",
["Use Youmuu's Ghostblade"] = "使用幽梦之灵",
["Use Muramana"] = "使用魔切",
["Min Mana for Muramana"] = "使用魔切的最小蓝量",
["Minion Buff"] = "小兵增益",
["Use Banner of Command"] = "使用号令之旗",
["AD Item Mode: "] = "AD物品模式",
["Burst Mode"] = "爆发模式",
["Combo Mode"] = "连招模式",
["KS Mode"] = "抢人头模式",
["Defensive Items Settings"] = "防御物品设置",
["Cleanse Item Config"] = "净化设置",
["Stuns"] = "眩晕",
["Silences"] = "沉默",
["Taunts"] = "嘲讽",
["Fears"] = "恐惧",
["Charms"] = "魅惑",
["Blinds"] = "致盲",
["Roots"] = "禁锢",
["Disarms"] = "变形",
["Suppresses"] = "压制",
["Slows"] = "减速",
["Exhausts"] = "虚弱",
["Ignite"] = "点燃",
["Poison"] = "中毒",
["Shield Self"] = "自动护盾",
["Use Self Shield"] = "使用自动护盾",
["Use Seraph's Embrace"] = "使用炽天使之拥",
["Use Ohmwrecker"] = "使用干扰水晶",
["Min dmg percent"] = "最小伤害百分比",
["Zhonya/Wooglets Settings"] = "中亚/沃格勒特的巫师帽设置",
["Use Zhoynas"] = "使用中亚",
["Use Wooglet's Witchcap"] = "使用沃格勒特的巫师帽",
["Only Z/W Special Spells"] = "只对特定技能使用",
["Debuff Enemy"] = "对敌人使用减益效果",
["Use Debuff Enemy"] = "使用减益效果",
["Use Randuin's Omen"] = "兰顿之兆",
["Randuins Enemies in Range"] = "在范围内有X个敌人时使用兰顿",
["Use Frost Queen"] = "使用冰霜女皇的指令",
["Cleanse Self"] = "净化类物品",
["Use Self Item Cleanse"] = "使用净化类物品",
["Use Quicksilver Sash"] = "使用水银饰带",
["Use Mercurial Scimitar"] = "使用水银弯刀",
["Use Dervish Blade"] = "使用苦行僧之刃",
["Cleanse Dangerous Spells"] = "净化危险的技能",
["Cleanse Extreme Spells"] = "净化极端危险的技能",
["Min Spells to use"] = "最少拥有X种减益效果才使用",
["Debuff Duration Seconds"] = "减益效果持续时间",
["Shield/Boost Ally"] = "给友军使用护盾/加速",
["Use Support Items"] = "使用辅助物品",
["Use Locket of Iron Solari"] = "钢铁烈阳之匣",
["Locket of Iron Solari Life Saver"] = "生命值低于X时使用钢铁烈阳之匣",
["Use Talisman of Ascension"] = "飞升护符",
["Use Face of the Mountain"] = "山岳之容",
["Face of the Mountain Life Saver"] = "生命值低于X时使用山岳之容",
["Use Guardians Horn"] = "守护者的号角",
["Life Saving Health %"] = " 生命值低于X%",
["Mikael Cleanse"] = "米凯尔的坩埚",
["Use Mikael's Crucible"] = "使用坩埚",
["Mikaels cleanse on Ally"] = "对友军使用坩埚",
["Mikaels Life Saver"] = "生命低于X%时使用坩埚",
["Ally Saving Health %"] = "友军生命值低于X%",
["Self Saving Health %"] = "自己生命值低于X%",
["Min Spells to use"] = "最少拥有X种减益效果才使用",
["Set Debuff Duration"] = "设置减益效果持续时间",
["Champ Shield Config"] = "英雄护盾设置",
["Champ Cleanse Config"] = "英雄净化设置",
["Shield Ally Vayne"] = "对友军薇恩使用护盾",
["Cleanse Ally Vayne"] = "对友军薇恩使用净化",
["Show In Game"] = "在游戏中显示",
["Show Version #"] = "显示版本号",
["Show Auto Pots"] = "显示自动药水",
["Show Use Auto Pots"] = "显示使用自动药水",
["Show Use Health Pots"] = "显示自动血药",
["Show Use Mana Pots"] = "显示自动蓝药",
["Show Use Flask"] = "显示自动魔瓶",
["Show Offensive Items"] = "显示攻击型物品",
["Show Use AP Items"] = "显示使用AP物品",
["Show AP Item Mode"] = "显示AP物品模式",
["Show Use AD Items"] = "显示使用AD物品",
["Show AD Item Mode"] = "显示AD物品模式",
["Show Defensive Items"] = "显示防御物品",
["Show Use Self Shield Items"] = "显示对自己使用护盾类物品",
["Show Use Debuff Enemy"] = "显示对地方使用减益效果",
["Show Self Item Cleanse "] = "显示对自己使用净化",
["Show Use Support Items"] = "显示使用辅助物品",
["Show Use Ally Cleanse Items"] = "显示对友军使用净化类物品",
["Show Use Banner"] = "显示使用号令之旗",
["Show Use Zhonas"] = "显示使用中亚",
["Show Use Wooglets"] = "显示使用沃格勒特的巫师帽",
["Show Use Z/W Lifeaver"] = "显示使用中亚的触发生命值",
["Show Z/W Dangerous"] = "显示使用中亚的危险程度",
}
local SupportedScriptList = {
"Evadeee","Sida's Auto Carry","Activator"
}
function translationchk(text)
    assert(type(text) == "string","<string> expected for text")
    local text2
    --if(text == "text1") then text2 = "change the text" end
    --print("find the text:",text,"tranTable:",tranTable[text])
    for i ,v in pairs(tranTable) do
    if(tranTable[text] ~= nil) then 
    text2 = tranTable[text] 
    --text2 = text
    else
    text2 = text
    end
    end
    return text2
end
function translateheaderchk(header)
    for i ,v in pairs(SupportedScriptList) do
    if(v == header) then 
    PrintLocal(header.." loaded!")
    end
    end
end
function OnLoad()
	PrintLocal("Translator loaded successfully!")
    PrintLocal("by: leoxp,Have fun!")
end
function OnUnload()
	SaveMaster()
end

function PrintLocal(text, isError)
	PrintChat("<font color=\"#ff0000\">BoL Config Translater:</font> <font color=\"#"..(isError and "F78183" or "FFFFFF").."\">"..text.."</font>")
end

-- End of A1-Config.

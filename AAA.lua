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
	local text = ChangingKey and not ChangingKeyVariable and "Press new key for menu..." or "�ű�����"
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
["Evadeee"] = "���",
["Enemy Spells"] = "���˼���",
["Evading Spells"] = "��ܼ���",
["Advanced Settings"] = "�߼�����",
["Traps"] = "����",
["Buffs"] = "����",
["Humanizer"] = "���˻�",
["Combat/Chase Mode"] = "����/׷��ģʽ",
["Controls"] = "����",
["Visual Settings"] = "�Ӿ�����",
["Performance Settings"] = "��������",
["Q - Decisive Strike"] = "Q����",
["W - Courage"] = "W����",
["Summoner Spell: Flash"] = "�ٻ�ʦ���ܣ�����",
["Item: Youmuu's Ghostblade"] = "����֮��",
["Item: Locket of the Iron Solari"] = "��������֮ϻ",
["Item: Zhonya / Wooglet"] = "���ɳ©",
["Item: Shurelya / Talisman"] = "�����ǵĿ�����/����",
["Dodge/Cross Settings"] = "��ܻ򴩹���������",
["Evading Settings"] = "�������",
["Collision Settings"] = "��ײ����",
["Script Interaction (API)"] = "�ű�������API��",
["Reset Settings"] = "��������",
["Nidalee and Teemo Traps"] = "��Ů����Ī������",
["Caitlyn and Jinx Traps"] = "Ů���ͽ��˹������",
["Banshee's Veil"] = "Ů����ɴ",
["Delays"] = "�ӳ�",
["Movement"] = "�ƶ�",
["Anchors"] = "��λ",
["Evading"] = "���",
["Dashes and blinks"] = "˲�ƺ�ͻ��",
["Special Actions"] = "���⶯��",
["Override - Anchor Settings"] = "���Ƕ�λ����",
["Override - Humanizer"] = "�������˻�",
["League of Legends Version"] = "Ӣ�����˰汾",
["Danger Level: "] = "Σ�յȼ�",
["Danger level info:"] = "Σ�յȼ���Ϣ",
["    0 - Off"] = "0 - �ر�",
["    1 - Use vs Normal Skillshots"] = "1 - ����һ�㼼�ܹ���ʹ��",
["2..4 - Use vs More Dangerous / CC"] = "2..4 - ������Σ�ռ��ܼ��ſ�ʹ��",
["    5 - Use vs Very Dangerous"] = "5 - �����ǳ�Σ�ռ���ʱʹ��",
["Use after-move delay in calcs"] = "�ڼ�����ӳٺ��ƶ�",
["Extra hit box radius: "] = "����ĵ���ֱ��",
["Evading points max distance"] = "�ı�Ǳ�ڰ�ȫ��ܵص��������",
["Evade only spells closer than:"] = "ֻ�ڷ�������ӽ�ֵ��ʱ����",
["Global skillshots as exception"] = "���ȫ�����ʱ������������",
["Attempt to DODGE linear spells"] = "������ֱ�ߵ��������ڵ�ʱ����",
["Attempt to CROSS linear spells"] = "������ֱ�ߵ���������ʱ��ȫ����",
["Attempt to DODGE rectangular spells"] = "�����ھ��ε��������ڵ�ʱ����",
["Attempt to CROSS rectangular spells"] = "�����ھ��ε���������ʱ��ȫ����",
["Attempt to DODGE circular spells"] = "������Բ�ε��������ڵ�ʱ����",
["Attempt to CROSS circular spells"] = "������Բ�ε���������ʱ��ȫ����",
["Attempt to DODGE triangular spells"] = "�����������ε��������ڵ�ʱ����",
["Attempt to CROSS triangular spells"] = "�����������ε���������ʱ��ȫ����",
["Attempt to DODGE conic spells"] = "������׶�ε��������ڵ�ʱ����",
["Attempt to CROSS conic spells"] = "������׶�ε���������ʱ��ȫ����",
["Attempt to dodge arc spells"] = "������׶�ε��������ڵ�ʱ����",
["Collision for minions"] = "С������ײ",
["Collision for heroes"] = "Ӣ�۵���ײ",
["Here you can allow other scripts"] = "���������ʹ�������ű�",
["to enable/disable and control Evadeee."] = "����/���úͿ���EVADEEE",
["Allow enabling/disabling evading"] = "��������/���ö��",
["Allow enabling/disabling Bot Mode"] = "��������/���û�����ģʽ",
["WARNING:"] = "����",
["By switching this ON/OFF - Evadeee"] = "ת�����͹�",
["will reset all your settings:"] = "���������趨",
["Restore default settings"] = "�ָ�Ĭ������",
["Enabled"] = "����",
["Ignore with dangerLevel >="] = "����Σ�յȼ�",
["    1 - Use vs everything"] = "1 - �κ�ʱ��ʹ��",
["2..4 - Use only vs More Dangerous / CC"] = "2..4 - ���ڽ�Σ�ռ��ܼ��ſ�ʹ��",
["    5 - Use only vs Very Dangerous"] = "5 - ���������ǳ�Σ�ռ���ʱʹ��",
["Delay before evading (ms)"] = "���ǰ�ӳ٣����룩",
["Ignore evading delay if you move"] = "��������ƶ����Զ��ǰ�ӳ�",
["Server Tick Buffer (ms)"] = "�����������ʱ�����룩",
["Pathfinding:"] = "Ѱ·",
["Move extra distance after evade"] = "��ܺ��ƶ�����ľ���",
["Randomize that extra distance"] = "������ɶ�ܺ��ƶ���ľ���ֵ",
["Juke when entering danger area"] = "��װ����Σ������",
["Move this distance during jukes"] = "�ٶ�������˷����ľ���",
["Allow changing path while evading"] = "�����ڶ��ʱ�ı�·��",
["Delay between each path change"] = "�ı�·��ʱ�ӳٵ�ʱ��",
["\"Smooth\" Diagonal Evading"] = "ƽ��б�߶��",
["Max Range Limit:"] = "��Զ��������",
["Anchor Type:"] = "��λ����",
["Safe Evade (Ignore Anchor):"] = "��ȫ��ܣ����Զ�λ��",
["Safe evade from enemy team"] = "��ȫ��ܵ���",
["Do that with X enemies nearby: "] = "�ڸ�����X������ʱ",
["How far enemies should be: "] = "�Ե��˵ľ������",
["Safe evade during Panic Mode"] = "��ʹ��ǿ������ģʽʱ��ȫ���",
["Explanation (Safe Evade):"] = "���ͣ���ȫ��ܣ�",
["This setting will force evade in the"] = "������ûᳯ��Զ��",
["direction away from enemy team."] = "�����ƶ�����ǿ�ƶ��",
["This will ignore your main anchor"] = "�������������λ",
["only when there are enemies nearby."] = "ֻ�ڸ����е���ʱ",
["Attempt to dodge spells from FoW"] = "���Զ�ܴ�û����Ұ�ĵط�������ķ���",
["Dodge if your HP <= X%: "] = "�����Ѫ��С��X%ʱ���",
["Dodge <= X normal spells..."] =	 "��С�ڵ���X����ͨ����������ʱ���",
["... in <= X seconds"] =	 "��С�ڵ���X����",
["Disable evading by idling X sec:"] = "����һ�X����Զ����ö��",
["Better dodging near walls"] = "ǽ�������õĶ��·��",
["Better dodging near turrets"] = "���˷������������õĶ��·��",
["Handling danger blinks and dashes:"] = "˲�ƺ�ͻ��ʱ���Σ��",
["Angle of the modified cast area"] = "���Σ�յĽǶ�",
["Blink/flash over missile"] = "˲�ƻ�ͻ����С����߶�ܹ���",
["Delay between dashes/blinks (ms):"] = "˲�ƻ��ͳ���ӳ�(ms)",
["Dash/Blink/Flash Mode:"] = "˲�ƻ�ͻ�������ֵ�ģʽ",
["Note:"] = "ע��",
["While activated, this mode overrides some of"] = "���㼤���������ʱ���ܻḲ��",
["the settings, which you can modify here."] = "һЩ���������������޸ĵ�����",
["Usually this is used together with SBTW."] = "һ������º��Զ��߿�����",
["To change the hotkey go to \"Controls\"."] = "�ڿ��������������ȼ�",
["Dodge \"Only Dangerous\" spells"] = "�����Σ�ռ���",
["Evade towards anchor only"] = "���ʱֻ��ǰ��λ",
["Ignore circular spells"] = "����Բ�μ���",
["Use dashes more often"] = "�����ʹ��˲��",
["To change controls just click here   \\/"] = "���������ı��������",
["Evading        | Hold"] = "��ס���",
["Evading        | Toggle"] = "���¶�ܿ�������ֱ���ڴΰ���ֹͣ",
["Combat/Chase Mode | Hold 1"] = "ս����׷��ģʽ����1",
["Combat/Chase Mode | Hold 2"] = "ս����׷��ģʽ����2",
["Combat/Chase Mode | Toggle"] = "ս����׷��ģʽ����",
["Panic Mode     | Refresh"] = "����ģʽˢ��",
["Panic Mode Duration (seconds)"] = "����ģʽʱ�䣨�룩",
["Remove spells with doubleclick"] = "˫���Ƴ����ܻ�ͼ",
["Quick Menu:"] = "��ݲ˵�",
["Open Quick Menu with LMB and:"] = "����������:�������ٲ˵�",
["Replace Panic Mode"] = "�滻����ģʽ",
["Explanation (Quick Menu):"] = "˵������ݲ˵���",
["If you choose 1 key for Quick Menu"] = "�����ѡ�񰴼�1��Ϊ��ݼ�",
["then make sure it doesn't overlap"] = "�˵���ݼ�����ȷ�ϲ����",
["with League's Quick Ping menu!"] = "��Ϸ��ʾPING�Ŀ�ݼ��ص�",
["Draw Skillshots"] = "���ܻ�ͼ��ʾ",
["Spell area line width"] = "���������ߵĴ�ϸ",
["Spell area color"] = "����������ɫ",
["Draw Dangerous Area"] = "Σ�������ͼ��ʾ",
["Danger area line width"] = "Σ�������ߵĴ�ϸ",
["Danger area color"] = "Σ��������ɫ",
["Display Evading Direction"] = "��ʾ��ܷ���",
["Show \"Doubleclick to remove!\""] = "��ʾ˫���Ƴ���ͼ��",
["Display Evadeee status"] = "��ʾEVADEEE״̬",
["Status display Y offset"] = "״̬��ʾ���Ტ��",
["Status display text size"] = "״̬��ʾ�����С",
["Print Evadeee status"] = "��ʾEVADEEE״̬",
["Show Priority Menu"] = "��ʾ���Ȳ˵�",
["Priority Menu X offset"] = "���Ȳ˵����Ტ��",
["Preset"] = "Ԥ��",
["Change this on your own risk:"] = "����ı��������Ը�",
["Update Frequency [Times per sec]"] = "ˢ������Ƶ�ʴ�/��",
-----------------SAC-----------------------
["Script Version"] = "�ű��汾",
["Generate Support Report"] = "����Ԯ������",
["Clear Chat When Enabled"] = "������ʱ��նԻ���",
["Show Click Marker (Broken)"] = "�����ѻ�",
["Click Marker Colour"] = "���Ԥ����ɫ",
["Minimum Time Between Clicks"] = "�����С���",
["Maximum Time Between Clicks"] = "��������",
["translation button"] = "�����",
["Harass mode"] = "ɧ��ģʽ",
["Cast Mode"] = "ʩ��ģʽ",
["Collision buffer"] = "��ײ���",
["Normal minions"] = "һ��С��",
["Jungle minions"] = "Ұ��",
["Others"] = "����",
["Check if minions are about to die"] = "���С�������˵��",
["Check collision at the unit pos"] = "��������λ����ײ",
["Check collision at the cast pos"] = "���ʩ��λ����ײ",
["Check collision at the predicted pos"] = "���Ԥ�Ʒ���λ����ײ",
["Enable debug"] = "�����ų�����ģʽ",
["Show collision"] = "��ʾ��ײ",
["Version"] = "�汾",
["No enemy heroes were found!"] = "δ���ֵз�Ӣ��",
["Target Selector Mode:"] = "Ŀ��ѡ��ģʽ",
["*LessCastPriority Recommended"] = "�Ƽ����Ҫ���������޶�",
["Hold Left Click Action"] = "��ס�������Ķ���",
["Focus Selected Target"] = "�۽�ѡ�е�Ŀ��",
["Attack Selected Buildings"] = "����ѡ�еĽ���",
["Disable Toggle Mode On Recall"] = "�ڻس�ʱ���ÿ���ģʽ",
["Disable Toggle Mode On Right Click"] = "����Ҽ�������ÿ���ģʽ",
["Mouse Over Hero To Stop Move"] = "�����ͣ��Ӣ���Ϸ�ʱֹͣ�ƶ�",
["      Against Champions"] = "����ս���ĵط�Ӣ��",
["Use In Auto Carry"] = "���Զ��������ģʽʹ��",
["Use In Mixed Mode"] = "�ڻ��ģʽʹ��",
["Use In Lane Clear"] = "������ģʽʹ��",
["Killsteal"] = "����ͷ",
["Auto Carry minimum % mana"] = "���ħ������%�򲻿����Զ��������ģʽ",
["Mixed Mode minimum % mana"] = "���ħ������%�򲻿������ģʽ",
["Lane Clear minimum % mana"] = "���ħ������%�򲻿�������ģʽ",
["      Skill Farm"] = "����ˢ��",
["Lane Clear Farm"] = "����ˢ��",
["Jungle Clear"] = "ˢҰ",
["TowerFarm"] = "����ˢ��?",
["Skill Farm Min Mana"] = "ʹ�ü���ˢ��ħ��������",
["(when enabled)"] = "������ʱ",
["Stick To Target"] = "����Ŀ��",
["   Stick To Target will mirror "] = "����Ŀ�����",
["   enemy waypoints so you stick"] = "���������н�·��",
["   to him like glue!"] = "�������������",
["Outer Turret Farm"] = "����ˢ��",
["Inner Turret Farm"] = "����ˢ��",
["Inhib Turret Farm"] = "ˮ��ˢ��",
["Nexus Turret Farm"] = "����ˢ��",
["Lane Clear Method"] = "���߷�ʽ",
["Double-Edged Sword"] = "˫�н��츳",
["Savagery"] = "Ұ���츳",
["Toggle mode (requires reload)"] = "����ģʽ����Ҫ2XF9��",
["Movement Enabled"] = "�����ƶ�",
["Attacks Enabled"] = "������",
["Anti-farm/harass (attack back)"] = "ɧ�ŵ��˲�����������",
["Attack Enemies"] = "��������",
["Prioritise Last Hit Over Harass"] = "����������ɧ��",
["Attack Wards"] = "������",
["           Main Hotkeys"] = "��Ҫ��ݼ�",
["Auto Carry"] = "�Զ����й���ģʽ",
["Last Hit"] = "����ģʽ",
["Mixed Mode"] = "���ģʽ",
["Lane Clear"] = "����",
["           Other Hotkeys"] = "������ݼ�",
["Target Lock"] = "Ŀ������",
["Enable/Disable Skill Farm"] = "������رռ���ˢ��",
["Lane Freeze (Default F1)"] = "F1�·��ز���",
["Support Mode (Default F6)"] = "����ģʽ",
["Toggle Streaming Mode with F7"] = "F7���ػ���ģʽ",
["Use Blade of the Ruined King"] = "ʹ���ư�",
["Use Bilgewater Cutlass"] = "ʹ�ñȶ��������䵶",
["Use Hextech Gunblade"] = "ʹ�ú���˹�Ƽ�ǹ��",
["Use Frost Queens Claim"] = "ʹ�ñ�˪Ů�ʵ�ָ��",
["Use Talisman of Ascension"] = "ʹ�÷�������",
["Use Ravenous Hydra"] = "ʹ��̰����ͷ��",
["Use Tiamat"] = "ʹ����������",
["Use Entropy"] = "ʹ�ñ�˪ս��",
["Use Youmuu's Ghostblade"] = "ʹ������֮��",
["Use Randuins Omen"] = "ʹ������֮��",
["Use Muramana"] = "ʹ��ħ��",
["Save BotRK for max heal"] = "����BotRK����������",
["Use Muramana [Champions]"] = "��Ӣ��ʹ��ħ��",
["Use Muramana [Minions]"] = "��С��ʹ��ħ��",
["Use Tiamat/Hydra to last hit"] = "ʹ���������ػ��߾�ͷ��������һ��",
["Use Muramana [Jungle]"] = "��Ұ��ʹ��ħ��",
["Champion Range Circle"] = "Ӣ�۷�ΧԲ��ͼ",
["Colour"] = "��ɫ",
["Circle Around Target"] = "Ŀ��Բ��ͼ",
["Draw Target Lock Circle"] = "��ʾĿ������Բ��ͼ",
["Target Lock Colour"] = "Ŀ��������ɫ",
["Target Lock Reminder Text"] = "Ŀ������������ʾ",
["Show Pet/Clone target scan range"] = "��ʾ����/��¡Ŀ��ɨ�跶Χ",
["Use Low FPS Circles"] = "ʹ�õ�FPSԲ",
["Show PermaShow box"] = "��ʾ������ʾ��",
["Show AA reminder on script load"] = "��ȡ�ű�ʱ��ʾAA����",
["Enable Pet Orbwalking:"] = "���������߿�",
["Tibbers"] = "��Ů�Ხ˹",
["Shaco's Clone"] = "С���¡",
["Target Style:"] = "Ŀ�귽ʽ",
["When To Orbwalk:"] = "ʲôʱ���߿�",
["Target Scan Range"] = "Ŀ��ɨ�跶Χ",
["Push Lane In LaneClear"] = "������ʱʹ������ģʽ",
["Delay Between Movements"] = "�ƶ�����ӳ�",
["Randomize Delay"] = "����ӳ�",
["Humanize Movement"] = "���˻��ƶ�",
["Last Hit Adjustment:"] = "��������",
["Adjustment Amount:"] = "������",
["Animation Cancel Adjustment:"] = "�չ�����ȡ������",
["Mouse Over Hero AA Cancel Fix:"] = "�����ͣ��Ӣ���Ϸ�ȡ���չ�",
["Mouse Over Hero Stop Distance:"] = "�����ͣ��Ӣ���Ϸ�ֹͣ����",
["Server Delay (don't touch): 100ms"] = "�������ӳ�100����",
["Disable AA Cancel Detection"] = "�����չ�ȡ�����",
["By Role:"] = "����ɫ",
["    Draw ADC"] = "ADC��ͼ",
["    Draw AP Carry"] = "AP��ͼ",
["    Draw Support"] = "������ͼ",
["    Draw Bruiser"] = "�̿ͻ�ͼ",
["    Draw Tank"] = "̹�˻�ͼ",
["By Champion:"] = "��Ӣ��",
["Modify Minion Health Bars"] = "����С��Ѫ��",
["Maximum Health Bars To Modify"] = "���Ѫ������",
["Draw Last Hit Arrows"] = "���һ��ͼ������",
["Always Draw Modified Health Bars"] = "һֱ��ʾѪ������",
["Always Draw Last Hit Arrows"] = "һֱ��ʾ���һ��ͼ������",
["Sida's Auto Carry"] = "Sida�߿�",
["Setup"] = "����",
["Hotkeys"] = "��ݼ�",
["Configuration"] = "����",
["Target Selector"] = "Ŀ��ѡ��",
["Skills"] = "����",
["Items"] = "��Ʒ",
["Farming"] = "ˢ��",
["Melee"] = "��ս",
["Drawing"] = "��ͼ",
["Pets/Clones"] = "����/��¡",
["Streaming Mode"] = "���ػ���ģʽ",
["Advanced / Fixes"] = "�߼�/����",
["VPrediction"] = "VԤ��",
["Collision"] = "��ײ���",
["Developers"] = "������",
["Circles"] = "ԲȦ",
["Enemy AA Range Circles"] = "�����չ���ΧȦ",
["Minion Drawing"] = "С�����",
["Other"] = "����",
["Auto Carry Mode"] = "�Զ����й���",
["Last Hit Mode"] = "���һ������ģʽ",
["Lane Clear Mode"] = "����ģʽ",
["Auto Carry Items"] = "�Զ�����ʹ�õ���Ʒ",
["Mixed Mode Items"] = "���ģʽʹ�õ���Ʒ",
["Lane Clear Items"] = "����ʹ�õ���Ʒ",
["Q (Decisive Strike)"] = "Q",
["E (Judgment)"] = "E",
["R (Demacian Justice)"] = "R",
["Masteries"] = "�츳",
["Damage Prediction Settings"] = "�˺�Ԥ������",
["Turret Farm"] = "����ˢ��",
["Activator"] = "���",
["Activator Version : "] = "����汾��",
["Debug Mode Setting"] = "����ģʽ����",
["Zhonya Debug"] = "��������",
["Debug Mode (shields,zhonya): "] = "����ģʽ(����,����)",
["Font Size Zhonya"] = "���������С",
["X Axis Draw Zhonya Debug"] = "������ʾX��λ��",
["Y Axis Draw Zhonya Debug"] = "������ʾY��λ��",
["QSS Debug "] = "ˮ���δ�����",
["Debug Mode (qss): "] = "����ģʽ(ˮ���δ�)",
["Font Size QSS"] = "ˮ���δ������С",
["X Axis Draw QSS Debug"] = "ˮ���δ���ʾX��λ��",
["Y Axis Draw QSS Debug"] = "ˮ���δ���ʾY��λ��",
["Cleanse Debug"] = "��������",
["Debug Mode (Cleanse): "] = "����ģʽ(����)",
["Font Size Cleanse"] = "���������С",
["X Axis Draw Cleanse Debug"] = "������ʾX��λ��",
["Y Axis Draw Cleanse Debug"] = "������ʾY��λ��",
["Mikael Debug"] = "��������",
["Debug Mode (Mikael): "] = "����ģʽ(����)",
["Font Size Mikael"] = "���������С",
["X Axis Draw Mikael Debug"] = "������ʾX��λ��",
["Y Axis Draw Mikael Debug"] = "������ʾY��λ��",
["Tower Damage"] = "�������˺�",
["Calculate Tower Damage"] = "����������˺�",
["Auto Spells"] = "�Զ�ʹ�ü���",
["Auto Shield Spells"] = "�Զ����ܼ���",
["Use Auto Shield Spells"] = "ʹ���Զ����ܼ���",
["Max percent of hp"] = "�������ֵ�ٷֱ�",
["Shield Ally Oriana"] = "�԰�������ʹ�û���",
["Auto Pot Settings"] = "�Զ�ҩˮ����",
["Use Auto Pots"] = "ʹ���Զ�ҩˮ",
["Use Health Pots"] = "�Զ���Ѫƿ",
["Use Mana Pots"] = "�Զ�����ƿ",
["Use Flask"] = "�Զ���ħƿ",
["Use Biscuit"] = "�Զ��Ա���",
["Min Health Percent"] = "��С����ֵ�ٷֱ�",
["Health Lost Percent"] = "��ʧ����ֵ�ٷֱ�",
["Min Mana Percent"] = "��С�����ٷֱ�",
["Min Flask Health Percent"] = "ħƿ-��С����ֵ�ٷֱ�",
["Min Flask Mana Percent"] = "ħƿ-��С�����ٷֱ�",
["Offensive Items Settings"] = "������Ʒ����",
["Button Mode"] = "����ģʽ",
["Use Button Mode"] = "ʹ�ð���ģʽ",
["Button Mode Key"] = "����",
["AP Items"] = "AP��Ʒ",
["Use AP Items"] = "ʹ��AP��Ʒ",
["Use Bilgewater Cutlass"] = "ʹ�ñȶ��������䵶",
["Use Blackfire Torch"] = "ʹ�����׻��",
["Use Deathfire Grasp"] = "ʹ��ڤ��֮ӵ",
["Use Hextech Gunblade"] = "ʹ�ú���˹�Ƽ�ǹ��",
["Use Twin Shadows"] = "ʹ��˫����Ӱ",
["Use Odyn's Veil"] = "ʹ�ð´�������ɱ",
["AP Item Mode: "] = "AP��Ʒģʽ",
["Burst Mode"] = "����ģʽ",
["Combo Mode"] = "����ģʽ",
["KS Mode"] = "����ͷģʽ",
["AD Items"] = "AD��Ʒ",
["Use AD Items On Auto Attack"] = "��ƽA��ʱ��ʹ��AD��Ʒ",
["Use AD Items"] = "ʹ��AD��Ʒ",
["Use Blade of the Ruined King"] = "ʹ���ư�����֮��",
["Use Entropy"] = "ʹ�ñ�˪ս��",
["Use Ravenous Hydra"] = "ʹ�þ�ͷ��",
["Use Sword of the Divine"] = "ʹ����ʥ֮��",
["Use Tiamat"] = "ʹ����������",
["Use Youmuu's Ghostblade"] = "ʹ������֮��",
["Use Muramana"] = "ʹ��ħ��",
["Min Mana for Muramana"] = "ʹ��ħ�е���С����",
["Minion Buff"] = "С������",
["Use Banner of Command"] = "ʹ�ú���֮��",
["AD Item Mode: "] = "AD��Ʒģʽ",
["Burst Mode"] = "����ģʽ",
["Combo Mode"] = "����ģʽ",
["KS Mode"] = "����ͷģʽ",
["Defensive Items Settings"] = "������Ʒ����",
["Cleanse Item Config"] = "��������",
["Stuns"] = "ѣ��",
["Silences"] = "��Ĭ",
["Taunts"] = "����",
["Fears"] = "�־�",
["Charms"] = "�Ȼ�",
["Blinds"] = "��ä",
["Roots"] = "����",
["Disarms"] = "����",
["Suppresses"] = "ѹ��",
["Slows"] = "����",
["Exhausts"] = "����",
["Ignite"] = "��ȼ",
["Poison"] = "�ж�",
["Shield Self"] = "�Զ�����",
["Use Self Shield"] = "ʹ���Զ�����",
["Use Seraph's Embrace"] = "ʹ�ó���ʹ֮ӵ",
["Use Ohmwrecker"] = "ʹ�ø���ˮ��",
["Min dmg percent"] = "��С�˺��ٷֱ�",
["Zhonya/Wooglets Settings"] = "����/�ָ����ص���ʦñ����",
["Use Zhoynas"] = "ʹ������",
["Use Wooglet's Witchcap"] = "ʹ���ָ����ص���ʦñ",
["Only Z/W Special Spells"] = "ֻ���ض�����ʹ��",
["Debuff Enemy"] = "�Ե���ʹ�ü���Ч��",
["Use Debuff Enemy"] = "ʹ�ü���Ч��",
["Use Randuin's Omen"] = "����֮��",
["Randuins Enemies in Range"] = "�ڷ�Χ����X������ʱʹ������",
["Use Frost Queen"] = "ʹ�ñ�˪Ů�ʵ�ָ��",
["Cleanse Self"] = "��������Ʒ",
["Use Self Item Cleanse"] = "ʹ�þ�������Ʒ",
["Use Quicksilver Sash"] = "ʹ��ˮ���δ�",
["Use Mercurial Scimitar"] = "ʹ��ˮ���䵶",
["Use Dervish Blade"] = "ʹ�ÿ���ɮ֮��",
["Cleanse Dangerous Spells"] = "����Σ�յļ���",
["Cleanse Extreme Spells"] = "��������Σ�յļ���",
["Min Spells to use"] = "����ӵ��X�ּ���Ч����ʹ��",
["Debuff Duration Seconds"] = "����Ч������ʱ��",
["Shield/Boost Ally"] = "���Ѿ�ʹ�û���/����",
["Use Support Items"] = "ʹ�ø�����Ʒ",
["Use Locket of Iron Solari"] = "��������֮ϻ",
["Locket of Iron Solari Life Saver"] = "����ֵ����Xʱʹ�ø�������֮ϻ",
["Use Talisman of Ascension"] = "��������",
["Use Face of the Mountain"] = "ɽ��֮��",
["Face of the Mountain Life Saver"] = "����ֵ����Xʱʹ��ɽ��֮��",
["Use Guardians Horn"] = "�ػ��ߵĺŽ�",
["Life Saving Health %"] = " ����ֵ����X%",
["Mikael Cleanse"] = "�׿���������",
["Use Mikael's Crucible"] = "ʹ������",
["Mikaels cleanse on Ally"] = "���Ѿ�ʹ������",
["Mikaels Life Saver"] = "��������X%ʱʹ������",
["Ally Saving Health %"] = "�Ѿ�����ֵ����X%",
["Self Saving Health %"] = "�Լ�����ֵ����X%",
["Min Spells to use"] = "����ӵ��X�ּ���Ч����ʹ��",
["Set Debuff Duration"] = "���ü���Ч������ʱ��",
["Champ Shield Config"] = "Ӣ�ۻ�������",
["Champ Cleanse Config"] = "Ӣ�۾�������",
["Shield Ally Vayne"] = "���Ѿ�ޱ��ʹ�û���",
["Cleanse Ally Vayne"] = "���Ѿ�ޱ��ʹ�þ���",
["Show In Game"] = "����Ϸ����ʾ",
["Show Version #"] = "��ʾ�汾��",
["Show Auto Pots"] = "��ʾ�Զ�ҩˮ",
["Show Use Auto Pots"] = "��ʾʹ���Զ�ҩˮ",
["Show Use Health Pots"] = "��ʾ�Զ�Ѫҩ",
["Show Use Mana Pots"] = "��ʾ�Զ���ҩ",
["Show Use Flask"] = "��ʾ�Զ�ħƿ",
["Show Offensive Items"] = "��ʾ��������Ʒ",
["Show Use AP Items"] = "��ʾʹ��AP��Ʒ",
["Show AP Item Mode"] = "��ʾAP��Ʒģʽ",
["Show Use AD Items"] = "��ʾʹ��AD��Ʒ",
["Show AD Item Mode"] = "��ʾAD��Ʒģʽ",
["Show Defensive Items"] = "��ʾ������Ʒ",
["Show Use Self Shield Items"] = "��ʾ���Լ�ʹ�û�������Ʒ",
["Show Use Debuff Enemy"] = "��ʾ�Եط�ʹ�ü���Ч��",
["Show Self Item Cleanse "] = "��ʾ���Լ�ʹ�þ���",
["Show Use Support Items"] = "��ʾʹ�ø�����Ʒ",
["Show Use Ally Cleanse Items"] = "��ʾ���Ѿ�ʹ�þ�������Ʒ",
["Show Use Banner"] = "��ʾʹ�ú���֮��",
["Show Use Zhonas"] = "��ʾʹ������",
["Show Use Wooglets"] = "��ʾʹ���ָ����ص���ʦñ",
["Show Use Z/W Lifeaver"] = "��ʾʹ�����ǵĴ�������ֵ",
["Show Z/W Dangerous"] = "��ʾʹ�����ǵ�Σ�ճ̶�",
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

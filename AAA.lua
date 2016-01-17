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
local version = "0.0117"

class('AAAUpdate')
function AAAUpdate:__init()
	self.updating = false
	self.updated = false
	AddDrawCallback(function ()
		self:draw()
	end)
	self:download()
end

function AAAUpdate:download( ... )
	PrintLocal("Checking Version Info,local version:"..version)
	self.updating = true
	local serveradress = "raw.githubusercontent.com"
	local scriptadress = "/leo9515/Tutorial/test"
	local ServerVersionDATA = GetWebResult(serveradress , scriptadress.."/AAA.version")
	if ServerVersionDATA then
		local ServerVersion = tonumber(ServerVersionDATA)
		if ServerVersion then
			if ServerVersion > tonumber(version) then
				PrintLocal("New version found:"..ServerVersion)
				PrintLocal("Updating, don't press F9")
				DownloadFile("http://"..serveradress..scriptadress.."/AAA.lua",SCRIPT_PATH.."AAA.lua", function ()
					updated = true
				end)
			else
				PrintLocal("No update found")
			end
		else
			PrintLocal("An error occured, while updating, please reload")
		end
	else
		PrintLocal("Could not connect to update Server")
	end
	self.updating = false
end

function AAAUpdate:draw()
	local w, h = WINDOW_W, WINDOW_H
	if self.updating then
		DrawTextA("[AAA] Updating", 25, 10,h*0.05,ARGB(255,255,255,255), "left", "center")
	end
	if updated then
		DrawTextA("[AAA] Updated, press 2xF9", 25, 10,h*0.05,ARGB(255,255,255,255), "left", "center")
	end
end

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
	if(MasterIndex ~= nil) then
    Master["I" .. MasterIndex] = I
    Master["P" .. MasterIndex] = P
    Master["PS" .. MasterIndex] = PS
    if not Master.useTS and SelectorConfig then Master.useTS = true end
    for var, value in pairs(Master) do
        settings[var] = value
    end
	SaveSettings("Master", settings)
	end
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
	if(#GameHeroes == 0) then
		for i = 1, heroManager.iCount do
			local hero = heroManager:getHero(i)
			if (hero and hero.valid and(hero.team ~= myHero.team)) then
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
    --translateheaderchk(header)
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
		index = index % GameEnemyCount + 1
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
["DeklandAIO: Orianna"] =  "神系列合集：奥利安娜",
["DeklandAIO Version: "] =  "神系列合集版本号：",
["Auth Settings"] =  "脚本验证设置",
["Debug Auth"] =  "调试验证",
["Fix Auth"] =  "修复验证",
["Target Selector Settings"] =  "目标选择器设置",
["Left Click Overide"] =  "左键点击目标优先",
["1 = Highest, 5 = Lowest, 0 = Ignore"]	= "1-最高，5-最低，0-忽略",
["Use Priority Mode"] =  "使用优先级模式",
["Set Priority Vladimir"] =  "设置吸血鬼的优先级",
["Keys Settings"] =  "键位设置",
["Harass"] =  "骚扰",
["Harass Toggle"] =  "骚扰开关",
["TeamFight"] =  "团战",
["Skill Settings"] =  "技能设置",
["                    Q Skill          "] =  "                Q技能              ",
["Use Harass"] =  "使用该技能骚扰",
["Use Kill Steal"] =  "使用该技能抢人头",
["Use Spacebar"] =  "使用空格",
["                    W Skill          "] =  "                W技能              ",
["Min No. Of Enemies In W Range"] =  "在W范围内最小敌人数量",
["                    E Skill          "] =  "                E技能              ",
["Use E>Q Combo"] =  "使用EQ连招",
["Use E If Can Hit"] =  "如果球能击中目标时使用E",
["Use E>W or E>R"] =  "使用EW或者ER连招",
["                    R Skill          "] =  "                R技能              ",
["R Block"] =  "禁止R自动释放",
["Set R Range"] =  "设置R的范围",
["Use Combo Ult - (Q+W+R Dmg)"] =  "使用终极连招（QWR的伤害）",
["Min No. Of Enemies"] =  "当至少有X名敌人时释放",
["Min No. Of KS Enemies"] =  "当至少有X名残血敌人时释放",
["Ult Vladimir"] =  "对吸血鬼释放R",
["                    Misc Settings          "] =  "            杂项设置              ",
["Harass Mana Management"] =  "骚扰蓝量控制",
["Farm Settings"] =  "刷兵设置",
["                    Farm Keys          "] =  "            刷兵按键              ",
["Farm Press"] =  "刷兵按键",
["Farm Toggle"] =  "刷兵开关",
["Lane Clear Press"] =  "清线按键",
["Lane Clear Toggle"] =  "清线开关",
["Jungle Farm"] =  "清野",
["                    Q Farm          "] =  "         Q技能刷兵           ",
["Last Hit"] =  " ",
["Lane Clear"] =  "清线",
["Jungle"] =  "清野",
["                    W Farm          "] =  "         W技能刷兵           ",
["                    E Farm          "] =  "         E技能刷兵           ",
["                    Misc          "] =  "                    杂项          ",
["Farm Mana Management"] =  "刷兵蓝量控制",
["OrbWalk Settings"] =  "走砍设置",
["            Team Fight Orbwalk Settings          "] =  "            团战走砍设置          ",
["Move To Mouse"] =  "向鼠标位置移动",
["Auto Attacks"] =  "自动攻击",
["               Harrass Orbwalk Settings          "] =  "            骚扰走砍设置          ",
["              Lane Farm Orbwalk Settings          "] =  "         清线刷兵走砍设置         ",
["              Jungle Farm Orbwalk Settings          "] =  "            清野走砍设置          ",
["On Dash Settings"] =  "面对突进时设置",
["Check On Dash Vladimir"] =  "检查吸血鬼的突进",
["Items Settings"] =  "物品设置",
["AP Items"] =  "AP的物品",
["Use AP Items"] =  "使用AP物品",
["Use Bilgewater Cutlass"] =  "比尔吉沃特弯刀",
["Use Blackfire Torch"] =  "黯炎火炬",
["Use Deathfire Grasp"] =  "冥火之拥",
["Use Hextech Gunblade"] =  "海克斯科技枪刃",
["Use Twin Shadows"] =  "双生暗影",
["AP Item Mode: "] =  "AP物品模式",
["Burst Mode"] =  "爆发模式",
["Combo Mode"] =  "连招模式",
["KS Mode"] =  "抢人头模式",
["AD Items"] =  "AD物品",
["Use AD Items"] =  "使用AD物品",
["Use Blade of the Ruined King"] =  "使用破败王者之刃",
["Use Entropy"] =  "冰霜战锤",
["Use Sword of the Divine"] =  "神圣之剑",
["Use Tiamat/Ravenous Hydra"] =  "提亚马特/九头蛇",
["Use Youmuu's Ghostblade"] =  "幽梦之灵",
["Use Muramana"] =  "魔切",
["Min Mana for Muramana"] =  "使用魔切的最小蓝量",
["AD Item Mode: "] =  "AD物品模式",
["Support Items"] =  "辅助物品",
["Use Support Items"] =  "使用辅助物品",
["Auto Wards"] =  "自动插眼",
["Use Sweeper"] =  "使用扫描",
["Ward Mode: "] =  "插眼模式",
["Only Bushes"] =  "只在草丛",
["Always"] =  "总是",
["Summoner Spells"] =  "召唤师技能",
["                    Ignite          "] =  "                    点燃          ",
["Use Ignite"] =  "使用点燃",
["Ignite Mode : "] =  "点燃模式：",
["ComboMode"] =  "连招模式",
["KSMode"] =  "抢人头模式",
["                    Smite          "] =  "                    惩戒          ",
["             Smite Not Found         "] =  "             没有发现惩戒         ",
["Use Smite"] = "使用惩戒",
["Smite Baron/Dragon/Vilemaw"] = "对大龙/小龙/卑鄙之喉使用惩戒",
["Smite Large Minions"] = "对大野怪使用惩戒",
["Smite Small Minions"] = "对小野怪使用惩戒",
["                  Lane          "] = "                  兵线          ",
["                  Jungle          "] = "                  打野          ",
["Smite Siege Minions"] = "对炮车使用惩戒",
["Smite Melee Minions"] = "对近战兵使用惩戒",
["Smite Caster Minions"] = "对远程兵使用惩戒",
["Draw Settings"] =  "绘图设置",
["Draw Skill Ranges"] =  "画出技能线圈",
["Lag free draw"] =  "不影响延迟的线圈",
["Draw Q Range"] =  "画出Q技能线圈",
["Choose Q Range Colour"] =  "选择Q技能线圈颜色",
["Draw W Range"] =  "画出W技能线圈",
["Choose W Range Colour"] =  "选择W技能颜色",
["Draw E Range"] =  "画出E技能线圈",
["Choose E Range Colour"] =  "选择E技能线圈颜色",
["Draw R Range"] =  "画出R技能线圈",
["Choose R Range Colour"] =  "选择R技能线圈颜色",
["Draw AA Range"] =  "画出平A的范围",
["Draw Awareness"] =  "显示意识",
["Draw Clicking Points"] =  "显示点击的位置",
["Draw Enemy Cooldowns"] =  "显示敌人的CD",
["Draw Enemy Predicted Damage"] =  "显示敌人的伤害",
["Draw Last Hit Marker"] =  "显示尾刀的标记",
["Draw Wards + Wards Timers"] =  "显示眼位以及眼位时间",
["Draw Turret Ranges"] =  "显示防御塔范围",
["Draw Kill Range"] =  "显示击杀范围",
["Kill Range"] =  "击杀范围",
["Choose Kill Range Colour"] =  "选择击杀范围的颜色",
["Draw Focused Target"] =  "显示锁定的目标",
["Focused Target"] =  "锁定目标",
["Choose Focused Target Colour"] =  "选择锁定目标的颜色",
["Draw Doomball Ranges"] =  "显示魔偶的范围",
["Draw Doomball W Range"] =  "显示魔偶W的范围",
["Draw Doomball R Range"] =  "显示魔偶R的范围",
----------------------------------------------------------------
["DeklandAIO: Syndra"] =  "神系列合集：辛德拉",
["Set Priority Amumu"] =  "设置木木的优先级",
["Use QE Snipe"] =  "使用QE",
["Cast On Optimal Target"] =  "对最佳目标释放",
["Ult Amumu"] =  "对木木释放R",
["Use QE Snipe (Teamfight)"] =  "使用QE（在团战时）",
["Use QE Snipe (Harass)"] =  "使用QE（在骚扰时）",
["Use Kill Steal QE Snipe"] =  "用QE抢人头",
["Use Gap Closers"] =  "对突进使用的技能",
["Interupt Skills"] =  "打断敌方技能",
["Check On Dash Amumu"] =  "检查木木的突进",
["Draw QE Range"] =  "画出QE的范围",
["Choose QE Range Colour"] =  "选择QE的线圈颜色",
["Draw Prediction"] =  "画出预判",
["Draw Q Prediction"] =  "画出Q的预判",
["Draw W Prediction"] =  "画出W的预判",
["Draw E Prediction"] =  "画出E的预判",
["Draw QE Prediction"] =  "画出QE的预判",
----------------神系列瑞兹锤石-----------------------
["DeklandAIO: Thresh"] = "神系列合集：锤石",
["Use Lantern Whilst Hooked"] = "勾中的同时使用灯笼",
["Use Lantern - Grab Ally"] = "对友军使用灯笼",
["Use Lantern - Self"] = "对自己使用灯笼",
["E Mode"] = "E技能模式",
["Auto"] = "自动",
["Pull"] = "向后拉",
["Push"] = "向前推",
["No. of Enemies In Range"] = "在范围内的敌军数量",
["Use Q On Dash "] = "对突进使用Q",
["Use E On Dash "] = "对突进使用E",
["             Ignite Not Found         "] = "             没有发现点燃         ",
["Draw Souls"] = "显示灵魂",
["DeklandAIO: Ryze"] = "神系列合集：瑞兹",
["Auto Q Stack"] = "自动Q攒被动",
-----------------神系列蛇女泽拉斯--------------------
["DeklandAIO: Cassiopeia"] = "神系列合集：卡西奥佩娅",
["Set Priority Chogath"] = "设置科加斯的优先级",
["Assisted Ult"] = "辅助大招",
["Use W Only If Q Misses"] = "只在Qmiss的时候使用W",
["E Daly Timer (secs)"] = "E延迟的时间(秒)",
["Use Spacebar (All skills can kill)"] = "使用空格(所有技能可以击杀)",
["When conditions are met it will ult Automatically"] = "当满足条件时会自动释放大招",
["No. Enemies in Range"] = "范围内有x名敌人",
["No. KS Enemies in Range"] = "范围内有x名敌人可以抢人头",
["No. Facing Enemies"] = "范围内有x名面朝你的敌人",
["Ult Chogath"] = "对科加斯使用大招",
["Auto E Poison Minions"] = "自动E中毒的小兵",
["Check On Dash Chogath"] = "检查科加斯的突进",
["Draw R Prediction"] = "显示R的预判",
["Draw Poison Targets"] = "显示中毒的目标",
["DeklandAIO: Xerath"] = "神系列合集：泽拉斯",
["Set Priority Nidalee"] = "设定奈德丽的优先级",
["Ult Tap (fires 'One' on release)"] = "大招按键(按一次放一个R)",
["Smart Cast Manual Q"] = "智能修正手动Q",
["Force Ult - R Key"] = "强制大招 - R键",
["Ult Near Mouse"] = "对鼠标附近的敌人放R",
["Ult Delay"] = "大招延迟",
["Check On Dash Nidalee"] = "检查奈德丽的突进",
["MiniMap draw"] = "小地图显示",
["Draw Ult Range"] = "显示R范围",
["Draw Ult Marks"] = "显示R标记",
-----------------烧伤合集----------------------------
["HTTF Prediction"] = "HTTF预判",
["Collision Settings"] = "碰撞设置",
["Buffer distance (Default value = 10)"] = "缓冲距离(默认10)",
["Ignore which is about to die"] = "忽略将要死亡的目标",
["Script version: "] = "脚本版本号",
["DivinePrediction"] = "神圣预判",
["Min Time in Path Before Predict"] = "预判路径的最小时间",
["Central Accuracy"] = "中心精准度",
["Debug Mode [Dev]"] = "调试模式[开发者]",
["Cast Mode"] = "释放模式",
["Fast"] = "快",
["Slow"] = "慢",
["Collision"] = "碰撞",
["Collision buffer"] = "碰撞缓冲",
["Normal minions"] = "普通小兵",
["Jungle minions"] = "野怪",
["Others"] = "其他",
["Check if minions are about to die"] = "检查即将死亡的小兵",
["Check collision at the unit pos"] = "检查单位位置的碰撞",
["Check collision at the cast pos"] = "检查释放位置的碰撞",
["Check collision at the predicted pos"] = "检查预判位置的碰撞",
["Developers"] = "开发者",
["Enable debug"] = "启用调试",
["Show collision"] = "显示碰撞",
["Version"] = "版本",
["--- Fun House Team ---"] = "---烧伤团队---",
["made by burn & ikita"] = "作者 burn & ikita",
["FH Global Settings"] = "烧伤合集全局设置",
["Amumu"] = "阿木木",
["5 = Maximum priority = You will focus first!"] = "5 - 最大优先级 -首要攻击目标",
["Target Selector - Extra Setup"] = "目标选择器 - 额外设置",
["- DISTANCE TO IGNORE TARGET (FOCUS MODE) -"] = "忽略锁定目标的距离",
["Default distance"] = " 默认距离",
["------ DRAWS ------"] = "------ 显示 ------",
["This allow you draw your target on"] = "这项设置允许将目标显示在屏幕上",
["the screen, for quicker target orientation"] = "以获得更快的目标方向",
["Enable draw of target (circle)"] = "启用显示目标(线圈)",
["Target circle color"] = "目标线圈颜色",
["Enable draw of target (text)"] = "启用显示目标(文字)",
["Select where to draw"] = "选择显示的位置",
["Fixed On Screen"] = "固定在屏幕上",
["On Mouse"] = "在鼠标上",
["--- Draw values ---"] = "--- 显示设置 ---",
["Draw X location"] = "显示X轴位置",
["Draw Y location"] = "显示Y轴位置",
["Draw size"] = "显示大小",
["Draw color"] = "显示颜色",
["Reset draw position"] = "重设显示位置",
["Auto Potions"] = "自动药水",
["Use Health Potion"] = "使用血瓶",
["Use Refillable Potion"] = "使用复用型药水",
["Use Hunters Potion"] = "使用猎人药水",
["Use Corrupting Potion"] = "使用腐败药水",
["Corrupting Potion DPS in Combat"] = "在战斗中使用腐败药水增加伤害",
["Absolute Min Health %"] = "绝对生命值最小百分比",
["In Combat Min Health %"] = "战斗中生命值最小百分比",
["QSS & Cleanse"] = "水银 & 净化",
["Enable auto cleanse enemy debuffs"] = "启用自动净化",
["Settings for debuffs"] = "减益效果设置",
["- Global delay before clean debuff -"] = "自动净化的全局延迟",
["Global Default delay"] = "全局默认延迟",
["- Usual debuffs -"] = "-常规减益效果-",
["Cleanse if debuff time > than (ms):"] = "如果减益效果时间大于..使用净化",
["- Slow debuff -"] = "- 减速 -",
["Cleanse if slow time > than (ms):"] = "如果减速时间大于..使用净化",
["- Special cases -"] = "- 特殊情况 -",
["Remove Zed R mark"] = "解劫的大招",
["Extra Awaraness"] = "额外意识",
["Enable Extra Awaraness"] = "启用额外意识",
["Warning Range"] = "警告的范围",
["Draw even if enemy not visible"] = "即使敌人隐身也线束",
["Security & Humanizer"] = "安全&拟人化",
["------------ SECURITY ------------"] = "------------ 安全 ------------",
["Enabling this, you will limit all functions"] = "启用此设置，会限制仅当敌人在你的",
["to only trigger them if enemy/object"] = "屏幕上时所有功能才生效",
["is on your Screen"] = " ",
["Enable extra Security mode"] = "启用额外安全设置",
["------------ HUMANIZER ------------"] = "------------ 拟人化 ------------",
["This will insert a delay between spells"] = "这项设置将会在你的连招中间加入延迟",
["If you set too high, it will make combo slow,"] = "如果你将数值设定的过高，连招会变慢",
["so if you use it increase it gradually!"] = "所以如果你要使用的话，请慢慢增加数值",
["Humanize Delay in ms"] = "拟人化延迟(毫秒)",
["Ryze Fun House 2.0"] = "烧伤合集2.0 - 瑞兹",
["General"] = "常规",
["Key binds"] = "键位设置",
["Auto Q stack out of combat"] = "在连招外自动Q攒被动",
["Combat"] = "连招",
["Smart Combo"] = "智能连招",
["Use Items on Combo"] = "在连招中使用物品",
["Use Desperate Power (R)"] = "使用绝望之力(R)",
["R Cast Mode"] = "R使用模式",
["Required stacks on 'Smart' for cast R"] = "智能使用R时需要被动层数",
["Harass"] = "骚扰",
["Use Overload (Q)"] = "使用超负荷(Q)",
["Use Rune Prison (W)"] = "使用符文禁锢(W)",
["Use Spell Flux (E)"] = "使用法术涌动(E)",
["Use Overload (Q) for last hit"] = "使用Q来补尾刀",
["Min Mana % to use Harass"] = "骚扰的最小蓝量 %",
["Auto kill"] = "自动击杀",
["Enable Auto Kill"] = "启用自动击杀",
["Auto KS under enemy towers"] = "在敌人塔下自动抢人头",
["Farming"] = "刷兵",
["Lane Clear"] = "清线",
["Min Mana % for lane clear"] = "清线的最小蓝量 %",
["Last Hit"] = "尾刀",
["Use Q for last hit"] = "使用Q来补尾刀",
["Last Hit with AA"] = "使用平A来补尾刀",
["Min Mana % for Q last hit"] = "Q补尾刀的最小蓝量",
["Drawings"] = "显示设置",
["Spell Range"] = "技能线圈",
["Enable Draws"] = "启用显示",
["Draw Q range"] = "显示Q范围",
["Q color"] = "Q线圈颜色",
["Draw W-E range"] = "显示W-E范围",
["W-E color"] = "W-E线圈颜色",
["Draw Stacks"] = "显示被动层数",
["Use Lag Free Circle"] = "使用不影响延迟的线圈",
["Kill Texts"] = "击杀提示",
["Use KillText"] = "启用击杀提示",
["Draw KillTime"] = "显示击杀时间",
["Text color"] = "文字颜色",
["Draw Damage Lines"] = "显示伤害指示线",
["Damage color display"] = "显示伤害的颜色",
["Miscellaneous"] = "杂项设置",
["Auto Heal"] = "自动治疗",
["Automatically use Heal"] = "使用自动治疗",
["Min percentage to cast Heal"] = "使用治疗的最小血量 %",
["Use Heal to Help teammates"] = "对友军使用治疗",
["Teammates to Heal"] = "使用治疗的友军",
["Auto Zhonyas"] = "自动中亚",
["Automatically Use Zhonyas"] = "自动使用中亚",
["Min Health % to use Zhonyas"] = "使用中亚的最小血量",
["Use W on enemy gap closers"] = "对敌方的突进使用W",
["Auto Q for get shield vs gap closers"] = "自动Q来获得护盾以抵御突进",
["Auto use Seraph's Embrace on low Health"] = "低血量时自动使用大天使",
["Min % to cast Seraph's Embrace"] = "使用大天使的最小血量 %",
["Prediction"] = "预判",
["-- Prediciton Settings --"] = "------ 预判设置 ------",
["VPrediction"] = "V预判",
["DPrediction"] = "神圣预判",
["-- VPrediction Settings --"] = "------ V预判设置 ------",
["Q Hit Chance"] = "Q的命中机会",
["Medium"] = "中等",
["High"] = "高",
["-- HPrediction Settings --"] = "------ H预判设置 ------",
["-- DPrediction Settings --"] = "----- 神圣预判设置 -----",
["Instant force W"] = "立即强制使用W",
["Flee Key"] = "逃跑按键",
["Toggle Parry Auto Attack"] = "切换格挡自动攻击",
["Orbwalk on Combo"] = "在连招中的走砍",
["To Vital"] = "移动至弱点",
["To Target"] = "移动至目标",
["Disabled"] = "关闭",
["Orbwalk Magnet Range"] = "走砍磁力范围",
["Vital Strafe Outwards Distance %"] = "击中弱点向外延伸距离%",
["Fiora Fun House 2.0"] = "烧伤合集2.0 - 菲奥娜",
["Orbwalk Settings"] = "走砍设置",
["W Hit Chance"] = "W技能命中的机会",
["Draw R range"] = "显示R的范围",
["Draw AA range"] = "显示平A的范围",
["Use IGNITE"] = "使用点燃",
["Q Color"] = "Q技能线圈颜色",
["Combo"] = "连招",
["--- Combo Logic ---"] = "--- 连招逻辑 ---",
["Save Q for dodge enemy hard spells"] = "保留Q来躲避敌人的重要技能",
["Q Gapclose regardless of vital"] = "使用Q突进时忽略弱点",
["Gapclose min catchup time"] = "突进最小追赶时间",
["Q minimal landing position"] = "Q的最短释放位置",
["Q Angle in degrees"] = "Q的角度",
["Q on minion to reach enemy"] = "Q小兵来接近敌人",
["--- Ultimate R Logic ---"] = "--- 大招使用逻辑 ---",
["Focus R Casted Target"] = "锁定使用R的目标",
["Cast when target killable"] = "当目标可以被击杀时使用R",
["Cast only when healing required (overrides above)"] = "有回血需要时用R",
["Cast when our HP less than %"] = "当生命值小于%时使用R",
["Cast before KS with Q when lower than"] = "在用Q抢人头之前使用R",
["Riposte Options"] = "劳伦特心眼刀(W)设置",
["Riposte Enabled"] = "使用W",
["Save Q Evadeee when Riposte cd"] = "当Wcd时保留Q来躲避",
["Auto Parry next attack when %HP <"] = "当生命值小于%时自动格挡下一次普通攻击",
["Humanizer: Extra delay"] = "拟人化：额外延迟",
["Parry Summoner Spells (low latency)"] = "格挡召唤师技能(低延迟)",
["Parry Dragon Wind"] = "格挡小龙的攻击",
["Parry Auto Attacks"] = "格挡普通攻击",
["Parry AA Damage Threshold"] = "格挡平A的伤害临界值",
["Parry is still a Work In Progress"] = "格挡功能是仍在开发的功能",
["If is not parrying a spell from the list,"] = "如果没有格挡列表中的技能",
["before report on forum, make a list like:"] = "在论坛报告之前，写一个像下面一样的列表",
["Champion-Spell that fails to parry"] = "格挡失败的技能：如果你有大于20个",
["When you have 20+ added, post it on forum. Thanks"] = "无法格挡的技能，请发表在论坛上",
["Riposte Main List"] = "格挡主要技能列表",
["--- Riposte Spells At Arrival ---"] = "--- 当技能命中的时候格挡 ---",
["Riposte Extra List"] = "格挡额外技能列表",
["Use Q on Harass"] = "在骚扰中使用Q",
["Use Lunge (Q)"] = "使用破空斩Q",
["Use Riposte (W) [only on Jungle]"] = "使用劳伦特心眼刀W[只对野怪]",
["Use Bladework (E)"] = "使用夺命连刺E",
["Use items"] = "使用物品",
["R Color"] = "R技能颜色",
["AA Color"] = "平A线圈颜色",
["Draw Magnet Orbwalk range"] = "显示走砍磁力范围",
["Draw Flee direction"] = "显示逃跑方向",
["Draw KillText"] = "显示击杀提示",
["HPrediction"] = "H预判",
["SxOrbWalk"] = "Sx走砍",
["General-Settings"] = "常规设置",
["Orbwalker Enabled"] = "走砍生效",
["Stop Move when Mouse above Hero"] = "当英雄在鼠标下时停止移动",
["Range to Stop Move"] = "停止移动的区域",
["ExtraDelay against Cancel AA"] = "取消平A后摇的额外延迟",
["Spam Attack on Target"] = "尽可能多的平A目标",
["Orbwalker Modus: "] = "走砍模式",
["To Mouse"] = "向鼠标",
["Humanizer-Settings"] = "拟人化设置",
["Limit Move-Commands per Second"] = "限制每秒发送的移动指令",
["Max Move-Commands per Second"] = "每秒发送移动指令的最大次数",
["Key-Settings"] = "键位设置",
["FightMode"] = "战斗模式",
["HarassMode"] = "骚扰模式",
["LaneClear"] = "清线",
["LastHit"] = "尾刀",
["Toggle-Settings"] = "切换设置",
["Make FightMode as Toggle"] = "显示战斗模式切换",
["Make HarassMode as Toggle"] = "显示骚扰模式切换",
["Make LaneClear as Toggle"] = "显示清线模式切换",
["Make LastHit as Toggle"] = "显示尾刀模式切换",
["Farm-Settings"] = "刷兵设置",
["Focus Farm over Harass"] = "在骚扰时专心补刀",
["Extra-Delay to LastHit"] = "尾刀时的额外延迟",
["Mastery-Settings"] = "天赋设置",
["Mastery: Butcher"] = "屠夫",
["Mastery: Arcane Blade"] = "双刃剑",
["Mastery: Havoc"] = "毁灭",
["Mastery: Devastating Strikes"] = "毁灭打击",
["Draw-Settings"] = "显示设置",
["Draw Own AA Range"] = "显示自己的平A线圈",
["Draw Enemy AA Range"] = "显示敌人的平A线圈",
["Draw LastHit-Cirlce around Minions"] = "在小兵上显示尾刀线圈",
["Draw LastHit-Line on Minions"] = "在小兵上显示尾刀指示线",
["Draw Box around MinionHpBar"] = "在小兵血条上画放开",
["Color-Settings"] = "颜色设置",
["Color Own AA Range: "] = "自己的平A线圈的颜色",
["white"] = "白色",
["blue"] = "蓝色",
["red"] = "红色",
["black"] = "黑色",
["green"] = "绿色",
["orange"] = "橙色",
["Color Enemy AA Range (out of Range): "] = "敌人平A线圈的颜色(范围外)",
["Color Enemy AA Range (in Range): "] = "敌人平A线圈的颜色(范围内)",
["Color LastHit MinionCirlce: "] = "小兵尾刀线圈颜色",
["Color LastHit MinionLine: "] = "小兵尾刀指示线颜色",
["ColorBox: Minion is LasthitAble: "] = "小兵可被尾刀的颜色",
["none"] = "无",
["ColorBox: Wait with LastHit: "] = "小兵等待被尾刀的颜色",
["ColorBox: Can Attack Minion: "] = "可以攻击的小兵颜色",
["TargetSelector"] = "目标选择器",
["Priority Settings"] = "优先级颜色",
["Focus Selected Target: "] = "锁定选定的目标",
["never"] = "从不",
["when in AA-Range"] = "当在平A范围时",
["TargetSelector Mode: "] = "目标选择器模式",
["LowHP"] = "低血量",
["LowHPPriority"] = "低血量+优先级",
["LessCast"] = "更少释放技能",
["LessCastPriority"] = "更少释放技能+优先级",
["nearest myHero"] = "离自己的英雄最近",
["nearest Mouse"] = "离鼠标最近",
["RawPriority"] = "重设优先级",
["Highest Priority (ADC) is Number 1!"] = "最高优先级(ADC)为1",
["Debug-Settings"] = "调试模式",
["Draw Circle around own Minions"] = "在己方小兵上画圈",
["Draw Circle around enemy Minions"] = "在敌方小兵上画圈",
["Draw Circle around jungle Minions"] = "在野怪上画圈",
["Draw Line for MinionAttacks"] = "显示小兵攻击指示线",
["Log Funcs"] = "日志功能",
["Irelia Fun House 2.0"] = "烧伤合集2.0 - 艾瑞莉娅",
["R Lane Clear toggle"] = "R清线切换",
["Force E"] = "强制E",
["Q on killable minion to reach enemy"] = "对可击杀的小兵使用Q以突进敌人",
["Use Q only as gap closer"] = "仅突进时使用Q",
["Minimum distance for use Q"] = "使用Q的最小距离",
["Save E for stun"] = "保留E用来眩晕",
["Use E for slow if enemy run away"] = "如果敌人逃跑使用E来减速",
["Use E for interrupt enemy dangerous spells"] = "使用E打断敌人的危险技能",
["Anti-gapclosers with E stun"] = "使用E眩晕来反突进",
["Use R on sbtw combo"] = "只在连招中使用R",
["Cast R when our HP less than"] = "当你的生命值低于%时使用R",
["Cast R when enemy HP less than"] = "当敌人生命值低于%时使用R",
["Block R in sbtw until Sheen/Tri Ready"] = "屏蔽R直到耀光效果就绪",
["In Team Fight, use R as AOE"] = "在团战中使用R打AOE",
["Use Bladesurge (Q) on minions"] = "对小兵使用Q",
["Use Bladesurge (Q) on target"] = "对目标使用Q",
["Use Equilibrium Strike (W)"] = "使用W",
["Use Equilibrium Strike (E)"] = "使用E",
["Use Bladesurge (Q)"] = "使用Q",
["Use Transcendent Blades (R)"] = "使用R",
["Only Q minions that can't be AA"] = "只对不能平A的小兵使用Q",
["Block Q on Jungle unless can reset"] = "屏蔽Q直到野怪可以被Q击杀",
["Block Q on minions under enemy tower"] = "在敌方塔下时屏蔽Q",
["Humanizer delay between Q (ms)"] = "Q之间的拟人化延迟(毫秒)",
["Use Hiten Style (W)"] = "使用W",
["No. of minions to use R"] = "使用R的最少小兵数量",
["Maximum distance for Q in Last Hit"] = "使用Q尾刀的最大距离",
["E Color"] = "E线圈的颜色",
["Auto Ignite"] = "自动点燃",
["Automatically Use Ignite"] = "自动使用点燃",
----------------烧伤瞎子---------------------
["Lee Sin Fun House 2.0"] = "烧伤合集2.0 - 盲僧",
["Lee Sin Fun House"] = "烧伤盲僧",
["Ward Jump Key"] = "摸眼按键",
["Insec Key"] = "Insec按键",
["Jungle Steal Key"] = "抢龙按键",
["Insta R on target"] = "立即对目标使用R",
["Disable R KS in combo 4 sec"] = "在4秒内关闭用R抢人头",
["Combo W->R KS (override autokill)"] = "W->R抢人头连招",
["Passive AA Spell Weave"] = "技能之间衔接被动平A",
["Smart"] = "只能",
["Quick"] = "快速",
["Use Stars Combo: RQQ"] = "使用明星连招：RQQ",
["Use Q-Smite for minion block"] = "有小兵挡住时使用Q惩戒",
["Use W on Combo"] = "在连招中使用W",
["Use wards if necessary (gap closer)"] = "使用W突进敌人(如果必要)",
["Cast R when it knockups at least"] = "如果能击飞x个敌人使用R",
["Cast W to Mega Kick position"] = "使用W来找能踢多个敌人的位置",
["Use R to stop enemy dangerous spells"] = "使用R来打断敌人的危险技能",
["-- ADVANCED --"] = "-- 高级设置 --",
["Combo-Insec value Target"] = "回旋踢目标",
["Combo-Insec with flash"] = "使用R闪回旋踢",
["Use R-flash if no W or wards"] = "如果没有W或者没有眼使用R闪",
["Use W-R-flash if Q cd (BETA)"] = "如果Qcd使用W-R闪(测试)",
["Insec Mode"] = "回旋踢模式",
["R Angle Variance"] = "R的角度调整",
["KS Enabled"] = "启用抢人头",
["Autokill Under Tower"] = "在塔下自动击杀",
["Autokill Q2"] = "使用二段Q自动击杀",
["Autokill R"] = "使用R自动击杀",
["Autokill Ignite"] = "使用点燃自动击杀",
["--- LANE CLEAR ---"] = "--- 清线 ---",
["LaneClear Sonic Wave (Q)"] = "使用Q清线",
["LaneClear Safeguard (W)"] = "使用W清线",
["LaneClear Tempest (E)"] = "使用E清线",
["LaneClear Tiamat Item"] = "使用提亚马特清线",
["LaneClear Energy %"] = "清线能量控制%",
["--- JUNGLE CLEAR ---"] = "--- 清野 ---",
["Jungle Sonic Wave (Q)"] = "使用Q清野",
["Jungle Safeguard (W)"] = "使用W清野",
["Jungle Tempest (E)"] = "使用E清野",
["Jungle Tiamat Item"] = "使用提亚马特清野",
["Use E if AA on cooldown"] = "使用E重置普攻",
["Use Q for harass"] = "使用一段Q骚扰",
["Use Q2 for harass"] = "使用二段Q骚扰",
["Use W for retreat after Q2+E"] = "二段Q+E后使用W撤退",
["Use E for harass"] = "使用E技能骚扰",
["-- Spells Range --"] = "-- 技能范围线圈 --",
["Draw W range"] = "显示W范围",
["W color"] = "W技能线圈颜色",
["Draw E range"] = "显示E技能范围",
["Combat Draws"] = "显示战斗",
["Insec direction & selected points"] = "回旋踢的地点&选定的地点",
["Collision & direction for direct R"] = "碰撞&直线R的方向",
["Draw non-Collision R direction"] = "显示无碰撞的R的方向",
["Collision & direction Prediction"] = "碰撞&方向预判",
["Draw Damage"] = "显示伤害",
["Draw Kill Text"] = "显示击杀提示",
["Debug"] = "调试",
["Focus Selected Target"] = "锁定选择的目标",
["Always"] = "总是",
["Auto Kill"] = "自动击杀",
["Insec Wardjump Range Reduction"] = "回旋踢摸眼范围减少",
["Magnetic Wards"] = "磁性插眼",
["Enable Magnetic Wards Draw"] = "启用磁性插眼显示",
["Use lfc"] = "使用lfc",
["--- Spots to be Displayed ---"] = "--- 显示的插眼点 ---",
["Normal Spots"] = "普通地点",
["Situational Spots"] = "取决于情况的地点",
["Safe Spots"] = "安全地点",
["--- Spots to be Auto Casted ---"] = "--- 自动插眼的地点 ---",
["Disable quickcast/smartcast on items"] = "禁用快速/智能使用物品",
["--- Possible Keys for Trigger ---"] = "--- 可能触发的按键 ---",
--------------烧伤寡妇----------------------
["Evelynn Fun House 2.0"] = "烧伤合集2.0 - 伊芙琳",
["Force R Key"] = "强制大招按键",
["Use Agony's Embrace (R)"] = "使用R",
["Required enemies to cast R"] = "使用R需要的敌人数",
["Auto R on low HP as life saver"] = "在低血量的时候自动R以救命",
["Minimum % of HP to auto R"] = "自动R的最小触发生命值",
["Use Hate Spike (Q)"] = "使用憎恨之刺(Q)",
["Use Ravage (E)"] = "使用毁灭打击(E) ",
["Draw A range"] = "显示平A范围",
["A color"] = "平A线圈颜色",
["Reverse Passive Vision"] = "反转被动视野",
["Vision Color"] = "视野颜色",
["Stealth Status"] = "隐身状态",
["Spin Color"] = "旋转颜色",
["Info Box"] = "信息框",
["X position of menu"] = "菜单的X轴位置",
["Y position of menu"] = "菜单的Y轴位置",
["W Settings"] = "W技能设置",
["Use W on flee mode"] = "在逃跑模式使用W",
["Use W for cleanse enemy slows"] = "使用W来移除敌人的减速",
["R Hit Chance"] = "R命中的机会",
["E color"] = "E线圈颜色",
["R color"] = "R线圈颜色",
["Key Binds"] = "键位设置",
--------------烧伤豹女狮子狗黄鸡------------
["FH Smite"] = "烧伤 惩戒",
["Jungle Camps"] = "野怪营地",
["Enable Auto Smite"] = "启用自动惩戒",
["Temporally Disable Autosmite"] = "暂时禁用惩戒",
["--- Global Objectives ---"] = "--- 全局目标 ---",
["Rift Scuttler Top"] = "上路河道蟹",
["Rift Herald"] = "峡谷先锋",
["Rift Scuttler Bot"] = "下路河道蟹",
["Baron"] = "大龙",
["Dragon"] = "小龙",
["--- Normal Camps ---"] = "-- 普通野怪 --",
["Murk Wolf"] = "暗影狼",
["Red Buff"] = "红buff",
["Blue Buff"] = "蓝buff",
["Gromp"] = "魔沼蛙",
["Raptors"] = "锋喙鸟(F4)",
["Krugs"] = "石甲虫",
["Chilling Smite KS"] = "寒霜惩戒抢人头",
["Chilling Smite Chase"] = "寒霜惩戒追击",
["Challenging Smite Combat"] = "在连招中使用挑战惩戒",
["Forced Smite on Enemy"] = "强制惩戒敌人",
["Draw Smite % damage"] = "显示惩戒百分比伤害",
["Smite Fun House"] = "惩戒 烧伤",
["Taric"] = "塔里克",
["Nidalee Fun House 2.0"] = "烧伤合集2.0 - 奈德丽",
["Nidalee Fun House"] = "烧伤合集 - 奈德丽",
["Harass Toggle Q"] = "Q骚扰开关",
["Use W on combo (human form)"] = "在连招中使用W(人形态)",
["Immobile"] = "不可移动的",
["Mana Min percentage W"] = "W的最小蓝量%",
["E for SpellWeaving/DPS"] = "使用E以提升输出",
["Auto heal E"] = "E自动加血",
["Self"] = "自己",
["Self/Ally"] = "自己/友军",
["Min percentage hp to auto heal"] = "自动加血的最小触发血量%",
["Min mana to cast E"] = "使用E的最小蓝量",
["Smart R swap"] = "智能R切换形态",
["Allow Mid-Jump Transform"] = "允许跳跃的空中变换形态",
["Harass (Human form)"] = "骚扰(人形态)",
["Use Javelin Toss (Q)"] = "使用人形态Q骚扰",
["Use Toggle Key Override (Keybinder Menu)"] = "使用按键开关覆盖",
["Min mana to cast Q"] = "使用Q的最小蓝量",
["Flee"] = "逃跑",
["W for Wall Jump Only"] = "W只用来跳墙",
["Lane Clear with AA"] = "使用平A清线",
["Use Bushwhack (W)"] = "使用人形态W",
["Use Primal Surge (E)"] = "使用人形态E",
["Use Takedown (Q)"] = "使用豹形态Q",
["Use Pounce (W)"] = "使用豹形态W",
["Use Swipe (E)"] = "使用豹形态E",
["Use Aspect of the Cougar (R)"] = "使用R",
["Mana Min percentage"] = "最小蓝量百分比",
["Draw Q range (Human)"] = "显示人形态Q范围",
["Draw W range (Human)"] = "显示人形态W范围",
["W color (Human)"] = "人形态W线圈颜色",
["Draw E range (Human)"] = "显示人形态E范围",
["Karthus"] = "卡尔萨斯",
["Rengar Fun House 2.0"] = "烧伤合集2.0 - 雷恩加尔",
["Rengar Fun House"] = "烧伤合集 - 雷恩加尔",
["Force E Key"] = "强制E按键",
["Combo Mode Key"] = "连招模式按键",
["Use empower W if health below %"] = "当生命值低于%使用强化W",
["Min health % for use it ^"] = "使用的最小生命值%",
["Use E on Dynamic Combo if enemy is far"] = "如果敌人距离很远在动态连招中使用E",
["Playing AP rengar !"] = "AP狮子狗模式",
["Use E on AP Combo if enemy is far"] = "如果敌人距离很远在AP连招中使用E",
["Anti Dashes"] = "反突进",
["Antidash Enemy Enabled"] = "对敌人启用反突进",
["LaneClear Savagery (Q)"] = "在清线中使用Q",
["LaneClear Battle Roar (W)"] = "在清线中使用W",
["LaneClear Bola Strike (E)"] = "在清线中使用E",
["stop using spells at 5 stacks"] = "5格残暴的时候停止使用技能",
["Jungle Savagery (Q)"] = "在清野中使用Q",
["Jungle Battle Roar (W)"] = "在清野中使用W",
["Jungle Bola Strike (E)"] = "在清野中使用E",
["Jungle Savagery (Q) Empower"] = "在清野中使用强化Q",
["Jungle Battle Roar (W) Empower"] = "在清野中使用W",
["Use Q if AA on cooldown"] = "使用Q来重置普攻",
["Use W if AA on cooldown"] = "使用W来重置普攻",
["Use W for harass"] = "使用W骚扰",
["Draw R timer"] = "显示R的时间",
["Draw R Stealth Distance"] = "显示R隐身距离",
["Draw R on:"] = "显示R状态:",
["Center of screen"] = "在屏幕中央",
["Champion"] = "英雄",
["-- Draw Combo Mode values --"] = "-- 显示连招模式设置 --",
["E Hit Chance"] = "E命中的机会",
["Swain"] = "斯维因",
["Azir Fun House 2.0"] = "烧伤合集2.0 - 阿兹尔",
["Force Q"] = "强制Q",
["Quick Dash Key"] = "快速突进按键",
["Panic R"] = "惊恐模式R",
["--- Q LOGIC ---"] = "--- Q技能逻辑 ---",
["Q prioritize soldier reposition"] = "Q优先重置沙兵的位置",
["Always expend W before Q Cast"] = "总是Q之前放W",
["--- W LOGIC ---"] = "--- W技能逻辑 ---",
["W Cast Method"] = "释放W的防晒霜",
["Always max range"] = "总是在最大距离",
["Min Mana % to cast extra W"] = "释放额外W的最小蓝量%",
["--- E LOGIC ---"] = "--- E技能逻辑 ---",
["E to target when safe"] = "当安全时E向目标",
["--- R LOGIC ---"] = "--- R技能逻辑 ---",
["Single target R in melee range"] = "处于近战攻击距离的时候只R一个目标",
["To Soldier"] = "向沙兵释放",
["To Ally/Tower"] = "向友军/塔释放",
["Single target R only under self HP"] = "只在自己生命值低于x时只R一个目标",
["Multi target R logic"] = "多目标R逻辑",
["Block"] = "屏蔽",
["Multi target R at least on"] = "多目标R时最小目标数",
["R enemies into walls"] = "把敌军推到墙里",
["Use orbwalking on combo"] = "在连招中使用走砍",
["--- Automated Logic ---"] = "--- 自动技能逻辑 ---",
["Auto R when at least on"] = "当目标至少有x个时自动R",
["Block Sion Ult (Beta)"] = "抵挡塞恩的R(测试)",
["Interrupt channelled spells with R"] = "使用R打断引导技能",
["R enemies back into tower range"] = "把敌人推到塔范围内",
["Block Gap Closers with R"] = "使用R反突进",
["R-Combo Casts"] = "使用R连招",
["--- COMBO-DASH LOGIC ---"] = "--- 突进连招逻辑 ---",
["Smart DASH chase in combo"] = "在追击时使用智能突进连招",
["Min Self HP % to smart dash"] = "自身生命值大于%时使用智能突进",
["Max target HP % to smart dash"] = "目标生命值小于%时使用智能突进",
["Max target HP % dash in R CD"] = "Rcd时目标",
["ASAP R to ally/tower after dash hit"] = " ",
["Dash R Area back range"] = " ",
["--- COMBO-INSEC LOGIC ---"] = "--- Insec连招逻辑 ---",
["Smart new-INSEC in combo"] = "在连招中使用智能新Insec连招",
["new-Insec only x allies more"] = "只在大于x名友军时使用新Insec连招",
["Use W on Harass"] = "在骚扰中使用W",
["Number of W used"] = "使用W的数量",
["Insec / Dash"] = "Insec / 突进",
["Min. gap from soldier in dash"] = "突进时至少存在的沙兵数",
["Abs. R delay after Q cast"] = "当Q释放后释放R的延迟",
["Insec Extension"] = "Insec的延伸距离",
["From Soldier"] = "从沙兵",
["From player"] = "来自玩家",
["Direct Hit"] = "直接击中",
["Use Conquering Sands (Q)"] = "使用Q",
["Use Shifting Sands (E)"] = "使用E",
["Use Emperor's Divide (R)"] = "使用R",
["Use Arise! (W)"] = "使用W",
["Number of Soldiers"] = "沙兵数目",
["Use W for AA if outside AA range"] = "如果在平A范围外使用W攻击",
["Draw Soldier range"] = "显示沙兵的攻击范围",
["Draw Soldier time"] = "显示沙兵持续时间",
["Draw Soldier Line"] = "显示沙兵指示线",
["Soldier and line color"] = "沙兵和指示线线的颜色",
["Soldier out-range color"] = "范围外的沙兵的颜色",
["Draw Dash Area"] = "显示突进的区域",
["Dash color"] = "突进区域颜色",
["Draw Insec range"] = "显示Insec的范围",
["Insec Draws"] = "Insec显示",
["Draw Insec Direction on target"] = "在目标上显示Insec的方向",
["Cast Ignite on Swain"] = "对斯维因使用点燃",
--------------QQQ亚索-----------------------
["Yasuo - The Windwalker"] = "风行者 - 亚索",
["----- General settings --------------------------"] = "----- 常用设置 --------------------------",
["> Keys"] = "> 按键设置",
["> Orbwalker"] = "> 走砍设置",
["> Targetselector"] = "> 目标选择器",
["> Prediction"] = "> 预判设置",
["> Draw"] = "> 显示设置",
["> Cooldowntracker"] = "> 冷却计时",
["> Scripthumanizer"] = "> 脚本拟人化",
["----- Utility settings -----------------------------"] = "----- 功能设置 --------------------------",
["> Windwall"] = "> 风墙",
["> Ultimate"] = "> 大招",
["> Turretdive"] = "> 越塔",
["> Gapclose"] = "> 突进",
["> Walljump"] = "> 穿墙",
["> Spells"] = "> 技能",
["> Summonerspells"] = "> 召唤师技能",
["> Items"] = "> 物品",
["----- Combat settings ----------------------------"] = "----- 战斗设置 --------------------------",
["> Combo"] = "> 连招",
["> Harass"] = "> 骚扰",
["> Killsteal"] = "> 抢人头",
["> Lasthit"] = "> 尾刀",
["> Laneclear"] = "> 清线",
["> Jungleclear"] = "> 清野",
["----- About the script ---------------------------"] = "关于本脚本",
["Gameregion"] = "游戏区域",
["Scriptversion"] = "脚本版本",
["Author"] = "作者",
["Updated"] = "更新日期",
["\"The road to ruin is shorter than you think...\""] = "灭亡之路,短的超乎你的想象。",
["This section is only a placeholder for more structure"] = "这个部分只是待添加内容的预留位置",
["Choose targetselector mode"] = "选择目标选择器位置",
["LESS_CAST"] = "更少使用技能",
["LOW_HP"] = "低血量",
["SELECTED_TARGET"] = "选定的目标",
["PRIORITY"] = "优先级",
["Set your priority here:"] = "在这里设定优先级",
["No targets found / available! "] = "没有找到目标",
["Draw your current target with circle:"] = "在你的当前目标上画圈",
["Draw your current target with line:"] = "在你的当前目标上画线",
["Use Gapclose"] = "使用突进",
["Check health before gapclosing under towers"] = "在塔下突进时检查血量",
["Only gapclose if my health > % "] = "只在我的血量大于%时突进",
["> Settings "] = "> 设置",
["Set Gapclose range"] = "设置突进距离",
["Draw gapclose target"] = "显示突进目标",
["> General settings"] = "> 常规设置",
["Use Autowall: "] = "使用自动风墙:",
["Draw skillshots: "] = "画出技能弹道",
["> Humanizer settings"] = "> 拟人化设置",
["Use Humanizer: "] = "使用拟人化",
["Humanizer level"] = "拟人化等级",
["Normal mode"] = "普通模式",
["Faker mode"] = "Faker模式",
["> Autoattack settings"] = "> 普通攻击设置",
["Block autoattacks: "] = "屏蔽普通攻击:",
["if your health is below %"] = "如果你的生命值低于%",
["> Skillshots"] = "> 技能弹道",
["No supported skillshots found!"] = "没有找到支持的技能",
["> Targeted spells"] = "> 指向性技能",
["No supported targeted spells found!"] = "没有找到支持的指向性技能",
[">> Towerdive settings"] = ">> 越塔设置",
["Towerdive Mode"] = "越塔模式",
["Never dive turrets"] = "从不越塔",
["Advanced mode"] = "高级模式",
["Draw turret range: "] = "显示防御塔范围: ",
[">> Normal Mode Settings"] = ">> 普通模式设置",
["Min number of ally minions"] = "最小友方小兵数",
[">> Easy Mode Settings"] = ">> 简单模式设置",
["Min number of ally champions"] = "最小友方英雄数",
["> Info about normal mode"] = "> 普通模式介绍",
[">| The normal mode checks for x number of ally minions"] = ">| 普通模式会检查防御塔下友方小兵的数量",
[">| under enemy turrets. If ally minions >= X then it allows diving!"] = ">| 如果友方小兵数大于等于x就会允许越塔",
["> Info about advanced mode"] = "> 高级模式介绍",
[">| The advanced mode checks for x number of ally minions"] = "高级模式会检查防御塔下友方小兵数量",
[">| as well as for x number of ally champions under enemy turrets."] = "和防御塔友方英雄数量",
[">| If both >= X then it allows diving!"] = "如果都大于等于x就会允许越塔",
["Always draw the indicators"] = "总是显示伤害预测",
["Only draw while holding"] = "只有在按键的时候才显示",
["Not draw inidicator if pressed"] = "在按键的时候不显示",
["> Draw cooldowns for:"] = "> 显示cd时间",
["your enemies"] = "敌方英雄",
["your allies"] = "友方英雄",
["your hero"] = "自己",
["Show horizontal indicators"] = "显示水平的伤害预测",
["Show vertical indicators"] = "显示垂直的伤害预测",
["Vertical position"] = "垂直伤害预测的位置",
["> Choose your Color"] = "> 选择颜色",
["Cooldown color"] = "cd计时颜色",
["Ready color"] = "技能就绪的颜色",
["Background color"] = "背景颜色",
["> Summoner Spells"] = "> 召唤师技能",
["Flash"] = "闪现",
["Ghost"] = "幽灵疾步",
["Barrier"] = "屏障",
["Smite"] = "惩戒",
["Exhaust"] = "虚弱",
["Heal"] = "治疗",
["Teleport"] = "传送",
["Cleanse"] = "净化",
["Clarity"] = "清晰术",
["Clairvoyance"] = "洞察",
["The Rest"] = "其他",
[">> Combat keys"] = ">> 战斗按键",
["Combo key"] = "连招按键",
["Harass key"] = "骚扰按键",
["Harass (toggle) key"] = "骚扰(开关)按键",
["Ultimate (toggle) key"] = "大招(开关)按键",
[">> Farm keys"] = ">> 发育按键",
["Lasthit key"] = "尾刀按键",
["Jungle- and laneclear key: "] = "清野和清线按键",
[">> Other keys"] = ">> 其他按键",
["Escape-/Walljump key"] = "逃跑/穿墙按键",
["Autowall (toggle) key"] = "自动风墙(开关)按键",
["Use walljump"] = "使用穿墙",
["Priority to gain vision"] = "获得视野的优先级",
["Wards"] = "眼",
["Wall"] = "风墙",
["> Draw jumpspot settings"] = "> 显示穿墙位置",
["Draw points"] = "显示点",
["Draw jumpspot while key pressed"] = "按键按下时显示穿墙位置",
["Radius of the jumpspots"] = "穿墙点半径",
["Max draw distance"] = "最大显示距离",
["Draw line to next jumpspots"] = "显示到下一穿墙点的直线",
["> Draw jumpspot colors"] = "> 显示穿墙点的颜色",
["Jumpspot color"] = "穿墙点的颜色",
["(E) - Sweeping Blade settings: "] = "(E) - 踏前斩设置",
["Increase dashtimer by"] = "增加突进时间",
[">| This option will increase the time how long the script"] = ">| 这项设置会通过一个设定的值来增加",
[">| thinks you are dashing by a fixed value"] = ">| 脚本认为你正在突进的时间",
["Check distance of target and (E)endpos"] = "检查目标和E结束地点的距离",
["Maximum distance"] = "最大距离",
[">| This option will check if the distance"] = ">| 这项设置会检查你的目标",
[">| between your target and the endposition of your (E) cast"] = ">| 和E结束地点的距离",
[">| is greater then the distance set in the slider."] = "如果大于你设定的距离",
[">| If yes the cast will get blocked!"] = "就会屏蔽E的释放",
[">| This prevents dashing too far away from your target!"] = "这会避免你突进时和目标离的太远",
["Auto Level Enable/Disable"] = "自动加点 开启/关闭",
["Auto Level Skills"] = "自动升级技能",
["No Autolevel"] = "不自动加点",
["> Autoultimate"] = "> 自动大招",
["Number of Targets for Auto(R)"] = "自动大招时的目标数",
[">| Auto(R) ignores settings below and only checks for X targets"] = ">| 自动大招会在有X个目标时才释放",
["> General settings:"] = "> 常规设置",
["Delay the ultimate for more CC"] = "延迟大招释放以延长团控时间",
["DelayTime "] = "延迟时间",
["Use (Q) while ulting"] = "当放大时使用Q",
["Use Ultimate under towers"] = "在塔下使用大招",
["> Target settings:"] = "> 目标设置",
["No supported targets found/available"] = "没有找到有效目标",
["> Advanced settings:"] = "> 高级设置:",
["Check for target health"] = "检查目标的血量",
["Only ult if target health below < %"] = "只在目标生命值小于%时使用大招",
["Check for our health"] = "检查自己的血量",
["Only ult if our health bigger > %"] = "只在自己生命值大于%时使用大招",
["General-Settings"] = "常规设置",
["Orbwalker Enabled"] = "启用走砍",
["Allow casts only for targets in camera"] = "只在目标在屏幕上时允许使用技能",
["Windwall only if your hero is on camera"] = "只在你的英雄在屏幕上时使用风墙",
["> Packet settings:"] = "> 封包设置",
["Limit packets to human level"] = "> 限制封包在人类的操作水平",
[">> General settings"] = ">> 常规设置",
["Choose combo mode"] = "选择连招模式",
["Prefer Q3-E"] = "优先Q3-E",
["Prefer E-Q3"] = "优先E-Q3",
["Use items in Combo"] = "在连招中使用物品",
[">> Choose your abilities"] = ">> 选择你的技能",
["(Q) - Use Steel Tempest"] = "使用Q",
["(Q3) - Use Empowered Tempest"] = "使用带旋风的Q",
["(E) - Use Sweeping Blade"] = "使用E",
["(R) - Use Last Breath"] = "使用R",
["Choose mode"] = "选择模式",
["1) Normal harass"] = "1)普通骚扰",
["2) Safe harass"] = "2)安全骚扰",
["3) Smart E-Q-E Harass"] = "3)智能E-Q-E骚扰",
["Enable smart lasthit if no target"] = "启用智能尾刀如果没有目标",
["Enable smart lasthit if target"] = "启用只能尾刀如果有目标",
["|> Smart lasthit will use spellsettings from the lasthitmenu"] = "|> 智能尾刀会使用尾刀菜单里的技能设置",
["|> Mode 1 will simply harass your enemy with spells"] = "|> 模式1会简单的用技能骚扰敌方",
["|> Mode 2 will harass your enemy and e back if possible"] = "|> 模式2会骚扰敌方并且如果可能的话E回来",
["|> Mode 3 will engage with e - harass and e back if possible"] = "|> 模式3会给E充能并骚扰对面再E回来",
["Use Smart Killsteal"] = "使用智能抢人头",
["Use items for Laneclear"] = "在清线时使用物品",
["Choose laneclear mode for (E)"] = "选择E清线的模式",
["Only lasthit with (E)"] = "只用E补尾刀",
["Use (E) always"] = "总是使用E",
["Choose laneclear mode for (Q3)"] = "选择带旋风的Q的清线模式",
["Cast to best pos"] = "在最佳位置释放",
["Cast to X or more amount of units "] = "当大于等于X个单位时释放",
["Min units to hit with (Q3)"] = "使用Q3时的最小单位数",
["Check health for using (E)"] = "使用E前检查血量",
["Only use (E) if health > %"] = "只在生命值大于%时使用E",
[">> Choose your spinsettings"] = ">> 选择环形Q设置",
["Prioritize spinning (Q)"] = "优先环形Q",
["Prioritize spinning (Q3)"] = "优先环形Q3",
["Min units to hit with spinning"] = "环形Q能击中的最小单位数",
["Use items to for Jungleclear"] = "清野时使用物品",
["Choose Prediction mode"] = "选择预判模式",
[">> VPrediction"] = ">> V预判",
["Hitchance of (Q): "] = "Q命中的机会",
["Hitchance of (Q3): "] = "Q3命中的机会",
[">> HPrediction"] = ">> H预判",
[">> Found Summonerspells"] = ">> 召唤师技能",
["No supported spells found"] = "没有找到支持的召唤师技能",
["Disable ALL drawings of the script"] = "关闭此脚本的所有显示",
["Draw spells only if not on cooldown"] = "只显示就绪的技能线圈",
["Draw fps friendly circles"] = "使用不影响fps的线圈",
["Choose strength of the circle"] = "选择线圈的质量",
["> Other settings:"] = "> 其他设置",
["Draw airborne targets"] = "显示被击飞的目标",
["Draw remaining (Q3) time"] = "显示Q3剩余时间",
["Draw damage on Healthbar: "] = "在血条上显示伤害",
["> Draw range of spell"] = "> 显示技能范围",
["Draw (Q): "] = "显示Q",
["Draw (Q3): "] = "显示Q3",
["Draw (E): "] = "显示E",
["Draw (W): "] = "显示W",
["Draw (R): "] = "显示R",
["> Draw color of spell"] = "> 显示线圈的颜色",
["(Q) Color:"] = "Q颜色",
["(Q3) Color:"] = "Q3颜色",
["(W) Color:"] = "W颜色",
["(E) Color:"] = "E颜色",
["(R) Color:"] = "R颜色",
["Healthbar Damage Drawings: "] = "血条伤害显示",
["Startingheight of the lines: "] = "指示线高度",
["Draw smart (Q)+(E)-Damage: "] = "显示智能Q+E伤害",
["Draw (Q)-Damage: "] = "显示Q伤害",
["Draw (Q3)-Damage: "] = "显示Q3伤害",
["Draw (E)-Damage: "] = "显示E伤害",
["Draw (R)-Damage: "] = "显示R伤害",
["Draw Ignite-Damage: "] = "显示点燃伤害",
["Permashow: "] = "状态显示:",
["Permashow HarassToggleKey "] = "显示骚扰开关按键",
["Permashow UltimateToggleKey"] = "显示大招开关按键",
["Permashow Autowall Key"] = "显示自动风墙按键",
["Permashow Prediction"] = "显示预判状态",
["Permashow Walljump"] = "显示风墙状态",
["Permashow HarassMode"] = "显示骚扰模式",
[">| You need to reload the script (2xF9) after changes here!"] = ">| 修改此处设置后你需要F9两次",
["> Healthpotions:"] = "> 自动血药",
["Use Healthpotions"] = "使用血瓶",
["if my health % is below"] = "如果自己生命值低于%",
["Only use pots if enemys around you"] = "只在附近有敌人的时候自动使用药水",
["Range to check"] = "检查范围",
------------------------神圣意识-------------------------
["Divine Awareness"] = "神圣意识",
["Debug Settings"] = "调试设置",
["Colors"] = "颜色",
["Stealth/sight wards/stones/totems"] = "隐形单位/眼/眼石/饰品",
["Vision wards/totems"] = "显示眼位",
["Traps"] = "陷阱",
["Key Bindings"] = "键位设置",
["Wards/Traps Range (DEFAULT IS ~ KEY)"] = "眼位/陷阱范围(默认是~键)",
["Enemy Vision (default ~)"] = "敌方视野(默认是~键)",
["Timers Call (default CTRL)"] = "计时器(默认Ctrl键)",
["Mark Wards and Traps"] = "标记眼位和陷阱",
["Mark enemy flashes/dashes/blinks"] = "标记敌人的闪现/突进技能",
["Towers"] = "防御塔",
["Draw enemy tower ranges"] = "画出敌人塔范围",
["Draw ally tower ranges"] = "画出友方塔范围",
["Draw tower ranges at distance"] = "在一定距离内才显示塔范围",
["Timers"] = "计时器",
["Display Jungle Timers"] = "显示打野计时",
["Display Inhibitor Timers"] = "显示水晶计时",
["Display Health-Relic Timers"] = "显示据点计时",
["Way Points"] = "路径显示",
["Draw enemy paths"] = "显示敌人的路线",
["Draw ally paths"] = "显示友军的路线",
["Draw last-seen champ map icon"] = "在小地图显示敌人最后一次出现的位置",
["Draw enemy FoW minions line"] = "显示战争迷雾里的兵线",
["Notification Settings"] = "提示设置",
["Gank Prediction"] = "Gank预测",
["Feature"] = "特点",
["Play alert sound"] = "播放提示音",
["Add to screen text alert"] = "在屏幕显示提示文字",
["Draw screen notification circle"] = "在屏幕显示提示线圈",
["Print in chat (local) a gank notification"] = "在聊天框显示gank提示(本地的)",
["FoW Camps Attack"] = "战争迷雾伏击",
["Log to Chatbox."] = "登陆ChatBox",
["Auto SS caller / Pinger"] = "敌人消失自动提醒/标记",
["Summoner Spells and Ult"] = "召唤师技能和大招",
["Send timers to chat"] = "将计时器发送到聊天框",
["Key (requires cursor over tracker)"] = "按键(需要鼠标移动至cd监视器)",
["On FoW teleport/recall log client-sided chat notification"] = "聊天框提醒战争迷雾里的传送/回城",
["Cooldown Tracker"] = "cd监视",
["HUD Style"] = "HUD风格",
["Chrome [Vertical]"] = "Chrome[垂直的]",
["Chrome [Horizontal] "] = "Chrome[水平的]",
[" Classic [Vertical]"] = "经典 [垂直的]",
["Classic [Horizontal]"] = "经典 [水平的]",
["Lock Side HUDS"] = "锁定HUD",
["Show Allies Side CD Tracker"] = "显示友方的cd",
["Show Enemies Side CD Tracker"] = "显示敌方的cd",
["Show Allies Over-Head CD Tracker"] = "显示友军头顶的cd",
["Show Enemies Over-Head CD Tracker"] = "显示敌方头顶的cd",
["Include me in tracker"] = "显示自己的cd",
["Cooldown Tracker Size"] = "cd计时器大小",
["Reload Sprites (default J)"] = "重新加载图片(默认J)",
["Enable Scarra Warding Assistance"] = "启用插眼助手",
["Automations"] = "自动",
["Lantern Grabber"] = "自动捡灯笼",
["Max Radius to trigger"] = "触发的最大半径",
["Hotkey to trigger"] = "触发的按键",
["Allow automation based on health"] = "取决于生命值的自动",
["Auto trigger when health% < "] = "当生命值小于%时自动触发",
["Enable BaseHit"] = "启用基地大招",
["Auto Level Sequence"] = "自动加点顺序",
["Auto Leveling"] = "自动加点",
["Vision ward on units stealth spells"] = "自动插真眼反隐",
["Voice Awareness"] = "语音提示",
["Mode"] = "模式",
["Real"] = "真人声音",
["Robot"] = "机器人声音",
["Gank Alert Announcement"] = "Gank提示",
["Recall/Teleport Announcement"] = "回城/传送提示",
["Compliments upon killing a champ"] = "杀敌之后的称赞",
["Motivations upon dying"] = "死亡之后的鼓舞",
["Camp 1 min respawn reminder"] = "水晶1分钟复活提醒",
["Base Hit Announcement"] = "基地大招提示",
["FoW  Camps Attack Alert"] = "在战争迷雾中的攻击警告",
["Evade Assistance"] = "躲避助手",
["Patch "] = "版本",
-----------------------Better Nerf卡牌----------------
["[Better Nerf] Twisted Fate"] = "[Better Nerf] 卡牌大师",
["[Developer]"] = "[开发者]",
["Donations are fully voluntary and highly appreciated"] = "捐助是完全自愿的,并且我们非常感谢捐助",
["[Orbwalker]"] = "[走砍]",
["Lux"] = "拉克丝",
["[Targetselector]"] = "[目标选择器]",
["[Prediction]"] = "[预判]",
["Extra delay"] = "额外延迟",
["Auto adjust delay (experimental)"] = "自动调整延迟(测试)",
["[Performance]"] = "[性能设置]",
["Limit ticks"] = "限制按键次数",
["Checks per second"] = "每秒检查",
["[Card Picker]"] = "[切牌器]",
["Enable"] = "启用",
["Gold"] = "黄牌",
["[Ultimate]"] = "[大招]",
["Cast predicted Ultimate through sprite"] = "通过小地图使用预判大招",
["Adjust R range"] = "调整R范围",
["Pick card when porting with Ultimate"] = "大招传送时选牌",
["[Combo]"] = "[连招]",
["Logic"] = "逻辑",
["[Wild Cards]"] = "[万能牌(Q)]",
["Stunned"] = "眩晕",
["Hitchance"] = "命中几率",
["Ignore Logic if enemy closer <"] = "敌军距离小于x时不使用连招逻辑",
["Max Distance"] = "最大距离",
["[Pick a Card]"] = "[选牌(W)]",
["Card picker"] = "切牌器",
["Pick card logic"] = "选牌逻辑",
["Distance check"] = "距离检测",
["Pick red, if hit more than 1"] = "如果能击中多于一个敌人就切红牌",
["Pick Blue if mana is below %"] = "如果蓝量低于%就切蓝牌",
[" > Use (Q) - Wild Cards"] = " > 使用Q - 万能牌",
[" > Use (W) - Pick a Card"] = "> 使用W - 选牌",
["Don't combo if mana < %"] = "如果蓝量低于%不使用连招",
["[Harass]"] = "[骚扰]",
["Harass #1"] = "骚扰 #1",
["Don't harass if mana < %"] = "蓝量低于%时不骚扰",
["[Farm]"] = "[发育]",
["Card"] = "切牌",
["Clear!"] = "清线",
["Don't farm with Q if mana < %"] = "蓝量低于%时不使用Q",
["Don't farm with W if mana < %"] = "蓝量低于%时不使用W",
["[Jungle Farm]"] = "[清野]",
["Jungle Farm!"] = "清野!",
["[Draw]"] = "[显示设置]",
["[Hitbox]"] = "[命中体积]",
["Color"] = "颜色",
["Quality"] = "质量",
["Width"] = "宽度",
["[Q - Wild Cards]"] = "Q -万能牌",
["Ready"] = "就绪",
["Draw mode"] = "显示模式",
["Default"] = "默认",
["Highlight"] = "高亮",
["[W - Pick a Card]"] = "[W - 选牌]",
["[E - Stacked Deck]"] = "[E - 卡牌骗术]",
["Text"] = "文字",
["Sprite"] = "图片",
["[TEXT]"] = "[文字]",
["[SPRITE]"] = "[图片]",
["Color Stack 1-3"] = "颜色叠加 1-3",
["Color Stack 4"] = "颜色叠加 4",
["Color Background"] = "颜色背景",
["[R - Destiny]"] = "[R - 命运]",
["Enable Minimap"] = "在小地图上启用显示",
["Draw Sprite Panel"] = "显示控制面板",
["Draw Alerter Text"] = "显示提醒文字",
["Draw click hitbox"] = "显示点击命中体积",
["Adjust width"] = "调整宽度",
["Adjust height"] = "调整高度",
["[Damage HP Bar]"] = "[血条伤害显示]",
["Draw damage info"] = "显示伤害信息",
["Color Text"] = "文字颜色",
["Color Bar"] = "血条颜色颜色",
["Color near Death"] = "接近死亡的颜色",
["Color Kill"] = "可以击杀的颜色",
["Calc x Auto Attacks"] = "计算平A次数",
["Lag-Free-Circles"] = "不影响延迟的线圈",
["Disable all Draws"] = "关闭所有的显示",
["[Killsteal]"] = "[抢人头]",
["Use Wild Cards"] = "使用Q",
["[Misc]"] = "[杂项设置]",
["[Rescue Pick]"] = "[保命选牌]",
["time"] = "时间",
["factor"] = "因素",
["[Auto Q immobile]"] = "[不能移动时自动Q]",
["Don't Q Lux"] = "不要对拉克丝使用Q",
["[Debug]"] = "[调试]",
["Spell Data"] = "技能数据",
["Prediction / minion hit"] = "预判 / 击中小兵",
["TargetSelector Mode"] = "目标选择器模式",
["LESS CAST"] = "更少使用技能",
["LESS CAST PRIORITY"] = "更少使用技能+优先级",
["NEAR MOUSE"] = "离鼠标最近",
["MOST AD"] = "AD最高",
["MOST AP"] = "AP最高",
["Damage Type"] = "伤害类型",
["MAGICAL"] = "魔法",
["PHYSICAL"] = "物理",
["Range"] = "范围",
["Draw for easy Setup"] = "容易设置的显示模式",
["Draw target"] = "显示目标",
["Circle"] = "线圈",
["ESP BOX"] = "ESP盒子",
["Blue"] = "蓝色",
["Red"] = "红色",
-----------------------滚筒机器薇恩-------------------------
["Tumble Machine Vayne"] = "滚筒机器 VN",
["Enable Packet Features"] = "启用封包",
["Combo Settings"] = "连招设置",
["AA Reset Q Method"] = "Q重置普通的方式",
["Forward and Back Arcs"] = "向前或向后Q",
["Everywhere"] = "任何位置",
["Use gap-close Q"] = "使用Q接近敌人",
["Use Q in Combo"] = "在连招中使用Q",
["Use E in Combo"] = "在连招中使用E",
["Use R in Combo"] = "在连招中使用R",
["Ward bush loss of vision"] = "敌人进草时自动插眼",
["Harass Settings"] = "骚扰设置",
["Use Harass Mode during: "] = "使用骚扰模式：",
["Harass Only"] = "只骚扰",
["Both Harass and Laneclear"] = "骚扰和清线",
["Forward Arc"] = "向前时",
["Side to Side"] = "从敌人一侧到另一侧",
["Old Side Method"] = "旧版本策略",
["Use Q in Harass"] = "在骚扰中使用Q",
["Use E in Harass"] = "在骚扰中使用E",
["Spell Settings"] = "技能设置",
["Q Settings"] = "Q技能设置",
["Use AA reset Q"] = "使用Q重置普攻",
["      ON"] = "开",
["ON: 3rd Proc"] = "第三次普攻",
["Use gap-close Q - Burst Harass"] = "使用Q接近 - 爆发骚扰模式",
["E Settings"] = "E技能设置",
["Use E Finisher"] = "使用E击杀",
["Don't E KS if # enemies near is >"] = "当附近敌人大于x时不要用E抢人头",
["Don't E KS if level is >"] = "当等级大于x时不要用E抢人头",
["E KS if near death"] = "如果濒死使用E抢人头",
["Calculate condemn-flash at:"] = "使用E闪：",
["Mouse Flash Position"] = "以鼠标位置为闪现位置",
["All Possible Flash Positions"] = "所有可能的闪现位置",
["R Settings"] = "R技能设置",
["Stay invis long as possible"] = "尽可能长时间的保持隐身状态",
["Stay invis min enemies"] = "保持隐身状态的最小敌人数",
["    Activate R"] = "自动R",
["R min enemies to use"] = "使用R的最小敌人数",
["Use R if Health% <="]	= "如果生命值小于等于%",
["Use R if in danger"] = "在危险情况下使用R",
["Use Q after R if danger"] = "在危险情况下使用RQ隐身",
["Special Condemn Settings"] = "特殊击退设置",
["Anti-Gap Close Settings"] = "反突进设置",
["Enable"] = "启用",
["Interrupt Settings"] = "打断设置",
["Tower Insec Settings"] = "防御塔Insec设置",
["Make Key Toggle"] = "使用按键开关",
["Max Enemy Minions (1)"] = "最大敌方小兵数",
["Max Range From Tower"] = "离塔的最大距离",
["Use On:"] = "使用的对象：",
["Target"] = "目标",
["Anyone"] = "任何人",
["Frequency:"] = "使用频率",
["More Often"] = "更频繁",
["More Accurate"] = "更精准",
["Q and Flash Usage:"] = "Q和闪现的使用",
["Q First"] = "先Q",
["Flash First"] = "先闪现",
["Never Use Q"] = "从不使用Q",
["Never Use Flash"] = "从不使用闪现",
["Wall Condemn Settings"] = "定墙设置",
["Use on Lucian"] = "对卢锡安使用",
["   If enemy health % <="] = "   如果敌人生命值小于<",
["Use wall condemn on"] = "使用定墙的对象",
["All listed"] = "所有列表里的目标",
["Use wall condemn during:"] = "以下情况下使用定墙",
["Combo and Harass"] = "连招和骚扰",
["Always On"] = "总是使用",
["Wall condemn accuracy"] = "定墙精准度",
["     Jungle Settings"] = "     清野设置",
["Use Q-AA reset on:"] = "以下情况使用Q重置普攻",
["All Jungle"] = "所有野怪",
["Large Monsters Only"] = "只是大型野怪",
["Wall Stun Large Monsters"] = "对大型野怪使用定墙",
["Disable Wall Stun at Level"] = "在等级x时禁用定墙",
["Jungle Clear Spells if Mana >"] = "如果蓝量大于x时才使用清野",
["     Lane Settings"] = "     清线设置",
["Q Method:"] = "Q使用方式",
["Lane Clear Q:"] = "清线中使用Q",
["Dash to Mouse"] = "位移至鼠标方向",
["Dash to Wall"] = "位移至墙",
["Lane Clear Spells if Mana >"] = "在清线中使用技能如果蓝量大于%",
["Humanize Clear Interval (Seconds)"] = "拟人化清线间隔(秒)",
["Tower Farm Help (Experimental)"] = "塔下发育助手(测试)",
["Item Settings"] = "物品设置",
["Offensive Items"] = "进攻型物品",
["Use Items During"] = "在以下情况使用",
["Combo and Harass Modes"] = "连招和骚扰模式",
["If My Health % is Less Than"] = "如果生命值低于%",
["If Target Health % is Less Than"] = "如果目标生命值低于%",
["QSS/Cleanse Settings"] = "水银/净化设置",
["Remove CC during: "] = "以下情况净化团控技能",
["Remove Exhaust"] = "净化虚弱",
["QSS Blitz Grab"] = "净化机器人的勾",
["Humanizer Delay (ms)"] = "人性化延迟(毫秒)",
["Use HP Potions During"] = "以下情况使用血药",
["Use HP Pot If Health % <"] = "生命值低于%使用血药",
["Damage Draw Settings"] = "伤害显示设置",
["Draw E DMG on bar:"] = "在血条显示E的伤害",
["Ascending"] = "上升",
["Descending"] = "下降",
["Draw E Text:"] = "显示E技能提示文字",
["Percentage"] = "百分比",
["Number"] = "数字",
["AA Remaining"] = "击杀剩余平A数",
["Grey out health"] = "灰色伤害溢出",
["Disable All Range Draws"] = "关闭所有范围显示",
["Draw Circle on Target"] = "在目标上显示线圈",
["Draw AA/E Range"] = "显示平A/E范围",
["Draw My Hitbox"] = "显示自己的命中体积",
["Draw (Q) Range"] = "显示Q的范围",
["Draw Passive Stacks"] = "显示被动层数",
["Draw Ult Invis Timer"] = "显示大招隐身计时器",
["Draw Attacks"] = "显示攻击",
["Draw Tower Insec"] = "显示防御塔Insec",
["While Key Pressed"] = "当按键按下时",
["Enable Streaming Mode (F7)"] = "启用流模式(F7)",
["General Settings"] = "常规设置",
["Auto Level Spells"] = "自动加点",
["Disable auto-level for first level"] = "在1级时关闭自动加点",
["Level order"] = "加点顺序",
["First 4 Levels Order"] = "前4级加点顺序",
["Display alert messages"] = "显示警告信息",
["Left Click Focus Target"] = "左键点击锁定目标",
["Off"] = "关闭",
["Permanent"] = "永久的",
["For One Minute"] = "持续一分钟",
["Target Mode:"] = "目标选择模式:",
["Easiest to kill"] = "最容易击杀",
["Less Cast Priority"] = "更少使用技能+优先级",
["Don't KS shield casters"] = "不要对有护盾技能的目标使用抢人头",
["Get to lane faster"] = "上线更快",
["Double Edge Sword Mastery?"] = "双刃剑天赋",
["No"] = "否",
["Yes"] = "是",
["Turn on Debug"] = "打开调试模式",
["Orbwalking Settings"] = "走砍设置",
["Keybindings"] = "键位设置",
["Escape Key"] = "逃跑按键",
["Burst Harass"] = "爆发骚扰连招",
["Condemn on Next AA (Toggle)"] = "下次平A推开目标(开关)",
["Flash Condemn"] = "闪现E",
["Disable Wall Condemn (Toggle)"] = "关闭定墙(开关)",
["   Use custom combat keys"] = "   使用习惯的战斗按键",
["Click For Instructions"] = "点击指令",
["Select Skin"] = "选择皮肤",
["Original Skin"] = "经典皮肤",
["Vindicator Vayne"] = "摩登骇客 薇恩",
["Aristocrat Vayne"] = "猎天使魔女 薇恩",
["Heartseeker Vayne"] = "觅心猎手 薇恩",
["Dragonslayer Vayne - Red"] = "屠龙勇士 薇恩 - 红色",
["Dragonslayer Vayne - Green"] = "屠龙勇士 薇恩 - 绿色",
["Dragonslayer Vayne - Blue"] = "屠龙勇士 薇恩 - 蓝色",
["Dragonslayer Vayne - Light Blue"] = "屠龙勇士 薇恩 - 浅蓝色",
["SKT T1 Vayne"] = "SKT T1 薇恩",
["Arc Vayne"] = "苍穹之光 薇恩",
["Snow Bard"] = "冰雪游神 巴德",
["No Gap Close Enemy Spells Detected"] = "没有检测到敌人的突进技能",
["Lucian Ult - Enable"] = "卢锡安大招 - 启用",
["     Humanizer Delay (ms)"] = "     拟人化延迟(毫秒)",
["Teleport - Enable"] = "传送 - 启用",
["Choose Free Orbwalker"] = "选择免费走砍",
["Nebelwolfi's Orbwalker"] = "Nebelwolfi走砍",
["Modes"] = "模式",
["Attack"] = "攻击",
["Move"] = "移动",
["LastHit Mode"] = "尾刀模式",
["Attack Enemy on Lasthit (Anti-Farm)"] = "敌人尾刀时攻击(阻止敌人发育)",
["LaneClear Mode"] = "清线模式",
["                    Mode Hotkeys"] = "                    模式热键",
[" -> Parameter mode:"] = "-> 参数模式",
["On/Off"] = "开/关",
["KeyDown"] = "按住按键",
["KeyToggle"] = "开关按键",
["                    Other Hotkeys"] = "                    其他热键",
["Left-Click Action"] = "左键动作",
["Lane Freeze (F1)"] = "猥琐补刀(F1)",
["Settings"] = "设置",
["Sticky radius to mouse"] = "停止不动的区域半径",
["Low HP"] = "低血量",
["Most AP"] = "AP最高",
["Most AD"] = "AD最高",
["Less Cast"] = "更少使用技能",
["Near Mouse"] = "离鼠标最近",
["Low HP Priority"] = "低血量+优先级",
["Dead"] = "死亡的",
["Closest"] = "最近的",
["Blade of the Ruined King"] = "破败王者之刃",
["Bilgewater Cutlass"] = "比尔吉沃特弯刀",
["Hextech Gunblade"] = "海克斯科技枪刃",
["Ravenous Hydra"] = "贪欲九头蛇",
["Titanic Hydra"] = "巨型九头蛇",
["Tiamat"] = "提亚马特",
["Entropy"] = "冰霜战锤",
["Yomuu's Ghostblade"] = "幽梦之灵",
["Farm Modes"] = "发育模式",
["Use Tiamat/Hydra to Lasthit"] = "使用提亚马特/九头蛇尾刀",
["Butcher"] = "屠夫",
["Arcane Blade"] = "双刃剑",
["Havoc"] = "毁灭",
["Advanced Tower farming (experimental"] = "高级塔下发育模式(测试)",
["LaneClear method"] = "清线方式",
["Highest"] = "最高效率",
["Stick to 1"] = "锁定一个小兵",
["Draw LastHit Indicator (LastHit Mode)"] = "显示尾刀指示器(尾刀模式)",
["Always Draw LastHit Indicator"] = "总是显示尾刀指示器",
["Lasthit Indicator Style"] = "尾刀指示器样式",
["New"] = "新",
["Old"] = "旧",
["Show Lasthit Indicator if"] = "以下情况显示尾刀指示器",
["1 AA-Kill"] = "一次平A击杀",
["2 AA-Kill"] = "两次平A击杀",
["3 AA-Kill"] = "三次平A击杀",
["Own AA Circle"] = "自己的平A线圈",
["Enemy AA Circles"] = "敌人的平A线圈",
["Lag Free Circles"] = "不影响延迟的线圈",
["Draw - General toggle"] = "显示 - 常规开关",
["Timing Settings"] = "计时设置",
["Cancel AA adjustment"] = "取消平A后摇调整",
["Lasthit adjustment"] = "尾刀调整",
["Version:"] = "版本:",
["Combat keys are located in orbwalking settings"] = "战斗按键在走砍里设置",
-----------------------时间机器艾克--------------
["Time Machine Ekko"] = "时间机器 艾克",
["Skin Changer"] = "皮肤切换",
["Sandstorm Ekko"] = "时之砂 艾克",
["Academy Ekko"] = "任性学霸 艾克",
["Use Q combo if  mana is above"] = "如果蓝量高于x使用Q连招",
["Use E combo if  mana is above"] = "如果蓝量高于x使用E连招",
["Use Q Correct Dash if mana >"] = "如果蓝量高于x使用E修正二段Q的方向",
["Reveal enemy in bush"] = "对草丛里的敌人自动插眼",
["Use Target W in Combo"] = "在连招中有目的性的使用W",
["W if it can hit X "] = "如果能击中X个敌人使用R",
["Use Q harass if  mana is above"] = "如果蓝量高于x使用Q骚扰",
["Harass Q last hit and hit enemy"] = "骚扰中使用Q补尾刀以及击中敌人",
["Auto-move to hit 2nd Q in Combo"] = "自动移动来使二段Q命中",
["On"] = "开",
["On and Draw"] = "打开并显示",
["Long Range W Engage"] = "战斗中使用远距离W",
["Long Range Before E Engage"] = "战斗中在E之前使用远距离W",
["During E Engage"] = "战斗使用E的时候",
["Use W on CC or slow"] = "使用W来打团控或者群体减速",
["Don't use E in AA range unless KS"] = "敌人在平A范围内时除了抢人头不要使用E",
["Offensive Ultimate Settings"] = "进攻性大招设置",
["Ult Target in Combo if"] = "以下情况在连招中使用大招",
["Target health % below"] = "目标生命值低于%",
["My health % below"] = "自己生命值低于%",
["Ult if 1 enemy is killable"] = "如果有1名敌人可击杀时使用R",
["Ult if 2 or more"] = "如果有2名或更多敌人可击杀时使用R",
["will go below 35% health"] = "会在血量低于35%的时候触发",
["Ult if set amount"] = "如果到达设定数值则使用R",
["will get hit"] = "即将收到攻击",
["Offensive Ult During:"] = "以下情况使用进攻性大招",
["Combo Only"] = "只在连招里使用",
["Block ult in combo mode if ult won't hit"] = "如果大招不能击中则不在连招中使用大招",
["Defensive Ult/Zhonya Settings"] = "防御性大招/中亚设置",
["Use if about to die"] = "濒死时使用",
["Only Defensive Ult if my"] = "如果自身情况满足..则使用防御性大招",
["health is less than targets"] = "生命值低于目标生命值",
["Ult if heal % is >"] = "大招治疗生命值高于%时使用R",
["Defensive Ult During:"] = "以下情况使用防御性大招：",
["Wave Clear Settings"] = "清线设置",
["Use Q in Wave Clear"] = "使用Q清线",
["Scenario 1:"] = "方案 1：",
["Minimum lane minions to hit "] = "至少击中的小兵数",
["Use Q if  mana is above"] = "如果蓝量高于x时使用Q",
["Must hit enemy also"] = "必须同时击中敌人",
["Scenario 2:"] = "方案 2：",
["---Jungle---"] = "---清野设置---",
["Use W in Jungle Clear"] = "使用W清野",
["Use E in Jungle Clear"] = "使用E清野",
["Escape Settings"] = "逃跑设置",
["Cast W direction you are heading"] = "向你面朝的方向使用W",
["Draw (W) Max Reachable Range"] = "显示能到达的W最大范围",
["Draw (E) Range"] = "显示E技能范围",
["Draw (R) Range"] = "显示R技能范围",
["Draw Line to R Spot"] = "在R的地点画指示线",
["Draw Passive Stack Counters"] = "显示被动层数指示器",
["Display ult hit count"] = "显示大招能击中的敌人数",
["Draw Tower Ranges"] = "显示防御塔范围",
["Damage Drawings"] = "显示伤害",
["Enable Bar Drawings"] = "启用血条伤害显示",
["Separated"] = "分离的",
["Combined"] = "一体的",
["Draw Bar Letters"] = "在血条上显示技能字母",
["Draw Bar Shadows"] = "显示血条阴影",
["Draw Bar Kill Text"] = "显示血条击杀提示",
["Draw (Q) Damage"] = "显示Q的伤害",
["Draw (E) Damage"] = "显示E的伤害",
["Draw (R) Damage"] = "显示R的伤害",
["Draw (I) Ignite Damage"] = "显示I(点燃)的伤害",
["Q Helper"] = "Q技能助手",
["Enable Q  Helper"] = "启用Q技能助手",
["Draw Box"] = "显示方框",
["Draw Minion Circles"] = "在小兵上显示线圈",
["Draw Enemy Circles"] = "在敌人上显示线圈",
["Item/Smite Settings"] = "物品/惩戒设置",
["Offensive Smite"] = "进攻性惩戒",
["Use Champion Smite During"] = "在以下情况对英雄使用惩戒",
["Combo and Lane Clear"] = "连招和清线",
["Use Smart Ignite"] = "使用智能点燃",
["Optimal"] = "最佳时机",
["Aggressive"] = "侵略性的",
["Prediction Method:"] = "预判方式:",
["Divine Prediction"] = "神圣预判",
["Make sure these are on unique keys"] = "确保以下按键是独立的",
["Wave Clear Key"] = "清线按键",
["Jungle KS Key"] = "清野/抢人头按键",
["Use on ShenE"] = "对慎的E使用",
["      Enable"] = "      启用",
["      Health % < "] = "      生命值低于%",
------------------------Raphlol女枪小炮--------------
["Ralphlol: Miss Fortune"] = "Raphlol:女枪",
["Use W if  mana is above"] = "蓝量高于x时使用W",
["Use E if  mana is above"] = "蓝量高于x时使用E",
["Use Q bounce in Combo"] = "在连招中使用Q弹射敌人",
["Use W in Combo"] = "在连招中使用W",
["Use E more often in Combo"] = "在连招中更频繁地使用E",
["(Q) to Minions"] = "Q小兵",
["Ignore High Health Tanks"] = "忽略高血量的坦克/肉盾",
["Only (Q) minions that will die"] = "只对能Q死的小兵使用Q",
["Use Harass also during Lane Clear"] = "在清线的时候依然骚扰对面",
["Use Q bounce in Harass"] = "在骚扰中使用Q弹射",
["Use W in Harass"] = "在骚扰中使用W",
["Ultimate Settings"] = "大招设置",
["Auto Ult During"] = "以下情况使用自动大招",
["Use Ult if X enemy hit"] = "如果能击中x名敌人使用自动大招",
["Use Ult if target will die"] = "如果目标能击杀时使用自动大招",
["Use on stunned targets"] = "对被眩晕的目标使用",
["Only AutoUlt if CC Nearby <="]= "如果附近的团控小于等于X使用自动大招",
["Cancel Ult if no more enemies inside"] = "如果R范围内没有敌人则取消大招",
["Cancel Ult when you right click"] = "当你点击右键的时候取消大招",
["Block Ult cast if it will miss"] = "如果大招打不中的话就屏蔽大招释放",
["(Shift Override)"] = "(覆盖Shift)",
["Clear Settings"] = "清线设置",
["Jungle Clear Settings"] = "清野设置",
["Use Q in Jungle Clear"] = "在清野中使用Q",
["Show notifications"] = "显示提示信息",
["Show CC Counter"] = "显示团控计数",
["Show Q Bounce Counter"] = "显示Q弹射计数",
["Draw (Q) Arcs"] = "显示Q弹射的范围",
["Draw (Q) Killable Minions"] = "显示Q能击杀的小兵",
["(R) Damage Drawing"] = "显示R的伤害",
["Minimum Duration"] = "最小持续时间",
["Full Duration"] = "最大持续时间",
["Assisted (E) Key"] = "辅助E按键",
["Assisted (R) Key"] = "辅助R按键",
["Ralphlol: Tristana"] = "Raphlol:小炮",
["E Harass White List"] = "E骚扰敌人列表",
["Use on Brand"] = "对布兰德使用",
["Enable Danger Ultimate"] = "启用危险时自动大招",
["Use on self"] = "对自己使用",
["Anti-Gap Settings"] = "反突进设置",
["Draw AA/R/E Range"] = "显示平A/R/E的范围",
["Draw (W) Range"] = "显示W范围",
["Draw (W) Spot"] = "显示W的落地点",
["All-In Key "] = "全力输出按键",
["Assisted (W) Key"] = "辅助W按键",
["(E) Wave Key"] = "E清线按键",
["Panic Ult Key"] = "保命大招按键",
-------------挑战者中单合集---------------
["SimpleLib - Orbwalk Manager"] = "SimpleLib - 走砍管理器",
["Orbwalker Selection"] = "走砍选择",
["SxOrbWalk"] = "Sx走砍",
["Big Fat Walk"] = "胖子走砍",
["Forbidden Ezreal by Da Vinci"] = "挑战者中单合集 - 伊泽瑞尔",
["SimpleLib - Spell Manager"] = "SimpleLib - 技能管理器",
["Enable Packets"] = "使用封包",
["Enable No-Face Exploit"] = "使用开发者模式",
["Disable All Draws"] = "关闭所有显示",
["Set All Skillshots to: "] = "将所有技能的预判调整为：",
["HPrediction"] = "H预判",
["DivinePred"] = "神圣预判",
["SPrediction"] = "S预判",
["Q Settings"] = "Q技能设置",
["Prediction Selection"] = "预判选择",
["X % Combo Accuracy"] = "连招精准度X%",
["X % Harass Accuracy"] = "骚扰精准度X%",
["80 % ~ Super High Accuracy"] = "80% ~ 极高精准度",
["60 % ~ High Accuracy (Recommended)"] = "60% ~ 高精准度(推荐)",
["30 % ~ Medium Accuracy"] = "30% ~ 中精准度",
["10 % ~ Low Accuracy"] = "10% ~ 低精准度",
["Drawing Settings"] = "绘图设置",
["Enable"] = "生效",
["Color"] = "颜色",
["Width"] = "宽度",
["Quality"] = "质量",
["W Settings"] = "W技能设置",
["E Settings"] = "E技能设置",
["R Settings"] = "R技能设置",
["Ezreal - Target Selector Settings"] = "[伊泽瑞尔] - 目标选择器设置",
["Shen"] = "慎",
["Draw circle on Target"] = "在目标上画圈",
["Draw circle for Range"] = "线圈范围",
["Ezreal - General Settings"] = "[伊泽瑞尔] - 常规设置",
["Overkill % for Dmg Predict.."] = "伤害溢出判断X%",
["Ezreal - Combo Settings"] = "[伊泽瑞尔] - 连招设置",
["Use Q"] = "使用Q",
["Use W"] = "使用W",
["Use R If Enemies >="]	= "如果敌人数量大于等于",
["Ezreal - Harass Settings"] = "[伊泽瑞尔] - 骚扰设置",
["Min. Mana Percent: "] = "最小蓝量百分比：",
["Ezreal - LaneClear Settings"] = "[伊泽瑞尔] - 清线设置",
["Ezreal - LastHit Settings"] = "[伊泽瑞尔] - 尾刀设置",
["Smart"] = "智能",
["Min. Mana Percent:"] = "最小蓝量设置",
["Ezreal - JungleClear Settings"] = "[伊泽瑞尔] - 清野设置",
["Ezreal - KillSteal Settings"] = "[伊泽瑞尔] - 抢人头设置",
["Use E"] = "使用E",
["Use R"] = "使用R",
["Use Ignite"] = "使用点燃",
["Ezreal - Auto Settings"] = "[伊泽瑞尔] - 自动设置",
["Use E To Evade"] = "使用E技能躲避",
["Shen (Q)"] = "慎的Q",
["Shen (W)"] = "慎的W",
["Shen (E)"] = "慎的E",
["Shen (R)"] = "慎的R",
["Time Limit to Evade"] = "躲避时间限制",
["% of Humanizer"] = "拟人化程度X%",
["Ezreal - Keys Settings"] = "[伊泽瑞尔] - 按键设置",
["Use main keys from your Orbwalker"] = "使用你的走砍按键设置",
["Harass (Toggle)"] = "骚扰开关",
["Assisted Ultimate (Near Mouse)"] = "辅助大招(在鼠标附近)",
[" -> Parameter mode:"] = " -> 参数模式",
["On/Off"] = "开/关",
["KeyDown"] = "按键",
["KeyToggle"] = "按键开关",
["BioZed Reborn by Da Vinci"] = "挑战者中单合集 - 劫",
["Zed - Target Selector Settings"] = "[劫] - 目标选择器设置",
["Darius"] = "德莱厄斯",
["Zed - General Settings"] = "[劫] - 常规设置",
["Developer Mode"] = "开发者模式",
["Zed - Combo Settings"] = "[劫] - 连招设置",
["Use W on Combo without R"] = "不使用R时使用W",
["Use W on Combo with R"] = "使用R时使用W",
["Swap to W/R to gap close"] = "使用二段W/R接近敌人",
["Swap to W/R if my HP % <="] = "如果生命值小于等于X%时使用二段W/R",
["Swap to W/R if target dead"] = "使用二段W/R如果目标死亡",
["Use Items"] = "使用物品",
["If Killable"] = "如果能杀死",
["R Mode"] = "R模式",
["Line"] = "直线模式",
["Triangle"] = "三角模式",
["MousePos"] = "鼠标位置",
["Don't use R On"] = "不要对..使用R",
["Zed - Harass Settings"] = "[劫] - 骚扰设置",
["Check collision before casting q"] = "在使用Q之前检查碰撞",
["Min. Energy Percent"] = "最小能量百分比",
["Zed - LaneClear Settings"] = "[劫] - 清线设置",
["Use Q If Hit >= "]	=	 "如果能击中的小兵>=X使用Q",
["Use W If Hit >= "]	=	 "如果能击中的小兵>=X使用W",
["Use E If Hit >= "]	=	 "如果能击中的小兵>=X使用E",
["Min. Energy Percent: "] = "最小能量百分比：",
["Zed - JungleClear Settings"] = "[劫] - 清野设置",
["Zed - LastHit Settings"] = "[劫] - 尾刀设置",
["Zed - KillSteal Settings"] = "[劫] - 抢人头设置",
["Zed - Auto Settings"] = "[劫] - 自动设置",
["Use Auto Q"] = "使用自动Q",
["Use Auto E"] = "使用自动E",
["Use R To Evade"] = "使用R躲避",
["Darius (Q)"] = "德莱厄斯Q",
["Darius (W)"] = "德莱厄斯W",
["Darius (E)"] = "德莱厄斯E",
["Darius (R)"] = "德莱厄斯R",
["Use R1 to Evade"] = "使用一段R躲避",
["Use R2 to Evade"] = "使用二段R躲避",
["Use W To Evade"] = "使用W躲避",
["Use W1 to Evade"] = "使用一段W躲避",
["Use W2 to Evade"] = "使用二段W躲避",
["Zed - Drawing Settings"] = "[劫] - 显示设置",
["Damage Calculation Bar"] = "血条伤害计算",
["Text when Passive Ready"] = "当被动可用时显示文字",
["Circle For W Shadow"] = "W影子线圈",
["Circle For R Shadow"] = "R影子线圈",
["Text on Shadows (W or R)"] = "在W或R的影子上显示文字",
["Zed - Key Settings"] = "[劫] - 按键设置",
["Combo with R (RWEQ)"] = "使用R的连招(RWEQ)",
["Combo without R (WEQ)"] = "不使用R的连招(WEQ)",
["Harass (QWE or QE)"] = "骚扰(QWE或者QE)",
["Harass (QWE)"] = "骚扰(QWE)",
["WQE (ON) or QE (OFF) Harass"] = "WQE(开)或QE(关)骚扰",
["LaneClear or JungleClear"] = "清线或清野",
["Run"] = "奔跑",
["Switcher for Combo Mode"] = "连招模式切换器",
["Don't cast spells before R"] = "当R技能释放之前不要释放技能",
["Forbidden Syndra by Da Vinci"] = "挑战者中单合集 - 辛德拉",
["QE Settings"] = "QE连招设置",
["Syndra - Target Selector Settings"] = "[辛德拉] - 目标选择器设置",
["Syndra - General Settings"] = "[辛德拉] - 常规设置",
["Less QE Range"] = "QE的最小范围",
["Dont use R on"] = "不要对以下目标使用R",
["QE Width"] = "QE连招宽度",
["Syndra - Combo Settings"] = "[辛德拉] - 连招设置",
["Use QE"] = "使用QE",
["Use WE"] = "使用WE",
["If Needed"] = "如果需要的话",
["Use Zhonyas if HP % <="]= "如果生命值小于%使用中亚",
["Cooldown on spells for r needed"] = "R需要的冷却时间",
["Syndra - Harass Settings"] = "[辛德拉] - 骚扰设置",
["Use Q if enemy can't move"] = "敌人不能移动的时候使用Q",
["Don't harass under turret"] = "不要骚扰在塔下的目标",
["Syndra - LaneClear Settings"] = "[辛德拉] - 清线设置",
["Syndra - JungleClear Settings"] = "[辛德拉] - 清野设置",
["Syndra - LastHit Settings"] = "[辛德拉] - 尾刀设置",
["Syndra - KillSteal Settings"] = "[辛德拉] - 抢人头设置",
["Syndra - Auto Settings"] = " [辛德拉] - 自动设置",
["Use QE/WE To Interrupt Channelings"] = "使用QE/WE来打断引导技能",
["Time Limit to Interrupt"] = "打断技能的时间限制",
["Use QE/WE To Interrupt GapClosers"] = "使用QE/WE来打断敌人的突进",
["Syndra - Drawing Settings"] = "[辛德拉] - 显示设置",
["E Lines"] = "E技能指示线",
["Text if Killable with R"] = "如果能用R击杀显示击杀提示",
["Circle On W Object"] = "在W抓取的目标上画圈",
["Syndra - Keys Settings"] = "[辛德拉] - 按键设置",
["Cast QE/WE Near Mouse"] = "在鼠标附近使用QE/WE",
}
local SupportedScriptList = {
"Evadeee","Sida's Auto Carry","Activator","DeklandAIO: Syndra","DeklandAIO: Orianna"
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
--[[function translateheaderchk(header)
    for i ,v in pairs(SupportedScriptList) do
    if(v == header) then 
    PrintLocal(header.." loaded!")
    end
    end
end]]--
function OnLoad()
	AAAUpdate()
	PrintLocal("Loaded successfully! by: leoxp,Have fun!")
end
function OnUnload()
	SaveMaster()
end

function PrintLocal(text, isError)
	PrintChat("<font color=\"#ff0000\">BoL Config Translater:</font> <font color=\"#"..(isError and "F78183" or "FFFFFF").."\">"..text.."</font>")
end

-- End of A1-Config.

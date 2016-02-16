local version = "0.02162"
local AAAautoupdate = true
local dumpuntranslated = false
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
local Global = {
	TS_SetFocus = _G.TS_SetFocus,
	TS_SetHeroPriority = _G.TS_SetHeroPriority,
	TS_Ignore = TS_Ignore,
}
local GameHeroes = { }
local SelectorConfig = nil
local GameEnemyCount = 0
local dumpdata = { }
class('AAAUpdate')
function AAAUpdate:__init()
	if not AAAautoupdate then 
		PrintLocal("Autoupdate Disabled!Local version:"..version)
	return
	end
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
local _SC = { init = true, initDraw = true, menuKey = 16, useTS = false, menuIndex = -1, instances = {}, _changeKey = false, _changeKeyInstance = false, _sliceInstance = false, _listInstance = false }
local function __SC__remove(name)
    if not GetSave("scriptConfig")[name] then GetSave("scriptConfig")[name] = {} end
    table.clear(GetSave("scriptConfig")[name])
end

local function __SC__load(name)
    if not GetSave("scriptConfig")[name] then GetSave("scriptConfig")[name] = {} end
    return GetSave("scriptConfig")[name]
end

local function __SC__save(name, content)
    if not GetSave("scriptConfig")[name] then GetSave("scriptConfig")[name] = {} end
    table.clear(GetSave("scriptConfig")[name])
    table.merge(GetSave("scriptConfig")[name], content, true)
end

local function __SC__saveMaster()
    local config = {}
    local P, PS, I = 0, 0, 0
    for _, instance in pairs(_SC.instances) do
        I = I + 1
        P = P + #instance._param
        PS = PS + #instance._permaShow
    end
    _SC.master["I" .. _SC.masterIndex] = I
    _SC.master["P" .. _SC.masterIndex] = P
    _SC.master["PS" .. _SC.masterIndex] = PS
    if not _SC.master.useTS and _SC.useTS then _SC.master.useTS = true end
    for var, value in pairs(_SC.master) do
        config[var] = value
    end
    __SC__save("Master", config)
end

local function __SC__updateMaster()
    _SC.master = __SC__load("Master")
    _SC.masterY, _SC.masterYp = 1, 0
    _SC.masterY = (_SC.master.useTS and 1 or 0)
    for i = 1, _SC.masterIndex - 1 do
        _SC.masterY = _SC.masterY + _SC.master["I" .. i]
        _SC.masterYp = _SC.masterYp + _SC.master["PS" .. i]
    end
    local size, sizep = (_SC.master.useTS and 2 or 1), 0
    for i = 1, _SC.master.iCount do
        size = size + _SC.master["I" .. i]
        sizep = sizep + _SC.master["PS" .. i]
    end
    _SC.draw.height = size * _SC.draw.cellSize
    _SC.pDraw.height = sizep * _SC.pDraw.cellSize
    _SC.draw.x = _SC.master.x
    _SC.draw.y = _SC.master.y
    _SC.pDraw.x = _SC.master.px
    _SC.pDraw.y = _SC.master.py
    _SC._Idraw.x = _SC.draw.x + _SC.draw.width + _SC.draw.border * 2
end

local function __SC__saveMenu()
    __SC__save("Menu", { menuKey = _SC.menuKey, draw = { x = _SC.draw.x, y = _SC.draw.y }, pDraw = { x = _SC.pDraw.x, y = _SC.pDraw.y } })
    _SC.master.x = _SC.draw.x
    _SC.master.y = _SC.draw.y
    _SC.master.px = _SC.pDraw.x
    _SC.master.py = _SC.pDraw.y
    __SC__saveMaster()
end

local function __SC__init_draw()
    if _SC.initDraw then
        UpdateWindow()
        --_SC.draw = { x = WINDOW_W and math.floor(WINDOW_W / 50) or 20, y = WINDOW_H and math.floor(WINDOW_H / 4) or 190, y1 = 0, height = 0, fontSize = WINDOW_H and math.round(WINDOW_H / 54) or 14, width = WINDOW_W and math.round(WINDOW_W / 4.8) or 213, border = 2, background = 1413167931, textColor = 4290427578, trueColor = 1422721024, falseColor = 1409321728, move = false }
		_SC.draw = {x = WINDOW_W and math.floor(WINDOW_W / 50) or 20, y = WINDOW_H and math.floor(WINDOW_H / 4) or 20, y1 = 0, height = 0, fontSize = 14, width = 374, border = 2, background = ARGB(Draw.Opacity, Colors.Background[1], Colors.Background[2], Colors.Background[3]), textColor = ARGB(Draw.FontOpacity, Colors.FontColor[1], Colors.FontColor[2], Colors.FontColor[3]), trueColor = 1422721024, falseColor = 1409321728, move = false }
        _SC.pDraw = { x = WINDOW_W and math.floor(WINDOW_W * 0.66) or 675, y = WINDOW_H and math.floor(WINDOW_H * 0.8) or 608, y1 = 0, height = 0, fontSize = WINDOW_H and math.round(WINDOW_H / 72) or 10, width = WINDOW_W and math.round(WINDOW_W / 6.4) or 160, border = 1, background = 1413167931, textColor = 4290427578, trueColor = 1422721024, falseColor = 1409321728, move = false }
        local menuConfig = __SC__load("Menu")
        table.merge(_SC, menuConfig, true)
        _SC.color = { 
		lgrey = ARGB(Draw.Opacity, Colors.Background[1], Colors.Background[2], Colors.Background[3]), 
		grey = ARGB(Draw.FontOpacity, Colors.FontColor[1], Colors.FontColor[2], Colors.FontColor[3]), 
		red = ARGB(Draw.ColorOpacity, Colors.DarkRed[1], Colors.DarkRed[2], Colors.DarkRed[3]), 
		green = ARGB(Draw.Opacity, Colors.DarkGreen[1], Colors.DarkGreen[2], Colors.DarkGreen[3]), 
		ivory = 4294967280 }
        _SC.draw.cellSize, _SC.draw.midSize, _SC.draw.row4, _SC.draw.row3, _SC.draw.row2, _SC.draw.row1 = _SC.draw.fontSize + _SC.draw.border, _SC.draw.fontSize / 2, _SC.draw.width * 0.9, _SC.draw.width * 0.8, _SC.draw.width * 0.7, _SC.draw.width * 0.6
        _SC.pDraw.cellSize, _SC.pDraw.midSize, _SC.pDraw.row = _SC.pDraw.fontSize + _SC.pDraw.border, _SC.pDraw.fontSize / 2, _SC.pDraw.width * 0.7
        _SC._Idraw = { x = _SC.draw.x + _SC.draw.width + _SC.draw.border * 2, y = _SC.draw.y, height = 0 }
        if WINDOW_H < 500 or WINDOW_W < 500 then return true end
        _SC.initDraw = nil
    end
    return _SC.initDraw
end

local function __SC__init(name)
    if name == nil then
        return (_SC.init or __SC__init_draw())
    end
    if _SC.init then
        _SC.init = nil
        __SC__init_draw()
        local gameStart = GetGame()
        _SC.master = __SC__load("Master")
        --[[ SurfaceS: Look into it! When loading the master, it screws up the Menu, when you change at the same time the running scripts.
           if _SC.master.osTime ~= nil and _SC.master.osTime == gameStart.osTime then
              for i = 1, _SC.master.iCount do
                  if _SC.master["name" .. i] == name then _SC.masterIndex = i end
              end
              if _SC.masterIndex == nil then
                  _SC.masterIndex = _SC.master.iCount + 1
                  _SC.master["name" .. _SC.masterIndex] = name
                  _SC.master.iCount = _SC.masterIndex
                  __SC__saveMaster()
             end
        else]]
        __SC__remove("Master")
        _SC.masterIndex = 1
        _SC.master.useTS = false
        _SC.master.x = _SC.draw.x
        _SC.master.y = _SC.draw.y
        _SC.master.px = _SC.pDraw.x
        _SC.master.py = _SC.pDraw.y
        _SC.master.osTime = gameStart.osTime
        _SC.master.name1 = name
        _SC.master.iCount = 1
        __SC__saveMaster()
        --end
    end
    __SC__updateMaster()
end

local function __SC__txtKey(key)
    return (key > 32 and key < 96 and " " .. string.char(key) .. " " or "(" .. tostring(key) .. ")")
end

local function __SC__DrawInstance(header, selected)
    DrawLine(_SC.draw.x + _SC.draw.width / 2, _SC.draw.y1, _SC.draw.x + _SC.draw.width / 2, _SC.draw.y1 + _SC.draw.cellSize, _SC.draw.width + _SC.draw.border * 2, (selected and _SC.color.red or _SC.color.lgrey))
    DrawText(translationchk(header), _SC.draw.fontSize, _SC.draw.x, _SC.draw.y1, (selected and _SC.color.ivory or _SC.color.grey))
    _SC.draw.y1 = _SC.draw.y1 + _SC.draw.cellSize
end

local function __SC__ResetSubIndexes()
    for i, instance in ipairs(_SC.instances) do
        instance:ResetSubIndexes()
    end
end

local __SC__OnDraw, __SC__OnWndMsg
local function __SC__OnLoad()
    if not __SC__OnDraw then
        function __SC__OnDraw()
            if __SC__init() or Console__IsOpen or GetGame().isOver then return end
            if IsKeyDown(_SC.menuKey) or _SC._changeKey then
                if _SC.draw.move then
                    local cursor = GetCursorPos()
                    _SC.draw.x = cursor.x - _SC.draw.offset.x
                    _SC.draw.y = cursor.y - _SC.draw.offset.y
                    _SC._Idraw.x = _SC.draw.x + _SC.draw.width + _SC.draw.border * 2
                elseif _SC.pDraw.move then
                    local cursor = GetCursorPos()
                    _SC.pDraw.x = cursor.x - _SC.pDraw.offset.x
                    _SC.pDraw.y = cursor.y - _SC.pDraw.offset.y
                end
                if _SC.masterIndex == 1 then
                    DrawLine(_SC.draw.x + _SC.draw.width / 2, _SC.draw.y, _SC.draw.x + _SC.draw.width / 2, _SC.draw.y + _SC.draw.height, _SC.draw.width + _SC.draw.border * 2, 1414812756) -- grey
                    _SC.draw.y1 = _SC.draw.y
                    local menuText = _SC._changeKey and not _SC._changeKeyVar and "press key for Menu" or "Menu"
                    DrawText(translationchk(menuText), _SC.draw.fontSize, _SC.draw.x, _SC.draw.y1, _SC.color.ivory) -- ivory
                    DrawText(__SC__txtKey(_SC.menuKey), _SC.draw.fontSize, _SC.draw.x + _SC.draw.width * 0.9, _SC.draw.y1, _SC.color.grey)
                end
                _SC.draw.y1 = _SC.draw.y + _SC.draw.cellSize
                if _SC.useTS then
                    __SC__DrawInstance("Target Selector", (_SC.menuIndex == 0))
                    if _SC.menuIndex == 0 then
                        DrawLine(_SC._Idraw.x + _SC.draw.width / 2, _SC.draw.y, _SC._Idraw.x + _SC.draw.width / 2, _SC.draw.y + _SC._Idraw.height, _SC.draw.width + _SC.draw.border * 2, 1414812756) -- grey
                        DrawText(translationchk("Target Selector"), _SC.draw.fontSize, _SC._Idraw.x, _SC.draw.y, _SC.color.ivory)
                        _SC._Idraw.y = TS__DrawMenu(_SC._Idraw.x, _SC.draw.y + _SC.draw.cellSize)
                        _SC._Idraw.height = _SC._Idraw.y - _SC.draw.y
                    end
                end
                _SC.draw.y1 = _SC.draw.y + _SC.draw.cellSize + (_SC.draw.cellSize * _SC.masterY)
                for index, instance in ipairs(_SC.instances) do
                    __SC__DrawInstance(instance.header, (_SC.menuIndex == index))
                    if _SC.menuIndex == index then instance:OnDraw() end
                end
            end
            local y1 = _SC.pDraw.y + (_SC.pDraw.cellSize * _SC.masterYp)
            local function DrawPermaShows(instance)

                if #instance._permaShow > 0 then
                    for _, varIndex in ipairs(instance._permaShow) do
                        local pVar = instance._param[varIndex].var
                        DrawLine(_SC.pDraw.x - _SC.pDraw.border, y1 + _SC.pDraw.midSize, _SC.pDraw.x + _SC.pDraw.row - _SC.pDraw.border, y1 + _SC.pDraw.midSize, _SC.pDraw.cellSize, _SC.color.lgrey)
                        DrawText(translationchk(instance._param[varIndex].text), _SC.pDraw.fontSize, _SC.pDraw.x, y1, _SC.color.grey)
                        if instance._param[varIndex].pType == SCRIPT_PARAM_SLICE or instance._param[varIndex].pType == SCRIPT_PARAM_LIST or instance._param[varIndex].pType == SCRIPT_PARAM_INFO then
                            DrawLine(_SC.pDraw.x + _SC.pDraw.row, y1 + _SC.pDraw.midSize, _SC.pDraw.x + _SC.pDraw.width + _SC.pDraw.border, y1 + _SC.pDraw.midSize, _SC.pDraw.cellSize, _SC.color.lgrey)
                            if instance._param[varIndex].pType == SCRIPT_PARAM_LIST then
                                local text = tostring(instance._param[varIndex].listTable[instance[pVar]])
                                local maxWidth = (_SC.pDraw.width - _SC.pDraw.row) * 0.8
                                local textWidth = GetTextArea(text, _SC.pDraw.fontSize).x
                                if textWidth > maxWidth then
                                    text = text:sub(1, math.floor(text:len() * maxWidth / textWidth)) .. ".."
                                end
                                DrawText(translationchk(text), _SC.pDraw.fontSize, _SC.pDraw.x + _SC.pDraw.row, y1, _SC.color.grey)
                            else
                                DrawText(translationchk(tostring(instance[pVar])), _SC.pDraw.fontSize, _SC.pDraw.x + _SC.pDraw.row + _SC.pDraw.border, y1, _SC.color.grey)
                            end
                        else
                            DrawLine(_SC.pDraw.x + _SC.pDraw.row, y1 + _SC.pDraw.midSize, _SC.pDraw.x + _SC.pDraw.width + _SC.pDraw.border, y1 + _SC.pDraw.midSize, _SC.pDraw.cellSize, (instance[pVar] and _SC.color.green or _SC.color.lgrey))
                            DrawText((instance[pVar] and "      ON" or "      OFF"), _SC.pDraw.fontSize, _SC.pDraw.x + _SC.pDraw.row + _SC.pDraw.border, y1, _SC.color.grey)
                        end
                        y1 = y1 + _SC.pDraw.cellSize
                    end
                end
                for _, subInstance in ipairs(instance._subInstances) do
                    DrawPermaShows(subInstance)
                end
            end
            for _, instance in ipairs(_SC.instances) do
                DrawPermaShows(instance)
            end
        end

        AddDrawCallback(__SC__OnDraw)
    end
    if not __SC__OnWndMsg then
        function __SC__OnWndMsg(msg, key)
            if __SC__init() or Console__IsOpen then return end
            local msg, key = msg, key
            if key == _SC.menuKey and _SC.lastKeyState ~= msg then
                _SC.lastKeyState = msg
                __SC__updateMaster()
            end
            if _SC._changeKey then
                if msg == KEY_DOWN then
                    if _SC._changeKeyMenu then return end
                    _SC._changeKey = false
                    if _SC._changeKeyVar == nil then
                        _SC.menuKey = key
                        if _SC.masterIndex == 1 then __SC__saveMenu() end
                    else
                        _SC._changeKeyInstance._param[_SC._changeKeyVar].key = key
                        _SC._changeKeyInstance:save()
                        --_SC.instances[_SC.menuIndex]._param[_SC._changeKeyVar].key = key
                        --_SC.instances[_SC.menuIndex]:save()
                    end
                    return
                else
                    if _SC._changeKeyMenu and key == _SC.menuKey then _SC._changeKeyMenu = false end
                end
            end
            if msg == WM_LBUTTONDOWN and IsKeyDown(_SC.menuKey) then
                if CursorIsUnder(_SC.draw.x, _SC.draw.y, _SC.draw.width, _SC.draw.height) then
                    _SC.menuIndex = -1
                    __SC__ResetSubIndexes()
                    if CursorIsUnder(_SC.draw.x + _SC.draw.width - _SC.draw.fontSize * 1.5, _SC.draw.y, _SC.draw.fontSize, _SC.draw.cellSize) then
                        _SC._changeKey, _SC._changeKeyVar, _SC._changeKeyMenu = true, nil, true
                        return
                    elseif CursorIsUnder(_SC.draw.x, _SC.draw.y, _SC.draw.width, _SC.draw.cellSize) then
                        _SC.draw.offset = Vector(GetCursorPos()) - _SC.draw
                        _SC.draw.move = true
                        return
                    else
                        if _SC.useTS and CursorIsUnder(_SC.draw.x, _SC.draw.y + _SC.draw.cellSize, _SC.draw.width, _SC.draw.cellSize) then _SC.menuIndex = 0 __SC__ResetSubIndexes() end
                        local y1 = _SC.draw.y + _SC.draw.cellSize + (_SC.draw.cellSize * _SC.masterY)
                        for index, _ in ipairs(_SC.instances) do
                            if CursorIsUnder(_SC.draw.x, y1, _SC.draw.width, _SC.draw.cellSize) then _SC.menuIndex = index __SC__ResetSubIndexes() end
                            y1 = y1 + _SC.draw.cellSize
                        end
                    end
                elseif CursorIsUnder(_SC.pDraw.x, _SC.pDraw.y, _SC.pDraw.width, _SC.pDraw.height) then
                    _SC.pDraw.offset = Vector(GetCursorPos()) - _SC.pDraw
                    _SC.pDraw.move = true
                elseif _SC.menuIndex == 0 then
                    TS_ClickMenu(_SC._Idraw.x, _SC.draw.y + _SC.draw.cellSize)
                elseif _SC.menuIndex > 0 then
                    local function CheckOnWndMsg(instance)
                        if CursorIsUnder(instance._x, _SC.draw.y, _SC.draw.width, instance._height) then
                            instance:OnWndMsg()
                        elseif instance._subMenuIndex > 0 then
                            CheckOnWndMsg(instance._subInstances[instance._subMenuIndex])
                        end
                    end
                    CheckOnWndMsg(_SC.instances[_SC.menuIndex])
                end
            elseif msg == WM_LBUTTONUP then
                if _SC.draw.move or _SC.pDraw.move then
                    _SC.draw.move = false
                    _SC.pDraw.move = false
                    if _SC.masterIndex == 1 then __SC__saveMenu() end
                    return
                elseif _SC._sliceInstance then
                    _SC._sliceInstance:save()
                    _SC._sliceInstance._slice = false
                    _SC._sliceInstance = false

                    return
                elseif _SC._listInstance then
                    _SC._listInstance:save()
                    _SC._listInstance._list = false
                    _SC._listInstance = false
                end
            else
                local function CheckOnWndMsg(instance)

                    for _, param in ipairs(instance._param) do
                        if param.pType == SCRIPT_PARAM_ONKEYTOGGLE and key == param.key and msg == KEY_DOWN then
                            instance[param.var] = not instance[param.var]
                        elseif param.pType == SCRIPT_PARAM_ONKEYDOWN and key == param.key then
                            instance[param.var] = (msg == KEY_DOWN)
                        end
                    end
                    for _, subInstance in ipairs(instance._subInstances) do
                        CheckOnWndMsg(subInstance)
                    end
                end
                for _, instance in ipairs(_SC.instances) do
                    CheckOnWndMsg(instance)
                end
            end
        end

        AddMsgCallback(__SC__OnWndMsg)
    end
end

function _G.scriptConfig:__init(header, name, parent)
    assert((type(header) == "string") and (type(name) == "string"), "scriptConfig: expected <string>, <string>)")
    if not parent then
        __SC__init(name)
        __SC__OnLoad()
    else
        self._parent = parent
    end
    self.header = header
    self.name = name
	if(dumpchk(header)) then
		print("configheader:",header)
	end
    self._tsInstances = {}
    self._param = {}
    self._permaShow = {}
    self._subInstances = {}
    self._subMenuIndex = 0
    self._x = parent and (parent._x + _SC.draw.width + _SC.draw.border*2) or _SC._Idraw.x
    self._y = 0
    self._height = 0
    self._slice = false
    table.insert(parent and parent._subInstances or _SC.instances, self)
end

function _G.scriptConfig:addSubMenu(header, name)
    assert((type(header) == "string") and (type(name) == "string"), "scriptConfig: expected <string>, <string>)")
    local subName = self.name .. "_" .. name
    local sub = scriptConfig(header, subName, self)
    self[name] = sub
end

function _G.scriptConfig:addParam(pVar, pText, pType, defaultValue, a, b, c)
    assert(type(pVar) == "string" and type(pText) == "string" and type(pType) == "number", "addParam: wrong argument types (<string>, <string>, <pType> expected)")
    assert(string.find(pVar, "[^%a%d]") == nil, "addParam: pVar should contain only char and number")
    --assert(self[pVar] == nil, "addParam: pVar should be unique, already existing " .. pVar)
    local newParam = { var = pVar, text = pText, pType = pType }
	if(dumpchk(pText)) then
		print("param text:",pText)
	end
    if pType == SCRIPT_PARAM_ONOFF then
        assert(type(defaultValue) == "boolean", "addParam: wrong argument types (<boolean> expected)")
    elseif pType == SCRIPT_PARAM_COLOR then
        assert(type(defaultValue) == "table", "addParam: wrong argument types (<table> expected)")
        assert(#defaultValue == 4, "addParam: wrong argument ({a,r,g,b} expected)")
    elseif pType == SCRIPT_PARAM_ONKEYDOWN or pType == SCRIPT_PARAM_ONKEYTOGGLE then
        assert(type(defaultValue) == "boolean" and type(a) == "number", "addParam: wrong argument types (<boolean> <number> expected)")
        newParam.key = a
    elseif pType == SCRIPT_PARAM_SLICE then
        assert(type(defaultValue) == "number" and type(a) == "number" and type(b) == "number" and (type(c) == "number" or c == nil), "addParam: wrong argument types (pVar, pText, pType, defaultValue, valMin, valMax, decimal) expected")
        newParam.min = a
        newParam.max = b
        newParam.idc = c or 0
        newParam.cursor = 0
    elseif pType == SCRIPT_PARAM_LIST then
        assert(type(defaultValue) == "number" and type(a) == "table", "addParam: wrong argument types (pVar, pText, pType, defaultValue, listTable) expected")
		for i,v in pairs(a) do
			if(dumpchk(v)) then
				print("param list:",v)
			end
        end
        newParam.listTable = a
        newParam.min = 1
        newParam.max = #a
        newParam.cursor = 0
    end
    self[pVar] = defaultValue
    table.insert(self._param, newParam)
    __SC__saveMaster()
    self:load()
end

function _G.scriptConfig:addTS(tsInstance)
    assert(type(tsInstance.mode) == "number", "addTS: expected TargetSelector)")
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
    __SC__saveMaster()
    self:load()
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

function _G.scriptConfig:permaShow(pVar)
    assert(type(pVar) == "string" and self[pVar] ~= nil, "permaShow: existing pVar expected)")
    for index, param in ipairs(self._param) do
        if param.var == pVar then
            table.insert(self._permaShow, index)
        end
    end
    __SC__saveMaster()
end

function _G.scriptConfig:_txtKey(key)
    return (key > 32 and key < 96 and " " .. string.char(key) .. " " or "(" .. tostring(key) .. ")")
end

function _G.scriptConfig:OnDraw()
    self._x = self._parent and (self._parent._x + _SC.draw.width + _SC.draw.border*2) or _SC._Idraw.x
    if self._slice and _SC._sliceInstance then
        local cursorX = math.min(math.max(0, GetCursorPos().x - self._x - _SC.draw.row3), _SC.draw.width - _SC.draw.row3)
        self[self._param[self._slice].var] = math.round(self._param[self._slice].min + cursorX / (_SC.draw.width - _SC.draw.row3) * (self._param[self._slice].max - self._param[self._slice].min), self._param[self._slice].idc)
    end
    self._y = _SC.draw.y
    DrawLine(self._x + _SC.draw.width / 2, self._y, self._x + _SC.draw.width / 2, self._y + self._height, _SC.draw.width + _SC.draw.border * 2, 1414812756) -- grey
    local menuText = _SC._changeKey and _SC._changeKeyVar and _SC._changeKeyInstance and _SC._changeKeyInstance.name == self.name and "press key for " .. self._param[_SC._changeKeyVar].var or self.header
    DrawText(translationchk(menuText), _SC.draw.fontSize, self._x, self._y, 4294967280) -- ivory
    self._y = self._y + _SC.draw.cellSize
    for index, _ in ipairs(self._subInstances) do
        self:_DrawSubInstance(index)
        if self._subMenuIndex == index then _:OnDraw() end
    end

    for index, _ in ipairs(self._param) do
        self:_DrawParam(index)
    end
    self._height = self._y - _SC.draw.y
    if self._list and _SC._listInstance and self._listY then
        local cursorY = math.min(GetCursorPos().y - self._listY, _SC.draw.cellSize * (self._param[self._list].max))
        if cursorY >= 0 then
            self[self._param[self._list].var] = math.round(self._param[self._list].min + cursorY / (_SC.draw.cellSize * (self._param[self._list].max)) * (self._param[self._list].max - self._param[self._list].min))
        end
        local maxWidth = 0
        for i, el in pairs(self._param[self._list].listTable) do
            maxWidth = math.max(maxWidth, GetTextArea(el, _SC.draw.fontSize).x)
        end
        -- BG:
        DrawRectangle(self._x + _SC.draw.row3, self._listY, maxWidth, self._param[self._list].max * _SC.draw.cellSize, ARGB(230,50,50,50))
        -- SELECTED:
        DrawRectangle(self._x + _SC.draw.row3, self._listY + (self[self._param[self._list].var]-1) * _SC.draw.cellSize, maxWidth, _SC.draw.cellSize, _SC.color.green)
        for i, el in pairs(self._param[self._list].listTable) do
            DrawText(translationchk(el), _SC.draw.fontSize, self._x + _SC.draw.row3, self._listY + (i-1) * _SC.draw.cellSize, 4294967280)
        end
    end
end

function _G.scriptConfig:_DrawSubInstance(index)
    local pVar = self._subInstances[index].name
    local selected = self._subMenuIndex == index
    DrawLine(self._x - _SC.draw.border, self._y + _SC.draw.midSize, self._x + _SC.draw.width + _SC.draw.border, self._y + _SC.draw.midSize, _SC.draw.cellSize, (selected and _SC.color.red or _SC.color.lgrey))
    DrawText(translationchk(self._subInstances[index].header), _SC.draw.fontSize, self._x, self._y, (selected and _SC.color.ivory or _SC.color.grey))
    DrawText("        >>", _SC.draw.fontSize, self._x + _SC.draw.row3 , self._y, (selected and _SC.color.ivory or _SC.color.grey))
    --_SC._Idraw.y = _SC._Idraw.y + _SC.draw.cellSize
    self._y = self._y + _SC.draw.cellSize
end

function _G.scriptConfig:_DrawParam(varIndex)
    local pVar = self._param[varIndex].var
    DrawLine(self._x - _SC.draw.border, self._y + _SC.draw.midSize, self._x + _SC.draw.row3 - _SC.draw.border, self._y + _SC.draw.midSize, _SC.draw.cellSize, _SC.color.lgrey)
    DrawText(translationchk(self._param[varIndex].text), _SC.draw.fontSize, self._x, self._y, _SC.color.grey)
    if self._param[varIndex].pType == SCRIPT_PARAM_SLICE then
        DrawText(translationchk(tostring(self[pVar])), _SC.draw.fontSize, self._x + _SC.draw.row2, self._y, _SC.color.grey)
        DrawLine(self._x + _SC.draw.row3, self._y + _SC.draw.midSize, self._x + _SC.draw.width + _SC.draw.border, self._y + _SC.draw.midSize, _SC.draw.cellSize, _SC.color.lgrey)
        -- cursor
        self._param[varIndex].cursor = (self[pVar] - self._param[varIndex].min) / (self._param[varIndex].max - self._param[varIndex].min) * (_SC.draw.width - _SC.draw.row3)
        DrawLine(self._x + _SC.draw.row3 + self._param[varIndex].cursor - _SC.draw.border, self._y + _SC.draw.midSize, self._x + _SC.draw.row3 + self._param[varIndex].cursor + _SC.draw.border, self._y + _SC.draw.midSize, _SC.draw.cellSize, 4292598640)
    elseif self._param[varIndex].pType == SCRIPT_PARAM_LIST then
        local text = translationchk(tostring(self._param[varIndex].listTable[self[pVar]]))
        local maxWidth = (_SC.draw.width - _SC.draw.row3) * 0.8
        local textWidth = GetTextArea(text, _SC.draw.fontSize).x
        if textWidth > maxWidth then
            text = text:sub(1, math.floor(text:len() * maxWidth / textWidth)) .. ".."
        end
        DrawText(text, _SC.draw.fontSize, self._x + _SC.draw.row3, self._y, _SC.color.grey)
        if self._list and _SC._listInstance then self._listY = self._y + _SC.draw.cellSize end
    elseif self._param[varIndex].pType == SCRIPT_PARAM_INFO then
        DrawText(translationchk(tostring(self[pVar])), _SC.draw.fontSize, self._x + _SC.draw.row3 + _SC.draw.border, self._y, _SC.color.grey)
    elseif self._param[varIndex].pType == SCRIPT_PARAM_COLOR then
        DrawRectangle(self._x + _SC.draw.row3 + _SC.draw.border, self._y, 80, _SC.draw.cellSize, ARGB(self[pVar][1], self[pVar][2], self[pVar][3], self[pVar][4]))
    else
        if (self._param[varIndex].pType == SCRIPT_PARAM_ONKEYDOWN or self._param[varIndex].pType == SCRIPT_PARAM_ONKEYTOGGLE) then
            DrawText(self:_txtKey(self._param[varIndex].key), _SC.draw.fontSize, self._x + _SC.draw.row2, self._y, _SC.color.grey)
        end
        DrawLine(self._x + _SC.draw.row3, self._y + _SC.draw.midSize, self._x + _SC.draw.width + _SC.draw.border, self._y + _SC.draw.midSize, _SC.draw.cellSize, (self[pVar] and _SC.color.green or _SC.color.red))
        DrawText((self[pVar] and "       ON" or "       OFF"), _SC.draw.fontSize, self._x + _SC.draw.row3 + _SC.draw.border - _SC.draw.width*0.075, self._y, _SC.color.grey)
    end
    self._y = self._y + _SC.draw.cellSize
end



function _G.scriptConfig:load()
    local function sensitiveMerge(base, t)
        for i, v in pairs(t) do
            if type(base[i]) == type(v) then
                if type(v) == "table" then sensitiveMerge(base[i], v)
                else base[i] = v
                end
            end
        end
    end

    local config = __SC__load(self.name)
    for var, value in pairs(config) do
        if type(value) == "table" then
            if self[var] then sensitiveMerge(self[var], value) end
        else self[var] = value
        end
    end
end

function _G.scriptConfig:save()
    local content = {}
    content._param = content._param or {}
    for var, param in pairs(self._param) do
        if param.pType ~= SCRIPT_PARAM_INFO then
            content[param.var] = self[param.var]
            if param.pType == SCRIPT_PARAM_ONKEYDOWN or param.pType == SCRIPT_PARAM_ONKEYTOGGLE then
                content._param[var] = { key = param.key }
            end
        end
    end
    content._tsInstances = content._tsInstances or {}
    for i, ts in pairs(self._tsInstances) do
        content._tsInstances[i] = { mode = ts.mode }
    end
    -- for i,pShow in pairs(self._permaShow) do
    -- table.insert (content, "_permaShow."..i.."="..tostring(pShow))
    -- end
    __SC__save(self.name, content)
end

function _G.scriptConfig:ResetSubIndexes()
    if self._subMenuIndex > 0 then
        self._subInstances[self._subMenuIndex]:ResetSubIndexes()
        self._subMenuIndex = 0
    end
end

function _G.scriptConfig:OnWndMsg()
    local y1 = _SC.draw.y + _SC.draw.cellSize
    if CursorIsUnder(self._x, _SC.draw.y, _SC.draw.width + _SC.draw.border, _SC.draw.cellSize) then self:ResetSubIndexes() end
    for i, instance in ipairs(self._subInstances) do
        if CursorIsUnder(self._x, y1, _SC.draw.width + _SC.draw.border, _SC.draw.cellSize) then self._subMenuIndex = i return end
        y1 = y1 + _SC.draw.cellSize
    end
    for i, param in ipairs(self._param) do
        if param.pType == SCRIPT_PARAM_ONKEYDOWN or param.pType == SCRIPT_PARAM_ONKEYTOGGLE then
            if CursorIsUnder(self._x + _SC.draw.row2, y1, _SC.draw.fontSize, _SC.draw.fontSize) then
                _SC._changeKey, _SC._changeKeyVar, _SC._changeKeyMenu = true, i, true
                _SC._changeKeyInstance = self
                self:ResetSubIndexes()
                return
            end
        end
        if param.pType == SCRIPT_PARAM_ONOFF or param.pType == SCRIPT_PARAM_ONKEYTOGGLE then
            if CursorIsUnder(self._x + _SC.draw.row3, y1, _SC.draw.width - _SC.draw.row3, _SC.draw.fontSize) then
                self[param.var] = not self[param.var]
                self:save()
                self:ResetSubIndexes()
                return
            end
        end
        if param.pType == SCRIPT_PARAM_COLOR then
            if CursorIsUnder(self._x + _SC.draw.row3, y1, _SC.draw.width - _SC.draw.row3, _SC.draw.fontSize) then
                __CP(nil, nil, self[param.var][1], self[param.var][2], self[param.var][3], self[param.var][4], self[param.var])
                self:save()
                self:ResetSubIndexes()
                return
            end
        end
		
		
        if param.pType == SCRIPT_PARAM_SLICE then
            if CursorIsUnder(self._x + _SC.draw.row3 - _SC.draw.border, y1, WINDOW_W, _SC.draw.fontSize) then
                self._slice = i
                _SC._sliceInstance = self
                self:ResetSubIndexes()

                return
            end
        end
        if param.pType == SCRIPT_PARAM_LIST then
            if CursorIsUnder(self._x + _SC.draw.row3 - _SC.draw.border, y1, WINDOW_W, _SC.draw.fontSize) then
                self._list = i
                _SC._listInstance = self
                self:ResetSubIndexes()

                return
            end
        end
        y1 = y1 + _SC.draw.cellSize
    end
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

function InitializeGameHeroes()
    if (#GameHeroes == 0) then
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
                -- print(hero.charName..":"..#GameHeroes)
            end
        end
    end
end

if not _G.HidePermaShow then
	_G.HidePermaShow = {}
end

function _G.CustomPermaShow(TextVar, ValueVar, VisibleVar, PermaColorVar, OnColorVar, OffColorVar, IndexVar)
	if not _G._CPS_Added then
		if not DrawCustomText then
			_G.DrawCustomText = _G.DrawText
			_G.DrawText = function(Arg1, Arg2, Arg3, Arg4, Arg5) _DrawText(Arg1, Arg2, Arg3, Arg4, Arg5) end
			_G.DrawCustomLine = _G.DrawLine
			_G.DrawLine = function(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) _DrawLine(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6) end
			OldPermaShowTable, OldPermaShowCount, IsPermaShowStatusOn, PermaShowTable = {}, 0, {}, {}
			AddDrawCallback(_DrawCustomPermaShow)
			_G._CPS_Added = true
		else
			OldPermaShowTable, OldPermaShowCount, IsPermaShowStatusOn, PermaShowTable = {}, 0, {}, {}
			AddDrawCallback(_DrawCustomPermaShow)
			_G._CPS_Added = true
		end
	end
	
	if(dumpchk(TextVar) or dumpchk(ValueVar)) then
		print("CustomPermaShow:"..TextVar)
	end

	if IndexVar == nil then
		local _CPS_Updated = false
		for i=1, #PermaShowTable do
			if PermaShowTable[i]["TextVar"] == TextVar then
				PermaShowTable[i]["ValueVar"], PermaShowTable[i]["VisibleVar"],_CPS_Updated = ValueVar,VisibleVar,true
				PermaShowTable[i]["PermaColorVar"],PermaShowTable[i]["OnColorVar"],PermaShowTable[i]["OffColorVar"] = PermaColorVar, OnColorVar, OffColorVar
			end
		end

		if not _CPS_Updated then
			PermaShowTable[#PermaShowTable+1] = {["TextVar"] = TextVar, ["ValueVar"] = ValueVar, ["VisibleVar"] = VisibleVar, ["PermaColorVar"] = PermaColorVar, ["OnColorVar"] = OnColorVar, ["OffColorVar"] = OffColorVar}
		end
	else
		local _CPS_Updated = false
		for i=1, #PermaShowTable do
			if PermaShowTable[i]["IndexVar"] == IndexVar then
				PermaShowTable[i]["ValueVar"], PermaShowTable[i]["VisibleVar"],_CPS_Updated = ValueVar,VisibleVar,true
				PermaShowTable[i]["PermaColorVar"],PermaShowTable[i]["OnColorVar"],PermaShowTable[i]["OffColorVar"] = PermaColorVar, OnColorVar, OffColorVar
				PermaShowTable[i]["TextVar"] = TextVar
			end
		end

		if not _CPS_Updated then
			PermaShowTable[#PermaShowTable+1] = {["TextVar"] = TextVar, ["ValueVar"] = ValueVar, ["VisibleVar"] = VisibleVar, ["PermaColorVar"] = PermaColorVar, ["OnColorVar"] = OnColorVar, ["OffColorVar"] = OffColorVar, ["IndexVar"] = IndexVar}
		end
	end
end

function _G._DrawCustomPermaShow()
	_CPS_Master = GetSave("scriptConfig")["Master"]
	_CPS_Master.py1 = _CPS_Master.py
	_CPS_Master.py2 = _CPS_Master.py
	_CPS_Master.color = { lgrey = 1413167931, grey = 4290427578, green = 1409321728}
	_CPS_Master.fontSize = WINDOW_H and math.round(WINDOW_H / 72) or 10
	_CPS_Master.midSize = _CPS_Master.fontSize / 2
	_CPS_Master.cellSize = _CPS_Master.fontSize + 1
	_CPS_Master.width = WINDOW_W and math.round(WINDOW_W / 6.4) or 160
	_CPS_Master.row = _CPS_Master.width * 0.7

	for i = 1, #PermaShowTable do
		if PermaShowTable[i].ValueVar == true then
			if PermaShowTable[i].OnColorVar == nil then
				if PermaShowTable[i].PermaColorVar == nil then
					ColorVar = _CPS_Master.color.green
				else
					ColorVar = PermaShowTable[i].PermaColorVar
				end
			else
				ColorVar = PermaShowTable[i].OnColorVar
			end
			TextVar = "      ON"
		elseif PermaShowTable[i].ValueVar == false then
			if PermaShowTable[i].OffColorVar == nil then
				if PermaShowTable[i].PermaColorVar == nil then
					ColorVar = _CPS_Master.color.lgrey
				else
					ColorVar = PermaShowTable[i].PermaColorVar
				end
			else
				ColorVar = PermaShowTable[i].OffColorVar
			end
			TextVar = "      OFF"
		else
			if PermaShowTable[i].PermaColorVar == nil then
				ColorVar = _CPS_Master.color.lgrey
			else
				ColorVar = PermaShowTable[i].PermaColorVar
			end
			TextVar = PermaShowTable[i].ValueVar
		end
		if PermaShowTable[i]["VisibleVar"] then
			if not (_G.HidePermaShow[PermaShowTable[i].TextVar] ~= nil and _G.HidePermaShow[PermaShowTable[i].TextVar] == true) then
				DrawCustomLine(_CPS_Master.px - 1, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.px + _CPS_Master.row - 1, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.cellSize, _CPS_Master.color.lgrey)
				DrawCustomText(translationchk(PermaShowTable[i].TextVar), _CPS_Master.fontSize, _CPS_Master.px, _CPS_Master.py1, _CPS_Master.color.grey)
				DrawCustomLine(_CPS_Master.px + _CPS_Master.row, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.px + _CPS_Master.width + 1, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.cellSize, ColorVar)
				DrawCustomText(translationchk(TextVar), _CPS_Master.fontSize, _CPS_Master.px + _CPS_Master.row + 1, _CPS_Master.py1, _CPS_Master.color.grey)
				_CPS_Master.py1 = _CPS_Master.py1 + _CPS_Master.cellSize
			end
		end
	end
	for i=1,OldPermaShowCount do
		if IsPermaShowStatusOn[_CPS_Master.py2] == true then
			ColorVar = _CPS_Master.color.green
			TextVar = "      ON"
		elseif IsPermaShowStatusOn[_CPS_Master.py2] == false then
			ColorVar = _CPS_Master.color.lgrey
			TextVar = "      OFF"
		else
			ColorVar = _CPS_Master.color.lgrey
			TextVar = IsPermaShowStatusOn[_CPS_Master.py2]
		end
		DrawCustomLine(_CPS_Master.px - 1, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.px + _CPS_Master.row - 1, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.cellSize, _CPS_Master.color.lgrey)
		DrawCustomText(translationchk(OldPermaShowTable[i].Arg1), _CPS_Master.fontSize, _CPS_Master.px, _CPS_Master.py1, _CPS_Master.color.grey)
		DrawCustomLine(_CPS_Master.px + _CPS_Master.row, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.px + _CPS_Master.width + 1, _CPS_Master.py1 + _CPS_Master.midSize, _CPS_Master.cellSize, (ColorVar))
		DrawCustomText(translationchk(TextVar), _CPS_Master.fontSize, _CPS_Master.px + _CPS_Master.row + 1, _CPS_Master.py1, _CPS_Master.color.grey)
		_CPS_Master.py1 = _CPS_Master.py1 + _CPS_Master.cellSize
		_CPS_Master.py2 = _CPS_Master.py2 + _CPS_Master.cellSize
	end
end

function _G._DrawText(Arg1, Arg2, Arg3, Arg4, Arg5)
	_CPS_Master = GetSave("scriptConfig")["Master"]
	_CPS_Master.row = (WINDOW_W and math.round(WINDOW_W / 6.4) or 160) * 0.7
	if Arg3 == _CPS_Master.px then
		if not (_G.HidePermaShow[Arg1] ~= nil and _G.HidePermaShow[Arg1] == true) then
			if not OldPermaShowTable[Arg1] then
				OldPermaShowTable[Arg1] = true
				OldPermaShowCount = OldPermaShowCount + 1
				OldPermaShowTable[OldPermaShowCount] = {}
				OldPermaShowTable[OldPermaShowCount]["Status"] = true
				OldPermaShowTable[OldPermaShowCount]["Arg1"] = Arg1
				OldPermaShowTable[OldPermaShowCount]["Arg2"] = Arg2
				OldPermaShowTable[OldPermaShowCount]["Arg3"] = Arg3
				OldPermaShowTable[OldPermaShowCount]["Arg4"] = Arg4
				OldPermaShowTable[OldPermaShowCount]["Arg5"] = Arg5
			end
		end
	elseif Arg3 == (_CPS_Master.px + _CPS_Master.row + 1) then
		if Arg1 == "      ON" then
			IsPermaShowStatusOn[Arg4] = true
		elseif Arg1 == "      OFF" then
			IsPermaShowStatusOn[Arg4] = false
		else
			IsPermaShowStatusOn[Arg4] = Arg1
		end
	else
		DrawCustomText(Arg1, Arg2, Arg3, Arg4, Arg5)
	end
end

function _G._DrawLine(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	_CPS_Master = GetSave("scriptConfig")["Master"]
	_CPS_Master.row = (WINDOW_W and math.round(WINDOW_W / 6.4) or 160) * 0.7
	if not (Arg1 == (_CPS_Master.px - 1) or Arg1 == (_CPS_Master.px + _CPS_Master.row)) then
		DrawCustomLine(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	end
end

local tranTable = {
["Menu"] = "菜单",
["press key for Menu"] = "设定新的菜单按钮...",
[" "] = " ",
["-"] = "-",
["NOW"] = "NOW",
["SOW"] = "SOW",
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
["2..4 - Use vs More Dangerous / CC"] = "2..4 - 遇到较危险技能及控制技能使用",
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
["2..4 - Use only vs More Dangerous / CC"] = "2..4 - 仅在较危险技能及控制技能使用",
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
["Blitzcrank | Q - Rocket Grab"] = "布里茨 | Q - 机械飞爪",
["On / Off [Permanent]"] = "开 / 关 [永久生效]",
["On / Off [This session]"] = "开 / 关 [当局游戏生效]",
["Dodging Mode"] = "躲避模式",
["Normal"] = "普通",
["Prefer dashes/blinks/spellshields"] = "优先使用位移/闪现/护盾",
["Only dashes/blinks/spellshields"] = "只使用位移/闪现/护盾",
["Draw this spell"] = "显示技能",
["Extra Width: "] = "额外宽度",
["Attempt to dodge from FoW"] = "尝试躲避战争迷雾里的技能",
["Allow casting while evading"] = "躲避的时候允许使用技能",
["Don't dodge from inside"] = "已在技能范围里时不躲避",
["Consider it dangerous"] = "判定此技能危险",
["    0 - Don't use dashes"] = "    0 - 不要使用位移",
["    1 - Use low CD spells"] = "    1 - 使用短cd技能",
["2..4 - Use more spells"] = "2..4 - 使用更多技能",
["    5 - Use flash"] = "    5 - 使用闪现",
["Blitzcrank | R - Static Field"] = "布里茨 | R - 静电力场",
["Simple"] = "简单",
["Advanced"] = "高级",
["\"Smooth\" Diagonal Evading"] = "平滑斜线躲避",
["Last Destination"] = "最后面向的方向",
["Mouse Position"] = "鼠标位置",
["Hero Position"] = "英雄位置",
["Allow Casting"] = "允许技能使用",
["Block Casting"] = "屏蔽技能使用",
["Modify/Block [Any direction]"] = "修正/屏蔽 [任何方向]",
["Modify/Block [Only towards cast position]"] = "修正/屏蔽 [顺着技能的方向]",
["Modify/Allow [Any direction]"] = "修正/允许 [任何方向]",
["Modify/Allow [Only towards cast position]"] = "修正/允许 [顺着技能的方向]",
["Minimum Range"] = "最小范围",
["Maximum Range"] = "最大范围",
["Randomized Range"] = "随机大小范围",
["Dodge \"Only Dangerous\" spells"] = "只躲避危险技能",
["To change the hotkey go to \"Controls\"."] = "在\"控制\"里修改热键",
["Disable"] = "关闭",
["Arrow"] = "箭头",
["Arrow [Outlined]"] = "箭头 [轮廓]",
["Show \"Doubleclick to remove!\""] = "显示\"双击移除躲避区域\"",
["Very Low"] = "非常低",
["Low"] = "低",
["Mid"] = "中",
["Very High"] = "很高",
["Ultra"] = "极限",
["Danger level: "] = "危险等级",
["Dodge <= X danger spells..."] = "在小于等于X个危险技能攻击你时躲避",
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
["*LessCastPriority Recommended"] = "推荐：最少使用技能+优先级",
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
["Save BotRK for max heal"] = "保留破败以获得最大治疗",
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
["Melee"] = "近战",
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
["Q Hit Chance"] = "Q的命中率",
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
["Draw E range"] = "显示E范围",
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
["Magnetic Wards"] = "便捷吸附性插眼",
["Enable Magnetic Wards Draw"] = "启用吸附性插眼显示",
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
["Delay the ultimate for more CC"] = "延迟大招释放以延长控制时间",
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
["None"] = "无",
["Pause Movement"] = "暂停移动",
["AutoCarry Mode"] = "自动连招输出模式",
["Target Lock Current Target"] = "锁定当前目标",
["Target Lock Selected Target"] = "锁定选定目标",
["Method 2"] = "方式2",
["Method 3"] = "方式3",
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
["Priority"] = "优先级",
["NearMouse"] = "离鼠标附近",
["MOST AD"] = "AD最高",
["MostAD"] = "AD最高",
["MOST AP"] = "AP最高",
["MostAP"] = "AP最高",
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
["Remove CC during: "] = "以下情况净化控制技能",
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
["Enable Streaming Mode (F7)"] = "启用屏蔽模式(F7)",
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
["Use W on CC or slow"] = "使用W来打控制或者群体减速",
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
["Only AutoUlt if CC Nearby <="]= "如果附近的控制小于等于X使用自动大招",
["Cancel Ult if no more enemies inside"] = "如果R范围内没有敌人则取消大招",
["Cancel Ult when you right click"] = "当你点击右键的时候取消大招",
["Block Ult cast if it will miss"] = "如果大招打不中的话就屏蔽大招释放",
["(Shift Override)"] = "(覆盖Shift)",
["Clear Settings"] = "清线设置",
["Jungle Clear Settings"] = "清野设置",
["Use Q in Jungle Clear"] = "在清野中使用Q",
["Show notifications"] = "显示提示信息",
["Show CC Counter"] = "显示控制技能计数",
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
["Ralphlol Kindred"] = "Ralphlol:千珏",
["Use Q gap-close "] = "使用Q接近敌人",
["In Combat Q Dash Method"] = "在战斗中Q位移的方式",
["Enable Ultimate"] = "启用大招",
["Use W in Wave Clear"] = "在清线中使用W",
["Also use champ Smite"] = "自动使用惩戒",
["Draw W Duration"] = "显示W持续时间",
["Draw R Duration"] = "显示R持续时间",
["Assisted Ultimate Key"] = "辅助大招按键",
["Malphite"] = "墨菲特",
["Keybindings are in the Orbwalking Settings menu"] = "按键设置在走砍设置菜单里",
["Ralphlol's Utility Suite"] = "Ralphlol的工具套件",
["Missed CS Counter"] = "漏刀计数器",
["X Position"] = "X轴位置",
["Y Position"] = "Y轴位置",
["Text Size"] = "文字大小",
["Jungler"] = "打野",
["Draw Enemy Waypoints"] = "显示敌人的行进路线",
["Draw Incoming Enemies"] = "显示即将赶到的敌人",
["Countdowns"] = " 倒计时",
["Ward Bush/ Pink Invis"] = "自动插真眼/神谕改造反隐",
["Key Activation"] = "热键",
["Max Time to check missing Enemy"] = "检查敌人消失的最大时间",
["Draw Minions"] = "显示小兵",
["Recall Positions"] = "回城地点",
["Print Messages"] = "显示消息",
---------------胖子意识---------------
["Big Fat Gosu"] = "胖子合集",
["Load Big Fat Mark IV"] = "加载胖子意识",
["Load Big Fat Evade"] = "加载胖子躲避",
["Sorry, this champion isnt supported yet =("] = "对不起,不支持这个英雄",
["Big Fat Gosu v. 3.61"] = "胖子合集v. 3.61",
["Big Fat Hev - Mark IV"] = "胖子意识",
["[Voice Settings]"] = "[语音设置]",
["Volume"] = "音量",
["Welcome"] = "欢迎",
["Danger!"] = "危险",
["Shutdown"] = "终结",
["SummonerSpells"] = "召唤师技能",
["WinLose sounds"] = "胜利/失败",
["Kill Announcer"] = "击杀播报",
["Shrooms Announcement"] = "踩蘑菇播报",
["Smite Announcement"] = "惩戒播报",
["JungleTimers Announcement"] = "打野计时播报",
["[Incoming Enemys to Track]"] = "[监视即将到来的敌人]",
["ON/OFF"] = "开/关",
["Stop track inc. enemys after x min"] = "x分钟后停止监视敌人",
["Allow this option"] = "允许此项设置",
["Scan Range"] = "扫描范围",
["Draw minimap"] = "小地图显示",
["Use Danger Sprite"] = "使用危险标志",
["Show waypoints"] = "显示行进路线",
["Enable Voice System"] = "启用语音系统",
["Jax"] = "贾克斯",
["[CD Tracker]"] = "[冷却计时器]",
["Use CD Tracker"] = "使用冷却计时器",
["[Wards to Track]"] = "[眼位监视]",
["Use Wards Tracker"] = "使用眼位监视",
["Use Sprites"] = "使用图片",
["Use Circles"] = "使用线圈",
["Use Text"] = "使用文字",
["[Recall Tracker]"] = "[回城监视]",
["Use Recall Tracker"] = "使用回城监视",
["Hud X"] = "HUD X轴位置",
["Hud Y"] = "HUD Y轴位置",
["Print Finished and Cancelled Recalls"] = "显示完成的回城和取消的回城",
["[BaseUlt]"] = "[基地大招]",
["Use BaseUlt"] = "使用基地大招",
["Print BaseUlt alert in chat"] = "在聊天框中显示基地大招提示",
["Draw BaseUlt Hud"] = "显示基地大招HUD",
["[Team BaseUlt Friends]"] = "[显示队友的基地大招]",
["[Tower Range]"] = "[防御塔范围]",
["Use Tower Ranges"] = "显示防御塔范围",
["Show only close"] = "只在接近防御塔时显示",
["Show ally turrets"] = "显示友军防御塔范围",
["Show turret view"] = "显示防御塔视野",
["Circle Quality"] = "线圈质量",
["Circle Width"] = "线圈宽度",
["[Jungle Timers]"] = "[打野计时]",
["Jungle Disrespect Tracker(FOW)"] = "无视野野区监视",
["Sounds for Drake and Baron"] = "大龙小龙提示音",
["(DEV) try to detect more"] = "(开发者)尝试检测更多信息",
["Enable Jungle Timers!!! Finally ^^"] = "最后,启用打野计时",
["[Enemies Hud]"] = "[敌人信息HUD]",
["Enable enemies hud"] = "启用敌人信息HUD",
["Hud Style"] = "HUD风格",
["Classic(small)"] = "经典(小)",
["Circle(medium)"] = "圆形(中)",
["Circle(big)"] = "圆形(大)",
["LowFps(Mendeleev)"] = "低fps",
["RitoStyle"] = "Rito风格",
["Hud Mode"] = "HUD模式",
["Vertical"] = " 垂直的",
["Horizontal"] = "水平的",
["HudX and HudY dont work for Old one"] = "HUD XY轴位置不会对经典风格生效",
["[Thresh Lantern]"] = "[锤石的灯笼]",
["Use Nearest Lantern"] = "捡最近的灯笼",
["Auto Use if HP < %"] = "如果生命值小于%自动使用",
["[Anti CC]"] = "[反控制]",
["Enable AntiCC"] = "启用反控制",
["[BuffTypes]"] = "[控制类型]",
["Disarm"] = "缴械",
["ForcedAction"] = "强制动作(嘲讽/魅惑)",
["Suppression"] = "压制",
["Suspension"] = "击飞",
["Slow"] = "减速",
["Blind"] = "致盲",
["Stun"] = "眩晕",
["Root"] = "禁锢",
["Silence"] = "沉默",
["Enable Mikael for teammates"] = "启用对队友使用坩埚",
["[TeamMates for Mikael]"] = "[对队友使用坩埚]",
["It will use Cleanse, Dervish Blade,"] = "它会使用净化,苦行僧之刃",
["Quicksilver Sash, Mercurial Scimitar"] = "水银饰带,水银弯刀",
[" or Mikael's Crucible."] = "或者米凯尔的坩埚",
["Suppressions by Malzahar, Skarner, Urgot,"] = "解除玛尔扎哈,斯卡纳,厄加特的压制",
["Warwick could be only removed by QSS"] = "狼人的压制只有水银能解",
["[Misc]"] = "[杂项]",
["Draw Exp Circle"] = "显示经验获得范围",
["Extra Awareness"] = "额外意识",
["Heal Cd's on Aram"] = "在大乱斗模式显示治疗cd",
["LordsDecree Cooldown"] = "雷霆领主的法令冷却时间",
["Big Fat Hev - Mark IV v. 4.001"] = "胖子意识 v. 4.001",
----------------烧伤剑圣巨魔螳螂-----------------
["Khazix Fun House 2.0"] = "烧伤合集2.0 - 卡兹克",
["Auto Harass Toggle"] = "自动骚扰开关",
["Prioritize Isolated"] = "孤立无援的目标优先",
["Back Flip Q Cast mid-jump"] = "向敌人后跳跃的空中使用Q ",
["--- Jump Logic ---"] = "--- 跳跃逻辑 ---",
["Save E in combo for KS"] = "在连招中留E抢人头",
["E engage if target very isolated"] = "如果目标孤立无援则先使用E",
["Double Jump Enabled"] = "击杀时使用两次跳跃",
["DbJump to max range intead of target"] = "两次跳跃跳到最远距离而不跳向目标",
["Auto DoubleJump offensive self hp"] = "自动两次跳跃的自身生命值",
["Auto DoubleJump def. enemy no"] = "自动两次跳跃的敌人数量",
["Auto DoubleJump delay"] = "自动两次跳跃延迟",
["Other Double Jump Positions"] = "两次跳跃的地点",
["SmartAuto"] = "智能自动模式",
["Mouse"] = "鼠标位置",
["Ally"] = "友军位置",
["Enemy"] = "敌人位置",
["Cast target killable with passive damage"] = "加上被动的伤害能够击杀时使用",
["Use Taste Their Fear (Q)"] = "使用品尝恐惧(Q)",
["Use Leap (E)"] = "使用跃击(E)",
["Use Void Spike (W)"] = "使用虚空突刺(W)",
["Draw Invis Time"] = "显示隐身时间",
["Cast Ignite on Sivir"] = "对希维尔使用点燃",
["E2 Hit Chance"] = "进化E命中的机会",
["Trundle Fun House"] = "烧伤合集 - 特朗德尔",
["Force R Key (current target)"] = "强制使用R按键(对当前目标)",
["--- Mana Settings ---"] = "--- 蓝量设置 ---",
["Minimum % Mana to use (W)"] = "使用W的最小蓝量",
["Use E as anti enemy gap closers"] = "使用E反突进",
["Use E as spell interruptor"] = "使用E打断敌人的技能",
["Use R on combo"] = "在连招中使用R",
["--- R Triggers ---"] = "--- R触发条件 ---",
["Minimum % HP to use (R)"] = "使用R的最小生命值%",
["R priority Mode"] = "R优先级模式",
["Defensive"] = "防御性",
["Selected Enemy"] = "选定的敌人",
["Use Chomp (Q)"] = "使用利齿撕咬(Q)",
["Use Frozen Domain (W)"] = "使用冰封领域(W)",
["Enable ks mode with R"] = "使用R抢人头",
["Enable Spells Draws"] = "启用技能线圈显示",
["-- Extra E draw options --"] = "--- E技能额外显示设置 ---",
["Draw E predicted position "] = "显示E技能预判位置",
["^ E hold: draw E | E twice: cast E"] = "按住E:显示E位置|E两次:使用E",
["Master Yi Fun House 2.0"] = "烧伤合集2.0 - 易",
["Master Yi Fun House"] = "烧伤合集 - 易",
["Forced Q Key"] = "强制使用Q按键",
["Use Q always (not recommended)"] = "总是使用Q(不推荐)",
["Use Q if: Q + 3x AA = kill enemy"]= "如果Q+3次平A能够击杀时使用Q",
["Use Q for avoid hard CC"] = "使用Q躲避硬控技能",
["Use Q for follow enemy dashes"] = "使用Q跟进敌人的位移",
["Use Q under X hp"] = "生命值低于x使用Q",
["Self hp % "] = "自身生命值%",
["Auto use Q for kill steal"] = "自动使用Q抢人头",
["Use W as life saver vs turret shots"] = "使用W减少防御塔伤害",
["Use W if Q CD for lower big damage"] = "当受到成吨伤害且QCD时使用W",
["Use W as AA reset"] = "使用W重置普攻",
["Only if killable"] = "仅当能击杀时",
["Use E on combo"] = "在连招中使用E",
["Auto R usage if we are slowed/exhausted"] = "被减速/虚弱时自动使用R",
["LaneClear Alpha Strike (Q)"] = "在清线中使用Q",
["LaneClear Wuju Style (E)"] = "在清线中使用E",
["Jungle Alpha Strike (Q)"] = "在清野中使用Q",
["Jungle Wuju Style (E)"] = "在清野中使用E",
["Cast Ignite on Malzahar"] = "对玛尔扎哈使用点燃",
-------------------女王ADC合集--------------
["AmberCarries - Kalista"] = "女王ADC合集 - 卡莉斯塔",
["[Kalista] - Combo Settings (SBTW)"] = "[卡莉斯塔] - 连招设置",
["Combo Key"] = "连招按键",
["Use (Q) in combo"] = "在连招中使用Q",
["OrbWalk Minion if no Target"] = "如果没有目标就A兵",
["[Kalista] - Harass Settings"] = "[卡莉斯塔] - 骚扰设置",
["Harass Key"] = "骚扰按键",
["Use (Q) in Harass"] = "在骚扰中使用Q",
["Use (E) in Harass"] = "在骚扰中使用E",
["[Kalista] - KillSteal Settings"] = "[卡莉斯塔] - 抢人头设置",
["Use KillSteal"] = "抢人头",
["[Kalista] - Balista Settings"] = "[卡莉斯塔] - 机器Q中释放大招设置",
["Use Balista"] = "使用此连招",
["Min Range to Blitz for Balista"] = "使用此连招的最大距离",
["[Kalista] - Spells Settings"] = "[卡莉斯塔] - 技能设置",
["(W) Settings"] = "W技能设置",
["Auto (W) - Bush revealer"] = "自动使用W探草丛",
["Max Range"] = "最大距离",
["(E) Settings"] = "E技能设置",
["Auto (E) if Unit Executable"] = "在单位能E死的时候使用E",
["Auto (E) Minion for Slow Unit"] = "E兵来减速单位",
["Only if unit not in AA Range"] = "当对面不在你的平A范围时才用E",
["Force Use if Closest Unit"] = "对离你最近的目标强制使用E",
["(R) Settings"] = "R技能设置",
["Auto (R)"] = "自动R",
["If ally HP < X %"] = "如果契约单位生命值小于X%",
["[Kalista] - Jungle Steal Settings"] = "[卡莉斯塔] - 抢野怪设置",
["Auto (E) Jungle Minion Executable"] = "能E死野怪时自动E",
["Execute Golem "] = "E假身",
["Execute Wolve "] = "E三狼",
["Execute Ghost "] = "E幽灵",
["Execute Gromp "] = "E蛤蟆",
["Execute Red Buff "] = "E红buff",
["Execute Blue Buff "] = "E蓝buff",
["Execute Crab"] = "E螃蟹",
["Execute Drake"] = "E小龙",
["Execute Nashor "] = "E大龙",
["[Kalista] - Last Hit Helper Settings"] = "[卡莉斯塔] - 尾刀助手设置",
["Auto (E) Minion Executable"] = "能E死小兵时自动E",
["if X minion Executable"] = "如果有X名小兵能E死",
["[Kalista] - Message Settings "] = "[卡莉斯塔] - 消息设置",
["Print Blitzcrank Shield"] = "显示机器人的盾",
["Print When Exhausted"] = "显示虚弱",
["Delay between each Message"] = "两条消息之间的延迟",
["[Kalista] - Misc Settings "] = "[卡莉斯塔] - 杂项设置",
["(E) Dmg Offset (+/- per stacks)"] = "E伤害计算调整(增加/减少)",
["[Kalista] -  Item Settings"] = "[卡莉斯塔] - 物品设置",
["Use Bilgewater Cutlass"] = "使用比尔吉沃特弯刀",
["Use BORTK"] = "使用破败王者之刃",
["Use Youmus"] = "使用幽梦之灵",
["Use Quicksilver Sash"] = "使用水银饰带",
["Use Mercurial Scimitar"] = "使用水银弯刀",
["Humanizer Delay (ms)"] = "拟人化延迟(毫秒)",
["Bush Revealer - Trinket ( blue/green)"] = "自动探草丛(饰品)",
["[Kalista] -  Auto Buy Settings"] = "[卡莉斯塔] - 自动买装备",
["Auto Buy Startup Item"] = "自动买出门装",
["Doran's Blade"] = "多兰剑",
["Health Potion"] = "血瓶",
["Blue Trinket"] = "蓝色饰品",
["Green Trinket"] = "绿色饰品",
["[Kalista] - Draw Settings "] = "[卡莉斯塔] - 绘图设置",
["Draw (Q) Range"] = "画出Q范围",
["Draw (E) Range"] = "画出E范围",
["Draw (R) Range"] = "画出R范围",
["Draw Sprite on Target"] = "在目标身上画标记",
["Draw (E) Damage"] = "显示E的伤害",
["Draw Minion/Jungle Executable"] = "显示能E死的小兵",
["Draw Damage Jungle Minion"] = "显示E对野怪的伤害",
["[Kalista] - OrbWalk Settings (SBTW)"] = "[卡莉斯塔] - 走砍设置",
["General-Settings"] = "常规设置",
["Orbwalker Enabled"] = "走砍生效开关",
["Stop Move when Mouse above Hero"] = "当英雄在鼠标下时停止",
["Range to Stop Move"] = "停止移动的区域",
["Focus Selected Target"] = "锁定选中的目标",
["ExtraDelay against Cancel AA"] = "平A的额外延迟",
["Spam Attack on Target"] = "尽可能多的攻击目标",
["Orbwalker Modus: "] = "走砍模式",
["To Mouse"] = "向鼠标移动",
["To Target"] = "向目标移动",
["Humanizer-Settings"] = "拟人化设置",
["Limit Move-Commands per Second"] = "限制每秒发送的移动指令",
["Max Move-Commands per Second"] = "每秒发送最多移动指令",
["Key-Settings"] = "按键设置",
["FightMode"] = "战斗模式",
["HarassMode"] = "骚扰模式",
["LaneClear"] = "清线",
["LastHit"] = "尾刀",
["Toggle-Settings"] = "显示开关状态设置",
["Make FightMode as Toggle"] = "显示战斗模式开关",
["Make HarassMode as Toggle"] = "显示骚扰模式开关",
["Make LaneClear as Toggle"] = "显示清线开关",
["Make LastHit as Toggle"] = "显示尾刀开关",
["Farm-Settings"] = "刷兵设置",
["Focus Farm over Harass"] = "骚扰时集中补兵",
["Extra-Delay to LastHit"] = "尾刀的额外延迟",
["Mastery-Settings"] = "天赋设置",
["Mastery: Butcher"] = "屠夫",
["Mastery: Arcane Blade"] = "双刃剑",
["Mastery: Havoc"] = " 毁灭",
["Mastery: Devastating Strikes"] = "毁灭打击",
["Draw-Settings"] = "显示设置",
["Draw Own AA Range"] = "画出自己的平A范围",
["Draw Enemy AA Range"] = "画出敌人的平A范围",
["Draw LastHit-Cirlce around Minions"] = "画出尾刀线圈",
["Draw LastHit-Line on Minions"] = "画出尾刀指示线",
["Draw Box around MinionHpBar"] = "在小兵的血条上画框",
["Color-Settings"] = "颜色设置",
["Color Own AA Range: "] = "自己平A线圈颜色",
["white"] = "白色",
["blue"] = "蓝色",
["red"] = "红色",
["black"] = "黑色",
["green"] = "绿色",
["orange"] = "橙色",
["Color Enemy AA Range (out of Range): "] = "敌人的平A范围颜色(范围之外)",
["Color Enemy AA Range (in Range): "] = "敌人的平A范围颜色(范围之外)",
["Color LastHit MinionCirlce: "] = "尾刀线圈颜色",
["Color LastHit MinionLine: "] = "尾刀指示线颜色",
["ColorBox: Minion is LasthitAble: "] = "当小兵可以尾刀时的颜色",
["none"] = "无",
["ColorBox: Wait with LastHit: "] = "当小兵等待被尾刀时的颜色",
["ColorBox: Can Attack Minion: "] = "可以攻击的小兵颜色",
["TargetSelector"] = "目标选择器",
["Priority Settings"] = "优先级设置",
["Focus Selected Target: "] = "集中选定的目标",
["never"] = "从不",
["when in AA-Range"] = "在平A范围时",
["Always"] = "总是",
["TargetSelector Mode: "] = "目标选择器模式",
["LowHP"] = "最低血量",
["LowHPPriority"] = "最低血量+优先级",
["LessCast"] = "使用技能最少",
["LessCastPriority"] = "使用技能最少+优先级",
["nearest myHero"] = "最近的英雄",
["nearest Mouse"] = "离鼠标最近",
["RawPriority"] = "优先级",
["Lucian"] = "卢锡安",
["Highest Priority (ADC) is Number 1!"] = "最高优先级为1",
["Debug-Settings"] = "调试设置",
["Draw Circle around own Minions"] = "在己方小兵上画圈",
["Draw Circle around enemy Minions"] = "在地方小兵上画圈",
["Draw Circle around jungle Minions"] = "在野怪上画圈",
["Draw Line for MinionAttacks"] = "在小兵血条上画平A指示线",
["Log Funcs"] = "日志功能",
["Cast (W) Exploit ( Ward Drake )"] = "用W开小龙的视野",
["Cast (W) Exploit ( Ward Nashor )"] = "用W开大龙的视野",
["Target Selector"] = "目标选择器",
["Target Selector Mode:"] = "目标选择模式",
["Low HP"] = "最低血量",
["Most AP"] = "AP最高",
["Most AD"] = "AD最高",
["Less Cast"] = "更少使用技能优先",
["Near Mouse"] = "离鼠标最近",
["Priority"] = "优先级",
["Low HP Priority"] = "最低血量+优先级",
["Less Cast Priority"] = "更少使用技能+优先级",
["Dead"] = "死亡的",
["Closest"] = "最近",


["AmberCarries - Quinn"] = "女王ADC合集 - 奎因",
["[Quinn] - Combo Settings (SBTW)"] = "[奎因] - 连招设置",
["Use (Q1) in combo"] = "在连招中使用Q-变身前",
["Use (Q2) in combo"] = "在连招中使用Q-变身后",
["Use (E1) in combo"] = "在连招中使用E-变身前",
["Use (E2) in combo"] = "在连招中使用E-变身后",
["Use (R1) in combo"] = "在连招中使用R-变身前",
["Use (R2) in combo"] = "在连招中使用R-变身后",
["[Quinn] - Harass Settings"] = "[奎因] - 骚扰设置",
["Use (Q1) in Harass"] = "在骚扰中使用Q-变身前",
["Use (E1) in Harass"] = "在骚扰中使用E-变身前",
["[Quinn] - Jungle Clear"] = "[奎因] - 清野设置",
["Jungle Clear Key"] = "清野按键",
["Use (Q1) in Jungle Clear"] = "在清野中使用Q-变身前",
["Use (E1) in Jungle Clear"] = "在清野中使用E-变身前",
["[Quinn] - Spell Settings"] = "[奎因] - 技能设置",
["(E1) Settings"] = "E-变身前设置",
["Use (E1) for:"] = "对..使用E-变身前",
["Range"] = "范围",
["Damage"] = "伤害",
["Never Cast if Unit got Passive"] = "如果目标身上有被动就不对他释放",
["Auto (W) when enemy go in bush "] = "当敌人进草时自动W开视野",
["(R1) Settings"] = "R-变身前 设置",
["Use (R1) if Target life < %"] = "当目标生命值小于X%时使用R-变身前",
["Maximum Enemi in Range: "] = "在范围内最大敌人数",
["Range: "] = "范围",
["Never Cast if my health < %"] = "如果自己生命值小于X%",
["(E2) Settings"] = "E-变身后 设置",
["Use (E2) for:"] = "对目标使用E-变身后：",
["Engage"] = "战斗",
["(R2) Settings"] = "R-变身后设置",
["For kill Target"] = "为了杀死目标",
["If no enemi in Range"] = "如果范围内没有目标",
["[Quinn] - Tower Dive Settings"] = "[奎因] - 越塔设置",
["Only if Ally is under tower"] = "仅当友军在塔下时",
["Force use if enemy HP < % "] = "当敌方生命值小于X%强制使用",
["Use (E1) for Tower Dive"] = "使用E-变身前越塔",
["Use (R) for Tower Dive"] = "使用R越塔",
["[Quinn] - KillSteal Settings"] = "[奎因] - 抢人头设置",
["Use (Q1) in KillSteal"] = "使用Q-变身前抢人头",
["Use (Q2) in KillSteal"] = "使用Q-变身后抢人头",
["Use (R2) in KillSteal"] = "使用R-变身后抢人头",
["[Quinn] - Passive Settings"] = "[奎因] - 被动设置",
["Force Proc Passive"] = "强制触发被动",
["[Quinn] - Wall Jump Settings"] = "[奎因] - 穿墙设置",
["Wall Jump Key"] = "穿墙按键",
["[Quinn] - Gap Closer Settings"] = "[奎因] - 反突进设置",
["JarvanIV - Spell: JarvanIVDragonStrike"] = "皇子 - Q技能",
["JarvanIV - Spell: JarvanIVCataclysm"] = "皇子 - E技能",
["[Quinn] - Interupte Spell Settings"] = "[奎因] - 打断技能设置",
["[Quinn] - Draw Settings "] = "[奎因] - 显示设置",
["Draw (Q1) Range"] = "显示Q-变身前范围",
["Draw (W) Range"] = "显示W范围",
["Draw (Q2) Range"] = "显示Q-变身后范围",
["Draw (E2) Range"] = "显示E-变身后范围",
["Draw (R2) Range"] = "显示R-变身后范围",
["Draw Ulti Time Remaining"] = "显示大招倒计时",
["Draw R2 Damage"] = "显示R-变身后的伤害",
["[Quinn] -  Item Settings"] = "[奎因] - 物品设置",
["[Quinn] -  Auto Buy Settings"] = "[奎因] - 自动购买设置",
["[Quinn] - OrbWalk Settings (SBTW)"] = "[奎因] - 走砍设置",
["AmberCarries - Kog'Maw"] = "女王ADC合集 - 大嘴",
["[KogMaw] - Combo Settings (SBTW)"] = "[大嘴] - 连招设置",
["Choose your Role"] = "选择你的位置",
["ADC"] = "ADC",
["AP MID"] = "AP中单",
["Use (Q)"] = "使用Q",
["Use (W)"] = "使用W",
["Use (E)"] = "使用E",
["Use (R)"] = "使用R",
["[KogMaw] - Harass Settings"] = "[大嘴] - 骚扰设置",
["[KogMaw] - KillSteal Settings"] = "[大嘴] - 抢人头设置",
["[KogMaw] - Misc Settings"] = "[大嘴] - 杂项设置",
["Use Auto Passive"] = "自动使用被动",
["[KogMaw] - Spells Settings"] = "[大嘴] - 技能设置",
["[KogMaw] - (Q) Spells"] = "[大嘴] - Q技能",
["(Q) Max Range"] = "Q最大距离",
["(Q) Min Range"] = "Q最小距离",
["[KogMaw] - (W) Spells"] = "[大嘴] - W技能",
[" 0  Only use if Target out of range"] = "0 - 当对手不在攻击范围",
[" 1  Use for Increase Damage"] = "1 - 用以打出高输出",
["Choose your (W) type"] = "选择你W技能的模式",
["[KogMaw] - (E) Spells"] = "[大嘴] - E技能",
["(E) Max Range"] = "E最大距离",
["(E) Min Range"] = "E最小距离",
["Only Use If Closest Enemy"] = "只对最近的敌人使用",
["Max Range: "] = "最大距离： ",
["[KogMaw] - (R) Spells"] = "[大嘴] - R技能",
["Maximum Stack"] = "最大R被动数",
["Use if Mana > X %"] = "当蓝量大于X%",
["[KogMaw] -  Item Settings"] = "[大嘴] - 物品设置",
["[KogMaw] -  Auto Buy Settings"] = "[大嘴] - 自动购买设置",
["Doran's Ring"] = "多兰戒",
["[KogMaw] - Draw Settings"] = "[大嘴] - 显示设置",
["[KogMaw] - Prediction Settings"] = "[大嘴] - 预判设置",
["0  VPred | 1  DP"] = "0 - VP预判|1 - 神圣预判",
["-> DivinePred have a better prediction"] = "->神圣预判效果更好",
["Make sure you got it before"] = "切换神圣预判前确保你已经拥有",
["[KogMaw] - Orbwalking Settings"] = "[大嘴] - 走砍设置",
["AmberCarries - Draven"] = "女王ADC合集 - 德莱文",
["[Draven] - Combo Settings"] = "[德莱文] - 连招设置",
["Use (W) in combo"] = "在连招中使用W",
["Use (E) in combo"] = "在连招中使用E",
["Use (R) in combo"] = "在连招中使用R",
["[Draven] - Harass Settings"] = "[德莱文] - 骚扰设置",
["Use (W) in harass"] = "在骚扰中使用W",
["[Draven] - Lane Clear Settings"] = "[德莱文] - 清线设置",
["Lane Clear Key"] = "清线按键",
["Use (Q) in lane clear"] = "在清线中使用Q",
["How Many Axe:"] = "斧头的数量",
["[Draven] - Last Hit Settings"] = "[德莱文] - 尾刀设置",
["Last Hit Key"] = "尾刀按键",
["[Draven] - Spells Settings"] = "[德莱文] - 技能设置",
["[Draven] - (Q) Spells Settings"] = "[德莱文] - Q技能设置",
["Auto Catch Axe: "] = "自动捡斧头",
["ToMouse"] = "向鼠标位置",
["ToHero"] = "向英雄位置",
["Dont"] = "不要捡斧头",
["Range Area:"] = "范围",
["If ToHero Choose"] = "如果向英雄位置选择",
["Auto Catch Axes (ToHero)"] = "自动捡斧头(向英雄位置)",
["Block if unit killable"] = "目标可击杀时不自动接斧头",
["With x AutoAttack:"] = "X次平A后",
["[Draven] - (W) Spells Settings"] = "[德莱文] - W技能设置",
["Use (W) for reach Axe: "] = "使用W去接斧头",
["IfNeed"] = "如果必要",
["AllTime"] = "总是",
["Use (W) If closest Unit"] = "如果被突进时使用W",
["Use (W) if Unit not in range"] = "如果目标不在平A范围内",
["[Draven] - (E) Spells Settings"] = "[德莱文] - E技能设置",
["Min Range:"] = "最小范围",
["Mana > X%"] = "蓝量大于X%",
["[Draven] - (R) Spells Settings"] = "[德莱文] - R技能设置",
["[Draven] - Gap Closer Settings"] = "[德莱文] - 反突进设置",
["[Draven] - Interupte Spell Settings"] = "[德莱文] - 打断技能",
["[Draven] -  Item Settings"] = "[德莱文] - 物品设置",
["[Draven] -  Auto Buy Settings"] = "[德莱文] - 自动购买物品",
["[Draven] - Draw Settings"] = "[德莱文] - 显示设置",
["Draw (Q) Area"] = "显示Q的区域",
["Draw Axe"] = "显示斧头位置",
["[Draven] - OrbWalk Settings"] = "[德莱文] - 走砍设置",
["Sivir"] = "轮子妈",
["AmberCarries - Twitch"] = "女王ADC合集 -图奇",
["[Twitch] - Combo Settings (SBTW)"] = "[图奇] - 连招设置",
["[Twitch] - Harass Settings (SBTW)"] = "[图奇] - 骚扰设置",
["Use (E) if X stacks"] = "当有X层被动时使用E",
["Harass if mana > X%"] = "当蓝量大于X%时骚扰",
["[Twitch] - Spells Settings"] = "[图奇] - 技能设置",
["[Twitch] - (Q) Settings"] = "[图奇] - Q技能",
["Min Range to enemy"] = "离敌人的最小距离",
["Max Range to enemy"] = "离敌人的最大距离",
["If stealth block (W)"] = "当隐身时不释放W",
["If stealth block (R)"] = "当隐身时不释放R",
["[Twitch] - (W) Settings"] = "[图奇] - W技能设置",
["Use (W) for:"] = "W技能释放：",
["When X stacks"] = "当有X层被动",
["IF When X Stacks Need Picked"] = "当有X层被动需要被选择",
["Stack Number"] = "被动层数",
["Auto use if X enemy hitable"] = "当X名目标可被释放时",
["Numbers enemy"] = "敌人数量",
["If my Mana > X% "] = "如果蓝量大于X%",
["HitChance"] = "击中的可能性",
["[Twitch] - (E) Settings"] = "[图奇] - E技能设置",
["Use (E) for:"] = "E技能释放：",
["For Execute"] = "可以击杀敌人时",
["When 6 Stacks"] = "6层被动时",
["If For execute Picked"] = "如果选择的敌人可以击杀",
["Use if X enemi executable"] = "如果X名敌人可以击杀",
["Unit Executable Without Ultimate: "] = "单位可以不用大招击杀",
["Unit Executable Under Ultimate: "] = "单位可以用大招击杀",
["If When 6 Stacks Picked"] = "如果选择的敌人有6层被动",
["When X enemy got 6 stacks"] = "当X名敌人有6层被动",
["Force Execute if unit killable"] = "如果目标可以被击杀强制释放",
["Keep Mana For (E)"] = "保留E技能的蓝量",
["[Twitch] - (R) Settings"] = "[图奇] - R技能设置",
["Use (R) if X enemy in range"] = "如果X名敌人在范围内使用R",
["Enemy Max Range: "] = "敌人最大距离",
["Use (R) if X ally in range"] = "如果X名友军在范围内",
["Ally Max Range: "] = "友军最大距离",
["[Twitch] - Tower Dive Settings"] = "[图奇] - 越塔设置",
["Use (R) for dive"] = "越塔时使用R",
["Only if (E) Ready"] = "只当E技能好时",
["Target life < X% hp"] = "当目标生命值小于X%",
["[Twitch] -  Item Settings"] = "物品设置",
["[Twitch] -  Auto Buy Settings"] = "自动购买设置",
["[Twitch] - Draw Settings"] = "显示设置",
["Draw Stealth State"] = "显示隐身状态",
["Draw Ulti Time left"] = "显示R技能剩余时间",
["[Twitch] - Jungle Steal Settings"] = "[图奇] - 抢野怪设置",
["[Twitch] - OrbWalk Settings (SBTW)"] = "[图奇] - 走砍设置",
["AmberCarries - Lucian"] = "女王ADC合集 - 卢锡安",
["[Lucian] - Combo Settings"] = "[卢锡安] - 连招设置",
["Combo Order "] = "连招顺序",
["No Order"] = "无序",
["[Lucian] - Harass Settings"] = "[卢锡安] - 骚扰设置",
["Mana > X%:"] = "蓝量大于X%",
["[Lucian] - LaneClear Settings"] = "[卢锡安] - 清线设置",
["LaneClear Key"] = "清线按键",
["[Lucian] - Spells Settings"] = "技能设置",
["(Q) Settings"] = "Q技能设置",
["Use on Minion for hit Target"] = "当可以穿小兵击中敌人时",
["Use if unit out range"] = "当目标在范围外时",
["~ AND ~"] = "~ & ~",
["Unit Health < X%:"] = "目标血量小于X%",
["AutoMove"] = "自动移动",
["Use Only if ComboKey Press"] = "仅当连招按键按下时",
["Use E if needed"] = "如果需要的时候使用E",
["[Lucian] -  Item Settings"] = "[卢锡安] - 物品设置",
["[Lucian] -  Auto Buy Settings"] = "[卢锡安] - 自动购买设置",
["[Lucian] - Gap Closer Settings"] = "[卢锡安] - 反突进设置",
["[Lucian] - Draw Settings"] = "[卢锡安] - 显示设置",
["Draw (E) CD"] = "显示E技能CD",
["[Lucian] - OrbWalk Settings"] = "[卢锡安] - 走砍设置",
["Zyra"] = "婕拉",
["AmberCarries - Vayne"] = "女王ADC合集 - 薇恩",
["[Vayne] - Combo Settings (SBTW)"] = "[薇恩] - 连招设置",
["[Vayne] - Wall Tumble Settings"] = "[薇恩] - 穿墙设置",
["Wall Tumble Key"] = "穿墙按键",
["[Vayne] - Harass Settings"] = "[薇恩] - 骚扰设置",
["[Vayne] - Lane Clear Settings"] = "[薇恩] - 清线设置",
["If my mana > X%"] = "如果蓝量大于X%",
["[Vayne] - Spell Settings"] = "[薇恩] - 技能设置",
["Use (Q) for:"] = "使用Q用以：",
["Reset AA CD"] = "重置普攻",
["When Castable"] = "当可用时",
["Proc W + Reset AA CD"] = "触发W + 重置普攻",
["Use (Q) for Kite"] = "用Q来风筝敌人",
["Max Range to Enemy for Kite"] = "风筝敌人的最大距离",
["Force (Q) if unit not in AA Range"] = "如果目标不在普攻范围强制Q",
["Stun"] = "眩晕",
["Reset AA & Stun"] = "重置普攻 + 眩晕",
["Stun Chance"] = "眩晕的机会",
["Auto Stun"] = "自动眩晕目标",
["Max Wall Range For Stunt"] = "眩晕时离墙的最大距离",
["Use (R) if:"] = "以下情况使用R",
["Target life < %"] = "目标生命小于X%",
["My life > %"] = "自己生命值大于X%",
["Minimum Enemi in Range: "] = "在范围内最少有X名敌人",
["Minimum Ally in Range: "] = "在范围内最少有X名友军",
["Keep Invisibily"] = "保持隐身状态",
["Only if closest enemy"] = "仅当自己被突进",
["[Vayne] - Tower Dive Settings"] = "[薇恩] - 越塔设置",
["Use (Q) for Tower Dive"] = "用Q技能来越塔",
["[Vayne] - KillSteal Settings"] = "[薇恩] - 抢人头设置",
["Use (E) in KillSteal"] = "用E来抢人头",
["[Vayne] - Gap Closer Settings"] = "[薇恩] - 反突进设置",
["[Vayne] - Interupte Spell Settings"] = "[薇恩] - 打断技能",
["[Vayne] -  Item Settings"] = "[薇恩] - 物品设置",
["[Vayne] -  Auto Buy Settings"] = "[薇恩] - 自动购买物品",
["[Vayne] - Draw Settings "] = "显示设置",
["Draw (Q) type: "] = "显示Q的类型",
["Draw (E) Predict on unit"] = "显示E技能的预判",
["Draw Damage"] = "显示伤害",
["Draw WallTumble Circle"] = "显示穿墙的圆圈",
["[Vayne] - OrbWalk Settings (SBTW)"] = "[薇恩] - 走砍设置",
["No enemy heroes were found!"] = "没有发现敌人",
--------------------绝对妖姬--------------------------
["Leblanc's Skillshots Settings"] = "乐芙兰技能弹道设置",
["[eSkillShot] Spell Settings"] = "[E技能弹道设置]",
["Override Minimum Hit % "] = "覆盖最小命中率",
["Overriden Minumum Hit %"] = "被覆盖的最小命中率",
["Prediction Cooldown (ms)"] = "预判冷却时间(ms)",
["[wSkillShot] Spell Settings"] = "[W技能弹道设置]",
["Totally LeBlanc - Totally Legit"] = "绝对妖姬",
["Totally LeBlanc  -  Key Settings"] = "绝对妖姬 - 按键设置",
["Combo GapClose Key"] = "突进连招按键",
["Combo Chain Key"] = "幻影锁链连招按键",
["Farm Key"] = "发育按键",
["Totally LeBlanc  -  Combo"] = "绝对妖姬 - 连招",
["Ethereal Chains (E)"] = "幻影锁链(E)",
["Max range:"] = "最大范围",
["Min width:"] = "最小宽度",
["Draw range"] = "显示技能范围",
["Perform Combo:"] = "使用的连招",
["Use AAs"] = "使用平A",
["Use W to GapClose"] = "使用W接近目标",
["Force ADC/APC"] = "强制攻击ADC/APC",
["Totally LeBlanc  -  Settings: W"] = "绝对妖姬 - W技能设置",
["Use Optional W Settings"] = "使用自定义W技能设置",
["Return: "] = "返回: ",
["Target dead"] = "目标死亡",
["Skills used"] = "技能用完",
["Both"] = "以上两者",
["Totally LeBlanc  -  Harass"] = "绝对妖姬 - 骚扰",
["Use Sigil of Malice (Q)"] = "使用恶意魔印(Q)",
["Use Distortion (W)"] = "使用魔影迷踪(W)",
["Use Ethereal Chains (E)"] = "使用幻影锁链(E)",
["Mana Manager %"] = "蓝量控制%",
["Totally LeBlanc  -  Farming"] = "绝对妖姬 - 发育",
["Minions outside AA range only"] = "只对在平A距离外的小兵使用",
["Farm if AA is on CD"] = "在平A的间隙使用技能发育",
["Totally LeBlanc  -  Laneclear"] = "绝对妖姬 - 清线",
["Use Mimic (R)"] = "使用故技重施(R)",
["Min minions to WR"] = "使用WR的最少小兵数",
["Min minions to W and WR"] = "使用W和WR的最少小兵数",
["Totally LeBlanc  -  KillSteal"] = "绝对妖姬 - 抢人头",
["Excecute"] = "",
["Not in Combo"] = "不在连招中使用",
["No other mode active"] = "其他模式未激活时",
["GapClose to kill enemy"] = "突进以击杀敌人",
["Gapclose > Q + R"] = "突进优先于Q+R",
["KillSteal Enemy"] = "使用抢人头的对象",
["Totally LeBlanc  -  Drawings"] = "绝对妖姬 - 显示",
["Lag-Free Circles"] = "不影响延迟的线圈",
["Use Lag-Free Circles"] = "使用不影响延迟的线圈",
["Length before Snapping"] = "",
["Use Drawings"] = "启用显示",
["Draw Sigil of Malice (Q)"] = "显示恶意魔印(Q)",
["Draw Distortion (W)"] = "显示魔影迷踪(W)",
["Draw Ethereal Chains (E)"] = "显示幻影锁链(E)",
["Draw Killable Text"] = "显示可击杀提示",
["Draw Killable Width"] = "显示击杀提示的宽度",
["Don't draw if spell is CD"] = "技能cd时不显示线圈",
["Totally LeBlanc  -  Prediction"] = "绝对妖姬 - 预判",
["Prediction Type:"] = "预判类型",
["VPrediction HitChance"] = "V预判的命中率",
["DivinePred HitChance"] = "神圣预判的命中率",
["Totally LeBlanc  -  Misc"] = "绝对妖姬 - 杂项",
["Auto Level"] = "自动加点",
["Use Auto Level"] = "使用自动加点",
["What to max?"] = "哪个技能先满级？",
["Use Summoner Ignite"] = "使用点燃",
["Zhyonas"] = "中亚",
["Use Zhonyas under % health"] = "生命值低于%时使用中亚",
["Auto Ignite Potion"] = "自动点燃血瓶",
["Drink Health Pot when Ignited"] = "被点燃时自动吃血瓶",
["Totally LeBlanc  -  OrbWalker"] = "绝对妖姬 - 走砍",
["Totally LeBlanc  -  TargetSelector Modes"] = "绝对妖姬 - 目标选择器模式",
["License"] = "许可",
["Patch: "] = "版本",
["Farm"] = "发育",
------------------王者视图------------------
["--------- LANGUAGE --------"] = "--------- 语言选择 ---------",
["Language"] = "语言",
["English"] = "英语",
["German"] = "德语",
["Portuguese"] = "葡萄牙语",
["Spanish"] = "西班牙语",
["French"] = "法语",
["Italian"] = "意大利语",
["Turkish"] = "土耳其语",
["Polski"] = "波兰语",
["------ Quick Toggles ------"] = "------ 快捷开关 ------",
["Hidden Objects"] = "隐形的单位",
["Aggro targets"] = "仇恨的目标",
["Side HUD"] = "HUD显示",
["Waypoints"] = "行进路线",
["Minimap SS"] = "小地图消失显示",
["Clone revealer"] = "分身探测器",
["Clone Revealer"] = "分身探测器",
["Recall Alert"] = "回城提示",
["Tower Ranges"] = "防御塔范围",
["Minimap Timers"] = "小地图计时器",
["Lasthit Helper"] = "尾刀助手",
["Notification System"] = "提醒系统",
["Spell Timer Drawings"] = "技能计时器显示",
["Other drawings"] = "其他显示",
["Sounds"] = "声音",
["Use sprites on minimap"] = "在小地图显示图片",
["Draw enemy team wards"] = "显示敌人眼位",
["Draw enemy team traps"] = "显示敌人的陷阱",
["Draw own team wards"] = "显示己方眼位",
["Draw own team traps"] = "显示己方陷阱",
["Draw type"] = "显示样式",
["Circular"] = "圆形的",
["Precise"] = "精确的",
["Circles quality"] = "线圈质量",
["Add Custom Ward Key"] = "添加习惯性眼位按键",
["Remove Custom Ward Key"] = "移除习惯性眼位按键",
["Key to hold to draw range"] = "按住显示范围按键",
["Key to toggle draw range"] = "开关显示范围按键",
["Expiring wards"] = "即将消失的眼位",
["Change expiring wards color"] = "修改即将消失的眼位的颜色",
["Expiring wards color"] = "即将消失的眼位的颜色",
["Change color below (seconds)"] = "在眼位时间小于x秒时改变颜色",
["Custom Wards"] = "习惯性眼位",
["Enemy Sight Wards"] = "敌人的假眼",
["Enemy Vision Wards"] = "敌人的真眼",
["Enemy Traps"] = "敌人的陷阱",
["Ally Sight Wards"] = "友军的假眼",
["Ally Vision Wards"] = "友军的真眼",
["Ally Traps"] = "友军的陷阱",
["Circles and lines"] = "线圈和线条",
["Lines"] = "指示线",
["Width of lines and circles"] = "线圈和线条的宽度",
["Quality of circle"] = "线圈的质量",
["Side enemy HUD"] = "侧边敌人HUD显示",
["HUD horizontal position"] = "HUD水平位置",
["HUD vertical position"] = "HUD垂直位置",
["Summ cds"] = "召唤师技能cd",
["Seconds"] = "秒",
["Game time"] = "游戏时间",
["Scale"] = "比例",
["Cooldowns Tracker"] = "冷却时间计时",
["Show enemy QWER cooldowns"] = "显示敌人QWER冷却",
["Classic"] = "经典",
["Classic R"] = "经典 R",
["Show enemy summoner cooldowns"] = "显示敌人召唤师技能冷却",
["Show ally QWER cooldowns"] = "显示友军QWER冷却",
["Show ally summoner cooldowns"] = "显示友军召唤师技能冷却",
["Show my QWER cooldowns"] = "显示自己QWER冷却",
["Show my summoner cooldowns"] = "显示自己的召唤师技能冷却",
["Cooldown"] = "冷却时间",
["No mana to cast"] = "没蓝放技能",
["No energy to cast"] = "没能量放技能",
["No valid targets"] = "没有可用目标",
["CD spell/text"] = "技能CD文字",
["Unknown"] = "未知",
["Draw paths also on minimap"] = "在小地图显示路径",
["Draw enemy path"] = "显示敌军路径",
["Draw enemy path time"] = "显示敌军路径时间",
["Draw ally path"] = "显示友军路径",
["Draw ally path time"] = "显示友军路径时间",
["Cross type"] = "十字交叉类型",
["Light"] = "轻量的",
["Ally cross color"] = "友军十字交叉颜色",
["Enemy cross color"] = "敌军十字交叉颜色",
["Ally lines color"] = "友军指示线颜色",
["Enemy lines color"] = "敌人指示线颜色",
["Cross size (only Normal type)"] = " ",
["Cross width (only Normal type)"] = " ",
["Show missing timer"] = "显示丢失的计时器",
["Show grey icon"] = "显示灰色图标",
["Draw timer after (seconds)"] = "x秒后显示计时器",
["Text color for SS timer"] = "丢失视野计时器文字颜色",
["Autoping SS (bol broken)"] = "丢失视野自动标记(bol功能损坏)",
["Auto SS enabled"] = "启用视野丢失提醒",
["Autoping SS after (seconds)"] = "丢失视野x秒后自动标记",
["Clone-able player circle color"] = "有分身的敌人线圈颜色",
["Circle quality"] = "线圈质量",
["Mark all enemy heroes"] = "标记所有敌方英雄",
["Draw recall sprite on minimap"] = "在小地图上显示回城图片",
["Recall Bar color"] = "回城读条的颜色",
["Recall Bar background color"] = "回城读条的背景颜色",
["Teleport Bar color"] = "传送读条的颜色",
["Teleport Bar background color"] = "传送读条的背景颜色",
["Color chat messages"] = "消息框消息颜色",
["Print recall cancel"] = "显示回城取消",
["Print teleport cancel"] = "显示传送取消",
["Min distance to draw range"] = "显示范围线圈的最小距离",
["Quality of towers ranges"] = "防御塔范围线圈的质量",
["Width of towers ranges"] = "防御塔范围线圈的宽度",
["Draw own team towers ranges"] = "显示己方防御塔范围",
["Own towers range color"] = "己方防御塔范围颜色",
["Draw enemy towers ranges"] = "显示敌方防御塔范围",
["Enemy towers ranges color"] = "敌方防御塔范围颜色",
["Enemy towers ranges color (danger)"] = "敌方防御塔范围(危险)",
["Enemy towers ranges color (aggro)"] = "敌方防御塔范围(被锁定)",
["Jungle Camps timers"] = "打野计时",
["Jungle Camps text size"] = "打野计时文字大小",
["Jungle Camps text color"] = "打野计时文字颜色",
["(bol broken) Ping when big monsters respawns"] = "大型野怪复活时标记(bol功能损坏)",
["Only me"] = "只是自己",
["My team"] = "己方队伍",
["Jungle camps to draw"] = "显示的野怪营地",
["Wight"] = "大幽灵",
["Red and Blue"] = "红蓝buff",
["Razorbeaks"] = "锋喙鸟",
["Murkwolves"] = "幻影狼",
["Crabs"] = "螃蟹",
["Inhibitors timers"] = "水晶计时器",
["Towers health (%)"] = "防御塔生命值(百分比显示)",
["Towers health (numeric)"] = "防御塔生命值(数值显示)",
["Inhibs/Tower Hp text size"] = "水晶/防御塔生命值文字大小",
["Inhibs/Tower Hp text color"] = "水晶/防御塔生命值文字颜色",
["Horizontal offset"] = "水平预设",
["Vertical offset"] = "垂直预设",
["Distance from player to draw helper"] = "显示补刀助手时离玩家的距离",
["Healthbar color of killable minion"] = "可被击杀的小兵血条颜色",
["Type of drawing for last hittable minions"] = "可被尾刀的小兵血条显示样式",
["Mark Healthbar"] = "标记血条",
["Draw circle"] = "显示线圈",
["Force enabling"] = "强制生效",
["Max notifies at the same time"] = "同时显示的最大提醒条目数",
["Duration of notifies"] = "提醒的持续时间",
["Color of notifies"] = "提醒的文字颜色",
["---- Events to show ----"] = "---- 事件提示 ----",
["An enemy disconnects"] = "一个敌军掉线",
["(bol broken) Ally ping SS"] = "(bol功能损坏)友军标记敌军消失",
["Red/Blue respawn"] = "红蓝buff重生",
["Dragon/Baron/Vilemaw respawn"] = "小龙/大龙/卑鄙之喉重生",
["Enemy gank incoming"] = "即将到来的敌人Gank",
["Spells casted"] = "被使用的技能",
["Rengar R"] = "狮子狗R",
["Pantheon R (1st)"] = "潘森一段大招(堕天一击)",
["Pantheon R (land)"] = "潘森二段大招(着陆)",
["TwistedFate R1 (Destiny)"] = "卡牌一段大招(命运)",
["TwistedFate R2 (Gate)"] = "卡牌二段大招(传送)",
["Map Drawings"] = "小地图显示",
["--- Jungle timers ---"] = "--- 打野计时 ---",
["Camp respawn"] = "野怪营地重生",
["--- Spell timers ---"] = "--- 技能计时 ---",
["Akali Bubble"] = "阿卡丽的奥义!霞阵(W)",
["Tryndamere Ultimate"] = "泰达米尔的大招",
["Kayle Ultimate"] = "凯尔的大招",
["Pantheon Ultimate"] = "潘森的大招",
["Twisted Fate Ultimate"] = "卡牌的大招",
["Thresh Lantern"] = "锤石的灯笼",
["Gangplank Ultimate"] = "船长的大招",
["Braum Shield"] = "布隆的盾牌",
["Fiddlesticks Ultimate"] = "稻草人的大招",
["Warwick Ultimate"] = "狼人的大招",
["Wukong Decoy"] = "猴子W",
["Wukong Ultimate"] = "猴子的大招",
["Rammus Ultimate"] = "龙龟的大招",
["Nasus Ultimate"] = "狗头的大招",
["Renekton Ultimate"] = "鳄鱼的大招",
["Alistar Ultimate"] = "牛头的大招",
["Amumu Ultimate"] = "阿木木的大招",
["Graves grenade"] = "男枪的W",
["Morgana shield"] = "莫甘娜的盾",
["Karthus Wall"] = "死歌的W",
["Blitzcrank shield"] = "机器人的被动",
["Galio Ultimate"] = "加里奥的大招",
["Taric Ultimate"] = "宝石的大招",
["Anivia egg"] = "冰鸟的蛋",
["Mundo Ultimate"] = "蒙多的大招",
["Autoattack ranges"] = "平A范围",
["--------- Enemies --------"] = "--------- 敌军 --------",
["Full circle"] = "完整线圈",
["Perpendicular line"] = "垂直线",
["Circle section"] = "线圈部分",
["Distance from you to draw"] = "显示时离你的距离",
["Color of range"] = "线圈颜色",
["--------- My hero --------"] = "--------- 自己的英雄 --------",
["Distance from enemy to draw"] = "显示时离敌军的距离",
["Show for"] = "显示的对象",
["Sound type"] = "声音类型",
["Gank alert"] = "gank提示",
["Enemy Red/Blue respawn"] = "敌方红蓝buff重生",
["Ally Red/Blue respawn"] = "己方红蓝buff重生",
["Dragon/Baron respawn"] = "大龙/小龙重生",
["Dragon/Baron under attack"] = "大龙/小龙被攻击",
["Early game ends at minute"] = "游戏前期结束的时间",
["Store chats"] = "商店对话",
["Hide loaded message"] = "隐藏加载信息",
["Reload sprites button"] = "重新加载图片按钮",
["Show surrender votes"] = "显示投降投票信息",
["Real Life Info"] = "实际生活信息",
["Show date"] = "显示日期",
["Show time"] = "显示时间",
["Color of infos"] = "信息的颜色",
["Show latency and FPS"] = "显示fps和延迟",
["Horizontal position"] = "水平位置",
["Draw experience range"] = "显示经验获得范围",
["Disable after early game (see 'Other')"] = "游戏前期之后关闭",
["Color of experience range circle"] = "经验获得范围线圈的颜色",
["Quality of exp range circle"] = "经验获得范围线圈的质量",
["Width of exp range circle"] = "经验获得范围线圈的宽度",
["Minion Bar"] = "小兵血条",
["Missed CS"] = "漏刀计数",
["Troubleshooting"] = "疑难解答",
["Disable sprites (need reload)"] = "关闭图片显示(需要重新加载)",
["Disable fullscreen warning (need reload)"] = "关闭全屏警告(需要重新加载)",
["Color of timers"] = "计时器颜色",
["Silenced"] = "沉默",
["AutoAttack ranges"] = "平A范围线圈",
--------------------------奇妙德莱文-------------------
["Fantastik Draven"] = "奇妙德莱文",
["Combo key(Space)"] = "连招按键(空格)",
["Farm key(X)"] = "发育按键(X)",
["Harass key(C)"] = "骚扰按键(C)",
["Min. % mana for W and E "] = "使用W和E的最小蓝量",
["Laneclear Settings"] = "清线设置",
["Use Q in 'Laneclear'"] = "在清线中使用Q",
["Use W in 'Laneclear'"] = "在清线中使用W",
["Jungleclear Settings"] = "清野设置",
["Use Q in 'Jungleclear'"] = "在清野中使用Q",
["Use W in 'Jungleclear'"] = "在清野中使用W",
["Draw Killable targets with R"] = "显示R能够击杀的目标",
["Misc"] = "杂项",
["KillSteal Settings"] = "抢人头设置",
["Use Ult KS"] = "使用大招抢人头",
["Avoid R Overkill"] = "避免",
["Ult KS range"] = "大招抢人头的范围",
["Use Ignite KS"] = "使用点燃抢人头",
["Catch axe if only in mouse range"] = "只接在鼠标范围内的斧头",
["Farm/Harass"] = "发育/骚扰",
["Use maximum 2 Axes"] = "使用最多2个斧头",
["Draw mouse range"] = "显示鼠标范围",
["Lag Free circle"] = "不影响延迟的线圈",
["Mouse Range"] = "鼠标范围",
["Evadeee Integration(If loaded)"] = "Evadeee结合(如果加载)",
["Don't catch if axe in turret"] = "不要接在塔下的斧头",
["Auto-Interrupt"] = "自动打断",
["Info"] = "信息",
["Anti-Gapclosers"] = "反突进",
["Baseult settings"] = "基地大招设置",
["Health Generation prediction"] = "生命值回复预判",
["Disable R"] = "禁用R",
["Sensetive Delay(.3 def)"] = "灵敏度延迟",
["Catch Axes(Z)"] = "接斧头(Z)",
["Use W to reach far Axes"] = "使用W接比较远的斧头",
["Draw Debug"] = "显示调试",
["Enable Permabox(reload)"] = "启用状态显示(需要重新加载)",
["Left Click target lock"] = "左键单击目标锁定",
["Orbwalker"] = "走砍",
-----------------DD2-----------------
["Riven - Broken Wings"] = "锐雯 - Broken Wings",
["Broken Wings [Main]"] = "Broken Wings [主要设置]",
["Main [Spells]"] = "主要设置 [技能]",
["Use [Q - Broken Wings]"] = "使用 [Q - 折翼之舞]",
["Use [W - Ki Burst]"] = "使用 [W - 震魂怒吼]",
["Use Youmus Ghostblade"] = "使用幽梦之灵",
["Main [Initiator]"] = "主要设置 [连招起手]",
["After E -> W"] = "E之后W",
["Force AA"] = "强制平A",
["Let Broken Wings decide"] = "由脚本决定",
["Main [Gapclose]"] = "主要设置 [突进]",
["Gapclose [Q - Broken Wings]"] = "突进 [Q - 折翼之舞]",
["In Combo"] = "在连招中",
["In Combo + Target is left-clicked"] = "在连招中且目标被左键单击锁定",
["Gapclose [E - Valor]"] = "突进 [E - 勇往直前]",
["Main [Force R]"] = "主要设置 [强制大招]",
["Cast R1 after next Animation"] = "在下个动作之后使用一段R",
["Cast R2"] = "使用二段R",
["Force R2 -> Q3"] = "强制在二段R之后使用三段Q",
["Force R On/Off"] = "强制R 开/关",
["Broken Wings [Utility]"] = "Broken Wings [功能设置]",
["Utility [Killsteal]"] = "功能设置 [抢人头]",
["Use [R2 - Windslash]"] = "使用 [R2 - 疾风斩]",
["Utility [Defensive]"] = "功能设置 [防御]",
["Auto W"] = "自动W",
["Broken Wings [Flee]"] = "Broken Wings [逃跑]",
["Use [E - Valor]"] = "使用 [E - 勇往直前]",
["Broken Wings [LastHit]"] = "Broken Wings [尾刀]",
["Draw Minion Health Bar Lines"] = "在小兵血条显示指示线",
["Last Hit Adjustment"] = "尾刀调整",
["Earlier"] = "提早",
["Later"] = "推迟",
["Last Hit Adjustment (Value)"] = "尾刀调整(数值)",
["Broken Wings [JungleClear]"] = "Broken Wings [清野]",
["Left click + Combo Key"] = "左键 + 连招按键",
["Broken Wings [Harrass]"] = "Broken Wings [骚扰]",
["Harrass Key"] = "骚扰按键",
["BW E Settings"] = "Broken Wings [E技能设置]",
["BW Visuals"] = "Broken Wings [显示设置]",
["Draw Range AA"] = "显示平A范围",
["Draw Range Q"] = "显示Q范围",
["Draw Range W"] = "显示W范围",
["Draw Range E"] = "显示E范围",
["Draw Range R2"] = "显示二段R范围",
["Draw left-clicked Target"] = "显示左键单击的目标",
["Awareness Q"] = "Q技能冷却显示",
["Awareness R"] = "R技能冷却显示",
["Awareness left-clicked Target"] = "左键单击目标意识显示",
["BW Advanced"] = "Broken Wings [高级设置]",
["Q-AA Logic"] = "QA逻辑",
["Low Ping - Stable"] = "低延迟 - 稳定模式",
["High Ping - Predicted"] = "高延迟 - 动作预判模式",
["Cancel Animation"] = "取消动作",
["Dance"] = "跳舞",
["Laugh"] = "大笑",
["Silent"] = "无声",
["Extra WindUpTime AA"] = "额外平A后摇时间",
["Extra WindUpTime Q-AA"] = "额外QA后摇时间",
["Core Processing"] = "核心处理",
["Section 1"] = "部分1",
["Section 2"] = "部分2",
["Cancel manual Broken Wings(Q)"] = "取消手动Q的后摇",
["Stop Move over MousePos"] = " ",
["BW Combo Key"] = "Broken Wings [连招按键]",
["BW Version"] = "Broken Wings [版本号]",
["No Targeted Spells Found"] = "没有找到指向性技能",
-------------------Pew走砍----------------
["Pewalk"] = "Pew走砍",
["Keys"] = "按键",
["-Skills-"] = "- 技能 -",
["SKILLS: Lane Clear"] = "技能:清线",
["-Orbwalking-"] = " - 走砍 -",
["Carry (SBTW)"] = "连招",
["Mixed"] = "骚扰",
["Key"] = "按键",
["Toggle"] = "开关",
["Draw Attack Range"] = "显示平A范围",
["Target Selection"] = "目标选择",
["Prioritize Selected Target"] = "锁定的目标优先",
["Draw Current Target"] = "显示当前的目标",
["Low FPS"] = "低fps线圈",
["-Priorities-"] = "- 优先级 -",
["Skill Farming"] = "技能发育",
["Reset: Broken Wings"] = "预设:Broken Wings",
["Only under turret"] = "只在塔下",
["Double Edged Sword"] = "双刃剑",
["Opressor"] = "恃强凌弱",
["Bounty Hunter"] = "赏金猎人",
["Savagery"] = "野蛮",
["[Humanizer] Movement Interval"] = "[拟人化] 移动间隔",
["Stop Movement"] = "停止移动",
["Left Mouse Button Down"] = "左键按下时",
["Mouse Over Hero"] = "英雄在鼠标下时",
["Last Hit Adjustment (ms)"] = "尾刀调整(ms)",
["Support Mode"] = "辅助模式",
--------------------bigfat ez----------------------
["Big Fat Ezreal"] = "Big Fat伊泽瑞尔",
["[Mode]"] = "[模式]",
["Settings Mode:"] = "设置模式",
["Recommended"] = "推荐设置",
["Expert"] = "专家设置",
["If you want to change back to Recommended"] = "如果你想恢复推荐设置",
["change it and press double f9"] = "改变模式后请按2下F9",
["Ignore SxOrbwalk"] = "忽略走砍",
["dont force loading big fat walk"] = "不强制读取Big Fat走砍",
["Current Prediction: Big Fat Vanga ver.: (1.3)"] = "目前预判：Big Fat 版本1.3",
["Toggle: Q"] = "开关Q",
["Toggle: W"] = "开关W",
["Bitch plx: WE 2 Mouse"] = "WE二连到鼠标位置",
["Big Fat Ezreal v. 0.25"] = "Big Fat伊泽瑞尔 V0.25",
["obviously by Big Fat Team"] = "Big Fat团队出品",
["[Draws]"] = "[图形显示]",
["Based on Range Dmg Info"] = "根据距离伤害信息",
["Draw Target Info"] = "显示目标信息",
["[HitChance]"] = "[命中几率]",
["[Kill Steal]"] = "[抢人头]",
["Chance: "] = "几率",
["R Chance: "] = "R几率",
["[Custom Settings]"] = "[自定义设置]",
["Q: Enable Vanga Dashes"] = "Q：开启突进",
["W: Enable Vanga Dashes"] = "W：开启突进 ",
["[KS Options]"] = "[抢人头选项]",
["Enable KS"] = "开启抢人头",
["KS with Q"] = "使用Q抢人头",
["KS with R"] = "使用R抢人头",
["max R Range: "] = "最大R距离",
["min R Range: "] = "最小R距离",
["Q: Use mana till :"] = "Q：魔法值限制",
["W: Use mana till :"] = "W：魔法值限制",
["Use Whitelist"] = "使用白名单",
["Whitelist Distance"] = "白名单距离",
["exception if White List Out Of Range"] = " 如果白名单超出距离除外",
["exception if do more dmg to other target"] = "如果能对其他目标造成更多伤害除外",
["enable this filter"] = "使用这个过滤器",
["[Key Binds]"] = "[按键绑定]",
["automaticly take binds from Orbwalk"] = "自动使用走砍设置按键",
-------------------------bigfat走砍------------------------
["Big Fat Orbwalker"] = "Big Fat走砍",
["Draw Prediction and Dmg"] = "显示预判和伤害",
["Use harass in LaneClear"] = "在清线中使用骚扰",
["Draw Range"] = "显示线圈",
["Support mode"] = "辅助模式",
["Extra WindUp Time"] = "额外后摇时间",
["Twin Shadows 1"] = "双生暗影1",
["Twin Shadows 2"] = "双生暗影2",
["Frost Queen's Claim"] = "冰霜女王的指令",
["Youmuu's Ghostblade"] = "幽梦之灵",
["Odyn's Veil"] = "女妖面纱",
["Muramana 2"] = "魔宗2",
["Randuin's Omen"] = "兰顿之兆",
["Muramana 1"] = "魔宗1",
["KeyBinds"] = "按键",
["Big Fat Orbwalker v. 0.51"] = "Big Fat走砍 v. 0.51",
["by Big Fat Team"] = "Big Fat团队出品",
-------------------------pew女警---------------------------
["PewCaitlyn"] = "PEW女警",
["Piltover Peacemaker"] = "和平使者(Q)",
["Use in Carry Mode"] = "连招模式使用",
["Harass in Mixed Mode"] = "骚扰模式使用",
["Harass in Clear Mode"] = "清线模式使用",
["Peacemaker Control Method"] = "和平使者使用模式",
["Calculated"] = "计算",
["Manual Control Key"] = "手动控制键",
["Cast HitChance [3==Highest]"]	=	 "能命中3个目标时使用（3个是最多）",
["Maximum Minion Collision"] = "最大化小兵碰撞",
["Use for Last Hits"] = "尾刀时使用",
["** Only when AA is on CD"] = "** 只在普攻冷却时使用",
["Always Save Mana for E"] = "总是为E保留魔力",
["Draw Peacemaker Range"] = "显示和平使者距离",
["Yordle Snap Trap"] = "约德尔诱捕器(W)",
["Cast on Target Path"] = "在目标路径上使用",
["Trap Channel Spells"] = "引导型法术放置陷阱",
["Trap Crowd Control"] = "群控中放置",
["Trap Revives (GA / Chronoshift)"] = "放置在即将复活的敌人身边（守护天使/时光大招）",
["Trap Teleports"] = "放置在传送点",
["Trap on Lose Vision (Grass)"] = "放置在没有视野的地方（草丛）",
["Draw Active Trap Timers"] = "显示陷阱时间",
["90 Caliber Net"] = "90口径网绳(E)",
["Net To Mouse"] = "向鼠标位置发射",
["Block Failed Wall Jumps"] = "阻止失败的越墙",
["Do Not Block if Will Jump This Far"] = "如果跳的很远不阻止",
["Ace in the Hole"] = "让子弹飞(R)",
["Draw Can Kill Alert"] = "显示可以大招击杀提示",
["Draw Line to Killable Character"] = "用连线方式显示你和目标",
["Draw Health Remaining Indicator"] = "显示剩余生命值指示",
["Kill Key"] = "击杀键",
["Use Automatically"] = "自动使用",
["-Other-"] = "-其他-",
["E - Q Combo"] = "E-Q二连",
["Movement Interval"] = "移动间隔",
--------------------bigfat金克斯---------------------
["Jinx, Bombs and Bullets"] = "枪炮金克斯",
["Recall Kill Settings"] = "回城击杀设置",
["Use On"] = "开启",
["On - Recall Spot Only"] = "开启-只击杀你视野能发现的回城",
["Additional Damage Buffer %"] = "额外伤害溢出%",
["Show recall messages"] = "显示回城信息",
["Draw recall locations"] = "显示回城地点",
["Use W combo if  mana is above"] = "如果魔法值在X以上使用W连招",
["Use R combo finisher"] = "使用R连招终结",
["Ward bush when they hide"] = "敌人进草插眼",
["Use QSS/Mercurial if hard CCed"] = "如果硬控很多使用水银弯刀或水银饰带",
["Use W harass if  mana is above"] = "如果魔法值在X以上使用W骚扰",
["Lane Clear Key Switch to"] = "清线转换成",
["Rocket"] = "火箭模式",
["Mini Gun"] = "机枪模式",
["Q Switch Method:"] = "Q模式转化:",
["Switch weapon for:"] = "以下情况转换武器模式:",
["Range & DPS"] = "距离和输出",
["KS With W"] = "W抢人头",
["Min W range"] = "W最小距离",
["Use Trap on CCed"] = "对被控制的敌人使用陷阱",
["Use Trap on Thresh/Blitz cast"] = "锤石和机器人施法时使用陷阱",
["Auto R max range"] = "自动最大距离R",
["Auto R frequency"] = "自动R的频率",
["Force Ult Mode"] = "强制使用大招",
["Draw Alternate AA Range"] = "显示AA范围",
["Draw Auto (R) Max Range"] = "显示自动R的最大距离",
["Draw R predicted spot"] = "显示预计的R地点",
["Full Combo Key (SBTW)"] = "全套大招",
["Force Ult"] = "强制使用大招",
["Force Trap"] = "强制使用陷阱",
-------------------------------bigfat飞机-----------------------
["Big Fat Corki"] = "Big Fat飞机",
["Big Fat Corki v. 0.51"] = "Big Fat飞机 V0.51",
["Big One R - between minion and target:"] = "在小兵和目标之间R",
["max distance :"] = "最大距离",
["R: Enable Vanga Dashes"] = "R：启用",
["R: Use mana till :"] = "R：在魔力值X时使用",
["E max Cast Distance"] = "最远E的距离",
["E: Use mana till :"] = "E：在魔力值X时使用",
["Extra Settings"] = "其他设置",
["Force Exhaust"] = "强制虚弱",
["Heal Settings"] = "治疗设置",
["--- Teammates to Heal ---"] = "---对队友使用治疗---",
["Shield'n'Heal"] = "护盾和治疗",
["Item Manager"] = "物品管理",
["Mikael's Crucible"] = "米凯尔的坩埚",
["Cast it on Bard"] = "对巴德使用",
["CC + Health"] = "控制+治疗",
["CC"] = "控制",
["Health"] = "治疗",
["Heal: Min % to cast it"] = "治疗：小于%血量使用",
["Humanizer: CC/Slow Delay (ms)"] = "拟人化延迟:控制/减速（毫秒）",
["CC: Usual debuffs"] = "控制：减益状态",
["CC: Slow debuff"] = "控制：减速状态",
["CC: Special cases"] = "控制：特殊情况",
["Face of the Mountain"] = "山岳之容",
["--> Use Face of the Mountain"] = "使用山岳之容",
["Use Locket of the Iron Solari in combat"] = "使用钢铁烈阳之匣",
["Use Zhonyas"] = "使用中娅",
["Use Frost Queen's Claim"] = "使用冰霜女皇的命令",
["Auto Brush Wards"] = "草丛自动插眼",
["Ward Brush when lose enemy vision"] = "当敌人进入草丛时插眼",
["Key 1"] = "按键1",
["Key 2"] = "按键2",
["Key 3"] = "按键3",
["Key 4"] = "按键4",
["Key 5"] = "按键5",
["Key 6"] = "按键6",
["Key 7"] = "按键7",
--------------------------funhouse---------------------------------------
["Bard Fun House"] = "烧伤辅助合集 - 巴德",
["Magical Journey"] = "神奇旅程",
["AFK Chimes"] = "AFK提示",
["Force Q Cast for slow"] = "强制使用Q减速",
["Force R with prediction"] = "强制使用有预判的R",
["--- Q Settings ---"] = "--- Q设置 ---",
["Extended Q Calculations"] = "延伸的Q计算",
["Cast Q to slow without Stun"] = "使用Q减速但不晕",
["--- W Settings ---"] = "--- W设置 ---",
["Use W for self heal"] = "使用W给自己治疗",
["Maximum % Health to use (W)"] = "当血量少于%时使用W",
["Use W for allies in combat"] = "战斗中对友军使用W",
["W ally only if Bard is safe"] = "只在自己安全的时候对友军使用W",
["--- E Settings ---"] = "--- E设置 ---",
["Cast Q during escapes"] = "逃跑时使用Q",
["Use W during escapes"] = "逃跑时使用W",
["--- R Settings (BETA) ---"] = "--- R设置 ---",
["R Range Percent"] = "R距离百分比",
["Minimum % Mana to use (Q)"] = "法力高于X%时使用Q",
["Minimum % Mana to use (E)"] = "法力高于X%时使用E",
["Minimum % Mana to use (R)"] = "法力高于X%时使用R",
["--- Harass Settings ---"] = "骚扰设置",
["Use Mana Manager"] = "使用法力管理",
["Auto Chimes"] = "自动提示",
["Collect in enemy jungle"] = "在敌人野区使用",
["Behind ally + no enemies only"] = "友军后方并且周围没有敌人",
["Safety distance vs enemy"] = "对敌安全距离",
["Cast Q Stun on encounter"] = "遭遇敌人使用Q晕",
["Cast W on encounter"] = "遭遇敌人使用W",
["Cast W for boost on full mana"] = "使用W加速(如果满蓝)",
["Cast E for shortcut"] = "使用E走捷径",
["Smart R on enemies when in escape"] = " 追击敌人智能使用R",
["Smart R on allies in danger"] = "当友军有危险时使用R",
["Ward enemy discover location"] = "发现敌人的位置插眼",
["Anti Dash & Gapclose"] = "防突进",
["--- Anti Dash & Capclose  Settings ---"] = "--- 防突进设置 ---",
["Use Q for Dash & Gapclose"] = "使用Q防突进",
["Draw Q Extended"] = "显示Q的延伸",
["Draw R target"] = "显示R的目标",
["Debug Mode"] = "调试模式",
["Q2 Hit Chance"] = "Q2命中率",
["Blitzcrank"] = "机器人",
["Cast it on Janna"] = "对风女",
["Shield Manager"] = "护盾管理",
["Shield Whitelist"] = "护盾白名单",
["--- Janna ---"] = "--- 风女 ---",
["Shield options"] = "护盾选项",
["Ignore"] = "忽略",
["Shield AA & Spells"] = "护盾平A和法术",
["Shield Auto Attacks"] = "护盾自动攻击",
["Shield Spells"] = "护盾法术",
["Shield if below % health "] = "血量低于%使用护盾",
["--- Blitzcrank ---"] = "--- 机器人 ---",
["Blitzcrank - Auto Attack"] = "自动攻击",
["Blitzcrank - Q: RocketGrab"] = "机器人Q",
["Blitzcrank - E: PowerFistAttack"] = "机器人E",
["Blitzcrank - R: StaticField"] = "机器人R",
["Humanizer: Shield Delay (ms)"] = "拟人化：护盾延迟（毫秒）",
["Min X% Mana"] = "法力高于%使用",
["Janna Fun House"] = "烧伤辅助合集 - 风女",
["Enable Shield (Toggle)"] = "启用护盾开关",
["--- Combat Settings ---"] = "战斗设置",
["Only use Q to interrupt"] = "只用Q打断",
["Settings inside the Shield'n'Heal menu"] = "设置使用护盾和治疗菜单的设置",
["Use Q as anti enemy gap closers"] = "用Q防突进",
["Use Q as spell interruptor"] = "用Q打断",
["Use W for ks"] = "W抢人头",
["Draw Insec Position"] = "显示突进位置",
["Insec color"] = "突进颜色",
["Kayle"] = "凯尔",
["Fizz Fun House 2.0"] = "烧伤合集2.0 - 菲兹",
["Jungle Steal mode"] = "抢野怪模式",
["Instant R"] = "立刻R",
["--- Combo Logic - Q ---"] = "--- 连招逻辑设置 Q ---",
["Use Min dist to Q (default off)"] = "使用Q的最小距离（默认关闭）",
["Min distance to use Q"] = "使用Q的最小距离",
["Q minion Gapclose potential kill"] = "如果可以击杀Q小兵突进",
["--- Combo Logic - E ---"] = "--- 连招逻辑设置 E ---",
["Force E on combo (Smart)"] = "--- 连招强制使用E（智能）---",
["Mid-air Flash finish if out-range"] = "如果超出攻击范围空中闪",
["--- Combo Logic - R ---"] = "--- 连招逻辑设置 R ---",
["Enable Long Range R (prediction)"] = "允许使用远距离R（预判位置）",
["Use R below enemy hp % "] = "敌人血量小于%使用R",
["R for potential kill (dmg calc)"] = "尝试使用R击杀（伤害预估）",
["--- Misc ---"] = "--- 杂项 ---",
["Mana check for succesful Q+W"] = "Q+W前判断法力值是否足够",
["Harass and escape with Q/E :"] = "骚扰和逃跑时使用Q/E",
["Use Urchin Strike (Q)"] = "使用Q",
["E Options"] = "E选项",
["Animation Cancel all jumps"] = "取消跳跃动画",
["Dodge spells from the list "] = "躲避列出的法术",
["Use Playful on enemy gap closers"] = "对敌人突进使用淘气打击",
["Jump/Back with Steal mode even if no smitable"] = "跳过去/跳回来抢怪即使没有惩戒",
["Auto E on burst damage (40% HP of dmg)"] = "自动E爆发伤害（对敌造成40%生命伤害）",
["Jump List"] = "跳的名单",
["--- Jump At Spell Arrival ---"] = "--- 被法术攻击时跳 ---",
["Kayle - Q: JudicatorReckoning"] = "凯尔Q",
["Kayle - W: JudicatorDevineBlessing"] = "凯尔W",
["Kayle - E: JudicatorRighteousFury"] = "凯尔E",
["Kayle - R: JudicatorIntervention"] = "凯尔R",
["R Targetting"] = "R目标",
["Cast R on Kayle"] = "对凯尔使用R",
["Use Seastone Trident (W)"] = "使用海神三叉戟W",
["Use Playful Trickster (E)"] = "使用淘气打击E",
["Misc Draws"] = "杂项显示",
["Draw Jump Spots"] = "显示跳跃的落点",
["Jump color"] = "跳跃颜色",
["Draw Double Jump Spots"] = "显示二段跳落点",
["Double Jump color"] = "二段跳颜色",
["Cast Ignite on Kayle"] = "对凯尔使用点燃",
["Written by: burn & ikita - Fun House Team"] = "由Burn & Ikita 荣誉出品",
["Urgot Fun House 2.0"] = "烧伤合集 2.0 - 厄加特",
["Urgot Fun House"] = "烧伤厄加特",
["Auto Q1: if poisoned enemy"] = "如果敌人中毒自动Q1",
["Auto Q2: if enemy not poisoned"] = "如果敌人没中毒自动Q2",
["Auto Q3: for ks enemy"] = "如果能击杀自动Q3",
["Disable: Auto Q2-Q3 under enemy tower"] = "敌人塔下禁用自动Q2-Q3",
["--- Q Enemy Track System on FOW ---"] = "--- 追踪Q迷雾中的敌人 ---",
["Auto Q poisoned enemy in FOW"] = "自动Q迷雾中中毒的敌人",
["Enable a hotkey for stop Q in FOW"] = "使用一个热键停止自动Q迷雾中的敌人",
["Hotkey for stop Auto Q in FOW"] = "热键停止自动Q迷雾中的敌人",
["Use W on AA range for slow enemy"] = "普攻范围内使用W减速敌人",
["If in AA range, delay combo for the slow"] = "如果普攻范围内，延迟连招优先减速",
["Use W with Q locked for slow enemy"] = "对Q减速的敌人使用W",
["Use W if enemy tower focus Urgot"] = "如果塔的目标是厄加特使用W",
["Use W vs enemy gaps closers"] = "敌人突进使用W",
["Use W vs targeted spells"] = "对目标的法术使用W",
["--- Enable W on this spells: ---"] = "--- 对于以下法术使用W ---",
["--- R champions Interrupter ---"] = "--- R敌方英雄打断 ---",
["Difference between enemy/team allies"] = "敌我人数",
["Use R as spell interrupter"] = "使用R作为打断",
["No cast R as interrupter if:"] = "如果以下情况不使用R",
["Enemy allies > Ours, with 1 of difference"] = "敌人>我军，人数差1",
["--- R champions Tower focus ---"] = "对塔的目标使用R",
["Enemy allies surrounding our target"] = "敌人和我军在目标附近",
["Auto R: Make our tower focus enemy"] = "自动R：使我军塔专注攻击",
["No cast R as tower focus if:"] = "如果以下情况不对塔的目标使用R",
["Enemy is surrounded for 1"] = "有1个敌人在周围",
["Our Health is lower than %"] = "我们的血量低于%",
["Health %"] = "血量%",
["Use Acid Hunter (Q)"] = "使用Q",
["Q usage mode: "] = "Q的使用模式",
["Spam mode"] = "饱和模式",
["For kill minion"] = "为击杀小兵",
["Use Noxian Corrosive Charge (E) [jungle]"] = "对野怪使用E",
["Only if AA on cooldown"] = "只在普攻冷却时",
["Min Mana % for E harass"] = "使用E骚扰的最低法力%",
["--- Enemy Track System ---"] = "--- 追踪敌人 ---",
["Draw Enemy prediction on FOW"] = "显示战争迷雾中敌人的预计位置",
["Show if tracker is temp. disabled"] = "如果追踪被禁用",
["Draw Poison time on enemy"] = "显示敌人中毒时间",
["Poison time color"] = "中毒时间颜色",
["Auto use Muramana active vs enemies"] = "对敌时自动使用魔切",
["Auto disable Muramana if no enemies"] = "没有敌人时自动禁用魔切",
["Cast it on Blitzcrank"] = "对机器人使用",
["Blitzcrank Fun House"] = "烧伤辅助合集 - 机器人",
["Use R+Q Combo"] = "使用R+Q连招",
["Use Q Killsteal"] = "使用Q抢人头",
["Use R Killsteal"] = "使用R抢人头",
["Set Q Range 750-925"] = "设置Q的距离 750-925",
["Use Q on"] = "使用Q的名单",
["Use Q on Lux"] = "对拉克丝使用Q",
["--- R Settings ---"] = "--- R设置 ---",
["Use R to interrupt spells"] = "使用R打断法术",
["X enemy targets to use R"] = "敌人数量为X时，使用R",
["Use E for Dash & Gapclose"] = "使用E突进",
["Draw Q Hook line"] = "显示Q的弹道",
----------------Jhin----------------
["Machine Series: Jhin"] = "Machine合集：烬",
["Only if first minion kill"] = "仅当第一个小兵能被击杀",
["Use W: "] = "使用W：",
["Only on stunnable"] = "只用于禁锢目标",
["Use W on Shaco invis"] = "对隐身的小丑使用W",
["Min W range if not reloading"] = "W的最小范围",
["Use Trap on channeled spells"] = "对正在引导法术的敌人使用陷阱",
["ON including own"] = "开-包括自己的控制技能",
["Cast Ult on FoW enemies"] = "对战争迷雾里的敌人使用R",
["Additional Humanizer (ms)"] = "额外拟人化延迟(毫秒)",
["Use E in Wave Clear"] = "在清线中使用E",
["Show (R) Humanizer Timer"] = "显示R技能拟人化延迟计时器",
["Draw AA and (Q) Range"] = "显示平A和Q的范围",
["Draw (R) Range Minimap"] = "在小地图上显示R的范围",
["Percent"] = "百分比",
["Raw Damage"] = "显示伤害",
["Assisted (R) Key (Hold)"] = "辅助性R按键(按住不放)",
["High Noon"] = "如日中天 - 烬",
----------------MMA-----------------
["Marksman's Mighty Assistant"] = "MMA走砍",
["Orbwalk [On-Hold]"] = "走砍 [按住]",
["Last Hit [On-Hold]"] = "尾刀 [按住]",
["Lane Clear [On-Hold]"] = "清线 [按住]",
["Dual Carry [On-Hold]"] = "双重走砍 [按住]",
["Orbwalk [Toggle]"] = "走砍 [开关]",
["Last Hit [Toggle]"] = "尾刀 [开关]",
["Lane Clear [Toggle]"] = "清线 [开关]",
["Dual Carry [Toggle]"] = "双重走砍 [开关]",
["Last-Hit Settings"] = "尾刀设置",
["Lane Freeze"] = "控线猥琐补刀",
["Last-Hit Assistance"] = "尾刀助手",
["Dual Carry Setup"] = "双重走砍设置",
["Orbwalk + Last-Hit"] = "走砍 + 尾刀",
["Orbwalk + Lane-Clear"] = "走砍 + 清线",
["Dual Carry mode first priority"] = "双重走砍模式优先",
["Heroes"] = "英雄",
["Minions"] = "小兵",
["Enable HP Correction under turrets"] = "在防御塔下时启用生命值修正",
["Give priority to big jungle mobs"] = "设定大型野怪优先",
["Movement Settings"] = "移动设置",
["Distance over DPS"] = "输出间隔中移动的距离",
["Hold-Position on mouse stop"] = "在鼠标下时停止移动",
["Orbwalk Boxes/Plants etc."] = "走砍时攻击小丑盒子/婕拉的植物",
["Hold-Position near walls"] = "在墙边时停止移动",
["Movement spam rate (in ms)"] = "移动指令发送频率(毫秒)",
["Mouse detection sensitivity"] = "鼠标动作检测敏感度",
["Active"] = "生效",
["Usage on Enemy %HP: "] = "当敌人生命值高于%时使用",
["Usage on myHero %HP: "] = "当自己生命值低于%时使用",
["Tiamat & Ravenous Hydra"] = "提亚马特 & 贪欲九头蛇",
["Target Mode: All[ON]/Champions[OFF]"] = "目标选择模式: 所有目标[开]/只对英雄[关]",
["Use when enemy count more than"] = "当敌人数量多于x时使用",
["Use items in LaneClear mode"] = "在清线中使用物品",
["Use items in Dual-Carry mode"] = "在双重走砍模式中使用物品",
["Using Infinity Edge?"] = "使用无尽之刃?",
["Display Settings"] = "显示设置",
["Auto-Attack Range"] = "平A范围",
["Auto-Attack Range Awareness"] = "AA范围意识",
["Current Target Circle"] = "当前目标线圈",
["Low-FPS circles"] = "低FPS线圈",
["Auto-Attack Range Circle Color"] = "平A线圈颜色",
["Display a circle on queued minions"] = "在等待被尾刀的小兵上画圈",
["How fast will my target die?"] = "目标死亡的速度有多快?",
["Last-Hit Circles"] = "尾刀线圈",
["Enable PermaShow for keys (Reload)"] = "启用按键状态显示(需要重新加载)",
["Debugging Settings"] = "调试设置",
["Enable debug prints"] = "启用调试信息显示",
["Debug last-hit spell damage (Reload)"] = "调试尾刀技能伤害(需要重新加载)",
["Enable heros auto attacks"] = "启用英雄的普通攻击",
["Debug time between auto-attacks"] = "调试普通攻击直接的间隔时间",
["Debug auto-attack damage"] = "调试普通攻击的伤害",
["Debug auto-attack cancels"] = "调试取消普通攻击",
["Debug minion HP correction"] = "调试小兵血量修正",
["Enable class initialization prints"] = "启用类初始化信息显示",
["Disable ally minion attack prediction"] = "关闭友方小兵攻击预判",
["Debug animation strings"] = "调试动作字符串",
["Target Selector Mode"] = "目标选择器模式",
["Lowest HP"] = "血量最低",
["Near Mouse"] = "鼠标附近",
["Most DPS"] = "输出最高",
["Lowest HP + Most DPS"] = "血量最低+输出最高",
["Target Selector Priorities"] = "目标选择器优先级",
["Attack selected targets only"] = "只攻击选定的目标",
["Target people on camera view"] = "只选择在屏幕内的目标",
["1st Priority"] = "一级优先",
["2nd Priority"] = "二级优先",
["3rd Priority"] = "三级优先",
["4th Priority"] = "四级优先",
["5th Priority"] = "五级优先",
["Turret Manager"] = "防御塔管理器",
["Enemy Turrets"] = "敌方防御塔",
["Show Range"] = "显示防御塔范围",
["Opacity"] = "透明度",
["Show Aggro Colors"] = "显示仇恨锁定颜色",
["Distance Based Opacity"] = "取决于距离的透明度",
["Hide Distance"] = "隐藏距离",
["Ally Turrets"] = "友方防御塔",
["Enable Dive-Awareness "] = "启用越塔意识",
["Mastery Settings"] = "天赋设置",
["Buff Settings"] = "Buff设置",
["Enable auto-potions"] = "启用自动药水",
["Potion Settings"] = "自动药水设置",
["Hunter Potion %"] = "猎人药水 %",
["Corrupting Potion %"] = "腐败药水 %",
["Biscuit %"] = "饼干 %",
["ItemCrystalFlask %"] = "魔瓶 %",
["Health Potion %"] = "血瓶 %",
["Mana Potion %"] = "蓝瓶 %",
["Seraph's Embrace %"] = "炽天使之拥 %",
["Use potions when ignited"] = "被点燃时使用药水",
["Disable Crowd-Control Detection"] = "关闭控制技能检测",
["No spells supported for this champion"] = "",
["Auto Bushes"] = "自动探草",
["Ward bushes on toggle"] = "自动进草插眼开关",
["Maximum bush check time (in sec)"] = "进草最大时间检测(秒)",
["Switch mode for"] = "切换模式为",
["None"] = "无",
["On-Hold"] = "按住",
["Toggle"] = "开关",
["Add key for"] = "添加按键为",
["Orbwalking"] = "走砍",
["Last-Hitting"] = "尾刀",
["Lane-Clearing"] = "清线",
["Dual-Carrying"] = "双重走砍",
["Lasthitting"] = "尾刀",
["Lasthitting2"] = "尾刀2",
["Lasthitting3"] = "尾刀3",
["Laneclearing"] = "清线",
["Laneclearing2"] = "清线2",
["Laneclearing3"] = "清线3",
["Dualcarrying"] = "双重走砍",
["Dualcarrying2"] = "双重走砍2",
["Dualcarrying3"] = "双重走砍3",
["Version: "] = "版本号:",
-------------------HTTF锐雯----------------
["HTTF Riven"] = "HTTF 锐雯",
["Burst Combo Toggle"] = "爆发连招开关",
["Use Flash in Burst Combo"] = "在爆发连招中使用闪现",
["Ulti"] = "大招",
["Activate R Mode"] = "触发R模式",
["Kill Steal"] = "抢人头",
["Combo - The number of QAA"] = "连招 - QA次数",
["Cast R Mode"] = "使用R模式",
["Save First Q before AA (T)"] = "普通攻击之前保留第一段Q",
["Use EQ (T)"] = "使用EQ",
["Save E before W (F)"] = "在W技能之前保留E技能",
["Use Item"] = "使用物品",
["Save First Q before AA (F)"] = "普通攻击之前保留第一段Q",
["Activate R"] = "触发R",
["Cast R"] = "使用R",
["Clear"] = "清线/清野",
["Save First Q even if Last Hit (T)"] = "在尾刀中的普通攻击之前保留第一段Q",
["Use EQ (F)"] = "使用EQ",
["Use W Min Count"] = "使用W的最小敌人数量",
["Wall Jump"] = "翻墙",
["Use Wall Jump"] = "使用翻墙",
["Misc"] = "杂项",
["Use Animation Cancel"] = "使用动作取消后摇",
["Cancel Type"] = "取消后摇类型",
["Joke"] = "开玩笑",
["Provoke"] = "嘲讽",
["Auto Cancel Q for manual QAA (F)"] = "自动取消手动QA的Q后摇",
["Cast E even if enemy is so closed (F)"] = "即使已经很贴近目标依然使用E",
["Combo - Attack selected target (T)"] = "常规连招 - 攻击选定的目标",
["Combo - Select range (600)"] = "常规连招 - 选择目标范围",
["Burst - Attack selected Target (T)"] = "爆发连招 - 攻击选定的目标",
["Burst - Select range (1200)"] = "爆发连招 - 选择目标范围",
["Q Cancel time offset"] = "取消Q后摇时间预设",
["Buffer between AA dmg and Spell"] = "平A与技能之间的缓冲时间",
["Buffer between AA dmg and move"] = "平A与移动指令之间的缓冲时间",
["Moving interval"] = "移动间隔",
["Stop moving over mouse"] = "在鼠标附近时停止移动",
["Draw"] = "显示",
["Draw Lag free circles"] = "使用不影响延迟的线圈",
["Draw Hitchance"] = "显示命中几率",
["Draw Combo Damage"] = "显示连招伤害",
["Wall Jump Position"] = "翻墙地点",
["Renekton"] = "雷克顿",
["HTTF Smite (HTTF Riven)"] = "HTTF 惩戒 (HTTF 锐雯)",
["Jungle Steal Settings"] = "抢野怪设置",
["Use Smite"] = "使用惩戒",
["Use Smite Toggle"] = "使用惩戒开关",
["Always Steal Dragon"] = "总是开启抢龙",
["KillSteal Settings"] = "抢人头设置",
["Use Stalker's Blade"] = "使用追猎者的刀锋",
["Draw Smite range"] = "显示惩戒范围",
["Draw Target"] = "显示目标",
["Draw Attack range"] = "显示平A范围",
["Early casting"] = "提早上点燃",
["Save Ignite if Killable with Spells"] = "如果目标能被技能击杀则保留点燃",
---------------------SIUsage---------------
["Summoner & Item Usage"] = "SIUsage活化剂",
["Health Potions"] = "血瓶",
["Use While Pressed"] = "当按键时使用",
["Use Always"] = "总是使用",
["Use if no enemies"] = "没有敌人时使用",
["If My Health % is <"] = "如果自己的生命值低于%",
["Remove CC"] = "解除控制",
["Remove Exhaust"] = "解除虚弱",
["Removal delay (ms)"] = "解控延迟(毫秒)",
["Normal Items/Smite"] = "普通物品/惩戒",
["Use Zhonyas/Seraphs Before Death"] = "死亡之前使用中娅/炽天使",
["OFF"] = "关闭",
["Summoner Exhaust"] = "虚弱",
["Exhaust Key"] = "虚弱按键",
---------------Feez Jayce-------------
["Jayce"] = "Feez杰斯",
["Script version:"] = "版本号:",
["Combo active"] = "连招",
["Spells"] = "技能",
["Q1 (Hammer)"] = "Q - 锤形态",
["W1 (Hammer)"] = "W - 锤形态",
["E1 (Hammer)"] = "E - 锤形态",
["R1 (Hammer)"] = "R - 锤形态",
["Q2 (Cannon)"] = "Q - 炮形态",
["W2 (Cannon)"] = "W - 炮形态",
["E2 (Cannon)"] = "E - 炮形态",
["R2 (Cannon)"] = "R - 炮形态",
["Harass active"] = "骚扰",
["Use Cannon Q"] = "使用炮形态Q",
["Use Cannon E->Q"] = "使用炮形态EQ",
["-> Switch stance to E->Q"] = "-> 切换形态来使用EQ",
["Use Cannon W"] = "使用炮形态W",
["Only when mana above %"] = "仅当蓝量高于%",
["Use Hammer Q"] = "使用锤形态Q",
["Use Hammer W"] = "使用锤形态W",
["Use Hammer E"] = "使用锤形态E",
["Orbwalk"] = "走砍",
["Orbwalker"] = "走砍",
["Interrupter"] = "技能打断",
["Switch stance to interrupt spells"] = "切换形态来打断技能",
["Wall Hop"] = "穿墙",
["Wall hop"] = "穿墙",
["Hit minions with Hammer E"] = "对小兵使用锤形态E",
["Reveal minions with Cannon Q"] = "使用炮形态Q获得小兵或野怪的视野",
["Champions"] = "英雄",
["Use flash"] = "使用闪现",
["Jungle Steal"] = "抢野怪",
["Switch stance to steal"] = "切换形态来抢野怪",
["Snipe"] = "狙杀",
["Snipe mode"] = "狙杀模式",
["Automatic mechanics"] = "",
["Cannon E->Q snipe to mouse"] = "对鼠标附近的敌人使用炮形态EQ狙杀",
[" -> Enabled"] = "-> 启用",
["Stack tear/manamune"] = "叠女神之泪/魔宗",
["Flee mode"] = "逃跑模式",
["PermaShow Menu"] = "状态显示菜单",
["Combo range"] = "连招范围",
["Thunderlord's Decree indicator circle"] = "雷霆领主的法令指示器线圈",
["Ranges"] = "范围",
["Hammer Q"] = "锤形态Q",
["Hammer E"] = "锤形态E",
["Cannon Q"] = "炮形态Q",
["Cannon E->Q Range"] = "炮形态EQ范围",
["Move Left/Right"] = "左右移动",
["Move Up/Down"] = "上下移动",
["Reset"] = "恢复默认设置",
["Jayce - Prediction Manager"] = "Feez杰斯 - 预判管理器",
["Load all predictions on start"] = "开始时加载所有预判",
["Prediction:"] = "预判",
["Hit Chance:"] = "命中率",
["1: Low"] = "1: 低",
["2: High"] = "2: 高",
["3: Target too slow or close"] = "3: 目标过慢或者过近",
["4: Target immobile"] = "4: 目标太远",
["5: Target dashing or blinking"] = "5: 目标正在使用位移技能或闪现",
["Accelerated Q"] = "加速的Q",
["No interruptable spells"] = "没有可打断的技能",
["Dashes and Jumps"] = "位移和跳跃",
["Interrupt Ezreal"] = "打断伊泽瑞尔",
["Priorities"] = "优先级",
["Ezreal"] = "伊泽瑞尔",
["Loading..."] = "加载中...",
["Muramana"] = "魔切",
["Twin Shadows"] = "双生暗影",
["Tiamat or Hydra"] = "提亚马特/九头蛇",
["BORK"] = "破败王者之刃",
["Baron Nashor"] = "纳什男爵",
["Snipe Ezreal"] = "狙杀伊泽瑞尔",
["Insec Ezreal"] = "Insec伊泽瑞尔",
--------------------Feez Lissandra-------------
["Lissandra - Blood Diamond"] = "Feez丽桑卓",
["Melt: Combo"] = "最大输出连招(对目标释放所有技能)",
["Safe-Melt: Combo"] = "开团+自保连招(E开团+R自己)",
["Flee (no 2nd E while combo)"] = "逃跑(连招时不使用二段E)",
["Smart KS"] = "智能抢人头",
["Melt"] = "最大输出连招",
["Use First E"] = "使用一段E",
["Use Second E"] = "使用二段E",
["Only ult when combo killable"] = "只在能击杀目标时使用R",
["Safe-Melt"] = "开团自保连招",
["least # of enemies to initiate"] = "开团至少能开到x个敌人",
["Use E (only first)"] = "先手使用E",
["Mana % must be > than:"] = "蓝量必须大于x%",
["Minimum E minions:"] = "至少能E中的小兵数",
["Minimum Q minions:"] = "至少能Q中的小兵数",
["2nd Keybind Key"] = " ",
["2nd Keybind Enabled"] = " ",
["least # of enemies to auto W"] = "能命中x名敌人时自动W",
["Jump Spots Color:"] = "E位移终点颜色",
["Q Range"] = "Q技能范围",
["W range"] = "W技能范围",
["E range"] = "E技能范围",
["R range"] = "R技能范围",
["W Range"] = "W技能范围",
["E Range"] = "E技能范围",
["R Range"] = "R技能范围",
["Color:"] = "颜色:",
["Last second E"] = "E最远距离位移",
["Lissandra - Prediction Manager"] = "丽桑卓 - 预判管理",
["Udyr"] = "乌迪尔",
---------------------Feez安妮---------------
["Annie the UnBEARable"] = "Feez安妮",
["Use Flash when Killable"] = "当目标可被击杀时使用闪现",
["Block AAs out of range [when spells ready]"] = "当技能可用时不平A",
["Combo Order"] = "连招顺序",
["Wait for Q hit"] = "等待Q技能命中",
["^^Will combo when q hits"] = "^^将会在Q命中的时候进行连招",
["Only for Q-W-R or Q-R-W"] = "只对Q-W-R和Q-R-W生效",
["Ult"] = "大招",
["Use Ult"] = "使用大招",
["Allow KS with ult"] = "允许使用大招抢人头",
["Ult on"] = "使用大招的目标",
["Use Stun"] = "使用自动眩晕",
["Auto Stun enemies focused by tower"] = "自动眩晕被防御塔锁定的敌人",
["Use W [Auto Stun]"] = "使用W(自动眩晕)",
["Use Ult [Auto Stun]"] = "使用R(自动眩晕)",
["Minimum enemies to auto stun"] = "自动眩晕的最小敌人数",
["Auto Farm"] = "自动发育",
["Auto Farm with Q"] = "自动使用Q发育",
["Auto reactivate farm mode"] = "自动开启发育模式",
["Toggle continuous farm"] = "发育模式开启状态显示",
["Stack to:"] = "自动将被动叠到",
["1 Stack"] = "1层",
["2 Stacks"] = "2层",
["3 Stacks"] = "3层",
["4 Stacks [Stun]"] = "4层[眩晕]",
["Auto Shield"] = "自动护盾",
["Turn off E stack for better results"] = "关闭E技能攒被动",
["Draw combo range"] = "显示连招范围",
["Draw flash + combo range"] = "显示闪现连招范围",
["Draw circle under TS target"] = "在选定的目标下画圈",
["Draw killable text on target"] = "在目标身上显示可击杀提示",
["Draw timer of tibbers on yourself"] = "在自己身上显示提伯斯的时间",
["Draw Tibbers target text on tibbers"] = "在提伯斯身上显示熊锁定的目标",
["Draw stun sprite"] = "显示眩晕图标",
["Text draw fix"] = "修复文字显示",
["Auto control & orbwalk tibbers"] = "自动操纵提伯斯",
["Tibbers follow toggle"] = "提伯斯跟随状态显示",
["Passive"] = "被动",
["Stack passive:"] = "自动攒被动:",
["In Spawn"] = "在泉水",
["Add Stack [*]"] = "增加被动层数[*]",
["Subtract Stack [-]"] = "减少被动层数[-]",
["Annie - Prediction Manager"] = "安妮 - 预判管理器",
-----------------Feez狐狸------------
["Ahri - Sexy Mistress"] = "Feez阿狸",
["Smart auto ignite"] = "智能自动点燃",
["Q Catch"] = "使用Q追赶",
["Use R for Q return"] = "使用R调整Q返回位置",
["Catch mode"] = "追击模式",
["Flexible"] = "灵活的",
["Tight"] = "紧追不放的",
["Use when health % >="] = "当生命值大于等于x%时使用",
["Use to initiate"] = "用来开团",
["Use default logic"] = "使用默认逻辑",
["Randomize ult distance"] = "随机的大招位移距离",
["Harass KeyDown"] = "骚扰按键",
["^Only when mana above %"] = "^仅当蓝量大于%",
["Flee active"] = "逃跑模式开启",
["Last Hit [Q]"] = "尾刀 [Q]",
["Minimum to last hit"] = "能尾刀的最少小兵数",
["Minimum laneclear with passive"] = "触发被动清线的最少小兵数",
["^Only when health below %"] = "^仅当生命值小于%",
["Spell hit spots"] = "技能命中点",
["Passive sprite"] = "被动图标显示",
["Q orb"] = "Q技能弹道",
["Ahri - Prediction Manager"] = "阿狸 - 预判管理",
["Prioritize selected target"] = "优先锁定选定的目标",
["Ult mode"] = "大招模式",
["Move to mouse"]= "移动至鼠标位置",
["NebelwolfisMoonWalker"] = "Nebelwolfi走砍",
["Harass Mode"] = "骚扰模式",
["Mouse over Hero to stop move"] = "英雄在鼠标下时停止移动",
["Melee Settings"] = "近战设置",
["Walk/Stick to target"] = "紧跟目标",
["Sticky radius to target"] = "紧跟目标半径",
------------------Forbidden Ahri Kassadin Twisted Fate Ryze----------------
["Challenger Ahri Reborn by Da Vinci"] = "挑战者中单合集 - 阿狸",
["Ahri - Target Selector Settings"] = "[阿狸] - 目标选择器设置",
["Ahri - General Settings"] = "[阿狸] - 常规设置",
["Catch the Q with Movement"] = "移动来调整Q的弹道",
["Ahri - Combo Settings"] = "[阿狸] - 连招设置",
["Catch the Q with R"] = "使用R调整Q的弹道",
["Give Priority to Catch the Q with R"] = "优先使用R调整Q的弹道",
["Use Ignite If Killable "] = "当可击杀时使用点燃",
["Ahri - Harass Settings"] = "[阿狸] - 骚扰设置",
["Ahri - LaneClear Settings"] = "[阿狸] - 清线设置",
["Use W If Minions >= "] = "当小兵大于等于x时使用W",
["Ahri - JungleClear Settings"] = "[阿狸] - 清野设置",
["Ahri - LastHit Settings"] = "[阿狸] - 尾刀设置",
["Never"] = "从不",
["Ahri - KillSteal Settings"] = "[阿狸] - 抢人头设置",
["Ahri - Auto Settings"] = "[阿狸] - 自动设置",
["Use E To Interrupt"] = "使用E技能打断",
["Ahri - Draw Settings"] = "[阿狸] - 显示设置",
["Path to Catch the Q"] = "调整Q弹道的路线",
["Line for Q Orb"] = "Q技能弹道指示线",
["Ahri - Keys Settings"] = "[阿狸] - 按键设置",
["Start with E (Toggle)"] = "连招E起手(开关)",

["Forbidden Kassadin by Da Vinci"] = "挑战者中单合集 - 卡萨丁",
["Kassadin - Target Selector Settings"] = "[卡萨丁] - 目标选择器设置",
["Kassadin - General Settings"] = "[卡萨丁] - 常规设置",
["Kassadin - Combo Settings"] = "[卡萨丁] - 连招设置",
["Kassadin - Harass Settings"] = "[卡萨丁] - 骚扰设置",
["Kassadin - LaneClear Settings"] = "[卡萨丁] - 清线设置",
["Kassadin - JungleClear Settings"] = "[卡萨丁] - 清野设置",
["Kassadin - LastHit Settings"] = "[卡萨丁] - 尾刀设置",
["Kassadin - KillSteal Settings"] = "[卡萨丁] - 抢人头设置",
["Kassadin - Drawing Settings"] = "[卡萨丁] - 显示设置",
["Kassadin - Keys Settings"] = "[卡萨丁] - 按键设置",

["Diana The Dark Eclipse by Da Vinci"] = "挑战者中单合集 - 戴安娜",
["Diana - Target Selector Settings"] = "[戴安娜] - 目标选择器设置",
["Range for Combo"] = "连招使用范围",
["Diana - General Settings"] = "[戴安娜] - 常规设置",
["Diana - Combo Settings"] = "[戴安娜] - 连招设置",
["Use R On Enemies Marked"] = "对标记的敌人使用R",
["Use QR on Object To GapClose"] = "对目标使用QR以突进敌人",
["Diana - Harass Settings"] = "[戴安娜] - 骚扰设置",
["Diana - LaneClear Settings"] = "[戴安娜] - 清线设置",
["Use E If Hit >="] = "当能命中大于等于x个敌人时使用E",
["Diana - JungleClear Settings"] = "[戴安娜] - 清野设置",
["Diana - LastHit Settings"] = "[戴安娜] - 尾刀设置",
["Diana - KillSteal Settings"] = "[戴安娜] - 抢人头设置",
["Diana - Auto Settings"] = "[戴安娜] - 自动设置",
["Diana - Draw Settings"] = "[戴安娜] - 显示设置",
["Diana - Keys Settings"] = "[戴安娜] - 按键设置",

["Forbidden TwistedFate by Da Vinci"] = "挑战者中单合集 - 崔斯特",
["TwistedFate - Target Selector Settings"] = "[戴安娜] - 目标选择器设置",
["Range for Harass"] = "骚扰使用范围",
["TwistedFate - General Settings"] = "[戴安娜] - 常规设置",
["Select gold card after R"] = "R技能之后自动切黄牌",
["TwistedFate - Combo Settings"] = "[戴安娜] - 连招设置",
["Use Q If Hit >="] = "当能击中大于等于x个单位时使用Q",
["Use Gold Card"] = "使用黄牌",
["Use Blue Card If Mana Percent <= "] = "蓝量小于等于x%时切蓝牌",
["TwistedFate - Harass Settings"] = "[戴安娜] - 骚扰设置",
["Priorize Farm over Harass"] = "发育优先于骚扰",
["TwistedFate - LaneClear Settings"] = "[戴安娜] - 清线设置",
["Use Q If Mana Percent >= "] = "当蓝量大于等于%时使用Q",
["Use Red Card If Hit >= "] = "当能击中大于等于x个单位时使用红牌",
["Red Card If Mana Percent >= "] = "如果蓝量高于%使用红牌",
["Use Blue"] = "使用蓝牌",
["TwistedFate - JungleClear Settings"] = "[戴安娜] - 清野设置",
["Use Red"] = "使用红牌",
["Use Red Card If Mana Percent >= "] = "如果蓝量高于%使用红牌",
["TwistedFate - LastHit Settings"] = "[戴安娜] - 尾刀设置",
["TwistedFate - KillSteal Settings"] = "[戴安娜] - 抢人头设置",
["TwistedFate - Auto Settings"] = "[戴安娜] - 自动设置",
["Use Gold Card To Interrupt Channelings"] = "使用黄牌打断引导型技能",
["Use Gold Card To Interrupt GapClosers"] = "使用黄牌打断突进者",
["TwistedFate - Drawing Settings"] = "[戴安娜] - 显示设置",
["TwistedFate - Keys Settings"] = "[戴安娜] - 按键设置",
["Start with Card (Toggle)"] = "切牌起手(开关)",
["Select Blue Card (Default: F1)"] = "切蓝牌(默认F1)",
["Select Red Card (Default: F2)"] = "切红牌(默认F2)",
["Select Gold Card (Default: F3)"] = "切黄牌(默认F3)",
["Extra WindUpTime"] = "额外后摇时间",
["Farm Delay"] = "发育延迟时间",

["Wizard by Da Vinci"] = "挑战者上单合集 - 瑞兹",
["QP Settings"] = "强化Q技能设置",
["Ryze - Target Selector Settings"] = "[瑞兹] - 目标选择器设置",
["Ryze - General Settings"] = "[瑞兹] - 常规设置",
["Ryze - Combo Settings"] = "[瑞兹] - 连招设置",
["Use Q no Collision"] = "使用Q时不检查碰撞",
["Ryze - Harass Settings"] = "[瑞兹] - 骚扰设置",
["Ryze - LaneClear Settings"] = "[瑞兹] - 清线设置",
["Ryze - JungleClear Settings"] = "[瑞兹] - 清野设置",
["Ryze - KillSteal Settings"] = "[瑞兹] - 抢人头设置",
["Ryze - Auto Settings"] = "[瑞兹] - 自动设置",
["Use W To Interrupt"] = "使用W来打断",
["Ryze - Draw Settings"] = "[瑞兹] - 显示设置",
["Ryze - Keys Settings"] = "[瑞兹] - 按键设置",
["Delay for LastHit (in ms)"] = "尾刀延迟(毫秒)",
--------------SAC-----------------------
["Stream Mode"] = "屏蔽模式",
["Green"] = "绿色",
["When In Range"] = "当在范围内时",
["Q (Tumble)"] = "Q(闪避突袭)",
["Last Hit Only"] = "只在尾刀使用",
["R (Final Hour)"] = "R(终极时刻)",
[" Only orbwalk who I attack "] = "只输出我正在攻击的目标",
[" Only orbwalk my selected target "] = "只输出我选定的目标",
[" Choose best target in scan range (set below)"] = "在一定范围内选择最佳目标(在下面设定)",
[" Orbwalk who I attack if possible, otherwise selected target"] = "在可能时只输出我正在攻击的目标,否则攻击选定的目标",
[" Orbwalk who I attack if possible, otherwise best in scan range"] = "在可能时只输出我正在攻击的目标,否则攻击范围内最佳目标",
[" Always "] = "总是",
[" AutoCarry mode "] = "自动连招输出模式",
[" Any mode"] = "任何模式",
["  Last Hit Earlier  "] = "提早尾刀",
["  Last Hit Later  "] = "推迟尾刀",
["  Cancel Earlier  "] = "提早取消",
["  Cancel Later  "] = "推迟取消",
["Server Delay: 100ms"] = "服务器延迟: 100毫秒",
["Sida's Auto Carry: Vayne"] = "SAC:薇恩",
["Allowed Condemn Targets"] = "允许眩晕的目标",
["Toggle Mode (Requires Reload)"] = "开关模式(需要重新加载)",
["Auto-Condemn"] = "自动E",
["Auto-Condemn Gap Closers"] = "自动推开突进者",
["Max Condemn Distance"] = "最大推开距离",
["Only condemn Reborn target"] = "只推开SAC选定的目标",
["Condemn Adjustment:"] = "E技能调整:",
["Disable attacks during ult stealth"] = "在大招隐身的情况下不平A",
["Wall Detection Method"] = "墙体检测方式",
["IsWall"] = "IsWall函数",
["Guess (for when IsWall breaks in BoL)"] = "猜测(当IsWall无法使用时)",
["              Sida's Auto Carry: Reborn"] = "              Sida走砍",
["No mode active"] = "无模式",
["Skill Farm"] = "技能发育",
["TARGET LOCK"] = "目标锁定",
["Auto-Condemn"] = "自动E",
["      Active"] = "    激活",
["      "] = "    冻结",
["Move to Mouse"] = "移动至鼠标位置",
["SAC Detected"] = "检测到SAC",
["Combat keys are connected to your SAC:R keys"] = "连招按键和SAC的连招按键绑定",
}
function translationchk(text)
	if not type(text) == "string" then return text end
    local text2
    if(tranTable[text] ~= nil) then 
    text2 = tranTable[text] 
    else
    text2 = text
    end
    return text2
end
function dumpchk(text)
	if not dumpuntranslated then return false end
	if text == "" then return false end
	if (tranTable[text] == nil) then
		if(dumpdata[text] == nil) then
		dumpdata[text] = " "
		WriteFile(('["'.. text ..'"]'.. ' = '.. '" ",').."\n", SCRIPT_PATH .. "results.txt","a")
		else
		return false
		end
		return true
	else
		return false
	end
end
function OnLoad()
	AAAUpdate()
	PrintLocal("Loaded successfully! by: leoxp,Have fun!")
end
function PrintLocal(text, isError)
	PrintChat("<font color=\"#ff0000\">BoL Config Translater:</font> <font color=\"#"..(isError and "F78183" or "FFFFFF").."\">"..text.."</font>")
end
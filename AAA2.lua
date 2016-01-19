local version = "0.0120"
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
	local ServerVersionDATA = GetWebResult(serveradress , scriptadress.."/AAA2.version")
	if ServerVersionDATA then
		local ServerVersion = tonumber(ServerVersionDATA)
		if ServerVersion then
			if ServerVersion > tonumber(version) then
				PrintLocal("New version found:"..ServerVersion)
				PrintLocal("Updating, don't press F9")
				DownloadFile("http://"..serveradress..scriptadress.."/AAA2.lua",SCRIPT_PATH.."AAA2.lua", function ()
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

local tranTable = {
["Menu"] = "菜單",
["press key for Menu"] = "設定新的菜單按鈕...",
["Evadeee"] = "躲避",
["Enemy Spells"] = "敵人技能",
["Evading Spells"] = "躲避技能",
["Advanced Settings"] = "高級設置",
["Traps"] = "陷阱",
["Buffs"] = "增益",
["Humanizer"] = "擬人化",
["Combat/Chase Mode"] = "連招/追擊模式",
["Controls"] = "控制",
["Visual Settings"] = "視覺設置",
["Performance Settings"] = "性能設置",
["Q - Decisive Strike"] = "Q技能",
["W - Courage"] = "W技能",
["Summoner Spell: Flash"] = "召喚師技能：閃現",
["Item: Youmuu's Ghostblade"] = "幽夢之靈",
["Item: Locket of the Iron Solari"] = "鋼鐵烈陽之匣",
["Item: Zhonya / Wooglet"] = "中婭沙漏",
["Item: Shurelya / Talisman"] = "舒瑞亞的狂想曲/護符",
["Dodge/Cross Settings"] = "躲避或穿過技能設置",
["Evading Settings"] = "躲避設置",
["Collision Settings"] = "碰撞設置",
["Script Interaction (API)"] = "腳本互動（API）",
["Reset Settings"] = "重置設置",
["Nidalee and Teemo Traps"] = "豹女和提莫的陷阱",
["Caitlyn and Jinx Traps"] = "女警和金克斯的陷阱",
["Banshee's Veil"] = "女妖面紗",
["Delays"] = "延遲",
["Movement"] = "移動",
["Anchors"] = "定位",
["Evading"] = "躲避",
["Dashes and blinks"] = "瞬移和突進",
["Special Actions"] = "特殊動作",
["Override - Anchor Settings"] = "覆蓋定位設置",
["Override - Humanizer"] = "覆蓋擬人化",
["League of Legends Version"] = "英雄聯盟版本",
["Danger Level: "] = "危險等級",
["Danger level info:"] = "危險等級信息",
["    0 - Off"] = "0 - 關閉",
["    1 - Use vs Normal Skillshots"] = "1 - 遇到一般技能攻擊使用",
["2..4 - Use vs More Dangerous / CC"] = "2..4 - 遇到較危險技能及團控使用",
["    5 - Use vs Very Dangerous"] = "5 - 遇到非常危險技能時使用",
["Use after-move delay in calcs"] = "在計算的延遲後移動",
["Extra hit box radius: "] = "額外的彈道直徑",
["Evading points max distance"] = "改變潛在安全躲避地點的最大距離",
["Evade only spells closer than:"] = "只在法術距離接近值的時候躲避",
["Global skillshots as exception"] = "躲避全球大招時忽略其他設置",
["Attempt to DODGE linear spells"] = "嘗試在直線彈道法術內的時候躲避",
["Attempt to CROSS linear spells"] = "嘗試在直線彈道法術外時安全穿過",
["Attempt to DODGE rectangular spells"] = "嘗試在矩形彈道法術內的時候躲避",
["Attempt to CROSS rectangular spells"] = "嘗試在矩形彈道法術外時安全穿過",
["Attempt to DODGE circular spells"] = "嘗試在圓形彈道法術內的時候躲避",
["Attempt to CROSS circular spells"] = "嘗試在圓形彈道法術外時安全穿過",
["Attempt to DODGE triangular spells"] = "嘗試在三角形彈道法術內的時候躲避",
["Attempt to CROSS triangular spells"] = "嘗試在三角形彈道法術外時安全穿過",
["Attempt to DODGE conic spells"] = "嘗試在錐形彈道法術內的時候躲避",
["Attempt to CROSS conic spells"] = "嘗試在錐形彈道法術外時安全穿過",
["Attempt to dodge arc spells"] = "嘗試在錐形彈道法術內的時候躲避",
["Collision for minions"] = "小兵的碰撞",
["Collision for heroes"] = "英雄的碰撞",
["Here you can allow other scripts"] = "這裡你可以使用其他腳本",
["to enable/disable and control Evadeee."] = "啟用/禁用和控制EVADEEE",
["Allow enabling/disabling evading"] = "允許啟用/禁用躲避",
["Allow enabling/disabling Bot Mode"] = "允許啟用/禁用機器人模式",
["WARNING:"] = "警告",
["By switching this ON/OFF - Evadeee"] = "轉換開和關",
["will reset all your settings:"] = "重置所有設定",
["Restore default settings"] = "恢復默認設置",
["Enabled"] = "啟用",
["Ignore with dangerLevel >="] = "忽略危險等級",
["    1 - Use vs everything"] = "1 - 任何時候都使用",
["2..4 - Use only vs More Dangerous / CC"] = "2..4 - 僅在較危險技能及團控使用",
["    5 - Use only vs Very Dangerous"] = "5 - 僅在遇到非常危險技能時使用",
["Delay before evading (ms)"] = "躲避前延遲（毫秒）",
["Ignore evading delay if you move"] = "如果你在移動忽略躲避前延遲",
["Server Tick Buffer (ms)"] = "服務器緩存計時（毫秒）",
["Pathfinding:"] = "尋路",
["Move extra distance after evade"] = "躲避後移動額外的距離",
["Randomize that extra distance"] = "隨機生成躲避後移額外的距離值",
["Juke when entering danger area"] = "假裝進入危險區域",
["Move this distance during jukes"] = "假動作距敵人法術的距離",
["Allow changing path while evading"] = "允許在躲避時改變路線",
["Delay between each path change"] = "改變路線時延遲的時間",
["\"Smooth\" Diagonal Evading"] = "平滑斜線躲避",
["Max Range Limit:"] = "最遠距離限制",
["Anchor Type:"] = "定位方法",
["Safe Evade (Ignore Anchor):"] = "安全躲避（忽略定位）",
["Safe evade from enemy team"] = "安全躲避敵人",
["Do that with X enemies nearby: "] = "在附近有X名敵人時",
["How far enemies should be: "] = "對敵人的警戒距離",
["Safe evade during Panic Mode"] = "在使用強制閃現模式時安全躲避",
["Explanation (Safe Evade):"] = "解釋（安全躲避）",
["This setting will force evade in the"] = "這個設置會朝着遠離",
["direction away from enemy team."] = "敵人移動方向強制躲避",
["This will ignore your main anchor"] = "這會忽略你的主定位",
["only when there are enemies nearby."] = "只在附近有敵人時",
["Attempt to dodge spells from FoW"] = "嘗試躲避從沒有視野的地方攻擊你的法術",
["Dodge if your HP <= X%: "] = "在你的血量小於X%時躲避",
["Dodge <= X normal spells..."] =	 "在小於等於X個普通法術攻擊你時躲避",
["... in <= X seconds"] =	 "在小於等於X秒內",
["Disable evading by idling X sec:"] = "在你掛機X秒後自動禁用躲避",
["Better dodging near walls"] = "牆附近更好的躲避路線",
["Better dodging near turrets"] = "敵人防禦塔附近更好的躲避路線",
["Handling danger blinks and dashes:"] = "瞬移和突進時躲避危險",
["Angle of the modified cast area"] = "躲避危險的角度",
["Blink/flash over missile"] = "瞬移或突進到小兵身邊躲避攻擊",
["Delay between dashes/blinks (ms):"] = "瞬移或猛衝的延遲(ms)",
["Dash/Blink/Flash Mode:"] = "瞬移或突進或閃現的模式",
["Note:"] = "注意",
["While activated, this mode overrides some of"] = "當你激活這個功能時可能會覆蓋",
["the settings, which you can modify here."] = "一些你其他的在這裡修改的設置",
["Usually this is used together with SBTW."] = "一般情況下和自動走砍開關",
["To change the hotkey go to \"Controls\"."] = "在控制設置中設置熱鍵",
["Dodge \"Only Dangerous\" spells"] = "僅躲避危險技能",
["Evade towards anchor only"] = "躲避時只向前定位",
["Ignore circular spells"] = "忽略圓形技能",
["Use dashes more often"] = "更多的使用瞬移",
["To change controls just click here   \\/"] = "點這裡來改變控制設置",
["Evading        | Hold"] = "按住躲避",
["Evading        | Toggle"] = "按下躲避開關啟用直到在次按下停止",
["Combat/Chase Mode | Hold 1"] = "戰鬥和追擊模式按鍵1",
["Combat/Chase Mode | Hold 2"] = "戰鬥和追擊模式按鍵2",
["Combat/Chase Mode | Toggle"] = "戰鬥和追擊模式開關",
["Panic Mode     | Refresh"] = "驚恐模式刷新",
["Panic Mode Duration (seconds)"] = "驚恐模式時間（秒）",
["Remove spells with doubleclick"] = "雙擊移除技能繪圖",
["Quick Menu:"] = "快捷菜單",
["Open Quick Menu with LMB and:"] = "用鼠標左鍵和:開啟快速菜單",
["Replace Panic Mode"] = "替換驚恐模式",
["Explanation (Quick Menu):"] = "說明（快捷菜單）",
["If you choose 1 key for Quick Menu"] = "如果你選擇按鍵1作為快捷鍵",
["then make sure it doesn't overlap"] = "菜單快捷鍵，請確認不會和",
["with League's Quick Ping menu!"] = "遊戲顯示PING的快捷鍵重疊",
["Draw Skillshots"] = "技能繪圖表示",
["Spell area line width"] = "技能區域線的粗細",
["Spell area color"] = "技能區域顏色",
["Draw Dangerous Area"] = "危險區域繪圖表示",
["Danger area line width"] = "危險區域線的粗細",
["Danger area color"] = "危險區域顏色",
["Display Evading Direction"] = "顯示躲避方向",
["Show \"Doubleclick to remove!\""] = "顯示雙擊移除（圖）",
["Display Evadeee status"] = "顯示EVADEEE狀態",
["Status display Y offset"] = "狀態顯示縱軸並列",
["Status display text size"] = "狀態顯示字體大小",
["Print Evadeee status"] = "顯示EVADEEE狀態",
["Show Priority Menu"] = "顯示優先菜單",
["Priority Menu X offset"] = "優先菜單橫軸並列",
["Preset"] = "預設",
["Change this on your own risk:"] = "如果改變此項風險自負",
["Update Frequency [Times per sec]"] = "刷新數據頻率次/秒",
-----------------SAC-----------------------
["Script Version"] = "腳本版本",
["Generate Support Report"] = "生成援助報告",
["Clear Chat When Enabled"] = "當開啟時清空對話框",
["Show Click Marker (Broken)"] = "功能已壞",
["Click Marker Colour"] = "點擊預測顏色",
["Minimum Time Between Clicks"] = "點擊最小間隔",
["Maximum Time Between Clicks"] = "點擊最大間隔",
["translation button"] = "翻譯鍵",
["Harass mode"] = "騷擾模式",
["Cast Mode"] = "施法模式",
["Collision buffer"] = "碰撞體積",
["Normal minions"] = "一般小兵",
["Jungle minions"] = "野怪",
["Others"] = "其他",
["Check if minions are about to die"] = "如果小兵快死了點擊",
["Check collision at the unit pos"] = "檢查物體間位置碰撞",
["Check collision at the cast pos"] = "檢查施法位置碰撞",
["Check collision at the predicted pos"] = "檢查預計法術位置碰撞",
["Enable debug"] = "開啟排除故障模式",
["Show collision"] = "顯示碰撞",
["Version"] = "版本",
["No enemy heroes were found!"] = "未發現敵方英雄",
["Target Selector Mode:"] = "目標選擇模式",
["*LessCastPriority Recommended"] = "推薦：最少使用技能+優先級",
["Hold Left Click Action"] = "按住鼠標左鍵的動作",
["Focus Selected Target"] = "聚焦選中的目標",
["Attack Selected Buildings"] = "攻擊選中的建築",
["Disable Toggle Mode On Recall"] = "在回城時禁用開關模式",
["Disable Toggle Mode On Right Click"] = "鼠標右鍵點擊禁用開關模式",
["Mouse Over Hero To Stop Move"] = "鼠標懸停在英雄上方時停止移動",
["      Against Champions"] = "與你戰鬥的地方英雄",
["Use In Auto Carry"] = "在自動連招輸出模式使用",
["Use In Mixed Mode"] = "在混合模式使用",
["Use In Lane Clear"] = "在清線模式使用",
["Killsteal"] = "搶人頭",
["Auto Carry minimum % mana"] = "如果魔法少於%則不開啟自動連招輸出模式",
["Mixed Mode minimum % mana"] = "如果魔法少於%則不開啟混合模式",
["Lane Clear minimum % mana"] = "如果魔法少於%則不開啟清線模式",
["      Skill Farm"] = "技能刷兵",
["Lane Clear Farm"] = "清線刷兵",
["Jungle Clear"] = "刷野",
["TowerFarm"] = "塔下刷兵?",
["Skill Farm Min Mana"] = "使用技能刷兵魔法不低於",
["(when enabled)"] = "當啟用時",
["Stick To Target"] = "緊盯目標",
["   Stick To Target will mirror "] = "緊盯目標輸出",
["   enemy waypoints so you stick"] = "跟緊敵人行進路線",
["   to him like glue!"] = "就像蓋倫貼臉打",
["Outer Turret Farm"] = "外塔刷兵",
["Inner Turret Farm"] = "內塔刷兵",
["Inhib Turret Farm"] = "水晶刷兵",
["Nexus Turret Farm"] = "門牙刷兵",
["Lane Clear Method"] = "清線方式",
["Double-Edged Sword"] = "雙刃劍天賦",
["Savagery"] = "野蠻天賦",
["Toggle mode (requires reload)"] = "開關模式（需要2XF9）",
["Movement Enabled"] = "允許移動",
["Attacks Enabled"] = "允許攻擊",
["Anti-farm/harass (attack back)"] = "騷擾敵人補刀（反擊）",
["Attack Enemies"] = "攻擊敵人",
["Prioritise Last Hit Over Harass"] = "補刀優先於騷擾",
["Attack Wards"] = "攻擊眼",
["           Main Hotkeys"] = "主要快捷鍵",
["Auto Carry"] = "自動連招攻擊模式",
["Last Hit"] = "補刀模式",
["Mixed Mode"] = "混合模式",
["Lane Clear"] = "清線",
["           Other Hotkeys"] = "其他快捷鍵",
["Target Lock"] = "目標鎖定",
["Enable/Disable Skill Farm"] = "開啟或關閉技能刷兵",
["Lane Freeze (Default F1)"] = "F1下防守補刀",
["Support Mode (Default F6)"] = "輔助模式",
["Toggle Streaming Mode with F7"] = "F7開關滑動模式",
["Use Blade of the Ruined King"] = "使用破敗",
["Use Bilgewater Cutlass"] = "使用比爾吉沃特彎刀",
["Use Hextech Gunblade"] = "使用海克斯科技槍刃",
["Use Frost Queens Claim"] = "使用冰霜女皇的指令",
["Use Talisman of Ascension"] = "使用飛升護符",
["Use Ravenous Hydra"] = "使用貪婪九頭蛇",
["Use Tiamat"] = "使用提亞馬特",
["Use Entropy"] = "使用冰霜戰錘",
["Use Youmuu's Ghostblade"] = "使用幽夢之靈",
["Use Randuins Omen"] = "使用蘭頓之兆",
["Use Muramana"] = "使用魔切",
["Save BotRK for max heal"] = "保留BotRK獲得最大治療",
["Use Muramana [Champions]"] = "對英雄使用魔切",
["Use Muramana [Minions]"] = "對小兵使用魔切",
["Use Tiamat/Hydra to last hit"] = "使用提亞馬特或者九頭蛇完成最後一擊",
["Use Muramana [Jungle]"] = "對野怪使用魔切",
["Champion Range Circle"] = "英雄範圍圓形圖",
["Colour"] = "顏色",
["Circle Around Target"] = "目標圓形圖",
["Draw Target Lock Circle"] = "顯示目標鎖定圓形圖",
["Target Lock Colour"] = "目標鎖定顏色",
["Target Lock Reminder Text"] = "目標鎖定文字提示",
["Show Pet/Clone target scan range"] = "顯示寵物/克隆目標掃描範圍",
["Use Low FPS Circles"] = "使用低FPS圓",
["Show PermaShow box"] = "顯示永久顯示框",
["Show AA reminder on script load"] = "讀取腳本時顯示AA提醒",
["Enable Pet Orbwalking:"] = "開啟寵物走砍",
["Tibbers"] = "火女提伯斯",
["Shaco's Clone"] = "小丑克隆",
["Target Style:"] = "目標方式",
["When To Orbwalk:"] = "什麼時候走砍",
["Target Scan Range"] = "目標掃描範圍",
["Push Lane In LaneClear"] = "在清線時使用推線模式",
["Delay Between Movements"] = "移動間隔延遲",
["Randomize Delay"] = "隨機延遲",
["Humanize Movement"] = "擬人化移動",
["Last Hit Adjustment:"] = "補刀調整",
["Adjustment Amount:"] = "調整量",
["Animation Cancel Adjustment:"] = "普攻動畫取消調整",
["Mouse Over Hero AA Cancel Fix:"] = "鼠標懸停在英雄上方取消普攻",
["Mouse Over Hero Stop Distance:"] = "鼠標懸停在英雄上方停止距離",
["Server Delay (don't touch): 100ms"] = "服務器延遲100毫秒",
["Disable AA Cancel Detection"] = "禁用普攻取消偵測",
["By Role:"] = "按角色",
["    Draw ADC"] = "ADC繪圖",
["    Draw AP Carry"] = "AP繪圖",
["    Draw Support"] = "輔助繪圖",
["    Draw Bruiser"] = "刺客繪圖",
["    Draw Tank"] = "坦克繪圖",
["By Champion:"] = "按英雄",
["Modify Minion Health Bars"] = "調整小兵血條",
["Maximum Health Bars To Modify"] = "最大血條調整",
["Draw Last Hit Arrows"] = "最後一擊圖形提醒",
["Always Draw Modified Health Bars"] = "一直顯示血條調整",
["Always Draw Last Hit Arrows"] = "一直顯示最後一擊圖形提醒",
["Sida's Auto Carry"] = "Sida走砍",
["Setup"] = "設置",
["Hotkeys"] = "快捷鍵",
["Configuration"] = "配置",
["Target Selector"] = "目標選擇",
["Skills"] = "技能",
["Items"] = "物品",
["Farming"] = "刷兵",
["Melee"] = "團戰",
["Drawing"] = "繪圖",
["Pets/Clones"] = "寵物/克隆",
["Streaming Mode"] = "開關滑動模式",
["Advanced / Fixes"] = "高級/調整",
["VPrediction"] = "V預判",
["Collision"] = "碰撞體積",
["Developers"] = "開發者",
["Circles"] = "圓圈",
["Enemy AA Range Circles"] = "敵人普攻範圍圈",
["Minion Drawing"] = "小兵標記",
["Other"] = "其他",
["Auto Carry Mode"] = "自動連招攻擊",
["Last Hit Mode"] = "最後一擊補刀模式",
["Lane Clear Mode"] = "清線模式",
["Auto Carry Items"] = "自動連招使用的物品",
["Mixed Mode Items"] = "混合模式使用的物品",
["Lane Clear Items"] = "清線使用的物品",
["Q (Decisive Strike)"] = "Q",
["E (Judgment)"] = "E",
["R (Demacian Justice)"] = "R",
["Masteries"] = "天賦",
["Damage Prediction Settings"] = "傷害預估設置",
["Turret Farm"] = "塔下刷兵",
["Activator"] = "活化劑",
["Activator Version : "] = "活化劑版本號",
["Debug Mode Setting"] = "調試模式設置",
["Zhonya Debug"] = "調試中亞",
["Debug Mode (shields,zhonya): "] = "調試模式(護盾,中亞)",
["Font Size Zhonya"] = "中亞字體大小",
["X Axis Draw Zhonya Debug"] = "中亞顯示X軸位置",
["Y Axis Draw Zhonya Debug"] = "中亞顯示Y軸位置",
["QSS Debug "] = "水銀飾帶調試",
["Debug Mode (qss): "] = "調試模式(水銀飾帶)",
["Font Size QSS"] = "水銀飾帶字體大小",
["X Axis Draw QSS Debug"] = "水銀飾帶顯示X軸位置",
["Y Axis Draw QSS Debug"] = "水銀飾帶顯示Y軸位置",
["Cleanse Debug"] = "凈化調試",
["Debug Mode (Cleanse): "] = "調試模式(凈化)",
["Font Size Cleanse"] = "凈化字體大小",
["X Axis Draw Cleanse Debug"] = "凈化顯示X軸位置",
["Y Axis Draw Cleanse Debug"] = "凈化顯示Y軸位置",
["Mikael Debug"] = "坩堝調試",
["Debug Mode (Mikael): "] = "調試模式(坩堝)",
["Font Size Mikael"] = "坩堝字體大小",
["X Axis Draw Mikael Debug"] = "坩堝顯示X軸位置",
["Y Axis Draw Mikael Debug"] = "坩堝顯示Y軸位置",
["Tower Damage"] = "防禦塔傷害",
["Calculate Tower Damage"] = "計算防禦塔傷害",
["Auto Spells"] = "自動使用技能",
["Auto Shield Spells"] = "自動護盾技能",
["Use Auto Shield Spells"] = "使用自動護盾技能",
["Max percent of hp"] = "最大生命值百分比",
["Shield Ally Oriana"] = "對奧利安娜使用護盾",
["Auto Pot Settings"] = "自動藥水設置",
["Use Auto Pots"] = "使用自動藥水",
["Use Health Pots"] = "自動吃血瓶",
["Use Mana Pots"] = "自動吃藍瓶",
["Use Flask"] = "自動吃魔瓶",
["Use Biscuit"] = "自動吃餅乾",
["Min Health Percent"] = "最小生命值百分比",
["Health Lost Percent"] = "損失生命值百分比",
["Min Mana Percent"] = "最小藍量百分比",
["Min Flask Health Percent"] = "魔瓶-最小生命值百分比",
["Min Flask Mana Percent"] = "魔瓶-最小藍量百分比",
["Offensive Items Settings"] = "進攻物品設置",
["Button Mode"] = "按鍵模式",
["Use Button Mode"] = "使用按鍵模式",
["Button Mode Key"] = "按鍵",
["AP Items"] = "AP物品",
["Use AP Items"] = "使用AP物品",
["Use Bilgewater Cutlass"] = "使用比爾吉沃特彎刀",
["Use Blackfire Torch"] = "使用黯炎火炬",
["Use Deathfire Grasp"] = "使用冥火之擁",
["Use Hextech Gunblade"] = "使用海克斯科技槍刃",
["Use Twin Shadows"] = "使用雙生暗影",
["Use Odyn's Veil"] = "使用奧戴恩的面殺",
["AP Item Mode: "] = "AP物品模式",
["Burst Mode"] = "爆發模式",
["Combo Mode"] = "連招模式",
["KS Mode"] = "搶人頭模式",
["AD Items"] = "AD物品",
["Use AD Items On Auto Attack"] = "在平A的時候使用AD物品",
["Use AD Items"] = "使用AD物品",
["Use Blade of the Ruined King"] = "使用破敗王者之刃",
["Use Entropy"] = "使用冰霜戰錘",
["Use Ravenous Hydra"] = "使用九頭蛇",
["Use Sword of the Divine"] = "使用神聖之劍",
["Use Tiamat"] = "使用提亞馬特",
["Use Youmuu's Ghostblade"] = "使用幽夢之靈",
["Use Muramana"] = "使用魔切",
["Min Mana for Muramana"] = "使用魔切的最小藍量",
["Minion Buff"] = "小兵增益",
["Use Banner of Command"] = "使用號令之旗",
["AD Item Mode: "] = "AD物品模式",
["Burst Mode"] = "爆發模式",
["Combo Mode"] = "連招模式",
["KS Mode"] = "搶人頭模式",
["Defensive Items Settings"] = "防禦物品設置",
["Cleanse Item Config"] = "凈化設置",
["Stuns"] = "眩暈",
["Silences"] = "沉默",
["Taunts"] = "嘲諷",
["Fears"] = "恐懼",
["Charms"] = "魅惑",
["Blinds"] = "致盲",
["Roots"] = "禁錮",
["Disarms"] = "變形",
["Suppresses"] = "壓制",
["Slows"] = "減速",
["Exhausts"] = "虛弱",
["Ignite"] = "點燃",
["Poison"] = "中毒",
["Shield Self"] = "自動護盾",
["Use Self Shield"] = "使用自動護盾",
["Use Seraph's Embrace"] = "使用熾天使之擁",
["Use Ohmwrecker"] = "使用干擾水晶",
["Min dmg percent"] = "最小傷害百分比",
["Zhonya/Wooglets Settings"] = "中亞/沃格勒特的巫師帽設置",
["Use Zhoynas"] = "使用中亞",
["Use Wooglet's Witchcap"] = "使用沃格勒特的巫師帽",
["Only Z/W Special Spells"] = "只對特定技能使用",
["Debuff Enemy"] = "對敵人使用減益效果",
["Use Debuff Enemy"] = "使用減益效果",
["Use Randuin's Omen"] = "蘭頓之兆",
["Randuins Enemies in Range"] = "在範圍內有X個敵人時使用蘭頓",
["Use Frost Queen"] = "使用冰霜女皇的指令",
["Cleanse Self"] = "凈化類物品",
["Use Self Item Cleanse"] = "使用凈化類物品",
["Use Quicksilver Sash"] = "使用水銀飾帶",
["Use Mercurial Scimitar"] = "使用水銀彎刀",
["Use Dervish Blade"] = "使用苦行僧之刃",
["Cleanse Dangerous Spells"] = "凈化危險的技能",
["Cleanse Extreme Spells"] = "凈化極端危險的技能",
["Min Spells to use"] = "最少擁有X種減益效果才使用",
["Debuff Duration Seconds"] = "減益效果持續時間",
["Shield/Boost Ally"] = "給友軍使用護盾/加速",
["Use Support Items"] = "使用輔助物品",
["Use Locket of Iron Solari"] = "鋼鐵烈陽之匣",
["Locket of Iron Solari Life Saver"] = "生命值低於X時使用鋼鐵烈陽之匣",
["Use Talisman of Ascension"] = "飛升護符",
["Use Face of the Mountain"] = "山嶽之容",
["Face of the Mountain Life Saver"] = "生命值低於X時使用山嶽之容",
["Use Guardians Horn"] = "守護者的號角",
["Life Saving Health %"] = " 生命值低於X%",
["Mikael Cleanse"] = "米凱爾的坩堝",
["Use Mikael's Crucible"] = "使用坩堝",
["Mikaels cleanse on Ally"] = "對友軍使用坩堝",
["Mikaels Life Saver"] = "生命低於X%時使用坩堝",
["Ally Saving Health %"] = "友軍生命值低於X%",
["Self Saving Health %"] = "自己生命值低於X%",
["Min Spells to use"] = "最少擁有X種減益效果才使用",
["Set Debuff Duration"] = "設置減益效果持續時間",
["Champ Shield Config"] = "英雄護盾設置",
["Champ Cleanse Config"] = "英雄凈化設置",
["Shield Ally Vayne"] = "對友軍薇恩使用護盾",
["Cleanse Ally Vayne"] = "對友軍薇恩使用凈化",
["Show In Game"] = "在遊戲中顯示",
["Show Version #"] = "顯示版本號",
["Show Auto Pots"] = "顯示自動藥水",
["Show Use Auto Pots"] = "顯示使用自動藥水",
["Show Use Health Pots"] = "顯示自動血葯",
["Show Use Mana Pots"] = "顯示自動藍葯",
["Show Use Flask"] = "顯示自動魔瓶",
["Show Offensive Items"] = "顯示攻擊型物品",
["Show Use AP Items"] = "顯示使用AP物品",
["Show AP Item Mode"] = "顯示AP物品模式",
["Show Use AD Items"] = "顯示使用AD物品",
["Show AD Item Mode"] = "顯示AD物品模式",
["Show Defensive Items"] = "顯示防禦物品",
["Show Use Self Shield Items"] = "顯示對自己使用護盾類物品",
["Show Use Debuff Enemy"] = "顯示對地方使用減益效果",
["Show Self Item Cleanse "] = "顯示對自己使用凈化",
["Show Use Support Items"] = "顯示使用輔助物品",
["Show Use Ally Cleanse Items"] = "顯示對友軍使用凈化類物品",
["Show Use Banner"] = "顯示使用號令之旗",
["Show Use Zhonas"] = "顯示使用中亞",
["Show Use Wooglets"] = "顯示使用沃格勒特的巫師帽",
["Show Use Z/W Lifeaver"] = "顯示使用中亞的觸發生命值",
["Show Z/W Dangerous"] = "顯示使用中亞的危險程度",
["DeklandAIO: Orianna"] =  "神系列合集：奧利安娜",
["DeklandAIO Version: "] =  "神系列合集版本號：",
["Auth Settings"] =  "腳本驗證設置",
["Debug Auth"] =  "調試驗證",
["Fix Auth"] =  "修復驗證",
["Target Selector Settings"] =  "目標選擇器設置",
["Left Click Overide"] =  "左鍵點擊目標優先",
["1 = Highest, 5 = Lowest, 0 = Ignore"]	= "1-最高，5-最低，0-忽略",
["Use Priority Mode"] =  "使用優先級模式",
["Set Priority Vladimir"] =  "設置吸血鬼的優先級",
["Keys Settings"] =  "鍵位設置",
["Harass"] =  "騷擾",
["Harass Toggle"] =  "騷擾開關",
["TeamFight"] =  "團戰",
["Skill Settings"] =  "技能設置",
["                    Q Skill          "] =  "                Q技能              ",
["Use Harass"] =  "使用該技能騷擾",
["Use Kill Steal"] =  "使用該技能搶人頭",
["Use Spacebar"] =  "使用空格",
["                    W Skill          "] =  "                W技能              ",
["Min No. Of Enemies In W Range"] =  "在W範圍內最小敵人數量",
["                    E Skill          "] =  "                E技能              ",
["Use E>Q Combo"] =  "使用EQ連招",
["Use E If Can Hit"] =  "如果球能擊中目標時使用E",
["Use E>W or E>R"] =  "使用EW或者ER連招",
["                    R Skill          "] =  "                R技能              ",
["R Block"] =  "禁止R自動釋放",
["Set R Range"] =  "設置R的範圍",
["Use Combo Ult - (Q+W+R Dmg)"] =  "使用終極連招（QWR的傷害）",
["Min No. Of Enemies"] =  "當至少有X名敵人時釋放",
["Min No. Of KS Enemies"] =  "當至少有X名殘血敵人時釋放",
["Ult Vladimir"] =  "對吸血鬼釋放R",
["                    Misc Settings          "] =  "            雜項設置              ",
["Harass Mana Management"] =  "騷擾藍量控制",
["Farm Settings"] =  "刷兵設置",
["                    Farm Keys          "] =  "            刷兵按鍵              ",
["Farm Press"] =  "刷兵按鍵",
["Farm Toggle"] =  "刷兵開關",
["Lane Clear Press"] =  "清線按鍵",
["Lane Clear Toggle"] =  "清線開關",
["Jungle Farm"] =  "清野",
["                    Q Farm          "] =  "         Q技能刷兵           ",
["Last Hit"] =  " ",
["Lane Clear"] =  "清線",
["Jungle"] =  "清野",
["                    W Farm          "] =  "         W技能刷兵           ",
["                    E Farm          "] =  "         E技能刷兵           ",
["                    Misc          "] =  "                    雜項          ",
["Farm Mana Management"] =  "刷兵藍量控制",
["OrbWalk Settings"] =  "走砍設置",
["            Team Fight Orbwalk Settings          "] =  "            團戰走砍設置          ",
["Move To Mouse"] =  "向鼠標位置移動",
["Auto Attacks"] =  "自動攻擊",
["               Harrass Orbwalk Settings          "] =  "            騷擾走砍設置          ",
["              Lane Farm Orbwalk Settings          "] =  "         清線刷兵走砍設置         ",
["              Jungle Farm Orbwalk Settings          "] =  "            清野走砍設置          ",
["On Dash Settings"] =  "面對突進時設置",
["Check On Dash Vladimir"] =  "檢查吸血鬼的突進",
["Items Settings"] =  "物品設置",
["AP Items"] =  "AP的物品",
["Use AP Items"] =  "使用AP物品",
["Use Bilgewater Cutlass"] =  "比爾吉沃特彎刀",
["Use Blackfire Torch"] =  "黯炎火炬",
["Use Deathfire Grasp"] =  "冥火之擁",
["Use Hextech Gunblade"] =  "海克斯科技槍刃",
["Use Twin Shadows"] =  "雙生暗影",
["AP Item Mode: "] =  "AP物品模式",
["Burst Mode"] =  "爆發模式",
["Combo Mode"] =  "連招模式",
["KS Mode"] =  "搶人頭模式",
["AD Items"] =  "AD物品",
["Use AD Items"] =  "使用AD物品",
["Use Blade of the Ruined King"] =  "使用破敗王者之刃",
["Use Entropy"] =  "冰霜戰錘",
["Use Sword of the Divine"] =  "神聖之劍",
["Use Tiamat/Ravenous Hydra"] =  "提亞馬特/九頭蛇",
["Use Youmuu's Ghostblade"] =  "幽夢之靈",
["Use Muramana"] =  "魔切",
["Min Mana for Muramana"] =  "使用魔切的最小藍量",
["AD Item Mode: "] =  "AD物品模式",
["Support Items"] =  "輔助物品",
["Use Support Items"] =  "使用輔助物品",
["Auto Wards"] =  "自動插眼",
["Use Sweeper"] =  "使用掃描",
["Ward Mode: "] =  "插眼模式",
["Only Bushes"] =  "只在草叢",
["Always"] =  "總是",
["Summoner Spells"] =  "召喚師技能",
["                    Ignite          "] =  "                    點燃          ",
["Use Ignite"] =  "使用點燃",
["Ignite Mode : "] =  "點燃模式：",
["ComboMode"] =  "連招模式",
["KSMode"] =  "搶人頭模式",
["                    Smite          "] =  "                    懲戒          ",
["             Smite Not Found         "] =  "             沒有發現懲戒         ",
["Use Smite"] = "使用懲戒",
["Smite Baron/Dragon/Vilemaw"] = "對大龍/小龍/卑鄙之喉使用懲戒",
["Smite Large Minions"] = "對大野怪使用懲戒",
["Smite Small Minions"] = "對小野怪使用懲戒",
["                  Lane          "] = "                  兵線          ",
["                  Jungle          "] = "                  打野          ",
["Smite Siege Minions"] = "對炮車使用懲戒",
["Smite Melee Minions"] = "對近戰兵使用懲戒",
["Smite Caster Minions"] = "對遠程兵使用懲戒",
["Draw Settings"] =  "繪圖設置",
["Draw Skill Ranges"] =  "畫出技能線圈",
["Lag free draw"] =  "不影響延遲的線圈",
["Draw Q Range"] =  "畫出Q技能線圈",
["Choose Q Range Colour"] =  "選擇Q技能線圈顏色",
["Draw W Range"] =  "畫出W技能線圈",
["Choose W Range Colour"] =  "選擇W技能顏色",
["Draw E Range"] =  "畫出E技能線圈",
["Choose E Range Colour"] =  "選擇E技能線圈顏色",
["Draw R Range"] =  "畫出R技能線圈",
["Choose R Range Colour"] =  "選擇R技能線圈顏色",
["Draw AA Range"] =  "畫出平A的範圍",
["Draw Awareness"] =  "顯示意識",
["Draw Clicking Points"] =  "顯示點擊的位置",
["Draw Enemy Cooldowns"] =  "顯示敵人的CD",
["Draw Enemy Predicted Damage"] =  "顯示敵人的傷害",
["Draw Last Hit Marker"] =  "顯示尾刀的標記",
["Draw Wards + Wards Timers"] =  "顯示眼位以及眼位時間",
["Draw Turret Ranges"] =  "顯示防禦塔範圍",
["Draw Kill Range"] =  "顯示擊殺範圍",
["Kill Range"] =  "擊殺範圍",
["Choose Kill Range Colour"] =  "選擇擊殺範圍的顏色",
["Draw Focused Target"] =  "顯示鎖定的目標",
["Focused Target"] =  "鎖定目標",
["Choose Focused Target Colour"] =  "選擇鎖定目標的顏色",
["Draw Doomball Ranges"] =  "顯示魔偶的範圍",
["Draw Doomball W Range"] =  "顯示魔偶W的範圍",
["Draw Doomball R Range"] =  "顯示魔偶R的範圍",
----------------------------------------------------------------
["DeklandAIO: Syndra"] =  "神系列合集：辛德拉",
["Set Priority Amumu"] =  "設置木木的優先級",
["Use QE Snipe"] =  "使用QE",
["Cast On Optimal Target"] =  "對最佳目標釋放",
["Ult Amumu"] =  "對木木釋放R",
["Use QE Snipe (Teamfight)"] =  "使用QE（在團戰時）",
["Use QE Snipe (Harass)"] =  "使用QE（在騷擾時）",
["Use Kill Steal QE Snipe"] =  "用QE搶人頭",
["Use Gap Closers"] =  "對突進使用的技能",
["Interupt Skills"] =  "打斷敵方技能",
["Check On Dash Amumu"] =  "檢查木木的突進",
["Draw QE Range"] =  "畫出QE的範圍",
["Choose QE Range Colour"] =  "選擇QE的線圈顏色",
["Draw Prediction"] =  "畫出預判",
["Draw Q Prediction"] =  "畫出Q的預判",
["Draw W Prediction"] =  "畫出W的預判",
["Draw E Prediction"] =  "畫出E的預判",
["Draw QE Prediction"] =  "畫出QE的預判",
----------------神系列瑞茲錘石-----------------------
["DeklandAIO: Thresh"] = "神系列合集：錘石",
--["Use Lantern Whilst Hooked"] = "勾中的同時使用燈籠",
--["Use Lantern - Grab Ally"] = "對友軍使用燈籠",
--["Use Lantern - Self"] = "對自己使用燈籠",
["E Mode"] = "E技能模式",
["Auto"] = "自動",
["Pull"] = "向後拉",
["Push"] = "向前推",
["No. of Enemies In Range"] = "在範圍內的敵軍數量",
["Use Q On Dash "] = "對突進使用Q",
["Use E On Dash "] = "對突進使用E",
["             Ignite Not Found         "] = "             沒有發現點燃         ",
["Draw Souls"] = "顯示靈魂",
["DeklandAIO: Ryze"] = "神系列合集：瑞茲",
["Auto Q Stack"] = "自動Q攢被動",
-----------------神系列蛇女澤拉斯--------------------
["DeklandAIO: Cassiopeia"] = "神系列合集：卡西奧佩婭",
["Set Priority Chogath"] = "設置科加斯的優先級",
["Assisted Ult"] = "輔助大招",
["Use W Only If Q Misses"] = "只在Qmiss的時候使用W",
["E Daly Timer (secs)"] = "E延遲的時間(秒)",
["Use Spacebar (All skills can kill)"] = "使用空格(所有技能可以擊殺)",
["When conditions are met it will ult Automatically"] = "當滿足條件時會自動釋放大招",
["No. Enemies in Range"] = "範圍內有x名敵人",
["No. KS Enemies in Range"] = "範圍內有x名敵人可以搶人頭",
["No. Facing Enemies"] = "範圍內有x名面朝你的敵人",
["Ult Chogath"] = "對科加斯使用大招",
["Auto E Poison Minions"] = "自動E中毒的小兵",
["Check On Dash Chogath"] = "檢查科加斯的突進",
["Draw R Prediction"] = "顯示R的預判",
["Draw Poison Targets"] = "顯示中毒的目標",
["DeklandAIO: Xerath"] = "神系列合集：澤拉斯",
["Set Priority Nidalee"] = "設定奈德麗的優先級",
["Ult Tap (fires 'One' on release)"] = "大招按鍵(按一次放一個R)",
["Smart Cast Manual Q"] = "智能修正手動Q",
["Force Ult - R Key"] = "強制大招 - R鍵",
["Ult Near Mouse"] = "對鼠標附近的敵人放R",
["Ult Delay"] = "大招延遲",
["Check On Dash Nidalee"] = "檢查奈德麗的突進",
["MiniMap draw"] = "小地圖顯示",
["Draw Ult Range"] = "顯示R範圍",
["Draw Ult Marks"] = "顯示R標記",
-----------------燒傷合集----------------------------
["HTTF Prediction"] = "HTTF預判",
["Collision Settings"] = "碰撞設置",
["Buffer distance (Default value = 10)"] = "緩衝距離(默認10)",
["Ignore which is about to die"] = "忽略將要死亡的目標",
["Script version: "] = "腳本版本號",
["DivinePrediction"] = "神聖預判",
["Min Time in Path Before Predict"] = "預判路徑的最小時間",
["Central Accuracy"] = "中心精準度",
["Debug Mode [Dev]"] = "調試模式[開發者]",
["Cast Mode"] = "釋放模式",
["Fast"] = "快",
["Slow"] = "慢",
["Collision"] = "碰撞",
["Collision buffer"] = "碰撞緩衝",
["Normal minions"] = "普通小兵",
["Jungle minions"] = "野怪",
["Others"] = "其他",
["Check if minions are about to die"] = "檢查即將死亡的小兵",
["Check collision at the unit pos"] = "檢查單位位置的碰撞",
["Check collision at the cast pos"] = "檢查釋放位置的碰撞",
["Check collision at the predicted pos"] = "檢查預判位置的碰撞",
["Developers"] = "開發者",
["Enable debug"] = "啟用調試",
["Show collision"] = "顯示碰撞",
["Version"] = "版本",
["--- Fun House Team ---"] = "---燒傷團隊---",
["made by burn & ikita"] = "作者 burn & ikita",
["FH Global Settings"] = "燒傷合集全局設置",
["Amumu"] = "阿木木",
["5 = Maximum priority = You will focus first!"] = "5 - 最大優先級 -首要攻擊目標",
["Target Selector - Extra Setup"] = "目標選擇器 - 額外設置",
["- DISTANCE TO IGNORE TARGET (FOCUS MODE) -"] = "忽略鎖定目標的距離",
["Default distance"] = " 默認距離",
["------ DRAWS ------"] = "------ 顯示 ------",
["This allow you draw your target on"] = "這項設置允許將目標顯示在屏幕上",
["the screen, for quicker target orientation"] = "以獲得更快的目標方向",
["Enable draw of target (circle)"] = "啟用顯示目標(線圈)",
["Target circle color"] = "目標線圈顏色",
["Enable draw of target (text)"] = "啟用顯示目標(文字)",
["Select where to draw"] = "選擇顯示的位置",
["Fixed On Screen"] = "固定在屏幕上",
["On Mouse"] = "在鼠標上",
["--- Draw values ---"] = "--- 顯示設置 ---",
["Draw X location"] = "顯示X軸位置",
["Draw Y location"] = "顯示Y軸位置",
["Draw size"] = "顯示大小",
["Draw color"] = "顯示顏色",
["Reset draw position"] = "重設顯示位置",
["Auto Potions"] = "自動藥水",
["Use Health Potion"] = "使用血瓶",
["Use Refillable Potion"] = "使用復用型藥水",
["Use Hunters Potion"] = "使用獵人藥水",
["Use Corrupting Potion"] = "使用腐敗藥水",
["Corrupting Potion DPS in Combat"] = "在戰鬥中使用腐敗藥水增加傷害",
["Absolute Min Health %"] = "絕對生命值最小百分比",
["In Combat Min Health %"] = "戰鬥中生命值最小百分比",
["QSS & Cleanse"] = "水銀 & 凈化",
["Enable auto cleanse enemy debuffs"] = "啟用自動凈化",
["Settings for debuffs"] = "減益效果設置",
["- Global delay before clean debuff -"] = "自動凈化的全局延遲",
["Global Default delay"] = "全局默認延遲",
["- Usual debuffs -"] = "-常規減益效果-",
["Cleanse if debuff time > than (ms):"] = "如果減益效果時間大於..使用凈化",
["- Slow debuff -"] = "- 減速 -",
["Cleanse if slow time > than (ms):"] = "如果減速時間大於..使用凈化",
["- Special cases -"] = "- 特殊情況 -",
["Remove Zed R mark"] = "解劫的大招",
["Extra Awaraness"] = "額外意識",
["Enable Extra Awaraness"] = "啟用額外意識",
["Warning Range"] = "警告的範圍",
["Draw even if enemy not visible"] = "即使敵人隱身也線束",
["Security & Humanizer"] = "安全&擬人化",
["------------ SECURITY ------------"] = "------------ 安全 ------------",
["Enabling this, you will limit all functions"] = "啟用此設置，會限制僅當敵人在你的",
["to only trigger them if enemy/object"] = "屏幕上時所有功能才生效",
["is on your Screen"] = " ",
["Enable extra Security mode"] = "啟用額外安全設置",
["------------ HUMANIZER ------------"] = "------------ 擬人化 ------------",
["This will insert a delay between spells"] = "這項設置將會在你的連招中間加入延遲",
["If you set too high, it will make combo slow,"] = "如果你將數值設定的過高，連招會變慢",
["so if you use it increase it gradually!"] = "所以如果你要使用的話，請慢慢增加數值",
["Humanize Delay in ms"] = "擬人化延遲(毫秒)",
["Ryze Fun House 2.0"] = "燒傷合集2.0 - 瑞茲",
["General"] = "常規",
["Key binds"] = "鍵位設置",
["Auto Q stack out of combat"] = "在連招外自動Q攢被動",
["Combat"] = "連招",
["Smart Combo"] = "智能連招",
["Use Items on Combo"] = "在連招中使用物品",
["Use Desperate Power (R)"] = "使用絕望之力(R)",
["R Cast Mode"] = "R使用模式",
["Required stacks on 'Smart' for cast R"] = "智能使用R時需要被動層數",
["Harass"] = "騷擾",
["Use Overload (Q)"] = "使用超負荷(Q)",
["Use Rune Prison (W)"] = "使用符文禁錮(W)",
["Use Spell Flux (E)"] = "使用法術涌動(E)",
["Use Overload (Q) for last hit"] = "使用Q來補尾刀",
["Min Mana % to use Harass"] = "騷擾的最小藍量 %",
["Auto kill"] = "自動擊殺",
["Enable Auto Kill"] = "啟用自動擊殺",
["Auto KS under enemy towers"] = "在敵人塔下自動搶人頭",
["Farming"] = "刷兵",
["Lane Clear"] = "清線",
["Min Mana % for lane clear"] = "清線的最小藍量 %",
["Last Hit"] = "尾刀",
["Use Q for last hit"] = "使用Q來補尾刀",
["Last Hit with AA"] = "使用平A來補尾刀",
["Min Mana % for Q last hit"] = "Q補尾刀的最小藍量",
["Drawings"] = "顯示設置",
["Spell Range"] = "技能線圈",
["Enable Draws"] = "啟用顯示",
["Draw Q range"] = "顯示Q範圍",
["Q color"] = "Q線圈顏色",
["Draw W-E range"] = "顯示W-E範圍",
["W-E color"] = "W-E線圈顏色",
["Draw Stacks"] = "顯示被動層數",
["Use Lag Free Circle"] = "使用不影響延遲的線圈",
["Kill Texts"] = "擊殺提示",
["Use KillText"] = "啟用擊殺提示",
["Draw KillTime"] = "顯示擊殺時間",
["Text color"] = "文字顏色",
["Draw Damage Lines"] = "顯示傷害指示線",
["Damage color display"] = "顯示傷害的顏色",
["Miscellaneous"] = "雜項設置",
["Auto Heal"] = "自動治療",
["Automatically use Heal"] = "使用自動治療",
["Min percentage to cast Heal"] = "使用治療的最小血量 %",
["Use Heal to Help teammates"] = "對友軍使用治療",
["Teammates to Heal"] = "使用治療的友軍",
["Auto Zhonyas"] = "自動中亞",
["Automatically Use Zhonyas"] = "自動使用中亞",
["Min Health % to use Zhonyas"] = "使用中亞的最小血量",
["Use W on enemy gap closers"] = "對敵方的突進使用W",
["Auto Q for get shield vs gap closers"] = "自動Q來獲得護盾以抵禦突進",
["Auto use Seraph's Embrace on low Health"] = "低血量時自動使用大天使",
["Min % to cast Seraph's Embrace"] = "使用大天使的最小血量 %",
["Prediction"] = "預判",
["-- Prediciton Settings --"] = "------ 預判設置 ------",
["VPrediction"] = "V預判",
["DPrediction"] = "神聖預判",
["-- VPrediction Settings --"] = "------ V預判設置 ------",
["Q Hit Chance"] = "Q的命中機會",
["Medium"] = "中等",
["High"] = "高",
["-- HPrediction Settings --"] = "------ H預判設置 ------",
["-- DPrediction Settings --"] = "----- 神聖預判設置 -----",
["Instant force W"] = "立即強制使用W",
["Flee Key"] = "逃跑按鍵",
["Toggle Parry Auto Attack"] = "切換格擋自動攻擊",
["Orbwalk on Combo"] = "在連招中的走砍",
["To Vital"] = "移動至弱點",
["To Target"] = "移動至目標",
["Disabled"] = "關閉",
["Orbwalk Magnet Range"] = "走砍磁力範圍",
["Vital Strafe Outwards Distance %"] = "擊中弱點向外延伸距離%",
["Fiora Fun House 2.0"] = "燒傷合集2.0 - 菲奧娜",
["Orbwalk Settings"] = "走砍設置",
["W Hit Chance"] = "W技能命中的機會",
["Draw R range"] = "顯示R的範圍",
["Draw AA range"] = "顯示平A的範圍",
["Use IGNITE"] = "使用點燃",
["Q Color"] = "Q技能線圈顏色",
["Combo"] = "連招",
["--- Combo Logic ---"] = "--- 連招邏輯 ---",
["Save Q for dodge enemy hard spells"] = "保留Q來躲避敵人的重要技能",
["Q Gapclose regardless of vital"] = "使用Q突進時忽略弱點",
["Gapclose min catchup time"] = "突進最小追趕時間",
["Q minimal landing position"] = "Q的最短釋放位置",
["Q Angle in degrees"] = "Q的角度",
["Q on minion to reach enemy"] = "Q小兵來接近敵人",
["--- Ultimate R Logic ---"] = "--- 大招使用邏輯 ---",
["Focus R Casted Target"] = "鎖定使用R的目標",
["Cast when target killable"] = "當目標可以被擊殺時使用R",
["Cast only when healing required (overrides above)"] = "有回血需要時用R",
["Cast when our HP less than %"] = "當生命值小於%時使用R",
["Cast before KS with Q when lower than"] = "在用Q搶人頭之前使用R",
["Riposte Options"] = "勞倫特心眼刀(W)設置",
["Riposte Enabled"] = "使用W",
["Save Q Evadeee when Riposte cd"] = "當Wcd時保留Q來躲避",
["Auto Parry next attack when %HP <"] = "當生命值小於%時自動格擋下一次普通攻擊",
["Humanizer: Extra delay"] = "擬人化：額外延遲",
["Parry Summoner Spells (low latency)"] = "格擋召喚師技能(低延遲)",
["Parry Dragon Wind"] = "格擋小龍的攻擊",
["Parry Auto Attacks"] = "格擋普通攻擊",
["Parry AA Damage Threshold"] = "格擋平A的傷害臨界值",
["Parry is still a Work In Progress"] = "格擋功能是仍在開發的功能",
["If is not parrying a spell from the list,"] = "如果沒有格擋列表中的技能",
["before report on forum, make a list like:"] = "在論壇報告之前，寫一個像下面一樣的列表",
["Champion-Spell that fails to parry"] = "格擋失敗的技能：如果你有大於20個",
["When you have 20+ added, post it on forum. Thanks"] = "無法格擋的技能，請發表在論壇上",
["Riposte Main List"] = "格擋主要技能列表",
["--- Riposte Spells At Arrival ---"] = "--- 當技能命中的時候格擋 ---",
["Riposte Extra List"] = "格擋額外技能列表",
["Use Q on Harass"] = "在騷擾中使用Q",
["Use Lunge (Q)"] = "使用破空斬Q",
["Use Riposte (W) [only on Jungle]"] = "使用勞倫特心眼刀W[只對野怪]",
["Use Bladework (E)"] = "使用奪命連刺E",
["Use items"] = "使用物品",
["R Color"] = "R技能顏色",
["AA Color"] = "平A線圈顏色",
["Draw Magnet Orbwalk range"] = "顯示走砍磁力範圍",
["Draw Flee direction"] = "顯示逃跑方向",
["Draw KillText"] = "顯示擊殺提示",
["HPrediction"] = "H預判",
["SxOrbWalk"] = "Sx走砍",
["General-Settings"] = "常規設置",
["Orbwalker Enabled"] = "走砍生效",
["Stop Move when Mouse above Hero"] = "當英雄在鼠標下時停止移動",
["Range to Stop Move"] = "停止移動的區域",
["ExtraDelay against Cancel AA"] = "取消平A後搖的額外延遲",
["Spam Attack on Target"] = "儘可能多的平A目標",
["Orbwalker Modus: "] = "走砍模式",
["To Mouse"] = "向鼠標",
["Humanizer-Settings"] = "擬人化設置",
["Limit Move-Commands per Second"] = "限制每秒發送的移動指令",
["Max Move-Commands per Second"] = "每秒發送移動指令的最大次數",
["Key-Settings"] = "鍵位設置",
["FightMode"] = "戰鬥模式",
["HarassMode"] = "騷擾模式",
["LaneClear"] = "清線",
["LastHit"] = "尾刀",
["Toggle-Settings"] = "切換設置",
["Make FightMode as Toggle"] = "顯示戰鬥模式切換",
["Make HarassMode as Toggle"] = "顯示騷擾模式切換",
["Make LaneClear as Toggle"] = "顯示清線模式切換",
["Make LastHit as Toggle"] = "顯示尾刀模式切換",
["Farm-Settings"] = "刷兵設置",
["Focus Farm over Harass"] = "在騷擾時專心補刀",
["Extra-Delay to LastHit"] = "尾刀時的額外延遲",
["Mastery-Settings"] = "天賦設置",
["Mastery: Butcher"] = "屠夫",
["Mastery: Arcane Blade"] = "雙刃劍",
["Mastery: Havoc"] = "毀滅",
["Mastery: Devastating Strikes"] = "毀滅打擊",
["Draw-Settings"] = "顯示設置",
["Draw Own AA Range"] = "顯示自己的平A線圈",
["Draw Enemy AA Range"] = "顯示敵人的平A線圈",
["Draw LastHit-Cirlce around Minions"] = "在小兵上顯示尾刀線圈",
["Draw LastHit-Line on Minions"] = "在小兵上顯示尾刀指示線",
["Draw Box around MinionHpBar"] = "在小兵血條上畫放開",
["Color-Settings"] = "顏色設置",
["Color Own AA Range: "] = "自己的平A線圈的顏色",
["white"] = "白色",
["blue"] = "藍色",
["red"] = "紅色",
["black"] = "黑色",
["green"] = "綠色",
["orange"] = "橙色",
["Color Enemy AA Range (out of Range): "] = "敵人平A線圈的顏色(範圍外)",
["Color Enemy AA Range (in Range): "] = "敵人平A線圈的顏色(範圍內)",
["Color LastHit MinionCirlce: "] = "小兵尾刀線圈顏色",
["Color LastHit MinionLine: "] = "小兵尾刀指示線顏色",
["ColorBox: Minion is LasthitAble: "] = "小兵可被尾刀的顏色",
["none"] = "無",
["ColorBox: Wait with LastHit: "] = "小兵等待被尾刀的顏色",
["ColorBox: Can Attack Minion: "] = "可以攻擊的小兵顏色",
["TargetSelector"] = "目標選擇器",
["Priority Settings"] = "優先級顏色",
["Focus Selected Target: "] = "鎖定選定的目標",
["never"] = "從不",
["when in AA-Range"] = "當在平A範圍時",
["TargetSelector Mode: "] = "目標選擇器模式",
["LowHP"] = "低血量",
["LowHPPriority"] = "低血量+優先級",
["LessCast"] = "更少釋放技能",
["LessCastPriority"] = "更少釋放技能+優先級",
["nearest myHero"] = "離自己的英雄最近",
["nearest Mouse"] = "離鼠標最近",
["RawPriority"] = "重設優先級",
["Highest Priority (ADC) is Number 1!"] = "最高優先級(ADC)為1",
["Debug-Settings"] = "調試模式",
["Draw Circle around own Minions"] = "在己方小兵上畫圈",
["Draw Circle around enemy Minions"] = "在敵方小兵上畫圈",
["Draw Circle around jungle Minions"] = "在野怪上畫圈",
["Draw Line for MinionAttacks"] = "顯示小兵攻擊指示線",
["Log Funcs"] = "日誌功能",
["Irelia Fun House 2.0"] = "燒傷合集2.0 - 艾瑞莉婭",
["R Lane Clear toggle"] = "R清線切換",
["Force E"] = "強制E",
["Q on killable minion to reach enemy"] = "對可擊殺的小兵使用Q以突進敵人",
["Use Q only as gap closer"] = "僅突進時使用Q",
["Minimum distance for use Q"] = "使用Q的最小距離",
["Save E for stun"] = "保留E用來眩暈",
["Use E for slow if enemy run away"] = "如果敵人逃跑使用E來減速",
["Use E for interrupt enemy dangerous spells"] = "使用E打斷敵人的危險技能",
["Anti-gapclosers with E stun"] = "使用E眩暈來反突進",
["Use R on sbtw combo"] = "只在連招中使用R",
["Cast R when our HP less than"] = "當你的生命值低於%時使用R",
["Cast R when enemy HP less than"] = "當敵人生命值低於%時使用R",
["Block R in sbtw until Sheen/Tri Ready"] = "屏蔽R直到耀光效果就緒",
["In Team Fight, use R as AOE"] = "在團戰中使用R打AOE",
["Use Bladesurge (Q) on minions"] = "對小兵使用Q",
["Use Bladesurge (Q) on target"] = "對目標使用Q",
["Use Equilibrium Strike (W)"] = "使用W",
["Use Equilibrium Strike (E)"] = "使用E",
["Use Bladesurge (Q)"] = "使用Q",
["Use Transcendent Blades (R)"] = "使用R",
["Only Q minions that can't be AA"] = "只對不能平A的小兵使用Q",
["Block Q on Jungle unless can reset"] = "屏蔽Q直到野怪可以被Q擊殺",
["Block Q on minions under enemy tower"] = "在敵方塔下時屏蔽Q",
["Humanizer delay between Q (ms)"] = "Q之間的擬人化延遲(毫秒)",
["Use Hiten Style (W)"] = "使用W",
["No. of minions to use R"] = "使用R的最少小兵數量",
["Maximum distance for Q in Last Hit"] = "使用Q尾刀的最大距離",
["E Color"] = "E線圈的顏色",
["Auto Ignite"] = "自動點燃",
["Automatically Use Ignite"] = "自動使用點燃",
----------------燒傷瞎子---------------------
["Lee Sin Fun House 2.0"] = "燒傷合集2.0 - 盲僧",
["Lee Sin Fun House"] = "燒傷盲僧",
["Ward Jump Key"] = "摸眼按鍵",
["Insec Key"] = "Insec按鍵",
["Jungle Steal Key"] = "搶龍按鍵",
["Insta R on target"] = "立即對目標使用R",
["Disable R KS in combo 4 sec"] = "在4秒內關閉用R搶人頭",
["Combo W->R KS (override autokill)"] = "W->R搶人頭連招",
["Passive AA Spell Weave"] = "技能之間銜接被動平A",
["Smart"] = "只能",
["Quick"] = "快速",
["Use Stars Combo: RQQ"] = "使用明星連招：RQQ",
["Use Q-Smite for minion block"] = "有小兵擋住時使用Q懲戒",
["Use W on Combo"] = "在連招中使用W",
["Use wards if necessary (gap closer)"] = "使用W突進敵人(如果必要)",
["Cast R when it knockups at least"] = "如果能擊飛x個敵人使用R",
["Cast W to Mega Kick position"] = "使用W來找能踢多個敵人的位置",
["Use R to stop enemy dangerous spells"] = "使用R來打斷敵人的危險技能",
["-- ADVANCED --"] = "-- 高級設置 --",
["Combo-Insec value Target"] = "迴旋踢目標",
["Combo-Insec with flash"] = "使用R閃迴旋踢",
["Use R-flash if no W or wards"] = "如果沒有W或者沒有眼使用R閃",
["Use W-R-flash if Q cd (BETA)"] = "如果Qcd使用W-R閃(測試)",
["Insec Mode"] = "迴旋踢模式",
["R Angle Variance"] = "R的角度調整",
["KS Enabled"] = "啟用搶人頭",
["Autokill Under Tower"] = "在塔下自動擊殺",
["Autokill Q2"] = "使用二段Q自動擊殺",
["Autokill R"] = "使用R自動擊殺",
["Autokill Ignite"] = "使用點燃自動擊殺",
["--- LANE CLEAR ---"] = "--- 清線 ---",
["LaneClear Sonic Wave (Q)"] = "使用Q清線",
["LaneClear Safeguard (W)"] = "使用W清線",
["LaneClear Tempest (E)"] = "使用E清線",
["LaneClear Tiamat Item"] = "使用提亞馬特清線",
["LaneClear Energy %"] = "清線能量控制%",
["--- JUNGLE CLEAR ---"] = "--- 清野 ---",
["Jungle Sonic Wave (Q)"] = "使用Q清野",
["Jungle Safeguard (W)"] = "使用W清野",
["Jungle Tempest (E)"] = "使用E清野",
["Jungle Tiamat Item"] = "使用提亞馬特清野",
["Use E if AA on cooldown"] = "使用E重置普攻",
["Use Q for harass"] = "使用一段Q騷擾",
["Use Q2 for harass"] = "使用二段Q騷擾",
["Use W for retreat after Q2+E"] = "二段Q+E後使用W撤退",
["Use E for harass"] = "使用E技能騷擾",
["-- Spells Range --"] = "-- 技能範圍線圈 --",
["Draw W range"] = "顯示W範圍",
["W color"] = "W技能線圈顏色",
["Draw E range"] = "顯示E技能範圍",
["Combat Draws"] = "顯示戰鬥",
["Insec direction & selected points"] = "迴旋踢的地點&選定的地點",
["Collision & direction for direct R"] = "碰撞&直線R的方向",
["Draw non-Collision R direction"] = "顯示無碰撞的R的方向",
["Collision & direction Prediction"] = "碰撞&方向預判",
["Draw Damage"] = "顯示傷害",
["Draw Kill Text"] = "顯示擊殺提示",
["Debug"] = "調試",
["Focus Selected Target"] = "鎖定選擇的目標",
["Always"] = "總是",
["Auto Kill"] = "自動擊殺",
["Insec Wardjump Range Reduction"] = "迴旋踢摸眼範圍減少",
["Magnetic Wards"] = "便捷吸附性插眼",
["Enable Magnetic Wards Draw"] = "啟用吸附性插眼顯示",
["Use lfc"] = "使用lfc",
["--- Spots to be Displayed ---"] = "--- 顯示的插眼點 ---",
["Normal Spots"] = "普通地點",
["Situational Spots"] = "取決於情況的地點",
["Safe Spots"] = "安全地點",
["--- Spots to be Auto Casted ---"] = "--- 自動插眼的地點 ---",
["Disable quickcast/smartcast on items"] = "禁用快速/智能使用物品",
["--- Possible Keys for Trigger ---"] = "--- 可能觸發的按鍵 ---",
--------------燒傷寡婦----------------------
["Evelynn Fun House 2.0"] = "燒傷合集2.0 - 伊芙琳",
["Force R Key"] = "強制大招按鍵",
["Use Agony's Embrace (R)"] = "使用R",
["Required enemies to cast R"] = "使用R需要的敵人數",
["Auto R on low HP as life saver"] = "在低血量的時候自動R以救命",
["Minimum % of HP to auto R"] = "自動R的最小觸發生命值",
["Use Hate Spike (Q)"] = "使用憎恨之刺(Q)",
["Use Ravage (E)"] = "使用毀滅打擊(E) ",
["Draw A range"] = "顯示平A範圍",
["A color"] = "平A線圈顏色",
["Reverse Passive Vision"] = "反轉被動視野",
["Vision Color"] = "視野顏色",
["Stealth Status"] = "隱身狀態",
["Spin Color"] = "旋轉顏色",
["Info Box"] = "信息框",
["X position of menu"] = "菜單的X軸位置",
["Y position of menu"] = "菜單的Y軸位置",
["W Settings"] = "W技能設置",
["Use W on flee mode"] = "在逃跑模式使用W",
["Use W for cleanse enemy slows"] = "使用W來移除敵人的減速",
["R Hit Chance"] = "R命中的機會",
["E color"] = "E線圈顏色",
["R color"] = "R線圈顏色",
["Key Binds"] = "鍵位設置",
--------------燒傷豹女獅子狗黃雞------------
["FH Smite"] = "燒傷 懲戒",
["Jungle Camps"] = "野怪營地",
["Enable Auto Smite"] = "啟用自動懲戒",
["Temporally Disable Autosmite"] = "暫時禁用懲戒",
["--- Global Objectives ---"] = "--- 全局目標 ---",
["Rift Scuttler Top"] = "上路河道蟹",
["Rift Herald"] = "峽谷先鋒",
["Rift Scuttler Bot"] = "下路河道蟹",
["Baron"] = "大龍",
["Dragon"] = "小龍",
["--- Normal Camps ---"] = "-- 普通野怪 --",
["Murk Wolf"] = "暗影狼",
["Red Buff"] = "紅buff",
["Blue Buff"] = "藍buff",
["Gromp"] = "魔沼蛙",
["Raptors"] = "鋒喙鳥(F4)",
["Krugs"] = "石甲蟲",
["Chilling Smite KS"] = "寒霜懲戒搶人頭",
["Chilling Smite Chase"] = "寒霜懲戒追擊",
["Challenging Smite Combat"] = "在連招中使用挑戰懲戒",
["Forced Smite on Enemy"] = "強制懲戒敵人",
["Draw Smite % damage"] = "顯示懲戒百分比傷害",
["Smite Fun House"] = "懲戒 燒傷",
["Taric"] = "塔里克",
["Nidalee Fun House 2.0"] = "燒傷合集2.0 - 奈德麗",
["Nidalee Fun House"] = "燒傷合集 - 奈德麗",
["Harass Toggle Q"] = "Q騷擾開關",
["Use W on combo (human form)"] = "在連招中使用W(人形態)",
["Immobile"] = "不可移動的",
["Mana Min percentage W"] = "W的最小藍量%",
["E for SpellWeaving/DPS"] = "使用E以提升輸出",
["Auto heal E"] = "E自動加血",
["Self"] = "自己",
["Self/Ally"] = "自己/友軍",
["Min percentage hp to auto heal"] = "自動加血的最小觸發血量%",
["Min mana to cast E"] = "使用E的最小藍量",
["Smart R swap"] = "智能R切換形態",
["Allow Mid-Jump Transform"] = "允許跳躍的空中變換形態",
["Harass (Human form)"] = "騷擾(人形態)",
["Use Javelin Toss (Q)"] = "使用人形態Q騷擾",
["Use Toggle Key Override (Keybinder Menu)"] = "使用按鍵開關覆蓋",
["Min mana to cast Q"] = "使用Q的最小藍量",
["Flee"] = "逃跑",
["W for Wall Jump Only"] = "W只用來跳牆",
["Lane Clear with AA"] = "使用平A清線",
["Use Bushwhack (W)"] = "使用人形態W",
["Use Primal Surge (E)"] = "使用人形態E",
["Use Takedown (Q)"] = "使用豹形態Q",
["Use Pounce (W)"] = "使用豹形態W",
["Use Swipe (E)"] = "使用豹形態E",
["Use Aspect of the Cougar (R)"] = "使用R",
["Mana Min percentage"] = "最小藍量百分比",
["Draw Q range (Human)"] = "顯示人形態Q範圍",
["Draw W range (Human)"] = "顯示人形態W範圍",
["W color (Human)"] = "人形態W線圈顏色",
["Draw E range (Human)"] = "顯示人形態E範圍",
["Karthus"] = "卡爾薩斯",
["Rengar Fun House 2.0"] = "燒傷合集2.0 - 雷恩加爾",
["Rengar Fun House"] = "燒傷合集 - 雷恩加爾",
["Force E Key"] = "強制E按鍵",
["Combo Mode Key"] = "連招模式按鍵",
["Use empower W if health below %"] = "當生命值低於%使用強化W",
["Min health % for use it ^"] = "使用的最小生命值%",
["Use E on Dynamic Combo if enemy is far"] = "如果敵人距離很遠在動態連招中使用E",
["Playing AP rengar !"] = "AP獅子狗模式",
["Use E on AP Combo if enemy is far"] = "如果敵人距離很遠在AP連招中使用E",
["Anti Dashes"] = "反突進",
["Antidash Enemy Enabled"] = "對敵人啟用反突進",
["LaneClear Savagery (Q)"] = "在清線中使用Q",
["LaneClear Battle Roar (W)"] = "在清線中使用W",
["LaneClear Bola Strike (E)"] = "在清線中使用E",
["stop using spells at 5 stacks"] = "5格殘暴的時候停止使用技能",
["Jungle Savagery (Q)"] = "在清野中使用Q",
["Jungle Battle Roar (W)"] = "在清野中使用W",
["Jungle Bola Strike (E)"] = "在清野中使用E",
["Jungle Savagery (Q) Empower"] = "在清野中使用強化Q",
["Jungle Battle Roar (W) Empower"] = "在清野中使用W",
["Use Q if AA on cooldown"] = "使用Q來重置普攻",
["Use W if AA on cooldown"] = "使用W來重置普攻",
["Use W for harass"] = "使用W騷擾",
["Draw R timer"] = "顯示R的時間",
["Draw R Stealth Distance"] = "顯示R隱身距離",
["Draw R on:"] = "顯示R狀態:",
["Center of screen"] = "在屏幕中央",
["Champion"] = "英雄",
["-- Draw Combo Mode values --"] = "-- 顯示連招模式設置 --",
["E Hit Chance"] = "E命中的機會",
["Swain"] = "斯維因",
["Azir Fun House 2.0"] = "燒傷合集2.0 - 阿茲爾",
["Force Q"] = "強制Q",
["Quick Dash Key"] = "快速突進按鍵",
["Panic R"] = "驚恐模式R",
["--- Q LOGIC ---"] = "--- Q技能邏輯 ---",
["Q prioritize soldier reposition"] = "Q優先重置沙兵的位置",
["Always expend W before Q Cast"] = "總是Q之前放W",
["--- W LOGIC ---"] = "--- W技能邏輯 ---",
["W Cast Method"] = "釋放W的防晒霜",
["Always max range"] = "總是在最大距離",
["Min Mana % to cast extra W"] = "釋放額外W的最小藍量%",
["--- E LOGIC ---"] = "--- E技能邏輯 ---",
["E to target when safe"] = "當安全時E向目標",
["--- R LOGIC ---"] = "--- R技能邏輯 ---",
["Single target R in melee range"] = "處於近戰攻擊距離的時候只R一個目標",
["To Soldier"] = "向沙兵釋放",
["To Ally/Tower"] = "向友軍/塔釋放",
["Single target R only under self HP"] = "只在自己生命值低於x時只R一個目標",
["Multi target R logic"] = "多目標R邏輯",
["Block"] = "屏蔽",
["Multi target R at least on"] = "多目標R時最小目標數",
["R enemies into walls"] = "把敵軍推到牆裡",
["Use orbwalking on combo"] = "在連招中使用走砍",
["--- Automated Logic ---"] = "--- 自動技能邏輯 ---",
["Auto R when at least on"] = "當目標至少有x個時自動R",
["Block Sion Ult (Beta)"] = "抵擋塞恩的R(測試)",
["Interrupt channelled spells with R"] = "使用R打斷引導技能",
["R enemies back into tower range"] = "把敵人推到塔範圍內",
["Block Gap Closers with R"] = "使用R反突進",
["R-Combo Casts"] = "使用R連招",
["--- COMBO-DASH LOGIC ---"] = "--- 突進連招邏輯 ---",
["Smart DASH chase in combo"] = "在追擊時使用智能突進連招",
["Min Self HP % to smart dash"] = "自身生命值大於%時使用智能突進",
["Max target HP % to smart dash"] = "目標生命值小於%時使用智能突進",
["Max target HP % dash in R CD"] = "Rcd時目標",
["ASAP R to ally/tower after dash hit"] = " ",
["Dash R Area back range"] = " ",
["--- COMBO-INSEC LOGIC ---"] = "--- Insec連招邏輯 ---",
["Smart new-INSEC in combo"] = "在連招中使用智能新Insec連招",
["new-Insec only x allies more"] = "只在大於x名友軍時使用新Insec連招",
["Use W on Harass"] = "在騷擾中使用W",
["Number of W used"] = "使用W的數量",
["Insec / Dash"] = "Insec / 突進",
["Min. gap from soldier in dash"] = "突進時至少存在的沙兵數",
["Abs. R delay after Q cast"] = "當Q釋放後釋放R的延遲",
["Insec Extension"] = "Insec的延伸距離",
["From Soldier"] = "從沙兵",
["From player"] = "來自玩家",
["Direct Hit"] = "直接擊中",
["Use Conquering Sands (Q)"] = "使用Q",
["Use Shifting Sands (E)"] = "使用E",
["Use Emperor's Divide (R)"] = "使用R",
["Use Arise! (W)"] = "使用W",
["Number of Soldiers"] = "沙兵數目",
["Use W for AA if outside AA range"] = "如果在平A範圍外使用W攻擊",
["Draw Soldier range"] = "顯示沙兵的攻擊範圍",
["Draw Soldier time"] = "顯示沙兵持續時間",
["Draw Soldier Line"] = "顯示沙兵指示線",
["Soldier and line color"] = "沙兵和指示線線的顏色",
["Soldier out-range color"] = "範圍外的沙兵的顏色",
["Draw Dash Area"] = "顯示突進的區域",
["Dash color"] = "突進區域顏色",
["Draw Insec range"] = "顯示Insec的範圍",
["Insec Draws"] = "Insec顯示",
["Draw Insec Direction on target"] = "在目標上顯示Insec的方向",
["Cast Ignite on Swain"] = "對斯維因使用點燃",
--------------QQQ亞索-----------------------
["Yasuo - The Windwalker"] = "風行者 - 亞索",
["----- General settings --------------------------"] = "----- 常用設置 --------------------------",
["> Keys"] = "> 按鍵設置",
["> Orbwalker"] = "> 走砍設置",
["> Targetselector"] = "> 目標選擇器",
["> Prediction"] = "> 預判設置",
["> Draw"] = "> 顯示設置",
["> Cooldowntracker"] = "> 冷卻計時",
["> Scripthumanizer"] = "> 腳本擬人化",
["----- Utility settings -----------------------------"] = "----- 功能設置 --------------------------",
["> Windwall"] = "> 風牆",
["> Ultimate"] = "> 大招",
["> Turretdive"] = "> 越塔",
["> Gapclose"] = "> 突進",
["> Walljump"] = "> 穿牆",
["> Spells"] = "> 技能",
["> Summonerspells"] = "> 召喚師技能",
["> Items"] = "> 物品",
["----- Combat settings ----------------------------"] = "----- 戰鬥設置 --------------------------",
["> Combo"] = "> 連招",
["> Harass"] = "> 騷擾",
["> Killsteal"] = "> 搶人頭",
["> Lasthit"] = "> 尾刀",
["> Laneclear"] = "> 清線",
["> Jungleclear"] = "> 清野",
["----- About the script ---------------------------"] = "關於本腳本",
["Gameregion"] = "遊戲區域",
["Scriptversion"] = "腳本版本",
["Author"] = "作者",
["Updated"] = "更新日期",
["\"The road to ruin is shorter than you think...\""] = "滅亡之路,短的超乎你的想象。",
["This section is only a placeholder for more structure"] = "這個部分只是待添加內容的預留位置",
["Choose targetselector mode"] = "選擇目標選擇器位置",
["LESS_CAST"] = "更少使用技能",
["LOW_HP"] = "低血量",
["SELECTED_TARGET"] = "選定的目標",
["PRIORITY"] = "優先級",
["Set your priority here:"] = "在這裡設定優先級",
["No targets found / available! "] = "沒有找到目標",
["Draw your current target with circle:"] = "在你的當前目標上畫圈",
["Draw your current target with line:"] = "在你的當前目標上畫線",
["Use Gapclose"] = "使用突進",
["Check health before gapclosing under towers"] = "在塔下突進時檢查血量",
["Only gapclose if my health > % "] = "只在我的血量大於%時突進",
["> Settings "] = "> 設置",
["Set Gapclose range"] = "設置突進距離",
["Draw gapclose target"] = "顯示突進目標",
["> General settings"] = "> 常規設置",
["Use Autowall: "] = "使用自動風牆:",
["Draw skillshots: "] = "畫出技能彈道",
["> Humanizer settings"] = "> 擬人化設置",
["Use Humanizer: "] = "使用擬人化",
["Humanizer level"] = "擬人化等級",
["Normal mode"] = "普通模式",
["Faker mode"] = "Faker模式",
["> Autoattack settings"] = "> 普通攻擊設置",
["Block autoattacks: "] = "屏蔽普通攻擊:",
["if your health is below %"] = "如果你的生命值低於%",
["> Skillshots"] = "> 技能彈道",
["No supported skillshots found!"] = "沒有找到支持的技能",
["> Targeted spells"] = "> 指向性技能",
["No supported targeted spells found!"] = "沒有找到支持的指向性技能",
[">> Towerdive settings"] = ">> 越塔設置",
["Towerdive Mode"] = "越塔模式",
["Never dive turrets"] = "從不越塔",
["Advanced mode"] = "高級模式",
["Draw turret range: "] = "顯示防禦塔範圍: ",
[">> Normal Mode Settings"] = ">> 普通模式設置",
["Min number of ally minions"] = "最小友方小兵數",
[">> Easy Mode Settings"] = ">> 簡單模式設置",
["Min number of ally champions"] = "最小友方英雄數",
["> Info about normal mode"] = "> 普通模式介紹",
[">| The normal mode checks for x number of ally minions"] = ">| 普通模式會檢查防禦塔下友方小兵的數量",
[">| under enemy turrets. If ally minions >= X then it allows diving!"] = ">| 如果友方小兵數大於等於x就會允許越塔",
["> Info about advanced mode"] = "> 高級模式介紹",
[">| The advanced mode checks for x number of ally minions"] = "高級模式會檢查防禦塔下友方小兵數量",
[">| as well as for x number of ally champions under enemy turrets."] = "和防禦塔友方英雄數量",
[">| If both >= X then it allows diving!"] = "如果都大於等於x就會允許越塔",
["Always draw the indicators"] = "總是顯示傷害預測",
["Only draw while holding"] = "只有在按鍵的時候才顯示",
["Not draw inidicator if pressed"] = "在按鍵的時候不顯示",
["> Draw cooldowns for:"] = "> 顯示cd時間",
["your enemies"] = "敵方英雄",
["your allies"] = "友方英雄",
["your hero"] = "自己",
["Show horizontal indicators"] = "顯示水平的傷害預測",
["Show vertical indicators"] = "顯示垂直的傷害預測",
["Vertical position"] = "垂直傷害預測的位置",
["> Choose your Color"] = "> 選擇顏色",
["Cooldown color"] = "cd計時顏色",
["Ready color"] = "技能就緒的顏色",
["Background color"] = "背景顏色",
["> Summoner Spells"] = "> 召喚師技能",
["Flash"] = "閃現",
["Ghost"] = "幽靈疾步",
["Barrier"] = "屏障",
["Smite"] = "懲戒",
["Exhaust"] = "虛弱",
["Heal"] = "治療",
["Teleport"] = "傳送",
["Cleanse"] = "凈化",
["Clarity"] = "清晰術",
["Clairvoyance"] = "洞察",
["The Rest"] = "其他",
[">> Combat keys"] = ">> 戰鬥按鍵",
["Combo key"] = "連招按鍵",
["Harass key"] = "騷擾按鍵",
["Harass (toggle) key"] = "騷擾(開關)按鍵",
["Ultimate (toggle) key"] = "大招(開關)按鍵",
[">> Farm keys"] = ">> 發育按鍵",
["Lasthit key"] = "尾刀按鍵",
["Jungle- and laneclear key: "] = "清野和清線按鍵",
[">> Other keys"] = ">> 其他按鍵",
["Escape-/Walljump key"] = "逃跑/穿牆按鍵",
["Autowall (toggle) key"] = "自動風牆(開關)按鍵",
["Use walljump"] = "使用穿牆",
["Priority to gain vision"] = "獲得視野的優先級",
["Wards"] = "眼",
["Wall"] = "風牆",
["> Draw jumpspot settings"] = "> 顯示穿牆位置",
["Draw points"] = "顯示點",
["Draw jumpspot while key pressed"] = "按鍵按下時顯示穿牆位置",
["Radius of the jumpspots"] = "穿牆點半徑",
["Max draw distance"] = "最大顯示距離",
["Draw line to next jumpspots"] = "顯示到下一穿牆點的直線",
["> Draw jumpspot colors"] = "> 顯示穿牆點的顏色",
["Jumpspot color"] = "穿牆點的顏色",
["(E) - Sweeping Blade settings: "] = "(E) - 踏前斬設置",
["Increase dashtimer by"] = "增加突進時間",
[">| This option will increase the time how long the script"] = ">| 這項設置會通過一個設定的值來增加",
[">| thinks you are dashing by a fixed value"] = ">| 腳本認為你正在突進的時間",
["Check distance of target and (E)endpos"] = "檢查目標和E結束地點的距離",
["Maximum distance"] = "最大距離",
[">| This option will check if the distance"] = ">| 這項設置會檢查你的目標",
[">| between your target and the endposition of your (E) cast"] = ">| 和E結束地點的距離",
[">| is greater then the distance set in the slider."] = "如果大於你設定的距離",
[">| If yes the cast will get blocked!"] = "就會屏蔽E的釋放",
[">| This prevents dashing too far away from your target!"] = "這會避免你突進時和目標離的太遠",
["Auto Level Enable/Disable"] = "自動加點 開啟/關閉",
["Auto Level Skills"] = "自動升級技能",
["No Autolevel"] = "不自動加點",
["> Autoultimate"] = "> 自動大招",
["Number of Targets for Auto(R)"] = "自動大招時的目標數",
[">| Auto(R) ignores settings below and only checks for X targets"] = ">| 自動大招會在有X個目標時才釋放",
["> General settings:"] = "> 常規設置",
["Delay the ultimate for more CC"] = "延遲大招釋放以延長團控時間",
["DelayTime "] = "延遲時間",
["Use (Q) while ulting"] = "當放大時使用Q",
["Use Ultimate under towers"] = "在塔下使用大招",
["> Target settings:"] = "> 目標設置",
["No supported targets found/available"] = "沒有找到有效目標",
["> Advanced settings:"] = "> 高級設置:",
["Check for target health"] = "檢查目標的血量",
["Only ult if target health below < %"] = "只在目標生命值小於%時使用大招",
["Check for our health"] = "檢查自己的血量",
["Only ult if our health bigger > %"] = "只在自己生命值大於%時使用大招",
["General-Settings"] = "常規設置",
["Orbwalker Enabled"] = "啟用走砍",
["Allow casts only for targets in camera"] = "只在目標在屏幕上時允許使用技能",
["Windwall only if your hero is on camera"] = "只在你的英雄在屏幕上時使用風牆",
["> Packet settings:"] = "> 封包設置",
["Limit packets to human level"] = "> 限制封包在人類的操作水平",
[">> General settings"] = ">> 常規設置",
["Choose combo mode"] = "選擇連招模式",
["Prefer Q3-E"] = "優先Q3-E",
["Prefer E-Q3"] = "優先E-Q3",
["Use items in Combo"] = "在連招中使用物品",
[">> Choose your abilities"] = ">> 選擇你的技能",
["(Q) - Use Steel Tempest"] = "使用Q",
["(Q3) - Use Empowered Tempest"] = "使用帶旋風的Q",
["(E) - Use Sweeping Blade"] = "使用E",
["(R) - Use Last Breath"] = "使用R",
["Choose mode"] = "選擇模式",
["1) Normal harass"] = "1)普通騷擾",
["2) Safe harass"] = "2)安全騷擾",
["3) Smart E-Q-E Harass"] = "3)智能E-Q-E騷擾",
["Enable smart lasthit if no target"] = "啟用智能尾刀如果沒有目標",
["Enable smart lasthit if target"] = "啟用只能尾刀如果有目標",
["|> Smart lasthit will use spellsettings from the lasthitmenu"] = "|> 智能尾刀會使用尾刀菜單里的技能設置",
["|> Mode 1 will simply harass your enemy with spells"] = "|> 模式1會簡單的用技能騷擾敵方",
["|> Mode 2 will harass your enemy and e back if possible"] = "|> 模式2會騷擾敵方並且如果可能的話E回來",
["|> Mode 3 will engage with e - harass and e back if possible"] = "|> 模式3會給E充能並騷擾對面再E回來",
["Use Smart Killsteal"] = "使用智能搶人頭",
["Use items for Laneclear"] = "在清線時使用物品",
["Choose laneclear mode for (E)"] = "選擇E清線的模式",
["Only lasthit with (E)"] = "只用E補尾刀",
["Use (E) always"] = "總是使用E",
["Choose laneclear mode for (Q3)"] = "選擇帶旋風的Q的清線模式",
["Cast to best pos"] = "在最佳位置釋放",
["Cast to X or more amount of units "] = "當大於等於X個單位時釋放",
["Min units to hit with (Q3)"] = "使用Q3時的最小單位數",
["Check health for using (E)"] = "使用E前檢查血量",
["Only use (E) if health > %"] = "只在生命值大於%時使用E",
[">> Choose your spinsettings"] = ">> 選擇環形Q設置",
["Prioritize spinning (Q)"] = "優先環形Q",
["Prioritize spinning (Q3)"] = "優先環形Q3",
["Min units to hit with spinning"] = "環形Q能擊中的最小單位數",
["Use items to for Jungleclear"] = "清野時使用物品",
["Choose Prediction mode"] = "選擇預判模式",
[">> VPrediction"] = ">> V預判",
["Hitchance of (Q): "] = "Q命中的機會",
["Hitchance of (Q3): "] = "Q3命中的機會",
[">> HPrediction"] = ">> H預判",
[">> Found Summonerspells"] = ">> 召喚師技能",
["No supported spells found"] = "沒有找到支持的召喚師技能",
["Disable ALL drawings of the script"] = "關閉此腳本的所有顯示",
["Draw spells only if not on cooldown"] = "只顯示就緒的技能線圈",
["Draw fps friendly circles"] = "使用不影響fps的線圈",
["Choose strength of the circle"] = "選擇線圈的質量",
["> Other settings:"] = "> 其他設置",
["Draw airborne targets"] = "顯示被擊飛的目標",
["Draw remaining (Q3) time"] = "顯示Q3剩餘時間",
["Draw damage on Healthbar: "] = "在血條上顯示傷害",
["> Draw range of spell"] = "> 顯示技能範圍",
["Draw (Q): "] = "顯示Q",
["Draw (Q3): "] = "顯示Q3",
["Draw (E): "] = "顯示E",
["Draw (W): "] = "顯示W",
["Draw (R): "] = "顯示R",
["> Draw color of spell"] = "> 顯示線圈的顏色",
["(Q) Color:"] = "Q顏色",
["(Q3) Color:"] = "Q3顏色",
["(W) Color:"] = "W顏色",
["(E) Color:"] = "E顏色",
["(R) Color:"] = "R顏色",
["Healthbar Damage Drawings: "] = "血條傷害顯示",
["Startingheight of the lines: "] = "指示線高度",
["Draw smart (Q)+(E)-Damage: "] = "顯示智能Q+E傷害",
["Draw (Q)-Damage: "] = "顯示Q傷害",
["Draw (Q3)-Damage: "] = "顯示Q3傷害",
["Draw (E)-Damage: "] = "顯示E傷害",
["Draw (R)-Damage: "] = "顯示R傷害",
["Draw Ignite-Damage: "] = "顯示點燃傷害",
["Permashow: "] = "狀態顯示:",
["Permashow HarassToggleKey "] = "顯示騷擾開關按鍵",
["Permashow UltimateToggleKey"] = "顯示大招開關按鍵",
["Permashow Autowall Key"] = "顯示自動風牆按鍵",
["Permashow Prediction"] = "顯示預判狀態",
["Permashow Walljump"] = "顯示風牆狀態",
["Permashow HarassMode"] = "顯示騷擾模式",
[">| You need to reload the script (2xF9) after changes here!"] = ">| 修改此處設置後你需要F9兩次",
["> Healthpotions:"] = "> 自動血葯",
["Use Healthpotions"] = "使用血瓶",
["if my health % is below"] = "如果自己生命值低於%",
["Only use pots if enemys around you"] = "只在附近有敵人的時候自動使用藥水",
["Range to check"] = "檢查範圍",
------------------------神聖意識-------------------------
["Divine Awareness"] = "神聖意識",
["Debug Settings"] = "調試設置",
["Colors"] = "顏色",
["Stealth/sight wards/stones/totems"] = "隱形單位/眼/眼石/飾品",
["Vision wards/totems"] = "顯示眼位",
["Traps"] = "陷阱",
["Key Bindings"] = "鍵位設置",
["Wards/Traps Range (DEFAULT IS ~ KEY)"] = "眼位/陷阱範圍(默認是~鍵)",
["Enemy Vision (default ~)"] = "敵方視野(默認是~鍵)",
["Timers Call (default CTRL)"] = "計時器(默認Ctrl鍵)",
["Mark Wards and Traps"] = "標記眼位和陷阱",
["Mark enemy flashes/dashes/blinks"] = "標記敵人的閃現/突進技能",
["Towers"] = "防禦塔",
["Draw enemy tower ranges"] = "畫出敵人塔範圍",
["Draw ally tower ranges"] = "畫出友方塔範圍",
["Draw tower ranges at distance"] = "在一定距離內才顯示塔範圍",
["Timers"] = "計時器",
["Display Jungle Timers"] = "顯示打野計時",
["Display Inhibitor Timers"] = "顯示水晶計時",
["Display Health-Relic Timers"] = "顯示據點計時",
["Way Points"] = "路徑顯示",
["Draw enemy paths"] = "顯示敵人的路線",
["Draw ally paths"] = "顯示友軍的路線",
["Draw last-seen champ map icon"] = "在小地圖顯示敵人最後一次出現的位置",
["Draw enemy FoW minions line"] = "顯示戰爭迷霧裡的兵線",
["Notification Settings"] = "提示設置",
["Gank Prediction"] = "Gank預測",
["Feature"] = "特點",
["Play alert sound"] = "播放提示音",
["Add to screen text alert"] = "在屏幕顯示提示文字",
["Draw screen notification circle"] = "在屏幕顯示提示線圈",
["Print in chat (local) a gank notification"] = "在聊天框顯示gank提示(本地的)",
["FoW Camps Attack"] = "戰爭迷霧伏擊",
["Log to Chatbox."] = "登陸ChatBox",
["Auto SS caller / Pinger"] = "敵人消失自動提醒/標記",
["Summoner Spells and Ult"] = "召喚師技能和大招",
["Send timers to chat"] = "將計時器發送到聊天框",
["Key (requires cursor over tracker)"] = "按鍵(需要鼠標移動至cd監視器)",
["On FoW teleport/recall log client-sided chat notification"] = "聊天框提醒戰爭迷霧裡的傳送/回城",
["Cooldown Tracker"] = "cd監視",
["HUD Style"] = "HUD風格",
["Chrome [Vertical]"] = "Chrome[垂直的]",
["Chrome [Horizontal] "] = "Chrome[水平的]",
[" Classic [Vertical]"] = "經典 [垂直的]",
["Classic [Horizontal]"] = "經典 [水平的]",
["Lock Side HUDS"] = "鎖定HUD",
["Show Allies Side CD Tracker"] = "顯示友方的cd",
["Show Enemies Side CD Tracker"] = "顯示敵方的cd",
["Show Allies Over-Head CD Tracker"] = "顯示友軍頭頂的cd",
["Show Enemies Over-Head CD Tracker"] = "顯示敵方頭頂的cd",
["Include me in tracker"] = "顯示自己的cd",
["Cooldown Tracker Size"] = "cd計時器大小",
["Reload Sprites (default J)"] = "重新加載圖片(默認J)",
["Enable Scarra Warding Assistance"] = "啟用插眼助手",
["Automations"] = "自動",
--["Lantern Grabber"] = "自動撿燈籠",
["Max Radius to trigger"] = "觸發的最大半徑",
["Hotkey to trigger"] = "觸發的按鍵",
["Allow automation based on health"] = "取決於生命值的自動",
["Auto trigger when health% < "] = "當生命值小於%時自動觸發",
["Enable BaseHit"] = "啟用基地大招",
["Auto Level Sequence"] = "自動加點順序",
["Auto Leveling"] = "自動加點",
["Vision ward on units stealth spells"] = "自動插真眼反隱",
["Voice Awareness"] = "語音提示",
["Mode"] = "模式",
["Real"] = "真人聲音",
["Robot"] = "機器人聲音",
["Gank Alert Announcement"] = "Gank提示",
["Recall/Teleport Announcement"] = "回城/傳送提示",
["Compliments upon killing a champ"] = "殺敵之後的稱讚",
["Motivations upon dying"] = "死亡之後的鼓舞",
["Camp 1 min respawn reminder"] = "水晶1分鐘復活提醒",
["Base Hit Announcement"] = "基地大招提示",
["FoW  Camps Attack Alert"] = "在戰爭迷霧中的攻擊警告",
["Evade Assistance"] = "躲避助手",
["Patch "] = "版本",
-----------------------Better Nerf卡牌----------------
["[Better Nerf] Twisted Fate"] = "[Better Nerf] 卡牌大師",
["[Developer]"] = "[開發者]",
["Donations are fully voluntary and highly appreciated"] = "捐助是完全自願的,並且我們非常感謝捐助",
["[Orbwalker]"] = "[走砍]",
["Lux"] = "拉克絲",
["[Targetselector]"] = "[目標選擇器]",
["[Prediction]"] = "[預判]",
["Extra delay"] = "額外延遲",
["Auto adjust delay (experimental)"] = "自動調整延遲(測試)",
["[Performance]"] = "[性能設置]",
["Limit ticks"] = "限制按鍵次數",
["Checks per second"] = "每秒檢查",
["[Card Picker]"] = "[切牌器]",
["Enable"] = "啟用",
["Gold"] = "黃牌",
["[Ultimate]"] = "[大招]",
["Cast predicted Ultimate through sprite"] = "通過小地圖使用預判大招",
["Adjust R range"] = "調整R範圍",
["Pick card when porting with Ultimate"] = "大招傳送時選牌",
["[Combo]"] = "[連招]",
["Logic"] = "邏輯",
["[Wild Cards]"] = "[萬能牌(Q)]",
["Stunned"] = "眩暈",
["Hitchance"] = "命中幾率",
["Ignore Logic if enemy closer <"] = "敵軍距離小於x時不使用連招邏輯",
["Max Distance"] = "最大距離",
["[Pick a Card]"] = "[選牌(W)]",
["Card picker"] = "切牌器",
["Pick card logic"] = "選牌邏輯",
["Distance check"] = "距離檢測",
["Pick red, if hit more than 1"] = "如果能擊中多於一個敵人就切紅牌",
["Pick Blue if mana is below %"] = "如果藍量低於%就切藍牌",
[" > Use (Q) - Wild Cards"] = " > 使用Q - 萬能牌",
[" > Use (W) - Pick a Card"] = "> 使用W - 選牌",
["Don't combo if mana < %"] = "如果藍量低於%不使用連招",
["[Harass]"] = "[騷擾]",
["Harass #1"] = "騷擾 #1",
["Don't harass if mana < %"] = "藍量低於%時不騷擾",
["[Farm]"] = "[發育]",
["Card"] = "切牌",
["Clear!"] = "清線",
["Don't farm with Q if mana < %"] = "藍量低於%時不使用Q",
["Don't farm with W if mana < %"] = "藍量低於%時不使用W",
["[Jungle Farm]"] = "[清野]",
["Jungle Farm!"] = "清野!",
["[Draw]"] = "[顯示設置]",
["[Hitbox]"] = "[命中體積]",
["Color"] = "顏色",
["Quality"] = "質量",
["Width"] = "寬度",
["[Q - Wild Cards]"] = "Q -萬能牌",
["Ready"] = "就緒",
["Draw mode"] = "顯示模式",
["Default"] = "默認",
["Highlight"] = "高亮",
["[W - Pick a Card]"] = "[W - 選牌]",
["[E - Stacked Deck]"] = "[E - 卡牌騙術]",
["Text"] = "文字",
["Sprite"] = "圖片",
["[TEXT]"] = "[文字]",
["[SPRITE]"] = "[圖片]",
["Color Stack 1-3"] = "顏色疊加 1-3",
["Color Stack 4"] = "顏色疊加 4",
["Color Background"] = "顏色背景",
--["[R - Destiny]"] = "[R - 命運]",
["Enable Minimap"] = "在小地圖上啟用顯示",
["Draw Sprite Panel"] = "顯示控制面板",
["Draw Alerter Text"] = "顯示提醒文字",
["Draw click hitbox"] = "顯示點擊命中體積",
["Adjust width"] = "調整寬度",
["Adjust height"] = "調整高度",
["[Damage HP Bar]"] = "[血條傷害顯示]",
["Draw damage info"] = "顯示傷害信息",
["Color Text"] = "文字顏色",
["Color Bar"] = "血條顏色顏色",
["Color near Death"] = "接近死亡的顏色",
["None"] = "無",
["Pause Movement"] = "暫停移動",
["AutoCarry Mode"] = "自動連招輸出模式",
["Target Lock Current Target"] = "鎖定當前目標",
["Target Lock Selected Target"] = "鎖定選定目標",
["Method 2"] = "方式2",
["Method 3"] = "方式3",
["Color Kill"] = "可以擊殺的顏色",
["Calc x Auto Attacks"] = "計算平A次數",
["Lag-Free-Circles"] = "不影響延遲的線圈",
["Disable all Draws"] = "關閉所有的顯示",
["[Killsteal]"] = "[搶人頭]",
["Use Wild Cards"] = "使用Q",
["[Misc]"] = "[雜項設置]",
["[Rescue Pick]"] = "[保命選牌]",
["time"] = "時間",
["factor"] = "因素",
["[Auto Q immobile]"] = "[不能移動時自動Q]",
["Don't Q Lux"] = "不要對拉克絲使用Q",
["[Debug]"] = "[調試]",
["Spell Data"] = "技能數據",
["Prediction / minion hit"] = "預判 / 擊中小兵",
["TargetSelector Mode"] = "目標選擇器模式",
["LESS CAST"] = "更少使用技能",
["LESS CAST PRIORITY"] = "更少使用技能+優先級",
["NEAR MOUSE"] = "離鼠標最近",
["Priority"] = "優先級",
["NearMouse"] = "離鼠標附近",
["MOST AD"] = "AD最高",
["MostAD"] = "AD最高",
["MOST AP"] = "AP最高",
["MostAP"] = "AP最高",
["Damage Type"] = "傷害類型",
["MAGICAL"] = "魔法",
["PHYSICAL"] = "物理",
["Range"] = "範圍",
["Draw for easy Setup"] = "容易設置的顯示模式",
["Draw target"] = "顯示目標",
["Circle"] = "線圈",
["ESP BOX"] = "ESP盒子",
["Blue"] = "藍色",
["Red"] = "紅色",
-----------------------滾筒機器薇恩-------------------------
["Tumble Machine Vayne"] = "滾筒機器 VN",
["Enable Packet Features"] = "啟用封包",
["Combo Settings"] = "連招設置",
["AA Reset Q Method"] = "Q重置普通的方式",
["Forward and Back Arcs"] = "向前或向後Q",
["Everywhere"] = "任何位置",
["Use gap-close Q"] = "使用Q接近敵人",
["Use Q in Combo"] = "在連招中使用Q",
["Use E in Combo"] = "在連招中使用E",
["Use R in Combo"] = "在連招中使用R",
["Ward bush loss of vision"] = "敵人進草時自動插眼",
["Harass Settings"] = "騷擾設置",
["Use Harass Mode during: "] = "使用騷擾模式：",
["Harass Only"] = "只騷擾",
["Both Harass and Laneclear"] = "騷擾和清線",
["Forward Arc"] = "向前時",
["Side to Side"] = "從敵人一側到另一側",
["Old Side Method"] = "舊版本策略",
["Use Q in Harass"] = "在騷擾中使用Q",
["Use E in Harass"] = "在騷擾中使用E",
["Spell Settings"] = "技能設置",
["Q Settings"] = "Q技能設置",
["Use AA reset Q"] = "使用Q重置普攻",
["      ON"] = "開",
["ON: 3rd Proc"] = "第三次普攻",
["Use gap-close Q - Burst Harass"] = "使用Q接近 - 爆發騷擾模式",
["E Settings"] = "E技能設置",
["Use E Finisher"] = "使用E擊殺",
["Don't E KS if # enemies near is >"] = "當附近敵人大於x時不要用E搶人頭",
["Don't E KS if level is >"] = "當等級大於x時不要用E搶人頭",
["E KS if near death"] = "如果瀕死使用E搶人頭",
["Calculate condemn-flash at:"] = "使用E閃：",
["Mouse Flash Position"] = "以鼠標位置為閃現位置",
["All Possible Flash Positions"] = "所有可能的閃現位置",
["R Settings"] = "R技能設置",
["Stay invis long as possible"] = "儘可能長時間的保持隱身狀態",
["Stay invis min enemies"] = "保持隱身狀態的最小敵人數",
["    Activate R"] = "自動R",
["R min enemies to use"] = "使用R的最小敵人數",
["Use R if Health% <="]	= "如果生命值小於等於%",
["Use R if in danger"] = "在危險情況下使用R",
["Use Q after R if danger"] = "在危險情況下使用RQ隱身",
["Special Condemn Settings"] = "特殊擊退設置",
["Anti-Gap Close Settings"] = "反突進設置",
["Enable"] = "啟用",
["Interrupt Settings"] = "打斷設置",
["Tower Insec Settings"] = "防禦塔Insec設置",
["Make Key Toggle"] = "使用按鍵開關",
["Max Enemy Minions (1)"] = "最大敵方小兵數",
["Max Range From Tower"] = "離塔的最大距離",
["Use On:"] = "使用的對象：",
["Target"] = "目標",
["Anyone"] = "任何人",
["Frequency:"] = "使用頻率",
["More Often"] = "更頻繁",
["More Accurate"] = "更精準",
["Q and Flash Usage:"] = "Q和閃現的使用",
["Q First"] = "先Q",
["Flash First"] = "先閃現",
["Never Use Q"] = "從不使用Q",
["Never Use Flash"] = "從不使用閃現",
["Wall Condemn Settings"] = "定牆設置",
["Use on Lucian"] = "對盧錫安使用",
["   If enemy health % <="] = "   如果敵人生命值小於<",
["Use wall condemn on"] = "使用定牆的對象",
["All listed"] = "所有列表裡的目標",
["Use wall condemn during:"] = "以下情況下使用定牆",
["Combo and Harass"] = "連招和騷擾",
["Always On"] = "總是使用",
["Wall condemn accuracy"] = "定牆精準度",
["     Jungle Settings"] = "     清野設置",
["Use Q-AA reset on:"] = "以下情況使用Q重置普攻",
["All Jungle"] = "所有野怪",
["Large Monsters Only"] = "只是大型野怪",
["Wall Stun Large Monsters"] = "對大型野怪使用定牆",
["Disable Wall Stun at Level"] = "在等級x時禁用定牆",
["Jungle Clear Spells if Mana >"] = "如果藍量大於x時才使用清野",
["     Lane Settings"] = "     清線設置",
["Q Method:"] = "Q使用方式",
["Lane Clear Q:"] = "清線中使用Q",
["Dash to Mouse"] = "位移至鼠標方向",
["Dash to Wall"] = "位移至牆",
["Lane Clear Spells if Mana >"] = "在清線中使用技能如果藍量大於%",
["Humanize Clear Interval (Seconds)"] = "擬人化清線間隔(秒)",
["Tower Farm Help (Experimental)"] = "塔下發育助手(測試)",
["Item Settings"] = "物品設置",
["Offensive Items"] = "進攻型物品",
["Use Items During"] = "在以下情況使用",
["Combo and Harass Modes"] = "連招和騷擾模式",
["If My Health % is Less Than"] = "如果生命值低於%",
["If Target Health % is Less Than"] = "如果目標生命值低於%",
["QSS/Cleanse Settings"] = "水銀/凈化設置",
["Remove CC during: "] = "以下情況凈化團控技能",
["Remove Exhaust"] = "凈化虛弱",
["QSS Blitz Grab"] = "凈化機器人的勾",
["Humanizer Delay (ms)"] = "人性化延遲(毫秒)",
["Use HP Potions During"] = "以下情況使用血葯",
["Use HP Pot If Health % <"] = "生命值低於%使用血葯",
["Damage Draw Settings"] = "傷害顯示設置",
["Draw E DMG on bar:"] = "在血條顯示E的傷害",
["Ascending"] = "上升",
["Descending"] = "下降",
["Draw E Text:"] = "顯示E技能提示文字",
["Percentage"] = "百分比",
["Number"] = "數字",
["AA Remaining"] = "擊殺剩餘平A數",
["Grey out health"] = "灰色傷害溢出",
["Disable All Range Draws"] = "關閉所有範圍顯示",
["Draw Circle on Target"] = "在目標上顯示線圈",
["Draw AA/E Range"] = "顯示平A/E範圍",
["Draw My Hitbox"] = "顯示自己的命中體積",
["Draw (Q) Range"] = "顯示Q的範圍",
["Draw Passive Stacks"] = "顯示被動層數",
["Draw Ult Invis Timer"] = "顯示大招隱身計時器",
["Draw Attacks"] = "顯示攻擊",
["Draw Tower Insec"] = "顯示防禦塔Insec",
["While Key Pressed"] = "當按鍵按下時",
["Enable Streaming Mode (F7)"] = "啟用流模式(F7)",
["General Settings"] = "常規設置",
["Auto Level Spells"] = "自動加點",
["Disable auto-level for first level"] = "在1級時關閉自動加點",
["Level order"] = "加點順序",
["First 4 Levels Order"] = "前4級加點順序",
["Display alert messages"] = "顯示警告信息",
["Left Click Focus Target"] = "左鍵點擊鎖定目標",
["Off"] = "關閉",
["Permanent"] = "永久的",
["For One Minute"] = "持續一分鐘",
["Target Mode:"] = "目標選擇模式:",
["Easiest to kill"] = "最容易擊殺",
["Less Cast Priority"] = "更少使用技能+優先級",
["Don't KS shield casters"] = "不要對有護盾技能的目標使用搶人頭",
["Get to lane faster"] = "上線更快",
["Double Edge Sword Mastery?"] = "雙刃劍天賦",
["No"] = "否",
["Yes"] = "是",
["Turn on Debug"] = "打開調試模式",
["Orbwalking Settings"] = "走砍設置",
["Keybindings"] = "鍵位設置",
["Escape Key"] = "逃跑按鍵",
["Burst Harass"] = "爆發騷擾連招",
["Condemn on Next AA (Toggle)"] = "下次平A推開目標(開關)",
["Flash Condemn"] = "閃現E",
["Disable Wall Condemn (Toggle)"] = "關閉定牆(開關)",
["   Use custom combat keys"] = "   使用習慣的戰鬥按鍵",
["Click For Instructions"] = "點擊指令",
["Select Skin"] = "選擇皮膚",
["Original Skin"] = "經典皮膚",
["Vindicator Vayne"] = "摩登駭客 薇恩",
["Aristocrat Vayne"] = "獵天使魔女 薇恩",
["Heartseeker Vayne"] = "覓心獵手 薇恩",
["Dragonslayer Vayne - Red"] = "屠龍勇士 薇恩 - 紅色",
["Dragonslayer Vayne - Green"] = "屠龍勇士 薇恩 - 綠色",
["Dragonslayer Vayne - Blue"] = "屠龍勇士 薇恩 - 藍色",
--["Dragonslayer Vayne - Light Blue"] = "屠龍勇士 薇恩 - 淺藍色",
["SKT T1 Vayne"] = "SKT T1 薇恩",
["Arc Vayne"] = "蒼穹之光 薇恩",
["Snow Bard"] = "冰雪游神 巴德",
["No Gap Close Enemy Spells Detected"] = "沒有檢測到敵人的突進技能",
["Lucian Ult - Enable"] = "盧錫安大招 - 啟用",
["     Humanizer Delay (ms)"] = "     擬人化延遲(毫秒)",
["Teleport - Enable"] = "傳送 - 啟用",
["Choose Free Orbwalker"] = "選擇免費走砍",
["Nebelwolfi's Orbwalker"] = "Nebelwolfi走砍",
["Modes"] = "模式",
["Attack"] = "攻擊",
["Move"] = "移動",
["LastHit Mode"] = "尾刀模式",
["Attack Enemy on Lasthit (Anti-Farm)"] = "敵人尾刀時攻擊(阻止敵人發育)",
["LaneClear Mode"] = "清線模式",
["                    Mode Hotkeys"] = "                    模式熱鍵",
[" -> Parameter mode:"] = "-> 參數模式",
["On/Off"] = "開/關",
["KeyDown"] = "按住按鍵",
["KeyToggle"] = "開關按鍵",
["                    Other Hotkeys"] = "                    其他熱鍵",
["Left-Click Action"] = "左鍵動作",
["Lane Freeze (F1)"] = "猥瑣補刀(F1)",
["Settings"] = "設置",
["Sticky radius to mouse"] = "停止不動的區域半徑",
["Low HP"] = "低血量",
["Most AP"] = "AP最高",
["Most AD"] = "AD最高",
["Less Cast"] = "更少使用技能",
["Near Mouse"] = "離鼠標最近",
["Low HP Priority"] = "低血量+優先級",
["Dead"] = "死亡的",
["Closest"] = "最近的",
["Blade of the Ruined King"] = "破敗王者之刃",
["Bilgewater Cutlass"] = "比爾吉沃特彎刀",
["Hextech Gunblade"] = "海克斯科技槍刃",
["Ravenous Hydra"] = "貪慾九頭蛇",
["Titanic Hydra"] = "巨型九頭蛇",
["Tiamat"] = "提亞馬特",
["Entropy"] = "冰霜戰錘",
["Yomuu's Ghostblade"] = "幽夢之靈",
["Farm Modes"] = "發育模式",
["Use Tiamat/Hydra to Lasthit"] = "使用提亞馬特/九頭蛇尾刀",
["Butcher"] = "屠夫",
["Arcane Blade"] = "雙刃劍",
["Havoc"] = "毀滅",
["Advanced Tower farming (experimental"] = "高級塔下發育模式(測試)",
["LaneClear method"] = "清線方式",
["Highest"] = "最高效率",
["Stick to 1"] = "鎖定一個小兵",
["Draw LastHit Indicator (LastHit Mode)"] = "顯示尾刀指示器(尾刀模式)",
["Always Draw LastHit Indicator"] = "總是顯示尾刀指示器",
["Lasthit Indicator Style"] = "尾刀指示器樣式",
["New"] = "新",
["Old"] = "舊",
["Show Lasthit Indicator if"] = "以下情況顯示尾刀指示器",
["1 AA-Kill"] = "一次平A擊殺",
["2 AA-Kill"] = "兩次平A擊殺",
["3 AA-Kill"] = "三次平A擊殺",
["Own AA Circle"] = "自己的平A線圈",
["Enemy AA Circles"] = "敵人的平A線圈",
["Lag Free Circles"] = "不影響延遲的線圈",
["Draw - General toggle"] = "顯示 - 常規開關",
["Timing Settings"] = "計時設置",
["Cancel AA adjustment"] = "取消平A後搖調整",
["Lasthit adjustment"] = "尾刀調整",
["Version:"] = "版本:",
["Combat keys are located in orbwalking settings"] = "戰鬥按鍵在走砍里設置",
-----------------------時間機器艾克--------------
["Time Machine Ekko"] = "時間機器 艾克",
["Skin Changer"] = "皮膚切換",
["Sandstorm Ekko"] = "時之砂 艾克",
["Academy Ekko"] = "任性學霸 艾克",
["Use Q combo if  mana is above"] = "如果藍量高於x使用Q連招",
["Use E combo if  mana is above"] = "如果藍量高於x使用E連招",
["Use Q Correct Dash if mana >"] = "如果藍量高於x使用E修正二段Q的方向",
["Reveal enemy in bush"] = "對草叢裡的敵人自動插眼",
["Use Target W in Combo"] = "在連招中有目的性的使用W",
["W if it can hit X "] = "如果能擊中X個敵人使用R",
["Use Q harass if  mana is above"] = "如果藍量高於x使用Q騷擾",
["Harass Q last hit and hit enemy"] = "騷擾中使用Q補尾刀以及擊中敵人",
["Auto-move to hit 2nd Q in Combo"] = "自動移動來使二段Q命中",
["On"] = "開",
["On and Draw"] = "打開並顯示",
["Long Range W Engage"] = "戰鬥中使用遠距離W",
["Long Range Before E Engage"] = "戰鬥中在E之前使用遠距離W",
["During E Engage"] = "戰鬥使用E的時候",
["Use W on CC or slow"] = "使用W來打團控或者群體減速",
["Don't use E in AA range unless KS"] = "敵人在平A範圍內時除了搶人頭不要使用E",
["Offensive Ultimate Settings"] = "進攻性大招設置",
["Ult Target in Combo if"] = "以下情況在連招中使用大招",
["Target health % below"] = "目標生命值低於%",
["My health % below"] = "自己生命值低於%",
["Ult if 1 enemy is killable"] = "如果有1名敵人可擊殺時使用R",
["Ult if 2 or more"] = "如果有2名或更多敵人可擊殺時使用R",
["will go below 35% health"] = "會在血量低於35%的時候觸發",
["Ult if set amount"] = "如果到達設定數值則使用R",
["will get hit"] = "即將收到攻擊",
["Offensive Ult During:"] = "以下情況使用進攻性大招",
["Combo Only"] = "只在連招里使用",
["Block ult in combo mode if ult won't hit"] = "如果大招不能擊中則不在連招中使用大招",
["Defensive Ult/Zhonya Settings"] = "防禦性大招/中亞設置",
["Use if about to die"] = "瀕死時使用",
["Only Defensive Ult if my"] = "如果自身情況滿足..則使用防禦性大招",
["health is less than targets"] = "生命值低於目標生命值",
["Ult if heal % is >"] = "大招治療生命值高於%時使用R",
["Defensive Ult During:"] = "以下情況使用防禦性大招：",
["Wave Clear Settings"] = "清線設置",
["Use Q in Wave Clear"] = "使用Q清線",
["Scenario 1:"] = "方案 1：",
["Minimum lane minions to hit "] = "至少擊中的小兵數",
["Use Q if  mana is above"] = "如果藍量高於x時使用Q",
["Must hit enemy also"] = "必須同時擊中敵人",
["Scenario 2:"] = "方案 2：",
["---Jungle---"] = "---清野設置---",
["Use W in Jungle Clear"] = "使用W清野",
["Use E in Jungle Clear"] = "使用E清野",
["Escape Settings"] = "逃跑設置",
["Cast W direction you are heading"] = "向你面朝的方向使用W",
["Draw (W) Max Reachable Range"] = "顯示能到達的W最大範圍",
["Draw (E) Range"] = "顯示E技能範圍",
["Draw (R) Range"] = "顯示R技能範圍",
["Draw Line to R Spot"] = "在R的地點畫指示線",
["Draw Passive Stack Counters"] = "顯示被動層數指示器",
["Display ult hit count"] = "顯示大招能擊中的敵人數",
["Draw Tower Ranges"] = "顯示防禦塔範圍",
["Damage Drawings"] = "顯示傷害",
["Enable Bar Drawings"] = "啟用血條傷害顯示",
["Separated"] = "分離的",
["Combined"] = "一體的",
["Draw Bar Letters"] = "在血條上顯示技能字母",
["Draw Bar Shadows"] = "顯示血條陰影",
["Draw Bar Kill Text"] = "顯示血條擊殺提示",
["Draw (Q) Damage"] = "顯示Q的傷害",
["Draw (E) Damage"] = "顯示E的傷害",
["Draw (R) Damage"] = "顯示R的傷害",
["Draw (I) Ignite Damage"] = "顯示I(點燃)的傷害",
["Q Helper"] = "Q技能助手",
["Enable Q  Helper"] = "啟用Q技能助手",
["Draw Box"] = "顯示方框",
["Draw Minion Circles"] = "在小兵上顯示線圈",
["Draw Enemy Circles"] = "在敵人上顯示線圈",
["Item/Smite Settings"] = "物品/懲戒設置",
["Offensive Smite"] = "進攻性懲戒",
["Use Champion Smite During"] = "在以下情況對英雄使用懲戒",
["Combo and Lane Clear"] = "連招和清線",
["Use Smart Ignite"] = "使用智能點燃",
["Optimal"] = "最佳時機",
["Aggressive"] = "侵略性的",
["Prediction Method:"] = "預判方式:",
["Divine Prediction"] = "神聖預判",
["Make sure these are on unique keys"] = "確保以下按鍵是獨立的",
["Wave Clear Key"] = "清線按鍵",
["Jungle KS Key"] = "清野/搶人頭按鍵",
["Use on ShenE"] = "對慎的E使用",
["      Enable"] = "      啟用",
["      Health % < "] = "      生命值低於%",
------------------------Raphlol女槍小炮--------------
["Ralphlol: Miss Fortune"] = "Raphlol:女槍",
["Use W if  mana is above"] = "藍量高於x時使用W",
["Use E if  mana is above"] = "藍量高於x時使用E",
["Use Q bounce in Combo"] = "在連招中使用Q彈射敵人",
["Use W in Combo"] = "在連招中使用W",
["Use E more often in Combo"] = "在連招中更頻繁地使用E",
["(Q) to Minions"] = "Q小兵",
["Ignore High Health Tanks"] = "忽略高血量的坦克/肉盾",
["Only (Q) minions that will die"] = "只對能Q死的小兵使用Q",
["Use Harass also during Lane Clear"] = "在清線的時候依然騷擾對面",
["Use Q bounce in Harass"] = "在騷擾中使用Q彈射",
["Use W in Harass"] = "在騷擾中使用W",
["Ultimate Settings"] = "大招設置",
["Auto Ult During"] = "以下情況使用自動大招",
["Use Ult if X enemy hit"] = "如果能擊中x名敵人使用自動大招",
["Use Ult if target will die"] = "如果目標能擊殺時使用自動大招",
["Use on stunned targets"] = "對被眩暈的目標使用",
["Only AutoUlt if CC Nearby <="]= "如果附近的團控小於等於X使用自動大招",
["Cancel Ult if no more enemies inside"] = "如果R範圍內沒有敵人則取消大招",
["Cancel Ult when you right click"] = "當你點擊右鍵的時候取消大招",
["Block Ult cast if it will miss"] = "如果大招打不中的話就屏蔽大招釋放",
["(Shift Override)"] = "(覆蓋Shift)",
["Clear Settings"] = "清線設置",
["Jungle Clear Settings"] = "清野設置",
["Use Q in Jungle Clear"] = "在清野中使用Q",
["Show notifications"] = "顯示提示信息",
["Show CC Counter"] = "顯示團控計數",
["Show Q Bounce Counter"] = "顯示Q彈射計數",
["Draw (Q) Arcs"] = "顯示Q彈射的範圍",
["Draw (Q) Killable Minions"] = "顯示Q能擊殺的小兵",
["(R) Damage Drawing"] = "顯示R的傷害",
["Minimum Duration"] = "最小持續時間",
["Full Duration"] = "最大持續時間",
["Assisted (E) Key"] = "輔助E按鍵",
["Assisted (R) Key"] = "輔助R按鍵",
["Ralphlol: Tristana"] = "Raphlol:小炮",
["E Harass White List"] = "E騷擾敵人列表",
["Use on Brand"] = "對布蘭德使用",
["Enable Danger Ultimate"] = "啟用危險時自動大招",
["Use on self"] = "對自己使用",
["Anti-Gap Settings"] = "反突進設置",
["Draw AA/R/E Range"] = "顯示平A/R/E的範圍",
["Draw (W) Range"] = "顯示W範圍",
["Draw (W) Spot"] = "顯示W的落地點",
["All-In Key "] = "全力輸出按鍵",
["Assisted (W) Key"] = "輔助W按鍵",
["(E) Wave Key"] = "E清線按鍵",
["Panic Ult Key"] = "保命大招按鍵",
-------------挑戰者中單合集---------------
["SimpleLib - Orbwalk Manager"] = "SimpleLib - 走砍管理器",
["Orbwalker Selection"] = "走砍選擇",
["SxOrbWalk"] = "Sx走砍",
["Big Fat Walk"] = "胖子走砍",
["Forbidden Ezreal by Da Vinci"] = "挑戰者中單合集 - 伊澤瑞爾",
["SimpleLib - Spell Manager"] = "SimpleLib - 技能管理器",
["Enable Packets"] = "使用封包",
["Enable No-Face Exploit"] = "使用開發者模式",
["Disable All Draws"] = "關閉所有顯示",
["Set All Skillshots to: "] = "將所有技能的預判調整為：",
["HPrediction"] = "H預判",
["DivinePred"] = "神聖預判",
["SPrediction"] = "S預判",
["Q Settings"] = "Q技能設置",
["Prediction Selection"] = "預判選擇",
["X % Combo Accuracy"] = "連招精準度X%",
["X % Harass Accuracy"] = "騷擾精準度X%",
["80 % ~ Super High Accuracy"] = "80% ~ 極高精準度",
["60 % ~ High Accuracy (Recommended)"] = "60% ~ 高精準度(推薦)",
["30 % ~ Medium Accuracy"] = "30% ~ 中精準度",
["10 % ~ Low Accuracy"] = "10% ~ 低精準度",
["Drawing Settings"] = "繪圖設置",
["Enable"] = "生效",
["Color"] = "顏色",
["Width"] = "寬度",
["Quality"] = "質量",
["W Settings"] = "W技能設置",
["E Settings"] = "E技能設置",
["R Settings"] = "R技能設置",
["Ezreal - Target Selector Settings"] = "[伊澤瑞爾] - 目標選擇器設置",
["Shen"] = "慎",
["Draw circle on Target"] = "在目標上畫圈",
["Draw circle for Range"] = "線圈範圍",
["Ezreal - General Settings"] = "[伊澤瑞爾] - 常規設置",
["Overkill % for Dmg Predict.."] = "傷害溢出判斷X%",
["Ezreal - Combo Settings"] = "[伊澤瑞爾] - 連招設置",
["Use Q"] = "使用Q",
["Use W"] = "使用W",
["Use R If Enemies >="]	= "如果敵人數量大於等於",
["Ezreal - Harass Settings"] = "[伊澤瑞爾] - 騷擾設置",
["Min. Mana Percent: "] = "最小藍量百分比：",
["Ezreal - LaneClear Settings"] = "[伊澤瑞爾] - 清線設置",
["Ezreal - LastHit Settings"] = "[伊澤瑞爾] - 尾刀設置",
["Smart"] = "智能",
["Min. Mana Percent:"] = "最小藍量設置",
["Ezreal - JungleClear Settings"] = "[伊澤瑞爾] - 清野設置",
["Ezreal - KillSteal Settings"] = "[伊澤瑞爾] - 搶人頭設置",
["Use E"] = "使用E",
["Use R"] = "使用R",
["Use Ignite"] = "使用點燃",
["Ezreal - Auto Settings"] = "[伊澤瑞爾] - 自動設置",
["Use E To Evade"] = "使用E技能躲避",
["Shen (Q)"] = "慎的Q",
["Shen (W)"] = "慎的W",
["Shen (E)"] = "慎的E",
["Shen (R)"] = "慎的R",
["Time Limit to Evade"] = "躲避時間限制",
["% of Humanizer"] = "擬人化程度X%",
["Ezreal - Keys Settings"] = "[伊澤瑞爾] - 按鍵設置",
["Use main keys from your Orbwalker"] = "使用你的走砍按鍵設置",
["Harass (Toggle)"] = "騷擾開關",
["Assisted Ultimate (Near Mouse)"] = "輔助大招(在鼠標附近)",
[" -> Parameter mode:"] = " -> 參數模式",
["On/Off"] = "開/關",
["KeyDown"] = "按鍵",
["KeyToggle"] = "按鍵開關",
["BioZed Reborn by Da Vinci"] = "挑戰者中單合集 - 劫",
["Zed - Target Selector Settings"] = "[劫] - 目標選擇器設置",
["Darius"] = "德萊厄斯",
["Zed - General Settings"] = "[劫] - 常規設置",
["Developer Mode"] = "開發者模式",
["Zed - Combo Settings"] = "[劫] - 連招設置",
["Use W on Combo without R"] = "不使用R時使用W",
["Use W on Combo with R"] = "使用R時使用W",
["Swap to W/R to gap close"] = "使用二段W/R接近敵人",
["Swap to W/R if my HP % <="] = "如果生命值小於等於X%時使用二段W/R",
["Swap to W/R if target dead"] = "使用二段W/R如果目標死亡",
["Use Items"] = "使用物品",
["If Killable"] = "如果能殺死",
["R Mode"] = "R模式",
["Line"] = "直線模式",
["Triangle"] = "三角模式",
["MousePos"] = "鼠標位置",
["Don't use R On"] = "不要對..使用R",
["Zed - Harass Settings"] = "[劫] - 騷擾設置",
["Check collision before casting q"] = "在使用Q之前檢查碰撞",
["Min. Energy Percent"] = "最小能量百分比",
["Zed - LaneClear Settings"] = "[劫] - 清線設置",
["Use Q If Hit >= "]	=	 "如果能擊中的小兵>=X使用Q",
["Use W If Hit >= "]	=	 "如果能擊中的小兵>=X使用W",
["Use E If Hit >= "]	=	 "如果能擊中的小兵>=X使用E",
["Min. Energy Percent: "] = "最小能量百分比：",
["Zed - JungleClear Settings"] = "[劫] - 清野設置",
["Zed - LastHit Settings"] = "[劫] - 尾刀設置",
["Zed - KillSteal Settings"] = "[劫] - 搶人頭設置",
["Zed - Auto Settings"] = "[劫] - 自動設置",
["Use Auto Q"] = "使用自動Q",
["Use Auto E"] = "使用自動E",
["Use R To Evade"] = "使用R躲避",
["Darius (Q)"] = "德萊厄斯Q",
["Darius (W)"] = "德萊厄斯W",
["Darius (E)"] = "德萊厄斯E",
["Darius (R)"] = "德萊厄斯R",
["Use R1 to Evade"] = "使用一段R躲避",
["Use R2 to Evade"] = "使用二段R躲避",
["Use W To Evade"] = "使用W躲避",
["Use W1 to Evade"] = "使用一段W躲避",
["Use W2 to Evade"] = "使用二段W躲避",
["Zed - Drawing Settings"] = "[劫] - 顯示設置",
["Damage Calculation Bar"] = "血條傷害計算",
["Text when Passive Ready"] = "當被動可用時顯示文字",
["Circle For W Shadow"] = "W影子線圈",
["Circle For R Shadow"] = "R影子線圈",
["Text on Shadows (W or R)"] = "在W或R的影子上顯示文字",
["Zed - Key Settings"] = "[劫] - 按鍵設置",
["Combo with R (RWEQ)"] = "使用R的連招(RWEQ)",
["Combo without R (WEQ)"] = "不使用R的連招(WEQ)",
["Harass (QWE or QE)"] = "騷擾(QWE或者QE)",
["Harass (QWE)"] = "騷擾(QWE)",
["WQE (ON) or QE (OFF) Harass"] = "WQE(開)或QE(關)騷擾",
["LaneClear or JungleClear"] = "清線或清野",
["Run"] = "奔跑",
["Switcher for Combo Mode"] = "連招模式切換器",
["Don't cast spells before R"] = "當R技能釋放之前不要釋放技能",
["Forbidden Syndra by Da Vinci"] = "挑戰者中單合集 - 辛德拉",
["QE Settings"] = "QE連招設置",
["Syndra - Target Selector Settings"] = "[辛德拉] - 目標選擇器設置",
["Syndra - General Settings"] = "[辛德拉] - 常規設置",
["Less QE Range"] = "QE的最小範圍",
["Dont use R on"] = "不要對以下目標使用R",
["QE Width"] = "QE連招寬度",
["Syndra - Combo Settings"] = "[辛德拉] - 連招設置",
["Use QE"] = "使用QE",
["Use WE"] = "使用WE",
["If Needed"] = "如果需要的話",
["Use Zhonyas if HP % <="]= "如果生命值小於%使用中亞",
["Cooldown on spells for r needed"] = "R需要的冷卻時間",
["Syndra - Harass Settings"] = "[辛德拉] - 騷擾設置",
["Use Q if enemy can't move"] = "敵人不能移動的時候使用Q",
["Don't harass under turret"] = "不要騷擾在塔下的目標",
["Syndra - LaneClear Settings"] = "[辛德拉] - 清線設置",
["Syndra - JungleClear Settings"] = "[辛德拉] - 清野設置",
["Syndra - LastHit Settings"] = "[辛德拉] - 尾刀設置",
["Syndra - KillSteal Settings"] = "[辛德拉] - 搶人頭設置",
["Syndra - Auto Settings"] = " [辛德拉] - 自動設置",
["Use QE/WE To Interrupt Channelings"] = "使用QE/WE來打斷引導技能",
["Time Limit to Interrupt"] = "打斷技能的時間限制",
["Use QE/WE To Interrupt GapClosers"] = "使用QE/WE來打斷敵人的突進",
["Syndra - Drawing Settings"] = "[辛德拉] - 顯示設置",
["E Lines"] = "E技能指示線",
["Text if Killable with R"] = "如果能用R擊殺顯示擊殺提示",
["Circle On W Object"] = "在W抓取的目標上畫圈",
["Syndra - Keys Settings"] = "[辛德拉] - 按鍵設置",
["Cast QE/WE Near Mouse"] = "在鼠標附近使用QE/WE",
---------------胖子意識---------------
["Big Fat Gosu"] = "胖子合集",
["Load Big Fat Mark IV"] = "加載胖子意識",
["Load Big Fat Evade"] = "加載胖子躲避",
["Sorry, this champion isnt supported yet =("] = "對不起,不支持這個英雄",
["Big Fat Gosu v. 3.61"] = "胖子合集v. 3.61",
["Big Fat Hev - Mark IV"] = "胖子意識",
["[Voice Settings]"] = "[語音設置]",
["Volume"] = "音量",
["Welcome"] = "歡迎",
["Danger!"] = "危險",
["Shutdown"] = "終結",
["SummonerSpells"] = "召喚師技能",
["WinLose sounds"] = "勝利/失敗",
["Kill Announcer"] = "擊殺播報",
["Shrooms Announcement"] = "踩蘑菇播報",
["Smite Announcement"] = "懲戒播報",
["JungleTimers Announcement"] = "打野計時播報",
["[Incoming Enemys to Track]"] = "[監視即將到來的敵人]",
["ON/OFF"] = "開/關",
["Stop track inc. enemys after x min"] = "x分鐘後停止監視敵人",
["Allow this option"] = "允許此項設置",
["Scan Range"] = "掃描範圍",
["Draw minimap"] = "小地圖顯示",
["Use Danger Sprite"] = "使用危險標誌",
["Show waypoints"] = "顯示路徑點",
["Enable Voice System"] = "啟用語音系統",
["Jax"] = "賈克斯",
["[CD Tracker]"] = "[冷卻計時器]",
["Use CD Tracker"] = "使用冷卻計時器",
["[Wards to Track]"] = "[眼位監視]",
["Use Wards Tracker"] = "使用眼位監視",
["Use Sprites"] = "使用圖片",
["Use Circles"] = "使用線圈",
["Use Text"] = "使用文字",
["[Recall Tracker]"] = "[回城監視]",
["Use Recall Tracker"] = "使用回城監視",
["Hud X"] = "HUD X軸位置",
["Hud Y"] = "HUD Y軸位置",
["Print Finished and Cancelled Recalls"] = "顯示完成的回城和取消的回城",
["[BaseUlt]"] = "[基地大招]",
["Use BaseUlt"] = "使用基地大招",
["Print BaseUlt alert in chat"] = "在聊天框中顯示基地大招提示",
["Draw BaseUlt Hud"] = "顯示基地大招HUD",
["[Team BaseUlt Friends]"] = "[顯示隊友的基地大招]",
["[Tower Range]"] = "[防禦塔範圍]",
["Use Tower Ranges"] = "顯示防禦塔範圍",
["Show only close"] = "只在接近防禦塔時顯示",
["Show ally turrets"] = "顯示友軍防禦塔範圍",
["Show turret view"] = "顯示防禦塔視野",
["Circle Quality"] = "線圈質量",
["Circle Width"] = "線圈寬度",
["[Jungle Timers]"] = "[打野計時]",
["Jungle Disrespect Tracker(FOW)"] = "無視野野區監視",
["Sounds for Drake and Baron"] = "大龍小龍提示音",
["(DEV) try to detect more"] = "(開發者)嘗試檢測更多信息",
["Enable Jungle Timers!!! Finally ^^"] = "最後,啟用打野計時",
["[Enemies Hud]"] = "[敵人信息HUD]",
["Enable enemies hud"] = "啟用敵人信息HUD",
["Hud Style"] = "HUD風格",
["Classic(small)"] = "經典(小)",
["Circle(medium)"] = "圓形(中)",
["Circle(big)"] = "圓形(大)",
["LowFps(Mendeleev)"] = "低fps",
["RitoStyle"] = "Rito風格",
["Hud Mode"] = "HUD模式",
["Vertical"] = " 垂直的",
["Horizontal"] = "水平的",
["HudX and HudY dont work for Old one"] = "HUD XY軸位置不會對經典風格生效",
--["[Thresh Lantern]"] = "[錘石的燈籠]",
--["Use Nearest Lantern"] = "撿最近的燈籠",
["Auto Use if HP < %"] = "如果生命值小於%自動使用",
["[Anti CC]"] = "[反團控]",
["Enable AntiCC"] = "啟用反團控",
["[BuffTypes]"] = "[控制類型]",
["Disarm"] = "繳械",
["ForcedAction"] = "強制動作(嘲諷/魅惑)",
["Suppression"] = "壓制",
["Suspension"] = "擊飛",
["Slow"] = "減速",
["Blind"] = "致盲",
["Stun"] = "眩暈",
["Root"] = "禁錮",
["Silence"] = "沉默",
["Enable Mikael for teammates"] = "啟用對隊友使用坩堝",
["[TeamMates for Mikael]"] = "[對隊友使用坩堝]",
["It will use Cleanse, Dervish Blade,"] = "它會使用凈化,苦行僧之刃",
["Quicksilver Sash, Mercurial Scimitar"] = "水銀飾帶,水銀彎刀",
[" or Mikael's Crucible."] = "或者米凱爾的坩堝",
["Suppressions by Malzahar, Skarner, Urgot,"] = "解除瑪爾扎哈,斯卡納,厄加特的壓制",
["Warwick could be only removed by QSS"] = "狼人的壓制只有水銀能解",
["[Misc]"] = "[雜項]",
["Draw Exp Circle"] = "顯示經驗獲得範圍",
["Extra Awareness"] = "額外意識",
["Heal Cd's on Aram"] = "在大亂斗模式顯示治療cd",
["LordsDecree Cooldown"] = "雷霆領主的法令冷卻時間",
["Big Fat Hev - Mark IV v. 4.001"] = "胖子意識 v. 4.001",

}
function translationchk(text)
    assert(type(text) == "string","<string> expected for text")
    local text2
    --if(text == "text1") then text2 = "change the text" end
    --print("find the text:",text,"tranTable:",tranTable[text])
    --for i ,v in pairs(tranTable) do
    if(tranTable[text] ~= nil) then 
    text2 = tranTable[text] 
    --text2 = text
    else
    text2 = text
    end
    --end
    return text2
end
function OnLoad()
	AAAUpdate()
	PrintLocal("Version for traditional Chinese!")
	PrintLocal("Loaded successfully! by: leoxp,Have fun!")
end
function PrintLocal(text, isError)
	PrintChat("<font color=\"#ff0000\">BoL Config Translater:</font> <font color=\"#"..(isError and "F78183" or "FFFFFF").."\">"..text.."</font>")
end
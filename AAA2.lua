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
["Menu"] = "�ˆ�",
["press key for Menu"] = "�O���µĲˆΰ��o...",
["Evadeee"] = "���",
["Enemy Spells"] = "���˼���",
["Evading Spells"] = "��ܼ���",
["Advanced Settings"] = "�߼��O��",
["Traps"] = "����",
["Buffs"] = "����",
["Humanizer"] = "�M�˻�",
["Combat/Chase Mode"] = "�B��/׷��ģʽ",
["Controls"] = "����",
["Visual Settings"] = "ҕ�X�O��",
["Performance Settings"] = "�����O��",
["Q - Decisive Strike"] = "Q����",
["W - Courage"] = "W����",
["Summoner Spell: Flash"] = "�ن������ܣ��W�F",
["Item: Youmuu's Ghostblade"] = "�ĉ�֮�`",
["Item: Locket of the Iron Solari"] = "��F���֮ϻ",
["Item: Zhonya / Wooglet"] = "�ЋIɳ©",
["Item: Shurelya / Talisman"] = "�������Ŀ�����/�o��",
["Dodge/Cross Settings"] = "��ܻ��^�����O��",
["Evading Settings"] = "����O��",
["Collision Settings"] = "��ײ�O��",
["Script Interaction (API)"] = "�_�����ӣ�API��",
["Reset Settings"] = "�����O��",
["Nidalee and Teemo Traps"] = "��Ů����Ī������",
["Caitlyn and Jinx Traps"] = "Ů���ͽ��˹������",
["Banshee's Veil"] = "Ů���漆",
["Delays"] = "���t",
["Movement"] = "�Ƅ�",
["Anchors"] = "��λ",
["Evading"] = "���",
["Dashes and blinks"] = "˲�ƺ�ͻ�M",
["Special Actions"] = "�������",
["Override - Anchor Settings"] = "���w��λ�O��",
["Override - Humanizer"] = "���w�M�˻�",
["League of Legends Version"] = "Ӣ���˰汾",
["Danger Level: "] = "Σ�U�ȼ�",
["Danger level info:"] = "Σ�U�ȼ���Ϣ",
["    0 - Off"] = "0 - �P�]",
["    1 - Use vs Normal Skillshots"] = "1 - ����һ�㼼�ܹ���ʹ��",
["2..4 - Use vs More Dangerous / CC"] = "2..4 - �����^Σ�U���ܼ��F��ʹ��",
["    5 - Use vs Very Dangerous"] = "5 - �����ǳ�Σ�U���ܕrʹ��",
["Use after-move delay in calcs"] = "��Ӌ������t���Ƅ�",
["Extra hit box radius: "] = "�~��ď���ֱ��",
["Evading points max distance"] = "��׃���ڰ�ȫ��ܵ��c�������x",
["Evade only spells closer than:"] = "ֻ�ڷ��g���x�ӽ�ֵ�ĕr����",
["Global skillshots as exception"] = "���ȫ����Еr���������O��",
["Attempt to DODGE linear spells"] = "�Lԇ��ֱ���������g�ȵĕr����",
["Attempt to CROSS linear spells"] = "�Lԇ��ֱ���������g��r��ȫ���^",
["Attempt to DODGE rectangular spells"] = "�Lԇ�ھ��Ώ������g�ȵĕr����",
["Attempt to CROSS rectangular spells"] = "�Lԇ�ھ��Ώ������g��r��ȫ���^",
["Attempt to DODGE circular spells"] = "�Lԇ�ڈA�Ώ������g�ȵĕr����",
["Attempt to CROSS circular spells"] = "�Lԇ�ڈA�Ώ������g��r��ȫ���^",
["Attempt to DODGE triangular spells"] = "�Lԇ�������Ώ������g�ȵĕr����",
["Attempt to CROSS triangular spells"] = "�Lԇ�������Ώ������g��r��ȫ���^",
["Attempt to DODGE conic spells"] = "�Lԇ���F�Ώ������g�ȵĕr����",
["Attempt to CROSS conic spells"] = "�Lԇ���F�Ώ������g��r��ȫ���^",
["Attempt to dodge arc spells"] = "�Lԇ���F�Ώ������g�ȵĕr����",
["Collision for minions"] = "С������ײ",
["Collision for heroes"] = "Ӣ�۵���ײ",
["Here you can allow other scripts"] = "�@�e�����ʹ�������_��",
["to enable/disable and control Evadeee."] = "����/���úͿ���EVADEEE",
["Allow enabling/disabling evading"] = "���S����/���ö��",
["Allow enabling/disabling Bot Mode"] = "���S����/���ÙC����ģʽ",
["WARNING:"] = "����",
["By switching this ON/OFF - Evadeee"] = "�D�Q�_���P",
["will reset all your settings:"] = "���������O��",
["Restore default settings"] = "�֏�Ĭ�J�O��",
["Enabled"] = "����",
["Ignore with dangerLevel >="] = "����Σ�U�ȼ�",
["    1 - Use vs everything"] = "1 - �κΕr��ʹ��",
["2..4 - Use only vs More Dangerous / CC"] = "2..4 - �H���^Σ�U���ܼ��F��ʹ��",
["    5 - Use only vs Very Dangerous"] = "5 - �H�������ǳ�Σ�U���ܕrʹ��",
["Delay before evading (ms)"] = "���ǰ���t�����룩",
["Ignore evading delay if you move"] = "��������ƄӺ��Զ��ǰ���t",
["Server Tick Buffer (ms)"] = "����������Ӌ�r�����룩",
["Pathfinding:"] = "��·",
["Move extra distance after evade"] = "������Ƅ��~��ľ��x",
["Randomize that extra distance"] = "�S�C���ɶ�������~��ľ��xֵ",
["Juke when entering danger area"] = "���b�M��Σ�U�^��",
["Move this distance during jukes"] = "�ل��������˷��g�ľ��x",
["Allow changing path while evading"] = "���S�ڶ�ܕr��׃·��",
["Delay between each path change"] = "��׃·���r���t�ĕr�g",
["\"Smooth\" Diagonal Evading"] = "ƽ��б�����",
["Max Range Limit:"] = "���h���x����",
["Anchor Type:"] = "��λ����",
["Safe Evade (Ignore Anchor):"] = "��ȫ��ܣ����Զ�λ��",
["Safe evade from enemy team"] = "��ȫ��ܔ���",
["Do that with X enemies nearby: "] = "�ڸ�����X�����˕r",
["How far enemies should be: "] = "�����˵ľ�����x",
["Safe evade during Panic Mode"] = "��ʹ�Ï����W�Fģʽ�r��ȫ���",
["Explanation (Safe Evade):"] = "��ጣ���ȫ��ܣ�",
["This setting will force evade in the"] = "�@���O�Õ������h�x",
["direction away from enemy team."] = "�����Ƅӷ����ƶ��",
["This will ignore your main anchor"] = "�@�������������λ",
["only when there are enemies nearby."] = "ֻ�ڸ����Д��˕r",
["Attempt to dodge spells from FoW"] = "�Lԇ��܏ě]��ҕҰ�ĵط�������ķ��g",
["Dodge if your HP <= X%: "] = "�����Ѫ��С�X%�r���",
["Dodge <= X normal spells..."] =	 "��С춵��X����ͨ���g������r���",
["... in <= X seconds"] =	 "��С춵��X���",
["Disable evading by idling X sec:"] = "�����CX�����Ԅӽ��ö��",
["Better dodging near walls"] = "���������õĶ��·��",
["Better dodging near turrets"] = "���˷��R���������õĶ��·��",
["Handling danger blinks and dashes:"] = "˲�ƺ�ͻ�M�r���Σ�U",
["Angle of the modified cast area"] = "���Σ�U�ĽǶ�",
["Blink/flash over missile"] = "˲�ƻ�ͻ�M��С����߅��ܹ���",
["Delay between dashes/blinks (ms):"] = "˲�ƻ����n�����t(ms)",
["Dash/Blink/Flash Mode:"] = "˲�ƻ�ͻ�M���W�F��ģʽ",
["Note:"] = "ע��",
["While activated, this mode overrides some of"] = "���㼤���@�����ܕr���ܕ����w",
["the settings, which you can modify here."] = "һЩ�����������@�e�޸ĵ��O��",
["Usually this is used together with SBTW."] = "һ����r�º��Ԅ��߿��_�P",
["To change the hotkey go to \"Controls\"."] = "�ڿ����O�����O�ß��I",
["Dodge \"Only Dangerous\" spells"] = "�H���Σ�U����",
["Evade towards anchor only"] = "��ܕrֻ��ǰ��λ",
["Ignore circular spells"] = "���ԈA�μ���",
["Use dashes more often"] = "�����ʹ��˲��",
["To change controls just click here   \\/"] = "�c�@�e���׃�����O��",
["Evading        | Hold"] = "��ס���",
["Evading        | Toggle"] = "���¶���_�P����ֱ���ڴΰ���ֹͣ",
["Combat/Chase Mode | Hold 1"] = "���Y��׷��ģʽ���I1",
["Combat/Chase Mode | Hold 2"] = "���Y��׷��ģʽ���I2",
["Combat/Chase Mode | Toggle"] = "���Y��׷��ģʽ�_�P",
["Panic Mode     | Refresh"] = "�@��ģʽˢ��",
["Panic Mode Duration (seconds)"] = "�@��ģʽ�r�g���룩",
["Remove spells with doubleclick"] = "�p���Ƴ������L�D",
["Quick Menu:"] = "��ݲˆ�",
["Open Quick Menu with LMB and:"] = "��������I��:�_�����ٲˆ�",
["Replace Panic Mode"] = "��Q�@��ģʽ",
["Explanation (Quick Menu):"] = "�f������ݲˆΣ�",
["If you choose 1 key for Quick Menu"] = "������x���I1�������I",
["then make sure it doesn't overlap"] = "�ˆο���I��Ո�_�J������",
["with League's Quick Ping menu!"] = "�[���@ʾPING�Ŀ���I�دB",
["Draw Skillshots"] = "�����L�D��ʾ",
["Spell area line width"] = "���܅^�򾀵Ĵּ�",
["Spell area color"] = "���܅^���ɫ",
["Draw Dangerous Area"] = "Σ�U�^���L�D��ʾ",
["Danger area line width"] = "Σ�U�^�򾀵Ĵּ�",
["Danger area color"] = "Σ�U�^���ɫ",
["Display Evading Direction"] = "�@ʾ��ܷ���",
["Show \"Doubleclick to remove!\""] = "�@ʾ�p���Ƴ����D��",
["Display Evadeee status"] = "�@ʾEVADEEE��B",
["Status display Y offset"] = "��B�@ʾ�v�S�K��",
["Status display text size"] = "��B�@ʾ���w��С",
["Print Evadeee status"] = "�@ʾEVADEEE��B",
["Show Priority Menu"] = "�@ʾ���Ȳˆ�",
["Priority Menu X offset"] = "���ȲˆΙM�S�K��",
["Preset"] = "�A�O",
["Change this on your own risk:"] = "�����׃����L�U��ؓ",
["Update Frequency [Times per sec]"] = "ˢ�����l�ʴ�/��",
-----------------SAC-----------------------
["Script Version"] = "�_���汾",
["Generate Support Report"] = "����Ԯ�����",
["Clear Chat When Enabled"] = "���_���r��Ռ�Ԓ��",
["Show Click Marker (Broken)"] = "�����щ�",
["Click Marker Colour"] = "�c���A�y�ɫ",
["Minimum Time Between Clicks"] = "�c����С�g��",
["Maximum Time Between Clicks"] = "�c������g��",
["translation button"] = "���g�I",
["Harass mode"] = "�}�_ģʽ",
["Cast Mode"] = "ʩ��ģʽ",
["Collision buffer"] = "��ײ�w�e",
["Normal minions"] = "һ��С��",
["Jungle minions"] = "Ұ��",
["Others"] = "����",
["Check if minions are about to die"] = "���С���������c��",
["Check collision at the unit pos"] = "�z�����w�gλ����ײ",
["Check collision at the cast pos"] = "�z��ʩ��λ����ײ",
["Check collision at the predicted pos"] = "�z���AӋ���gλ����ײ",
["Enable debug"] = "�_���ų�����ģʽ",
["Show collision"] = "�@ʾ��ײ",
["Version"] = "�汾",
["No enemy heroes were found!"] = "δ�l�F����Ӣ��",
["Target Selector Mode:"] = "Ŀ���x��ģʽ",
["*LessCastPriority Recommended"] = "���]������ʹ�ü���+���ȼ�",
["Hold Left Click Action"] = "��ס������I�Ą���",
["Focus Selected Target"] = "�۽��x�е�Ŀ��",
["Attack Selected Buildings"] = "�����x�еĽ��B",
["Disable Toggle Mode On Recall"] = "�ڻسǕr�����_�Pģʽ",
["Disable Toggle Mode On Right Click"] = "������I�c�������_�Pģʽ",
["Mouse Over Hero To Stop Move"] = "��ˑ�ͣ��Ӣ���Ϸ��rֹͣ�Ƅ�",
["      Against Champions"] = "�c����Y�ĵط�Ӣ��",
["Use In Auto Carry"] = "���Ԅ��B��ݔ��ģʽʹ��",
["Use In Mixed Mode"] = "�ڻ��ģʽʹ��",
["Use In Lane Clear"] = "���往ģʽʹ��",
["Killsteal"] = "�����^",
["Auto Carry minimum % mana"] = "���ħ�����%�t���_���Ԅ��B��ݔ��ģʽ",
["Mixed Mode minimum % mana"] = "���ħ�����%�t���_�����ģʽ",
["Lane Clear minimum % mana"] = "���ħ�����%�t���_���往ģʽ",
["      Skill Farm"] = "����ˢ��",
["Lane Clear Farm"] = "�往ˢ��",
["Jungle Clear"] = "ˢҰ",
["TowerFarm"] = "����ˢ��?",
["Skill Farm Min Mana"] = "ʹ�ü���ˢ��ħ�������",
["(when enabled)"] = "�����Õr",
["Stick To Target"] = "�o��Ŀ��",
["   Stick To Target will mirror "] = "�o��Ŀ��ݔ��",
["   enemy waypoints so you stick"] = "���o�������M·��",
["   to him like glue!"] = "�����w���NĘ��",
["Outer Turret Farm"] = "����ˢ��",
["Inner Turret Farm"] = "����ˢ��",
["Inhib Turret Farm"] = "ˮ��ˢ��",
["Nexus Turret Farm"] = "�T��ˢ��",
["Lane Clear Method"] = "�往��ʽ",
["Double-Edged Sword"] = "�p�Є����x",
["Savagery"] = "Ұ�U���x",
["Toggle mode (requires reload)"] = "�_�Pģʽ����Ҫ2XF9��",
["Movement Enabled"] = "���S�Ƅ�",
["Attacks Enabled"] = "���S����",
["Anti-farm/harass (attack back)"] = "�}�_�����a����������",
["Attack Enemies"] = "��������",
["Prioritise Last Hit Over Harass"] = "�a��������}�_",
["Attack Wards"] = "������",
["           Main Hotkeys"] = "��Ҫ����I",
["Auto Carry"] = "�Ԅ��B�й���ģʽ",
["Last Hit"] = "�a��ģʽ",
["Mixed Mode"] = "���ģʽ",
["Lane Clear"] = "�往",
["           Other Hotkeys"] = "��������I",
["Target Lock"] = "Ŀ���i��",
["Enable/Disable Skill Farm"] = "�_�����P�]����ˢ��",
["Lane Freeze (Default F1)"] = "F1�·����a��",
["Support Mode (Default F6)"] = "�o��ģʽ",
["Toggle Streaming Mode with F7"] = "F7�_�P����ģʽ",
["Use Blade of the Ruined King"] = "ʹ���Ɣ�",
["Use Bilgewater Cutlass"] = "ʹ�ñȠ������؏���",
["Use Hextech Gunblade"] = "ʹ�ú���˹�Ƽ�����",
["Use Frost Queens Claim"] = "ʹ�ñ�˪Ů�ʵ�ָ��",
["Use Talisman of Ascension"] = "ʹ���w���o��",
["Use Ravenous Hydra"] = "ʹ��؝�����^��",
["Use Tiamat"] = "ʹ���၆�R��",
["Use Entropy"] = "ʹ�ñ�˪���N",
["Use Youmuu's Ghostblade"] = "ʹ���ĉ�֮�`",
["Use Randuins Omen"] = "ʹ���m�D֮��",
["Use Muramana"] = "ʹ��ħ��",
["Save BotRK for max heal"] = "����BotRK�@������ί�",
["Use Muramana [Champions]"] = "��Ӣ��ʹ��ħ��",
["Use Muramana [Minions]"] = "��С��ʹ��ħ��",
["Use Tiamat/Hydra to last hit"] = "ʹ���၆�R�ػ��߾��^���������һ��",
["Use Muramana [Jungle]"] = "��Ұ��ʹ��ħ��",
["Champion Range Circle"] = "Ӣ�۹����A�ΈD",
["Colour"] = "�ɫ",
["Circle Around Target"] = "Ŀ�ˈA�ΈD",
["Draw Target Lock Circle"] = "�@ʾĿ���i���A�ΈD",
["Target Lock Colour"] = "Ŀ���i���ɫ",
["Target Lock Reminder Text"] = "Ŀ���i��������ʾ",
["Show Pet/Clone target scan range"] = "�@ʾ����/��¡Ŀ�˒��蹠��",
["Use Low FPS Circles"] = "ʹ�õ�FPS�A",
["Show PermaShow box"] = "�@ʾ�����@ʾ��",
["Show AA reminder on script load"] = "�xȡ�_���r�@ʾAA����",
["Enable Pet Orbwalking:"] = "�_�������߿�",
["Tibbers"] = "��Ů�Ხ˹",
["Shaco's Clone"] = "С���¡",
["Target Style:"] = "Ŀ�˷�ʽ",
["When To Orbwalk:"] = "ʲ�N�r���߿�",
["Target Scan Range"] = "Ŀ�˒��蹠��",
["Push Lane In LaneClear"] = "���往�rʹ���ƾ�ģʽ",
["Delay Between Movements"] = "�Ƅ��g�����t",
["Randomize Delay"] = "�S�C���t",
["Humanize Movement"] = "�M�˻��Ƅ�",
["Last Hit Adjustment:"] = "�a���{��",
["Adjustment Amount:"] = "�{����",
["Animation Cancel Adjustment:"] = "�չ��Ӯ�ȡ���{��",
["Mouse Over Hero AA Cancel Fix:"] = "��ˑ�ͣ��Ӣ���Ϸ�ȡ���չ�",
["Mouse Over Hero Stop Distance:"] = "��ˑ�ͣ��Ӣ���Ϸ�ֹͣ���x",
["Server Delay (don't touch): 100ms"] = "���������t100����",
["Disable AA Cancel Detection"] = "�����չ�ȡ���ɜy",
["By Role:"] = "����ɫ",
["    Draw ADC"] = "ADC�L�D",
["    Draw AP Carry"] = "AP�L�D",
["    Draw Support"] = "�o���L�D",
["    Draw Bruiser"] = "�̿��L�D",
["    Draw Tank"] = "̹���L�D",
["By Champion:"] = "��Ӣ��",
["Modify Minion Health Bars"] = "�{��С��Ѫ�l",
["Maximum Health Bars To Modify"] = "���Ѫ�l�{��",
["Draw Last Hit Arrows"] = "����һ��D������",
["Always Draw Modified Health Bars"] = "һֱ�@ʾѪ�l�{��",
["Always Draw Last Hit Arrows"] = "һֱ�@ʾ����һ��D������",
["Sida's Auto Carry"] = "Sida�߿�",
["Setup"] = "�O��",
["Hotkeys"] = "����I",
["Configuration"] = "����",
["Target Selector"] = "Ŀ���x��",
["Skills"] = "����",
["Items"] = "��Ʒ",
["Farming"] = "ˢ��",
["Melee"] = "�F��",
["Drawing"] = "�L�D",
["Pets/Clones"] = "����/��¡",
["Streaming Mode"] = "�_�P����ģʽ",
["Advanced / Fixes"] = "�߼�/�{��",
["VPrediction"] = "V�A��",
["Collision"] = "��ײ�w�e",
["Developers"] = "�_�l��",
["Circles"] = "�AȦ",
["Enemy AA Range Circles"] = "�����չ�����Ȧ",
["Minion Drawing"] = "С����ӛ",
["Other"] = "����",
["Auto Carry Mode"] = "�Ԅ��B�й���",
["Last Hit Mode"] = "����һ���a��ģʽ",
["Lane Clear Mode"] = "�往ģʽ",
["Auto Carry Items"] = "�Ԅ��B��ʹ�õ���Ʒ",
["Mixed Mode Items"] = "���ģʽʹ�õ���Ʒ",
["Lane Clear Items"] = "�往ʹ�õ���Ʒ",
["Q (Decisive Strike)"] = "Q",
["E (Judgment)"] = "E",
["R (Demacian Justice)"] = "R",
["Masteries"] = "���x",
["Damage Prediction Settings"] = "�����A���O��",
["Turret Farm"] = "����ˢ��",
["Activator"] = "���",
["Activator Version : "] = "����汾̖",
["Debug Mode Setting"] = "�{ԇģʽ�O��",
["Zhonya Debug"] = "�{ԇ�Ё�",
["Debug Mode (shields,zhonya): "] = "�{ԇģʽ(�o��,�Ё�)",
["Font Size Zhonya"] = "�Ё����w��С",
["X Axis Draw Zhonya Debug"] = "�Ё��@ʾX�Sλ��",
["Y Axis Draw Zhonya Debug"] = "�Ё��@ʾY�Sλ��",
["QSS Debug "] = "ˮ�y��{ԇ",
["Debug Mode (qss): "] = "�{ԇģʽ(ˮ�y�)",
["Font Size QSS"] = "ˮ�y����w��С",
["X Axis Draw QSS Debug"] = "ˮ�y��@ʾX�Sλ��",
["Y Axis Draw QSS Debug"] = "ˮ�y��@ʾY�Sλ��",
["Cleanse Debug"] = "�����{ԇ",
["Debug Mode (Cleanse): "] = "�{ԇģʽ(����)",
["Font Size Cleanse"] = "�������w��С",
["X Axis Draw Cleanse Debug"] = "�����@ʾX�Sλ��",
["Y Axis Draw Cleanse Debug"] = "�����@ʾY�Sλ��",
["Mikael Debug"] = "����{ԇ",
["Debug Mode (Mikael): "] = "�{ԇģʽ(���)",
["Font Size Mikael"] = "������w��С",
["X Axis Draw Mikael Debug"] = "����@ʾX�Sλ��",
["Y Axis Draw Mikael Debug"] = "����@ʾY�Sλ��",
["Tower Damage"] = "���R������",
["Calculate Tower Damage"] = "Ӌ����R������",
["Auto Spells"] = "�Ԅ�ʹ�ü���",
["Auto Shield Spells"] = "�Ԅ��o�ܼ���",
["Use Auto Shield Spells"] = "ʹ���Ԅ��o�ܼ���",
["Max percent of hp"] = "�������ֵ�ٷֱ�",
["Shield Ally Oriana"] = "���W������ʹ���o��",
["Auto Pot Settings"] = "�Ԅ�ˎˮ�O��",
["Use Auto Pots"] = "ʹ���Ԅ�ˎˮ",
["Use Health Pots"] = "�Ԅӳ�Ѫƿ",
["Use Mana Pots"] = "�Ԅӳ��{ƿ",
["Use Flask"] = "�Ԅӳ�ħƿ",
["Use Biscuit"] = "�Ԅӳ��Ǭ",
["Min Health Percent"] = "��С����ֵ�ٷֱ�",
["Health Lost Percent"] = "�pʧ����ֵ�ٷֱ�",
["Min Mana Percent"] = "��С�{���ٷֱ�",
["Min Flask Health Percent"] = "ħƿ-��С����ֵ�ٷֱ�",
["Min Flask Mana Percent"] = "ħƿ-��С�{���ٷֱ�",
["Offensive Items Settings"] = "�M����Ʒ�O��",
["Button Mode"] = "���Iģʽ",
["Use Button Mode"] = "ʹ�ð��Iģʽ",
["Button Mode Key"] = "���I",
["AP Items"] = "AP��Ʒ",
["Use AP Items"] = "ʹ��AP��Ʒ",
["Use Bilgewater Cutlass"] = "ʹ�ñȠ������؏���",
["Use Blackfire Torch"] = "ʹ�����׻��",
["Use Deathfire Grasp"] = "ʹ��ڤ��֮��",
["Use Hextech Gunblade"] = "ʹ�ú���˹�Ƽ�����",
["Use Twin Shadows"] = "ʹ���p����Ӱ",
["Use Odyn's Veil"] = "ʹ�ÊW�������暢",
["AP Item Mode: "] = "AP��Ʒģʽ",
["Burst Mode"] = "���lģʽ",
["Combo Mode"] = "�B��ģʽ",
["KS Mode"] = "�����^ģʽ",
["AD Items"] = "AD��Ʒ",
["Use AD Items On Auto Attack"] = "��ƽA�ĕr��ʹ��AD��Ʒ",
["Use AD Items"] = "ʹ��AD��Ʒ",
["Use Blade of the Ruined King"] = "ʹ���Ɣ�����֮��",
["Use Entropy"] = "ʹ�ñ�˪���N",
["Use Ravenous Hydra"] = "ʹ�þ��^��",
["Use Sword of the Divine"] = "ʹ�����}֮��",
["Use Tiamat"] = "ʹ���၆�R��",
["Use Youmuu's Ghostblade"] = "ʹ���ĉ�֮�`",
["Use Muramana"] = "ʹ��ħ��",
["Min Mana for Muramana"] = "ʹ��ħ�е���С�{��",
["Minion Buff"] = "С������",
["Use Banner of Command"] = "ʹ��̖��֮��",
["AD Item Mode: "] = "AD��Ʒģʽ",
["Burst Mode"] = "���lģʽ",
["Combo Mode"] = "�B��ģʽ",
["KS Mode"] = "�����^ģʽ",
["Defensive Items Settings"] = "���R��Ʒ�O��",
["Cleanse Item Config"] = "�����O��",
["Stuns"] = "ѣ��",
["Silences"] = "��Ĭ",
["Taunts"] = "���S",
["Fears"] = "�֑�",
["Charms"] = "�Ȼ�",
["Blinds"] = "��ä",
["Roots"] = "���d",
["Disarms"] = "׃��",
["Suppresses"] = "����",
["Slows"] = "�p��",
["Exhausts"] = "̓��",
["Ignite"] = "�cȼ",
["Poison"] = "�ж�",
["Shield Self"] = "�Ԅ��o��",
["Use Self Shield"] = "ʹ���Ԅ��o��",
["Use Seraph's Embrace"] = "ʹ�ß���ʹ֮��",
["Use Ohmwrecker"] = "ʹ�øɔ_ˮ��",
["Min dmg percent"] = "��С�����ٷֱ�",
["Zhonya/Wooglets Settings"] = "�Ё�/�ָ����ص��׎�ñ�O��",
["Use Zhoynas"] = "ʹ���Ё�",
["Use Wooglet's Witchcap"] = "ʹ���ָ����ص��׎�ñ",
["Only Z/W Special Spells"] = "ֻ���ض�����ʹ��",
["Debuff Enemy"] = "������ʹ�Üp��Ч��",
["Use Debuff Enemy"] = "ʹ�Üp��Ч��",
["Use Randuin's Omen"] = "�m�D֮��",
["Randuins Enemies in Range"] = "�ڹ�������X�����˕rʹ���m�D",
["Use Frost Queen"] = "ʹ�ñ�˪Ů�ʵ�ָ��",
["Cleanse Self"] = "�������Ʒ",
["Use Self Item Cleanse"] = "ʹ�Ã������Ʒ",
["Use Quicksilver Sash"] = "ʹ��ˮ�y�",
["Use Mercurial Scimitar"] = "ʹ��ˮ�y����",
["Use Dervish Blade"] = "ʹ�ÿ���ɮ֮��",
["Cleanse Dangerous Spells"] = "����Σ�U�ļ���",
["Cleanse Extreme Spells"] = "�����O��Σ�U�ļ���",
["Min Spells to use"] = "���ٓ���X�N�p��Ч����ʹ��",
["Debuff Duration Seconds"] = "�p��Ч�����m�r�g",
["Shield/Boost Ally"] = "�o��܊ʹ���o��/����",
["Use Support Items"] = "ʹ���o����Ʒ",
["Use Locket of Iron Solari"] = "��F���֮ϻ",
["Locket of Iron Solari Life Saver"] = "����ֵ���X�rʹ����F���֮ϻ",
["Use Talisman of Ascension"] = "�w���o��",
["Use Face of the Mountain"] = "ɽ�[֮��",
["Face of the Mountain Life Saver"] = "����ֵ���X�rʹ��ɽ�[֮��",
["Use Guardians Horn"] = "���o�ߵ�̖��",
["Life Saving Health %"] = " ����ֵ���X%",
["Mikael Cleanse"] = "�ׄP�������",
["Use Mikael's Crucible"] = "ʹ�����",
["Mikaels cleanse on Ally"] = "����܊ʹ�����",
["Mikaels Life Saver"] = "�������X%�rʹ�����",
["Ally Saving Health %"] = "��܊����ֵ���X%",
["Self Saving Health %"] = "�Լ�����ֵ���X%",
["Min Spells to use"] = "���ٓ���X�N�p��Ч����ʹ��",
["Set Debuff Duration"] = "�O�Üp��Ч�����m�r�g",
["Champ Shield Config"] = "Ӣ���o���O��",
["Champ Cleanse Config"] = "Ӣ�ۃ����O��",
["Shield Ally Vayne"] = "����܊ޱ��ʹ���o��",
["Cleanse Ally Vayne"] = "����܊ޱ��ʹ�Ã���",
["Show In Game"] = "���[�����@ʾ",
["Show Version #"] = "�@ʾ�汾̖",
["Show Auto Pots"] = "�@ʾ�Ԅ�ˎˮ",
["Show Use Auto Pots"] = "�@ʾʹ���Ԅ�ˎˮ",
["Show Use Health Pots"] = "�@ʾ�Ԅ�Ѫș",
["Show Use Mana Pots"] = "�@ʾ�Ԅ��{ș",
["Show Use Flask"] = "�@ʾ�Ԅ�ħƿ",
["Show Offensive Items"] = "�@ʾ��������Ʒ",
["Show Use AP Items"] = "�@ʾʹ��AP��Ʒ",
["Show AP Item Mode"] = "�@ʾAP��Ʒģʽ",
["Show Use AD Items"] = "�@ʾʹ��AD��Ʒ",
["Show AD Item Mode"] = "�@ʾAD��Ʒģʽ",
["Show Defensive Items"] = "�@ʾ���R��Ʒ",
["Show Use Self Shield Items"] = "�@ʾ���Լ�ʹ���o�����Ʒ",
["Show Use Debuff Enemy"] = "�@ʾ���ط�ʹ�Üp��Ч��",
["Show Self Item Cleanse "] = "�@ʾ���Լ�ʹ�Ã���",
["Show Use Support Items"] = "�@ʾʹ���o����Ʒ",
["Show Use Ally Cleanse Items"] = "�@ʾ����܊ʹ�Ã������Ʒ",
["Show Use Banner"] = "�@ʾʹ��̖��֮��",
["Show Use Zhonas"] = "�@ʾʹ���Ё�",
["Show Use Wooglets"] = "�@ʾʹ���ָ����ص��׎�ñ",
["Show Use Z/W Lifeaver"] = "�@ʾʹ���Ё����|�l����ֵ",
["Show Z/W Dangerous"] = "�@ʾʹ���Ё���Σ�U�̶�",
["DeklandAIO: Orianna"] =  "��ϵ�кϼ����W������",
["DeklandAIO Version: "] =  "��ϵ�кϼ��汾̖��",
["Auth Settings"] =  "�_����C�O��",
["Debug Auth"] =  "�{ԇ��C",
["Fix Auth"] =  "�ޏ���C",
["Target Selector Settings"] =  "Ŀ���x�����O��",
["Left Click Overide"] =  "���I�c��Ŀ�˃���",
["1 = Highest, 5 = Lowest, 0 = Ignore"]	= "1-��ߣ�5-��ͣ�0-����",
["Use Priority Mode"] =  "ʹ�Ã��ȼ�ģʽ",
["Set Priority Vladimir"] =  "�O����Ѫ��ă��ȼ�",
["Keys Settings"] =  "�Iλ�O��",
["Harass"] =  "�}�_",
["Harass Toggle"] =  "�}�_�_�P",
["TeamFight"] =  "�F��",
["Skill Settings"] =  "�����O��",
["                    Q Skill          "] =  "                Q����              ",
["Use Harass"] =  "ʹ��ԓ�����}�_",
["Use Kill Steal"] =  "ʹ��ԓ���ܓ����^",
["Use Spacebar"] =  "ʹ�ÿո�",
["                    W Skill          "] =  "                W����              ",
["Min No. Of Enemies In W Range"] =  "��W��������С���˔���",
["                    E Skill          "] =  "                E����              ",
["Use E>Q Combo"] =  "ʹ��EQ�B��",
["Use E If Can Hit"] =  "������ܓ���Ŀ�˕rʹ��E",
["Use E>W or E>R"] =  "ʹ��EW����ER�B��",
["                    R Skill          "] =  "                R����              ",
["R Block"] =  "��ֹR�Ԅ�ጷ�",
["Set R Range"] =  "�O��R�Ĺ���",
["Use Combo Ult - (Q+W+R Dmg)"] =  "ʹ�ýK�O�B�У�QWR�Ă�����",
["Min No. Of Enemies"] =  "��������X�����˕rጷ�",
["Min No. Of KS Enemies"] =  "��������X����Ѫ���˕rጷ�",
["Ult Vladimir"] =  "����Ѫ��ጷ�R",
["                    Misc Settings          "] =  "            �s��O��              ",
["Harass Mana Management"] =  "�}�_�{������",
["Farm Settings"] =  "ˢ���O��",
["                    Farm Keys          "] =  "            ˢ�����I              ",
["Farm Press"] =  "ˢ�����I",
["Farm Toggle"] =  "ˢ���_�P",
["Lane Clear Press"] =  "�往���I",
["Lane Clear Toggle"] =  "�往�_�P",
["Jungle Farm"] =  "��Ұ",
["                    Q Farm          "] =  "         Q����ˢ��           ",
["Last Hit"] =  " ",
["Lane Clear"] =  "�往",
["Jungle"] =  "��Ұ",
["                    W Farm          "] =  "         W����ˢ��           ",
["                    E Farm          "] =  "         E����ˢ��           ",
["                    Misc          "] =  "                    �s�          ",
["Farm Mana Management"] =  "ˢ���{������",
["OrbWalk Settings"] =  "�߿��O��",
["            Team Fight Orbwalk Settings          "] =  "            �F���߿��O��          ",
["Move To Mouse"] =  "�����λ���Ƅ�",
["Auto Attacks"] =  "�Ԅӹ���",
["               Harrass Orbwalk Settings          "] =  "            �}�_�߿��O��          ",
["              Lane Farm Orbwalk Settings          "] =  "         �往ˢ���߿��O��         ",
["              Jungle Farm Orbwalk Settings          "] =  "            ��Ұ�߿��O��          ",
["On Dash Settings"] =  "�挦ͻ�M�r�O��",
["Check On Dash Vladimir"] =  "�z����Ѫ���ͻ�M",
["Items Settings"] =  "��Ʒ�O��",
["AP Items"] =  "AP����Ʒ",
["Use AP Items"] =  "ʹ��AP��Ʒ",
["Use Bilgewater Cutlass"] =  "�Ƞ������؏���",
["Use Blackfire Torch"] =  "���׻��",
["Use Deathfire Grasp"] =  "ڤ��֮��",
["Use Hextech Gunblade"] =  "����˹�Ƽ�����",
["Use Twin Shadows"] =  "�p����Ӱ",
["AP Item Mode: "] =  "AP��Ʒģʽ",
["Burst Mode"] =  "���lģʽ",
["Combo Mode"] =  "�B��ģʽ",
["KS Mode"] =  "�����^ģʽ",
["AD Items"] =  "AD��Ʒ",
["Use AD Items"] =  "ʹ��AD��Ʒ",
["Use Blade of the Ruined King"] =  "ʹ���Ɣ�����֮��",
["Use Entropy"] =  "��˪���N",
["Use Sword of the Divine"] =  "���}֮��",
["Use Tiamat/Ravenous Hydra"] =  "�၆�R��/���^��",
["Use Youmuu's Ghostblade"] =  "�ĉ�֮�`",
["Use Muramana"] =  "ħ��",
["Min Mana for Muramana"] =  "ʹ��ħ�е���С�{��",
["AD Item Mode: "] =  "AD��Ʒģʽ",
["Support Items"] =  "�o����Ʒ",
["Use Support Items"] =  "ʹ���o����Ʒ",
["Auto Wards"] =  "�ԄӲ���",
["Use Sweeper"] =  "ʹ�Ò���",
["Ward Mode: "] =  "����ģʽ",
["Only Bushes"] =  "ֻ�ڲ݅�",
["Always"] =  "����",
["Summoner Spells"] =  "�ن�������",
["                    Ignite          "] =  "                    �cȼ          ",
["Use Ignite"] =  "ʹ���cȼ",
["Ignite Mode : "] =  "�cȼģʽ��",
["ComboMode"] =  "�B��ģʽ",
["KSMode"] =  "�����^ģʽ",
["                    Smite          "] =  "                    �ͽ�          ",
["             Smite Not Found         "] =  "             �]�аl�F�ͽ�         ",
["Use Smite"] = "ʹ�Ñͽ�",
["Smite Baron/Dragon/Vilemaw"] = "������/С��/����֮��ʹ�Ñͽ�",
["Smite Large Minions"] = "����Ұ��ʹ�Ñͽ�",
["Smite Small Minions"] = "��СҰ��ʹ�Ñͽ�",
["                  Lane          "] = "                  ����          ",
["                  Jungle          "] = "                  ��Ұ          ",
["Smite Siege Minions"] = "����܇ʹ�Ñͽ�",
["Smite Melee Minions"] = "�������ʹ�Ñͽ�",
["Smite Caster Minions"] = "���h�̱�ʹ�Ñͽ�",
["Draw Settings"] =  "�L�D�O��",
["Draw Skill Ranges"] =  "�������ܾ�Ȧ",
["Lag free draw"] =  "��Ӱ����t�ľ�Ȧ",
["Draw Q Range"] =  "����Q���ܾ�Ȧ",
["Choose Q Range Colour"] =  "�x��Q���ܾ�Ȧ�ɫ",
["Draw W Range"] =  "����W���ܾ�Ȧ",
["Choose W Range Colour"] =  "�x��W�����ɫ",
["Draw E Range"] =  "����E���ܾ�Ȧ",
["Choose E Range Colour"] =  "�x��E���ܾ�Ȧ�ɫ",
["Draw R Range"] =  "����R���ܾ�Ȧ",
["Choose R Range Colour"] =  "�x��R���ܾ�Ȧ�ɫ",
["Draw AA Range"] =  "����ƽA�Ĺ���",
["Draw Awareness"] =  "�@ʾ���R",
["Draw Clicking Points"] =  "�@ʾ�c����λ��",
["Draw Enemy Cooldowns"] =  "�@ʾ���˵�CD",
["Draw Enemy Predicted Damage"] =  "�@ʾ���˵Ă���",
["Draw Last Hit Marker"] =  "�@ʾβ���Ę�ӛ",
["Draw Wards + Wards Timers"] =  "�@ʾ��λ�Լ���λ�r�g",
["Draw Turret Ranges"] =  "�@ʾ���R������",
["Draw Kill Range"] =  "�@ʾ��������",
["Kill Range"] =  "��������",
["Choose Kill Range Colour"] =  "�x������������ɫ",
["Draw Focused Target"] =  "�@ʾ�i����Ŀ��",
["Focused Target"] =  "�i��Ŀ��",
["Choose Focused Target Colour"] =  "�x���i��Ŀ�˵��ɫ",
["Draw Doomball Ranges"] =  "�@ʾħż�Ĺ���",
["Draw Doomball W Range"] =  "�@ʾħżW�Ĺ���",
["Draw Doomball R Range"] =  "�@ʾħżR�Ĺ���",
----------------------------------------------------------------
["DeklandAIO: Syndra"] =  "��ϵ�кϼ���������",
["Set Priority Amumu"] =  "�O��ľľ�ă��ȼ�",
["Use QE Snipe"] =  "ʹ��QE",
["Cast On Optimal Target"] =  "�����Ŀ��ጷ�",
["Ult Amumu"] =  "��ľľጷ�R",
["Use QE Snipe (Teamfight)"] =  "ʹ��QE���ڈF��r��",
["Use QE Snipe (Harass)"] =  "ʹ��QE�����}�_�r��",
["Use Kill Steal QE Snipe"] =  "��QE�����^",
["Use Gap Closers"] =  "��ͻ�Mʹ�õļ���",
["Interupt Skills"] =  "�����������",
["Check On Dash Amumu"] =  "�z��ľľ��ͻ�M",
["Draw QE Range"] =  "����QE�Ĺ���",
["Choose QE Range Colour"] =  "�x��QE�ľ�Ȧ�ɫ",
["Draw Prediction"] =  "�����A��",
["Draw Q Prediction"] =  "����Q���A��",
["Draw W Prediction"] =  "����W���A��",
["Draw E Prediction"] =  "����E���A��",
["Draw QE Prediction"] =  "����QE���A��",
----------------��ϵ����Ɲ�Nʯ-----------------------
["DeklandAIO: Thresh"] = "��ϵ�кϼ����Nʯ",
--["Use Lantern Whilst Hooked"] = "���е�ͬ�rʹ�ß��\",
--["Use Lantern - Grab Ally"] = "����܊ʹ�ß��\",
--["Use Lantern - Self"] = "���Լ�ʹ�ß��\",
["E Mode"] = "E����ģʽ",
["Auto"] = "�Ԅ�",
["Pull"] = "������",
["Push"] = "��ǰ��",
["No. of Enemies In Range"] = "�ڹ����ȵĔ�܊����",
["Use Q On Dash "] = "��ͻ�Mʹ��Q",
["Use E On Dash "] = "��ͻ�Mʹ��E",
["             Ignite Not Found         "] = "             �]�аl�F�cȼ         ",
["Draw Souls"] = "�@ʾ�`��",
["DeklandAIO: Ryze"] = "��ϵ�кϼ�����Ɲ",
["Auto Q Stack"] = "�Ԅ�Q������",
-----------------��ϵ����Ů����˹--------------------
["DeklandAIO: Cassiopeia"] = "��ϵ�кϼ��������W��I",
["Set Priority Chogath"] = "�O�ÿƼ�˹�ă��ȼ�",
["Assisted Ult"] = "�o������",
["Use W Only If Q Misses"] = "ֻ��Qmiss�ĕr��ʹ��W",
["E Daly Timer (secs)"] = "E���t�ĕr�g(��)",
["Use Spacebar (All skills can kill)"] = "ʹ�ÿո�(���м��ܿ��ԓ���)",
["When conditions are met it will ult Automatically"] = "���M��l���r���Ԅ�ጷŴ���",
["No. Enemies in Range"] = "��������x������",
["No. KS Enemies in Range"] = "��������x�����˿��ԓ����^",
["No. Facing Enemies"] = "��������x���泯��Ĕ���",
["Ult Chogath"] = "���Ƽ�˹ʹ�ô���",
["Auto E Poison Minions"] = "�Ԅ�E�ж���С��",
["Check On Dash Chogath"] = "�z��Ƽ�˹��ͻ�M",
["Draw R Prediction"] = "�@ʾR���A��",
["Draw Poison Targets"] = "�@ʾ�ж���Ŀ��",
["DeklandAIO: Xerath"] = "��ϵ�кϼ�������˹",
["Set Priority Nidalee"] = "�O���ε����ă��ȼ�",
["Ult Tap (fires 'One' on release)"] = "���а��I(��һ�η�һ��R)",
["Smart Cast Manual Q"] = "���������ք�Q",
["Force Ult - R Key"] = "���ƴ��� - R�I",
["Ult Near Mouse"] = "����˸����Ĕ��˷�R",
["Ult Delay"] = "�������t",
["Check On Dash Nidalee"] = "�z���ε�����ͻ�M",
["MiniMap draw"] = "С�؈D�@ʾ",
["Draw Ult Range"] = "�@ʾR����",
["Draw Ult Marks"] = "�@ʾR��ӛ",
-----------------�����ϼ�----------------------------
["HTTF Prediction"] = "HTTF�A��",
["Collision Settings"] = "��ײ�O��",
["Buffer distance (Default value = 10)"] = "���n���x(Ĭ�J10)",
["Ignore which is about to die"] = "���Ԍ�Ҫ������Ŀ��",
["Script version: "] = "�_���汾̖",
["DivinePrediction"] = "���}�A��",
["Min Time in Path Before Predict"] = "�A��·������С�r�g",
["Central Accuracy"] = "���ľ��ʶ�",
["Debug Mode [Dev]"] = "�{ԇģʽ[�_�l��]",
["Cast Mode"] = "ጷ�ģʽ",
["Fast"] = "��",
["Slow"] = "��",
["Collision"] = "��ײ",
["Collision buffer"] = "��ײ���n",
["Normal minions"] = "��ͨС��",
["Jungle minions"] = "Ұ��",
["Others"] = "����",
["Check if minions are about to die"] = "�z�鼴��������С��",
["Check collision at the unit pos"] = "�z���λλ�õ���ײ",
["Check collision at the cast pos"] = "�z��ጷ�λ�õ���ײ",
["Check collision at the predicted pos"] = "�z���A��λ�õ���ײ",
["Developers"] = "�_�l��",
["Enable debug"] = "�����{ԇ",
["Show collision"] = "�@ʾ��ײ",
["Version"] = "�汾",
["--- Fun House Team ---"] = "---�����F�---",
["made by burn & ikita"] = "���� burn & ikita",
["FH Global Settings"] = "�����ϼ�ȫ���O��",
["Amumu"] = "��ľľ",
["5 = Maximum priority = You will focus first!"] = "5 - ����ȼ� -��Ҫ����Ŀ��",
["Target Selector - Extra Setup"] = "Ŀ���x���� - �~���O��",
["- DISTANCE TO IGNORE TARGET (FOCUS MODE) -"] = "�����i��Ŀ�˵ľ��x",
["Default distance"] = " Ĭ�J���x",
["------ DRAWS ------"] = "------ �@ʾ ------",
["This allow you draw your target on"] = "�@��O�����S��Ŀ���@ʾ����Ļ��",
["the screen, for quicker target orientation"] = "�ԫ@�ø����Ŀ�˷���",
["Enable draw of target (circle)"] = "�����@ʾĿ��(��Ȧ)",
["Target circle color"] = "Ŀ�˾�Ȧ�ɫ",
["Enable draw of target (text)"] = "�����@ʾĿ��(����)",
["Select where to draw"] = "�x���@ʾ��λ��",
["Fixed On Screen"] = "�̶�����Ļ��",
["On Mouse"] = "�������",
["--- Draw values ---"] = "--- �@ʾ�O�� ---",
["Draw X location"] = "�@ʾX�Sλ��",
["Draw Y location"] = "�@ʾY�Sλ��",
["Draw size"] = "�@ʾ��С",
["Draw color"] = "�@ʾ�ɫ",
["Reset draw position"] = "���O�@ʾλ��",
["Auto Potions"] = "�Ԅ�ˎˮ",
["Use Health Potion"] = "ʹ��Ѫƿ",
["Use Refillable Potion"] = "ʹ�Ï�����ˎˮ",
["Use Hunters Potion"] = "ʹ�ëC��ˎˮ",
["Use Corrupting Potion"] = "ʹ�ø���ˎˮ",
["Corrupting Potion DPS in Combat"] = "�ڑ��Y��ʹ�ø���ˎˮ���ӂ���",
["Absolute Min Health %"] = "�^������ֵ��С�ٷֱ�",
["In Combat Min Health %"] = "���Y������ֵ��С�ٷֱ�",
["QSS & Cleanse"] = "ˮ�y & ����",
["Enable auto cleanse enemy debuffs"] = "�����ԄӃ���",
["Settings for debuffs"] = "�p��Ч���O��",
["- Global delay before clean debuff -"] = "�ԄӃ�����ȫ�����t",
["Global Default delay"] = "ȫ��Ĭ�J���t",
["- Usual debuffs -"] = "-��Ҏ�p��Ч��-",
["Cleanse if debuff time > than (ms):"] = "����p��Ч���r�g���..ʹ�Ã���",
["- Slow debuff -"] = "- �p�� -",
["Cleanse if slow time > than (ms):"] = "����p�ٕr�g���..ʹ�Ã���",
["- Special cases -"] = "- ������r -",
["Remove Zed R mark"] = "��ٵĴ���",
["Extra Awaraness"] = "�~�����R",
["Enable Extra Awaraness"] = "�����~�����R",
["Warning Range"] = "����Ĺ���",
["Draw even if enemy not visible"] = "��ʹ�����[��Ҳ����",
["Security & Humanizer"] = "��ȫ&�M�˻�",
["------------ SECURITY ------------"] = "------------ ��ȫ ------------",
["Enabling this, you will limit all functions"] = "���ô��O�ã������ƃH�����������",
["to only trigger them if enemy/object"] = "��Ļ�ϕr���й��ܲ���Ч",
["is on your Screen"] = " ",
["Enable extra Security mode"] = "�����~�ⰲȫ�O��",
["------------ HUMANIZER ------------"] = "------------ �M�˻� ------------",
["This will insert a delay between spells"] = "�@��O�Ì���������B�����g�������t",
["If you set too high, it will make combo slow,"] = "����㌢��ֵ�O�����^�ߣ��B�Е�׃��",
["so if you use it increase it gradually!"] = "���������Ҫʹ�õ�Ԓ��Ո�������Ӕ�ֵ",
["Humanize Delay in ms"] = "�M�˻����t(����)",
["Ryze Fun House 2.0"] = "�����ϼ�2.0 - ��Ɲ",
["General"] = "��Ҏ",
["Key binds"] = "�Iλ�O��",
["Auto Q stack out of combat"] = "���B�����Ԅ�Q������",
["Combat"] = "�B��",
["Smart Combo"] = "�����B��",
["Use Items on Combo"] = "���B����ʹ����Ʒ",
["Use Desperate Power (R)"] = "ʹ�ý^��֮��(R)",
["R Cast Mode"] = "Rʹ��ģʽ",
["Required stacks on 'Smart' for cast R"] = "����ʹ��R�r��Ҫ���ӌӔ�",
["Harass"] = "�}�_",
["Use Overload (Q)"] = "ʹ�ó�ؓ��(Q)",
["Use Rune Prison (W)"] = "ʹ�÷��Ľ��d(W)",
["Use Spell Flux (E)"] = "ʹ�÷��gӿ��(E)",
["Use Overload (Q) for last hit"] = "ʹ��Q���aβ��",
["Min Mana % to use Harass"] = "�}�_����С�{�� %",
["Auto kill"] = "�Ԅӓ���",
["Enable Auto Kill"] = "�����Ԅӓ���",
["Auto KS under enemy towers"] = "�ڔ��������Ԅӓ����^",
["Farming"] = "ˢ��",
["Lane Clear"] = "�往",
["Min Mana % for lane clear"] = "�往����С�{�� %",
["Last Hit"] = "β��",
["Use Q for last hit"] = "ʹ��Q���aβ��",
["Last Hit with AA"] = "ʹ��ƽA���aβ��",
["Min Mana % for Q last hit"] = "Q�aβ������С�{��",
["Drawings"] = "�@ʾ�O��",
["Spell Range"] = "���ܾ�Ȧ",
["Enable Draws"] = "�����@ʾ",
["Draw Q range"] = "�@ʾQ����",
["Q color"] = "Q��Ȧ�ɫ",
["Draw W-E range"] = "�@ʾW-E����",
["W-E color"] = "W-E��Ȧ�ɫ",
["Draw Stacks"] = "�@ʾ���ӌӔ�",
["Use Lag Free Circle"] = "ʹ�ò�Ӱ����t�ľ�Ȧ",
["Kill Texts"] = "������ʾ",
["Use KillText"] = "���Ó�����ʾ",
["Draw KillTime"] = "�@ʾ�����r�g",
["Text color"] = "�����ɫ",
["Draw Damage Lines"] = "�@ʾ����ָʾ��",
["Damage color display"] = "�@ʾ�������ɫ",
["Miscellaneous"] = "�s��O��",
["Auto Heal"] = "�Ԅ��ί�",
["Automatically use Heal"] = "ʹ���Ԅ��ί�",
["Min percentage to cast Heal"] = "ʹ���ί�����СѪ�� %",
["Use Heal to Help teammates"] = "����܊ʹ���ί�",
["Teammates to Heal"] = "ʹ���ί�����܊",
["Auto Zhonyas"] = "�Ԅ��Ё�",
["Automatically Use Zhonyas"] = "�Ԅ�ʹ���Ё�",
["Min Health % to use Zhonyas"] = "ʹ���Ё�����СѪ��",
["Use W on enemy gap closers"] = "��������ͻ�Mʹ��W",
["Auto Q for get shield vs gap closers"] = "�Ԅ�Q��@���o���ԵֶRͻ�M",
["Auto use Seraph's Embrace on low Health"] = "��Ѫ���r�Ԅ�ʹ�ô���ʹ",
["Min % to cast Seraph's Embrace"] = "ʹ�ô���ʹ����СѪ�� %",
["Prediction"] = "�A��",
["-- Prediciton Settings --"] = "------ �A���O�� ------",
["VPrediction"] = "V�A��",
["DPrediction"] = "���}�A��",
["-- VPrediction Settings --"] = "------ V�A���O�� ------",
["Q Hit Chance"] = "Q�����ЙC��",
["Medium"] = "�е�",
["High"] = "��",
["-- HPrediction Settings --"] = "------ H�A���O�� ------",
["-- DPrediction Settings --"] = "----- ���}�A���O�� -----",
["Instant force W"] = "��������ʹ��W",
["Flee Key"] = "���ܰ��I",
["Toggle Parry Auto Attack"] = "�ГQ����Ԅӹ���",
["Orbwalk on Combo"] = "���B���е��߿�",
["To Vital"] = "�Ƅ������c",
["To Target"] = "�Ƅ���Ŀ��",
["Disabled"] = "�P�]",
["Orbwalk Magnet Range"] = "�߿���������",
["Vital Strafe Outwards Distance %"] = "�������c����������x%",
["Fiora Fun House 2.0"] = "�����ϼ�2.0 - �ƊW��",
["Orbwalk Settings"] = "�߿��O��",
["W Hit Chance"] = "W�������еęC��",
["Draw R range"] = "�@ʾR�Ĺ���",
["Draw AA range"] = "�@ʾƽA�Ĺ���",
["Use IGNITE"] = "ʹ���cȼ",
["Q Color"] = "Q���ܾ�Ȧ�ɫ",
["Combo"] = "�B��",
["--- Combo Logic ---"] = "--- �B��߉݋ ---",
["Save Q for dodge enemy hard spells"] = "����Q���ܔ��˵���Ҫ����",
["Q Gapclose regardless of vital"] = "ʹ��Qͻ�M�r�������c",
["Gapclose min catchup time"] = "ͻ�M��С׷�s�r�g",
["Q minimal landing position"] = "Q�����ጷ�λ��",
["Q Angle in degrees"] = "Q�ĽǶ�",
["Q on minion to reach enemy"] = "QС����ӽ�����",
["--- Ultimate R Logic ---"] = "--- ����ʹ��߉݋ ---",
["Focus R Casted Target"] = "�i��ʹ��R��Ŀ��",
["Cast when target killable"] = "��Ŀ�˿��Ա������rʹ��R",
["Cast only when healing required (overrides above)"] = "�л�Ѫ��Ҫ�r��R",
["Cast when our HP less than %"] = "������ֵС�%�rʹ��R",
["Cast before KS with Q when lower than"] = "����Q�����^֮ǰʹ��R",
["Riposte Options"] = "�ڂ������۵�(W)�O��",
["Riposte Enabled"] = "ʹ��W",
["Save Q Evadeee when Riposte cd"] = "��Wcd�r����Q����",
["Auto Parry next attack when %HP <"] = "������ֵС�%�r�ԄӸ����һ����ͨ����",
["Humanizer: Extra delay"] = "�M�˻����~�����t",
["Parry Summoner Spells (low latency)"] = "����ن�������(�����t)",
["Parry Dragon Wind"] = "���С���Ĺ���",
["Parry Auto Attacks"] = "�����ͨ����",
["Parry AA Damage Threshold"] = "���ƽA�Ă����R��ֵ",
["Parry is still a Work In Progress"] = "��������������_�l�Ĺ���",
["If is not parrying a spell from the list,"] = "����]�и���б��еļ���",
["before report on forum, make a list like:"] = "��Փ�����֮ǰ����һ��������һ�ӵ��б�",
["Champion-Spell that fails to parry"] = "���ʧ���ļ��ܣ�������д��20��",
["When you have 20+ added, post it on forum. Thanks"] = "�o������ļ��ܣ�Ո�l����Փ����",
["Riposte Main List"] = "�����Ҫ�����б�",
["--- Riposte Spells At Arrival ---"] = "--- ���������еĕr���� ---",
["Riposte Extra List"] = "����~�⼼���б�",
["Use Q on Harass"] = "���}�_��ʹ��Q",
["Use Lunge (Q)"] = "ʹ���ƿՔ�Q",
["Use Riposte (W) [only on Jungle]"] = "ʹ�Äڂ������۵�W[ֻ��Ұ��]",
["Use Bladework (E)"] = "ʹ�ÊZ���B��E",
["Use items"] = "ʹ����Ʒ",
["R Color"] = "R�����ɫ",
["AA Color"] = "ƽA��Ȧ�ɫ",
["Draw Magnet Orbwalk range"] = "�@ʾ�߿���������",
["Draw Flee direction"] = "�@ʾ���ܷ���",
["Draw KillText"] = "�@ʾ������ʾ",
["HPrediction"] = "H�A��",
["SxOrbWalk"] = "Sx�߿�",
["General-Settings"] = "��Ҏ�O��",
["Orbwalker Enabled"] = "�߿���Ч",
["Stop Move when Mouse above Hero"] = "��Ӣ��������rֹͣ�Ƅ�",
["Range to Stop Move"] = "ֹͣ�Ƅӵą^��",
["ExtraDelay against Cancel AA"] = "ȡ��ƽA��u���~�����t",
["Spam Attack on Target"] = "�����ܶ��ƽAĿ��",
["Orbwalker Modus: "] = "�߿�ģʽ",
["To Mouse"] = "�����",
["Humanizer-Settings"] = "�M�˻��O��",
["Limit Move-Commands per Second"] = "����ÿ��l�͵��Ƅ�ָ��",
["Max Move-Commands per Second"] = "ÿ��l���Ƅ�ָ������Δ�",
["Key-Settings"] = "�Iλ�O��",
["FightMode"] = "���Yģʽ",
["HarassMode"] = "�}�_ģʽ",
["LaneClear"] = "�往",
["LastHit"] = "β��",
["Toggle-Settings"] = "�ГQ�O��",
["Make FightMode as Toggle"] = "�@ʾ���Yģʽ�ГQ",
["Make HarassMode as Toggle"] = "�@ʾ�}�_ģʽ�ГQ",
["Make LaneClear as Toggle"] = "�@ʾ�往ģʽ�ГQ",
["Make LastHit as Toggle"] = "�@ʾβ��ģʽ�ГQ",
["Farm-Settings"] = "ˢ���O��",
["Focus Farm over Harass"] = "���}�_�r�����a��",
["Extra-Delay to LastHit"] = "β���r���~�����t",
["Mastery-Settings"] = "���x�O��",
["Mastery: Butcher"] = "����",
["Mastery: Arcane Blade"] = "�p�Є�",
["Mastery: Havoc"] = "����",
["Mastery: Devastating Strikes"] = "������",
["Draw-Settings"] = "�@ʾ�O��",
["Draw Own AA Range"] = "�@ʾ�Լ���ƽA��Ȧ",
["Draw Enemy AA Range"] = "�@ʾ���˵�ƽA��Ȧ",
["Draw LastHit-Cirlce around Minions"] = "��С�����@ʾβ����Ȧ",
["Draw LastHit-Line on Minions"] = "��С�����@ʾβ��ָʾ��",
["Draw Box around MinionHpBar"] = "��С��Ѫ�l�Ϯ����_",
["Color-Settings"] = "�ɫ�O��",
["Color Own AA Range: "] = "�Լ���ƽA��Ȧ���ɫ",
["white"] = "��ɫ",
["blue"] = "�{ɫ",
["red"] = "�tɫ",
["black"] = "��ɫ",
["green"] = "�Gɫ",
["orange"] = "��ɫ",
["Color Enemy AA Range (out of Range): "] = "����ƽA��Ȧ���ɫ(������)",
["Color Enemy AA Range (in Range): "] = "����ƽA��Ȧ���ɫ(������)",
["Color LastHit MinionCirlce: "] = "С��β����Ȧ�ɫ",
["Color LastHit MinionLine: "] = "С��β��ָʾ���ɫ",
["ColorBox: Minion is LasthitAble: "] = "С���ɱ�β�����ɫ",
["none"] = "�o",
["ColorBox: Wait with LastHit: "] = "С���ȴ���β�����ɫ",
["ColorBox: Can Attack Minion: "] = "���Թ�����С���ɫ",
["TargetSelector"] = "Ŀ���x����",
["Priority Settings"] = "���ȼ��ɫ",
["Focus Selected Target: "] = "�i���x����Ŀ��",
["never"] = "�Ĳ�",
["when in AA-Range"] = "����ƽA�����r",
["TargetSelector Mode: "] = "Ŀ���x����ģʽ",
["LowHP"] = "��Ѫ��",
["LowHPPriority"] = "��Ѫ��+���ȼ�",
["LessCast"] = "����ጷż���",
["LessCastPriority"] = "����ጷż���+���ȼ�",
["nearest myHero"] = "�x�Լ���Ӣ�����",
["nearest Mouse"] = "�x������",
["RawPriority"] = "���O���ȼ�",
["Highest Priority (ADC) is Number 1!"] = "��߃��ȼ�(ADC)��1",
["Debug-Settings"] = "�{ԇģʽ",
["Draw Circle around own Minions"] = "�ڼ���С���Ϯ�Ȧ",
["Draw Circle around enemy Minions"] = "�ڔ���С���Ϯ�Ȧ",
["Draw Circle around jungle Minions"] = "��Ұ���Ϯ�Ȧ",
["Draw Line for MinionAttacks"] = "�@ʾС������ָʾ��",
["Log Funcs"] = "���I����",
["Irelia Fun House 2.0"] = "�����ϼ�2.0 - ������I",
["R Lane Clear toggle"] = "R�往�ГQ",
["Force E"] = "����E",
["Q on killable minion to reach enemy"] = "���ɓ�����С��ʹ��Q��ͻ�M����",
["Use Q only as gap closer"] = "�Hͻ�M�rʹ��Q",
["Minimum distance for use Q"] = "ʹ��Q����С���x",
["Save E for stun"] = "����E�Á�ѣ��",
["Use E for slow if enemy run away"] = "�����������ʹ��E��p��",
["Use E for interrupt enemy dangerous spells"] = "ʹ��E������˵�Σ�U����",
["Anti-gapclosers with E stun"] = "ʹ��Eѣ����ͻ�M",
["Use R on sbtw combo"] = "ֻ���B����ʹ��R",
["Cast R when our HP less than"] = "���������ֵ���%�rʹ��R",
["Cast R when enemy HP less than"] = "����������ֵ���%�rʹ��R",
["Block R in sbtw until Sheen/Tri Ready"] = "����Rֱ��ҫ��Ч���;w",
["In Team Fight, use R as AOE"] = "�ڈF����ʹ��R��AOE",
["Use Bladesurge (Q) on minions"] = "��С��ʹ��Q",
["Use Bladesurge (Q) on target"] = "��Ŀ��ʹ��Q",
["Use Equilibrium Strike (W)"] = "ʹ��W",
["Use Equilibrium Strike (E)"] = "ʹ��E",
["Use Bladesurge (Q)"] = "ʹ��Q",
["Use Transcendent Blades (R)"] = "ʹ��R",
["Only Q minions that can't be AA"] = "ֻ������ƽA��С��ʹ��Q",
["Block Q on Jungle unless can reset"] = "����Qֱ��Ұ�ֿ��Ա�Q����",
["Block Q on minions under enemy tower"] = "�ڔ������r����Q",
["Humanizer delay between Q (ms)"] = "Q֮�g�ĔM�˻����t(����)",
["Use Hiten Style (W)"] = "ʹ��W",
["No. of minions to use R"] = "ʹ��R������С������",
["Maximum distance for Q in Last Hit"] = "ʹ��Qβ���������x",
["E Color"] = "E��Ȧ���ɫ",
["Auto Ignite"] = "�Ԅ��cȼ",
["Automatically Use Ignite"] = "�Ԅ�ʹ���cȼ",
----------------����Ϲ��---------------------
["Lee Sin Fun House 2.0"] = "�����ϼ�2.0 - äɮ",
["Lee Sin Fun House"] = "����äɮ",
["Ward Jump Key"] = "���۰��I",
["Insec Key"] = "Insec���I",
["Jungle Steal Key"] = "�������I",
["Insta R on target"] = "������Ŀ��ʹ��R",
["Disable R KS in combo 4 sec"] = "��4����P�]��R�����^",
["Combo W->R KS (override autokill)"] = "W->R�����^�B��",
["Passive AA Spell Weave"] = "����֮�g㕽ӱ���ƽA",
["Smart"] = "ֻ��",
["Quick"] = "����",
["Use Stars Combo: RQQ"] = "ʹ�������B�У�RQQ",
["Use Q-Smite for minion block"] = "��С����ס�rʹ��Q�ͽ�",
["Use W on Combo"] = "���B����ʹ��W",
["Use wards if necessary (gap closer)"] = "ʹ��Wͻ�M����(�����Ҫ)",
["Cast R when it knockups at least"] = "����ܓ��wx������ʹ��R",
["Cast W to Mega Kick position"] = "ʹ��W�������߶������˵�λ��",
["Use R to stop enemy dangerous spells"] = "ʹ��R�������˵�Σ�U����",
["-- ADVANCED --"] = "-- �߼��O�� --",
["Combo-Insec value Target"] = "ޒ����Ŀ��",
["Combo-Insec with flash"] = "ʹ��R�Wޒ����",
["Use R-flash if no W or wards"] = "����]��W���ߛ]����ʹ��R�W",
["Use W-R-flash if Q cd (BETA)"] = "���Qcdʹ��W-R�W(�yԇ)",
["Insec Mode"] = "ޒ����ģʽ",
["R Angle Variance"] = "R�ĽǶ��{��",
["KS Enabled"] = "���Ó����^",
["Autokill Under Tower"] = "�������Ԅӓ���",
["Autokill Q2"] = "ʹ�ö���Q�Ԅӓ���",
["Autokill R"] = "ʹ��R�Ԅӓ���",
["Autokill Ignite"] = "ʹ���cȼ�Ԅӓ���",
["--- LANE CLEAR ---"] = "--- �往 ---",
["LaneClear Sonic Wave (Q)"] = "ʹ��Q�往",
["LaneClear Safeguard (W)"] = "ʹ��W�往",
["LaneClear Tempest (E)"] = "ʹ��E�往",
["LaneClear Tiamat Item"] = "ʹ���၆�R���往",
["LaneClear Energy %"] = "�往��������%",
["--- JUNGLE CLEAR ---"] = "--- ��Ұ ---",
["Jungle Sonic Wave (Q)"] = "ʹ��Q��Ұ",
["Jungle Safeguard (W)"] = "ʹ��W��Ұ",
["Jungle Tempest (E)"] = "ʹ��E��Ұ",
["Jungle Tiamat Item"] = "ʹ���၆�R����Ұ",
["Use E if AA on cooldown"] = "ʹ��E�����չ�",
["Use Q for harass"] = "ʹ��һ��Q�}�_",
["Use Q2 for harass"] = "ʹ�ö���Q�}�_",
["Use W for retreat after Q2+E"] = "����Q+E��ʹ��W����",
["Use E for harass"] = "ʹ��E�����}�_",
["-- Spells Range --"] = "-- ���ܹ�����Ȧ --",
["Draw W range"] = "�@ʾW����",
["W color"] = "W���ܾ�Ȧ�ɫ",
["Draw E range"] = "�@ʾE���ܹ���",
["Combat Draws"] = "�@ʾ���Y",
["Insec direction & selected points"] = "ޒ���ߵĵ��c&�x���ĵ��c",
["Collision & direction for direct R"] = "��ײ&ֱ��R�ķ���",
["Draw non-Collision R direction"] = "�@ʾ�o��ײ��R�ķ���",
["Collision & direction Prediction"] = "��ײ&�����A��",
["Draw Damage"] = "�@ʾ����",
["Draw Kill Text"] = "�@ʾ������ʾ",
["Debug"] = "�{ԇ",
["Focus Selected Target"] = "�i���x���Ŀ��",
["Always"] = "����",
["Auto Kill"] = "�Ԅӓ���",
["Insec Wardjump Range Reduction"] = "ޒ�������۹����p��",
["Magnetic Wards"] = "��������Բ���",
["Enable Magnetic Wards Draw"] = "���������Բ����@ʾ",
["Use lfc"] = "ʹ��lfc",
["--- Spots to be Displayed ---"] = "--- �@ʾ�Ĳ����c ---",
["Normal Spots"] = "��ͨ���c",
["Situational Spots"] = "ȡ�Q���r�ĵ��c",
["Safe Spots"] = "��ȫ���c",
["--- Spots to be Auto Casted ---"] = "--- �ԄӲ��۵ĵ��c ---",
["Disable quickcast/smartcast on items"] = "���ÿ���/����ʹ����Ʒ",
["--- Possible Keys for Trigger ---"] = "--- �����|�l�İ��I ---",
--------------�����ыD----------------------
["Evelynn Fun House 2.0"] = "�����ϼ�2.0 - ��ܽ��",
["Force R Key"] = "���ƴ��а��I",
["Use Agony's Embrace (R)"] = "ʹ��R",
["Required enemies to cast R"] = "ʹ��R��Ҫ�Ĕ��˔�",
["Auto R on low HP as life saver"] = "�ڵ�Ѫ���ĕr���Ԅ�R�Ծ���",
["Minimum % of HP to auto R"] = "�Ԅ�R����С�|�l����ֵ",
["Use Hate Spike (Q)"] = "ʹ������֮��(Q)",
["Use Ravage (E)"] = "ʹ�Ú�����(E) ",
["Draw A range"] = "�@ʾƽA����",
["A color"] = "ƽA��Ȧ�ɫ",
["Reverse Passive Vision"] = "���D����ҕҰ",
["Vision Color"] = "ҕҰ�ɫ",
["Stealth Status"] = "�[���B",
["Spin Color"] = "���D�ɫ",
["Info Box"] = "��Ϣ��",
["X position of menu"] = "�ˆε�X�Sλ��",
["Y position of menu"] = "�ˆε�Y�Sλ��",
["W Settings"] = "W�����O��",
["Use W on flee mode"] = "������ģʽʹ��W",
["Use W for cleanse enemy slows"] = "ʹ��W���Ƴ����˵Ĝp��",
["R Hit Chance"] = "R���еęC��",
["E color"] = "E��Ȧ�ɫ",
["R color"] = "R��Ȧ�ɫ",
["Key Binds"] = "�Iλ�O��",
--------------������Ů�{�ӹ��S�u------------
["FH Smite"] = "���� �ͽ�",
["Jungle Camps"] = "Ұ�֠I��",
["Enable Auto Smite"] = "�����Ԅӑͽ�",
["Temporally Disable Autosmite"] = "���r���Ñͽ�",
["--- Global Objectives ---"] = "--- ȫ��Ŀ�� ---",
["Rift Scuttler Top"] = "��·�ӵ�з",
["Rift Herald"] = "�{�����h",
["Rift Scuttler Bot"] = "��·�ӵ�з",
["Baron"] = "����",
["Dragon"] = "С��",
["--- Normal Camps ---"] = "-- ��ͨҰ�� --",
["Murk Wolf"] = "��Ӱ��",
["Red Buff"] = "�tbuff",
["Blue Buff"] = "�{buff",
["Gromp"] = "ħ����",
["Raptors"] = "�h��B(F4)",
["Krugs"] = "ʯ���x",
["Chilling Smite KS"] = "��˪�ͽ䓌���^",
["Chilling Smite Chase"] = "��˪�ͽ�׷��",
["Challenging Smite Combat"] = "���B����ʹ������ͽ�",
["Forced Smite on Enemy"] = "���Ƒͽ䔳��",
["Draw Smite % damage"] = "�@ʾ�ͽ�ٷֱȂ���",
["Smite Fun House"] = "�ͽ� ����",
["Taric"] = "�����",
["Nidalee Fun House 2.0"] = "�����ϼ�2.0 - �ε���",
["Nidalee Fun House"] = "�����ϼ� - �ε���",
["Harass Toggle Q"] = "Q�}�_�_�P",
["Use W on combo (human form)"] = "���B����ʹ��W(���ΑB)",
["Immobile"] = "�����Ƅӵ�",
["Mana Min percentage W"] = "W����С�{��%",
["E for SpellWeaving/DPS"] = "ʹ��E������ݔ��",
["Auto heal E"] = "E�ԄӼ�Ѫ",
["Self"] = "�Լ�",
["Self/Ally"] = "�Լ�/��܊",
["Min percentage hp to auto heal"] = "�ԄӼ�Ѫ����С�|�lѪ��%",
["Min mana to cast E"] = "ʹ��E����С�{��",
["Smart R swap"] = "����R�ГQ�ΑB",
["Allow Mid-Jump Transform"] = "���S���S�Ŀ���׃�Q�ΑB",
["Harass (Human form)"] = "�}�_(���ΑB)",
["Use Javelin Toss (Q)"] = "ʹ�����ΑBQ�}�_",
["Use Toggle Key Override (Keybinder Menu)"] = "ʹ�ð��I�_�P���w",
["Min mana to cast Q"] = "ʹ��Q����С�{��",
["Flee"] = "����",
["W for Wall Jump Only"] = "Wֻ�Á�����",
["Lane Clear with AA"] = "ʹ��ƽA�往",
["Use Bushwhack (W)"] = "ʹ�����ΑBW",
["Use Primal Surge (E)"] = "ʹ�����ΑBE",
["Use Takedown (Q)"] = "ʹ�ñ��ΑBQ",
["Use Pounce (W)"] = "ʹ�ñ��ΑBW",
["Use Swipe (E)"] = "ʹ�ñ��ΑBE",
["Use Aspect of the Cougar (R)"] = "ʹ��R",
["Mana Min percentage"] = "��С�{���ٷֱ�",
["Draw Q range (Human)"] = "�@ʾ���ΑBQ����",
["Draw W range (Human)"] = "�@ʾ���ΑBW����",
["W color (Human)"] = "���ΑBW��Ȧ�ɫ",
["Draw E range (Human)"] = "�@ʾ���ΑBE����",
["Karthus"] = "�����_˹",
["Rengar Fun House 2.0"] = "�����ϼ�2.0 - �׶��Ӡ�",
["Rengar Fun House"] = "�����ϼ� - �׶��Ӡ�",
["Force E Key"] = "����E���I",
["Combo Mode Key"] = "�B��ģʽ���I",
["Use empower W if health below %"] = "������ֵ���%ʹ�Ï���W",
["Min health % for use it ^"] = "ʹ�õ���С����ֵ%",
["Use E on Dynamic Combo if enemy is far"] = "������˾��x���h�ڄӑB�B����ʹ��E",
["Playing AP rengar !"] = "AP�{�ӹ�ģʽ",
["Use E on AP Combo if enemy is far"] = "������˾��x���h��AP�B����ʹ��E",
["Anti Dashes"] = "��ͻ�M",
["Antidash Enemy Enabled"] = "�����ˆ��÷�ͻ�M",
["LaneClear Savagery (Q)"] = "���往��ʹ��Q",
["LaneClear Battle Roar (W)"] = "���往��ʹ��W",
["LaneClear Bola Strike (E)"] = "���往��ʹ��E",
["stop using spells at 5 stacks"] = "5�񚈱��ĕr��ֹͣʹ�ü���",
["Jungle Savagery (Q)"] = "����Ұ��ʹ��Q",
["Jungle Battle Roar (W)"] = "����Ұ��ʹ��W",
["Jungle Bola Strike (E)"] = "����Ұ��ʹ��E",
["Jungle Savagery (Q) Empower"] = "����Ұ��ʹ�Ï���Q",
["Jungle Battle Roar (W) Empower"] = "����Ұ��ʹ��W",
["Use Q if AA on cooldown"] = "ʹ��Q�������չ�",
["Use W if AA on cooldown"] = "ʹ��W�������չ�",
["Use W for harass"] = "ʹ��W�}�_",
["Draw R timer"] = "�@ʾR�ĕr�g",
["Draw R Stealth Distance"] = "�@ʾR�[����x",
["Draw R on:"] = "�@ʾR��B:",
["Center of screen"] = "����Ļ����",
["Champion"] = "Ӣ��",
["-- Draw Combo Mode values --"] = "-- �@ʾ�B��ģʽ�O�� --",
["E Hit Chance"] = "E���еęC��",
["Swain"] = "˹�S��",
["Azir Fun House 2.0"] = "�����ϼ�2.0 - ��Ɲ��",
["Force Q"] = "����Q",
["Quick Dash Key"] = "����ͻ�M���I",
["Panic R"] = "�@��ģʽR",
["--- Q LOGIC ---"] = "--- Q����߉݋ ---",
["Q prioritize soldier reposition"] = "Q��������ɳ����λ��",
["Always expend W before Q Cast"] = "����Q֮ǰ��W",
["--- W LOGIC ---"] = "--- W����߉݋ ---",
["W Cast Method"] = "ጷ�W�ķ�ɹ˪",
["Always max range"] = "�����������x",
["Min Mana % to cast extra W"] = "ጷ��~��W����С�{��%",
["--- E LOGIC ---"] = "--- E����߉݋ ---",
["E to target when safe"] = "����ȫ�rE��Ŀ��",
["--- R LOGIC ---"] = "--- R����߉݋ ---",
["Single target R in melee range"] = "̎춽��𹥓����x�ĕr��ֻRһ��Ŀ��",
["To Soldier"] = "��ɳ��ጷ�",
["To Ally/Tower"] = "����܊/��ጷ�",
["Single target R only under self HP"] = "ֻ���Լ�����ֵ���x�rֻRһ��Ŀ��",
["Multi target R logic"] = "��Ŀ��R߉݋",
["Block"] = "����",
["Multi target R at least on"] = "��Ŀ��R�r��СĿ�˔�",
["R enemies into walls"] = "�є�܊�Ƶ����e",
["Use orbwalking on combo"] = "���B����ʹ���߿�",
["--- Automated Logic ---"] = "--- �ԄӼ���߉݋ ---",
["Auto R when at least on"] = "��Ŀ��������x���r�Ԅ�R",
["Block Sion Ult (Beta)"] = "�֓�������R(�yԇ)",
["Interrupt channelled spells with R"] = "ʹ��R�����������",
["R enemies back into tower range"] = "�є����Ƶ���������",
["Block Gap Closers with R"] = "ʹ��R��ͻ�M",
["R-Combo Casts"] = "ʹ��R�B��",
["--- COMBO-DASH LOGIC ---"] = "--- ͻ�M�B��߉݋ ---",
["Smart DASH chase in combo"] = "��׷���rʹ������ͻ�M�B��",
["Min Self HP % to smart dash"] = "��������ֵ���%�rʹ������ͻ�M",
["Max target HP % to smart dash"] = "Ŀ������ֵС�%�rʹ������ͻ�M",
["Max target HP % dash in R CD"] = "Rcd�rĿ��",
["ASAP R to ally/tower after dash hit"] = " ",
["Dash R Area back range"] = " ",
["--- COMBO-INSEC LOGIC ---"] = "--- Insec�B��߉݋ ---",
["Smart new-INSEC in combo"] = "���B����ʹ��������Insec�B��",
["new-Insec only x allies more"] = "ֻ�ڴ��x����܊�rʹ����Insec�B��",
["Use W on Harass"] = "���}�_��ʹ��W",
["Number of W used"] = "ʹ��W�Ĕ���",
["Insec / Dash"] = "Insec / ͻ�M",
["Min. gap from soldier in dash"] = "ͻ�M�r���ٴ��ڵ�ɳ����",
["Abs. R delay after Q cast"] = "��Qጷ���ጷ�R�����t",
["Insec Extension"] = "Insec��������x",
["From Soldier"] = "��ɳ��",
["From player"] = "�������",
["Direct Hit"] = "ֱ�ӓ���",
["Use Conquering Sands (Q)"] = "ʹ��Q",
["Use Shifting Sands (E)"] = "ʹ��E",
["Use Emperor's Divide (R)"] = "ʹ��R",
["Use Arise! (W)"] = "ʹ��W",
["Number of Soldiers"] = "ɳ����Ŀ",
["Use W for AA if outside AA range"] = "�����ƽA������ʹ��W����",
["Draw Soldier range"] = "�@ʾɳ���Ĺ�������",
["Draw Soldier time"] = "�@ʾɳ�����m�r�g",
["Draw Soldier Line"] = "�@ʾɳ��ָʾ��",
["Soldier and line color"] = "ɳ����ָʾ�������ɫ",
["Soldier out-range color"] = "�������ɳ�����ɫ",
["Draw Dash Area"] = "�@ʾͻ�M�ą^��",
["Dash color"] = "ͻ�M�^���ɫ",
["Draw Insec range"] = "�@ʾInsec�Ĺ���",
["Insec Draws"] = "Insec�@ʾ",
["Draw Insec Direction on target"] = "��Ŀ�����@ʾInsec�ķ���",
["Cast Ignite on Swain"] = "��˹�S��ʹ���cȼ",
--------------QQQ����-----------------------
["Yasuo - The Windwalker"] = "�L���� - ����",
["----- General settings --------------------------"] = "----- �����O�� --------------------------",
["> Keys"] = "> ���I�O��",
["> Orbwalker"] = "> �߿��O��",
["> Targetselector"] = "> Ŀ���x����",
["> Prediction"] = "> �A���O��",
["> Draw"] = "> �@ʾ�O��",
["> Cooldowntracker"] = "> ��sӋ�r",
["> Scripthumanizer"] = "> �_���M�˻�",
["----- Utility settings -----------------------------"] = "----- �����O�� --------------------------",
["> Windwall"] = "> �L��",
["> Ultimate"] = "> ����",
["> Turretdive"] = "> Խ��",
["> Gapclose"] = "> ͻ�M",
["> Walljump"] = "> ����",
["> Spells"] = "> ����",
["> Summonerspells"] = "> �ن�������",
["> Items"] = "> ��Ʒ",
["----- Combat settings ----------------------------"] = "----- ���Y�O�� --------------------------",
["> Combo"] = "> �B��",
["> Harass"] = "> �}�_",
["> Killsteal"] = "> �����^",
["> Lasthit"] = "> β��",
["> Laneclear"] = "> �往",
["> Jungleclear"] = "> ��Ұ",
["----- About the script ---------------------------"] = "�P춱��_��",
["Gameregion"] = "�[��^��",
["Scriptversion"] = "�_���汾",
["Author"] = "����",
["Updated"] = "��������",
["\"The road to ruin is shorter than you think...\""] = "����֮·,�̵ĳ����������",
["This section is only a placeholder for more structure"] = "�@������ֻ�Ǵ���Ӄ��ݵ��A��λ��",
["Choose targetselector mode"] = "�x��Ŀ���x����λ��",
["LESS_CAST"] = "����ʹ�ü���",
["LOW_HP"] = "��Ѫ��",
["SELECTED_TARGET"] = "�x����Ŀ��",
["PRIORITY"] = "���ȼ�",
["Set your priority here:"] = "���@�e�O�����ȼ�",
["No targets found / available! "] = "�]���ҵ�Ŀ��",
["Draw your current target with circle:"] = "����Į�ǰĿ���Ϯ�Ȧ",
["Draw your current target with line:"] = "����Į�ǰĿ���Ϯ���",
["Use Gapclose"] = "ʹ��ͻ�M",
["Check health before gapclosing under towers"] = "������ͻ�M�r�z��Ѫ��",
["Only gapclose if my health > % "] = "ֻ���ҵ�Ѫ�����%�rͻ�M",
["> Settings "] = "> �O��",
["Set Gapclose range"] = "�O��ͻ�M���x",
["Draw gapclose target"] = "�@ʾͻ�MĿ��",
["> General settings"] = "> ��Ҏ�O��",
["Use Autowall: "] = "ʹ���Ԅ��L��:",
["Draw skillshots: "] = "�������܏���",
["> Humanizer settings"] = "> �M�˻��O��",
["Use Humanizer: "] = "ʹ�ÔM�˻�",
["Humanizer level"] = "�M�˻��ȼ�",
["Normal mode"] = "��ͨģʽ",
["Faker mode"] = "Fakerģʽ",
["> Autoattack settings"] = "> ��ͨ�����O��",
["Block autoattacks: "] = "������ͨ����:",
["if your health is below %"] = "����������ֵ���%",
["> Skillshots"] = "> ���܏���",
["No supported skillshots found!"] = "�]���ҵ�֧�ֵļ���",
["> Targeted spells"] = "> ָ���Լ���",
["No supported targeted spells found!"] = "�]���ҵ�֧�ֵ�ָ���Լ���",
[">> Towerdive settings"] = ">> Խ���O��",
["Towerdive Mode"] = "Խ��ģʽ",
["Never dive turrets"] = "�Ĳ�Խ��",
["Advanced mode"] = "�߼�ģʽ",
["Draw turret range: "] = "�@ʾ���R������: ",
[">> Normal Mode Settings"] = ">> ��ͨģʽ�O��",
["Min number of ally minions"] = "��С�ѷ�С����",
[">> Easy Mode Settings"] = ">> ����ģʽ�O��",
["Min number of ally champions"] = "��С�ѷ�Ӣ�۔�",
["> Info about normal mode"] = "> ��ͨģʽ��B",
[">| The normal mode checks for x number of ally minions"] = ">| ��ͨģʽ���z����R�����ѷ�С���Ĕ���",
[">| under enemy turrets. If ally minions >= X then it allows diving!"] = ">| ����ѷ�С������춵��x�͕����SԽ��",
["> Info about advanced mode"] = "> �߼�ģʽ��B",
[">| The advanced mode checks for x number of ally minions"] = "�߼�ģʽ���z����R�����ѷ�С������",
[">| as well as for x number of ally champions under enemy turrets."] = "�ͷ��R���ѷ�Ӣ�۔���",
[">| If both >= X then it allows diving!"] = "�������춵��x�͕����SԽ��",
["Always draw the indicators"] = "�����@ʾ�����A�y",
["Only draw while holding"] = "ֻ���ڰ��I�ĕr����@ʾ",
["Not draw inidicator if pressed"] = "�ڰ��I�ĕr���@ʾ",
["> Draw cooldowns for:"] = "> �@ʾcd�r�g",
["your enemies"] = "����Ӣ��",
["your allies"] = "�ѷ�Ӣ��",
["your hero"] = "�Լ�",
["Show horizontal indicators"] = "�@ʾˮƽ�Ă����A�y",
["Show vertical indicators"] = "�@ʾ��ֱ�Ă����A�y",
["Vertical position"] = "��ֱ�����A�y��λ��",
["> Choose your Color"] = "> �x���ɫ",
["Cooldown color"] = "cdӋ�r�ɫ",
["Ready color"] = "���ܾ;w���ɫ",
["Background color"] = "�����ɫ",
["> Summoner Spells"] = "> �ن�������",
["Flash"] = "�W�F",
["Ghost"] = "���`����",
["Barrier"] = "����",
["Smite"] = "�ͽ�",
["Exhaust"] = "̓��",
["Heal"] = "�ί�",
["Teleport"] = "����",
["Cleanse"] = "����",
["Clarity"] = "�����g",
["Clairvoyance"] = "����",
["The Rest"] = "����",
[">> Combat keys"] = ">> ���Y���I",
["Combo key"] = "�B�а��I",
["Harass key"] = "�}�_���I",
["Harass (toggle) key"] = "�}�_(�_�P)���I",
["Ultimate (toggle) key"] = "����(�_�P)���I",
[">> Farm keys"] = ">> �l�����I",
["Lasthit key"] = "β�����I",
["Jungle- and laneclear key: "] = "��Ұ���往���I",
[">> Other keys"] = ">> �������I",
["Escape-/Walljump key"] = "����/�������I",
["Autowall (toggle) key"] = "�Ԅ��L��(�_�P)���I",
["Use walljump"] = "ʹ�ô���",
["Priority to gain vision"] = "�@��ҕҰ�ă��ȼ�",
["Wards"] = "��",
["Wall"] = "�L��",
["> Draw jumpspot settings"] = "> �@ʾ����λ��",
["Draw points"] = "�@ʾ�c",
["Draw jumpspot while key pressed"] = "���I���r�@ʾ����λ��",
["Radius of the jumpspots"] = "�����c�돽",
["Max draw distance"] = "����@ʾ���x",
["Draw line to next jumpspots"] = "�@ʾ����һ�����c��ֱ��",
["> Draw jumpspot colors"] = "> �@ʾ�����c���ɫ",
["Jumpspot color"] = "�����c���ɫ",
["(E) - Sweeping Blade settings: "] = "(E) - ̤ǰ���O��",
["Increase dashtimer by"] = "����ͻ�M�r�g",
[">| This option will increase the time how long the script"] = ">| �@��O�Õ�ͨ�^һ���O����ֵ������",
[">| thinks you are dashing by a fixed value"] = ">| �_���J��������ͻ�M�ĕr�g",
["Check distance of target and (E)endpos"] = "�z��Ŀ�˺�E�Y�����c�ľ��x",
["Maximum distance"] = "�����x",
[">| This option will check if the distance"] = ">| �@��O�Õ��z�����Ŀ��",
[">| between your target and the endposition of your (E) cast"] = ">| ��E�Y�����c�ľ��x",
[">| is greater then the distance set in the slider."] = "���������O���ľ��x",
[">| If yes the cast will get blocked!"] = "�͕�����E��ጷ�",
[">| This prevents dashing too far away from your target!"] = "�@��������ͻ�M�r��Ŀ���x��̫�h",
["Auto Level Enable/Disable"] = "�ԄӼ��c �_��/�P�]",
["Auto Level Skills"] = "�Ԅ���������",
["No Autolevel"] = "���ԄӼ��c",
["> Autoultimate"] = "> �ԄӴ���",
["Number of Targets for Auto(R)"] = "�ԄӴ��Еr��Ŀ�˔�",
[">| Auto(R) ignores settings below and only checks for X targets"] = ">| �ԄӴ��Е�����X��Ŀ�˕r��ጷ�",
["> General settings:"] = "> ��Ҏ�O��",
["Delay the ultimate for more CC"] = "���t����ጷ������L�F�ؕr�g",
["DelayTime "] = "���t�r�g",
["Use (Q) while ulting"] = "���Ŵ�rʹ��Q",
["Use Ultimate under towers"] = "������ʹ�ô���",
["> Target settings:"] = "> Ŀ���O��",
["No supported targets found/available"] = "�]���ҵ���ЧĿ��",
["> Advanced settings:"] = "> �߼��O��:",
["Check for target health"] = "�z��Ŀ�˵�Ѫ��",
["Only ult if target health below < %"] = "ֻ��Ŀ������ֵС�%�rʹ�ô���",
["Check for our health"] = "�z���Լ���Ѫ��",
["Only ult if our health bigger > %"] = "ֻ���Լ�����ֵ���%�rʹ�ô���",
["General-Settings"] = "��Ҏ�O��",
["Orbwalker Enabled"] = "�����߿�",
["Allow casts only for targets in camera"] = "ֻ��Ŀ������Ļ�ϕr���Sʹ�ü���",
["Windwall only if your hero is on camera"] = "ֻ�����Ӣ������Ļ�ϕrʹ���L��",
["> Packet settings:"] = "> ����O��",
["Limit packets to human level"] = "> ���Ʒ������Ĳ���ˮƽ",
[">> General settings"] = ">> ��Ҏ�O��",
["Choose combo mode"] = "�x���B��ģʽ",
["Prefer Q3-E"] = "����Q3-E",
["Prefer E-Q3"] = "����E-Q3",
["Use items in Combo"] = "���B����ʹ����Ʒ",
[">> Choose your abilities"] = ">> �x����ļ���",
["(Q) - Use Steel Tempest"] = "ʹ��Q",
["(Q3) - Use Empowered Tempest"] = "ʹ�Î����L��Q",
["(E) - Use Sweeping Blade"] = "ʹ��E",
["(R) - Use Last Breath"] = "ʹ��R",
["Choose mode"] = "�x��ģʽ",
["1) Normal harass"] = "1)��ͨ�}�_",
["2) Safe harass"] = "2)��ȫ�}�_",
["3) Smart E-Q-E Harass"] = "3)����E-Q-E�}�_",
["Enable smart lasthit if no target"] = "��������β������]��Ŀ��",
["Enable smart lasthit if target"] = "����ֻ��β�������Ŀ��",
["|> Smart lasthit will use spellsettings from the lasthitmenu"] = "|> ����β����ʹ��β���ˆ���ļ����O��",
["|> Mode 1 will simply harass your enemy with spells"] = "|> ģʽ1�����ε��ü����}�_����",
["|> Mode 2 will harass your enemy and e back if possible"] = "|> ģʽ2���}�_�����K��������ܵ�ԒE�؁�",
["|> Mode 3 will engage with e - harass and e back if possible"] = "|> ģʽ3���oE���܁K�}�_������E�؁�",
["Use Smart Killsteal"] = "ʹ�����ܓ����^",
["Use items for Laneclear"] = "���往�rʹ����Ʒ",
["Choose laneclear mode for (E)"] = "�x��E�往��ģʽ",
["Only lasthit with (E)"] = "ֻ��E�aβ��",
["Use (E) always"] = "����ʹ��E",
["Choose laneclear mode for (Q3)"] = "�x�����L��Q���往ģʽ",
["Cast to best pos"] = "�����λ��ጷ�",
["Cast to X or more amount of units "] = "����춵��X����λ�rጷ�",
["Min units to hit with (Q3)"] = "ʹ��Q3�r����С��λ��",
["Check health for using (E)"] = "ʹ��Eǰ�z��Ѫ��",
["Only use (E) if health > %"] = "ֻ������ֵ���%�rʹ��E",
[">> Choose your spinsettings"] = ">> �x��h��Q�O��",
["Prioritize spinning (Q)"] = "���ȭh��Q",
["Prioritize spinning (Q3)"] = "���ȭh��Q3",
["Min units to hit with spinning"] = "�h��Q�ܓ��е���С��λ��",
["Use items to for Jungleclear"] = "��Ұ�rʹ����Ʒ",
["Choose Prediction mode"] = "�x���A��ģʽ",
[">> VPrediction"] = ">> V�A��",
["Hitchance of (Q): "] = "Q���еęC��",
["Hitchance of (Q3): "] = "Q3���еęC��",
[">> HPrediction"] = ">> H�A��",
[">> Found Summonerspells"] = ">> �ن�������",
["No supported spells found"] = "�]���ҵ�֧�ֵ��ن�������",
["Disable ALL drawings of the script"] = "�P�]���_���������@ʾ",
["Draw spells only if not on cooldown"] = "ֻ�@ʾ�;w�ļ��ܾ�Ȧ",
["Draw fps friendly circles"] = "ʹ�ò�Ӱ�fps�ľ�Ȧ",
["Choose strength of the circle"] = "�x��Ȧ���|��",
["> Other settings:"] = "> �����O��",
["Draw airborne targets"] = "�@ʾ�����w��Ŀ��",
["Draw remaining (Q3) time"] = "�@ʾQ3ʣ�N�r�g",
["Draw damage on Healthbar: "] = "��Ѫ�l���@ʾ����",
["> Draw range of spell"] = "> �@ʾ���ܹ���",
["Draw (Q): "] = "�@ʾQ",
["Draw (Q3): "] = "�@ʾQ3",
["Draw (E): "] = "�@ʾE",
["Draw (W): "] = "�@ʾW",
["Draw (R): "] = "�@ʾR",
["> Draw color of spell"] = "> �@ʾ��Ȧ���ɫ",
["(Q) Color:"] = "Q�ɫ",
["(Q3) Color:"] = "Q3�ɫ",
["(W) Color:"] = "W�ɫ",
["(E) Color:"] = "E�ɫ",
["(R) Color:"] = "R�ɫ",
["Healthbar Damage Drawings: "] = "Ѫ�l�����@ʾ",
["Startingheight of the lines: "] = "ָʾ���߶�",
["Draw smart (Q)+(E)-Damage: "] = "�@ʾ����Q+E����",
["Draw (Q)-Damage: "] = "�@ʾQ����",
["Draw (Q3)-Damage: "] = "�@ʾQ3����",
["Draw (E)-Damage: "] = "�@ʾE����",
["Draw (R)-Damage: "] = "�@ʾR����",
["Draw Ignite-Damage: "] = "�@ʾ�cȼ����",
["Permashow: "] = "��B�@ʾ:",
["Permashow HarassToggleKey "] = "�@ʾ�}�_�_�P���I",
["Permashow UltimateToggleKey"] = "�@ʾ�����_�P���I",
["Permashow Autowall Key"] = "�@ʾ�Ԅ��L�����I",
["Permashow Prediction"] = "�@ʾ�A�Р�B",
["Permashow Walljump"] = "�@ʾ�L����B",
["Permashow HarassMode"] = "�@ʾ�}�_ģʽ",
[">| You need to reload the script (2xF9) after changes here!"] = ">| �޸Ĵ�̎�O��������ҪF9�ɴ�",
["> Healthpotions:"] = "> �Ԅ�Ѫș",
["Use Healthpotions"] = "ʹ��Ѫƿ",
["if my health % is below"] = "����Լ�����ֵ���%",
["Only use pots if enemys around you"] = "ֻ�ڸ����Д��˵ĕr���Ԅ�ʹ��ˎˮ",
["Range to check"] = "�z�鹠��",
------------------------���}���R-------------------------
["Divine Awareness"] = "���}���R",
["Debug Settings"] = "�{ԇ�O��",
["Colors"] = "�ɫ",
["Stealth/sight wards/stones/totems"] = "�[�Ά�λ/��/��ʯ/�Ʒ",
["Vision wards/totems"] = "�@ʾ��λ",
["Traps"] = "����",
["Key Bindings"] = "�Iλ�O��",
["Wards/Traps Range (DEFAULT IS ~ KEY)"] = "��λ/���幠��(Ĭ�J��~�I)",
["Enemy Vision (default ~)"] = "����ҕҰ(Ĭ�J��~�I)",
["Timers Call (default CTRL)"] = "Ӌ�r��(Ĭ�JCtrl�I)",
["Mark Wards and Traps"] = "��ӛ��λ������",
["Mark enemy flashes/dashes/blinks"] = "��ӛ���˵��W�F/ͻ�M����",
["Towers"] = "���R��",
["Draw enemy tower ranges"] = "��������������",
["Draw ally tower ranges"] = "�����ѷ�������",
["Draw tower ranges at distance"] = "��һ�����x�Ȳ��@ʾ������",
["Timers"] = "Ӌ�r��",
["Display Jungle Timers"] = "�@ʾ��ҰӋ�r",
["Display Inhibitor Timers"] = "�@ʾˮ��Ӌ�r",
["Display Health-Relic Timers"] = "�@ʾ���cӋ�r",
["Way Points"] = "·���@ʾ",
["Draw enemy paths"] = "�@ʾ���˵�·��",
["Draw ally paths"] = "�@ʾ��܊��·��",
["Draw last-seen champ map icon"] = "��С�؈D�@ʾ��������һ�γ��F��λ��",
["Draw enemy FoW minions line"] = "�@ʾ�����F�e�ı���",
["Notification Settings"] = "��ʾ�O��",
["Gank Prediction"] = "Gank�A�y",
["Feature"] = "���c",
["Play alert sound"] = "������ʾ��",
["Add to screen text alert"] = "����Ļ�@ʾ��ʾ����",
["Draw screen notification circle"] = "����Ļ�@ʾ��ʾ��Ȧ",
["Print in chat (local) a gank notification"] = "��������@ʾgank��ʾ(���ص�)",
["FoW Camps Attack"] = "�����F����",
["Log to Chatbox."] = "���ChatBox",
["Auto SS caller / Pinger"] = "������ʧ�Ԅ�����/��ӛ",
["Summoner Spells and Ult"] = "�ن������ܺʹ���",
["Send timers to chat"] = "��Ӌ�r���l�͵������",
["Key (requires cursor over tracker)"] = "���I(��Ҫ����Ƅ���cd�Oҕ��)",
["On FoW teleport/recall log client-sided chat notification"] = "��������ё����F�e�Ă���/�س�",
["Cooldown Tracker"] = "cd�Oҕ",
["HUD Style"] = "HUD�L��",
["Chrome [Vertical]"] = "Chrome[��ֱ��]",
["Chrome [Horizontal] "] = "Chrome[ˮƽ��]",
[" Classic [Vertical]"] = "���� [��ֱ��]",
["Classic [Horizontal]"] = "���� [ˮƽ��]",
["Lock Side HUDS"] = "�i��HUD",
["Show Allies Side CD Tracker"] = "�@ʾ�ѷ���cd",
["Show Enemies Side CD Tracker"] = "�@ʾ������cd",
["Show Allies Over-Head CD Tracker"] = "�@ʾ��܊�^픵�cd",
["Show Enemies Over-Head CD Tracker"] = "�@ʾ�����^픵�cd",
["Include me in tracker"] = "�@ʾ�Լ���cd",
["Cooldown Tracker Size"] = "cdӋ�r����С",
["Reload Sprites (default J)"] = "���¼��d�DƬ(Ĭ�JJ)",
["Enable Scarra Warding Assistance"] = "���ò�������",
["Automations"] = "�Ԅ�",
--["Lantern Grabber"] = "�Ԅӓ���\",
["Max Radius to trigger"] = "�|�l�����돽",
["Hotkey to trigger"] = "�|�l�İ��I",
["Allow automation based on health"] = "ȡ�Q�����ֵ���Ԅ�",
["Auto trigger when health% < "] = "������ֵС�%�r�Ԅ��|�l",
["Enable BaseHit"] = "���û��ش���",
["Auto Level Sequence"] = "�ԄӼ��c���",
["Auto Leveling"] = "�ԄӼ��c",
["Vision ward on units stealth spells"] = "�ԄӲ����۷��[",
["Voice Awareness"] = "�Z����ʾ",
["Mode"] = "ģʽ",
["Real"] = "������",
["Robot"] = "�C������",
["Gank Alert Announcement"] = "Gank��ʾ",
["Recall/Teleport Announcement"] = "�س�/������ʾ",
["Compliments upon killing a champ"] = "����֮��ķQד",
["Motivations upon dying"] = "����֮��Ĺ���",
["Camp 1 min respawn reminder"] = "ˮ��1��犏ͻ�����",
["Base Hit Announcement"] = "���ش�����ʾ",
["FoW  Camps Attack Alert"] = "�ڑ����F�еĹ�������",
["Evade Assistance"] = "�������",
["Patch "] = "�汾",
-----------------------Better Nerf����----------------
["[Better Nerf] Twisted Fate"] = "[Better Nerf] ���ƴ�",
["[Developer]"] = "[�_�l��]",
["Donations are fully voluntary and highly appreciated"] = "��������ȫ���,�K���҂��ǳ����x����",
["[Orbwalker]"] = "[�߿�]",
["Lux"] = "���˽z",
["[Targetselector]"] = "[Ŀ���x����]",
["[Prediction]"] = "[�A��]",
["Extra delay"] = "�~�����t",
["Auto adjust delay (experimental)"] = "�Ԅ��{�����t(�yԇ)",
["[Performance]"] = "[�����O��]",
["Limit ticks"] = "���ư��I�Δ�",
["Checks per second"] = "ÿ��z��",
["[Card Picker]"] = "[������]",
["Enable"] = "����",
["Gold"] = "�S��",
["[Ultimate]"] = "[����]",
["Cast predicted Ultimate through sprite"] = "ͨ�^С�؈Dʹ���A�д���",
["Adjust R range"] = "�{��R����",
["Pick card when porting with Ultimate"] = "���Ђ��͕r�x��",
["[Combo]"] = "[�B��]",
["Logic"] = "߉݋",
["[Wild Cards]"] = "[�f����(Q)]",
["Stunned"] = "ѣ��",
["Hitchance"] = "���Ў���",
["Ignore Logic if enemy closer <"] = "��܊���xС�x�r��ʹ���B��߉݋",
["Max Distance"] = "�����x",
["[Pick a Card]"] = "[�x��(W)]",
["Card picker"] = "������",
["Pick card logic"] = "�x��߉݋",
["Distance check"] = "���x�z�y",
["Pick red, if hit more than 1"] = "����ܓ��ж��һ�����˾��мt��",
["Pick Blue if mana is below %"] = "����{�����%�����{��",
[" > Use (Q) - Wild Cards"] = " > ʹ��Q - �f����",
[" > Use (W) - Pick a Card"] = "> ʹ��W - �x��",
["Don't combo if mana < %"] = "����{�����%��ʹ���B��",
["[Harass]"] = "[�}�_]",
["Harass #1"] = "�}�_ #1",
["Don't harass if mana < %"] = "�{�����%�r���}�_",
["[Farm]"] = "[�l��]",
["Card"] = "����",
["Clear!"] = "�往",
["Don't farm with Q if mana < %"] = "�{�����%�r��ʹ��Q",
["Don't farm with W if mana < %"] = "�{�����%�r��ʹ��W",
["[Jungle Farm]"] = "[��Ұ]",
["Jungle Farm!"] = "��Ұ!",
["[Draw]"] = "[�@ʾ�O��]",
["[Hitbox]"] = "[�����w�e]",
["Color"] = "�ɫ",
["Quality"] = "�|��",
["Width"] = "����",
["[Q - Wild Cards]"] = "Q -�f����",
["Ready"] = "�;w",
["Draw mode"] = "�@ʾģʽ",
["Default"] = "Ĭ�J",
["Highlight"] = "����",
["[W - Pick a Card]"] = "[W - �x��]",
["[E - Stacked Deck]"] = "[E - �����_�g]",
["Text"] = "����",
["Sprite"] = "�DƬ",
["[TEXT]"] = "[����]",
["[SPRITE]"] = "[�DƬ]",
["Color Stack 1-3"] = "�ɫ�B�� 1-3",
["Color Stack 4"] = "�ɫ�B�� 4",
["Color Background"] = "�ɫ����",
--["[R - Destiny]"] = "[R - ���\]",
["Enable Minimap"] = "��С�؈D�φ����@ʾ",
["Draw Sprite Panel"] = "�@ʾ�������",
["Draw Alerter Text"] = "�@ʾ��������",
["Draw click hitbox"] = "�@ʾ�c�������w�e",
["Adjust width"] = "�{������",
["Adjust height"] = "�{���߶�",
["[Damage HP Bar]"] = "[Ѫ�l�����@ʾ]",
["Draw damage info"] = "�@ʾ������Ϣ",
["Color Text"] = "�����ɫ",
["Color Bar"] = "Ѫ�l�ɫ�ɫ",
["Color near Death"] = "�ӽ��������ɫ",
["None"] = "�o",
["Pause Movement"] = "��ͣ�Ƅ�",
["AutoCarry Mode"] = "�Ԅ��B��ݔ��ģʽ",
["Target Lock Current Target"] = "�i����ǰĿ��",
["Target Lock Selected Target"] = "�i���x��Ŀ��",
["Method 2"] = "��ʽ2",
["Method 3"] = "��ʽ3",
["Color Kill"] = "���ԓ������ɫ",
["Calc x Auto Attacks"] = "Ӌ��ƽA�Δ�",
["Lag-Free-Circles"] = "��Ӱ����t�ľ�Ȧ",
["Disable all Draws"] = "�P�]���е��@ʾ",
["[Killsteal]"] = "[�����^]",
["Use Wild Cards"] = "ʹ��Q",
["[Misc]"] = "[�s��O��]",
["[Rescue Pick]"] = "[�����x��]",
["time"] = "�r�g",
["factor"] = "����",
["[Auto Q immobile]"] = "[�����Ƅӕr�Ԅ�Q]",
["Don't Q Lux"] = "��Ҫ�����˽zʹ��Q",
["[Debug]"] = "[�{ԇ]",
["Spell Data"] = "���ܔ���",
["Prediction / minion hit"] = "�A�� / ����С��",
["TargetSelector Mode"] = "Ŀ���x����ģʽ",
["LESS CAST"] = "����ʹ�ü���",
["LESS CAST PRIORITY"] = "����ʹ�ü���+���ȼ�",
["NEAR MOUSE"] = "�x������",
["Priority"] = "���ȼ�",
["NearMouse"] = "�x��˸���",
["MOST AD"] = "AD���",
["MostAD"] = "AD���",
["MOST AP"] = "AP���",
["MostAP"] = "AP���",
["Damage Type"] = "�������",
["MAGICAL"] = "ħ��",
["PHYSICAL"] = "����",
["Range"] = "����",
["Draw for easy Setup"] = "�����O�õ��@ʾģʽ",
["Draw target"] = "�@ʾĿ��",
["Circle"] = "��Ȧ",
["ESP BOX"] = "ESP����",
["Blue"] = "�{ɫ",
["Red"] = "�tɫ",
-----------------------�LͲ�C��ޱ��-------------------------
["Tumble Machine Vayne"] = "�LͲ�C�� VN",
["Enable Packet Features"] = "���÷��",
["Combo Settings"] = "�B���O��",
["AA Reset Q Method"] = "Q������ͨ�ķ�ʽ",
["Forward and Back Arcs"] = "��ǰ������Q",
["Everywhere"] = "�κ�λ��",
["Use gap-close Q"] = "ʹ��Q�ӽ�����",
["Use Q in Combo"] = "���B����ʹ��Q",
["Use E in Combo"] = "���B����ʹ��E",
["Use R in Combo"] = "���B����ʹ��R",
["Ward bush loss of vision"] = "�����M�ݕr�ԄӲ���",
["Harass Settings"] = "�}�_�O��",
["Use Harass Mode during: "] = "ʹ���}�_ģʽ��",
["Harass Only"] = "ֻ�}�_",
["Both Harass and Laneclear"] = "�}�_���往",
["Forward Arc"] = "��ǰ�r",
["Side to Side"] = "�Ĕ���һ�ȵ���һ��",
["Old Side Method"] = "�f�汾����",
["Use Q in Harass"] = "���}�_��ʹ��Q",
["Use E in Harass"] = "���}�_��ʹ��E",
["Spell Settings"] = "�����O��",
["Q Settings"] = "Q�����O��",
["Use AA reset Q"] = "ʹ��Q�����չ�",
["      ON"] = "�_",
["ON: 3rd Proc"] = "�������չ�",
["Use gap-close Q - Burst Harass"] = "ʹ��Q�ӽ� - ���l�}�_ģʽ",
["E Settings"] = "E�����O��",
["Use E Finisher"] = "ʹ��E����",
["Don't E KS if # enemies near is >"] = "���������˴��x�r��Ҫ��E�����^",
["Don't E KS if level is >"] = "���ȼ����x�r��Ҫ��E�����^",
["E KS if near death"] = "����l��ʹ��E�����^",
["Calculate condemn-flash at:"] = "ʹ��E�W��",
["Mouse Flash Position"] = "�����λ�Þ��W�Fλ��",
["All Possible Flash Positions"] = "���п��ܵ��W�Fλ��",
["R Settings"] = "R�����O��",
["Stay invis long as possible"] = "�������L�r�g�ı����[���B",
["Stay invis min enemies"] = "�����[���B����С���˔�",
["    Activate R"] = "�Ԅ�R",
["R min enemies to use"] = "ʹ��R����С���˔�",
["Use R if Health% <="]	= "�������ֵС춵��%",
["Use R if in danger"] = "��Σ�U��r��ʹ��R",
["Use Q after R if danger"] = "��Σ�U��r��ʹ��RQ�[��",
["Special Condemn Settings"] = "��������O��",
["Anti-Gap Close Settings"] = "��ͻ�M�O��",
["Enable"] = "����",
["Interrupt Settings"] = "����O��",
["Tower Insec Settings"] = "���R��Insec�O��",
["Make Key Toggle"] = "ʹ�ð��I�_�P",
["Max Enemy Minions (1)"] = "��󔳷�С����",
["Max Range From Tower"] = "�x���������x",
["Use On:"] = "ʹ�õČ���",
["Target"] = "Ŀ��",
["Anyone"] = "�κ���",
["Frequency:"] = "ʹ���l��",
["More Often"] = "���l��",
["More Accurate"] = "������",
["Q and Flash Usage:"] = "Q���W�F��ʹ��",
["Q First"] = "��Q",
["Flash First"] = "���W�F",
["Never Use Q"] = "�Ĳ�ʹ��Q",
["Never Use Flash"] = "�Ĳ�ʹ���W�F",
["Wall Condemn Settings"] = "�����O��",
["Use on Lucian"] = "���R�a��ʹ��",
["   If enemy health % <="] = "   �����������ֵС�<",
["Use wall condemn on"] = "ʹ�ö����Č���",
["All listed"] = "�����б��e��Ŀ��",
["Use wall condemn during:"] = "������r��ʹ�ö���",
["Combo and Harass"] = "�B�к��}�_",
["Always On"] = "����ʹ��",
["Wall condemn accuracy"] = "�������ʶ�",
["     Jungle Settings"] = "     ��Ұ�O��",
["Use Q-AA reset on:"] = "������rʹ��Q�����չ�",
["All Jungle"] = "����Ұ��",
["Large Monsters Only"] = "ֻ�Ǵ���Ұ��",
["Wall Stun Large Monsters"] = "������Ұ��ʹ�ö���",
["Disable Wall Stun at Level"] = "�ڵȼ�x�r���ö���",
["Jungle Clear Spells if Mana >"] = "����{�����x�r��ʹ����Ұ",
["     Lane Settings"] = "     �往�O��",
["Q Method:"] = "Qʹ�÷�ʽ",
["Lane Clear Q:"] = "�往��ʹ��Q",
["Dash to Mouse"] = "λ������˷���",
["Dash to Wall"] = "λ������",
["Lane Clear Spells if Mana >"] = "���往��ʹ�ü�������{�����%",
["Humanize Clear Interval (Seconds)"] = "�M�˻��往�g��(��)",
["Tower Farm Help (Experimental)"] = "���°l������(�yԇ)",
["Item Settings"] = "��Ʒ�O��",
["Offensive Items"] = "�M������Ʒ",
["Use Items During"] = "��������rʹ��",
["Combo and Harass Modes"] = "�B�к��}�_ģʽ",
["If My Health % is Less Than"] = "�������ֵ���%",
["If Target Health % is Less Than"] = "���Ŀ������ֵ���%",
["QSS/Cleanse Settings"] = "ˮ�y/�����O��",
["Remove CC during: "] = "������r�����F�ؼ���",
["Remove Exhaust"] = "����̓��",
["QSS Blitz Grab"] = "�����C���˵Ĺ�",
["Humanizer Delay (ms)"] = "���Ի����t(����)",
["Use HP Potions During"] = "������rʹ��Ѫș",
["Use HP Pot If Health % <"] = "����ֵ���%ʹ��Ѫș",
["Damage Draw Settings"] = "�����@ʾ�O��",
["Draw E DMG on bar:"] = "��Ѫ�l�@ʾE�Ă���",
["Ascending"] = "����",
["Descending"] = "�½�",
["Draw E Text:"] = "�@ʾE������ʾ����",
["Percentage"] = "�ٷֱ�",
["Number"] = "����",
["AA Remaining"] = "����ʣ�NƽA��",
["Grey out health"] = "��ɫ�������",
["Disable All Range Draws"] = "�P�]���й����@ʾ",
["Draw Circle on Target"] = "��Ŀ�����@ʾ��Ȧ",
["Draw AA/E Range"] = "�@ʾƽA/E����",
["Draw My Hitbox"] = "�@ʾ�Լ��������w�e",
["Draw (Q) Range"] = "�@ʾQ�Ĺ���",
["Draw Passive Stacks"] = "�@ʾ���ӌӔ�",
["Draw Ult Invis Timer"] = "�@ʾ�����[��Ӌ�r��",
["Draw Attacks"] = "�@ʾ����",
["Draw Tower Insec"] = "�@ʾ���R��Insec",
["While Key Pressed"] = "�����I���r",
["Enable Streaming Mode (F7)"] = "������ģʽ(F7)",
["General Settings"] = "��Ҏ�O��",
["Auto Level Spells"] = "�ԄӼ��c",
["Disable auto-level for first level"] = "��1���r�P�]�ԄӼ��c",
["Level order"] = "���c���",
["First 4 Levels Order"] = "ǰ4�����c���",
["Display alert messages"] = "�@ʾ������Ϣ",
["Left Click Focus Target"] = "���I�c���i��Ŀ��",
["Off"] = "�P�]",
["Permanent"] = "���õ�",
["For One Minute"] = "���mһ���",
["Target Mode:"] = "Ŀ���x��ģʽ:",
["Easiest to kill"] = "�����ד���",
["Less Cast Priority"] = "����ʹ�ü���+���ȼ�",
["Don't KS shield casters"] = "��Ҫ�����o�ܼ��ܵ�Ŀ��ʹ�Ó����^",
["Get to lane faster"] = "�Ͼ�����",
["Double Edge Sword Mastery?"] = "�p�Є����x",
["No"] = "��",
["Yes"] = "��",
["Turn on Debug"] = "���_�{ԇģʽ",
["Orbwalking Settings"] = "�߿��O��",
["Keybindings"] = "�Iλ�O��",
["Escape Key"] = "���ܰ��I",
["Burst Harass"] = "���l�}�_�B��",
["Condemn on Next AA (Toggle)"] = "�´�ƽA���_Ŀ��(�_�P)",
["Flash Condemn"] = "�W�FE",
["Disable Wall Condemn (Toggle)"] = "�P�]����(�_�P)",
["   Use custom combat keys"] = "   ʹ�����T�đ��Y���I",
["Click For Instructions"] = "�c��ָ��",
["Select Skin"] = "�x��Ƥ�w",
["Original Skin"] = "����Ƥ�w",
["Vindicator Vayne"] = "Ħ���� ޱ��",
["Aristocrat Vayne"] = "�C��ʹħŮ ޱ��",
["Heartseeker Vayne"] = "Ғ�īC�� ޱ��",
["Dragonslayer Vayne - Red"] = "������ʿ ޱ�� - �tɫ",
["Dragonslayer Vayne - Green"] = "������ʿ ޱ�� - �Gɫ",
["Dragonslayer Vayne - Blue"] = "������ʿ ޱ�� - �{ɫ",
--["Dragonslayer Vayne - Light Blue"] = "������ʿ ޱ�� - �\�{ɫ",
["SKT T1 Vayne"] = "SKT T1 ޱ��",
["Arc Vayne"] = "�n�֮�� ޱ��",
["Snow Bard"] = "��ѩ���� �͵�",
["No Gap Close Enemy Spells Detected"] = "�]�Йz�y�����˵�ͻ�M����",
["Lucian Ult - Enable"] = "�R�a������ - ����",
["     Humanizer Delay (ms)"] = "     �M�˻����t(����)",
["Teleport - Enable"] = "���� - ����",
["Choose Free Orbwalker"] = "�x�����M�߿�",
["Nebelwolfi's Orbwalker"] = "Nebelwolfi�߿�",
["Modes"] = "ģʽ",
["Attack"] = "����",
["Move"] = "�Ƅ�",
["LastHit Mode"] = "β��ģʽ",
["Attack Enemy on Lasthit (Anti-Farm)"] = "����β���r����(��ֹ���˰l��)",
["LaneClear Mode"] = "�往ģʽ",
["                    Mode Hotkeys"] = "                    ģʽ���I",
[" -> Parameter mode:"] = "-> ����ģʽ",
["On/Off"] = "�_/�P",
["KeyDown"] = "��ס���I",
["KeyToggle"] = "�_�P���I",
["                    Other Hotkeys"] = "                    �������I",
["Left-Click Action"] = "���I����",
["Lane Freeze (F1)"] = "⫬��a��(F1)",
["Settings"] = "�O��",
["Sticky radius to mouse"] = "ֹͣ���ӵą^��돽",
["Low HP"] = "��Ѫ��",
["Most AP"] = "AP���",
["Most AD"] = "AD���",
["Less Cast"] = "����ʹ�ü���",
["Near Mouse"] = "�x������",
["Low HP Priority"] = "��Ѫ��+���ȼ�",
["Dead"] = "������",
["Closest"] = "�����",
["Blade of the Ruined King"] = "�Ɣ�����֮��",
["Bilgewater Cutlass"] = "�Ƞ������؏���",
["Hextech Gunblade"] = "����˹�Ƽ�����",
["Ravenous Hydra"] = "؝�j���^��",
["Titanic Hydra"] = "���;��^��",
["Tiamat"] = "�၆�R��",
["Entropy"] = "��˪���N",
["Yomuu's Ghostblade"] = "�ĉ�֮�`",
["Farm Modes"] = "�l��ģʽ",
["Use Tiamat/Hydra to Lasthit"] = "ʹ���၆�R��/���^��β��",
["Butcher"] = "����",
["Arcane Blade"] = "�p�Є�",
["Havoc"] = "����",
["Advanced Tower farming (experimental"] = "�߼����°l��ģʽ(�yԇ)",
["LaneClear method"] = "�往��ʽ",
["Highest"] = "���Ч��",
["Stick to 1"] = "�i��һ��С��",
["Draw LastHit Indicator (LastHit Mode)"] = "�@ʾβ��ָʾ��(β��ģʽ)",
["Always Draw LastHit Indicator"] = "�����@ʾβ��ָʾ��",
["Lasthit Indicator Style"] = "β��ָʾ����ʽ",
["New"] = "��",
["Old"] = "�f",
["Show Lasthit Indicator if"] = "������r�@ʾβ��ָʾ��",
["1 AA-Kill"] = "һ��ƽA����",
["2 AA-Kill"] = "�ɴ�ƽA����",
["3 AA-Kill"] = "����ƽA����",
["Own AA Circle"] = "�Լ���ƽA��Ȧ",
["Enemy AA Circles"] = "���˵�ƽA��Ȧ",
["Lag Free Circles"] = "��Ӱ����t�ľ�Ȧ",
["Draw - General toggle"] = "�@ʾ - ��Ҏ�_�P",
["Timing Settings"] = "Ӌ�r�O��",
["Cancel AA adjustment"] = "ȡ��ƽA��u�{��",
["Lasthit adjustment"] = "β���{��",
["Version:"] = "�汾:",
["Combat keys are located in orbwalking settings"] = "���Y���I���߿����O��",
-----------------------�r�g�C������--------------
["Time Machine Ekko"] = "�r�g�C�� ����",
["Skin Changer"] = "Ƥ�w�ГQ",
["Sandstorm Ekko"] = "�r֮ɰ ����",
["Academy Ekko"] = "���ԌW�� ����",
["Use Q combo if  mana is above"] = "����{�����xʹ��Q�B��",
["Use E combo if  mana is above"] = "����{�����xʹ��E�B��",
["Use Q Correct Dash if mana >"] = "����{�����xʹ��E��������Q�ķ���",
["Reveal enemy in bush"] = "���݅��e�Ĕ����ԄӲ���",
["Use Target W in Combo"] = "���B������Ŀ���Ե�ʹ��W",
["W if it can hit X "] = "����ܓ���X������ʹ��R",
["Use Q harass if  mana is above"] = "����{�����xʹ��Q�}�_",
["Harass Q last hit and hit enemy"] = "�}�_��ʹ��Q�aβ���Լ����Д���",
["Auto-move to hit 2nd Q in Combo"] = "�Ԅ��ƄӁ�ʹ����Q����",
["On"] = "�_",
["On and Draw"] = "���_�K�@ʾ",
["Long Range W Engage"] = "���Y��ʹ���h���xW",
["Long Range Before E Engage"] = "���Y����E֮ǰʹ���h���xW",
["During E Engage"] = "���Yʹ��E�ĕr��",
["Use W on CC or slow"] = "ʹ��W���F�ػ���Ⱥ�w�p��",
["Don't use E in AA range unless KS"] = "������ƽA�����ȕr���˓����^��Ҫʹ��E",
["Offensive Ultimate Settings"] = "�M���Դ����O��",
["Ult Target in Combo if"] = "������r���B����ʹ�ô���",
["Target health % below"] = "Ŀ������ֵ���%",
["My health % below"] = "�Լ�����ֵ���%",
["Ult if 1 enemy is killable"] = "�����1�����˿ɓ����rʹ��R",
["Ult if 2 or more"] = "�����2����������˿ɓ����rʹ��R",
["will go below 35% health"] = "����Ѫ�����35%�ĕr���|�l",
["Ult if set amount"] = "������_�O����ֵ�tʹ��R",
["will get hit"] = "�����յ�����",
["Offensive Ult During:"] = "������rʹ���M���Դ���",
["Combo Only"] = "ֻ���B����ʹ��",
["Block ult in combo mode if ult won't hit"] = "������в��ܓ��Єt�����B����ʹ�ô���",
["Defensive Ult/Zhonya Settings"] = "���R�Դ���/�Ё��O��",
["Use if about to die"] = "�l���rʹ��",
["Only Defensive Ult if my"] = "���������r�M��..�tʹ�÷��R�Դ���",
["health is less than targets"] = "����ֵ���Ŀ������ֵ",
["Ult if heal % is >"] = "�����ί�����ֵ���%�rʹ��R",
["Defensive Ult During:"] = "������rʹ�÷��R�Դ��У�",
["Wave Clear Settings"] = "�往�O��",
["Use Q in Wave Clear"] = "ʹ��Q�往",
["Scenario 1:"] = "���� 1��",
["Minimum lane minions to hit "] = "���ٓ��е�С����",
["Use Q if  mana is above"] = "����{�����x�rʹ��Q",
["Must hit enemy also"] = "���ͬ�r���Д���",
["Scenario 2:"] = "���� 2��",
["---Jungle---"] = "---��Ұ�O��---",
["Use W in Jungle Clear"] = "ʹ��W��Ұ",
["Use E in Jungle Clear"] = "ʹ��E��Ұ",
["Escape Settings"] = "�����O��",
["Cast W direction you are heading"] = "�����泯�ķ���ʹ��W",
["Draw (W) Max Reachable Range"] = "�@ʾ�ܵ��_��W��󹠇�",
["Draw (E) Range"] = "�@ʾE���ܹ���",
["Draw (R) Range"] = "�@ʾR���ܹ���",
["Draw Line to R Spot"] = "��R�ĵ��c��ָʾ��",
["Draw Passive Stack Counters"] = "�@ʾ���ӌӔ�ָʾ��",
["Display ult hit count"] = "�@ʾ�����ܓ��еĔ��˔�",
["Draw Tower Ranges"] = "�@ʾ���R������",
["Damage Drawings"] = "�@ʾ����",
["Enable Bar Drawings"] = "����Ѫ�l�����@ʾ",
["Separated"] = "���x��",
["Combined"] = "һ�w��",
["Draw Bar Letters"] = "��Ѫ�l���@ʾ������ĸ",
["Draw Bar Shadows"] = "�@ʾѪ�l�Ӱ",
["Draw Bar Kill Text"] = "�@ʾѪ�l������ʾ",
["Draw (Q) Damage"] = "�@ʾQ�Ă���",
["Draw (E) Damage"] = "�@ʾE�Ă���",
["Draw (R) Damage"] = "�@ʾR�Ă���",
["Draw (I) Ignite Damage"] = "�@ʾI(�cȼ)�Ă���",
["Q Helper"] = "Q��������",
["Enable Q  Helper"] = "����Q��������",
["Draw Box"] = "�@ʾ����",
["Draw Minion Circles"] = "��С�����@ʾ��Ȧ",
["Draw Enemy Circles"] = "�ڔ������@ʾ��Ȧ",
["Item/Smite Settings"] = "��Ʒ/�ͽ��O��",
["Offensive Smite"] = "�M���ԑͽ�",
["Use Champion Smite During"] = "��������r��Ӣ��ʹ�Ñͽ�",
["Combo and Lane Clear"] = "�B�к��往",
["Use Smart Ignite"] = "ʹ�������cȼ",
["Optimal"] = "��ѕr�C",
["Aggressive"] = "�����Ե�",
["Prediction Method:"] = "�A�з�ʽ:",
["Divine Prediction"] = "���}�A��",
["Make sure these are on unique keys"] = "�_�����°��I�Ǫ�����",
["Wave Clear Key"] = "�往���I",
["Jungle KS Key"] = "��Ұ/�����^���I",
["Use on ShenE"] = "������Eʹ��",
["      Enable"] = "      ����",
["      Health % < "] = "      ����ֵ���%",
------------------------RaphlolŮ��С��--------------
["Ralphlol: Miss Fortune"] = "Raphlol:Ů��",
["Use W if  mana is above"] = "�{�����x�rʹ��W",
["Use E if  mana is above"] = "�{�����x�rʹ��E",
["Use Q bounce in Combo"] = "���B����ʹ��Q���䔳��",
["Use W in Combo"] = "���B����ʹ��W",
["Use E more often in Combo"] = "���B���и��l����ʹ��E",
["(Q) to Minions"] = "QС��",
["Ignore High Health Tanks"] = "���Ը�Ѫ����̹��/���",
["Only (Q) minions that will die"] = "ֻ����Q����С��ʹ��Q",
["Use Harass also during Lane Clear"] = "���往�ĕr����Ȼ�}�_����",
["Use Q bounce in Harass"] = "���}�_��ʹ��Q����",
["Use W in Harass"] = "���}�_��ʹ��W",
["Ultimate Settings"] = "�����O��",
["Auto Ult During"] = "������rʹ���ԄӴ���",
["Use Ult if X enemy hit"] = "����ܓ���x������ʹ���ԄӴ���",
["Use Ult if target will die"] = "���Ŀ���ܓ����rʹ���ԄӴ���",
["Use on stunned targets"] = "����ѣ����Ŀ��ʹ��",
["Only AutoUlt if CC Nearby <="]= "��������ĈF��С춵��Xʹ���ԄӴ���",
["Cancel Ult if no more enemies inside"] = "���R�����ț]�Д��˄tȡ������",
["Cancel Ult when you right click"] = "�����c�����I�ĕr��ȡ������",
["Block Ult cast if it will miss"] = "������д��е�Ԓ�����δ���ጷ�",
["(Shift Override)"] = "(���wShift)",
["Clear Settings"] = "�往�O��",
["Jungle Clear Settings"] = "��Ұ�O��",
["Use Q in Jungle Clear"] = "����Ұ��ʹ��Q",
["Show notifications"] = "�@ʾ��ʾ��Ϣ",
["Show CC Counter"] = "�@ʾ�F��Ӌ��",
["Show Q Bounce Counter"] = "�@ʾQ����Ӌ��",
["Draw (Q) Arcs"] = "�@ʾQ����Ĺ���",
["Draw (Q) Killable Minions"] = "�@ʾQ�ܓ�����С��",
["(R) Damage Drawing"] = "�@ʾR�Ă���",
["Minimum Duration"] = "��С���m�r�g",
["Full Duration"] = "�����m�r�g",
["Assisted (E) Key"] = "�o��E���I",
["Assisted (R) Key"] = "�o��R���I",
["Ralphlol: Tristana"] = "Raphlol:С��",
["E Harass White List"] = "E�}�_�����б�",
["Use on Brand"] = "�����m��ʹ��",
["Enable Danger Ultimate"] = "����Σ�U�r�ԄӴ���",
["Use on self"] = "���Լ�ʹ��",
["Anti-Gap Settings"] = "��ͻ�M�O��",
["Draw AA/R/E Range"] = "�@ʾƽA/R/E�Ĺ���",
["Draw (W) Range"] = "�@ʾW����",
["Draw (W) Spot"] = "�@ʾW������c",
["All-In Key "] = "ȫ��ݔ�����I",
["Assisted (W) Key"] = "�o��W���I",
["(E) Wave Key"] = "E�往���I",
["Panic Ult Key"] = "�������а��I",
-------------�������Іκϼ�---------------
["SimpleLib - Orbwalk Manager"] = "SimpleLib - �߿�������",
["Orbwalker Selection"] = "�߿��x��",
["SxOrbWalk"] = "Sx�߿�",
["Big Fat Walk"] = "�����߿�",
["Forbidden Ezreal by Da Vinci"] = "�������Іκϼ� - ������",
["SimpleLib - Spell Manager"] = "SimpleLib - ���ܹ�����",
["Enable Packets"] = "ʹ�÷��",
["Enable No-Face Exploit"] = "ʹ���_�l��ģʽ",
["Disable All Draws"] = "�P�]�����@ʾ",
["Set All Skillshots to: "] = "�����м��ܵ��A���{���飺",
["HPrediction"] = "H�A��",
["DivinePred"] = "���}�A��",
["SPrediction"] = "S�A��",
["Q Settings"] = "Q�����O��",
["Prediction Selection"] = "�A���x��",
["X % Combo Accuracy"] = "�B�о��ʶ�X%",
["X % Harass Accuracy"] = "�}�_���ʶ�X%",
["80 % ~ Super High Accuracy"] = "80% ~ �O�߾��ʶ�",
["60 % ~ High Accuracy (Recommended)"] = "60% ~ �߾��ʶ�(���])",
["30 % ~ Medium Accuracy"] = "30% ~ �о��ʶ�",
["10 % ~ Low Accuracy"] = "10% ~ �;��ʶ�",
["Drawing Settings"] = "�L�D�O��",
["Enable"] = "��Ч",
["Color"] = "�ɫ",
["Width"] = "����",
["Quality"] = "�|��",
["W Settings"] = "W�����O��",
["E Settings"] = "E�����O��",
["R Settings"] = "R�����O��",
["Ezreal - Target Selector Settings"] = "[������] - Ŀ���x�����O��",
["Shen"] = "��",
["Draw circle on Target"] = "��Ŀ���Ϯ�Ȧ",
["Draw circle for Range"] = "��Ȧ����",
["Ezreal - General Settings"] = "[������] - ��Ҏ�O��",
["Overkill % for Dmg Predict.."] = "��������Д�X%",
["Ezreal - Combo Settings"] = "[������] - �B���O��",
["Use Q"] = "ʹ��Q",
["Use W"] = "ʹ��W",
["Use R If Enemies >="]	= "������˔�����춵��",
["Ezreal - Harass Settings"] = "[������] - �}�_�O��",
["Min. Mana Percent: "] = "��С�{���ٷֱȣ�",
["Ezreal - LaneClear Settings"] = "[������] - �往�O��",
["Ezreal - LastHit Settings"] = "[������] - β���O��",
["Smart"] = "����",
["Min. Mana Percent:"] = "��С�{���O��",
["Ezreal - JungleClear Settings"] = "[������] - ��Ұ�O��",
["Ezreal - KillSteal Settings"] = "[������] - �����^�O��",
["Use E"] = "ʹ��E",
["Use R"] = "ʹ��R",
["Use Ignite"] = "ʹ���cȼ",
["Ezreal - Auto Settings"] = "[������] - �Ԅ��O��",
["Use E To Evade"] = "ʹ��E���ܶ��",
["Shen (Q)"] = "����Q",
["Shen (W)"] = "����W",
["Shen (E)"] = "����E",
["Shen (R)"] = "����R",
["Time Limit to Evade"] = "��ܕr�g����",
["% of Humanizer"] = "�M�˻��̶�X%",
["Ezreal - Keys Settings"] = "[������] - ���I�O��",
["Use main keys from your Orbwalker"] = "ʹ������߿����I�O��",
["Harass (Toggle)"] = "�}�_�_�P",
["Assisted Ultimate (Near Mouse)"] = "�o������(����˸���)",
[" -> Parameter mode:"] = " -> ����ģʽ",
["On/Off"] = "�_/�P",
["KeyDown"] = "���I",
["KeyToggle"] = "���I�_�P",
["BioZed Reborn by Da Vinci"] = "�������Іκϼ� - ��",
["Zed - Target Selector Settings"] = "[��] - Ŀ���x�����O��",
["Darius"] = "���R��˹",
["Zed - General Settings"] = "[��] - ��Ҏ�O��",
["Developer Mode"] = "�_�l��ģʽ",
["Zed - Combo Settings"] = "[��] - �B���O��",
["Use W on Combo without R"] = "��ʹ��R�rʹ��W",
["Use W on Combo with R"] = "ʹ��R�rʹ��W",
["Swap to W/R to gap close"] = "ʹ�ö���W/R�ӽ�����",
["Swap to W/R if my HP % <="] = "�������ֵС춵��X%�rʹ�ö���W/R",
["Swap to W/R if target dead"] = "ʹ�ö���W/R���Ŀ������",
["Use Items"] = "ʹ����Ʒ",
["If Killable"] = "����ܚ���",
["R Mode"] = "Rģʽ",
["Line"] = "ֱ��ģʽ",
["Triangle"] = "����ģʽ",
["MousePos"] = "���λ��",
["Don't use R On"] = "��Ҫ��..ʹ��R",
["Zed - Harass Settings"] = "[��] - �}�_�O��",
["Check collision before casting q"] = "��ʹ��Q֮ǰ�z����ײ",
["Min. Energy Percent"] = "��С�����ٷֱ�",
["Zed - LaneClear Settings"] = "[��] - �往�O��",
["Use Q If Hit >= "]	=	 "����ܓ��е�С��>=Xʹ��Q",
["Use W If Hit >= "]	=	 "����ܓ��е�С��>=Xʹ��W",
["Use E If Hit >= "]	=	 "����ܓ��е�С��>=Xʹ��E",
["Min. Energy Percent: "] = "��С�����ٷֱȣ�",
["Zed - JungleClear Settings"] = "[��] - ��Ұ�O��",
["Zed - LastHit Settings"] = "[��] - β���O��",
["Zed - KillSteal Settings"] = "[��] - �����^�O��",
["Zed - Auto Settings"] = "[��] - �Ԅ��O��",
["Use Auto Q"] = "ʹ���Ԅ�Q",
["Use Auto E"] = "ʹ���Ԅ�E",
["Use R To Evade"] = "ʹ��R���",
["Darius (Q)"] = "���R��˹Q",
["Darius (W)"] = "���R��˹W",
["Darius (E)"] = "���R��˹E",
["Darius (R)"] = "���R��˹R",
["Use R1 to Evade"] = "ʹ��һ��R���",
["Use R2 to Evade"] = "ʹ�ö���R���",
["Use W To Evade"] = "ʹ��W���",
["Use W1 to Evade"] = "ʹ��һ��W���",
["Use W2 to Evade"] = "ʹ�ö���W���",
["Zed - Drawing Settings"] = "[��] - �@ʾ�O��",
["Damage Calculation Bar"] = "Ѫ�l����Ӌ��",
["Text when Passive Ready"] = "�����ӿ��Õr�@ʾ����",
["Circle For W Shadow"] = "WӰ�Ӿ�Ȧ",
["Circle For R Shadow"] = "RӰ�Ӿ�Ȧ",
["Text on Shadows (W or R)"] = "��W��R��Ӱ�����@ʾ����",
["Zed - Key Settings"] = "[��] - ���I�O��",
["Combo with R (RWEQ)"] = "ʹ��R���B��(RWEQ)",
["Combo without R (WEQ)"] = "��ʹ��R���B��(WEQ)",
["Harass (QWE or QE)"] = "�}�_(QWE����QE)",
["Harass (QWE)"] = "�}�_(QWE)",
["WQE (ON) or QE (OFF) Harass"] = "WQE(�_)��QE(�P)�}�_",
["LaneClear or JungleClear"] = "�往����Ұ",
["Run"] = "����",
["Switcher for Combo Mode"] = "�B��ģʽ�ГQ��",
["Don't cast spells before R"] = "��R����ጷ�֮ǰ��Ҫጷż���",
["Forbidden Syndra by Da Vinci"] = "�������Іκϼ� - ������",
["QE Settings"] = "QE�B���O��",
["Syndra - Target Selector Settings"] = "[������] - Ŀ���x�����O��",
["Syndra - General Settings"] = "[������] - ��Ҏ�O��",
["Less QE Range"] = "QE����С����",
["Dont use R on"] = "��Ҫ������Ŀ��ʹ��R",
["QE Width"] = "QE�B�Ќ���",
["Syndra - Combo Settings"] = "[������] - �B���O��",
["Use QE"] = "ʹ��QE",
["Use WE"] = "ʹ��WE",
["If Needed"] = "�����Ҫ��Ԓ",
["Use Zhonyas if HP % <="]= "�������ֵС�%ʹ���Ё�",
["Cooldown on spells for r needed"] = "R��Ҫ����s�r�g",
["Syndra - Harass Settings"] = "[������] - �}�_�O��",
["Use Q if enemy can't move"] = "���˲����Ƅӵĕr��ʹ��Q",
["Don't harass under turret"] = "��Ҫ�}�_�����µ�Ŀ��",
["Syndra - LaneClear Settings"] = "[������] - �往�O��",
["Syndra - JungleClear Settings"] = "[������] - ��Ұ�O��",
["Syndra - LastHit Settings"] = "[������] - β���O��",
["Syndra - KillSteal Settings"] = "[������] - �����^�O��",
["Syndra - Auto Settings"] = " [������] - �Ԅ��O��",
["Use QE/WE To Interrupt Channelings"] = "ʹ��QE/WE������������",
["Time Limit to Interrupt"] = "��༼�ܵĕr�g����",
["Use QE/WE To Interrupt GapClosers"] = "ʹ��QE/WE�������˵�ͻ�M",
["Syndra - Drawing Settings"] = "[������] - �@ʾ�O��",
["E Lines"] = "E����ָʾ��",
["Text if Killable with R"] = "�������R�����@ʾ������ʾ",
["Circle On W Object"] = "��Wץȡ��Ŀ���Ϯ�Ȧ",
["Syndra - Keys Settings"] = "[������] - ���I�O��",
["Cast QE/WE Near Mouse"] = "����˸���ʹ��QE/WE",
---------------�������R---------------
["Big Fat Gosu"] = "���Ӻϼ�",
["Load Big Fat Mark IV"] = "���d�������R",
["Load Big Fat Evade"] = "���d���Ӷ��",
["Sorry, this champion isnt supported yet =("] = "������,��֧���@��Ӣ��",
["Big Fat Gosu v. 3.61"] = "���Ӻϼ�v. 3.61",
["Big Fat Hev - Mark IV"] = "�������R",
["[Voice Settings]"] = "[�Z���O��]",
["Volume"] = "����",
["Welcome"] = "�gӭ",
["Danger!"] = "Σ�U",
["Shutdown"] = "�K�Y",
["SummonerSpells"] = "�ن�������",
["WinLose sounds"] = "����/ʧ��",
["Kill Announcer"] = "��������",
["Shrooms Announcement"] = "��Ģ������",
["Smite Announcement"] = "�ͽ䲥��",
["JungleTimers Announcement"] = "��ҰӋ�r����",
["[Incoming Enemys to Track]"] = "[�Oҕ��������Ĕ���]",
["ON/OFF"] = "�_/�P",
["Stop track inc. enemys after x min"] = "x�����ֹͣ�Oҕ����",
["Allow this option"] = "���S����O��",
["Scan Range"] = "���蹠��",
["Draw minimap"] = "С�؈D�@ʾ",
["Use Danger Sprite"] = "ʹ��Σ�U���I",
["Show waypoints"] = "�@ʾ·���c",
["Enable Voice System"] = "�����Z��ϵ�y",
["Jax"] = "�Z��˹",
["[CD Tracker]"] = "[��sӋ�r��]",
["Use CD Tracker"] = "ʹ����sӋ�r��",
["[Wards to Track]"] = "[��λ�Oҕ]",
["Use Wards Tracker"] = "ʹ����λ�Oҕ",
["Use Sprites"] = "ʹ�ÈDƬ",
["Use Circles"] = "ʹ�þ�Ȧ",
["Use Text"] = "ʹ������",
["[Recall Tracker]"] = "[�سǱOҕ]",
["Use Recall Tracker"] = "ʹ�ûسǱOҕ",
["Hud X"] = "HUD X�Sλ��",
["Hud Y"] = "HUD Y�Sλ��",
["Print Finished and Cancelled Recalls"] = "�@ʾ��ɵĻسǺ�ȡ���Ļس�",
["[BaseUlt]"] = "[���ش���]",
["Use BaseUlt"] = "ʹ�û��ش���",
["Print BaseUlt alert in chat"] = "����������@ʾ���ش�����ʾ",
["Draw BaseUlt Hud"] = "�@ʾ���ش���HUD",
["[Team BaseUlt Friends]"] = "[�@ʾ��ѵĻ��ش���]",
["[Tower Range]"] = "[���R������]",
["Use Tower Ranges"] = "�@ʾ���R������",
["Show only close"] = "ֻ�ڽӽ����R���r�@ʾ",
["Show ally turrets"] = "�@ʾ��܊���R������",
["Show turret view"] = "�@ʾ���R��ҕҰ",
["Circle Quality"] = "��Ȧ�|��",
["Circle Width"] = "��Ȧ����",
["[Jungle Timers]"] = "[��ҰӋ�r]",
["Jungle Disrespect Tracker(FOW)"] = "�oҕҰҰ�^�Oҕ",
["Sounds for Drake and Baron"] = "����С����ʾ��",
["(DEV) try to detect more"] = "(�_�l��)�Lԇ�z�y������Ϣ",
["Enable Jungle Timers!!! Finally ^^"] = "����,���ô�ҰӋ�r",
["[Enemies Hud]"] = "[������ϢHUD]",
["Enable enemies hud"] = "���Ô�����ϢHUD",
["Hud Style"] = "HUD�L��",
["Classic(small)"] = "����(С)",
["Circle(medium)"] = "�A��(��)",
["Circle(big)"] = "�A��(��)",
["LowFps(Mendeleev)"] = "��fps",
["RitoStyle"] = "Rito�L��",
["Hud Mode"] = "HUDģʽ",
["Vertical"] = " ��ֱ��",
["Horizontal"] = "ˮƽ��",
["HudX and HudY dont work for Old one"] = "HUD XY�Sλ�ò����������L����Ч",
--["[Thresh Lantern]"] = "[�Nʯ�ğ��\]",
--["Use Nearest Lantern"] = "������ğ��\",
["Auto Use if HP < %"] = "�������ֵС�%�Ԅ�ʹ��",
["[Anti CC]"] = "[���F��]",
["Enable AntiCC"] = "���÷��F��",
["[BuffTypes]"] = "[�������]",
["Disarm"] = "�Uе",
["ForcedAction"] = "���Ƅ���(���S/�Ȼ�)",
["Suppression"] = "����",
["Suspension"] = "���w",
["Slow"] = "�p��",
["Blind"] = "��ä",
["Stun"] = "ѣ��",
["Root"] = "���d",
["Silence"] = "��Ĭ",
["Enable Mikael for teammates"] = "���Ì����ʹ�����",
["[TeamMates for Mikael]"] = "[�����ʹ�����]",
["It will use Cleanse, Dervish Blade,"] = "����ʹ�Ã���,����ɮ֮��",
["Quicksilver Sash, Mercurial Scimitar"] = "ˮ�y�,ˮ�y����",
[" or Mikael's Crucible."] = "�����ׄP�������",
["Suppressions by Malzahar, Skarner, Urgot,"] = "�����������,˹���{,����صĉ���",
["Warwick could be only removed by QSS"] = "���˵ĉ���ֻ��ˮ�y�ܽ�",
["[Misc]"] = "[�s�]",
["Draw Exp Circle"] = "�@ʾ���@�ù���",
["Extra Awareness"] = "�~�����R",
["Heal Cd's on Aram"] = "�ڴ�y��ģʽ�@ʾ�ί�cd",
["LordsDecree Cooldown"] = "�����I���ķ�����s�r�g",
["Big Fat Hev - Mark IV v. 4.001"] = "�������R v. 4.001",

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
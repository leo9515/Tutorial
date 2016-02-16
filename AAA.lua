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
["Menu"] = "�˵�",
["press key for Menu"] = "�趨�µĲ˵���ť...",
[" "] = " ",
["-"] = "-",
["NOW"] = "NOW",
["SOW"] = "SOW",
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
["2..4 - Use vs More Dangerous / CC"] = "2..4 - ������Σ�ռ��ܼ����Ƽ���ʹ��",
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
["2..4 - Use only vs More Dangerous / CC"] = "2..4 - ���ڽ�Σ�ռ��ܼ����Ƽ���ʹ��",
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
["Blitzcrank | Q - Rocket Grab"] = "����� | Q - ��е��צ",
["On / Off [Permanent]"] = "�� / �� [������Ч]",
["On / Off [This session]"] = "�� / �� [������Ϸ��Ч]",
["Dodging Mode"] = "���ģʽ",
["Normal"] = "��ͨ",
["Prefer dashes/blinks/spellshields"] = "����ʹ��λ��/����/����",
["Only dashes/blinks/spellshields"] = "ֻʹ��λ��/����/����",
["Draw this spell"] = "��ʾ����",
["Extra Width: "] = "������",
["Attempt to dodge from FoW"] = "���Զ��ս��������ļ���",
["Allow casting while evading"] = "��ܵ�ʱ������ʹ�ü���",
["Don't dodge from inside"] = "���ڼ��ܷ�Χ��ʱ�����",
["Consider it dangerous"] = "�ж��˼���Σ��",
["    0 - Don't use dashes"] = "    0 - ��Ҫʹ��λ��",
["    1 - Use low CD spells"] = "    1 - ʹ�ö�cd����",
["2..4 - Use more spells"] = "2..4 - ʹ�ø��༼��",
["    5 - Use flash"] = "    5 - ʹ������",
["Blitzcrank | R - Static Field"] = "����� | R - ��������",
["Simple"] = "��",
["Advanced"] = "�߼�",
["\"Smooth\" Diagonal Evading"] = "ƽ��б�߶��",
["Last Destination"] = "�������ķ���",
["Mouse Position"] = "���λ��",
["Hero Position"] = "Ӣ��λ��",
["Allow Casting"] = "������ʹ��",
["Block Casting"] = "���μ���ʹ��",
["Modify/Block [Any direction]"] = "����/���� [�κη���]",
["Modify/Block [Only towards cast position]"] = "����/���� [˳�ż��ܵķ���]",
["Modify/Allow [Any direction]"] = "����/���� [�κη���]",
["Modify/Allow [Only towards cast position]"] = "����/���� [˳�ż��ܵķ���]",
["Minimum Range"] = "��С��Χ",
["Maximum Range"] = "���Χ",
["Randomized Range"] = "�����С��Χ",
["Dodge \"Only Dangerous\" spells"] = "ֻ���Σ�ռ���",
["To change the hotkey go to \"Controls\"."] = "��\"����\"���޸��ȼ�",
["Disable"] = "�ر�",
["Arrow"] = "��ͷ",
["Arrow [Outlined]"] = "��ͷ [����]",
["Show \"Doubleclick to remove!\""] = "��ʾ\"˫���Ƴ��������\"",
["Very Low"] = "�ǳ���",
["Low"] = "��",
["Mid"] = "��",
["Very High"] = "�ܸ�",
["Ultra"] = "����",
["Danger level: "] = "Σ�յȼ�",
["Dodge <= X danger spells..."] = "��С�ڵ���X��Σ�ռ��ܹ�����ʱ���",
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
["*LessCastPriority Recommended"] = "�Ƽ�������ʹ�ü���+���ȼ�",
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
["Save BotRK for max heal"] = "�����ư��Ի���������",
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
["DeklandAIO: Orianna"] =  "��ϵ�кϼ�����������",
["DeklandAIO Version: "] =  "��ϵ�кϼ��汾�ţ�",
["Auth Settings"] =  "�ű���֤����",
["Debug Auth"] =  "������֤",
["Fix Auth"] =  "�޸���֤",
["Target Selector Settings"] =  "Ŀ��ѡ��������",
["Left Click Overide"] =  "������Ŀ������",
["1 = Highest, 5 = Lowest, 0 = Ignore"]	= "1-��ߣ�5-��ͣ�0-����",
["Use Priority Mode"] =  "ʹ�����ȼ�ģʽ",
["Set Priority Vladimir"] =  "������Ѫ������ȼ�",
["Keys Settings"] =  "��λ����",
["Harass"] =  "ɧ��",
["Harass Toggle"] =  "ɧ�ſ���",
["TeamFight"] =  "��ս",
["Skill Settings"] =  "��������",
["                    Q Skill          "] =  "                Q����              ",
["Use Harass"] =  "ʹ�øü���ɧ��",
["Use Kill Steal"] =  "ʹ�øü�������ͷ",
["Use Spacebar"] =  "ʹ�ÿո�",
["                    W Skill          "] =  "                W����              ",
["Min No. Of Enemies In W Range"] =  "��W��Χ����С��������",
["                    E Skill          "] =  "                E����              ",
["Use E>Q Combo"] =  "ʹ��EQ����",
["Use E If Can Hit"] =  "������ܻ���Ŀ��ʱʹ��E",
["Use E>W or E>R"] =  "ʹ��EW����ER����",
["                    R Skill          "] =  "                R����              ",
["R Block"] =  "��ֹR�Զ��ͷ�",
["Set R Range"] =  "����R�ķ�Χ",
["Use Combo Ult - (Q+W+R Dmg)"] =  "ʹ���ռ����У�QWR���˺���",
["Min No. Of Enemies"] =  "��������X������ʱ�ͷ�",
["Min No. Of KS Enemies"] =  "��������X����Ѫ����ʱ�ͷ�",
["Ult Vladimir"] =  "����Ѫ���ͷ�R",
["                    Misc Settings          "] =  "            ��������              ",
["Harass Mana Management"] =  "ɧ����������",
["Farm Settings"] =  "ˢ������",
["                    Farm Keys          "] =  "            ˢ������              ",
["Farm Press"] =  "ˢ������",
["Farm Toggle"] =  "ˢ������",
["Lane Clear Press"] =  "���߰���",
["Lane Clear Toggle"] =  "���߿���",
["Jungle Farm"] =  "��Ұ",
["                    Q Farm          "] =  "         Q����ˢ��           ",
["Last Hit"] =  " ",
["Lane Clear"] =  "����",
["Jungle"] =  "��Ұ",
["                    W Farm          "] =  "         W����ˢ��           ",
["                    E Farm          "] =  "         E����ˢ��           ",
["                    Misc          "] =  "                    ����          ",
["Farm Mana Management"] =  "ˢ����������",
["OrbWalk Settings"] =  "�߿�����",
["            Team Fight Orbwalk Settings          "] =  "            ��ս�߿�����          ",
["Move To Mouse"] =  "�����λ���ƶ�",
["Auto Attacks"] =  "�Զ�����",
["               Harrass Orbwalk Settings          "] =  "            ɧ���߿�����          ",
["              Lane Farm Orbwalk Settings          "] =  "         ����ˢ���߿�����         ",
["              Jungle Farm Orbwalk Settings          "] =  "            ��Ұ�߿�����          ",
["On Dash Settings"] =  "���ͻ��ʱ����",
["Check On Dash Vladimir"] =  "�����Ѫ���ͻ��",
["Items Settings"] =  "��Ʒ����",
["AP Items"] =  "AP����Ʒ",
["Use AP Items"] =  "ʹ��AP��Ʒ",
["Use Bilgewater Cutlass"] =  "�ȶ��������䵶",
["Use Blackfire Torch"] =  "���׻��",
["Use Deathfire Grasp"] =  "ڤ��֮ӵ",
["Use Hextech Gunblade"] =  "����˹�Ƽ�ǹ��",
["Use Twin Shadows"] =  "˫����Ӱ",
["AP Item Mode: "] =  "AP��Ʒģʽ",
["Burst Mode"] =  "����ģʽ",
["Combo Mode"] =  "����ģʽ",
["KS Mode"] =  "����ͷģʽ",
["AD Items"] =  "AD��Ʒ",
["Use AD Items"] =  "ʹ��AD��Ʒ",
["Use Blade of the Ruined King"] =  "ʹ���ư�����֮��",
["Use Entropy"] =  "��˪ս��",
["Use Sword of the Divine"] =  "��ʥ֮��",
["Use Tiamat/Ravenous Hydra"] =  "��������/��ͷ��",
["Use Youmuu's Ghostblade"] =  "����֮��",
["Use Muramana"] =  "ħ��",
["Min Mana for Muramana"] =  "ʹ��ħ�е���С����",
["AD Item Mode: "] =  "AD��Ʒģʽ",
["Support Items"] =  "������Ʒ",
["Use Support Items"] =  "ʹ�ø�����Ʒ",
["Auto Wards"] =  "�Զ�����",
["Use Sweeper"] =  "ʹ��ɨ��",
["Ward Mode: "] =  "����ģʽ",
["Only Bushes"] =  "ֻ�ڲݴ�",
["Always"] =  "����",
["Summoner Spells"] =  "�ٻ�ʦ����",
["                    Ignite          "] =  "                    ��ȼ          ",
["Use Ignite"] =  "ʹ�õ�ȼ",
["Ignite Mode : "] =  "��ȼģʽ��",
["ComboMode"] =  "����ģʽ",
["KSMode"] =  "����ͷģʽ",
["                    Smite          "] =  "                    �ͽ�          ",
["             Smite Not Found         "] =  "             û�з��ֳͽ�         ",
["Use Smite"] = "ʹ�óͽ�",
["Smite Baron/Dragon/Vilemaw"] = "�Դ���/С��/����֮��ʹ�óͽ�",
["Smite Large Minions"] = "�Դ�Ұ��ʹ�óͽ�",
["Smite Small Minions"] = "��СҰ��ʹ�óͽ�",
["                  Lane          "] = "                  ����          ",
["                  Jungle          "] = "                  ��Ұ          ",
["Smite Siege Minions"] = "���ڳ�ʹ�óͽ�",
["Smite Melee Minions"] = "�Խ�ս��ʹ�óͽ�",
["Smite Caster Minions"] = "��Զ�̱�ʹ�óͽ�",
["Draw Settings"] =  "��ͼ����",
["Draw Skill Ranges"] =  "����������Ȧ",
["Lag free draw"] =  "��Ӱ���ӳٵ���Ȧ",
["Draw Q Range"] =  "����Q������Ȧ",
["Choose Q Range Colour"] =  "ѡ��Q������Ȧ��ɫ",
["Draw W Range"] =  "����W������Ȧ",
["Choose W Range Colour"] =  "ѡ��W������ɫ",
["Draw E Range"] =  "����E������Ȧ",
["Choose E Range Colour"] =  "ѡ��E������Ȧ��ɫ",
["Draw R Range"] =  "����R������Ȧ",
["Choose R Range Colour"] =  "ѡ��R������Ȧ��ɫ",
["Draw AA Range"] =  "����ƽA�ķ�Χ",
["Draw Awareness"] =  "��ʾ��ʶ",
["Draw Clicking Points"] =  "��ʾ�����λ��",
["Draw Enemy Cooldowns"] =  "��ʾ���˵�CD",
["Draw Enemy Predicted Damage"] =  "��ʾ���˵��˺�",
["Draw Last Hit Marker"] =  "��ʾβ���ı��",
["Draw Wards + Wards Timers"] =  "��ʾ��λ�Լ���λʱ��",
["Draw Turret Ranges"] =  "��ʾ��������Χ",
["Draw Kill Range"] =  "��ʾ��ɱ��Χ",
["Kill Range"] =  "��ɱ��Χ",
["Choose Kill Range Colour"] =  "ѡ���ɱ��Χ����ɫ",
["Draw Focused Target"] =  "��ʾ������Ŀ��",
["Focused Target"] =  "����Ŀ��",
["Choose Focused Target Colour"] =  "ѡ������Ŀ�����ɫ",
["Draw Doomball Ranges"] =  "��ʾħż�ķ�Χ",
["Draw Doomball W Range"] =  "��ʾħżW�ķ�Χ",
["Draw Doomball R Range"] =  "��ʾħżR�ķ�Χ",
----------------------------------------------------------------
["DeklandAIO: Syndra"] =  "��ϵ�кϼ���������",
["Set Priority Amumu"] =  "����ľľ�����ȼ�",
["Use QE Snipe"] =  "ʹ��QE",
["Cast On Optimal Target"] =  "�����Ŀ���ͷ�",
["Ult Amumu"] =  "��ľľ�ͷ�R",
["Use QE Snipe (Teamfight)"] =  "ʹ��QE������սʱ��",
["Use QE Snipe (Harass)"] =  "ʹ��QE����ɧ��ʱ��",
["Use Kill Steal QE Snipe"] =  "��QE����ͷ",
["Use Gap Closers"] =  "��ͻ��ʹ�õļ���",
["Interupt Skills"] =  "��ϵз�����",
["Check On Dash Amumu"] =  "���ľľ��ͻ��",
["Draw QE Range"] =  "����QE�ķ�Χ",
["Choose QE Range Colour"] =  "ѡ��QE����Ȧ��ɫ",
["Draw Prediction"] =  "����Ԥ��",
["Draw Q Prediction"] =  "����Q��Ԥ��",
["Draw W Prediction"] =  "����W��Ԥ��",
["Draw E Prediction"] =  "����E��Ԥ��",
["Draw QE Prediction"] =  "����QE��Ԥ��",
----------------��ϵ�����ȴ�ʯ-----------------------
["DeklandAIO: Thresh"] = "��ϵ�кϼ�����ʯ",
["Use Lantern Whilst Hooked"] = "���е�ͬʱʹ�õ���",
["Use Lantern - Grab Ally"] = "���Ѿ�ʹ�õ���",
["Use Lantern - Self"] = "���Լ�ʹ�õ���",
["E Mode"] = "E����ģʽ",
["Auto"] = "�Զ�",
["Pull"] = "�����",
["Push"] = "��ǰ��",
["No. of Enemies In Range"] = "�ڷ�Χ�ڵĵо�����",
["Use Q On Dash "] = "��ͻ��ʹ��Q",
["Use E On Dash "] = "��ͻ��ʹ��E",
["             Ignite Not Found         "] = "             û�з��ֵ�ȼ         ",
["Draw Souls"] = "��ʾ���",
["DeklandAIO: Ryze"] = "��ϵ�кϼ�������",
["Auto Q Stack"] = "�Զ�Q�ܱ���",
-----------------��ϵ����Ů����˹--------------------
["DeklandAIO: Cassiopeia"] = "��ϵ�кϼ������������",
["Set Priority Chogath"] = "���ÿƼ�˹�����ȼ�",
["Assisted Ult"] = "��������",
["Use W Only If Q Misses"] = "ֻ��Qmiss��ʱ��ʹ��W",
["E Daly Timer (secs)"] = "E�ӳٵ�ʱ��(��)",
["Use Spacebar (All skills can kill)"] = "ʹ�ÿո�(���м��ܿ��Ի�ɱ)",
["When conditions are met it will ult Automatically"] = "����������ʱ���Զ��ͷŴ���",
["No. Enemies in Range"] = "��Χ����x������",
["No. KS Enemies in Range"] = "��Χ����x�����˿�������ͷ",
["No. Facing Enemies"] = "��Χ����x���泯��ĵ���",
["Ult Chogath"] = "�ԿƼ�˹ʹ�ô���",
["Auto E Poison Minions"] = "�Զ�E�ж���С��",
["Check On Dash Chogath"] = "���Ƽ�˹��ͻ��",
["Draw R Prediction"] = "��ʾR��Ԥ��",
["Draw Poison Targets"] = "��ʾ�ж���Ŀ��",
["DeklandAIO: Xerath"] = "��ϵ�кϼ�������˹",
["Set Priority Nidalee"] = "�趨�ε��������ȼ�",
["Ult Tap (fires 'One' on release)"] = "���а���(��һ�η�һ��R)",
["Smart Cast Manual Q"] = "���������ֶ�Q",
["Force Ult - R Key"] = "ǿ�ƴ��� - R��",
["Ult Near Mouse"] = "����긽���ĵ��˷�R",
["Ult Delay"] = "�����ӳ�",
["Check On Dash Nidalee"] = "����ε�����ͻ��",
["MiniMap draw"] = "С��ͼ��ʾ",
["Draw Ult Range"] = "��ʾR��Χ",
["Draw Ult Marks"] = "��ʾR���",
-----------------���˺ϼ�----------------------------
["HTTF Prediction"] = "HTTFԤ��",
["Collision Settings"] = "��ײ����",
["Buffer distance (Default value = 10)"] = "�������(Ĭ��10)",
["Ignore which is about to die"] = "���Խ�Ҫ������Ŀ��",
["Script version: "] = "�ű��汾��",
["DivinePrediction"] = "��ʥԤ��",
["Min Time in Path Before Predict"] = "Ԥ��·������Сʱ��",
["Central Accuracy"] = "���ľ�׼��",
["Debug Mode [Dev]"] = "����ģʽ[������]",
["Cast Mode"] = "�ͷ�ģʽ",
["Fast"] = "��",
["Slow"] = "��",
["Collision"] = "��ײ",
["Collision buffer"] = "��ײ����",
["Normal minions"] = "��ͨС��",
["Jungle minions"] = "Ұ��",
["Others"] = "����",
["Check if minions are about to die"] = "��鼴��������С��",
["Check collision at the unit pos"] = "��鵥λλ�õ���ײ",
["Check collision at the cast pos"] = "����ͷ�λ�õ���ײ",
["Check collision at the predicted pos"] = "���Ԥ��λ�õ���ײ",
["Developers"] = "������",
["Enable debug"] = "���õ���",
["Show collision"] = "��ʾ��ײ",
["Version"] = "�汾",
["--- Fun House Team ---"] = "---�����Ŷ�---",
["made by burn & ikita"] = "���� burn & ikita",
["FH Global Settings"] = "���˺ϼ�ȫ������",
["Amumu"] = "��ľľ",
["5 = Maximum priority = You will focus first!"] = "5 - ������ȼ� -��Ҫ����Ŀ��",
["Target Selector - Extra Setup"] = "Ŀ��ѡ���� - ��������",
["- DISTANCE TO IGNORE TARGET (FOCUS MODE) -"] = "��������Ŀ��ľ���",
["Default distance"] = " Ĭ�Ͼ���",
["------ DRAWS ------"] = "------ ��ʾ ------",
["This allow you draw your target on"] = "������������Ŀ����ʾ����Ļ��",
["the screen, for quicker target orientation"] = "�Ի�ø����Ŀ�귽��",
["Enable draw of target (circle)"] = "������ʾĿ��(��Ȧ)",
["Target circle color"] = "Ŀ����Ȧ��ɫ",
["Enable draw of target (text)"] = "������ʾĿ��(����)",
["Select where to draw"] = "ѡ����ʾ��λ��",
["Fixed On Screen"] = "�̶�����Ļ��",
["On Mouse"] = "�������",
["--- Draw values ---"] = "--- ��ʾ���� ---",
["Draw X location"] = "��ʾX��λ��",
["Draw Y location"] = "��ʾY��λ��",
["Draw size"] = "��ʾ��С",
["Draw color"] = "��ʾ��ɫ",
["Reset draw position"] = "������ʾλ��",
["Auto Potions"] = "�Զ�ҩˮ",
["Use Health Potion"] = "ʹ��Ѫƿ",
["Use Refillable Potion"] = "ʹ�ø�����ҩˮ",
["Use Hunters Potion"] = "ʹ������ҩˮ",
["Use Corrupting Potion"] = "ʹ�ø���ҩˮ",
["Corrupting Potion DPS in Combat"] = "��ս����ʹ�ø���ҩˮ�����˺�",
["Absolute Min Health %"] = "��������ֵ��С�ٷֱ�",
["In Combat Min Health %"] = "ս��������ֵ��С�ٷֱ�",
["QSS & Cleanse"] = "ˮ�� & ����",
["Enable auto cleanse enemy debuffs"] = "�����Զ�����",
["Settings for debuffs"] = "����Ч������",
["- Global delay before clean debuff -"] = "�Զ�������ȫ���ӳ�",
["Global Default delay"] = "ȫ��Ĭ���ӳ�",
["- Usual debuffs -"] = "-�������Ч��-",
["Cleanse if debuff time > than (ms):"] = "�������Ч��ʱ�����..ʹ�þ���",
["- Slow debuff -"] = "- ���� -",
["Cleanse if slow time > than (ms):"] = "�������ʱ�����..ʹ�þ���",
["- Special cases -"] = "- ������� -",
["Remove Zed R mark"] = "��ٵĴ���",
["Extra Awaraness"] = "������ʶ",
["Enable Extra Awaraness"] = "���ö�����ʶ",
["Warning Range"] = "����ķ�Χ",
["Draw even if enemy not visible"] = "��ʹ��������Ҳ����",
["Security & Humanizer"] = "��ȫ&���˻�",
["------------ SECURITY ------------"] = "------------ ��ȫ ------------",
["Enabling this, you will limit all functions"] = "���ô����ã������ƽ������������",
["to only trigger them if enemy/object"] = "��Ļ��ʱ���й��ܲ���Ч",
["is on your Screen"] = " ",
["Enable extra Security mode"] = "���ö��ⰲȫ����",
["------------ HUMANIZER ------------"] = "------------ ���˻� ------------",
["This will insert a delay between spells"] = "�������ý�������������м�����ӳ�",
["If you set too high, it will make combo slow,"] = "����㽫��ֵ�趨�Ĺ��ߣ����л����",
["so if you use it increase it gradually!"] = "���������Ҫʹ�õĻ���������������ֵ",
["Humanize Delay in ms"] = "���˻��ӳ�(����)",
["Ryze Fun House 2.0"] = "���˺ϼ�2.0 - ����",
["General"] = "����",
["Key binds"] = "��λ����",
["Auto Q stack out of combat"] = "���������Զ�Q�ܱ���",
["Combat"] = "����",
["Smart Combo"] = "��������",
["Use Items on Combo"] = "��������ʹ����Ʒ",
["Use Desperate Power (R)"] = "ʹ�þ���֮��(R)",
["R Cast Mode"] = "Rʹ��ģʽ",
["Required stacks on 'Smart' for cast R"] = "����ʹ��Rʱ��Ҫ��������",
["Harass"] = "ɧ��",
["Use Overload (Q)"] = "ʹ�ó�����(Q)",
["Use Rune Prison (W)"] = "ʹ�÷��Ľ���(W)",
["Use Spell Flux (E)"] = "ʹ�÷���ӿ��(E)",
["Use Overload (Q) for last hit"] = "ʹ��Q����β��",
["Min Mana % to use Harass"] = "ɧ�ŵ���С���� %",
["Auto kill"] = "�Զ���ɱ",
["Enable Auto Kill"] = "�����Զ���ɱ",
["Auto KS under enemy towers"] = "�ڵ��������Զ�����ͷ",
["Farming"] = "ˢ��",
["Lane Clear"] = "����",
["Min Mana % for lane clear"] = "���ߵ���С���� %",
["Last Hit"] = "β��",
["Use Q for last hit"] = "ʹ��Q����β��",
["Last Hit with AA"] = "ʹ��ƽA����β��",
["Min Mana % for Q last hit"] = "Q��β������С����",
["Drawings"] = "��ʾ����",
["Spell Range"] = "������Ȧ",
["Enable Draws"] = "������ʾ",
["Draw Q range"] = "��ʾQ��Χ",
["Q color"] = "Q��Ȧ��ɫ",
["Draw W-E range"] = "��ʾW-E��Χ",
["W-E color"] = "W-E��Ȧ��ɫ",
["Draw Stacks"] = "��ʾ��������",
["Use Lag Free Circle"] = "ʹ�ò�Ӱ���ӳٵ���Ȧ",
["Kill Texts"] = "��ɱ��ʾ",
["Use KillText"] = "���û�ɱ��ʾ",
["Draw KillTime"] = "��ʾ��ɱʱ��",
["Text color"] = "������ɫ",
["Draw Damage Lines"] = "��ʾ�˺�ָʾ��",
["Damage color display"] = "��ʾ�˺�����ɫ",
["Miscellaneous"] = "��������",
["Auto Heal"] = "�Զ�����",
["Automatically use Heal"] = "ʹ���Զ�����",
["Min percentage to cast Heal"] = "ʹ�����Ƶ���СѪ�� %",
["Use Heal to Help teammates"] = "���Ѿ�ʹ������",
["Teammates to Heal"] = "ʹ�����Ƶ��Ѿ�",
["Auto Zhonyas"] = "�Զ�����",
["Automatically Use Zhonyas"] = "�Զ�ʹ������",
["Min Health % to use Zhonyas"] = "ʹ�����ǵ���СѪ��",
["Use W on enemy gap closers"] = "�Եз���ͻ��ʹ��W",
["Auto Q for get shield vs gap closers"] = "�Զ�Q����û����Ե���ͻ��",
["Auto use Seraph's Embrace on low Health"] = "��Ѫ��ʱ�Զ�ʹ�ô���ʹ",
["Min % to cast Seraph's Embrace"] = "ʹ�ô���ʹ����СѪ�� %",
["Prediction"] = "Ԥ��",
["-- Prediciton Settings --"] = "------ Ԥ������ ------",
["VPrediction"] = "VԤ��",
["DPrediction"] = "��ʥԤ��",
["-- VPrediction Settings --"] = "------ VԤ������ ------",
["Q Hit Chance"] = "Q��������",
["Medium"] = "�е�",
["High"] = "��",
["-- HPrediction Settings --"] = "------ HԤ������ ------",
["-- DPrediction Settings --"] = "----- ��ʥԤ������ -----",
["Instant force W"] = "����ǿ��ʹ��W",
["Flee Key"] = "���ܰ���",
["Toggle Parry Auto Attack"] = "�л����Զ�����",
["Orbwalk on Combo"] = "�������е��߿�",
["To Vital"] = "�ƶ�������",
["To Target"] = "�ƶ���Ŀ��",
["Disabled"] = "�ر�",
["Orbwalk Magnet Range"] = "�߿�������Χ",
["Vital Strafe Outwards Distance %"] = "�������������������%",
["Fiora Fun House 2.0"] = "���˺ϼ�2.0 - �ư���",
["Orbwalk Settings"] = "�߿�����",
["W Hit Chance"] = "W�������еĻ���",
["Draw R range"] = "��ʾR�ķ�Χ",
["Draw AA range"] = "��ʾƽA�ķ�Χ",
["Use IGNITE"] = "ʹ�õ�ȼ",
["Q Color"] = "Q������Ȧ��ɫ",
["Combo"] = "����",
["--- Combo Logic ---"] = "--- �����߼� ---",
["Save Q for dodge enemy hard spells"] = "����Q����ܵ��˵���Ҫ����",
["Q Gapclose regardless of vital"] = "ʹ��Qͻ��ʱ��������",
["Gapclose min catchup time"] = "ͻ����С׷��ʱ��",
["Q minimal landing position"] = "Q������ͷ�λ��",
["Q Angle in degrees"] = "Q�ĽǶ�",
["Q on minion to reach enemy"] = "QС�����ӽ�����",
["--- Ultimate R Logic ---"] = "--- ����ʹ���߼� ---",
["Focus R Casted Target"] = "����ʹ��R��Ŀ��",
["Cast when target killable"] = "��Ŀ����Ա���ɱʱʹ��R",
["Cast only when healing required (overrides above)"] = "�л�Ѫ��Ҫʱ��R",
["Cast when our HP less than %"] = "������ֵС��%ʱʹ��R",
["Cast before KS with Q when lower than"] = "����Q����ͷ֮ǰʹ��R",
["Riposte Options"] = "���������۵�(W)����",
["Riposte Enabled"] = "ʹ��W",
["Save Q Evadeee when Riposte cd"] = "��Wcdʱ����Q�����",
["Auto Parry next attack when %HP <"] = "������ֵС��%ʱ�Զ�����һ����ͨ����",
["Humanizer: Extra delay"] = "���˻��������ӳ�",
["Parry Summoner Spells (low latency)"] = "���ٻ�ʦ����(���ӳ�)",
["Parry Dragon Wind"] = "��С���Ĺ���",
["Parry Auto Attacks"] = "����ͨ����",
["Parry AA Damage Threshold"] = "��ƽA���˺��ٽ�ֵ",
["Parry is still a Work In Progress"] = "�񵲹��������ڿ����Ĺ���",
["If is not parrying a spell from the list,"] = "���û�и��б��еļ���",
["before report on forum, make a list like:"] = "����̳����֮ǰ��дһ��������һ�����б�",
["Champion-Spell that fails to parry"] = "��ʧ�ܵļ��ܣ�������д���20��",
["When you have 20+ added, post it on forum. Thanks"] = "�޷��񵲵ļ��ܣ��뷢������̳��",
["Riposte Main List"] = "����Ҫ�����б�",
["--- Riposte Spells At Arrival ---"] = "--- ���������е�ʱ��� ---",
["Riposte Extra List"] = "�񵲶��⼼���б�",
["Use Q on Harass"] = "��ɧ����ʹ��Q",
["Use Lunge (Q)"] = "ʹ���ƿ�նQ",
["Use Riposte (W) [only on Jungle]"] = "ʹ�����������۵�W[ֻ��Ұ��]",
["Use Bladework (E)"] = "ʹ�ö�������E",
["Use items"] = "ʹ����Ʒ",
["R Color"] = "R������ɫ",
["AA Color"] = "ƽA��Ȧ��ɫ",
["Draw Magnet Orbwalk range"] = "��ʾ�߿�������Χ",
["Draw Flee direction"] = "��ʾ���ܷ���",
["Draw KillText"] = "��ʾ��ɱ��ʾ",
["HPrediction"] = "HԤ��",
["SxOrbWalk"] = "Sx�߿�",
["General-Settings"] = "��������",
["Orbwalker Enabled"] = "�߿���Ч",
["Stop Move when Mouse above Hero"] = "��Ӣ���������ʱֹͣ�ƶ�",
["Range to Stop Move"] = "ֹͣ�ƶ�������",
["ExtraDelay against Cancel AA"] = "ȡ��ƽA��ҡ�Ķ����ӳ�",
["Spam Attack on Target"] = "�����ܶ��ƽAĿ��",
["Orbwalker Modus: "] = "�߿�ģʽ",
["To Mouse"] = "�����",
["Humanizer-Settings"] = "���˻�����",
["Limit Move-Commands per Second"] = "����ÿ�뷢�͵��ƶ�ָ��",
["Max Move-Commands per Second"] = "ÿ�뷢���ƶ�ָ���������",
["Key-Settings"] = "��λ����",
["FightMode"] = "ս��ģʽ",
["HarassMode"] = "ɧ��ģʽ",
["LaneClear"] = "����",
["LastHit"] = "β��",
["Toggle-Settings"] = "�л�����",
["Make FightMode as Toggle"] = "��ʾս��ģʽ�л�",
["Make HarassMode as Toggle"] = "��ʾɧ��ģʽ�л�",
["Make LaneClear as Toggle"] = "��ʾ����ģʽ�л�",
["Make LastHit as Toggle"] = "��ʾβ��ģʽ�л�",
["Farm-Settings"] = "ˢ������",
["Focus Farm over Harass"] = "��ɧ��ʱר�Ĳ���",
["Extra-Delay to LastHit"] = "β��ʱ�Ķ����ӳ�",
["Mastery-Settings"] = "�츳����",
["Mastery: Butcher"] = "����",
["Mastery: Arcane Blade"] = "˫�н�",
["Mastery: Havoc"] = "����",
["Mastery: Devastating Strikes"] = "������",
["Draw-Settings"] = "��ʾ����",
["Draw Own AA Range"] = "��ʾ�Լ���ƽA��Ȧ",
["Draw Enemy AA Range"] = "��ʾ���˵�ƽA��Ȧ",
["Draw LastHit-Cirlce around Minions"] = "��С������ʾβ����Ȧ",
["Draw LastHit-Line on Minions"] = "��С������ʾβ��ָʾ��",
["Draw Box around MinionHpBar"] = "��С��Ѫ���ϻ��ſ�",
["Color-Settings"] = "��ɫ����",
["Color Own AA Range: "] = "�Լ���ƽA��Ȧ����ɫ",
["white"] = "��ɫ",
["blue"] = "��ɫ",
["red"] = "��ɫ",
["black"] = "��ɫ",
["green"] = "��ɫ",
["orange"] = "��ɫ",
["Color Enemy AA Range (out of Range): "] = "����ƽA��Ȧ����ɫ(��Χ��)",
["Color Enemy AA Range (in Range): "] = "����ƽA��Ȧ����ɫ(��Χ��)",
["Color LastHit MinionCirlce: "] = "С��β����Ȧ��ɫ",
["Color LastHit MinionLine: "] = "С��β��ָʾ����ɫ",
["ColorBox: Minion is LasthitAble: "] = "С���ɱ�β������ɫ",
["none"] = "��",
["ColorBox: Wait with LastHit: "] = "С���ȴ���β������ɫ",
["ColorBox: Can Attack Minion: "] = "���Թ�����С����ɫ",
["TargetSelector"] = "Ŀ��ѡ����",
["Priority Settings"] = "���ȼ���ɫ",
["Focus Selected Target: "] = "����ѡ����Ŀ��",
["never"] = "�Ӳ�",
["when in AA-Range"] = "����ƽA��Χʱ",
["TargetSelector Mode: "] = "Ŀ��ѡ����ģʽ",
["LowHP"] = "��Ѫ��",
["LowHPPriority"] = "��Ѫ��+���ȼ�",
["LessCast"] = "�����ͷż���",
["LessCastPriority"] = "�����ͷż���+���ȼ�",
["nearest myHero"] = "���Լ���Ӣ�����",
["nearest Mouse"] = "��������",
["RawPriority"] = "�������ȼ�",
["Highest Priority (ADC) is Number 1!"] = "������ȼ�(ADC)Ϊ1",
["Debug-Settings"] = "����ģʽ",
["Draw Circle around own Minions"] = "�ڼ���С���ϻ�Ȧ",
["Draw Circle around enemy Minions"] = "�ڵз�С���ϻ�Ȧ",
["Draw Circle around jungle Minions"] = "��Ұ���ϻ�Ȧ",
["Draw Line for MinionAttacks"] = "��ʾС������ָʾ��",
["Log Funcs"] = "��־����",
["Irelia Fun House 2.0"] = "���˺ϼ�2.0 - �������",
["R Lane Clear toggle"] = "R�����л�",
["Force E"] = "ǿ��E",
["Q on killable minion to reach enemy"] = "�Կɻ�ɱ��С��ʹ��Q��ͻ������",
["Use Q only as gap closer"] = "��ͻ��ʱʹ��Q",
["Minimum distance for use Q"] = "ʹ��Q����С����",
["Save E for stun"] = "����E����ѣ��",
["Use E for slow if enemy run away"] = "�����������ʹ��E������",
["Use E for interrupt enemy dangerous spells"] = "ʹ��E��ϵ��˵�Σ�ռ���",
["Anti-gapclosers with E stun"] = "ʹ��Eѣ������ͻ��",
["Use R on sbtw combo"] = "ֻ��������ʹ��R",
["Cast R when our HP less than"] = "���������ֵ����%ʱʹ��R",
["Cast R when enemy HP less than"] = "����������ֵ����%ʱʹ��R",
["Block R in sbtw until Sheen/Tri Ready"] = "����Rֱ��ҫ��Ч������",
["In Team Fight, use R as AOE"] = "����ս��ʹ��R��AOE",
["Use Bladesurge (Q) on minions"] = "��С��ʹ��Q",
["Use Bladesurge (Q) on target"] = "��Ŀ��ʹ��Q",
["Use Equilibrium Strike (W)"] = "ʹ��W",
["Use Equilibrium Strike (E)"] = "ʹ��E",
["Use Bladesurge (Q)"] = "ʹ��Q",
["Use Transcendent Blades (R)"] = "ʹ��R",
["Only Q minions that can't be AA"] = "ֻ�Բ���ƽA��С��ʹ��Q",
["Block Q on Jungle unless can reset"] = "����Qֱ��Ұ�ֿ��Ա�Q��ɱ",
["Block Q on minions under enemy tower"] = "�ڵз�����ʱ����Q",
["Humanizer delay between Q (ms)"] = "Q֮������˻��ӳ�(����)",
["Use Hiten Style (W)"] = "ʹ��W",
["No. of minions to use R"] = "ʹ��R������С������",
["Maximum distance for Q in Last Hit"] = "ʹ��Qβ����������",
["E Color"] = "E��Ȧ����ɫ",
["Auto Ignite"] = "�Զ���ȼ",
["Automatically Use Ignite"] = "�Զ�ʹ�õ�ȼ",
----------------����Ϲ��---------------------
["Lee Sin Fun House 2.0"] = "���˺ϼ�2.0 - äɮ",
["Lee Sin Fun House"] = "����äɮ",
["Ward Jump Key"] = "���۰���",
["Insec Key"] = "Insec����",
["Jungle Steal Key"] = "��������",
["Insta R on target"] = "������Ŀ��ʹ��R",
["Disable R KS in combo 4 sec"] = "��4���ڹر���R����ͷ",
["Combo W->R KS (override autokill)"] = "W->R����ͷ����",
["Passive AA Spell Weave"] = "����֮���νӱ���ƽA",
["Smart"] = "ֻ��",
["Quick"] = "����",
["Use Stars Combo: RQQ"] = "ʹ���������У�RQQ",
["Use Q-Smite for minion block"] = "��С����סʱʹ��Q�ͽ�",
["Use W on Combo"] = "��������ʹ��W",
["Use wards if necessary (gap closer)"] = "ʹ��Wͻ������(�����Ҫ)",
["Cast R when it knockups at least"] = "����ܻ���x������ʹ��R",
["Cast W to Mega Kick position"] = "ʹ��W�������߶�����˵�λ��",
["Use R to stop enemy dangerous spells"] = "ʹ��R����ϵ��˵�Σ�ռ���",
["-- ADVANCED --"] = "-- �߼����� --",
["Combo-Insec value Target"] = "������Ŀ��",
["Combo-Insec with flash"] = "ʹ��R��������",
["Use R-flash if no W or wards"] = "���û��W����û����ʹ��R��",
["Use W-R-flash if Q cd (BETA)"] = "���Qcdʹ��W-R��(����)",
["Insec Mode"] = "������ģʽ",
["R Angle Variance"] = "R�ĽǶȵ���",
["KS Enabled"] = "��������ͷ",
["Autokill Under Tower"] = "�������Զ���ɱ",
["Autokill Q2"] = "ʹ�ö���Q�Զ���ɱ",
["Autokill R"] = "ʹ��R�Զ���ɱ",
["Autokill Ignite"] = "ʹ�õ�ȼ�Զ���ɱ",
["--- LANE CLEAR ---"] = "--- ���� ---",
["LaneClear Sonic Wave (Q)"] = "ʹ��Q����",
["LaneClear Safeguard (W)"] = "ʹ��W����",
["LaneClear Tempest (E)"] = "ʹ��E����",
["LaneClear Tiamat Item"] = "ʹ��������������",
["LaneClear Energy %"] = "������������%",
["--- JUNGLE CLEAR ---"] = "--- ��Ұ ---",
["Jungle Sonic Wave (Q)"] = "ʹ��Q��Ұ",
["Jungle Safeguard (W)"] = "ʹ��W��Ұ",
["Jungle Tempest (E)"] = "ʹ��E��Ұ",
["Jungle Tiamat Item"] = "ʹ������������Ұ",
["Use E if AA on cooldown"] = "ʹ��E�����չ�",
["Use Q for harass"] = "ʹ��һ��Qɧ��",
["Use Q2 for harass"] = "ʹ�ö���Qɧ��",
["Use W for retreat after Q2+E"] = "����Q+E��ʹ��W����",
["Use E for harass"] = "ʹ��E����ɧ��",
["-- Spells Range --"] = "-- ���ܷ�Χ��Ȧ --",
["Draw W range"] = "��ʾW��Χ",
["W color"] = "W������Ȧ��ɫ",
["Draw E range"] = "��ʾE��Χ",
["Combat Draws"] = "��ʾս��",
["Insec direction & selected points"] = "�����ߵĵص�&ѡ���ĵص�",
["Collision & direction for direct R"] = "��ײ&ֱ��R�ķ���",
["Draw non-Collision R direction"] = "��ʾ����ײ��R�ķ���",
["Collision & direction Prediction"] = "��ײ&����Ԥ��",
["Draw Damage"] = "��ʾ�˺�",
["Draw Kill Text"] = "��ʾ��ɱ��ʾ",
["Debug"] = "����",
["Focus Selected Target"] = "����ѡ���Ŀ��",
["Always"] = "����",
["Auto Kill"] = "�Զ���ɱ",
["Insec Wardjump Range Reduction"] = "���������۷�Χ����",
["Magnetic Wards"] = "��������Բ���",
["Enable Magnetic Wards Draw"] = "���������Բ�����ʾ",
["Use lfc"] = "ʹ��lfc",
["--- Spots to be Displayed ---"] = "--- ��ʾ�Ĳ��۵� ---",
["Normal Spots"] = "��ͨ�ص�",
["Situational Spots"] = "ȡ��������ĵص�",
["Safe Spots"] = "��ȫ�ص�",
["--- Spots to be Auto Casted ---"] = "--- �Զ����۵ĵص� ---",
["Disable quickcast/smartcast on items"] = "���ÿ���/����ʹ����Ʒ",
["--- Possible Keys for Trigger ---"] = "--- ���ܴ����İ��� ---",
--------------���˹Ѹ�----------------------
["Evelynn Fun House 2.0"] = "���˺ϼ�2.0 - ��ܽ��",
["Force R Key"] = "ǿ�ƴ��а���",
["Use Agony's Embrace (R)"] = "ʹ��R",
["Required enemies to cast R"] = "ʹ��R��Ҫ�ĵ�����",
["Auto R on low HP as life saver"] = "�ڵ�Ѫ����ʱ���Զ�R�Ծ���",
["Minimum % of HP to auto R"] = "�Զ�R����С��������ֵ",
["Use Hate Spike (Q)"] = "ʹ������֮��(Q)",
["Use Ravage (E)"] = "ʹ�û�����(E) ",
["Draw A range"] = "��ʾƽA��Χ",
["A color"] = "ƽA��Ȧ��ɫ",
["Reverse Passive Vision"] = "��ת������Ұ",
["Vision Color"] = "��Ұ��ɫ",
["Stealth Status"] = "����״̬",
["Spin Color"] = "��ת��ɫ",
["Info Box"] = "��Ϣ��",
["X position of menu"] = "�˵���X��λ��",
["Y position of menu"] = "�˵���Y��λ��",
["W Settings"] = "W��������",
["Use W on flee mode"] = "������ģʽʹ��W",
["Use W for cleanse enemy slows"] = "ʹ��W���Ƴ����˵ļ���",
["R Hit Chance"] = "R���еĻ���",
["E color"] = "E��Ȧ��ɫ",
["R color"] = "R��Ȧ��ɫ",
["Key Binds"] = "��λ����",
--------------���˱�Ůʨ�ӹ��Ƽ�------------
["FH Smite"] = "���� �ͽ�",
["Jungle Camps"] = "Ұ��Ӫ��",
["Enable Auto Smite"] = "�����Զ��ͽ�",
["Temporally Disable Autosmite"] = "��ʱ���óͽ�",
["--- Global Objectives ---"] = "--- ȫ��Ŀ�� ---",
["Rift Scuttler Top"] = "��·�ӵ�з",
["Rift Herald"] = "Ͽ���ȷ�",
["Rift Scuttler Bot"] = "��·�ӵ�з",
["Baron"] = "����",
["Dragon"] = "С��",
["--- Normal Camps ---"] = "-- ��ͨҰ�� --",
["Murk Wolf"] = "��Ӱ��",
["Red Buff"] = "��buff",
["Blue Buff"] = "��buff",
["Gromp"] = "ħ����",
["Raptors"] = "�����(F4)",
["Krugs"] = "ʯ�׳�",
["Chilling Smite KS"] = "��˪�ͽ�����ͷ",
["Chilling Smite Chase"] = "��˪�ͽ�׷��",
["Challenging Smite Combat"] = "��������ʹ����ս�ͽ�",
["Forced Smite on Enemy"] = "ǿ�Ƴͽ����",
["Draw Smite % damage"] = "��ʾ�ͽ�ٷֱ��˺�",
["Smite Fun House"] = "�ͽ� ����",
["Taric"] = "�����",
["Nidalee Fun House 2.0"] = "���˺ϼ�2.0 - �ε���",
["Nidalee Fun House"] = "���˺ϼ� - �ε���",
["Harass Toggle Q"] = "Qɧ�ſ���",
["Use W on combo (human form)"] = "��������ʹ��W(����̬)",
["Immobile"] = "�����ƶ���",
["Mana Min percentage W"] = "W����С����%",
["E for SpellWeaving/DPS"] = "ʹ��E���������",
["Auto heal E"] = "E�Զ���Ѫ",
["Self"] = "�Լ�",
["Self/Ally"] = "�Լ�/�Ѿ�",
["Min percentage hp to auto heal"] = "�Զ���Ѫ����С����Ѫ��%",
["Min mana to cast E"] = "ʹ��E����С����",
["Smart R swap"] = "����R�л���̬",
["Allow Mid-Jump Transform"] = "������Ծ�Ŀ��б任��̬",
["Harass (Human form)"] = "ɧ��(����̬)",
["Use Javelin Toss (Q)"] = "ʹ������̬Qɧ��",
["Use Toggle Key Override (Keybinder Menu)"] = "ʹ�ð������ظ���",
["Min mana to cast Q"] = "ʹ��Q����С����",
["Flee"] = "����",
["W for Wall Jump Only"] = "Wֻ������ǽ",
["Lane Clear with AA"] = "ʹ��ƽA����",
["Use Bushwhack (W)"] = "ʹ������̬W",
["Use Primal Surge (E)"] = "ʹ������̬E",
["Use Takedown (Q)"] = "ʹ�ñ���̬Q",
["Use Pounce (W)"] = "ʹ�ñ���̬W",
["Use Swipe (E)"] = "ʹ�ñ���̬E",
["Use Aspect of the Cougar (R)"] = "ʹ��R",
["Mana Min percentage"] = "��С�����ٷֱ�",
["Draw Q range (Human)"] = "��ʾ����̬Q��Χ",
["Draw W range (Human)"] = "��ʾ����̬W��Χ",
["W color (Human)"] = "����̬W��Ȧ��ɫ",
["Draw E range (Human)"] = "��ʾ����̬E��Χ",
["Karthus"] = "������˹",
["Rengar Fun House 2.0"] = "���˺ϼ�2.0 - �׶��Ӷ�",
["Rengar Fun House"] = "���˺ϼ� - �׶��Ӷ�",
["Force E Key"] = "ǿ��E����",
["Combo Mode Key"] = "����ģʽ����",
["Use empower W if health below %"] = "������ֵ����%ʹ��ǿ��W",
["Min health % for use it ^"] = "ʹ�õ���С����ֵ%",
["Use E on Dynamic Combo if enemy is far"] = "������˾����Զ�ڶ�̬������ʹ��E",
["Playing AP rengar !"] = "APʨ�ӹ�ģʽ",
["Use E on AP Combo if enemy is far"] = "������˾����Զ��AP������ʹ��E",
["Anti Dashes"] = "��ͻ��",
["Antidash Enemy Enabled"] = "�Ե������÷�ͻ��",
["LaneClear Savagery (Q)"] = "��������ʹ��Q",
["LaneClear Battle Roar (W)"] = "��������ʹ��W",
["LaneClear Bola Strike (E)"] = "��������ʹ��E",
["stop using spells at 5 stacks"] = "5��б���ʱ��ֹͣʹ�ü���",
["Jungle Savagery (Q)"] = "����Ұ��ʹ��Q",
["Jungle Battle Roar (W)"] = "����Ұ��ʹ��W",
["Jungle Bola Strike (E)"] = "����Ұ��ʹ��E",
["Jungle Savagery (Q) Empower"] = "����Ұ��ʹ��ǿ��Q",
["Jungle Battle Roar (W) Empower"] = "����Ұ��ʹ��W",
["Use Q if AA on cooldown"] = "ʹ��Q�������չ�",
["Use W if AA on cooldown"] = "ʹ��W�������չ�",
["Use W for harass"] = "ʹ��Wɧ��",
["Draw R timer"] = "��ʾR��ʱ��",
["Draw R Stealth Distance"] = "��ʾR�������",
["Draw R on:"] = "��ʾR״̬:",
["Center of screen"] = "����Ļ����",
["Champion"] = "Ӣ��",
["-- Draw Combo Mode values --"] = "-- ��ʾ����ģʽ���� --",
["E Hit Chance"] = "E���еĻ���",
["Swain"] = "˹ά��",
["Azir Fun House 2.0"] = "���˺ϼ�2.0 - ���ȶ�",
["Force Q"] = "ǿ��Q",
["Quick Dash Key"] = "����ͻ������",
["Panic R"] = "����ģʽR",
["--- Q LOGIC ---"] = "--- Q�����߼� ---",
["Q prioritize soldier reposition"] = "Q��������ɳ����λ��",
["Always expend W before Q Cast"] = "����Q֮ǰ��W",
["--- W LOGIC ---"] = "--- W�����߼� ---",
["W Cast Method"] = "�ͷ�W�ķ�ɹ˪",
["Always max range"] = "������������",
["Min Mana % to cast extra W"] = "�ͷŶ���W����С����%",
["--- E LOGIC ---"] = "--- E�����߼� ---",
["E to target when safe"] = "����ȫʱE��Ŀ��",
["--- R LOGIC ---"] = "--- R�����߼� ---",
["Single target R in melee range"] = "���ڽ�ս���������ʱ��ֻRһ��Ŀ��",
["To Soldier"] = "��ɳ���ͷ�",
["To Ally/Tower"] = "���Ѿ�/���ͷ�",
["Single target R only under self HP"] = "ֻ���Լ�����ֵ����xʱֻRһ��Ŀ��",
["Multi target R logic"] = "��Ŀ��R�߼�",
["Block"] = "����",
["Multi target R at least on"] = "��Ŀ��Rʱ��СĿ����",
["R enemies into walls"] = "�ѵо��Ƶ�ǽ��",
["Use orbwalking on combo"] = "��������ʹ���߿�",
["--- Automated Logic ---"] = "--- �Զ������߼� ---",
["Auto R when at least on"] = "��Ŀ��������x��ʱ�Զ�R",
["Block Sion Ult (Beta)"] = "�ֵ�������R(����)",
["Interrupt channelled spells with R"] = "ʹ��R�����������",
["R enemies back into tower range"] = "�ѵ����Ƶ�����Χ��",
["Block Gap Closers with R"] = "ʹ��R��ͻ��",
["R-Combo Casts"] = "ʹ��R����",
["--- COMBO-DASH LOGIC ---"] = "--- ͻ�������߼� ---",
["Smart DASH chase in combo"] = "��׷��ʱʹ������ͻ������",
["Min Self HP % to smart dash"] = "��������ֵ����%ʱʹ������ͻ��",
["Max target HP % to smart dash"] = "Ŀ������ֵС��%ʱʹ������ͻ��",
["Max target HP % dash in R CD"] = "RcdʱĿ��",
["ASAP R to ally/tower after dash hit"] = " ",
["Dash R Area back range"] = " ",
["--- COMBO-INSEC LOGIC ---"] = "--- Insec�����߼� ---",
["Smart new-INSEC in combo"] = "��������ʹ��������Insec����",
["new-Insec only x allies more"] = "ֻ�ڴ���x���Ѿ�ʱʹ����Insec����",
["Use W on Harass"] = "��ɧ����ʹ��W",
["Number of W used"] = "ʹ��W������",
["Insec / Dash"] = "Insec / ͻ��",
["Min. gap from soldier in dash"] = "ͻ��ʱ���ٴ��ڵ�ɳ����",
["Abs. R delay after Q cast"] = "��Q�ͷź��ͷ�R���ӳ�",
["Insec Extension"] = "Insec���������",
["From Soldier"] = "��ɳ��",
["From player"] = "�������",
["Direct Hit"] = "ֱ�ӻ���",
["Use Conquering Sands (Q)"] = "ʹ��Q",
["Use Shifting Sands (E)"] = "ʹ��E",
["Use Emperor's Divide (R)"] = "ʹ��R",
["Use Arise! (W)"] = "ʹ��W",
["Number of Soldiers"] = "ɳ����Ŀ",
["Use W for AA if outside AA range"] = "�����ƽA��Χ��ʹ��W����",
["Draw Soldier range"] = "��ʾɳ���Ĺ�����Χ",
["Draw Soldier time"] = "��ʾɳ������ʱ��",
["Draw Soldier Line"] = "��ʾɳ��ָʾ��",
["Soldier and line color"] = "ɳ����ָʾ���ߵ���ɫ",
["Soldier out-range color"] = "��Χ���ɳ������ɫ",
["Draw Dash Area"] = "��ʾͻ��������",
["Dash color"] = "ͻ��������ɫ",
["Draw Insec range"] = "��ʾInsec�ķ�Χ",
["Insec Draws"] = "Insec��ʾ",
["Draw Insec Direction on target"] = "��Ŀ������ʾInsec�ķ���",
["Cast Ignite on Swain"] = "��˹ά��ʹ�õ�ȼ",
--------------QQQ����-----------------------
["Yasuo - The Windwalker"] = "������ - ����",
["----- General settings --------------------------"] = "----- �������� --------------------------",
["> Keys"] = "> ��������",
["> Orbwalker"] = "> �߿�����",
["> Targetselector"] = "> Ŀ��ѡ����",
["> Prediction"] = "> Ԥ������",
["> Draw"] = "> ��ʾ����",
["> Cooldowntracker"] = "> ��ȴ��ʱ",
["> Scripthumanizer"] = "> �ű����˻�",
["----- Utility settings -----------------------------"] = "----- �������� --------------------------",
["> Windwall"] = "> ��ǽ",
["> Ultimate"] = "> ����",
["> Turretdive"] = "> Խ��",
["> Gapclose"] = "> ͻ��",
["> Walljump"] = "> ��ǽ",
["> Spells"] = "> ����",
["> Summonerspells"] = "> �ٻ�ʦ����",
["> Items"] = "> ��Ʒ",
["----- Combat settings ----------------------------"] = "----- ս������ --------------------------",
["> Combo"] = "> ����",
["> Harass"] = "> ɧ��",
["> Killsteal"] = "> ����ͷ",
["> Lasthit"] = "> β��",
["> Laneclear"] = "> ����",
["> Jungleclear"] = "> ��Ұ",
["----- About the script ---------------------------"] = "���ڱ��ű�",
["Gameregion"] = "��Ϸ����",
["Scriptversion"] = "�ű��汾",
["Author"] = "����",
["Updated"] = "��������",
["\"The road to ruin is shorter than you think...\""] = "����֮·,�̵ĳ����������",
["This section is only a placeholder for more structure"] = "�������ֻ�Ǵ�������ݵ�Ԥ��λ��",
["Choose targetselector mode"] = "ѡ��Ŀ��ѡ����λ��",
["LESS_CAST"] = "����ʹ�ü���",
["LOW_HP"] = "��Ѫ��",
["SELECTED_TARGET"] = "ѡ����Ŀ��",
["PRIORITY"] = "���ȼ�",
["Set your priority here:"] = "�������趨���ȼ�",
["No targets found / available! "] = "û���ҵ�Ŀ��",
["Draw your current target with circle:"] = "����ĵ�ǰĿ���ϻ�Ȧ",
["Draw your current target with line:"] = "����ĵ�ǰĿ���ϻ���",
["Use Gapclose"] = "ʹ��ͻ��",
["Check health before gapclosing under towers"] = "������ͻ��ʱ���Ѫ��",
["Only gapclose if my health > % "] = "ֻ���ҵ�Ѫ������%ʱͻ��",
["> Settings "] = "> ����",
["Set Gapclose range"] = "����ͻ������",
["Draw gapclose target"] = "��ʾͻ��Ŀ��",
["> General settings"] = "> ��������",
["Use Autowall: "] = "ʹ���Զ���ǽ:",
["Draw skillshots: "] = "�������ܵ���",
["> Humanizer settings"] = "> ���˻�����",
["Use Humanizer: "] = "ʹ�����˻�",
["Humanizer level"] = "���˻��ȼ�",
["Normal mode"] = "��ͨģʽ",
["Faker mode"] = "Fakerģʽ",
["> Autoattack settings"] = "> ��ͨ��������",
["Block autoattacks: "] = "������ͨ����:",
["if your health is below %"] = "����������ֵ����%",
["> Skillshots"] = "> ���ܵ���",
["No supported skillshots found!"] = "û���ҵ�֧�ֵļ���",
["> Targeted spells"] = "> ָ���Լ���",
["No supported targeted spells found!"] = "û���ҵ�֧�ֵ�ָ���Լ���",
[">> Towerdive settings"] = ">> Խ������",
["Towerdive Mode"] = "Խ��ģʽ",
["Never dive turrets"] = "�Ӳ�Խ��",
["Advanced mode"] = "�߼�ģʽ",
["Draw turret range: "] = "��ʾ��������Χ: ",
[">> Normal Mode Settings"] = ">> ��ͨģʽ����",
["Min number of ally minions"] = "��С�ѷ�С����",
[">> Easy Mode Settings"] = ">> ��ģʽ����",
["Min number of ally champions"] = "��С�ѷ�Ӣ����",
["> Info about normal mode"] = "> ��ͨģʽ����",
[">| The normal mode checks for x number of ally minions"] = ">| ��ͨģʽ������������ѷ�С��������",
[">| under enemy turrets. If ally minions >= X then it allows diving!"] = ">| ����ѷ�С�������ڵ���x�ͻ�����Խ��",
["> Info about advanced mode"] = "> �߼�ģʽ����",
[">| The advanced mode checks for x number of ally minions"] = "�߼�ģʽ������������ѷ�С������",
[">| as well as for x number of ally champions under enemy turrets."] = "�ͷ������ѷ�Ӣ������",
[">| If both >= X then it allows diving!"] = "��������ڵ���x�ͻ�����Խ��",
["Always draw the indicators"] = "������ʾ�˺�Ԥ��",
["Only draw while holding"] = "ֻ���ڰ�����ʱ�����ʾ",
["Not draw inidicator if pressed"] = "�ڰ�����ʱ����ʾ",
["> Draw cooldowns for:"] = "> ��ʾcdʱ��",
["your enemies"] = "�з�Ӣ��",
["your allies"] = "�ѷ�Ӣ��",
["your hero"] = "�Լ�",
["Show horizontal indicators"] = "��ʾˮƽ���˺�Ԥ��",
["Show vertical indicators"] = "��ʾ��ֱ���˺�Ԥ��",
["Vertical position"] = "��ֱ�˺�Ԥ���λ��",
["> Choose your Color"] = "> ѡ����ɫ",
["Cooldown color"] = "cd��ʱ��ɫ",
["Ready color"] = "���ܾ�������ɫ",
["Background color"] = "������ɫ",
["> Summoner Spells"] = "> �ٻ�ʦ����",
["Flash"] = "����",
["Ghost"] = "���鼲��",
["Barrier"] = "����",
["Smite"] = "�ͽ�",
["Exhaust"] = "����",
["Heal"] = "����",
["Teleport"] = "����",
["Cleanse"] = "����",
["Clarity"] = "������",
["Clairvoyance"] = "����",
["The Rest"] = "����",
[">> Combat keys"] = ">> ս������",
["Combo key"] = "���а���",
["Harass key"] = "ɧ�Ű���",
["Harass (toggle) key"] = "ɧ��(����)����",
["Ultimate (toggle) key"] = "����(����)����",
[">> Farm keys"] = ">> ��������",
["Lasthit key"] = "β������",
["Jungle- and laneclear key: "] = "��Ұ�����߰���",
[">> Other keys"] = ">> ��������",
["Escape-/Walljump key"] = "����/��ǽ����",
["Autowall (toggle) key"] = "�Զ���ǽ(����)����",
["Use walljump"] = "ʹ�ô�ǽ",
["Priority to gain vision"] = "�����Ұ�����ȼ�",
["Wards"] = "��",
["Wall"] = "��ǽ",
["> Draw jumpspot settings"] = "> ��ʾ��ǽλ��",
["Draw points"] = "��ʾ��",
["Draw jumpspot while key pressed"] = "��������ʱ��ʾ��ǽλ��",
["Radius of the jumpspots"] = "��ǽ��뾶",
["Max draw distance"] = "�����ʾ����",
["Draw line to next jumpspots"] = "��ʾ����һ��ǽ���ֱ��",
["> Draw jumpspot colors"] = "> ��ʾ��ǽ�����ɫ",
["Jumpspot color"] = "��ǽ�����ɫ",
["(E) - Sweeping Blade settings: "] = "(E) - ̤ǰն����",
["Increase dashtimer by"] = "����ͻ��ʱ��",
[">| This option will increase the time how long the script"] = ">| �������û�ͨ��һ���趨��ֵ������",
[">| thinks you are dashing by a fixed value"] = ">| �ű���Ϊ������ͻ����ʱ��",
["Check distance of target and (E)endpos"] = "���Ŀ���E�����ص�ľ���",
["Maximum distance"] = "������",
[">| This option will check if the distance"] = ">| �������û������Ŀ��",
[">| between your target and the endposition of your (E) cast"] = ">| ��E�����ص�ľ���",
[">| is greater then the distance set in the slider."] = "����������趨�ľ���",
[">| If yes the cast will get blocked!"] = "�ͻ�����E���ͷ�",
[">| This prevents dashing too far away from your target!"] = "��������ͻ��ʱ��Ŀ�����̫Զ",
["Auto Level Enable/Disable"] = "�Զ��ӵ� ����/�ر�",
["Auto Level Skills"] = "�Զ���������",
["No Autolevel"] = "���Զ��ӵ�",
["> Autoultimate"] = "> �Զ�����",
["Number of Targets for Auto(R)"] = "�Զ�����ʱ��Ŀ����",
[">| Auto(R) ignores settings below and only checks for X targets"] = ">| �Զ����л�����X��Ŀ��ʱ���ͷ�",
["> General settings:"] = "> ��������",
["Delay the ultimate for more CC"] = "�ӳٴ����ͷ����ӳ�����ʱ��",
["DelayTime "] = "�ӳ�ʱ��",
["Use (Q) while ulting"] = "���Ŵ�ʱʹ��Q",
["Use Ultimate under towers"] = "������ʹ�ô���",
["> Target settings:"] = "> Ŀ������",
["No supported targets found/available"] = "û���ҵ���ЧĿ��",
["> Advanced settings:"] = "> �߼�����:",
["Check for target health"] = "���Ŀ���Ѫ��",
["Only ult if target health below < %"] = "ֻ��Ŀ������ֵС��%ʱʹ�ô���",
["Check for our health"] = "����Լ���Ѫ��",
["Only ult if our health bigger > %"] = "ֻ���Լ�����ֵ����%ʱʹ�ô���",
["General-Settings"] = "��������",
["Orbwalker Enabled"] = "�����߿�",
["Allow casts only for targets in camera"] = "ֻ��Ŀ������Ļ��ʱ����ʹ�ü���",
["Windwall only if your hero is on camera"] = "ֻ�����Ӣ������Ļ��ʱʹ�÷�ǽ",
["> Packet settings:"] = "> �������",
["Limit packets to human level"] = "> ���Ʒ��������Ĳ���ˮƽ",
[">> General settings"] = ">> ��������",
["Choose combo mode"] = "ѡ������ģʽ",
["Prefer Q3-E"] = "����Q3-E",
["Prefer E-Q3"] = "����E-Q3",
["Use items in Combo"] = "��������ʹ����Ʒ",
[">> Choose your abilities"] = ">> ѡ����ļ���",
["(Q) - Use Steel Tempest"] = "ʹ��Q",
["(Q3) - Use Empowered Tempest"] = "ʹ�ô������Q",
["(E) - Use Sweeping Blade"] = "ʹ��E",
["(R) - Use Last Breath"] = "ʹ��R",
["Choose mode"] = "ѡ��ģʽ",
["1) Normal harass"] = "1)��ͨɧ��",
["2) Safe harass"] = "2)��ȫɧ��",
["3) Smart E-Q-E Harass"] = "3)����E-Q-Eɧ��",
["Enable smart lasthit if no target"] = "��������β�����û��Ŀ��",
["Enable smart lasthit if target"] = "����ֻ��β�������Ŀ��",
["|> Smart lasthit will use spellsettings from the lasthitmenu"] = "|> ����β����ʹ��β���˵���ļ�������",
["|> Mode 1 will simply harass your enemy with spells"] = "|> ģʽ1��򵥵��ü���ɧ�ŵз�",
["|> Mode 2 will harass your enemy and e back if possible"] = "|> ģʽ2��ɧ�ŵз�����������ܵĻ�E����",
["|> Mode 3 will engage with e - harass and e back if possible"] = "|> ģʽ3���E���ܲ�ɧ�Ŷ�����E����",
["Use Smart Killsteal"] = "ʹ����������ͷ",
["Use items for Laneclear"] = "������ʱʹ����Ʒ",
["Choose laneclear mode for (E)"] = "ѡ��E���ߵ�ģʽ",
["Only lasthit with (E)"] = "ֻ��E��β��",
["Use (E) always"] = "����ʹ��E",
["Choose laneclear mode for (Q3)"] = "ѡ��������Q������ģʽ",
["Cast to best pos"] = "�����λ���ͷ�",
["Cast to X or more amount of units "] = "�����ڵ���X����λʱ�ͷ�",
["Min units to hit with (Q3)"] = "ʹ��Q3ʱ����С��λ��",
["Check health for using (E)"] = "ʹ��Eǰ���Ѫ��",
["Only use (E) if health > %"] = "ֻ������ֵ����%ʱʹ��E",
[">> Choose your spinsettings"] = ">> ѡ����Q����",
["Prioritize spinning (Q)"] = "���Ȼ���Q",
["Prioritize spinning (Q3)"] = "���Ȼ���Q3",
["Min units to hit with spinning"] = "����Q�ܻ��е���С��λ��",
["Use items to for Jungleclear"] = "��Ұʱʹ����Ʒ",
["Choose Prediction mode"] = "ѡ��Ԥ��ģʽ",
[">> VPrediction"] = ">> VԤ��",
["Hitchance of (Q): "] = "Q���еĻ���",
["Hitchance of (Q3): "] = "Q3���еĻ���",
[">> HPrediction"] = ">> HԤ��",
[">> Found Summonerspells"] = ">> �ٻ�ʦ����",
["No supported spells found"] = "û���ҵ�֧�ֵ��ٻ�ʦ����",
["Disable ALL drawings of the script"] = "�رմ˽ű���������ʾ",
["Draw spells only if not on cooldown"] = "ֻ��ʾ�����ļ�����Ȧ",
["Draw fps friendly circles"] = "ʹ�ò�Ӱ��fps����Ȧ",
["Choose strength of the circle"] = "ѡ����Ȧ������",
["> Other settings:"] = "> ��������",
["Draw airborne targets"] = "��ʾ�����ɵ�Ŀ��",
["Draw remaining (Q3) time"] = "��ʾQ3ʣ��ʱ��",
["Draw damage on Healthbar: "] = "��Ѫ������ʾ�˺�",
["> Draw range of spell"] = "> ��ʾ���ܷ�Χ",
["Draw (Q): "] = "��ʾQ",
["Draw (Q3): "] = "��ʾQ3",
["Draw (E): "] = "��ʾE",
["Draw (W): "] = "��ʾW",
["Draw (R): "] = "��ʾR",
["> Draw color of spell"] = "> ��ʾ��Ȧ����ɫ",
["(Q) Color:"] = "Q��ɫ",
["(Q3) Color:"] = "Q3��ɫ",
["(W) Color:"] = "W��ɫ",
["(E) Color:"] = "E��ɫ",
["(R) Color:"] = "R��ɫ",
["Healthbar Damage Drawings: "] = "Ѫ���˺���ʾ",
["Startingheight of the lines: "] = "ָʾ�߸߶�",
["Draw smart (Q)+(E)-Damage: "] = "��ʾ����Q+E�˺�",
["Draw (Q)-Damage: "] = "��ʾQ�˺�",
["Draw (Q3)-Damage: "] = "��ʾQ3�˺�",
["Draw (E)-Damage: "] = "��ʾE�˺�",
["Draw (R)-Damage: "] = "��ʾR�˺�",
["Draw Ignite-Damage: "] = "��ʾ��ȼ�˺�",
["Permashow: "] = "״̬��ʾ:",
["Permashow HarassToggleKey "] = "��ʾɧ�ſ��ذ���",
["Permashow UltimateToggleKey"] = "��ʾ���п��ذ���",
["Permashow Autowall Key"] = "��ʾ�Զ���ǽ����",
["Permashow Prediction"] = "��ʾԤ��״̬",
["Permashow Walljump"] = "��ʾ��ǽ״̬",
["Permashow HarassMode"] = "��ʾɧ��ģʽ",
[">| You need to reload the script (2xF9) after changes here!"] = ">| �޸Ĵ˴����ú�����ҪF9����",
["> Healthpotions:"] = "> �Զ�Ѫҩ",
["Use Healthpotions"] = "ʹ��Ѫƿ",
["if my health % is below"] = "����Լ�����ֵ����%",
["Only use pots if enemys around you"] = "ֻ�ڸ����е��˵�ʱ���Զ�ʹ��ҩˮ",
["Range to check"] = "��鷶Χ",
------------------------��ʥ��ʶ-------------------------
["Divine Awareness"] = "��ʥ��ʶ",
["Debug Settings"] = "��������",
["Colors"] = "��ɫ",
["Stealth/sight wards/stones/totems"] = "���ε�λ/��/��ʯ/��Ʒ",
["Vision wards/totems"] = "��ʾ��λ",
["Traps"] = "����",
["Key Bindings"] = "��λ����",
["Wards/Traps Range (DEFAULT IS ~ KEY)"] = "��λ/���巶Χ(Ĭ����~��)",
["Enemy Vision (default ~)"] = "�з���Ұ(Ĭ����~��)",
["Timers Call (default CTRL)"] = "��ʱ��(Ĭ��Ctrl��)",
["Mark Wards and Traps"] = "�����λ������",
["Mark enemy flashes/dashes/blinks"] = "��ǵ��˵�����/ͻ������",
["Towers"] = "������",
["Draw enemy tower ranges"] = "������������Χ",
["Draw ally tower ranges"] = "�����ѷ�����Χ",
["Draw tower ranges at distance"] = "��һ�������ڲ���ʾ����Χ",
["Timers"] = "��ʱ��",
["Display Jungle Timers"] = "��ʾ��Ұ��ʱ",
["Display Inhibitor Timers"] = "��ʾˮ����ʱ",
["Display Health-Relic Timers"] = "��ʾ�ݵ��ʱ",
["Way Points"] = "·����ʾ",
["Draw enemy paths"] = "��ʾ���˵�·��",
["Draw ally paths"] = "��ʾ�Ѿ���·��",
["Draw last-seen champ map icon"] = "��С��ͼ��ʾ�������һ�γ��ֵ�λ��",
["Draw enemy FoW minions line"] = "��ʾս��������ı���",
["Notification Settings"] = "��ʾ����",
["Gank Prediction"] = "GankԤ��",
["Feature"] = "�ص�",
["Play alert sound"] = "������ʾ��",
["Add to screen text alert"] = "����Ļ��ʾ��ʾ����",
["Draw screen notification circle"] = "����Ļ��ʾ��ʾ��Ȧ",
["Print in chat (local) a gank notification"] = "���������ʾgank��ʾ(���ص�)",
["FoW Camps Attack"] = "ս���������",
["Log to Chatbox."] = "��½ChatBox",
["Auto SS caller / Pinger"] = "������ʧ�Զ�����/���",
["Summoner Spells and Ult"] = "�ٻ�ʦ���ܺʹ���",
["Send timers to chat"] = "����ʱ�����͵������",
["Key (requires cursor over tracker)"] = "����(��Ҫ����ƶ���cd������)",
["On FoW teleport/recall log client-sided chat notification"] = "���������ս��������Ĵ���/�س�",
["Cooldown Tracker"] = "cd����",
["HUD Style"] = "HUD���",
["Chrome [Vertical]"] = "Chrome[��ֱ��]",
["Chrome [Horizontal] "] = "Chrome[ˮƽ��]",
[" Classic [Vertical]"] = "���� [��ֱ��]",
["Classic [Horizontal]"] = "���� [ˮƽ��]",
["Lock Side HUDS"] = "����HUD",
["Show Allies Side CD Tracker"] = "��ʾ�ѷ���cd",
["Show Enemies Side CD Tracker"] = "��ʾ�з���cd",
["Show Allies Over-Head CD Tracker"] = "��ʾ�Ѿ�ͷ����cd",
["Show Enemies Over-Head CD Tracker"] = "��ʾ�з�ͷ����cd",
["Include me in tracker"] = "��ʾ�Լ���cd",
["Cooldown Tracker Size"] = "cd��ʱ����С",
["Reload Sprites (default J)"] = "���¼���ͼƬ(Ĭ��J)",
["Enable Scarra Warding Assistance"] = "���ò�������",
["Automations"] = "�Զ�",
["Lantern Grabber"] = "�Զ������",
["Max Radius to trigger"] = "���������뾶",
["Hotkey to trigger"] = "�����İ���",
["Allow automation based on health"] = "ȡ��������ֵ���Զ�",
["Auto trigger when health% < "] = "������ֵС��%ʱ�Զ�����",
["Enable BaseHit"] = "���û��ش���",
["Auto Level Sequence"] = "�Զ��ӵ�˳��",
["Auto Leveling"] = "�Զ��ӵ�",
["Vision ward on units stealth spells"] = "�Զ������۷���",
["Voice Awareness"] = "������ʾ",
["Mode"] = "ģʽ",
["Real"] = "��������",
["Robot"] = "����������",
["Gank Alert Announcement"] = "Gank��ʾ",
["Recall/Teleport Announcement"] = "�س�/������ʾ",
["Compliments upon killing a champ"] = "ɱ��֮��ĳ���",
["Motivations upon dying"] = "����֮��Ĺ���",
["Camp 1 min respawn reminder"] = "ˮ��1���Ӹ�������",
["Base Hit Announcement"] = "���ش�����ʾ",
["FoW  Camps Attack Alert"] = "��ս�������еĹ�������",
["Evade Assistance"] = "�������",
["Patch "] = "�汾",
-----------------------Better Nerf����----------------
["[Better Nerf] Twisted Fate"] = "[Better Nerf] ���ƴ�ʦ",
["[Developer]"] = "[������]",
["Donations are fully voluntary and highly appreciated"] = "��������ȫ��Ը��,�������Ƿǳ���л����",
["[Orbwalker]"] = "[�߿�]",
["Lux"] = "����˿",
["[Targetselector]"] = "[Ŀ��ѡ����]",
["[Prediction]"] = "[Ԥ��]",
["Extra delay"] = "�����ӳ�",
["Auto adjust delay (experimental)"] = "�Զ������ӳ�(����)",
["[Performance]"] = "[��������]",
["Limit ticks"] = "���ư�������",
["Checks per second"] = "ÿ����",
["[Card Picker]"] = "[������]",
["Enable"] = "����",
["Gold"] = "����",
["[Ultimate]"] = "[����]",
["Cast predicted Ultimate through sprite"] = "ͨ��С��ͼʹ��Ԥ�д���",
["Adjust R range"] = "����R��Χ",
["Pick card when porting with Ultimate"] = "���д���ʱѡ��",
["[Combo]"] = "[����]",
["Logic"] = "�߼�",
["[Wild Cards]"] = "[������(Q)]",
["Stunned"] = "ѣ��",
["Hitchance"] = "���м���",
["Ignore Logic if enemy closer <"] = "�о�����С��xʱ��ʹ�������߼�",
["Max Distance"] = "������",
["[Pick a Card]"] = "[ѡ��(W)]",
["Card picker"] = "������",
["Pick card logic"] = "ѡ���߼�",
["Distance check"] = "������",
["Pick red, if hit more than 1"] = "����ܻ��ж���һ�����˾��к���",
["Pick Blue if mana is below %"] = "�����������%��������",
[" > Use (Q) - Wild Cards"] = " > ʹ��Q - ������",
[" > Use (W) - Pick a Card"] = "> ʹ��W - ѡ��",
["Don't combo if mana < %"] = "�����������%��ʹ������",
["[Harass]"] = "[ɧ��]",
["Harass #1"] = "ɧ�� #1",
["Don't harass if mana < %"] = "��������%ʱ��ɧ��",
["[Farm]"] = "[����]",
["Card"] = "����",
["Clear!"] = "����",
["Don't farm with Q if mana < %"] = "��������%ʱ��ʹ��Q",
["Don't farm with W if mana < %"] = "��������%ʱ��ʹ��W",
["[Jungle Farm]"] = "[��Ұ]",
["Jungle Farm!"] = "��Ұ!",
["[Draw]"] = "[��ʾ����]",
["[Hitbox]"] = "[�������]",
["Color"] = "��ɫ",
["Quality"] = "����",
["Width"] = "���",
["[Q - Wild Cards]"] = "Q -������",
["Ready"] = "����",
["Draw mode"] = "��ʾģʽ",
["Default"] = "Ĭ��",
["Highlight"] = "����",
["[W - Pick a Card]"] = "[W - ѡ��]",
["[E - Stacked Deck]"] = "[E - ����ƭ��]",
["Text"] = "����",
["Sprite"] = "ͼƬ",
["[TEXT]"] = "[����]",
["[SPRITE]"] = "[ͼƬ]",
["Color Stack 1-3"] = "��ɫ���� 1-3",
["Color Stack 4"] = "��ɫ���� 4",
["Color Background"] = "��ɫ����",
["[R - Destiny]"] = "[R - ����]",
["Enable Minimap"] = "��С��ͼ��������ʾ",
["Draw Sprite Panel"] = "��ʾ�������",
["Draw Alerter Text"] = "��ʾ��������",
["Draw click hitbox"] = "��ʾ����������",
["Adjust width"] = "�������",
["Adjust height"] = "�����߶�",
["[Damage HP Bar]"] = "[Ѫ���˺���ʾ]",
["Draw damage info"] = "��ʾ�˺���Ϣ",
["Color Text"] = "������ɫ",
["Color Bar"] = "Ѫ����ɫ��ɫ",
["Color near Death"] = "�ӽ���������ɫ",
["None"] = "��",
["Pause Movement"] = "��ͣ�ƶ�",
["AutoCarry Mode"] = "�Զ��������ģʽ",
["Target Lock Current Target"] = "������ǰĿ��",
["Target Lock Selected Target"] = "����ѡ��Ŀ��",
["Method 2"] = "��ʽ2",
["Method 3"] = "��ʽ3",
["Color Kill"] = "���Ի�ɱ����ɫ",
["Calc x Auto Attacks"] = "����ƽA����",
["Lag-Free-Circles"] = "��Ӱ���ӳٵ���Ȧ",
["Disable all Draws"] = "�ر����е���ʾ",
["[Killsteal]"] = "[����ͷ]",
["Use Wild Cards"] = "ʹ��Q",
["[Misc]"] = "[��������]",
["[Rescue Pick]"] = "[����ѡ��]",
["time"] = "ʱ��",
["factor"] = "����",
["[Auto Q immobile]"] = "[�����ƶ�ʱ�Զ�Q]",
["Don't Q Lux"] = "��Ҫ������˿ʹ��Q",
["[Debug]"] = "[����]",
["Spell Data"] = "��������",
["Prediction / minion hit"] = "Ԥ�� / ����С��",
["TargetSelector Mode"] = "Ŀ��ѡ����ģʽ",
["LESS CAST"] = "����ʹ�ü���",
["LESS CAST PRIORITY"] = "����ʹ�ü���+���ȼ�",
["NEAR MOUSE"] = "��������",
["Priority"] = "���ȼ�",
["NearMouse"] = "����긽��",
["MOST AD"] = "AD���",
["MostAD"] = "AD���",
["MOST AP"] = "AP���",
["MostAP"] = "AP���",
["Damage Type"] = "�˺�����",
["MAGICAL"] = "ħ��",
["PHYSICAL"] = "����",
["Range"] = "��Χ",
["Draw for easy Setup"] = "�������õ���ʾģʽ",
["Draw target"] = "��ʾĿ��",
["Circle"] = "��Ȧ",
["ESP BOX"] = "ESP����",
["Blue"] = "��ɫ",
["Red"] = "��ɫ",
-----------------------��Ͳ����ޱ��-------------------------
["Tumble Machine Vayne"] = "��Ͳ���� VN",
["Enable Packet Features"] = "���÷��",
["Combo Settings"] = "��������",
["AA Reset Q Method"] = "Q������ͨ�ķ�ʽ",
["Forward and Back Arcs"] = "��ǰ�����Q",
["Everywhere"] = "�κ�λ��",
["Use gap-close Q"] = "ʹ��Q�ӽ�����",
["Use Q in Combo"] = "��������ʹ��Q",
["Use E in Combo"] = "��������ʹ��E",
["Use R in Combo"] = "��������ʹ��R",
["Ward bush loss of vision"] = "���˽���ʱ�Զ�����",
["Harass Settings"] = "ɧ������",
["Use Harass Mode during: "] = "ʹ��ɧ��ģʽ��",
["Harass Only"] = "ֻɧ��",
["Both Harass and Laneclear"] = "ɧ�ź�����",
["Forward Arc"] = "��ǰʱ",
["Side to Side"] = "�ӵ���һ�ൽ��һ��",
["Old Side Method"] = "�ɰ汾����",
["Use Q in Harass"] = "��ɧ����ʹ��Q",
["Use E in Harass"] = "��ɧ����ʹ��E",
["Spell Settings"] = "��������",
["Q Settings"] = "Q��������",
["Use AA reset Q"] = "ʹ��Q�����չ�",
["      ON"] = "��",
["ON: 3rd Proc"] = "�������չ�",
["Use gap-close Q - Burst Harass"] = "ʹ��Q�ӽ� - ����ɧ��ģʽ",
["E Settings"] = "E��������",
["Use E Finisher"] = "ʹ��E��ɱ",
["Don't E KS if # enemies near is >"] = "���������˴���xʱ��Ҫ��E����ͷ",
["Don't E KS if level is >"] = "���ȼ�����xʱ��Ҫ��E����ͷ",
["E KS if near death"] = "�������ʹ��E����ͷ",
["Calculate condemn-flash at:"] = "ʹ��E����",
["Mouse Flash Position"] = "�����λ��Ϊ����λ��",
["All Possible Flash Positions"] = "���п��ܵ�����λ��",
["R Settings"] = "R��������",
["Stay invis long as possible"] = "�����ܳ�ʱ��ı�������״̬",
["Stay invis min enemies"] = "��������״̬����С������",
["    Activate R"] = "�Զ�R",
["R min enemies to use"] = "ʹ��R����С������",
["Use R if Health% <="]	= "�������ֵС�ڵ���%",
["Use R if in danger"] = "��Σ�������ʹ��R",
["Use Q after R if danger"] = "��Σ�������ʹ��RQ����",
["Special Condemn Settings"] = "�����������",
["Anti-Gap Close Settings"] = "��ͻ������",
["Enable"] = "����",
["Interrupt Settings"] = "�������",
["Tower Insec Settings"] = "������Insec����",
["Make Key Toggle"] = "ʹ�ð�������",
["Max Enemy Minions (1)"] = "���з�С����",
["Max Range From Tower"] = "������������",
["Use On:"] = "ʹ�õĶ���",
["Target"] = "Ŀ��",
["Anyone"] = "�κ���",
["Frequency:"] = "ʹ��Ƶ��",
["More Often"] = "��Ƶ��",
["More Accurate"] = "����׼",
["Q and Flash Usage:"] = "Q�����ֵ�ʹ��",
["Q First"] = "��Q",
["Flash First"] = "������",
["Never Use Q"] = "�Ӳ�ʹ��Q",
["Never Use Flash"] = "�Ӳ�ʹ������",
["Wall Condemn Settings"] = "��ǽ����",
["Use on Lucian"] = "��¬����ʹ��",
["   If enemy health % <="] = "   �����������ֵС��<",
["Use wall condemn on"] = "ʹ�ö�ǽ�Ķ���",
["All listed"] = "�����б����Ŀ��",
["Use wall condemn during:"] = "���������ʹ�ö�ǽ",
["Combo and Harass"] = "���к�ɧ��",
["Always On"] = "����ʹ��",
["Wall condemn accuracy"] = "��ǽ��׼��",
["     Jungle Settings"] = "     ��Ұ����",
["Use Q-AA reset on:"] = "�������ʹ��Q�����չ�",
["All Jungle"] = "����Ұ��",
["Large Monsters Only"] = "ֻ�Ǵ���Ұ��",
["Wall Stun Large Monsters"] = "�Դ���Ұ��ʹ�ö�ǽ",
["Disable Wall Stun at Level"] = "�ڵȼ�xʱ���ö�ǽ",
["Jungle Clear Spells if Mana >"] = "�����������xʱ��ʹ����Ұ",
["     Lane Settings"] = "     ��������",
["Q Method:"] = "Qʹ�÷�ʽ",
["Lane Clear Q:"] = "������ʹ��Q",
["Dash to Mouse"] = "λ������귽��",
["Dash to Wall"] = "λ����ǽ",
["Lane Clear Spells if Mana >"] = "��������ʹ�ü��������������%",
["Humanize Clear Interval (Seconds)"] = "���˻����߼��(��)",
["Tower Farm Help (Experimental)"] = "���·�������(����)",
["Item Settings"] = "��Ʒ����",
["Offensive Items"] = "��������Ʒ",
["Use Items During"] = "���������ʹ��",
["Combo and Harass Modes"] = "���к�ɧ��ģʽ",
["If My Health % is Less Than"] = "�������ֵ����%",
["If Target Health % is Less Than"] = "���Ŀ������ֵ����%",
["QSS/Cleanse Settings"] = "ˮ��/��������",
["Remove CC during: "] = "��������������Ƽ���",
["Remove Exhaust"] = "��������",
["QSS Blitz Grab"] = "���������˵Ĺ�",
["Humanizer Delay (ms)"] = "���Ի��ӳ�(����)",
["Use HP Potions During"] = "�������ʹ��Ѫҩ",
["Use HP Pot If Health % <"] = "����ֵ����%ʹ��Ѫҩ",
["Damage Draw Settings"] = "�˺���ʾ����",
["Draw E DMG on bar:"] = "��Ѫ����ʾE���˺�",
["Ascending"] = "����",
["Descending"] = "�½�",
["Draw E Text:"] = "��ʾE������ʾ����",
["Percentage"] = "�ٷֱ�",
["Number"] = "����",
["AA Remaining"] = "��ɱʣ��ƽA��",
["Grey out health"] = "��ɫ�˺����",
["Disable All Range Draws"] = "�ر����з�Χ��ʾ",
["Draw Circle on Target"] = "��Ŀ������ʾ��Ȧ",
["Draw AA/E Range"] = "��ʾƽA/E��Χ",
["Draw My Hitbox"] = "��ʾ�Լ����������",
["Draw (Q) Range"] = "��ʾQ�ķ�Χ",
["Draw Passive Stacks"] = "��ʾ��������",
["Draw Ult Invis Timer"] = "��ʾ���������ʱ��",
["Draw Attacks"] = "��ʾ����",
["Draw Tower Insec"] = "��ʾ������Insec",
["While Key Pressed"] = "����������ʱ",
["Enable Streaming Mode (F7)"] = "��������ģʽ(F7)",
["General Settings"] = "��������",
["Auto Level Spells"] = "�Զ��ӵ�",
["Disable auto-level for first level"] = "��1��ʱ�ر��Զ��ӵ�",
["Level order"] = "�ӵ�˳��",
["First 4 Levels Order"] = "ǰ4���ӵ�˳��",
["Display alert messages"] = "��ʾ������Ϣ",
["Left Click Focus Target"] = "����������Ŀ��",
["Off"] = "�ر�",
["Permanent"] = "���õ�",
["For One Minute"] = "����һ����",
["Target Mode:"] = "Ŀ��ѡ��ģʽ:",
["Easiest to kill"] = "�����׻�ɱ",
["Less Cast Priority"] = "����ʹ�ü���+���ȼ�",
["Don't KS shield casters"] = "��Ҫ���л��ܼ��ܵ�Ŀ��ʹ������ͷ",
["Get to lane faster"] = "���߸���",
["Double Edge Sword Mastery?"] = "˫�н��츳",
["No"] = "��",
["Yes"] = "��",
["Turn on Debug"] = "�򿪵���ģʽ",
["Orbwalking Settings"] = "�߿�����",
["Keybindings"] = "��λ����",
["Escape Key"] = "���ܰ���",
["Burst Harass"] = "����ɧ������",
["Condemn on Next AA (Toggle)"] = "�´�ƽA�ƿ�Ŀ��(����)",
["Flash Condemn"] = "����E",
["Disable Wall Condemn (Toggle)"] = "�رն�ǽ(����)",
["   Use custom combat keys"] = "   ʹ��ϰ�ߵ�ս������",
["Click For Instructions"] = "���ָ��",
["Select Skin"] = "ѡ��Ƥ��",
["Original Skin"] = "����Ƥ��",
["Vindicator Vayne"] = "Ħ�Ǻ��� ޱ��",
["Aristocrat Vayne"] = "����ʹħŮ ޱ��",
["Heartseeker Vayne"] = "�������� ޱ��",
["Dragonslayer Vayne - Red"] = "������ʿ ޱ�� - ��ɫ",
["Dragonslayer Vayne - Green"] = "������ʿ ޱ�� - ��ɫ",
["Dragonslayer Vayne - Blue"] = "������ʿ ޱ�� - ��ɫ",
["Dragonslayer Vayne - Light Blue"] = "������ʿ ޱ�� - ǳ��ɫ",
["SKT T1 Vayne"] = "SKT T1 ޱ��",
["Arc Vayne"] = "���֮�� ޱ��",
["Snow Bard"] = "��ѩ���� �͵�",
["No Gap Close Enemy Spells Detected"] = "û�м�⵽���˵�ͻ������",
["Lucian Ult - Enable"] = "¬�������� - ����",
["     Humanizer Delay (ms)"] = "     ���˻��ӳ�(����)",
["Teleport - Enable"] = "���� - ����",
["Choose Free Orbwalker"] = "ѡ������߿�",
["Nebelwolfi's Orbwalker"] = "Nebelwolfi�߿�",
["Modes"] = "ģʽ",
["Attack"] = "����",
["Move"] = "�ƶ�",
["LastHit Mode"] = "β��ģʽ",
["Attack Enemy on Lasthit (Anti-Farm)"] = "����β��ʱ����(��ֹ���˷���)",
["LaneClear Mode"] = "����ģʽ",
["                    Mode Hotkeys"] = "                    ģʽ�ȼ�",
[" -> Parameter mode:"] = "-> ����ģʽ",
["On/Off"] = "��/��",
["KeyDown"] = "��ס����",
["KeyToggle"] = "���ذ���",
["                    Other Hotkeys"] = "                    �����ȼ�",
["Left-Click Action"] = "�������",
["Lane Freeze (F1)"] = "�������(F1)",
["Settings"] = "����",
["Sticky radius to mouse"] = "ֹͣ����������뾶",
["Low HP"] = "��Ѫ��",
["Most AP"] = "AP���",
["Most AD"] = "AD���",
["Less Cast"] = "����ʹ�ü���",
["Near Mouse"] = "��������",
["Low HP Priority"] = "��Ѫ��+���ȼ�",
["Dead"] = "������",
["Closest"] = "�����",
["Blade of the Ruined King"] = "�ư�����֮��",
["Bilgewater Cutlass"] = "�ȶ��������䵶",
["Hextech Gunblade"] = "����˹�Ƽ�ǹ��",
["Ravenous Hydra"] = "̰����ͷ��",
["Titanic Hydra"] = "���;�ͷ��",
["Tiamat"] = "��������",
["Entropy"] = "��˪ս��",
["Yomuu's Ghostblade"] = "����֮��",
["Farm Modes"] = "����ģʽ",
["Use Tiamat/Hydra to Lasthit"] = "ʹ����������/��ͷ��β��",
["Butcher"] = "����",
["Arcane Blade"] = "˫�н�",
["Havoc"] = "����",
["Advanced Tower farming (experimental"] = "�߼����·���ģʽ(����)",
["LaneClear method"] = "���߷�ʽ",
["Highest"] = "���Ч��",
["Stick to 1"] = "����һ��С��",
["Draw LastHit Indicator (LastHit Mode)"] = "��ʾβ��ָʾ��(β��ģʽ)",
["Always Draw LastHit Indicator"] = "������ʾβ��ָʾ��",
["Lasthit Indicator Style"] = "β��ָʾ����ʽ",
["New"] = "��",
["Old"] = "��",
["Show Lasthit Indicator if"] = "���������ʾβ��ָʾ��",
["1 AA-Kill"] = "һ��ƽA��ɱ",
["2 AA-Kill"] = "����ƽA��ɱ",
["3 AA-Kill"] = "����ƽA��ɱ",
["Own AA Circle"] = "�Լ���ƽA��Ȧ",
["Enemy AA Circles"] = "���˵�ƽA��Ȧ",
["Lag Free Circles"] = "��Ӱ���ӳٵ���Ȧ",
["Draw - General toggle"] = "��ʾ - ���濪��",
["Timing Settings"] = "��ʱ����",
["Cancel AA adjustment"] = "ȡ��ƽA��ҡ����",
["Lasthit adjustment"] = "β������",
["Version:"] = "�汾:",
["Combat keys are located in orbwalking settings"] = "ս���������߿�������",
-----------------------ʱ���������--------------
["Time Machine Ekko"] = "ʱ����� ����",
["Skin Changer"] = "Ƥ���л�",
["Sandstorm Ekko"] = "ʱ֮ɰ ����",
["Academy Ekko"] = "����ѧ�� ����",
["Use Q combo if  mana is above"] = "�����������xʹ��Q����",
["Use E combo if  mana is above"] = "�����������xʹ��E����",
["Use Q Correct Dash if mana >"] = "�����������xʹ��E��������Q�ķ���",
["Reveal enemy in bush"] = "�Բݴ���ĵ����Զ�����",
["Use Target W in Combo"] = "����������Ŀ���Ե�ʹ��W",
["W if it can hit X "] = "����ܻ���X������ʹ��R",
["Use Q harass if  mana is above"] = "�����������xʹ��Qɧ��",
["Harass Q last hit and hit enemy"] = "ɧ����ʹ��Q��β���Լ����е���",
["Auto-move to hit 2nd Q in Combo"] = "�Զ��ƶ���ʹ����Q����",
["On"] = "��",
["On and Draw"] = "�򿪲���ʾ",
["Long Range W Engage"] = "ս����ʹ��Զ����W",
["Long Range Before E Engage"] = "ս������E֮ǰʹ��Զ����W",
["During E Engage"] = "ս��ʹ��E��ʱ��",
["Use W on CC or slow"] = "ʹ��W������ƻ���Ⱥ�����",
["Don't use E in AA range unless KS"] = "������ƽA��Χ��ʱ��������ͷ��Ҫʹ��E",
["Offensive Ultimate Settings"] = "�����Դ�������",
["Ult Target in Combo if"] = "���������������ʹ�ô���",
["Target health % below"] = "Ŀ������ֵ����%",
["My health % below"] = "�Լ�����ֵ����%",
["Ult if 1 enemy is killable"] = "�����1�����˿ɻ�ɱʱʹ��R",
["Ult if 2 or more"] = "�����2���������˿ɻ�ɱʱʹ��R",
["will go below 35% health"] = "����Ѫ������35%��ʱ�򴥷�",
["Ult if set amount"] = "��������趨��ֵ��ʹ��R",
["will get hit"] = "�����յ�����",
["Offensive Ult During:"] = "�������ʹ�ý����Դ���",
["Combo Only"] = "ֻ��������ʹ��",
["Block ult in combo mode if ult won't hit"] = "������в��ܻ�������������ʹ�ô���",
["Defensive Ult/Zhonya Settings"] = "�����Դ���/��������",
["Use if about to die"] = "����ʱʹ��",
["Only Defensive Ult if my"] = "��������������..��ʹ�÷����Դ���",
["health is less than targets"] = "����ֵ����Ŀ������ֵ",
["Ult if heal % is >"] = "������������ֵ����%ʱʹ��R",
["Defensive Ult During:"] = "�������ʹ�÷����Դ��У�",
["Wave Clear Settings"] = "��������",
["Use Q in Wave Clear"] = "ʹ��Q����",
["Scenario 1:"] = "���� 1��",
["Minimum lane minions to hit "] = "���ٻ��е�С����",
["Use Q if  mana is above"] = "�����������xʱʹ��Q",
["Must hit enemy also"] = "����ͬʱ���е���",
["Scenario 2:"] = "���� 2��",
["---Jungle---"] = "---��Ұ����---",
["Use W in Jungle Clear"] = "ʹ��W��Ұ",
["Use E in Jungle Clear"] = "ʹ��E��Ұ",
["Escape Settings"] = "��������",
["Cast W direction you are heading"] = "�����泯�ķ���ʹ��W",
["Draw (W) Max Reachable Range"] = "��ʾ�ܵ����W���Χ",
["Draw (E) Range"] = "��ʾE���ܷ�Χ",
["Draw (R) Range"] = "��ʾR���ܷ�Χ",
["Draw Line to R Spot"] = "��R�ĵص㻭ָʾ��",
["Draw Passive Stack Counters"] = "��ʾ��������ָʾ��",
["Display ult hit count"] = "��ʾ�����ܻ��еĵ�����",
["Draw Tower Ranges"] = "��ʾ��������Χ",
["Damage Drawings"] = "��ʾ�˺�",
["Enable Bar Drawings"] = "����Ѫ���˺���ʾ",
["Separated"] = "�����",
["Combined"] = "һ���",
["Draw Bar Letters"] = "��Ѫ������ʾ������ĸ",
["Draw Bar Shadows"] = "��ʾѪ����Ӱ",
["Draw Bar Kill Text"] = "��ʾѪ����ɱ��ʾ",
["Draw (Q) Damage"] = "��ʾQ���˺�",
["Draw (E) Damage"] = "��ʾE���˺�",
["Draw (R) Damage"] = "��ʾR���˺�",
["Draw (I) Ignite Damage"] = "��ʾI(��ȼ)���˺�",
["Q Helper"] = "Q��������",
["Enable Q  Helper"] = "����Q��������",
["Draw Box"] = "��ʾ����",
["Draw Minion Circles"] = "��С������ʾ��Ȧ",
["Draw Enemy Circles"] = "�ڵ�������ʾ��Ȧ",
["Item/Smite Settings"] = "��Ʒ/�ͽ�����",
["Offensive Smite"] = "�����Գͽ�",
["Use Champion Smite During"] = "�����������Ӣ��ʹ�óͽ�",
["Combo and Lane Clear"] = "���к�����",
["Use Smart Ignite"] = "ʹ�����ܵ�ȼ",
["Optimal"] = "���ʱ��",
["Aggressive"] = "�����Ե�",
["Prediction Method:"] = "Ԥ�з�ʽ:",
["Divine Prediction"] = "��ʥԤ��",
["Make sure these are on unique keys"] = "ȷ�����°����Ƕ�����",
["Wave Clear Key"] = "���߰���",
["Jungle KS Key"] = "��Ұ/����ͷ����",
["Use on ShenE"] = "������Eʹ��",
["      Enable"] = "      ����",
["      Health % < "] = "      ����ֵ����%",
------------------------RaphlolŮǹС��--------------
["Ralphlol: Miss Fortune"] = "Raphlol:Ůǹ",
["Use W if  mana is above"] = "��������xʱʹ��W",
["Use E if  mana is above"] = "��������xʱʹ��E",
["Use Q bounce in Combo"] = "��������ʹ��Q�������",
["Use W in Combo"] = "��������ʹ��W",
["Use E more often in Combo"] = "�������и�Ƶ����ʹ��E",
["(Q) to Minions"] = "QС��",
["Ignore High Health Tanks"] = "���Ը�Ѫ����̹��/���",
["Only (Q) minions that will die"] = "ֻ����Q����С��ʹ��Q",
["Use Harass also during Lane Clear"] = "�����ߵ�ʱ����Ȼɧ�Ŷ���",
["Use Q bounce in Harass"] = "��ɧ����ʹ��Q����",
["Use W in Harass"] = "��ɧ����ʹ��W",
["Ultimate Settings"] = "��������",
["Auto Ult During"] = "�������ʹ���Զ�����",
["Use Ult if X enemy hit"] = "����ܻ���x������ʹ���Զ�����",
["Use Ult if target will die"] = "���Ŀ���ܻ�ɱʱʹ���Զ�����",
["Use on stunned targets"] = "�Ա�ѣ�ε�Ŀ��ʹ��",
["Only AutoUlt if CC Nearby <="]= "��������Ŀ���С�ڵ���Xʹ���Զ�����",
["Cancel Ult if no more enemies inside"] = "���R��Χ��û�е�����ȡ������",
["Cancel Ult when you right click"] = "�������Ҽ���ʱ��ȡ������",
["Block Ult cast if it will miss"] = "������д��еĻ������δ����ͷ�",
["(Shift Override)"] = "(����Shift)",
["Clear Settings"] = "��������",
["Jungle Clear Settings"] = "��Ұ����",
["Use Q in Jungle Clear"] = "����Ұ��ʹ��Q",
["Show notifications"] = "��ʾ��ʾ��Ϣ",
["Show CC Counter"] = "��ʾ���Ƽ��ܼ���",
["Show Q Bounce Counter"] = "��ʾQ�������",
["Draw (Q) Arcs"] = "��ʾQ����ķ�Χ",
["Draw (Q) Killable Minions"] = "��ʾQ�ܻ�ɱ��С��",
["(R) Damage Drawing"] = "��ʾR���˺�",
["Minimum Duration"] = "��С����ʱ��",
["Full Duration"] = "������ʱ��",
["Assisted (E) Key"] = "����E����",
["Assisted (R) Key"] = "����R����",
["Ralphlol: Tristana"] = "Raphlol:С��",
["E Harass White List"] = "Eɧ�ŵ����б�",
["Use on Brand"] = "�Բ�����ʹ��",
["Enable Danger Ultimate"] = "����Σ��ʱ�Զ�����",
["Use on self"] = "���Լ�ʹ��",
["Anti-Gap Settings"] = "��ͻ������",
["Draw AA/R/E Range"] = "��ʾƽA/R/E�ķ�Χ",
["Draw (W) Range"] = "��ʾW��Χ",
["Draw (W) Spot"] = "��ʾW����ص�",
["All-In Key "] = "ȫ���������",
["Assisted (W) Key"] = "����W����",
["(E) Wave Key"] = "E���߰���",
["Panic Ult Key"] = "�������а���",
-------------��ս���е��ϼ�---------------
["SimpleLib - Orbwalk Manager"] = "SimpleLib - �߿�������",
["Orbwalker Selection"] = "�߿�ѡ��",
["SxOrbWalk"] = "Sx�߿�",
["Big Fat Walk"] = "�����߿�",
["Forbidden Ezreal by Da Vinci"] = "��ս���е��ϼ� - �������",
["SimpleLib - Spell Manager"] = "SimpleLib - ���ܹ�����",
["Enable Packets"] = "ʹ�÷��",
["Enable No-Face Exploit"] = "ʹ�ÿ�����ģʽ",
["Disable All Draws"] = "�ر�������ʾ",
["Set All Skillshots to: "] = "�����м��ܵ�Ԥ�е���Ϊ��",
["HPrediction"] = "HԤ��",
["DivinePred"] = "��ʥԤ��",
["SPrediction"] = "SԤ��",
["Q Settings"] = "Q��������",
["Prediction Selection"] = "Ԥ��ѡ��",
["X % Combo Accuracy"] = "���о�׼��X%",
["X % Harass Accuracy"] = "ɧ�ž�׼��X%",
["80 % ~ Super High Accuracy"] = "80% ~ ���߾�׼��",
["60 % ~ High Accuracy (Recommended)"] = "60% ~ �߾�׼��(�Ƽ�)",
["30 % ~ Medium Accuracy"] = "30% ~ �о�׼��",
["10 % ~ Low Accuracy"] = "10% ~ �;�׼��",
["Drawing Settings"] = "��ͼ����",
["Enable"] = "��Ч",
["Color"] = "��ɫ",
["Width"] = "���",
["Quality"] = "����",
["W Settings"] = "W��������",
["E Settings"] = "E��������",
["R Settings"] = "R��������",
["Ezreal - Target Selector Settings"] = "[�������] - Ŀ��ѡ��������",
["Shen"] = "��",
["Draw circle on Target"] = "��Ŀ���ϻ�Ȧ",
["Draw circle for Range"] = "��Ȧ��Χ",
["Ezreal - General Settings"] = "[�������] - ��������",
["Overkill % for Dmg Predict.."] = "�˺�����ж�X%",
["Ezreal - Combo Settings"] = "[�������] - ��������",
["Use Q"] = "ʹ��Q",
["Use W"] = "ʹ��W",
["Use R If Enemies >="]	= "��������������ڵ���",
["Ezreal - Harass Settings"] = "[�������] - ɧ������",
["Min. Mana Percent: "] = "��С�����ٷֱȣ�",
["Ezreal - LaneClear Settings"] = "[�������] - ��������",
["Ezreal - LastHit Settings"] = "[�������] - β������",
["Smart"] = "����",
["Min. Mana Percent:"] = "��С��������",
["Ezreal - JungleClear Settings"] = "[�������] - ��Ұ����",
["Ezreal - KillSteal Settings"] = "[�������] - ����ͷ����",
["Use E"] = "ʹ��E",
["Use R"] = "ʹ��R",
["Use Ignite"] = "ʹ�õ�ȼ",
["Ezreal - Auto Settings"] = "[�������] - �Զ�����",
["Use E To Evade"] = "ʹ��E���ܶ��",
["Shen (Q)"] = "����Q",
["Shen (W)"] = "����W",
["Shen (E)"] = "����E",
["Shen (R)"] = "����R",
["Time Limit to Evade"] = "���ʱ������",
["% of Humanizer"] = "���˻��̶�X%",
["Ezreal - Keys Settings"] = "[�������] - ��������",
["Use main keys from your Orbwalker"] = "ʹ������߿���������",
["Harass (Toggle)"] = "ɧ�ſ���",
["Assisted Ultimate (Near Mouse)"] = "��������(����긽��)",
[" -> Parameter mode:"] = " -> ����ģʽ",
["On/Off"] = "��/��",
["KeyDown"] = "����",
["KeyToggle"] = "��������",
["BioZed Reborn by Da Vinci"] = "��ս���е��ϼ� - ��",
["Zed - Target Selector Settings"] = "[��] - Ŀ��ѡ��������",
["Darius"] = "������˹",
["Zed - General Settings"] = "[��] - ��������",
["Developer Mode"] = "������ģʽ",
["Zed - Combo Settings"] = "[��] - ��������",
["Use W on Combo without R"] = "��ʹ��Rʱʹ��W",
["Use W on Combo with R"] = "ʹ��Rʱʹ��W",
["Swap to W/R to gap close"] = "ʹ�ö���W/R�ӽ�����",
["Swap to W/R if my HP % <="] = "�������ֵС�ڵ���X%ʱʹ�ö���W/R",
["Swap to W/R if target dead"] = "ʹ�ö���W/R���Ŀ������",
["Use Items"] = "ʹ����Ʒ",
["If Killable"] = "�����ɱ��",
["R Mode"] = "Rģʽ",
["Line"] = "ֱ��ģʽ",
["Triangle"] = "����ģʽ",
["MousePos"] = "���λ��",
["Don't use R On"] = "��Ҫ��..ʹ��R",
["Zed - Harass Settings"] = "[��] - ɧ������",
["Check collision before casting q"] = "��ʹ��Q֮ǰ�����ײ",
["Min. Energy Percent"] = "��С�����ٷֱ�",
["Zed - LaneClear Settings"] = "[��] - ��������",
["Use Q If Hit >= "]	=	 "����ܻ��е�С��>=Xʹ��Q",
["Use W If Hit >= "]	=	 "����ܻ��е�С��>=Xʹ��W",
["Use E If Hit >= "]	=	 "����ܻ��е�С��>=Xʹ��E",
["Min. Energy Percent: "] = "��С�����ٷֱȣ�",
["Zed - JungleClear Settings"] = "[��] - ��Ұ����",
["Zed - LastHit Settings"] = "[��] - β������",
["Zed - KillSteal Settings"] = "[��] - ����ͷ����",
["Zed - Auto Settings"] = "[��] - �Զ�����",
["Use Auto Q"] = "ʹ���Զ�Q",
["Use Auto E"] = "ʹ���Զ�E",
["Use R To Evade"] = "ʹ��R���",
["Darius (Q)"] = "������˹Q",
["Darius (W)"] = "������˹W",
["Darius (E)"] = "������˹E",
["Darius (R)"] = "������˹R",
["Use R1 to Evade"] = "ʹ��һ��R���",
["Use R2 to Evade"] = "ʹ�ö���R���",
["Use W To Evade"] = "ʹ��W���",
["Use W1 to Evade"] = "ʹ��һ��W���",
["Use W2 to Evade"] = "ʹ�ö���W���",
["Zed - Drawing Settings"] = "[��] - ��ʾ����",
["Damage Calculation Bar"] = "Ѫ���˺�����",
["Text when Passive Ready"] = "����������ʱ��ʾ����",
["Circle For W Shadow"] = "WӰ����Ȧ",
["Circle For R Shadow"] = "RӰ����Ȧ",
["Text on Shadows (W or R)"] = "��W��R��Ӱ������ʾ����",
["Zed - Key Settings"] = "[��] - ��������",
["Combo with R (RWEQ)"] = "ʹ��R������(RWEQ)",
["Combo without R (WEQ)"] = "��ʹ��R������(WEQ)",
["Harass (QWE or QE)"] = "ɧ��(QWE����QE)",
["Harass (QWE)"] = "ɧ��(QWE)",
["WQE (ON) or QE (OFF) Harass"] = "WQE(��)��QE(��)ɧ��",
["LaneClear or JungleClear"] = "���߻���Ұ",
["Run"] = "����",
["Switcher for Combo Mode"] = "����ģʽ�л���",
["Don't cast spells before R"] = "��R�����ͷ�֮ǰ��Ҫ�ͷż���",
["Forbidden Syndra by Da Vinci"] = "��ս���е��ϼ� - ������",
["QE Settings"] = "QE��������",
["Syndra - Target Selector Settings"] = "[������] - Ŀ��ѡ��������",
["Syndra - General Settings"] = "[������] - ��������",
["Less QE Range"] = "QE����С��Χ",
["Dont use R on"] = "��Ҫ������Ŀ��ʹ��R",
["QE Width"] = "QE���п��",
["Syndra - Combo Settings"] = "[������] - ��������",
["Use QE"] = "ʹ��QE",
["Use WE"] = "ʹ��WE",
["If Needed"] = "�����Ҫ�Ļ�",
["Use Zhonyas if HP % <="]= "�������ֵС��%ʹ������",
["Cooldown on spells for r needed"] = "R��Ҫ����ȴʱ��",
["Syndra - Harass Settings"] = "[������] - ɧ������",
["Use Q if enemy can't move"] = "���˲����ƶ���ʱ��ʹ��Q",
["Don't harass under turret"] = "��Ҫɧ�������µ�Ŀ��",
["Syndra - LaneClear Settings"] = "[������] - ��������",
["Syndra - JungleClear Settings"] = "[������] - ��Ұ����",
["Syndra - LastHit Settings"] = "[������] - β������",
["Syndra - KillSteal Settings"] = "[������] - ����ͷ����",
["Syndra - Auto Settings"] = " [������] - �Զ�����",
["Use QE/WE To Interrupt Channelings"] = "ʹ��QE/WE�������������",
["Time Limit to Interrupt"] = "��ϼ��ܵ�ʱ������",
["Use QE/WE To Interrupt GapClosers"] = "ʹ��QE/WE����ϵ��˵�ͻ��",
["Syndra - Drawing Settings"] = "[������] - ��ʾ����",
["E Lines"] = "E����ָʾ��",
["Text if Killable with R"] = "�������R��ɱ��ʾ��ɱ��ʾ",
["Circle On W Object"] = "��Wץȡ��Ŀ���ϻ�Ȧ",
["Syndra - Keys Settings"] = "[������] - ��������",
["Cast QE/WE Near Mouse"] = "����긽��ʹ��QE/WE",
["Ralphlol Kindred"] = "Ralphlol:ǧ��",
["Use Q gap-close "] = "ʹ��Q�ӽ�����",
["In Combat Q Dash Method"] = "��ս����Qλ�Ƶķ�ʽ",
["Enable Ultimate"] = "���ô���",
["Use W in Wave Clear"] = "��������ʹ��W",
["Also use champ Smite"] = "�Զ�ʹ�óͽ�",
["Draw W Duration"] = "��ʾW����ʱ��",
["Draw R Duration"] = "��ʾR����ʱ��",
["Assisted Ultimate Key"] = "�������а���",
["Malphite"] = "ī����",
["Keybindings are in the Orbwalking Settings menu"] = "�����������߿����ò˵���",
["Ralphlol's Utility Suite"] = "Ralphlol�Ĺ����׼�",
["Missed CS Counter"] = "©��������",
["X Position"] = "X��λ��",
["Y Position"] = "Y��λ��",
["Text Size"] = "���ִ�С",
["Jungler"] = "��Ұ",
["Draw Enemy Waypoints"] = "��ʾ���˵��н�·��",
["Draw Incoming Enemies"] = "��ʾ�����ϵ��ĵ���",
["Countdowns"] = " ����ʱ",
["Ward Bush/ Pink Invis"] = "�Զ�������/���͸��췴��",
["Key Activation"] = "�ȼ�",
["Max Time to check missing Enemy"] = "��������ʧ�����ʱ��",
["Draw Minions"] = "��ʾС��",
["Recall Positions"] = "�سǵص�",
["Print Messages"] = "��ʾ��Ϣ",
---------------������ʶ---------------
["Big Fat Gosu"] = "���Ӻϼ�",
["Load Big Fat Mark IV"] = "����������ʶ",
["Load Big Fat Evade"] = "�������Ӷ��",
["Sorry, this champion isnt supported yet =("] = "�Բ���,��֧�����Ӣ��",
["Big Fat Gosu v. 3.61"] = "���Ӻϼ�v. 3.61",
["Big Fat Hev - Mark IV"] = "������ʶ",
["[Voice Settings]"] = "[��������]",
["Volume"] = "����",
["Welcome"] = "��ӭ",
["Danger!"] = "Σ��",
["Shutdown"] = "�ս�",
["SummonerSpells"] = "�ٻ�ʦ����",
["WinLose sounds"] = "ʤ��/ʧ��",
["Kill Announcer"] = "��ɱ����",
["Shrooms Announcement"] = "��Ģ������",
["Smite Announcement"] = "�ͽ䲥��",
["JungleTimers Announcement"] = "��Ұ��ʱ����",
["[Incoming Enemys to Track]"] = "[���Ӽ��������ĵ���]",
["ON/OFF"] = "��/��",
["Stop track inc. enemys after x min"] = "x���Ӻ�ֹͣ���ӵ���",
["Allow this option"] = "�����������",
["Scan Range"] = "ɨ�跶Χ",
["Draw minimap"] = "С��ͼ��ʾ",
["Use Danger Sprite"] = "ʹ��Σ�ձ�־",
["Show waypoints"] = "��ʾ�н�·��",
["Enable Voice System"] = "��������ϵͳ",
["Jax"] = "�ֿ�˹",
["[CD Tracker]"] = "[��ȴ��ʱ��]",
["Use CD Tracker"] = "ʹ����ȴ��ʱ��",
["[Wards to Track]"] = "[��λ����]",
["Use Wards Tracker"] = "ʹ����λ����",
["Use Sprites"] = "ʹ��ͼƬ",
["Use Circles"] = "ʹ����Ȧ",
["Use Text"] = "ʹ������",
["[Recall Tracker]"] = "[�سǼ���]",
["Use Recall Tracker"] = "ʹ�ûسǼ���",
["Hud X"] = "HUD X��λ��",
["Hud Y"] = "HUD Y��λ��",
["Print Finished and Cancelled Recalls"] = "��ʾ��ɵĻسǺ�ȡ���Ļس�",
["[BaseUlt]"] = "[���ش���]",
["Use BaseUlt"] = "ʹ�û��ش���",
["Print BaseUlt alert in chat"] = "�����������ʾ���ش�����ʾ",
["Draw BaseUlt Hud"] = "��ʾ���ش���HUD",
["[Team BaseUlt Friends]"] = "[��ʾ���ѵĻ��ش���]",
["[Tower Range]"] = "[��������Χ]",
["Use Tower Ranges"] = "��ʾ��������Χ",
["Show only close"] = "ֻ�ڽӽ�������ʱ��ʾ",
["Show ally turrets"] = "��ʾ�Ѿ���������Χ",
["Show turret view"] = "��ʾ��������Ұ",
["Circle Quality"] = "��Ȧ����",
["Circle Width"] = "��Ȧ���",
["[Jungle Timers]"] = "[��Ұ��ʱ]",
["Jungle Disrespect Tracker(FOW)"] = "����ҰҰ������",
["Sounds for Drake and Baron"] = "����С����ʾ��",
["(DEV) try to detect more"] = "(������)���Լ�������Ϣ",
["Enable Jungle Timers!!! Finally ^^"] = "���,���ô�Ұ��ʱ",
["[Enemies Hud]"] = "[������ϢHUD]",
["Enable enemies hud"] = "���õ�����ϢHUD",
["Hud Style"] = "HUD���",
["Classic(small)"] = "����(С)",
["Circle(medium)"] = "Բ��(��)",
["Circle(big)"] = "Բ��(��)",
["LowFps(Mendeleev)"] = "��fps",
["RitoStyle"] = "Rito���",
["Hud Mode"] = "HUDģʽ",
["Vertical"] = " ��ֱ��",
["Horizontal"] = "ˮƽ��",
["HudX and HudY dont work for Old one"] = "HUD XY��λ�ò���Ծ�������Ч",
["[Thresh Lantern]"] = "[��ʯ�ĵ���]",
["Use Nearest Lantern"] = "������ĵ���",
["Auto Use if HP < %"] = "�������ֵС��%�Զ�ʹ��",
["[Anti CC]"] = "[������]",
["Enable AntiCC"] = "���÷�����",
["[BuffTypes]"] = "[��������]",
["Disarm"] = "��е",
["ForcedAction"] = "ǿ�ƶ���(����/�Ȼ�)",
["Suppression"] = "ѹ��",
["Suspension"] = "����",
["Slow"] = "����",
["Blind"] = "��ä",
["Stun"] = "ѣ��",
["Root"] = "����",
["Silence"] = "��Ĭ",
["Enable Mikael for teammates"] = "���öԶ���ʹ������",
["[TeamMates for Mikael]"] = "[�Զ���ʹ������]",
["It will use Cleanse, Dervish Blade,"] = "����ʹ�þ���,����ɮ֮��",
["Quicksilver Sash, Mercurial Scimitar"] = "ˮ���δ�,ˮ���䵶",
[" or Mikael's Crucible."] = "�����׿���������",
["Suppressions by Malzahar, Skarner, Urgot,"] = "����������,˹����,����ص�ѹ��",
["Warwick could be only removed by QSS"] = "���˵�ѹ��ֻ��ˮ���ܽ�",
["[Misc]"] = "[����]",
["Draw Exp Circle"] = "��ʾ�����÷�Χ",
["Extra Awareness"] = "������ʶ",
["Heal Cd's on Aram"] = "�ڴ��Ҷ�ģʽ��ʾ����cd",
["LordsDecree Cooldown"] = "���������ķ�����ȴʱ��",
["Big Fat Hev - Mark IV v. 4.001"] = "������ʶ v. 4.001",
----------------���˽�ʥ��ħ���-----------------
["Khazix Fun House 2.0"] = "���˺ϼ�2.0 - ���ȿ�",
["Auto Harass Toggle"] = "�Զ�ɧ�ſ���",
["Prioritize Isolated"] = "������Ԯ��Ŀ������",
["Back Flip Q Cast mid-jump"] = "����˺���Ծ�Ŀ���ʹ��Q ",
["--- Jump Logic ---"] = "--- ��Ծ�߼� ---",
["Save E in combo for KS"] = "����������E����ͷ",
["E engage if target very isolated"] = "���Ŀ�������Ԯ����ʹ��E",
["Double Jump Enabled"] = "��ɱʱʹ��������Ծ",
["DbJump to max range intead of target"] = "������Ծ������Զ�����������Ŀ��",
["Auto DoubleJump offensive self hp"] = "�Զ�������Ծ����������ֵ",
["Auto DoubleJump def. enemy no"] = "�Զ�������Ծ�ĵ�������",
["Auto DoubleJump delay"] = "�Զ�������Ծ�ӳ�",
["Other Double Jump Positions"] = "������Ծ�ĵص�",
["SmartAuto"] = "�����Զ�ģʽ",
["Mouse"] = "���λ��",
["Ally"] = "�Ѿ�λ��",
["Enemy"] = "����λ��",
["Cast target killable with passive damage"] = "���ϱ������˺��ܹ���ɱʱʹ��",
["Use Taste Their Fear (Q)"] = "ʹ��Ʒ���־�(Q)",
["Use Leap (E)"] = "ʹ��Ծ��(E)",
["Use Void Spike (W)"] = "ʹ�����ͻ��(W)",
["Draw Invis Time"] = "��ʾ����ʱ��",
["Cast Ignite on Sivir"] = "��ϣά��ʹ�õ�ȼ",
["E2 Hit Chance"] = "����E���еĻ���",
["Trundle Fun House"] = "���˺ϼ� - ���ʵ¶�",
["Force R Key (current target)"] = "ǿ��ʹ��R����(�Ե�ǰĿ��)",
["--- Mana Settings ---"] = "--- �������� ---",
["Minimum % Mana to use (W)"] = "ʹ��W����С����",
["Use E as anti enemy gap closers"] = "ʹ��E��ͻ��",
["Use E as spell interruptor"] = "ʹ��E��ϵ��˵ļ���",
["Use R on combo"] = "��������ʹ��R",
["--- R Triggers ---"] = "--- R�������� ---",
["Minimum % HP to use (R)"] = "ʹ��R����С����ֵ%",
["R priority Mode"] = "R���ȼ�ģʽ",
["Defensive"] = "������",
["Selected Enemy"] = "ѡ���ĵ���",
["Use Chomp (Q)"] = "ʹ������˺ҧ(Q)",
["Use Frozen Domain (W)"] = "ʹ�ñ�������(W)",
["Enable ks mode with R"] = "ʹ��R����ͷ",
["Enable Spells Draws"] = "���ü�����Ȧ��ʾ",
["-- Extra E draw options --"] = "--- E���ܶ�����ʾ���� ---",
["Draw E predicted position "] = "��ʾE����Ԥ��λ��",
["^ E hold: draw E | E twice: cast E"] = "��סE:��ʾEλ��|E����:ʹ��E",
["Master Yi Fun House 2.0"] = "���˺ϼ�2.0 - ��",
["Master Yi Fun House"] = "���˺ϼ� - ��",
["Forced Q Key"] = "ǿ��ʹ��Q����",
["Use Q always (not recommended)"] = "����ʹ��Q(���Ƽ�)",
["Use Q if: Q + 3x AA = kill enemy"]= "���Q+3��ƽA�ܹ���ɱʱʹ��Q",
["Use Q for avoid hard CC"] = "ʹ��Q���Ӳ�ؼ���",
["Use Q for follow enemy dashes"] = "ʹ��Q�������˵�λ��",
["Use Q under X hp"] = "����ֵ����xʹ��Q",
["Self hp % "] = "��������ֵ%",
["Auto use Q for kill steal"] = "�Զ�ʹ��Q����ͷ",
["Use W as life saver vs turret shots"] = "ʹ��W���ٷ������˺�",
["Use W if Q CD for lower big damage"] = "���ܵ��ɶ��˺���QCDʱʹ��W",
["Use W as AA reset"] = "ʹ��W�����չ�",
["Only if killable"] = "�����ܻ�ɱʱ",
["Use E on combo"] = "��������ʹ��E",
["Auto R usage if we are slowed/exhausted"] = "������/����ʱ�Զ�ʹ��R",
["LaneClear Alpha Strike (Q)"] = "��������ʹ��Q",
["LaneClear Wuju Style (E)"] = "��������ʹ��E",
["Jungle Alpha Strike (Q)"] = "����Ұ��ʹ��Q",
["Jungle Wuju Style (E)"] = "����Ұ��ʹ��E",
["Cast Ignite on Malzahar"] = "���������ʹ�õ�ȼ",
-------------------Ů��ADC�ϼ�--------------
["AmberCarries - Kalista"] = "Ů��ADC�ϼ� - ����˹��",
["[Kalista] - Combo Settings (SBTW)"] = "[����˹��] - ��������",
["Combo Key"] = "���а���",
["Use (Q) in combo"] = "��������ʹ��Q",
["OrbWalk Minion if no Target"] = "���û��Ŀ���A��",
["[Kalista] - Harass Settings"] = "[����˹��] - ɧ������",
["Harass Key"] = "ɧ�Ű���",
["Use (Q) in Harass"] = "��ɧ����ʹ��Q",
["Use (E) in Harass"] = "��ɧ����ʹ��E",
["[Kalista] - KillSteal Settings"] = "[����˹��] - ����ͷ����",
["Use KillSteal"] = "����ͷ",
["[Kalista] - Balista Settings"] = "[����˹��] - ����Q���ͷŴ�������",
["Use Balista"] = "ʹ�ô�����",
["Min Range to Blitz for Balista"] = "ʹ�ô����е�������",
["[Kalista] - Spells Settings"] = "[����˹��] - ��������",
["(W) Settings"] = "W��������",
["Auto (W) - Bush revealer"] = "�Զ�ʹ��W̽�ݴ�",
["Max Range"] = "������",
["(E) Settings"] = "E��������",
["Auto (E) if Unit Executable"] = "�ڵ�λ��E����ʱ��ʹ��E",
["Auto (E) Minion for Slow Unit"] = "E�������ٵ�λ",
["Only if unit not in AA Range"] = "�����治�����ƽA��Χʱ����E",
["Force Use if Closest Unit"] = "�����������Ŀ��ǿ��ʹ��E",
["(R) Settings"] = "R��������",
["Auto (R)"] = "�Զ�R",
["If ally HP < X %"] = "�����Լ��λ����ֵС��X%",
["[Kalista] - Jungle Steal Settings"] = "[����˹��] - ��Ұ������",
["Auto (E) Jungle Minion Executable"] = "��E��Ұ��ʱ�Զ�E",
["Execute Golem "] = "E����",
["Execute Wolve "] = "E����",
["Execute Ghost "] = "E����",
["Execute Gromp "] = "E���",
["Execute Red Buff "] = "E��buff",
["Execute Blue Buff "] = "E��buff",
["Execute Crab"] = "E�з",
["Execute Drake"] = "EС��",
["Execute Nashor "] = "E����",
["[Kalista] - Last Hit Helper Settings"] = "[����˹��] - β����������",
["Auto (E) Minion Executable"] = "��E��С��ʱ�Զ�E",
["if X minion Executable"] = "�����X��С����E��",
["[Kalista] - Message Settings "] = "[����˹��] - ��Ϣ����",
["Print Blitzcrank Shield"] = "��ʾ�����˵Ķ�",
["Print When Exhausted"] = "��ʾ����",
["Delay between each Message"] = "������Ϣ֮����ӳ�",
["[Kalista] - Misc Settings "] = "[����˹��] - ��������",
["(E) Dmg Offset (+/- per stacks)"] = "E�˺��������(����/����)",
["[Kalista] -  Item Settings"] = "[����˹��] - ��Ʒ����",
["Use Bilgewater Cutlass"] = "ʹ�ñȶ��������䵶",
["Use BORTK"] = "ʹ���ư�����֮��",
["Use Youmus"] = "ʹ������֮��",
["Use Quicksilver Sash"] = "ʹ��ˮ���δ�",
["Use Mercurial Scimitar"] = "ʹ��ˮ���䵶",
["Humanizer Delay (ms)"] = "���˻��ӳ�(����)",
["Bush Revealer - Trinket ( blue/green)"] = "�Զ�̽�ݴ�(��Ʒ)",
["[Kalista] -  Auto Buy Settings"] = "[����˹��] - �Զ���װ��",
["Auto Buy Startup Item"] = "�Զ������װ",
["Doran's Blade"] = "������",
["Health Potion"] = "Ѫƿ",
["Blue Trinket"] = "��ɫ��Ʒ",
["Green Trinket"] = "��ɫ��Ʒ",
["[Kalista] - Draw Settings "] = "[����˹��] - ��ͼ����",
["Draw (Q) Range"] = "����Q��Χ",
["Draw (E) Range"] = "����E��Χ",
["Draw (R) Range"] = "����R��Χ",
["Draw Sprite on Target"] = "��Ŀ�����ϻ����",
["Draw (E) Damage"] = "��ʾE���˺�",
["Draw Minion/Jungle Executable"] = "��ʾ��E����С��",
["Draw Damage Jungle Minion"] = "��ʾE��Ұ�ֵ��˺�",
["[Kalista] - OrbWalk Settings (SBTW)"] = "[����˹��] - �߿�����",
["General-Settings"] = "��������",
["Orbwalker Enabled"] = "�߿���Ч����",
["Stop Move when Mouse above Hero"] = "��Ӣ���������ʱֹͣ",
["Range to Stop Move"] = "ֹͣ�ƶ�������",
["Focus Selected Target"] = "����ѡ�е�Ŀ��",
["ExtraDelay against Cancel AA"] = "ƽA�Ķ����ӳ�",
["Spam Attack on Target"] = "�����ܶ�Ĺ���Ŀ��",
["Orbwalker Modus: "] = "�߿�ģʽ",
["To Mouse"] = "������ƶ�",
["To Target"] = "��Ŀ���ƶ�",
["Humanizer-Settings"] = "���˻�����",
["Limit Move-Commands per Second"] = "����ÿ�뷢�͵��ƶ�ָ��",
["Max Move-Commands per Second"] = "ÿ�뷢������ƶ�ָ��",
["Key-Settings"] = "��������",
["FightMode"] = "ս��ģʽ",
["HarassMode"] = "ɧ��ģʽ",
["LaneClear"] = "����",
["LastHit"] = "β��",
["Toggle-Settings"] = "��ʾ����״̬����",
["Make FightMode as Toggle"] = "��ʾս��ģʽ����",
["Make HarassMode as Toggle"] = "��ʾɧ��ģʽ����",
["Make LaneClear as Toggle"] = "��ʾ���߿���",
["Make LastHit as Toggle"] = "��ʾβ������",
["Farm-Settings"] = "ˢ������",
["Focus Farm over Harass"] = "ɧ��ʱ���в���",
["Extra-Delay to LastHit"] = "β���Ķ����ӳ�",
["Mastery-Settings"] = "�츳����",
["Mastery: Butcher"] = "����",
["Mastery: Arcane Blade"] = "˫�н�",
["Mastery: Havoc"] = " ����",
["Mastery: Devastating Strikes"] = "������",
["Draw-Settings"] = "��ʾ����",
["Draw Own AA Range"] = "�����Լ���ƽA��Χ",
["Draw Enemy AA Range"] = "�������˵�ƽA��Χ",
["Draw LastHit-Cirlce around Minions"] = "����β����Ȧ",
["Draw LastHit-Line on Minions"] = "����β��ָʾ��",
["Draw Box around MinionHpBar"] = "��С����Ѫ���ϻ���",
["Color-Settings"] = "��ɫ����",
["Color Own AA Range: "] = "�Լ�ƽA��Ȧ��ɫ",
["white"] = "��ɫ",
["blue"] = "��ɫ",
["red"] = "��ɫ",
["black"] = "��ɫ",
["green"] = "��ɫ",
["orange"] = "��ɫ",
["Color Enemy AA Range (out of Range): "] = "���˵�ƽA��Χ��ɫ(��Χ֮��)",
["Color Enemy AA Range (in Range): "] = "���˵�ƽA��Χ��ɫ(��Χ֮��)",
["Color LastHit MinionCirlce: "] = "β����Ȧ��ɫ",
["Color LastHit MinionLine: "] = "β��ָʾ����ɫ",
["ColorBox: Minion is LasthitAble: "] = "��С������β��ʱ����ɫ",
["none"] = "��",
["ColorBox: Wait with LastHit: "] = "��С���ȴ���β��ʱ����ɫ",
["ColorBox: Can Attack Minion: "] = "���Թ�����С����ɫ",
["TargetSelector"] = "Ŀ��ѡ����",
["Priority Settings"] = "���ȼ�����",
["Focus Selected Target: "] = "����ѡ����Ŀ��",
["never"] = "�Ӳ�",
["when in AA-Range"] = "��ƽA��Χʱ",
["Always"] = "����",
["TargetSelector Mode: "] = "Ŀ��ѡ����ģʽ",
["LowHP"] = "���Ѫ��",
["LowHPPriority"] = "���Ѫ��+���ȼ�",
["LessCast"] = "ʹ�ü�������",
["LessCastPriority"] = "ʹ�ü�������+���ȼ�",
["nearest myHero"] = "�����Ӣ��",
["nearest Mouse"] = "��������",
["RawPriority"] = "���ȼ�",
["Lucian"] = "¬����",
["Highest Priority (ADC) is Number 1!"] = "������ȼ�Ϊ1",
["Debug-Settings"] = "��������",
["Draw Circle around own Minions"] = "�ڼ���С���ϻ�Ȧ",
["Draw Circle around enemy Minions"] = "�ڵط�С���ϻ�Ȧ",
["Draw Circle around jungle Minions"] = "��Ұ���ϻ�Ȧ",
["Draw Line for MinionAttacks"] = "��С��Ѫ���ϻ�ƽAָʾ��",
["Log Funcs"] = "��־����",
["Cast (W) Exploit ( Ward Drake )"] = "��W��С������Ұ",
["Cast (W) Exploit ( Ward Nashor )"] = "��W����������Ұ",
["Target Selector"] = "Ŀ��ѡ����",
["Target Selector Mode:"] = "Ŀ��ѡ��ģʽ",
["Low HP"] = "���Ѫ��",
["Most AP"] = "AP���",
["Most AD"] = "AD���",
["Less Cast"] = "����ʹ�ü�������",
["Near Mouse"] = "��������",
["Priority"] = "���ȼ�",
["Low HP Priority"] = "���Ѫ��+���ȼ�",
["Less Cast Priority"] = "����ʹ�ü���+���ȼ�",
["Dead"] = "������",
["Closest"] = "���",


["AmberCarries - Quinn"] = "Ů��ADC�ϼ� - ����",
["[Quinn] - Combo Settings (SBTW)"] = "[����] - ��������",
["Use (Q1) in combo"] = "��������ʹ��Q-����ǰ",
["Use (Q2) in combo"] = "��������ʹ��Q-�����",
["Use (E1) in combo"] = "��������ʹ��E-����ǰ",
["Use (E2) in combo"] = "��������ʹ��E-�����",
["Use (R1) in combo"] = "��������ʹ��R-����ǰ",
["Use (R2) in combo"] = "��������ʹ��R-�����",
["[Quinn] - Harass Settings"] = "[����] - ɧ������",
["Use (Q1) in Harass"] = "��ɧ����ʹ��Q-����ǰ",
["Use (E1) in Harass"] = "��ɧ����ʹ��E-����ǰ",
["[Quinn] - Jungle Clear"] = "[����] - ��Ұ����",
["Jungle Clear Key"] = "��Ұ����",
["Use (Q1) in Jungle Clear"] = "����Ұ��ʹ��Q-����ǰ",
["Use (E1) in Jungle Clear"] = "����Ұ��ʹ��E-����ǰ",
["[Quinn] - Spell Settings"] = "[����] - ��������",
["(E1) Settings"] = "E-����ǰ����",
["Use (E1) for:"] = "��..ʹ��E-����ǰ",
["Range"] = "��Χ",
["Damage"] = "�˺�",
["Never Cast if Unit got Passive"] = "���Ŀ�������б����Ͳ������ͷ�",
["Auto (W) when enemy go in bush "] = "�����˽���ʱ�Զ�W����Ұ",
["(R1) Settings"] = "R-����ǰ ����",
["Use (R1) if Target life < %"] = "��Ŀ������ֵС��X%ʱʹ��R-����ǰ",
["Maximum Enemi in Range: "] = "�ڷ�Χ����������",
["Range: "] = "��Χ",
["Never Cast if my health < %"] = "����Լ�����ֵС��X%",
["(E2) Settings"] = "E-����� ����",
["Use (E2) for:"] = "��Ŀ��ʹ��E-�����",
["Engage"] = "ս��",
["(R2) Settings"] = "R-���������",
["For kill Target"] = "Ϊ��ɱ��Ŀ��",
["If no enemi in Range"] = "�����Χ��û��Ŀ��",
["[Quinn] - Tower Dive Settings"] = "[����] - Խ������",
["Only if Ally is under tower"] = "�����Ѿ�������ʱ",
["Force use if enemy HP < % "] = "���з�����ֵС��X%ǿ��ʹ��",
["Use (E1) for Tower Dive"] = "ʹ��E-����ǰԽ��",
["Use (R) for Tower Dive"] = "ʹ��RԽ��",
["[Quinn] - KillSteal Settings"] = "[����] - ����ͷ����",
["Use (Q1) in KillSteal"] = "ʹ��Q-����ǰ����ͷ",
["Use (Q2) in KillSteal"] = "ʹ��Q-���������ͷ",
["Use (R2) in KillSteal"] = "ʹ��R-���������ͷ",
["[Quinn] - Passive Settings"] = "[����] - ��������",
["Force Proc Passive"] = "ǿ�ƴ�������",
["[Quinn] - Wall Jump Settings"] = "[����] - ��ǽ����",
["Wall Jump Key"] = "��ǽ����",
["[Quinn] - Gap Closer Settings"] = "[����] - ��ͻ������",
["JarvanIV - Spell: JarvanIVDragonStrike"] = "���� - Q����",
["JarvanIV - Spell: JarvanIVCataclysm"] = "���� - E����",
["[Quinn] - Interupte Spell Settings"] = "[����] - ��ϼ�������",
["[Quinn] - Draw Settings "] = "[����] - ��ʾ����",
["Draw (Q1) Range"] = "��ʾQ-����ǰ��Χ",
["Draw (W) Range"] = "��ʾW��Χ",
["Draw (Q2) Range"] = "��ʾQ-�����Χ",
["Draw (E2) Range"] = "��ʾE-�����Χ",
["Draw (R2) Range"] = "��ʾR-�����Χ",
["Draw Ulti Time Remaining"] = "��ʾ���е���ʱ",
["Draw R2 Damage"] = "��ʾR-�������˺�",
["[Quinn] -  Item Settings"] = "[����] - ��Ʒ����",
["[Quinn] -  Auto Buy Settings"] = "[����] - �Զ���������",
["[Quinn] - OrbWalk Settings (SBTW)"] = "[����] - �߿�����",
["AmberCarries - Kog'Maw"] = "Ů��ADC�ϼ� - ����",
["[KogMaw] - Combo Settings (SBTW)"] = "[����] - ��������",
["Choose your Role"] = "ѡ�����λ��",
["ADC"] = "ADC",
["AP MID"] = "AP�е�",
["Use (Q)"] = "ʹ��Q",
["Use (W)"] = "ʹ��W",
["Use (E)"] = "ʹ��E",
["Use (R)"] = "ʹ��R",
["[KogMaw] - Harass Settings"] = "[����] - ɧ������",
["[KogMaw] - KillSteal Settings"] = "[����] - ����ͷ����",
["[KogMaw] - Misc Settings"] = "[����] - ��������",
["Use Auto Passive"] = "�Զ�ʹ�ñ���",
["[KogMaw] - Spells Settings"] = "[����] - ��������",
["[KogMaw] - (Q) Spells"] = "[����] - Q����",
["(Q) Max Range"] = "Q������",
["(Q) Min Range"] = "Q��С����",
["[KogMaw] - (W) Spells"] = "[����] - W����",
[" 0  Only use if Target out of range"] = "0 - �����ֲ��ڹ�����Χ",
[" 1  Use for Increase Damage"] = "1 - ���Դ�������",
["Choose your (W) type"] = "ѡ����W���ܵ�ģʽ",
["[KogMaw] - (E) Spells"] = "[����] - E����",
["(E) Max Range"] = "E������",
["(E) Min Range"] = "E��С����",
["Only Use If Closest Enemy"] = "ֻ������ĵ���ʹ��",
["Max Range: "] = "�����룺 ",
["[KogMaw] - (R) Spells"] = "[����] - R����",
["Maximum Stack"] = "���R������",
["Use if Mana > X %"] = "����������X%",
["[KogMaw] -  Item Settings"] = "[����] - ��Ʒ����",
["[KogMaw] -  Auto Buy Settings"] = "[����] - �Զ���������",
["Doran's Ring"] = "������",
["[KogMaw] - Draw Settings"] = "[����] - ��ʾ����",
["[KogMaw] - Prediction Settings"] = "[����] - Ԥ������",
["0  VPred | 1  DP"] = "0 - VPԤ��|1 - ��ʥԤ��",
["-> DivinePred have a better prediction"] = "->��ʥԤ��Ч������",
["Make sure you got it before"] = "�л���ʥԤ��ǰȷ�����Ѿ�ӵ��",
["[KogMaw] - Orbwalking Settings"] = "[����] - �߿�����",
["AmberCarries - Draven"] = "Ů��ADC�ϼ� - ������",
["[Draven] - Combo Settings"] = "[������] - ��������",
["Use (W) in combo"] = "��������ʹ��W",
["Use (E) in combo"] = "��������ʹ��E",
["Use (R) in combo"] = "��������ʹ��R",
["[Draven] - Harass Settings"] = "[������] - ɧ������",
["Use (W) in harass"] = "��ɧ����ʹ��W",
["[Draven] - Lane Clear Settings"] = "[������] - ��������",
["Lane Clear Key"] = "���߰���",
["Use (Q) in lane clear"] = "��������ʹ��Q",
["How Many Axe:"] = "��ͷ������",
["[Draven] - Last Hit Settings"] = "[������] - β������",
["Last Hit Key"] = "β������",
["[Draven] - Spells Settings"] = "[������] - ��������",
["[Draven] - (Q) Spells Settings"] = "[������] - Q��������",
["Auto Catch Axe: "] = "�Զ���ͷ",
["ToMouse"] = "�����λ��",
["ToHero"] = "��Ӣ��λ��",
["Dont"] = "��Ҫ��ͷ",
["Range Area:"] = "��Χ",
["If ToHero Choose"] = "�����Ӣ��λ��ѡ��",
["Auto Catch Axes (ToHero)"] = "�Զ���ͷ(��Ӣ��λ��)",
["Block if unit killable"] = "Ŀ��ɻ�ɱʱ���Զ��Ӹ�ͷ",
["With x AutoAttack:"] = "X��ƽA��",
["[Draven] - (W) Spells Settings"] = "[������] - W��������",
["Use (W) for reach Axe: "] = "ʹ��Wȥ�Ӹ�ͷ",
["IfNeed"] = "�����Ҫ",
["AllTime"] = "����",
["Use (W) If closest Unit"] = "�����ͻ��ʱʹ��W",
["Use (W) if Unit not in range"] = "���Ŀ�겻��ƽA��Χ��",
["[Draven] - (E) Spells Settings"] = "[������] - E��������",
["Min Range:"] = "��С��Χ",
["Mana > X%"] = "��������X%",
["[Draven] - (R) Spells Settings"] = "[������] - R��������",
["[Draven] - Gap Closer Settings"] = "[������] - ��ͻ������",
["[Draven] - Interupte Spell Settings"] = "[������] - ��ϼ���",
["[Draven] -  Item Settings"] = "[������] - ��Ʒ����",
["[Draven] -  Auto Buy Settings"] = "[������] - �Զ�������Ʒ",
["[Draven] - Draw Settings"] = "[������] - ��ʾ����",
["Draw (Q) Area"] = "��ʾQ������",
["Draw Axe"] = "��ʾ��ͷλ��",
["[Draven] - OrbWalk Settings"] = "[������] - �߿�����",
["Sivir"] = "������",
["AmberCarries - Twitch"] = "Ů��ADC�ϼ� -ͼ��",
["[Twitch] - Combo Settings (SBTW)"] = "[ͼ��] - ��������",
["[Twitch] - Harass Settings (SBTW)"] = "[ͼ��] - ɧ������",
["Use (E) if X stacks"] = "����X�㱻��ʱʹ��E",
["Harass if mana > X%"] = "����������X%ʱɧ��",
["[Twitch] - Spells Settings"] = "[ͼ��] - ��������",
["[Twitch] - (Q) Settings"] = "[ͼ��] - Q����",
["Min Range to enemy"] = "����˵���С����",
["Max Range to enemy"] = "����˵�������",
["If stealth block (W)"] = "������ʱ���ͷ�W",
["If stealth block (R)"] = "������ʱ���ͷ�R",
["[Twitch] - (W) Settings"] = "[ͼ��] - W��������",
["Use (W) for:"] = "W�����ͷţ�",
["When X stacks"] = "����X�㱻��",
["IF When X Stacks Need Picked"] = "����X�㱻����Ҫ��ѡ��",
["Stack Number"] = "��������",
["Auto use if X enemy hitable"] = "��X��Ŀ��ɱ��ͷ�ʱ",
["Numbers enemy"] = "��������",
["If my Mana > X% "] = "�����������X%",
["HitChance"] = "���еĿ�����",
["[Twitch] - (E) Settings"] = "[ͼ��] - E��������",
["Use (E) for:"] = "E�����ͷţ�",
["For Execute"] = "���Ի�ɱ����ʱ",
["When 6 Stacks"] = "6�㱻��ʱ",
["If For execute Picked"] = "���ѡ��ĵ��˿��Ի�ɱ",
["Use if X enemi executable"] = "���X�����˿��Ի�ɱ",
["Unit Executable Without Ultimate: "] = "��λ���Բ��ô��л�ɱ",
["Unit Executable Under Ultimate: "] = "��λ�����ô��л�ɱ",
["If When 6 Stacks Picked"] = "���ѡ��ĵ�����6�㱻��",
["When X enemy got 6 stacks"] = "��X��������6�㱻��",
["Force Execute if unit killable"] = "���Ŀ����Ա���ɱǿ���ͷ�",
["Keep Mana For (E)"] = "����E���ܵ�����",
["[Twitch] - (R) Settings"] = "[ͼ��] - R��������",
["Use (R) if X enemy in range"] = "���X�������ڷ�Χ��ʹ��R",
["Enemy Max Range: "] = "����������",
["Use (R) if X ally in range"] = "���X���Ѿ��ڷ�Χ��",
["Ally Max Range: "] = "�Ѿ�������",
["[Twitch] - Tower Dive Settings"] = "[ͼ��] - Խ������",
["Use (R) for dive"] = "Խ��ʱʹ��R",
["Only if (E) Ready"] = "ֻ��E���ܺ�ʱ",
["Target life < X% hp"] = "��Ŀ������ֵС��X%",
["[Twitch] -  Item Settings"] = "��Ʒ����",
["[Twitch] -  Auto Buy Settings"] = "�Զ���������",
["[Twitch] - Draw Settings"] = "��ʾ����",
["Draw Stealth State"] = "��ʾ����״̬",
["Draw Ulti Time left"] = "��ʾR����ʣ��ʱ��",
["[Twitch] - Jungle Steal Settings"] = "[ͼ��] - ��Ұ������",
["[Twitch] - OrbWalk Settings (SBTW)"] = "[ͼ��] - �߿�����",
["AmberCarries - Lucian"] = "Ů��ADC�ϼ� - ¬����",
["[Lucian] - Combo Settings"] = "[¬����] - ��������",
["Combo Order "] = "����˳��",
["No Order"] = "����",
["[Lucian] - Harass Settings"] = "[¬����] - ɧ������",
["Mana > X%:"] = "��������X%",
["[Lucian] - LaneClear Settings"] = "[¬����] - ��������",
["LaneClear Key"] = "���߰���",
["[Lucian] - Spells Settings"] = "��������",
["(Q) Settings"] = "Q��������",
["Use on Minion for hit Target"] = "�����Դ�С�����е���ʱ",
["Use if unit out range"] = "��Ŀ���ڷ�Χ��ʱ",
["~ AND ~"] = "~ & ~",
["Unit Health < X%:"] = "Ŀ��Ѫ��С��X%",
["AutoMove"] = "�Զ��ƶ�",
["Use Only if ComboKey Press"] = "�������а�������ʱ",
["Use E if needed"] = "�����Ҫ��ʱ��ʹ��E",
["[Lucian] -  Item Settings"] = "[¬����] - ��Ʒ����",
["[Lucian] -  Auto Buy Settings"] = "[¬����] - �Զ���������",
["[Lucian] - Gap Closer Settings"] = "[¬����] - ��ͻ������",
["[Lucian] - Draw Settings"] = "[¬����] - ��ʾ����",
["Draw (E) CD"] = "��ʾE����CD",
["[Lucian] - OrbWalk Settings"] = "[¬����] - �߿�����",
["Zyra"] = "���",
["AmberCarries - Vayne"] = "Ů��ADC�ϼ� - ޱ��",
["[Vayne] - Combo Settings (SBTW)"] = "[ޱ��] - ��������",
["[Vayne] - Wall Tumble Settings"] = "[ޱ��] - ��ǽ����",
["Wall Tumble Key"] = "��ǽ����",
["[Vayne] - Harass Settings"] = "[ޱ��] - ɧ������",
["[Vayne] - Lane Clear Settings"] = "[ޱ��] - ��������",
["If my mana > X%"] = "�����������X%",
["[Vayne] - Spell Settings"] = "[ޱ��] - ��������",
["Use (Q) for:"] = "ʹ��Q���ԣ�",
["Reset AA CD"] = "�����չ�",
["When Castable"] = "������ʱ",
["Proc W + Reset AA CD"] = "����W + �����չ�",
["Use (Q) for Kite"] = "��Q�����ݵ���",
["Max Range to Enemy for Kite"] = "���ݵ��˵�������",
["Force (Q) if unit not in AA Range"] = "���Ŀ�겻���չ���Χǿ��Q",
["Stun"] = "ѣ��",
["Reset AA & Stun"] = "�����չ� + ѣ��",
["Stun Chance"] = "ѣ�εĻ���",
["Auto Stun"] = "�Զ�ѣ��Ŀ��",
["Max Wall Range For Stunt"] = "ѣ��ʱ��ǽ��������",
["Use (R) if:"] = "�������ʹ��R",
["Target life < %"] = "Ŀ������С��X%",
["My life > %"] = "�Լ�����ֵ����X%",
["Minimum Enemi in Range: "] = "�ڷ�Χ��������X������",
["Minimum Ally in Range: "] = "�ڷ�Χ��������X���Ѿ�",
["Keep Invisibily"] = "��������״̬",
["Only if closest enemy"] = "�����Լ���ͻ��",
["[Vayne] - Tower Dive Settings"] = "[ޱ��] - Խ������",
["Use (Q) for Tower Dive"] = "��Q������Խ��",
["[Vayne] - KillSteal Settings"] = "[ޱ��] - ����ͷ����",
["Use (E) in KillSteal"] = "��E������ͷ",
["[Vayne] - Gap Closer Settings"] = "[ޱ��] - ��ͻ������",
["[Vayne] - Interupte Spell Settings"] = "[ޱ��] - ��ϼ���",
["[Vayne] -  Item Settings"] = "[ޱ��] - ��Ʒ����",
["[Vayne] -  Auto Buy Settings"] = "[ޱ��] - �Զ�������Ʒ",
["[Vayne] - Draw Settings "] = "��ʾ����",
["Draw (Q) type: "] = "��ʾQ������",
["Draw (E) Predict on unit"] = "��ʾE���ܵ�Ԥ��",
["Draw Damage"] = "��ʾ�˺�",
["Draw WallTumble Circle"] = "��ʾ��ǽ��ԲȦ",
["[Vayne] - OrbWalk Settings (SBTW)"] = "[ޱ��] - �߿�����",
["No enemy heroes were found!"] = "û�з��ֵ���",
--------------------��������--------------------------
["Leblanc's Skillshots Settings"] = "��ܽ�����ܵ�������",
["[eSkillShot] Spell Settings"] = "[E���ܵ�������]",
["Override Minimum Hit % "] = "������С������",
["Overriden Minumum Hit %"] = "�����ǵ���С������",
["Prediction Cooldown (ms)"] = "Ԥ����ȴʱ��(ms)",
["[wSkillShot] Spell Settings"] = "[W���ܵ�������]",
["Totally LeBlanc - Totally Legit"] = "��������",
["Totally LeBlanc  -  Key Settings"] = "�������� - ��������",
["Combo GapClose Key"] = "ͻ�����а���",
["Combo Chain Key"] = "��Ӱ�������а���",
["Farm Key"] = "��������",
["Totally LeBlanc  -  Combo"] = "�������� - ����",
["Ethereal Chains (E)"] = "��Ӱ����(E)",
["Max range:"] = "���Χ",
["Min width:"] = "��С���",
["Draw range"] = "��ʾ���ܷ�Χ",
["Perform Combo:"] = "ʹ�õ�����",
["Use AAs"] = "ʹ��ƽA",
["Use W to GapClose"] = "ʹ��W�ӽ�Ŀ��",
["Force ADC/APC"] = "ǿ�ƹ���ADC/APC",
["Totally LeBlanc  -  Settings: W"] = "�������� - W��������",
["Use Optional W Settings"] = "ʹ���Զ���W��������",
["Return: "] = "����: ",
["Target dead"] = "Ŀ������",
["Skills used"] = "��������",
["Both"] = "��������",
["Totally LeBlanc  -  Harass"] = "�������� - ɧ��",
["Use Sigil of Malice (Q)"] = "ʹ�ö���ħӡ(Q)",
["Use Distortion (W)"] = "ʹ��ħӰ����(W)",
["Use Ethereal Chains (E)"] = "ʹ�û�Ӱ����(E)",
["Mana Manager %"] = "��������%",
["Totally LeBlanc  -  Farming"] = "�������� - ����",
["Minions outside AA range only"] = "ֻ����ƽA�������С��ʹ��",
["Farm if AA is on CD"] = "��ƽA�ļ�϶ʹ�ü��ܷ���",
["Totally LeBlanc  -  Laneclear"] = "�������� - ����",
["Use Mimic (R)"] = "ʹ�ùʼ���ʩ(R)",
["Min minions to WR"] = "ʹ��WR������С����",
["Min minions to W and WR"] = "ʹ��W��WR������С����",
["Totally LeBlanc  -  KillSteal"] = "�������� - ����ͷ",
["Excecute"] = "",
["Not in Combo"] = "����������ʹ��",
["No other mode active"] = "����ģʽδ����ʱ",
["GapClose to kill enemy"] = "ͻ���Ի�ɱ����",
["Gapclose > Q + R"] = "ͻ��������Q+R",
["KillSteal Enemy"] = "ʹ������ͷ�Ķ���",
["Totally LeBlanc  -  Drawings"] = "�������� - ��ʾ",
["Lag-Free Circles"] = "��Ӱ���ӳٵ���Ȧ",
["Use Lag-Free Circles"] = "ʹ�ò�Ӱ���ӳٵ���Ȧ",
["Length before Snapping"] = "",
["Use Drawings"] = "������ʾ",
["Draw Sigil of Malice (Q)"] = "��ʾ����ħӡ(Q)",
["Draw Distortion (W)"] = "��ʾħӰ����(W)",
["Draw Ethereal Chains (E)"] = "��ʾ��Ӱ����(E)",
["Draw Killable Text"] = "��ʾ�ɻ�ɱ��ʾ",
["Draw Killable Width"] = "��ʾ��ɱ��ʾ�Ŀ��",
["Don't draw if spell is CD"] = "����cdʱ����ʾ��Ȧ",
["Totally LeBlanc  -  Prediction"] = "�������� - Ԥ��",
["Prediction Type:"] = "Ԥ������",
["VPrediction HitChance"] = "VԤ�е�������",
["DivinePred HitChance"] = "��ʥԤ�е�������",
["Totally LeBlanc  -  Misc"] = "�������� - ����",
["Auto Level"] = "�Զ��ӵ�",
["Use Auto Level"] = "ʹ���Զ��ӵ�",
["What to max?"] = "�ĸ�������������",
["Use Summoner Ignite"] = "ʹ�õ�ȼ",
["Zhyonas"] = "����",
["Use Zhonyas under % health"] = "����ֵ����%ʱʹ������",
["Auto Ignite Potion"] = "�Զ���ȼѪƿ",
["Drink Health Pot when Ignited"] = "����ȼʱ�Զ���Ѫƿ",
["Totally LeBlanc  -  OrbWalker"] = "�������� - �߿�",
["Totally LeBlanc  -  TargetSelector Modes"] = "�������� - Ŀ��ѡ����ģʽ",
["License"] = "���",
["Patch: "] = "�汾",
["Farm"] = "����",
------------------������ͼ------------------
["--------- LANGUAGE --------"] = "--------- ����ѡ�� ---------",
["Language"] = "����",
["English"] = "Ӣ��",
["German"] = "����",
["Portuguese"] = "��������",
["Spanish"] = "��������",
["French"] = "����",
["Italian"] = "�������",
["Turkish"] = "��������",
["Polski"] = "������",
["------ Quick Toggles ------"] = "------ ��ݿ��� ------",
["Hidden Objects"] = "���εĵ�λ",
["Aggro targets"] = "��޵�Ŀ��",
["Side HUD"] = "HUD��ʾ",
["Waypoints"] = "�н�·��",
["Minimap SS"] = "С��ͼ��ʧ��ʾ",
["Clone revealer"] = "����̽����",
["Clone Revealer"] = "����̽����",
["Recall Alert"] = "�س���ʾ",
["Tower Ranges"] = "��������Χ",
["Minimap Timers"] = "С��ͼ��ʱ��",
["Lasthit Helper"] = "β������",
["Notification System"] = "����ϵͳ",
["Spell Timer Drawings"] = "���ܼ�ʱ����ʾ",
["Other drawings"] = "������ʾ",
["Sounds"] = "����",
["Use sprites on minimap"] = "��С��ͼ��ʾͼƬ",
["Draw enemy team wards"] = "��ʾ������λ",
["Draw enemy team traps"] = "��ʾ���˵�����",
["Draw own team wards"] = "��ʾ������λ",
["Draw own team traps"] = "��ʾ��������",
["Draw type"] = "��ʾ��ʽ",
["Circular"] = "Բ�ε�",
["Precise"] = "��ȷ��",
["Circles quality"] = "��Ȧ����",
["Add Custom Ward Key"] = "���ϰ������λ����",
["Remove Custom Ward Key"] = "�Ƴ�ϰ������λ����",
["Key to hold to draw range"] = "��ס��ʾ��Χ����",
["Key to toggle draw range"] = "������ʾ��Χ����",
["Expiring wards"] = "������ʧ����λ",
["Change expiring wards color"] = "�޸ļ�����ʧ����λ����ɫ",
["Expiring wards color"] = "������ʧ����λ����ɫ",
["Change color below (seconds)"] = "����λʱ��С��x��ʱ�ı���ɫ",
["Custom Wards"] = "ϰ������λ",
["Enemy Sight Wards"] = "���˵ļ���",
["Enemy Vision Wards"] = "���˵�����",
["Enemy Traps"] = "���˵�����",
["Ally Sight Wards"] = "�Ѿ��ļ���",
["Ally Vision Wards"] = "�Ѿ�������",
["Ally Traps"] = "�Ѿ�������",
["Circles and lines"] = "��Ȧ������",
["Lines"] = "ָʾ��",
["Width of lines and circles"] = "��Ȧ�������Ŀ��",
["Quality of circle"] = "��Ȧ������",
["Side enemy HUD"] = "��ߵ���HUD��ʾ",
["HUD horizontal position"] = "HUDˮƽλ��",
["HUD vertical position"] = "HUD��ֱλ��",
["Summ cds"] = "�ٻ�ʦ����cd",
["Seconds"] = "��",
["Game time"] = "��Ϸʱ��",
["Scale"] = "����",
["Cooldowns Tracker"] = "��ȴʱ���ʱ",
["Show enemy QWER cooldowns"] = "��ʾ����QWER��ȴ",
["Classic"] = "����",
["Classic R"] = "���� R",
["Show enemy summoner cooldowns"] = "��ʾ�����ٻ�ʦ������ȴ",
["Show ally QWER cooldowns"] = "��ʾ�Ѿ�QWER��ȴ",
["Show ally summoner cooldowns"] = "��ʾ�Ѿ��ٻ�ʦ������ȴ",
["Show my QWER cooldowns"] = "��ʾ�Լ�QWER��ȴ",
["Show my summoner cooldowns"] = "��ʾ�Լ����ٻ�ʦ������ȴ",
["Cooldown"] = "��ȴʱ��",
["No mana to cast"] = "û���ż���",
["No energy to cast"] = "û�����ż���",
["No valid targets"] = "û�п���Ŀ��",
["CD spell/text"] = "����CD����",
["Unknown"] = "δ֪",
["Draw paths also on minimap"] = "��С��ͼ��ʾ·��",
["Draw enemy path"] = "��ʾ�о�·��",
["Draw enemy path time"] = "��ʾ�о�·��ʱ��",
["Draw ally path"] = "��ʾ�Ѿ�·��",
["Draw ally path time"] = "��ʾ�Ѿ�·��ʱ��",
["Cross type"] = "ʮ�ֽ�������",
["Light"] = "������",
["Ally cross color"] = "�Ѿ�ʮ�ֽ�����ɫ",
["Enemy cross color"] = "�о�ʮ�ֽ�����ɫ",
["Ally lines color"] = "�Ѿ�ָʾ����ɫ",
["Enemy lines color"] = "����ָʾ����ɫ",
["Cross size (only Normal type)"] = " ",
["Cross width (only Normal type)"] = " ",
["Show missing timer"] = "��ʾ��ʧ�ļ�ʱ��",
["Show grey icon"] = "��ʾ��ɫͼ��",
["Draw timer after (seconds)"] = "x�����ʾ��ʱ��",
["Text color for SS timer"] = "��ʧ��Ұ��ʱ��������ɫ",
["Autoping SS (bol broken)"] = "��ʧ��Ұ�Զ����(bol������)",
["Auto SS enabled"] = "������Ұ��ʧ����",
["Autoping SS after (seconds)"] = "��ʧ��Ұx����Զ����",
["Clone-able player circle color"] = "�з���ĵ�����Ȧ��ɫ",
["Circle quality"] = "��Ȧ����",
["Mark all enemy heroes"] = "������ез�Ӣ��",
["Draw recall sprite on minimap"] = "��С��ͼ����ʾ�س�ͼƬ",
["Recall Bar color"] = "�سǶ�������ɫ",
["Recall Bar background color"] = "�سǶ����ı�����ɫ",
["Teleport Bar color"] = "���Ͷ�������ɫ",
["Teleport Bar background color"] = "���Ͷ����ı�����ɫ",
["Color chat messages"] = "��Ϣ����Ϣ��ɫ",
["Print recall cancel"] = "��ʾ�س�ȡ��",
["Print teleport cancel"] = "��ʾ����ȡ��",
["Min distance to draw range"] = "��ʾ��Χ��Ȧ����С����",
["Quality of towers ranges"] = "��������Χ��Ȧ������",
["Width of towers ranges"] = "��������Χ��Ȧ�Ŀ��",
["Draw own team towers ranges"] = "��ʾ������������Χ",
["Own towers range color"] = "������������Χ��ɫ",
["Draw enemy towers ranges"] = "��ʾ�з���������Χ",
["Enemy towers ranges color"] = "�з���������Χ��ɫ",
["Enemy towers ranges color (danger)"] = "�з���������Χ(Σ��)",
["Enemy towers ranges color (aggro)"] = "�з���������Χ(������)",
["Jungle Camps timers"] = "��Ұ��ʱ",
["Jungle Camps text size"] = "��Ұ��ʱ���ִ�С",
["Jungle Camps text color"] = "��Ұ��ʱ������ɫ",
["(bol broken) Ping when big monsters respawns"] = "����Ұ�ָ���ʱ���(bol������)",
["Only me"] = "ֻ���Լ�",
["My team"] = "��������",
["Jungle camps to draw"] = "��ʾ��Ұ��Ӫ��",
["Wight"] = "������",
["Red and Blue"] = "����buff",
["Razorbeaks"] = "�����",
["Murkwolves"] = "��Ӱ��",
["Crabs"] = "�з",
["Inhibitors timers"] = "ˮ����ʱ��",
["Towers health (%)"] = "����������ֵ(�ٷֱ���ʾ)",
["Towers health (numeric)"] = "����������ֵ(��ֵ��ʾ)",
["Inhibs/Tower Hp text size"] = "ˮ��/����������ֵ���ִ�С",
["Inhibs/Tower Hp text color"] = "ˮ��/����������ֵ������ɫ",
["Horizontal offset"] = "ˮƽԤ��",
["Vertical offset"] = "��ֱԤ��",
["Distance from player to draw helper"] = "��ʾ��������ʱ����ҵľ���",
["Healthbar color of killable minion"] = "�ɱ���ɱ��С��Ѫ����ɫ",
["Type of drawing for last hittable minions"] = "�ɱ�β����С��Ѫ����ʾ��ʽ",
["Mark Healthbar"] = "���Ѫ��",
["Draw circle"] = "��ʾ��Ȧ",
["Force enabling"] = "ǿ����Ч",
["Max notifies at the same time"] = "ͬʱ��ʾ�����������Ŀ��",
["Duration of notifies"] = "���ѵĳ���ʱ��",
["Color of notifies"] = "���ѵ�������ɫ",
["---- Events to show ----"] = "---- �¼���ʾ ----",
["An enemy disconnects"] = "һ���о�����",
["(bol broken) Ally ping SS"] = "(bol������)�Ѿ���ǵо���ʧ",
["Red/Blue respawn"] = "����buff����",
["Dragon/Baron/Vilemaw respawn"] = "С��/����/����֮������",
["Enemy gank incoming"] = "���������ĵ���Gank",
["Spells casted"] = "��ʹ�õļ���",
["Rengar R"] = "ʨ�ӹ�R",
["Pantheon R (1st)"] = "��ɭһ�δ���(����һ��)",
["Pantheon R (land)"] = "��ɭ���δ���(��½)",
["TwistedFate R1 (Destiny)"] = "����һ�δ���(����)",
["TwistedFate R2 (Gate)"] = "���ƶ��δ���(����)",
["Map Drawings"] = "С��ͼ��ʾ",
["--- Jungle timers ---"] = "--- ��Ұ��ʱ ---",
["Camp respawn"] = "Ұ��Ӫ������",
["--- Spell timers ---"] = "--- ���ܼ�ʱ ---",
["Akali Bubble"] = "�������İ���!ϼ��(W)",
["Tryndamere Ultimate"] = "̩���׶��Ĵ���",
["Kayle Ultimate"] = "�����Ĵ���",
["Pantheon Ultimate"] = "��ɭ�Ĵ���",
["Twisted Fate Ultimate"] = "���ƵĴ���",
["Thresh Lantern"] = "��ʯ�ĵ���",
["Gangplank Ultimate"] = "�����Ĵ���",
["Braum Shield"] = "��¡�Ķ���",
["Fiddlesticks Ultimate"] = "�����˵Ĵ���",
["Warwick Ultimate"] = "���˵Ĵ���",
["Wukong Decoy"] = "����W",
["Wukong Ultimate"] = "���ӵĴ���",
["Rammus Ultimate"] = "����Ĵ���",
["Nasus Ultimate"] = "��ͷ�Ĵ���",
["Renekton Ultimate"] = "����Ĵ���",
["Alistar Ultimate"] = "ţͷ�Ĵ���",
["Amumu Ultimate"] = "��ľľ�Ĵ���",
["Graves grenade"] = "��ǹ��W",
["Morgana shield"] = "Ī���ȵĶ�",
["Karthus Wall"] = "�����W",
["Blitzcrank shield"] = "�����˵ı���",
["Galio Ultimate"] = "����µĴ���",
["Taric Ultimate"] = "��ʯ�Ĵ���",
["Anivia egg"] = "����ĵ�",
["Mundo Ultimate"] = "�ɶ�Ĵ���",
["Autoattack ranges"] = "ƽA��Χ",
["--------- Enemies --------"] = "--------- �о� --------",
["Full circle"] = "������Ȧ",
["Perpendicular line"] = "��ֱ��",
["Circle section"] = "��Ȧ����",
["Distance from you to draw"] = "��ʾʱ����ľ���",
["Color of range"] = "��Ȧ��ɫ",
["--------- My hero --------"] = "--------- �Լ���Ӣ�� --------",
["Distance from enemy to draw"] = "��ʾʱ��о��ľ���",
["Show for"] = "��ʾ�Ķ���",
["Sound type"] = "��������",
["Gank alert"] = "gank��ʾ",
["Enemy Red/Blue respawn"] = "�з�����buff����",
["Ally Red/Blue respawn"] = "��������buff����",
["Dragon/Baron respawn"] = "����/С������",
["Dragon/Baron under attack"] = "����/С��������",
["Early game ends at minute"] = "��Ϸǰ�ڽ�����ʱ��",
["Store chats"] = "�̵�Ի�",
["Hide loaded message"] = "���ؼ�����Ϣ",
["Reload sprites button"] = "���¼���ͼƬ��ť",
["Show surrender votes"] = "��ʾͶ��ͶƱ��Ϣ",
["Real Life Info"] = "ʵ��������Ϣ",
["Show date"] = "��ʾ����",
["Show time"] = "��ʾʱ��",
["Color of infos"] = "��Ϣ����ɫ",
["Show latency and FPS"] = "��ʾfps���ӳ�",
["Horizontal position"] = "ˮƽλ��",
["Draw experience range"] = "��ʾ�����÷�Χ",
["Disable after early game (see 'Other')"] = "��Ϸǰ��֮��ر�",
["Color of experience range circle"] = "�����÷�Χ��Ȧ����ɫ",
["Quality of exp range circle"] = "�����÷�Χ��Ȧ������",
["Width of exp range circle"] = "�����÷�Χ��Ȧ�Ŀ��",
["Minion Bar"] = "С��Ѫ��",
["Missed CS"] = "©������",
["Troubleshooting"] = "���ѽ��",
["Disable sprites (need reload)"] = "�ر�ͼƬ��ʾ(��Ҫ���¼���)",
["Disable fullscreen warning (need reload)"] = "�ر�ȫ������(��Ҫ���¼���)",
["Color of timers"] = "��ʱ����ɫ",
["Silenced"] = "��Ĭ",
["AutoAttack ranges"] = "ƽA��Χ��Ȧ",
--------------------------���������-------------------
["Fantastik Draven"] = "���������",
["Combo key(Space)"] = "���а���(�ո�)",
["Farm key(X)"] = "��������(X)",
["Harass key(C)"] = "ɧ�Ű���(C)",
["Min. % mana for W and E "] = "ʹ��W��E����С����",
["Laneclear Settings"] = "��������",
["Use Q in 'Laneclear'"] = "��������ʹ��Q",
["Use W in 'Laneclear'"] = "��������ʹ��W",
["Jungleclear Settings"] = "��Ұ����",
["Use Q in 'Jungleclear'"] = "����Ұ��ʹ��Q",
["Use W in 'Jungleclear'"] = "����Ұ��ʹ��W",
["Draw Killable targets with R"] = "��ʾR�ܹ���ɱ��Ŀ��",
["Misc"] = "����",
["KillSteal Settings"] = "����ͷ����",
["Use Ult KS"] = "ʹ�ô�������ͷ",
["Avoid R Overkill"] = "����",
["Ult KS range"] = "��������ͷ�ķ�Χ",
["Use Ignite KS"] = "ʹ�õ�ȼ����ͷ",
["Catch axe if only in mouse range"] = "ֻ������귶Χ�ڵĸ�ͷ",
["Farm/Harass"] = "����/ɧ��",
["Use maximum 2 Axes"] = "ʹ�����2����ͷ",
["Draw mouse range"] = "��ʾ��귶Χ",
["Lag Free circle"] = "��Ӱ���ӳٵ���Ȧ",
["Mouse Range"] = "��귶Χ",
["Evadeee Integration(If loaded)"] = "Evadeee���(�������)",
["Don't catch if axe in turret"] = "��Ҫ�������µĸ�ͷ",
["Auto-Interrupt"] = "�Զ����",
["Info"] = "��Ϣ",
["Anti-Gapclosers"] = "��ͻ��",
["Baseult settings"] = "���ش�������",
["Health Generation prediction"] = "����ֵ�ظ�Ԥ��",
["Disable R"] = "����R",
["Sensetive Delay(.3 def)"] = "�������ӳ�",
["Catch Axes(Z)"] = "�Ӹ�ͷ(Z)",
["Use W to reach far Axes"] = "ʹ��W�ӱȽ�Զ�ĸ�ͷ",
["Draw Debug"] = "��ʾ����",
["Enable Permabox(reload)"] = "����״̬��ʾ(��Ҫ���¼���)",
["Left Click target lock"] = "�������Ŀ������",
["Orbwalker"] = "�߿�",
-----------------DD2-----------------
["Riven - Broken Wings"] = "���� - Broken Wings",
["Broken Wings [Main]"] = "Broken Wings [��Ҫ����]",
["Main [Spells]"] = "��Ҫ���� [����]",
["Use [Q - Broken Wings]"] = "ʹ�� [Q - ����֮��]",
["Use [W - Ki Burst]"] = "ʹ�� [W - ���ŭ��]",
["Use Youmus Ghostblade"] = "ʹ������֮��",
["Main [Initiator]"] = "��Ҫ���� [��������]",
["After E -> W"] = "E֮��W",
["Force AA"] = "ǿ��ƽA",
["Let Broken Wings decide"] = "�ɽű�����",
["Main [Gapclose]"] = "��Ҫ���� [ͻ��]",
["Gapclose [Q - Broken Wings]"] = "ͻ�� [Q - ����֮��]",
["In Combo"] = "��������",
["In Combo + Target is left-clicked"] = "����������Ŀ�걻�����������",
["Gapclose [E - Valor]"] = "ͻ�� [E - ����ֱǰ]",
["Main [Force R]"] = "��Ҫ���� [ǿ�ƴ���]",
["Cast R1 after next Animation"] = "���¸�����֮��ʹ��һ��R",
["Cast R2"] = "ʹ�ö���R",
["Force R2 -> Q3"] = "ǿ���ڶ���R֮��ʹ������Q",
["Force R On/Off"] = "ǿ��R ��/��",
["Broken Wings [Utility]"] = "Broken Wings [��������]",
["Utility [Killsteal]"] = "�������� [����ͷ]",
["Use [R2 - Windslash]"] = "ʹ�� [R2 - ����ն]",
["Utility [Defensive]"] = "�������� [����]",
["Auto W"] = "�Զ�W",
["Broken Wings [Flee]"] = "Broken Wings [����]",
["Use [E - Valor]"] = "ʹ�� [E - ����ֱǰ]",
["Broken Wings [LastHit]"] = "Broken Wings [β��]",
["Draw Minion Health Bar Lines"] = "��С��Ѫ����ʾָʾ��",
["Last Hit Adjustment"] = "β������",
["Earlier"] = "����",
["Later"] = "�Ƴ�",
["Last Hit Adjustment (Value)"] = "β������(��ֵ)",
["Broken Wings [JungleClear]"] = "Broken Wings [��Ұ]",
["Left click + Combo Key"] = "��� + ���а���",
["Broken Wings [Harrass]"] = "Broken Wings [ɧ��]",
["Harrass Key"] = "ɧ�Ű���",
["BW E Settings"] = "Broken Wings [E��������]",
["BW Visuals"] = "Broken Wings [��ʾ����]",
["Draw Range AA"] = "��ʾƽA��Χ",
["Draw Range Q"] = "��ʾQ��Χ",
["Draw Range W"] = "��ʾW��Χ",
["Draw Range E"] = "��ʾE��Χ",
["Draw Range R2"] = "��ʾ����R��Χ",
["Draw left-clicked Target"] = "��ʾ���������Ŀ��",
["Awareness Q"] = "Q������ȴ��ʾ",
["Awareness R"] = "R������ȴ��ʾ",
["Awareness left-clicked Target"] = "�������Ŀ����ʶ��ʾ",
["BW Advanced"] = "Broken Wings [�߼�����]",
["Q-AA Logic"] = "QA�߼�",
["Low Ping - Stable"] = "���ӳ� - �ȶ�ģʽ",
["High Ping - Predicted"] = "���ӳ� - ����Ԥ��ģʽ",
["Cancel Animation"] = "ȡ������",
["Dance"] = "����",
["Laugh"] = "��Ц",
["Silent"] = "����",
["Extra WindUpTime AA"] = "����ƽA��ҡʱ��",
["Extra WindUpTime Q-AA"] = "����QA��ҡʱ��",
["Core Processing"] = "���Ĵ���",
["Section 1"] = "����1",
["Section 2"] = "����2",
["Cancel manual Broken Wings(Q)"] = "ȡ���ֶ�Q�ĺ�ҡ",
["Stop Move over MousePos"] = " ",
["BW Combo Key"] = "Broken Wings [���а���]",
["BW Version"] = "Broken Wings [�汾��]",
["No Targeted Spells Found"] = "û���ҵ�ָ���Լ���",
-------------------Pew�߿�----------------
["Pewalk"] = "Pew�߿�",
["Keys"] = "����",
["-Skills-"] = "- ���� -",
["SKILLS: Lane Clear"] = "����:����",
["-Orbwalking-"] = " - �߿� -",
["Carry (SBTW)"] = "����",
["Mixed"] = "ɧ��",
["Key"] = "����",
["Toggle"] = "����",
["Draw Attack Range"] = "��ʾƽA��Χ",
["Target Selection"] = "Ŀ��ѡ��",
["Prioritize Selected Target"] = "������Ŀ������",
["Draw Current Target"] = "��ʾ��ǰ��Ŀ��",
["Low FPS"] = "��fps��Ȧ",
["-Priorities-"] = "- ���ȼ� -",
["Skill Farming"] = "���ܷ���",
["Reset: Broken Wings"] = "Ԥ��:Broken Wings",
["Only under turret"] = "ֻ������",
["Double Edged Sword"] = "˫�н�",
["Opressor"] = "��ǿ����",
["Bounty Hunter"] = "�ͽ�����",
["Savagery"] = "Ұ��",
["[Humanizer] Movement Interval"] = "[���˻�] �ƶ����",
["Stop Movement"] = "ֹͣ�ƶ�",
["Left Mouse Button Down"] = "�������ʱ",
["Mouse Over Hero"] = "Ӣ���������ʱ",
["Last Hit Adjustment (ms)"] = "β������(ms)",
["Support Mode"] = "����ģʽ",
--------------------bigfat ez----------------------
["Big Fat Ezreal"] = "Big Fat�������",
["[Mode]"] = "[ģʽ]",
["Settings Mode:"] = "����ģʽ",
["Recommended"] = "�Ƽ�����",
["Expert"] = "ר������",
["If you want to change back to Recommended"] = "�������ָ��Ƽ�����",
["change it and press double f9"] = "�ı�ģʽ���밴2��F9",
["Ignore SxOrbwalk"] = "�����߿�",
["dont force loading big fat walk"] = "��ǿ�ƶ�ȡBig Fat�߿�",
["Current Prediction: Big Fat Vanga ver.: (1.3)"] = "ĿǰԤ�У�Big Fat �汾1.3",
["Toggle: Q"] = "����Q",
["Toggle: W"] = "����W",
["Bitch plx: WE 2 Mouse"] = "WE���������λ��",
["Big Fat Ezreal v. 0.25"] = "Big Fat������� V0.25",
["obviously by Big Fat Team"] = "Big Fat�Ŷӳ�Ʒ",
["[Draws]"] = "[ͼ����ʾ]",
["Based on Range Dmg Info"] = "���ݾ����˺���Ϣ",
["Draw Target Info"] = "��ʾĿ����Ϣ",
["[HitChance]"] = "[���м���]",
["[Kill Steal]"] = "[����ͷ]",
["Chance: "] = "����",
["R Chance: "] = "R����",
["[Custom Settings]"] = "[�Զ�������]",
["Q: Enable Vanga Dashes"] = "Q������ͻ��",
["W: Enable Vanga Dashes"] = "W������ͻ�� ",
["[KS Options]"] = "[����ͷѡ��]",
["Enable KS"] = "��������ͷ",
["KS with Q"] = "ʹ��Q����ͷ",
["KS with R"] = "ʹ��R����ͷ",
["max R Range: "] = "���R����",
["min R Range: "] = "��СR����",
["Q: Use mana till :"] = "Q��ħ��ֵ����",
["W: Use mana till :"] = "W��ħ��ֵ����",
["Use Whitelist"] = "ʹ�ð�����",
["Whitelist Distance"] = "����������",
["exception if White List Out Of Range"] = " ��������������������",
["exception if do more dmg to other target"] = "����ܶ�����Ŀ����ɸ����˺�����",
["enable this filter"] = "ʹ�����������",
["[Key Binds]"] = "[������]",
["automaticly take binds from Orbwalk"] = "�Զ�ʹ���߿����ð���",
-------------------------bigfat�߿�------------------------
["Big Fat Orbwalker"] = "Big Fat�߿�",
["Draw Prediction and Dmg"] = "��ʾԤ�к��˺�",
["Use harass in LaneClear"] = "��������ʹ��ɧ��",
["Draw Range"] = "��ʾ��Ȧ",
["Support mode"] = "����ģʽ",
["Extra WindUp Time"] = "�����ҡʱ��",
["Twin Shadows 1"] = "˫����Ӱ1",
["Twin Shadows 2"] = "˫����Ӱ2",
["Frost Queen's Claim"] = "��˪Ů����ָ��",
["Youmuu's Ghostblade"] = "����֮��",
["Odyn's Veil"] = "Ů����ɴ",
["Muramana 2"] = "ħ��2",
["Randuin's Omen"] = "����֮��",
["Muramana 1"] = "ħ��1",
["KeyBinds"] = "����",
["Big Fat Orbwalker v. 0.51"] = "Big Fat�߿� v. 0.51",
["by Big Fat Team"] = "Big Fat�Ŷӳ�Ʒ",
-------------------------pewŮ��---------------------------
["PewCaitlyn"] = "PEWŮ��",
["Piltover Peacemaker"] = "��ƽʹ��(Q)",
["Use in Carry Mode"] = "����ģʽʹ��",
["Harass in Mixed Mode"] = "ɧ��ģʽʹ��",
["Harass in Clear Mode"] = "����ģʽʹ��",
["Peacemaker Control Method"] = "��ƽʹ��ʹ��ģʽ",
["Calculated"] = "����",
["Manual Control Key"] = "�ֶ����Ƽ�",
["Cast HitChance [3==Highest]"]	=	 "������3��Ŀ��ʱʹ�ã�3������ࣩ",
["Maximum Minion Collision"] = "���С����ײ",
["Use for Last Hits"] = "β��ʱʹ��",
["** Only when AA is on CD"] = "** ֻ���չ���ȴʱʹ��",
["Always Save Mana for E"] = "����ΪE����ħ��",
["Draw Peacemaker Range"] = "��ʾ��ƽʹ�߾���",
["Yordle Snap Trap"] = "Լ�¶��ղ���(W)",
["Cast on Target Path"] = "��Ŀ��·����ʹ��",
["Trap Channel Spells"] = "�����ͷ�����������",
["Trap Crowd Control"] = "Ⱥ���з���",
["Trap Revives (GA / Chronoshift)"] = "�����ڼ�������ĵ�����ߣ��ػ���ʹ/ʱ����У�",
["Trap Teleports"] = "�����ڴ��͵�",
["Trap on Lose Vision (Grass)"] = "������û����Ұ�ĵط����ݴԣ�",
["Draw Active Trap Timers"] = "��ʾ����ʱ��",
["90 Caliber Net"] = "90�ھ�����(E)",
["Net To Mouse"] = "�����λ�÷���",
["Block Failed Wall Jumps"] = "��ֹʧ�ܵ�Խǽ",
["Do Not Block if Will Jump This Far"] = "������ĺ�Զ����ֹ",
["Ace in the Hole"] = "���ӵ���(R)",
["Draw Can Kill Alert"] = "��ʾ���Դ��л�ɱ��ʾ",
["Draw Line to Killable Character"] = "�����߷�ʽ��ʾ���Ŀ��",
["Draw Health Remaining Indicator"] = "��ʾʣ������ֵָʾ",
["Kill Key"] = "��ɱ��",
["Use Automatically"] = "�Զ�ʹ��",
["-Other-"] = "-����-",
["E - Q Combo"] = "E-Q����",
["Movement Interval"] = "�ƶ����",
--------------------bigfat���˹---------------------
["Jinx, Bombs and Bullets"] = "ǹ�ڽ��˹",
["Recall Kill Settings"] = "�سǻ�ɱ����",
["Use On"] = "����",
["On - Recall Spot Only"] = "����-ֻ��ɱ����Ұ�ܷ��ֵĻس�",
["Additional Damage Buffer %"] = "�����˺����%",
["Show recall messages"] = "��ʾ�س���Ϣ",
["Draw recall locations"] = "��ʾ�سǵص�",
["Use W combo if  mana is above"] = "���ħ��ֵ��X����ʹ��W����",
["Use R combo finisher"] = "ʹ��R�����ս�",
["Ward bush when they hide"] = "���˽��ݲ���",
["Use QSS/Mercurial if hard CCed"] = "���Ӳ�غܶ�ʹ��ˮ���䵶��ˮ���δ�",
["Use W harass if  mana is above"] = "���ħ��ֵ��X����ʹ��Wɧ��",
["Lane Clear Key Switch to"] = "����ת����",
["Rocket"] = "���ģʽ",
["Mini Gun"] = "��ǹģʽ",
["Q Switch Method:"] = "Qģʽת��:",
["Switch weapon for:"] = "�������ת������ģʽ:",
["Range & DPS"] = "��������",
["KS With W"] = "W����ͷ",
["Min W range"] = "W��С����",
["Use Trap on CCed"] = "�Ա����Ƶĵ���ʹ������",
["Use Trap on Thresh/Blitz cast"] = "��ʯ�ͻ�����ʩ��ʱʹ������",
["Auto R max range"] = "�Զ�������R",
["Auto R frequency"] = "�Զ�R��Ƶ��",
["Force Ult Mode"] = "ǿ��ʹ�ô���",
["Draw Alternate AA Range"] = "��ʾAA��Χ",
["Draw Auto (R) Max Range"] = "��ʾ�Զ�R��������",
["Draw R predicted spot"] = "��ʾԤ�Ƶ�R�ص�",
["Full Combo Key (SBTW)"] = "ȫ�״���",
["Force Ult"] = "ǿ��ʹ�ô���",
["Force Trap"] = "ǿ��ʹ������",
-------------------------------bigfat�ɻ�-----------------------
["Big Fat Corki"] = "Big Fat�ɻ�",
["Big Fat Corki v. 0.51"] = "Big Fat�ɻ� V0.51",
["Big One R - between minion and target:"] = "��С����Ŀ��֮��R",
["max distance :"] = "������",
["R: Enable Vanga Dashes"] = "R������",
["R: Use mana till :"] = "R����ħ��ֵXʱʹ��",
["E max Cast Distance"] = "��ԶE�ľ���",
["E: Use mana till :"] = "E����ħ��ֵXʱʹ��",
["Extra Settings"] = "��������",
["Force Exhaust"] = "ǿ������",
["Heal Settings"] = "��������",
["--- Teammates to Heal ---"] = "---�Զ���ʹ������---",
["Shield'n'Heal"] = "���ܺ�����",
["Item Manager"] = "��Ʒ����",
["Mikael's Crucible"] = "�׿���������",
["Cast it on Bard"] = "�԰͵�ʹ��",
["CC + Health"] = "����+����",
["CC"] = "����",
["Health"] = "����",
["Heal: Min % to cast it"] = "���ƣ�С��%Ѫ��ʹ��",
["Humanizer: CC/Slow Delay (ms)"] = "���˻��ӳ�:����/���٣����룩",
["CC: Usual debuffs"] = "���ƣ�����״̬",
["CC: Slow debuff"] = "���ƣ�����״̬",
["CC: Special cases"] = "���ƣ��������",
["Face of the Mountain"] = "ɽ��֮��",
["--> Use Face of the Mountain"] = "ʹ��ɽ��֮��",
["Use Locket of the Iron Solari in combat"] = "ʹ�ø�������֮ϻ",
["Use Zhonyas"] = "ʹ�����",
["Use Frost Queen's Claim"] = "ʹ�ñ�˪Ů�ʵ�����",
["Auto Brush Wards"] = "�ݴ��Զ�����",
["Ward Brush when lose enemy vision"] = "�����˽���ݴ�ʱ����",
["Key 1"] = "����1",
["Key 2"] = "����2",
["Key 3"] = "����3",
["Key 4"] = "����4",
["Key 5"] = "����5",
["Key 6"] = "����6",
["Key 7"] = "����7",
--------------------------funhouse---------------------------------------
["Bard Fun House"] = "���˸����ϼ� - �͵�",
["Magical Journey"] = "�����ó�",
["AFK Chimes"] = "AFK��ʾ",
["Force Q Cast for slow"] = "ǿ��ʹ��Q����",
["Force R with prediction"] = "ǿ��ʹ����Ԥ�е�R",
["--- Q Settings ---"] = "--- Q���� ---",
["Extended Q Calculations"] = "�����Q����",
["Cast Q to slow without Stun"] = "ʹ��Q���ٵ�����",
["--- W Settings ---"] = "--- W���� ---",
["Use W for self heal"] = "ʹ��W���Լ�����",
["Maximum % Health to use (W)"] = "��Ѫ������%ʱʹ��W",
["Use W for allies in combat"] = "ս���ж��Ѿ�ʹ��W",
["W ally only if Bard is safe"] = "ֻ���Լ���ȫ��ʱ����Ѿ�ʹ��W",
["--- E Settings ---"] = "--- E���� ---",
["Cast Q during escapes"] = "����ʱʹ��Q",
["Use W during escapes"] = "����ʱʹ��W",
["--- R Settings (BETA) ---"] = "--- R���� ---",
["R Range Percent"] = "R����ٷֱ�",
["Minimum % Mana to use (Q)"] = "��������X%ʱʹ��Q",
["Minimum % Mana to use (E)"] = "��������X%ʱʹ��E",
["Minimum % Mana to use (R)"] = "��������X%ʱʹ��R",
["--- Harass Settings ---"] = "ɧ������",
["Use Mana Manager"] = "ʹ�÷�������",
["Auto Chimes"] = "�Զ���ʾ",
["Collect in enemy jungle"] = "�ڵ���Ұ��ʹ��",
["Behind ally + no enemies only"] = "�Ѿ��󷽲�����Χû�е���",
["Safety distance vs enemy"] = "�Եа�ȫ����",
["Cast Q Stun on encounter"] = "��������ʹ��Q��",
["Cast W on encounter"] = "��������ʹ��W",
["Cast W for boost on full mana"] = "ʹ��W����(�������)",
["Cast E for shortcut"] = "ʹ��E�߽ݾ�",
["Smart R on enemies when in escape"] = " ׷����������ʹ��R",
["Smart R on allies in danger"] = "���Ѿ���Σ��ʱʹ��R",
["Ward enemy discover location"] = "���ֵ��˵�λ�ò���",
["Anti Dash & Gapclose"] = "��ͻ��",
["--- Anti Dash & Capclose  Settings ---"] = "--- ��ͻ������ ---",
["Use Q for Dash & Gapclose"] = "ʹ��Q��ͻ��",
["Draw Q Extended"] = "��ʾQ������",
["Draw R target"] = "��ʾR��Ŀ��",
["Debug Mode"] = "����ģʽ",
["Q2 Hit Chance"] = "Q2������",
["Blitzcrank"] = "������",
["Cast it on Janna"] = "�Է�Ů",
["Shield Manager"] = "���ܹ���",
["Shield Whitelist"] = "���ܰ�����",
["--- Janna ---"] = "--- ��Ů ---",
["Shield options"] = "����ѡ��",
["Ignore"] = "����",
["Shield AA & Spells"] = "����ƽA�ͷ���",
["Shield Auto Attacks"] = "�����Զ�����",
["Shield Spells"] = "���ܷ���",
["Shield if below % health "] = "Ѫ������%ʹ�û���",
["--- Blitzcrank ---"] = "--- ������ ---",
["Blitzcrank - Auto Attack"] = "�Զ�����",
["Blitzcrank - Q: RocketGrab"] = "������Q",
["Blitzcrank - E: PowerFistAttack"] = "������E",
["Blitzcrank - R: StaticField"] = "������R",
["Humanizer: Shield Delay (ms)"] = "���˻��������ӳ٣����룩",
["Min X% Mana"] = "��������%ʹ��",
["Janna Fun House"] = "���˸����ϼ� - ��Ů",
["Enable Shield (Toggle)"] = "���û��ܿ���",
["--- Combat Settings ---"] = "ս������",
["Only use Q to interrupt"] = "ֻ��Q���",
["Settings inside the Shield'n'Heal menu"] = "����ʹ�û��ܺ����Ʋ˵�������",
["Use Q as anti enemy gap closers"] = "��Q��ͻ��",
["Use Q as spell interruptor"] = "��Q���",
["Use W for ks"] = "W����ͷ",
["Draw Insec Position"] = "��ʾͻ��λ��",
["Insec color"] = "ͻ����ɫ",
["Kayle"] = "����",
["Fizz Fun House 2.0"] = "���˺ϼ�2.0 - ����",
["Jungle Steal mode"] = "��Ұ��ģʽ",
["Instant R"] = "����R",
["--- Combo Logic - Q ---"] = "--- �����߼����� Q ---",
["Use Min dist to Q (default off)"] = "ʹ��Q����С���루Ĭ�Ϲرգ�",
["Min distance to use Q"] = "ʹ��Q����С����",
["Q minion Gapclose potential kill"] = "������Ի�ɱQС��ͻ��",
["--- Combo Logic - E ---"] = "--- �����߼����� E ---",
["Force E on combo (Smart)"] = "--- ����ǿ��ʹ��E�����ܣ�---",
["Mid-air Flash finish if out-range"] = "�������������Χ������",
["--- Combo Logic - R ---"] = "--- �����߼����� R ---",
["Enable Long Range R (prediction)"] = "����ʹ��Զ����R��Ԥ��λ�ã�",
["Use R below enemy hp % "] = "����Ѫ��С��%ʹ��R",
["R for potential kill (dmg calc)"] = "����ʹ��R��ɱ���˺�Ԥ����",
["--- Misc ---"] = "--- ���� ---",
["Mana check for succesful Q+W"] = "Q+Wǰ�жϷ���ֵ�Ƿ��㹻",
["Harass and escape with Q/E :"] = "ɧ�ź�����ʱʹ��Q/E",
["Use Urchin Strike (Q)"] = "ʹ��Q",
["E Options"] = "Eѡ��",
["Animation Cancel all jumps"] = "ȡ����Ծ����",
["Dodge spells from the list "] = "����г��ķ���",
["Use Playful on enemy gap closers"] = "�Ե���ͻ��ʹ���������",
["Jump/Back with Steal mode even if no smitable"] = "����ȥ/���������ּ�ʹû�гͽ�",
["Auto E on burst damage (40% HP of dmg)"] = "�Զ�E�����˺����Ե����40%�����˺���",
["Jump List"] = "��������",
["--- Jump At Spell Arrival ---"] = "--- ����������ʱ�� ---",
["Kayle - Q: JudicatorReckoning"] = "����Q",
["Kayle - W: JudicatorDevineBlessing"] = "����W",
["Kayle - E: JudicatorRighteousFury"] = "����E",
["Kayle - R: JudicatorIntervention"] = "����R",
["R Targetting"] = "RĿ��",
["Cast R on Kayle"] = "�Կ���ʹ��R",
["Use Seastone Trident (W)"] = "ʹ�ú��������W",
["Use Playful Trickster (E)"] = "ʹ���������E",
["Misc Draws"] = "������ʾ",
["Draw Jump Spots"] = "��ʾ��Ծ�����",
["Jump color"] = "��Ծ��ɫ",
["Draw Double Jump Spots"] = "��ʾ���������",
["Double Jump color"] = "��������ɫ",
["Cast Ignite on Kayle"] = "�Կ���ʹ�õ�ȼ",
["Written by: burn & ikita - Fun House Team"] = "��Burn & Ikita ������Ʒ",
["Urgot Fun House 2.0"] = "���˺ϼ� 2.0 - �����",
["Urgot Fun House"] = "���˶����",
["Auto Q1: if poisoned enemy"] = "��������ж��Զ�Q1",
["Auto Q2: if enemy not poisoned"] = "�������û�ж��Զ�Q2",
["Auto Q3: for ks enemy"] = "����ܻ�ɱ�Զ�Q3",
["Disable: Auto Q2-Q3 under enemy tower"] = "�������½����Զ�Q2-Q3",
["--- Q Enemy Track System on FOW ---"] = "--- ׷��Q�����еĵ��� ---",
["Auto Q poisoned enemy in FOW"] = "�Զ�Q�������ж��ĵ���",
["Enable a hotkey for stop Q in FOW"] = "ʹ��һ���ȼ�ֹͣ�Զ�Q�����еĵ���",
["Hotkey for stop Auto Q in FOW"] = "�ȼ�ֹͣ�Զ�Q�����еĵ���",
["Use W on AA range for slow enemy"] = "�չ���Χ��ʹ��W���ٵ���",
["If in AA range, delay combo for the slow"] = "����չ���Χ�ڣ��ӳ��������ȼ���",
["Use W with Q locked for slow enemy"] = "��Q���ٵĵ���ʹ��W",
["Use W if enemy tower focus Urgot"] = "�������Ŀ���Ƕ����ʹ��W",
["Use W vs enemy gaps closers"] = "����ͻ��ʹ��W",
["Use W vs targeted spells"] = "��Ŀ��ķ���ʹ��W",
["--- Enable W on this spells: ---"] = "--- �������·���ʹ��W ---",
["--- R champions Interrupter ---"] = "--- R�з�Ӣ�۴�� ---",
["Difference between enemy/team allies"] = "��������",
["Use R as spell interrupter"] = "ʹ��R��Ϊ���",
["No cast R as interrupter if:"] = "������������ʹ��R",
["Enemy allies > Ours, with 1 of difference"] = "����>�Ҿ���������1",
["--- R champions Tower focus ---"] = "������Ŀ��ʹ��R",
["Enemy allies surrounding our target"] = "���˺��Ҿ���Ŀ�긽��",
["Auto R: Make our tower focus enemy"] = "�Զ�R��ʹ�Ҿ���רע����",
["No cast R as tower focus if:"] = "������������������Ŀ��ʹ��R",
["Enemy is surrounded for 1"] = "��1����������Χ",
["Our Health is lower than %"] = "���ǵ�Ѫ������%",
["Health %"] = "Ѫ��%",
["Use Acid Hunter (Q)"] = "ʹ��Q",
["Q usage mode: "] = "Q��ʹ��ģʽ",
["Spam mode"] = "����ģʽ",
["For kill minion"] = "Ϊ��ɱС��",
["Use Noxian Corrosive Charge (E) [jungle]"] = "��Ұ��ʹ��E",
["Only if AA on cooldown"] = "ֻ���չ���ȴʱ",
["Min Mana % for E harass"] = "ʹ��Eɧ�ŵ���ͷ���%",
["--- Enemy Track System ---"] = "--- ׷�ٵ��� ---",
["Draw Enemy prediction on FOW"] = "��ʾս�������е��˵�Ԥ��λ��",
["Show if tracker is temp. disabled"] = "���׷�ٱ�����",
["Draw Poison time on enemy"] = "��ʾ�����ж�ʱ��",
["Poison time color"] = "�ж�ʱ����ɫ",
["Auto use Muramana active vs enemies"] = "�Ե�ʱ�Զ�ʹ��ħ��",
["Auto disable Muramana if no enemies"] = "û�е���ʱ�Զ�����ħ��",
["Cast it on Blitzcrank"] = "�Ի�����ʹ��",
["Blitzcrank Fun House"] = "���˸����ϼ� - ������",
["Use R+Q Combo"] = "ʹ��R+Q����",
["Use Q Killsteal"] = "ʹ��Q����ͷ",
["Use R Killsteal"] = "ʹ��R����ͷ",
["Set Q Range 750-925"] = "����Q�ľ��� 750-925",
["Use Q on"] = "ʹ��Q������",
["Use Q on Lux"] = "������˿ʹ��Q",
["--- R Settings ---"] = "--- R���� ---",
["Use R to interrupt spells"] = "ʹ��R��Ϸ���",
["X enemy targets to use R"] = "��������ΪXʱ��ʹ��R",
["Use E for Dash & Gapclose"] = "ʹ��Eͻ��",
["Draw Q Hook line"] = "��ʾQ�ĵ���",
----------------Jhin----------------
["Machine Series: Jhin"] = "Machine�ϼ�����",
["Only if first minion kill"] = "������һ��С���ܱ���ɱ",
["Use W: "] = "ʹ��W��",
["Only on stunnable"] = "ֻ���ڽ���Ŀ��",
["Use W on Shaco invis"] = "�������С��ʹ��W",
["Min W range if not reloading"] = "W����С��Χ",
["Use Trap on channeled spells"] = "���������������ĵ���ʹ������",
["ON including own"] = "��-�����Լ��Ŀ��Ƽ���",
["Cast Ult on FoW enemies"] = "��ս��������ĵ���ʹ��R",
["Additional Humanizer (ms)"] = "�������˻��ӳ�(����)",
["Use E in Wave Clear"] = "��������ʹ��E",
["Show (R) Humanizer Timer"] = "��ʾR�������˻��ӳټ�ʱ��",
["Draw AA and (Q) Range"] = "��ʾƽA��Q�ķ�Χ",
["Draw (R) Range Minimap"] = "��С��ͼ����ʾR�ķ�Χ",
["Percent"] = "�ٷֱ�",
["Raw Damage"] = "��ʾ�˺�",
["Assisted (R) Key (Hold)"] = "������R����(��ס����)",
["High Noon"] = "�������� - ��",
----------------MMA-----------------
["Marksman's Mighty Assistant"] = "MMA�߿�",
["Orbwalk [On-Hold]"] = "�߿� [��ס]",
["Last Hit [On-Hold]"] = "β�� [��ס]",
["Lane Clear [On-Hold]"] = "���� [��ס]",
["Dual Carry [On-Hold]"] = "˫���߿� [��ס]",
["Orbwalk [Toggle]"] = "�߿� [����]",
["Last Hit [Toggle]"] = "β�� [����]",
["Lane Clear [Toggle]"] = "���� [����]",
["Dual Carry [Toggle]"] = "˫���߿� [����]",
["Last-Hit Settings"] = "β������",
["Lane Freeze"] = "�����������",
["Last-Hit Assistance"] = "β������",
["Dual Carry Setup"] = "˫���߿�����",
["Orbwalk + Last-Hit"] = "�߿� + β��",
["Orbwalk + Lane-Clear"] = "�߿� + ����",
["Dual Carry mode first priority"] = "˫���߿�ģʽ����",
["Heroes"] = "Ӣ��",
["Minions"] = "С��",
["Enable HP Correction under turrets"] = "�ڷ�������ʱ��������ֵ����",
["Give priority to big jungle mobs"] = "�趨����Ұ������",
["Movement Settings"] = "�ƶ�����",
["Distance over DPS"] = "���������ƶ��ľ���",
["Hold-Position on mouse stop"] = "�������ʱֹͣ�ƶ�",
["Orbwalk Boxes/Plants etc."] = "�߿�ʱ����С�����/�����ֲ��",
["Hold-Position near walls"] = "��ǽ��ʱֹͣ�ƶ�",
["Movement spam rate (in ms)"] = "�ƶ�ָ���Ƶ��(����)",
["Mouse detection sensitivity"] = "��궯��������ж�",
["Active"] = "��Ч",
["Usage on Enemy %HP: "] = "����������ֵ����%ʱʹ��",
["Usage on myHero %HP: "] = "���Լ�����ֵ����%ʱʹ��",
["Tiamat & Ravenous Hydra"] = "�������� & ̰����ͷ��",
["Target Mode: All[ON]/Champions[OFF]"] = "Ŀ��ѡ��ģʽ: ����Ŀ��[��]/ֻ��Ӣ��[��]",
["Use when enemy count more than"] = "��������������xʱʹ��",
["Use items in LaneClear mode"] = "��������ʹ����Ʒ",
["Use items in Dual-Carry mode"] = "��˫���߿�ģʽ��ʹ����Ʒ",
["Using Infinity Edge?"] = "ʹ���޾�֮��?",
["Display Settings"] = "��ʾ����",
["Auto-Attack Range"] = "ƽA��Χ",
["Auto-Attack Range Awareness"] = "AA��Χ��ʶ",
["Current Target Circle"] = "��ǰĿ����Ȧ",
["Low-FPS circles"] = "��FPS��Ȧ",
["Auto-Attack Range Circle Color"] = "ƽA��Ȧ��ɫ",
["Display a circle on queued minions"] = "�ڵȴ���β����С���ϻ�Ȧ",
["How fast will my target die?"] = "Ŀ���������ٶ��ж��?",
["Last-Hit Circles"] = "β����Ȧ",
["Enable PermaShow for keys (Reload)"] = "���ð���״̬��ʾ(��Ҫ���¼���)",
["Debugging Settings"] = "��������",
["Enable debug prints"] = "���õ�����Ϣ��ʾ",
["Debug last-hit spell damage (Reload)"] = "����β�������˺�(��Ҫ���¼���)",
["Enable heros auto attacks"] = "����Ӣ�۵���ͨ����",
["Debug time between auto-attacks"] = "������ͨ����ֱ�ӵļ��ʱ��",
["Debug auto-attack damage"] = "������ͨ�������˺�",
["Debug auto-attack cancels"] = "����ȡ����ͨ����",
["Debug minion HP correction"] = "����С��Ѫ������",
["Enable class initialization prints"] = "�������ʼ����Ϣ��ʾ",
["Disable ally minion attack prediction"] = "�ر��ѷ�С������Ԥ��",
["Debug animation strings"] = "���Զ����ַ���",
["Target Selector Mode"] = "Ŀ��ѡ����ģʽ",
["Lowest HP"] = "Ѫ�����",
["Near Mouse"] = "��긽��",
["Most DPS"] = "������",
["Lowest HP + Most DPS"] = "Ѫ�����+������",
["Target Selector Priorities"] = "Ŀ��ѡ�������ȼ�",
["Attack selected targets only"] = "ֻ����ѡ����Ŀ��",
["Target people on camera view"] = "ֻѡ������Ļ�ڵ�Ŀ��",
["1st Priority"] = "һ������",
["2nd Priority"] = "��������",
["3rd Priority"] = "��������",
["4th Priority"] = "�ļ�����",
["5th Priority"] = "�弶����",
["Turret Manager"] = "������������",
["Enemy Turrets"] = "�з�������",
["Show Range"] = "��ʾ��������Χ",
["Opacity"] = "͸����",
["Show Aggro Colors"] = "��ʾ���������ɫ",
["Distance Based Opacity"] = "ȡ���ھ����͸����",
["Hide Distance"] = "���ؾ���",
["Ally Turrets"] = "�ѷ�������",
["Enable Dive-Awareness "] = "����Խ����ʶ",
["Mastery Settings"] = "�츳����",
["Buff Settings"] = "Buff����",
["Enable auto-potions"] = "�����Զ�ҩˮ",
["Potion Settings"] = "�Զ�ҩˮ����",
["Hunter Potion %"] = "����ҩˮ %",
["Corrupting Potion %"] = "����ҩˮ %",
["Biscuit %"] = "���� %",
["ItemCrystalFlask %"] = "ħƿ %",
["Health Potion %"] = "Ѫƿ %",
["Mana Potion %"] = "��ƿ %",
["Seraph's Embrace %"] = "����ʹ֮ӵ %",
["Use potions when ignited"] = "����ȼʱʹ��ҩˮ",
["Disable Crowd-Control Detection"] = "�رտ��Ƽ��ܼ��",
["No spells supported for this champion"] = "",
["Auto Bushes"] = "�Զ�̽��",
["Ward bushes on toggle"] = "�Զ����ݲ��ۿ���",
["Maximum bush check time (in sec)"] = "�������ʱ����(��)",
["Switch mode for"] = "�л�ģʽΪ",
["None"] = "��",
["On-Hold"] = "��ס",
["Toggle"] = "����",
["Add key for"] = "��Ӱ���Ϊ",
["Orbwalking"] = "�߿�",
["Last-Hitting"] = "β��",
["Lane-Clearing"] = "����",
["Dual-Carrying"] = "˫���߿�",
["Lasthitting"] = "β��",
["Lasthitting2"] = "β��2",
["Lasthitting3"] = "β��3",
["Laneclearing"] = "����",
["Laneclearing2"] = "����2",
["Laneclearing3"] = "����3",
["Dualcarrying"] = "˫���߿�",
["Dualcarrying2"] = "˫���߿�2",
["Dualcarrying3"] = "˫���߿�3",
["Version: "] = "�汾��:",
-------------------HTTF����----------------
["HTTF Riven"] = "HTTF ����",
["Burst Combo Toggle"] = "�������п���",
["Use Flash in Burst Combo"] = "�ڱ���������ʹ������",
["Ulti"] = "����",
["Activate R Mode"] = "����Rģʽ",
["Kill Steal"] = "����ͷ",
["Combo - The number of QAA"] = "���� - QA����",
["Cast R Mode"] = "ʹ��Rģʽ",
["Save First Q before AA (T)"] = "��ͨ����֮ǰ������һ��Q",
["Use EQ (T)"] = "ʹ��EQ",
["Save E before W (F)"] = "��W����֮ǰ����E����",
["Use Item"] = "ʹ����Ʒ",
["Save First Q before AA (F)"] = "��ͨ����֮ǰ������һ��Q",
["Activate R"] = "����R",
["Cast R"] = "ʹ��R",
["Clear"] = "����/��Ұ",
["Save First Q even if Last Hit (T)"] = "��β���е���ͨ����֮ǰ������һ��Q",
["Use EQ (F)"] = "ʹ��EQ",
["Use W Min Count"] = "ʹ��W����С��������",
["Wall Jump"] = "��ǽ",
["Use Wall Jump"] = "ʹ�÷�ǽ",
["Misc"] = "����",
["Use Animation Cancel"] = "ʹ�ö���ȡ����ҡ",
["Cancel Type"] = "ȡ����ҡ����",
["Joke"] = "����Ц",
["Provoke"] = "����",
["Auto Cancel Q for manual QAA (F)"] = "�Զ�ȡ���ֶ�QA��Q��ҡ",
["Cast E even if enemy is so closed (F)"] = "��ʹ�Ѿ�������Ŀ����Ȼʹ��E",
["Combo - Attack selected target (T)"] = "�������� - ����ѡ����Ŀ��",
["Combo - Select range (600)"] = "�������� - ѡ��Ŀ�귶Χ",
["Burst - Attack selected Target (T)"] = "�������� - ����ѡ����Ŀ��",
["Burst - Select range (1200)"] = "�������� - ѡ��Ŀ�귶Χ",
["Q Cancel time offset"] = "ȡ��Q��ҡʱ��Ԥ��",
["Buffer between AA dmg and Spell"] = "ƽA�뼼��֮��Ļ���ʱ��",
["Buffer between AA dmg and move"] = "ƽA���ƶ�ָ��֮��Ļ���ʱ��",
["Moving interval"] = "�ƶ����",
["Stop moving over mouse"] = "����긽��ʱֹͣ�ƶ�",
["Draw"] = "��ʾ",
["Draw Lag free circles"] = "ʹ�ò�Ӱ���ӳٵ���Ȧ",
["Draw Hitchance"] = "��ʾ���м���",
["Draw Combo Damage"] = "��ʾ�����˺�",
["Wall Jump Position"] = "��ǽ�ص�",
["Renekton"] = "�׿˶�",
["HTTF Smite (HTTF Riven)"] = "HTTF �ͽ� (HTTF ����)",
["Jungle Steal Settings"] = "��Ұ������",
["Use Smite"] = "ʹ�óͽ�",
["Use Smite Toggle"] = "ʹ�óͽ俪��",
["Always Steal Dragon"] = "���ǿ�������",
["KillSteal Settings"] = "����ͷ����",
["Use Stalker's Blade"] = "ʹ��׷���ߵĵ���",
["Draw Smite range"] = "��ʾ�ͽ䷶Χ",
["Draw Target"] = "��ʾĿ��",
["Draw Attack range"] = "��ʾƽA��Χ",
["Early casting"] = "�����ϵ�ȼ",
["Save Ignite if Killable with Spells"] = "���Ŀ���ܱ����ܻ�ɱ������ȼ",
---------------------SIUsage---------------
["Summoner & Item Usage"] = "SIUsage���",
["Health Potions"] = "Ѫƿ",
["Use While Pressed"] = "������ʱʹ��",
["Use Always"] = "����ʹ��",
["Use if no enemies"] = "û�е���ʱʹ��",
["If My Health % is <"] = "����Լ�������ֵ����%",
["Remove CC"] = "�������",
["Remove Exhaust"] = "�������",
["Removal delay (ms)"] = "����ӳ�(����)",
["Normal Items/Smite"] = "��ͨ��Ʒ/�ͽ�",
["Use Zhonyas/Seraphs Before Death"] = "����֮ǰʹ�����/����ʹ",
["OFF"] = "�ر�",
["Summoner Exhaust"] = "����",
["Exhaust Key"] = "��������",
---------------Feez Jayce-------------
["Jayce"] = "Feez��˹",
["Script version:"] = "�汾��:",
["Combo active"] = "����",
["Spells"] = "����",
["Q1 (Hammer)"] = "Q - ����̬",
["W1 (Hammer)"] = "W - ����̬",
["E1 (Hammer)"] = "E - ����̬",
["R1 (Hammer)"] = "R - ����̬",
["Q2 (Cannon)"] = "Q - ����̬",
["W2 (Cannon)"] = "W - ����̬",
["E2 (Cannon)"] = "E - ����̬",
["R2 (Cannon)"] = "R - ����̬",
["Harass active"] = "ɧ��",
["Use Cannon Q"] = "ʹ������̬Q",
["Use Cannon E->Q"] = "ʹ������̬EQ",
["-> Switch stance to E->Q"] = "-> �л���̬��ʹ��EQ",
["Use Cannon W"] = "ʹ������̬W",
["Only when mana above %"] = "������������%",
["Use Hammer Q"] = "ʹ�ô���̬Q",
["Use Hammer W"] = "ʹ�ô���̬W",
["Use Hammer E"] = "ʹ�ô���̬E",
["Orbwalk"] = "�߿�",
["Orbwalker"] = "�߿�",
["Interrupter"] = "���ܴ��",
["Switch stance to interrupt spells"] = "�л���̬����ϼ���",
["Wall Hop"] = "��ǽ",
["Wall hop"] = "��ǽ",
["Hit minions with Hammer E"] = "��С��ʹ�ô���̬E",
["Reveal minions with Cannon Q"] = "ʹ������̬Q���С����Ұ�ֵ���Ұ",
["Champions"] = "Ӣ��",
["Use flash"] = "ʹ������",
["Jungle Steal"] = "��Ұ��",
["Switch stance to steal"] = "�л���̬����Ұ��",
["Snipe"] = "��ɱ",
["Snipe mode"] = "��ɱģʽ",
["Automatic mechanics"] = "",
["Cannon E->Q snipe to mouse"] = "����긽���ĵ���ʹ������̬EQ��ɱ",
[" -> Enabled"] = "-> ����",
["Stack tear/manamune"] = "��Ů��֮��/ħ��",
["Flee mode"] = "����ģʽ",
["PermaShow Menu"] = "״̬��ʾ�˵�",
["Combo range"] = "���з�Χ",
["Thunderlord's Decree indicator circle"] = "���������ķ���ָʾ����Ȧ",
["Ranges"] = "��Χ",
["Hammer Q"] = "����̬Q",
["Hammer E"] = "����̬E",
["Cannon Q"] = "����̬Q",
["Cannon E->Q Range"] = "����̬EQ��Χ",
["Move Left/Right"] = "�����ƶ�",
["Move Up/Down"] = "�����ƶ�",
["Reset"] = "�ָ�Ĭ������",
["Jayce - Prediction Manager"] = "Feez��˹ - Ԥ�й�����",
["Load all predictions on start"] = "��ʼʱ��������Ԥ��",
["Prediction:"] = "Ԥ��",
["Hit Chance:"] = "������",
["1: Low"] = "1: ��",
["2: High"] = "2: ��",
["3: Target too slow or close"] = "3: Ŀ��������߹���",
["4: Target immobile"] = "4: Ŀ��̫Զ",
["5: Target dashing or blinking"] = "5: Ŀ������ʹ��λ�Ƽ��ܻ�����",
["Accelerated Q"] = "���ٵ�Q",
["No interruptable spells"] = "û�пɴ�ϵļ���",
["Dashes and Jumps"] = "λ�ƺ���Ծ",
["Interrupt Ezreal"] = "����������",
["Priorities"] = "���ȼ�",
["Ezreal"] = "�������",
["Loading..."] = "������...",
["Muramana"] = "ħ��",
["Twin Shadows"] = "˫����Ӱ",
["Tiamat or Hydra"] = "��������/��ͷ��",
["BORK"] = "�ư�����֮��",
["Baron Nashor"] = "��ʲ�о�",
["Snipe Ezreal"] = "��ɱ�������",
["Insec Ezreal"] = "Insec�������",
--------------------Feez Lissandra-------------
["Lissandra - Blood Diamond"] = "Feez��ɣ׿",
["Melt: Combo"] = "����������(��Ŀ���ͷ����м���)",
["Safe-Melt: Combo"] = "����+�Ա�����(E����+R�Լ�)",
["Flee (no 2nd E while combo)"] = "����(����ʱ��ʹ�ö���E)",
["Smart KS"] = "��������ͷ",
["Melt"] = "����������",
["Use First E"] = "ʹ��һ��E",
["Use Second E"] = "ʹ�ö���E",
["Only ult when combo killable"] = "ֻ���ܻ�ɱĿ��ʱʹ��R",
["Safe-Melt"] = "�����Ա�����",
["least # of enemies to initiate"] = "���������ܿ���x������",
["Use E (only first)"] = "����ʹ��E",
["Mana % must be > than:"] = "�����������x%",
["Minimum E minions:"] = "������E�е�С����",
["Minimum Q minions:"] = "������Q�е�С����",
["2nd Keybind Key"] = " ",
["2nd Keybind Enabled"] = " ",
["least # of enemies to auto W"] = "������x������ʱ�Զ�W",
["Jump Spots Color:"] = "Eλ���յ���ɫ",
["Q Range"] = "Q���ܷ�Χ",
["W range"] = "W���ܷ�Χ",
["E range"] = "E���ܷ�Χ",
["R range"] = "R���ܷ�Χ",
["W Range"] = "W���ܷ�Χ",
["E Range"] = "E���ܷ�Χ",
["R Range"] = "R���ܷ�Χ",
["Color:"] = "��ɫ:",
["Last second E"] = "E��Զ����λ��",
["Lissandra - Prediction Manager"] = "��ɣ׿ - Ԥ�й���",
["Udyr"] = "�ڵ϶�",
---------------------Feez����---------------
["Annie the UnBEARable"] = "Feez����",
["Use Flash when Killable"] = "��Ŀ��ɱ���ɱʱʹ������",
["Block AAs out of range [when spells ready]"] = "�����ܿ���ʱ��ƽA",
["Combo Order"] = "����˳��",
["Wait for Q hit"] = "�ȴ�Q��������",
["^^Will combo when q hits"] = "^^������Q���е�ʱ���������",
["Only for Q-W-R or Q-R-W"] = "ֻ��Q-W-R��Q-R-W��Ч",
["Ult"] = "����",
["Use Ult"] = "ʹ�ô���",
["Allow KS with ult"] = "����ʹ�ô�������ͷ",
["Ult on"] = "ʹ�ô��е�Ŀ��",
["Use Stun"] = "ʹ���Զ�ѣ��",
["Auto Stun enemies focused by tower"] = "�Զ�ѣ�α������������ĵ���",
["Use W [Auto Stun]"] = "ʹ��W(�Զ�ѣ��)",
["Use Ult [Auto Stun]"] = "ʹ��R(�Զ�ѣ��)",
["Minimum enemies to auto stun"] = "�Զ�ѣ�ε���С������",
["Auto Farm"] = "�Զ�����",
["Auto Farm with Q"] = "�Զ�ʹ��Q����",
["Auto reactivate farm mode"] = "�Զ���������ģʽ",
["Toggle continuous farm"] = "����ģʽ����״̬��ʾ",
["Stack to:"] = "�Զ�����������",
["1 Stack"] = "1��",
["2 Stacks"] = "2��",
["3 Stacks"] = "3��",
["4 Stacks [Stun]"] = "4��[ѣ��]",
["Auto Shield"] = "�Զ�����",
["Turn off E stack for better results"] = "�ر�E�����ܱ���",
["Draw combo range"] = "��ʾ���з�Χ",
["Draw flash + combo range"] = "��ʾ�������з�Χ",
["Draw circle under TS target"] = "��ѡ����Ŀ���»�Ȧ",
["Draw killable text on target"] = "��Ŀ��������ʾ�ɻ�ɱ��ʾ",
["Draw timer of tibbers on yourself"] = "���Լ�������ʾ�Ხ˹��ʱ��",
["Draw Tibbers target text on tibbers"] = "���Ხ˹������ʾ��������Ŀ��",
["Draw stun sprite"] = "��ʾѣ��ͼ��",
["Text draw fix"] = "�޸�������ʾ",
["Auto control & orbwalk tibbers"] = "�Զ������Ხ˹",
["Tibbers follow toggle"] = "�Ხ˹����״̬��ʾ",
["Passive"] = "����",
["Stack passive:"] = "�Զ��ܱ���:",
["In Spawn"] = "��Ȫˮ",
["Add Stack [*]"] = "���ӱ�������[*]",
["Subtract Stack [-]"] = "���ٱ�������[-]",
["Annie - Prediction Manager"] = "���� - Ԥ�й�����",
-----------------Feez����------------
["Ahri - Sexy Mistress"] = "Feez����",
["Smart auto ignite"] = "�����Զ���ȼ",
["Q Catch"] = "ʹ��Q׷��",
["Use R for Q return"] = "ʹ��R����Q����λ��",
["Catch mode"] = "׷��ģʽ",
["Flexible"] = "����",
["Tight"] = "��׷���ŵ�",
["Use when health % >="] = "������ֵ���ڵ���x%ʱʹ��",
["Use to initiate"] = "��������",
["Use default logic"] = "ʹ��Ĭ���߼�",
["Randomize ult distance"] = "����Ĵ���λ�ƾ���",
["Harass KeyDown"] = "ɧ�Ű���",
["^Only when mana above %"] = "^������������%",
["Flee active"] = "����ģʽ����",
["Last Hit [Q]"] = "β�� [Q]",
["Minimum to last hit"] = "��β��������С����",
["Minimum laneclear with passive"] = "�����������ߵ�����С����",
["^Only when health below %"] = "^��������ֵС��%",
["Spell hit spots"] = "�������е�",
["Passive sprite"] = "����ͼ����ʾ",
["Q orb"] = "Q���ܵ���",
["Ahri - Prediction Manager"] = "���� - Ԥ�й���",
["Prioritize selected target"] = "��������ѡ����Ŀ��",
["Ult mode"] = "����ģʽ",
["Move to mouse"]= "�ƶ������λ��",
["NebelwolfisMoonWalker"] = "Nebelwolfi�߿�",
["Harass Mode"] = "ɧ��ģʽ",
["Mouse over Hero to stop move"] = "Ӣ���������ʱֹͣ�ƶ�",
["Melee Settings"] = "��ս����",
["Walk/Stick to target"] = "����Ŀ��",
["Sticky radius to target"] = "����Ŀ��뾶",
------------------Forbidden Ahri Kassadin Twisted Fate Ryze----------------
["Challenger Ahri Reborn by Da Vinci"] = "��ս���е��ϼ� - ����",
["Ahri - Target Selector Settings"] = "[����] - Ŀ��ѡ��������",
["Ahri - General Settings"] = "[����] - ��������",
["Catch the Q with Movement"] = "�ƶ�������Q�ĵ���",
["Ahri - Combo Settings"] = "[����] - ��������",
["Catch the Q with R"] = "ʹ��R����Q�ĵ���",
["Give Priority to Catch the Q with R"] = "����ʹ��R����Q�ĵ���",
["Use Ignite If Killable "] = "���ɻ�ɱʱʹ�õ�ȼ",
["Ahri - Harass Settings"] = "[����] - ɧ������",
["Ahri - LaneClear Settings"] = "[����] - ��������",
["Use W If Minions >= "] = "��С�����ڵ���xʱʹ��W",
["Ahri - JungleClear Settings"] = "[����] - ��Ұ����",
["Ahri - LastHit Settings"] = "[����] - β������",
["Never"] = "�Ӳ�",
["Ahri - KillSteal Settings"] = "[����] - ����ͷ����",
["Ahri - Auto Settings"] = "[����] - �Զ�����",
["Use E To Interrupt"] = "ʹ��E���ܴ��",
["Ahri - Draw Settings"] = "[����] - ��ʾ����",
["Path to Catch the Q"] = "����Q������·��",
["Line for Q Orb"] = "Q���ܵ���ָʾ��",
["Ahri - Keys Settings"] = "[����] - ��������",
["Start with E (Toggle)"] = "����E����(����)",

["Forbidden Kassadin by Da Vinci"] = "��ս���е��ϼ� - ������",
["Kassadin - Target Selector Settings"] = "[������] - Ŀ��ѡ��������",
["Kassadin - General Settings"] = "[������] - ��������",
["Kassadin - Combo Settings"] = "[������] - ��������",
["Kassadin - Harass Settings"] = "[������] - ɧ������",
["Kassadin - LaneClear Settings"] = "[������] - ��������",
["Kassadin - JungleClear Settings"] = "[������] - ��Ұ����",
["Kassadin - LastHit Settings"] = "[������] - β������",
["Kassadin - KillSteal Settings"] = "[������] - ����ͷ����",
["Kassadin - Drawing Settings"] = "[������] - ��ʾ����",
["Kassadin - Keys Settings"] = "[������] - ��������",

["Diana The Dark Eclipse by Da Vinci"] = "��ս���е��ϼ� - ������",
["Diana - Target Selector Settings"] = "[������] - Ŀ��ѡ��������",
["Range for Combo"] = "����ʹ�÷�Χ",
["Diana - General Settings"] = "[������] - ��������",
["Diana - Combo Settings"] = "[������] - ��������",
["Use R On Enemies Marked"] = "�Ա�ǵĵ���ʹ��R",
["Use QR on Object To GapClose"] = "��Ŀ��ʹ��QR��ͻ������",
["Diana - Harass Settings"] = "[������] - ɧ������",
["Diana - LaneClear Settings"] = "[������] - ��������",
["Use E If Hit >="] = "�������д��ڵ���x������ʱʹ��E",
["Diana - JungleClear Settings"] = "[������] - ��Ұ����",
["Diana - LastHit Settings"] = "[������] - β������",
["Diana - KillSteal Settings"] = "[������] - ����ͷ����",
["Diana - Auto Settings"] = "[������] - �Զ�����",
["Diana - Draw Settings"] = "[������] - ��ʾ����",
["Diana - Keys Settings"] = "[������] - ��������",

["Forbidden TwistedFate by Da Vinci"] = "��ս���е��ϼ� - ��˹��",
["TwistedFate - Target Selector Settings"] = "[������] - Ŀ��ѡ��������",
["Range for Harass"] = "ɧ��ʹ�÷�Χ",
["TwistedFate - General Settings"] = "[������] - ��������",
["Select gold card after R"] = "R����֮���Զ��л���",
["TwistedFate - Combo Settings"] = "[������] - ��������",
["Use Q If Hit >="] = "���ܻ��д��ڵ���x����λʱʹ��Q",
["Use Gold Card"] = "ʹ�û���",
["Use Blue Card If Mana Percent <= "] = "����С�ڵ���x%ʱ������",
["TwistedFate - Harass Settings"] = "[������] - ɧ������",
["Priorize Farm over Harass"] = "����������ɧ��",
["TwistedFate - LaneClear Settings"] = "[������] - ��������",
["Use Q If Mana Percent >= "] = "���������ڵ���%ʱʹ��Q",
["Use Red Card If Hit >= "] = "���ܻ��д��ڵ���x����λʱʹ�ú���",
["Red Card If Mana Percent >= "] = "�����������%ʹ�ú���",
["Use Blue"] = "ʹ������",
["TwistedFate - JungleClear Settings"] = "[������] - ��Ұ����",
["Use Red"] = "ʹ�ú���",
["Use Red Card If Mana Percent >= "] = "�����������%ʹ�ú���",
["TwistedFate - LastHit Settings"] = "[������] - β������",
["TwistedFate - KillSteal Settings"] = "[������] - ����ͷ����",
["TwistedFate - Auto Settings"] = "[������] - �Զ�����",
["Use Gold Card To Interrupt Channelings"] = "ʹ�û��ƴ�������ͼ���",
["Use Gold Card To Interrupt GapClosers"] = "ʹ�û��ƴ��ͻ����",
["TwistedFate - Drawing Settings"] = "[������] - ��ʾ����",
["TwistedFate - Keys Settings"] = "[������] - ��������",
["Start with Card (Toggle)"] = "��������(����)",
["Select Blue Card (Default: F1)"] = "������(Ĭ��F1)",
["Select Red Card (Default: F2)"] = "�к���(Ĭ��F2)",
["Select Gold Card (Default: F3)"] = "�л���(Ĭ��F3)",
["Extra WindUpTime"] = "�����ҡʱ��",
["Farm Delay"] = "�����ӳ�ʱ��",

["Wizard by Da Vinci"] = "��ս���ϵ��ϼ� - ����",
["QP Settings"] = "ǿ��Q��������",
["Ryze - Target Selector Settings"] = "[����] - Ŀ��ѡ��������",
["Ryze - General Settings"] = "[����] - ��������",
["Ryze - Combo Settings"] = "[����] - ��������",
["Use Q no Collision"] = "ʹ��Qʱ�������ײ",
["Ryze - Harass Settings"] = "[����] - ɧ������",
["Ryze - LaneClear Settings"] = "[����] - ��������",
["Ryze - JungleClear Settings"] = "[����] - ��Ұ����",
["Ryze - KillSteal Settings"] = "[����] - ����ͷ����",
["Ryze - Auto Settings"] = "[����] - �Զ�����",
["Use W To Interrupt"] = "ʹ��W�����",
["Ryze - Draw Settings"] = "[����] - ��ʾ����",
["Ryze - Keys Settings"] = "[����] - ��������",
["Delay for LastHit (in ms)"] = "β���ӳ�(����)",
--------------SAC-----------------------
["Stream Mode"] = "����ģʽ",
["Green"] = "��ɫ",
["When In Range"] = "���ڷ�Χ��ʱ",
["Q (Tumble)"] = "Q(����ͻϮ)",
["Last Hit Only"] = "ֻ��β��ʹ��",
["R (Final Hour)"] = "R(�ռ�ʱ��)",
[" Only orbwalk who I attack "] = "ֻ��������ڹ�����Ŀ��",
[" Only orbwalk my selected target "] = "ֻ�����ѡ����Ŀ��",
[" Choose best target in scan range (set below)"] = "��һ����Χ��ѡ�����Ŀ��(�������趨)",
[" Orbwalk who I attack if possible, otherwise selected target"] = "�ڿ���ʱֻ��������ڹ�����Ŀ��,���򹥻�ѡ����Ŀ��",
[" Orbwalk who I attack if possible, otherwise best in scan range"] = "�ڿ���ʱֻ��������ڹ�����Ŀ��,���򹥻���Χ�����Ŀ��",
[" Always "] = "����",
[" AutoCarry mode "] = "�Զ��������ģʽ",
[" Any mode"] = "�κ�ģʽ",
["  Last Hit Earlier  "] = "����β��",
["  Last Hit Later  "] = "�Ƴ�β��",
["  Cancel Earlier  "] = "����ȡ��",
["  Cancel Later  "] = "�Ƴ�ȡ��",
["Server Delay: 100ms"] = "�������ӳ�: 100����",
["Sida's Auto Carry: Vayne"] = "SAC:ޱ��",
["Allowed Condemn Targets"] = "����ѣ�ε�Ŀ��",
["Toggle Mode (Requires Reload)"] = "����ģʽ(��Ҫ���¼���)",
["Auto-Condemn"] = "�Զ�E",
["Auto-Condemn Gap Closers"] = "�Զ��ƿ�ͻ����",
["Max Condemn Distance"] = "����ƿ�����",
["Only condemn Reborn target"] = "ֻ�ƿ�SACѡ����Ŀ��",
["Condemn Adjustment:"] = "E���ܵ���:",
["Disable attacks during ult stealth"] = "�ڴ������������²�ƽA",
["Wall Detection Method"] = "ǽ���ⷽʽ",
["IsWall"] = "IsWall����",
["Guess (for when IsWall breaks in BoL)"] = "�²�(��IsWall�޷�ʹ��ʱ)",
["              Sida's Auto Carry: Reborn"] = "              Sida�߿�",
["No mode active"] = "��ģʽ",
["Skill Farm"] = "���ܷ���",
["TARGET LOCK"] = "Ŀ������",
["Auto-Condemn"] = "�Զ�E",
["      Active"] = "    ����",
["      "] = "    ����",
["Move to Mouse"] = "�ƶ������λ��",
["SAC Detected"] = "��⵽SAC",
["Combat keys are connected to your SAC:R keys"] = "���а�����SAC�����а�����",
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
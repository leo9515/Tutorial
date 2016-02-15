local version = "0.0215"
local AAAautoupdate = false
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

local tranTable = {["Menu"] = "菜單",
["press key for Menu"] = "設定新的菜單按鈕...",
[" "] = " ",
["-"] = "-",
["NOW"] = "NOW",
["SOW"] = "SOW",
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
["    1 - Use vs Normal Skillshots"] = "1 - 遇到壹般技能攻擊使用",
["2..4 - Use vs More Dangerous / CC"] = "2..4 - 遇到較危險技能及控制技能使用",
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
["Here you can allow other scripts"] = "這�堜p可以使用其他腳本",
["to enable/disable and control Evadeee."] = "使用/禁用和控制EVADEEE",
["Allow enabling/disabling evading"] = "允許使用/禁用躲避",
["Allow enabling/disabling Bot Mode"] = "允許使用/禁用機器人模式",
["WARNING:"] = "警告",
["By switching this ON/OFF - Evadeee"] = "轉換開和關",
["will reset all your settings:"] = "重置所有設定",
["Restore default settings"] = "恢複默認設置",
["Enabled"] = "使用",
["Ignore with dangerLevel >="] = "忽略危險等級",
["    1 - Use vs everything"] = "1 - 任何時候都使用",
["2..4 - Use only vs More Dangerous / CC"] = "2..4 - 僅在較危險技能及控制技能使用",
["    5 - Use only vs Very Dangerous"] = "5 - 僅在遇到非常危險技能時使用",
["Delay before evading (ms)"] = "躲避前延遲（毫秒）",
["Ignore evading delay if you move"] = "如果妳在移動忽略躲避前延遲",
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
["This setting will force evade in the"] = "這個設置會朝著遠離",
["direction away from enemy team."] = "敵人移動方向強制躲避",
["This will ignore your main anchor"] = "這會忽略妳的主定位",
["only when there are enemies nearby."] = "只在附近有敵人時",
["Attempt to dodge spells from FoW"] = "嘗試躲避從沒有視野的地方攻擊妳的法術",
["Dodge if your HP <= X%: "] = "在妳的血量小于X%時躲避",
["Dodge <= X normal spells..."] =	 "在小于等于X個普通法術攻擊妳時躲避",
["... in <= X seconds"] =	 "在小于等于X秒內",
["Disable evading by idling X sec:"] = "在妳挂機X秒後自動禁用躲避",
["Better dodging near walls"] = "牆附近更好的躲避路線",
["Better dodging near turrets"] = "敵人防禦塔附近更好的躲避路線",
["Handling danger blinks and dashes:"] = "瞬移和突進時躲避危險",
["Angle of the modified cast area"] = "躲避危險的角度",
["Blink/flash over missile"] = "瞬移或突進到小兵身邊躲避攻擊",
["Delay between dashes/blinks (ms):"] = "瞬移或猛沖的延遲(ms)",
["Dash/Blink/Flash Mode:"] = "瞬移或突進或閃現的模式",
["Note:"] = "注意",
["While activated, this mode overrides some of"] = "當妳激活這個功能時可能會覆蓋",
["the settings, which you can modify here."] = "壹些妳其他的在這�堶蚹麊熙]置",
["Usually this is used together with SBTW."] = "壹般情況下和自動走砍開關",
["To change the hotkey go to \"Controls\"."] = "在控制設置中設置熱鍵",
["Dodge \"Only Dangerous\" spells"] = "僅躲避危險技能",
["Evade towards anchor only"] = "躲避時只向前定位",
["Ignore circular spells"] = "忽略圓形技能",
["Use dashes more often"] = "更多的使用瞬移",
["To change controls just click here   \\/"] = "點這�堥荍幭亃惆豲]置",
["Evading        | Hold"] = "按住躲避",
["Evading        | Toggle"] = "按下躲避開關使直到在次按下停止",
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
["If you choose 1 key for Quick Menu"] = "如果妳選擇按鍵1作為快捷鍵",
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
["Blitzcrank | Q - Rocket Grab"] = "布�堹� | Q - 機械飛爪",
["On / Off [Permanent]"] = "開 / 關 [永久生效]",
["On / Off [This session]"] = "開 / 關 [當局遊戲生效]",
["Dodging Mode"] = "躲避模式",
["Normal"] = "普通",
["Prefer dashes/blinks/spellshields"] = "優先使用位移/閃現/護盾",
["Only dashes/blinks/spellshields"] = "只使用位移/閃現/護盾",
["Draw this spell"] = "顯示技能",
["Extra Width: "] = "額外寬度",
["Attempt to dodge from FoW"] = "嘗試躲避戰爭迷霧�堛漣獊�",
["Allow casting while evading"] = "躲避的時候允許使用技能",
["Don't dodge from inside"] = "已在技能範圍�堮氻ㄧ�避",
["Consider it dangerous"] = "判定此技能危險",
["    0 - Don't use dashes"] = "    0 - 不要使用位移",
["    1 - Use low CD spells"] = "    1 - 使用短cd技能",
["2..4 - Use more spells"] = "2..4 - 使用更多技能",
["    5 - Use flash"] = "    5 - 使用閃現",
["Blitzcrank | R - Static Field"] = "布�堹� | R - 靜電力場",
["Simple"] = "簡單",
["Advanced"] = "高級",
["\"Smooth\" Diagonal Evading"] = "平滑斜線躲避",
["Last Destination"] = "最後面向的方向",
["Mouse Position"] = "鼠標位置",
["Hero Position"] = "英雄位置",
["Allow Casting"] = "允許技能使用",
["Block Casting"] = "屏蔽技能使用",
["Modify/Block [Any direction]"] = "修正/屏蔽 [任何方向]",
["Modify/Block [Only towards cast position]"] = "修正/屏蔽 [順著技能的方向]",
["Modify/Allow [Any direction]"] = "修正/允許 [任何方向]",
["Modify/Allow [Only towards cast position]"] = "修正/允許 [順著技能的方向]",
["Minimum Range"] = "最小範圍",
["Maximum Range"] = "最大範圍",
["Randomized Range"] = "隨機大小範圍",
["Dodge \"Only Dangerous\" spells"] = "只躲避危險技能",
["To change the hotkey go to \"Controls\"."] = "在\"控制\"�堶蚹嚗鶬�",
["Disable"] = "關閉",
["Arrow"] = "箭頭",
["Arrow [Outlined]"] = "箭頭 [輪廓]",
["Show \"Doubleclick to remove!\""] = "顯示\"雙擊移除躲避區域\"",
["Very Low"] = "非常低",
["Low"] = "低",
["Mid"] = "中",
["Very High"] = "很高",
["Ultra"] = "極限",
["Danger level: "] = "危險等級",
["Dodge <= X danger spells..."] = "在小于等于X個危險技能攻擊妳時躲避",
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
["Normal minions"] = "壹般小兵",
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
["      Against Champions"] = "與妳戰鬥的地方英雄",
["Use In Auto Carry"] = "在自動連招輸出模式使用",
["Use In Mixed Mode"] = "在混合模式使用",
["Use In Lane Clear"] = "在清線模式使用",
["Killsteal"] = "搶人頭",
["Auto Carry minimum % mana"] = "如果魔法少于%則不開啟自動連招輸出模式",
["Mixed Mode minimum % mana"] = "如果魔法少于%則不開啟混合模式",
["Lane Clear minimum % mana"] = "如果魔法少于%則不開啟清線模式",
["      Skill Farm"] = "技能刷兵",
["Lane Clear Farm"] = "清線刷兵",
["Jungle Clear"] = "刷野",
["TowerFarm"] = "塔下刷兵",
["Skill Farm Min Mana"] = "使用技能刷兵魔法不低于",
["(when enabled)"] = "當使時",
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
["Prioritise Last Hit Over Harass"] = "補刀優先于騷擾",
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
["Save BotRK for max heal"] = "保留破敗以獲得最大治療",
["Use Muramana [Champions]"] = "對英雄使用魔切",
["Use Muramana [Minions]"] = "對小兵使用魔切",
["Use Tiamat/Hydra to last hit"] = "使用提亞馬特或者九頭蛇完成最後壹擊",
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
["Shaco's Clone"] = "小醜克隆",
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
["Draw Last Hit Arrows"] = "最後壹擊圖形提醒",
["Always Draw Modified Health Bars"] = "壹直顯示血條調整",
["Always Draw Last Hit Arrows"] = "壹直顯示最後壹擊圖形提醒",
["Sida's Auto Carry"] = "Sida走砍",
["Setup"] = "設置",
["Hotkeys"] = "快捷鍵",
["Configuration"] = "配置",
["Target Selector"] = "目標選擇",
["Skills"] = "技能",
["Items"] = "物品",
["Farming"] = "刷兵",
["Melee"] = "近戰",
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
["Last Hit Mode"] = "最後壹擊補刀模式",
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
["Cleanse Debug"] = "淨化調試",
["Debug Mode (Cleanse): "] = "調試模式(淨化)",
["Font Size Cleanse"] = "淨化字體大小",
["X Axis Draw Cleanse Debug"] = "淨化顯示X軸位置",
["Y Axis Draw Cleanse Debug"] = "淨化顯示Y軸位置",
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
["Use Biscuit"] = "自動吃餅幹",
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
["Cleanse Item Config"] = "淨化設置",
["Stuns"] = "眩暈",
["Silences"] = "沈默",
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
["Use Ohmwrecker"] = "使用幹擾水晶",
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
["Cleanse Self"] = "淨化類物品",
["Use Self Item Cleanse"] = "使用淨化類物品",
["Use Quicksilver Sash"] = "使用水銀飾帶",
["Use Mercurial Scimitar"] = "使用水銀彎刀",
["Use Dervish Blade"] = "使用苦行僧之刃",
["Cleanse Dangerous Spells"] = "淨化危險的技能",
["Cleanse Extreme Spells"] = "淨化極端危險的技能",
["Min Spells to use"] = "最少擁有X種減益效果才使用",
["Debuff Duration Seconds"] = "減益效果持續時間",
["Shield/Boost Ally"] = "給友軍使用護盾/加速",
["Use Support Items"] = "使用輔助物品",
["Use Locket of Iron Solari"] = "鋼鐵烈陽之匣",
["Locket of Iron Solari Life Saver"] = "生命值低于X時使用鋼鐵烈陽之匣",
["Use Talisman of Ascension"] = "飛升護符",
["Use Face of the Mountain"] = "山嶽之容",
["Face of the Mountain Life Saver"] = "生命值低于X時使用山嶽之容",
["Use Guardians Horn"] = "守護者的號角",
["Life Saving Health %"] = " 生命值低于X%",
["Mikael Cleanse"] = "米凱爾的坩堝",
["Use Mikael's Crucible"] = "使用坩堝",
["Mikaels cleanse on Ally"] = "對友軍使用坩堝",
["Mikaels Life Saver"] = "生命低于X%時使用坩堝",
["Ally Saving Health %"] = "友軍生命值低于X%",
["Self Saving Health %"] = "自己生命值低于X%",
["Min Spells to use"] = "最少擁有X種減益效果才使用",
["Set Debuff Duration"] = "設置減益效果持續時間",
["Champ Shield Config"] = "英雄護盾設置",
["Champ Cleanse Config"] = "英雄淨化設置",
["Shield Ally Vayne"] = "對友軍薇恩使用護盾",
["Cleanse Ally Vayne"] = "對友軍薇恩使用淨化",
["Show In Game"] = "在遊戲中顯示",
["Show Version #"] = "顯示版本號",
["Show Auto Pots"] = "顯示自動藥水",
["Show Use Auto Pots"] = "顯示使用自動藥水",
["Show Use Health Pots"] = "顯示自動血藥",
["Show Use Mana Pots"] = "顯示自動藍藥",
["Show Use Flask"] = "顯示自動魔瓶",
["Show Offensive Items"] = "顯示攻擊型物品",
["Show Use AP Items"] = "顯示使用AP物品",
["Show AP Item Mode"] = "顯示AP物品模式",
["Show Use AD Items"] = "顯示使用AD物品",
["Show AD Item Mode"] = "顯示AD物品模式",
["Show Defensive Items"] = "顯示防禦物品",
["Show Use Self Shield Items"] = "顯示對自己使用護盾類物品",
["Show Use Debuff Enemy"] = "顯示對地方使用減益效果",
["Show Self Item Cleanse "] = "顯示對自己使用淨化",
["Show Use Support Items"] = "顯示使用輔助物品",
["Show Use Ally Cleanse Items"] = "顯示對友軍使用淨化類物品",
["Show Use Banner"] = "顯示使用號令之旗",
["Show Use Zhonas"] = "顯示使用中亞",
["Show Use Wooglets"] = "顯示使用沃格勒特的巫師帽",
["Show Use Z/W Lifeaver"] = "顯示使用中亞的觸發生命值",
["Show Z/W Dangerous"] = "顯示使用中亞的危險程度",
["DeklandAIO: Orianna"] =  "神系列合集：奧利安娜",
["DeklandAIO Version: "] =  "神系列合集版本號：",
["Auth Settings"] =  "腳本驗證設置",
["Debug Auth"] =  "調試驗證",
["Fix Auth"] =  "修複驗證",
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
["Use Lantern Whilst Hooked"] = "勾中的同時使用燈籠",
["Use Lantern - Grab Ally"] = "對友軍使用燈籠",
["Use Lantern - Self"] = "對自己使用燈籠",
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
["No. Facing Enemies"] = "範圍內有x名面朝妳的敵人",
["Ult Chogath"] = "對科加斯使用大招",
["Auto E Poison Minions"] = "自動E中毒的小兵",
["Check On Dash Chogath"] = "檢查科加斯的突進",
["Draw R Prediction"] = "顯示R的預判",
["Draw Poison Targets"] = "顯示中毒的目標",
["DeklandAIO: Xerath"] = "神系列合集：澤拉斯",
["Set Priority Nidalee"] = "設定奈德麗的優先級",
["Ult Tap (fires 'One' on release)"] = "大招按鍵(按壹次放壹個R)",
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
["Buffer distance (Default value = 10)"] = "緩沖距離(默認10)",
["Ignore which is about to die"] = "忽略將要死亡的目標",
["Script version: "] = "腳本版本號",
["DivinePrediction"] = "神聖預判",
["Min Time in Path Before Predict"] = "預判路徑的最小時間",
["Central Accuracy"] = "中心精准度",
["Debug Mode [Dev]"] = "調試模式[開發者]",
["Cast Mode"] = "釋放模式",
["Fast"] = "快",
["Slow"] = "慢",
["Collision"] = "碰撞",
["Collision buffer"] = "碰撞緩沖",
["Normal minions"] = "普通小兵",
["Jungle minions"] = "野怪",
["Others"] = "其他",
["Check if minions are about to die"] = "檢查即將死亡的小兵",
["Check collision at the unit pos"] = "檢查單位位置的碰撞",
["Check collision at the cast pos"] = "檢查釋放位置的碰撞",
["Check collision at the predicted pos"] = "檢查預判位置的碰撞",
["Developers"] = "開發者",
["Enable debug"] = "使調試",
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
["Enable draw of target (circle)"] = "使顯示目標(線圈)",
["Target circle color"] = "目標線圈顏色",
["Enable draw of target (text)"] = "使顯示目標(文字)",
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
["Use Refillable Potion"] = "使用複用型藥水",
["Use Hunters Potion"] = "使用獵人藥水",
["Use Corrupting Potion"] = "使用腐敗藥水",
["Corrupting Potion DPS in Combat"] = "在戰鬥中使用腐敗藥水增加傷害",
["Absolute Min Health %"] = "絕對生命值最小百分比",
["In Combat Min Health %"] = "戰鬥中生命值最小百分比",
["QSS & Cleanse"] = "水銀 & 淨化",
["Enable auto cleanse enemy debuffs"] = "使自動淨化",
["Settings for debuffs"] = "減益效果設置",
["- Global delay before clean debuff -"] = "自動淨化的全局延遲",
["Global Default delay"] = "全局默認延遲",
["- Usual debuffs -"] = "-常規減益效果-",
["Cleanse if debuff time > than (ms):"] = "如果減益效果時間大于..使用淨化",
["- Slow debuff -"] = "- 減速 -",
["Cleanse if slow time > than (ms):"] = "如果減速時間大于..使用淨化",
["- Special cases -"] = "- 特殊情況 -",
["Remove Zed R mark"] = "解劫的大招",
["Extra Awaraness"] = "額外意識",
["Enable Extra Awaraness"] = "使額外意識",
["Warning Range"] = "警告的範圍",
["Draw even if enemy not visible"] = "即使敵人隱身也線束",
["Security & Humanizer"] = "安全&擬人化",
["------------ SECURITY ------------"] = "------------ 安全 ------------",
["Enabling this, you will limit all functions"] = "使此設置，會限制僅當敵人在妳的",
["to only trigger them if enemy/object"] = "屏幕上時所有功能才生效",
["is on your Screen"] = " ",
["Enable extra Security mode"] = "使額外安全設置",
["------------ HUMANIZER ------------"] = "------------ 擬人化 ------------",
["This will insert a delay between spells"] = "這項設置將會在妳的連招中間加入延遲",
["If you set too high, it will make combo slow,"] = "如果妳將數值設定的過高，連招會變慢",
["so if you use it increase it gradually!"] = "所以如果妳要使用的話，請慢慢增加數值",
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
["Use Spell Flux (E)"] = "使用法術湧動(E)",
["Use Overload (Q) for last hit"] = "使用Q來補尾刀",
["Min Mana % to use Harass"] = "騷擾的最小藍量 %",
["Auto kill"] = "自動擊殺",
["Enable Auto Kill"] = "使自動擊殺",
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
["Enable Draws"] = "使顯示",
["Draw Q range"] = "顯示Q範圍",
["Q color"] = "Q線圈顏色",
["Draw W-E range"] = "顯示W-E範圍",
["W-E color"] = "W-E線圈顏色",
["Draw Stacks"] = "顯示被動層數",
["Use Lag Free Circle"] = "使用不影響延遲的線圈",
["Kill Texts"] = "擊殺提示",
["Use KillText"] = "使擊殺提示",
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
["Cast when our HP less than %"] = "當生命值小于%時使用R",
["Cast before KS with Q when lower than"] = "在用Q搶人頭之前使用R",
["Riposte Options"] = "勞倫特心眼刀(W)設置",
["Riposte Enabled"] = "使用W",
["Save Q Evadeee when Riposte cd"] = "當Wcd時保留Q來躲避",
["Auto Parry next attack when %HP <"] = "當生命值小于%時自動格擋下壹次普通攻擊",
["Humanizer: Extra delay"] = "擬人化：額外延遲",
["Parry Summoner Spells (low latency)"] = "格擋召喚師技能(低延遲)",
["Parry Dragon Wind"] = "格擋小龍的攻擊",
["Parry Auto Attacks"] = "格擋普通攻擊",
["Parry AA Damage Threshold"] = "格擋平A的傷害臨界值",
["Parry is still a Work In Progress"] = "格擋功能是仍在開發的功能",
["If is not parrying a spell from the list,"] = "如果沒有格擋列表中的技能",
["before report on forum, make a list like:"] = "在論壇報告之前，寫壹個像下面壹樣的列表",
["Champion-Spell that fails to parry"] = "格擋失敗的技能：如果妳有大于20個",
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
["Spam Attack on Target"] = "盡可能多的平A目標",
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
["Log Funcs"] = "日志功能",
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
["Cast R when our HP less than"] = "當妳的生命值低于%時使用R",
["Cast R when enemy HP less than"] = "當敵人生命值低于%時使用R",
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
["Combo-Insec value Target"] = "回旋踢目標",
["Combo-Insec with flash"] = "使用R閃回旋踢",
["Use R-flash if no W or wards"] = "如果沒有W或者沒有眼使用R閃",
["Use W-R-flash if Q cd (BETA)"] = "如果Qcd使用W-R閃(測試)",
["Insec Mode"] = "回旋踢模式",
["R Angle Variance"] = "R的角度調整",
["KS Enabled"] = "使搶人頭",
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
["Use Q for harass"] = "使用壹段Q騷擾",
["Use Q2 for harass"] = "使用二段Q騷擾",
["Use W for retreat after Q2+E"] = "二段Q+E後使用W撤退",
["Use E for harass"] = "使用E技能騷擾",
["-- Spells Range --"] = "-- 技能範圍線圈 --",
["Draw W range"] = "顯示W範圍",
["W color"] = "W技能線圈顏色",
["Draw E range"] = "顯示E範圍",
["Combat Draws"] = "顯示戰鬥",
["Insec direction & selected points"] = "回旋踢的地點&選定的地點",
["Collision & direction for direct R"] = "碰撞&直線R的方向",
["Draw non-Collision R direction"] = "顯示無碰撞的R的方向",
["Collision & direction Prediction"] = "碰撞&方向預判",
["Draw Damage"] = "顯示傷害",
["Draw Kill Text"] = "顯示擊殺提示",
["Debug"] = "調試",
["Focus Selected Target"] = "鎖定選擇的目標",
["Always"] = "總是",
["Auto Kill"] = "自動擊殺",
["Insec Wardjump Range Reduction"] = "回旋踢摸眼範圍減少",
["Magnetic Wards"] = "便捷吸附性插眼",
["Enable Magnetic Wards Draw"] = "使吸附性插眼顯示",
["Use lfc"] = "使用lfc",
["--- Spots to be Displayed ---"] = "--- 顯示的插眼點 ---",
["Normal Spots"] = "普通地點",
["Situational Spots"] = "取決于情況的地點",
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
["Enable Auto Smite"] = "使自動懲戒",
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
["Taric"] = "塔�塈J",
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
["Use empower W if health below %"] = "當生命值低于%使用強化W",
["Min health % for use it ^"] = "使用的最小生命值%",
["Use E on Dynamic Combo if enemy is far"] = "如果敵人距離很遠在動態連招中使用E",
["Playing AP rengar !"] = "AP獅子狗模式",
["Use E on AP Combo if enemy is far"] = "如果敵人距離很遠在AP連招中使用E",
["Anti Dashes"] = "反突進",
["Antidash Enemy Enabled"] = "對敵人使反突進",
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
["W Cast Method"] = "釋放W的防曬霜",
["Always max range"] = "總是在最大距離",
["Min Mana % to cast extra W"] = "釋放額外W的最小藍量%",
["--- E LOGIC ---"] = "--- E技能邏輯 ---",
["E to target when safe"] = "當安全時E向目標",
["--- R LOGIC ---"] = "--- R技能邏輯 ---",
["Single target R in melee range"] = "處于近戰攻擊距離的時候只R壹個目標",
["To Soldier"] = "向沙兵釋放",
["To Ally/Tower"] = "向友軍/塔釋放",
["Single target R only under self HP"] = "只在自己生命值低于x時只R壹個目標",
["Multi target R logic"] = "多目標R邏輯",
["Block"] = "屏蔽",
["Multi target R at least on"] = "多目標R時最小目標數",
["R enemies into walls"] = "把敵軍推到牆��",
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
["Min Self HP % to smart dash"] = "自身生命值大于%時使用智能突進",
["Max target HP % to smart dash"] = "目標生命值小于%時使用智能突進",
["Max target HP % dash in R CD"] = "Rcd時目標",
["ASAP R to ally/tower after dash hit"] = " ",
["Dash R Area back range"] = " ",
["--- COMBO-INSEC LOGIC ---"] = "--- Insec連招邏輯 ---",
["Smart new-INSEC in combo"] = "在連招中使用智能新Insec連招",
["new-Insec only x allies more"] = "只在大于x名友軍時使用新Insec連招",
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
["----- About the script ---------------------------"] = "關于本腳本",
["Gameregion"] = "遊戲區域",
["Scriptversion"] = "腳本版本",
["Author"] = "作者",
["Updated"] = "更新日期",
["\"The road to ruin is shorter than you think...\""] = "滅亡之路,短的超乎妳的想象。",
["This section is only a placeholder for more structure"] = "這個部分只是待添加內容的預留位置",
["Choose targetselector mode"] = "選擇目標選擇器位置",
["LESS_CAST"] = "更少使用技能",
["LOW_HP"] = "低血量",
["SELECTED_TARGET"] = "選定的目標",
["PRIORITY"] = "優先級",
["Set your priority here:"] = "在這�堻]定優先級",
["No targets found / available! "] = "沒有找到目標",
["Draw your current target with circle:"] = "在妳的當前目標上畫圈",
["Draw your current target with line:"] = "在妳的當前目標上畫線",
["Use Gapclose"] = "使用突進",
["Check health before gapclosing under towers"] = "在塔下突進時檢查血量",
["Only gapclose if my health > % "] = "只在我的血量大于%時突進",
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
["if your health is below %"] = "如果妳的生命值低于%",
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
[">| under enemy turrets. If ally minions >= X then it allows diving!"] = ">| 如果友方小兵數大于等于x就會允許越塔",
["> Info about advanced mode"] = "> 高級模式介紹",
[">| The advanced mode checks for x number of ally minions"] = "高級模式會檢查防禦塔下友方小兵數量",
[">| as well as for x number of ally champions under enemy turrets."] = "和防禦塔友方英雄數量",
[">| If both >= X then it allows diving!"] = "如果都大于等于x就會允許越塔",
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
["Cleanse"] = "淨化",
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
["Draw line to next jumpspots"] = "顯示到下壹穿牆點的直線",
["> Draw jumpspot colors"] = "> 顯示穿牆點的顏色",
["Jumpspot color"] = "穿牆點的顏色",
["(E) - Sweeping Blade settings: "] = "(E) - 踏前斬設置",
["Increase dashtimer by"] = "增加突進時間",
[">| This option will increase the time how long the script"] = ">| 這項設置會通過壹個設定的值來增加",
[">| thinks you are dashing by a fixed value"] = ">| 腳本認為妳正在突進的時間",
["Check distance of target and (E)endpos"] = "檢查目標和E結束地點的距離",
["Maximum distance"] = "最大距離",
[">| This option will check if the distance"] = ">| 這項設置會檢查妳的目標",
[">| between your target and the endposition of your (E) cast"] = ">| 和E結束地點的距離",
[">| is greater then the distance set in the slider."] = "如果大于妳設定的距離",
[">| If yes the cast will get blocked!"] = "就會屏蔽E的釋放",
[">| This prevents dashing too far away from your target!"] = "這會避免妳突進時和目標離的太遠",
["Auto Level Enable/Disable"] = "自動加點 開啟/關閉",
["Auto Level Skills"] = "自動升級技能",
["No Autolevel"] = "不自動加點",
["> Autoultimate"] = "> 自動大招",
["Number of Targets for Auto(R)"] = "自動大招時的目標數",
[">| Auto(R) ignores settings below and only checks for X targets"] = ">| 自動大招會在有X個目標時才釋放",
["> General settings:"] = "> 常規設置",
["Delay the ultimate for more CC"] = "延遲大招釋放以延長控制時間",
["DelayTime "] = "延遲時間",
["Use (Q) while ulting"] = "當放大時使用Q",
["Use Ultimate under towers"] = "在塔下使用大招",
["> Target settings:"] = "> 目標設置",
["No supported targets found/available"] = "沒有找到有效目標",
["> Advanced settings:"] = "> 高級設置:",
["Check for target health"] = "檢查目標的血量",
["Only ult if target health below < %"] = "只在目標生命值小于%時使用大招",
["Check for our health"] = "檢查自己的血量",
["Only ult if our health bigger > %"] = "只在自己生命值大于%時使用大招",
["General-Settings"] = "常規設置",
["Orbwalker Enabled"] = "使走砍",
["Allow casts only for targets in camera"] = "只在目標在屏幕上時允許使用技能",
["Windwall only if your hero is on camera"] = "只在妳的英雄在屏幕上時使用風牆",
["> Packet settings:"] = "> 封包設置",
["Limit packets to human level"] = "> 限制封包在人類的操作水平",
[">> General settings"] = ">> 常規設置",
["Choose combo mode"] = "選擇連招模式",
["Prefer Q3-E"] = "優先Q3-E",
["Prefer E-Q3"] = "優先E-Q3",
["Use items in Combo"] = "在連招中使用物品",
[">> Choose your abilities"] = ">> 選擇妳的技能",
["(Q) - Use Steel Tempest"] = "使用Q",
["(Q3) - Use Empowered Tempest"] = "使用帶旋風的Q",
["(E) - Use Sweeping Blade"] = "使用E",
["(R) - Use Last Breath"] = "使用R",
["Choose mode"] = "選擇模式",
["1) Normal harass"] = "1)普通騷擾",
["2) Safe harass"] = "2)安全騷擾",
["3) Smart E-Q-E Harass"] = "3)智能E-Q-E騷擾",
["Enable smart lasthit if no target"] = "使智能尾刀如果沒有目標",
["Enable smart lasthit if target"] = "使只能尾刀如果有目標",
["|> Smart lasthit will use spellsettings from the lasthitmenu"] = "|> 智能尾刀會使用尾刀菜單�堛漣獊鈳]置",
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
["Cast to X or more amount of units "] = "當大于等于X個單位時釋放",
["Min units to hit with (Q3)"] = "使用Q3時的最小單位數",
["Check health for using (E)"] = "使用E前檢查血量",
["Only use (E) if health > %"] = "只在生命值大于%時使用E",
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
["Draw remaining (Q3) time"] = "顯示Q3剩余時間",
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
[">| You need to reload the script (2xF9) after changes here!"] = ">| 修改此處設置後妳需要F9兩次",
["> Healthpotions:"] = "> 自動血藥",
["Use Healthpotions"] = "使用血瓶",
["if my health % is below"] = "如果自己生命值低于%",
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
["Draw tower ranges at distance"] = "在壹定距離內才顯示塔範圍",
["Timers"] = "計時器",
["Display Jungle Timers"] = "顯示打野計時",
["Display Inhibitor Timers"] = "顯示水晶計時",
["Display Health-Relic Timers"] = "顯示據點計時",
["Way Points"] = "路徑顯示",
["Draw enemy paths"] = "顯示敵人的路線",
["Draw ally paths"] = "顯示友軍的路線",
["Draw last-seen champ map icon"] = "在小地圖顯示敵人最後壹次出現的位置",
["Draw enemy FoW minions line"] = "顯示戰爭迷霧�堛漣L線",
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
["On FoW teleport/recall log client-sided chat notification"] = "聊天框提醒戰爭迷霧�堛熄ヶe/回城",
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
["Enable Scarra Warding Assistance"] = "使插眼助手",
["Automations"] = "自動",
["Lantern Grabber"] = "自動撿燈籠",
["Max Radius to trigger"] = "觸發的最大半徑",
["Hotkey to trigger"] = "觸發的按鍵",
["Allow automation based on health"] = "取決于生命值的自動",
["Auto trigger when health% < "] = "當生命值小于%時自動觸發",
["Enable BaseHit"] = "使基地大招",
["Auto Level Sequence"] = "自動加點順序",
["Auto Leveling"] = "自動加點",
["Vision ward on units stealth spells"] = "自動插真眼反隱",
["Voice Awareness"] = "語音提示",
["Mode"] = "模式",
["Real"] = "真人聲音",
["Robot"] = "機器人聲音",
["Gank Alert Announcement"] = "Gank提示",
["Recall/Teleport Announcement"] = "回城/傳送提示",
["Compliments upon killing a champ"] = "殺敵之後的稱贊",
["Motivations upon dying"] = "死亡之後的鼓舞",
["Camp 1 min respawn reminder"] = "水晶1分鍾複活提醒",
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
["Enable"] = "使",
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
["Ignore Logic if enemy closer <"] = "敵軍距離小于x時不使用連招邏輯",
["Max Distance"] = "最大距離",
["[Pick a Card]"] = "[選牌(W)]",
["Card picker"] = "切牌器",
["Pick card logic"] = "選牌邏輯",
["Distance check"] = "距離檢測",
["Pick red, if hit more than 1"] = "如果能擊中多于壹個敵人就切紅牌",
["Pick Blue if mana is below %"] = "如果藍量低于%就切藍牌",
[" > Use (Q) - Wild Cards"] = " > 使用Q - 萬能牌",
[" > Use (W) - Pick a Card"] = "> 使用W - 選牌",
["Don't combo if mana < %"] = "如果藍量低于%不使用連招",
["[Harass]"] = "[騷擾]",
["Harass #1"] = "騷擾 #1",
["Don't harass if mana < %"] = "藍量低于%時不騷擾",
["[Farm]"] = "[發育]",
["Card"] = "切牌",
["Clear!"] = "清線",
["Don't farm with Q if mana < %"] = "藍量低于%時不使用Q",
["Don't farm with W if mana < %"] = "藍量低于%時不使用W",
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
["[R - Destiny]"] = "[R - 命運]",
["Enable Minimap"] = "在小地圖上使顯示",
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
["Enable Packet Features"] = "使封包",
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
["Side to Side"] = "從敵人壹側到另壹側",
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
["Don't E KS if # enemies near is >"] = "當附近敵人大于x時不要用E搶人頭",
["Don't E KS if level is >"] = "當等級大于x時不要用E搶人頭",
["E KS if near death"] = "如果瀕死使用E搶人頭",
["Calculate condemn-flash at:"] = "使用E閃：",
["Mouse Flash Position"] = "以鼠標位置為閃現位置",
["All Possible Flash Positions"] = "所有可能的閃現位置",
["R Settings"] = "R技能設置",
["Stay invis long as possible"] = "盡可能長時間的保持隱身狀態",
["Stay invis min enemies"] = "保持隱身狀態的最小敵人數",
["    Activate R"] = "自動R",
["R min enemies to use"] = "使用R的最小敵人數",
["Use R if Health% <="]	= "如果生命值小于等于%",
["Use R if in danger"] = "在危險情況下使用R",
["Use Q after R if danger"] = "在危險情況下使用RQ隱身",
["Special Condemn Settings"] = "特殊擊退設置",
["Anti-Gap Close Settings"] = "反突進設置",
["Enable"] = "使",
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
["More Accurate"] = "更精准",
["Q and Flash Usage:"] = "Q和閃現的使用",
["Q First"] = "先Q",
["Flash First"] = "先閃現",
["Never Use Q"] = "從不使用Q",
["Never Use Flash"] = "從不使用閃現",
["Wall Condemn Settings"] = "定牆設置",
["Use on Lucian"] = "對盧錫安使用",
["   If enemy health % <="] = "   如果敵人生命值小于<",
["Use wall condemn on"] = "使用定牆的對象",
["All listed"] = "所有列表�堛漸媦�",
["Use wall condemn during:"] = "以下情況下使用定牆",
["Combo and Harass"] = "連招和騷擾",
["Always On"] = "總是使用",
["Wall condemn accuracy"] = "定牆精准度",
["     Jungle Settings"] = "     清野設置",
["Use Q-AA reset on:"] = "以下情況使用Q重置普攻",
["All Jungle"] = "所有野怪",
["Large Monsters Only"] = "只是大型野怪",
["Wall Stun Large Monsters"] = "對大型野怪使用定牆",
["Disable Wall Stun at Level"] = "在等級x時禁用定牆",
["Jungle Clear Spells if Mana >"] = "如果藍量大于x時才使用清野",
["     Lane Settings"] = "     清線設置",
["Q Method:"] = "Q使用方式",
["Lane Clear Q:"] = "清線中使用Q",
["Dash to Mouse"] = "位移至鼠標方向",
["Dash to Wall"] = "位移至牆",
["Lane Clear Spells if Mana >"] = "在清線中使用技能如果藍量大于%",
["Humanize Clear Interval (Seconds)"] = "擬人化清線間隔(秒)",
["Tower Farm Help (Experimental)"] = "塔下發育助手(測試)",
["Item Settings"] = "物品設置",
["Offensive Items"] = "進攻型物品",
["Use Items During"] = "在以下情況使用",
["Combo and Harass Modes"] = "連招和騷擾模式",
["If My Health % is Less Than"] = "如果生命值低于%",
["If Target Health % is Less Than"] = "如果目標生命值低于%",
["QSS/Cleanse Settings"] = "水銀/淨化設置",
["Remove CC during: "] = "以下情況淨化控制技能",
["Remove Exhaust"] = "淨化虛弱",
["QSS Blitz Grab"] = "淨化機器人的勾",
["Humanizer Delay (ms)"] = "人性化延遲(毫秒)",
["Use HP Potions During"] = "以下情況使用血藥",
["Use HP Pot If Health % <"] = "生命值低于%使用血藥",
["Damage Draw Settings"] = "傷害顯示設置",
["Draw E DMG on bar:"] = "在血條顯示E的傷害",
["Ascending"] = "上升",
["Descending"] = "下降",
["Draw E Text:"] = "顯示E技能提示文字",
["Percentage"] = "百分比",
["Number"] = "數字",
["AA Remaining"] = "擊殺剩余平A數",
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
["Enable Streaming Mode (F7)"] = "使流模式(F7)",
["General Settings"] = "常規設置",
["Auto Level Spells"] = "自動加點",
["Disable auto-level for first level"] = "在1級時關閉自動加點",
["Level order"] = "加點順序",
["First 4 Levels Order"] = "前4級加點順序",
["Display alert messages"] = "顯示警告信息",
["Left Click Focus Target"] = "左鍵點擊鎖定目標",
["Off"] = "關閉",
["Permanent"] = "永久的",
["For One Minute"] = "持續壹分鍾",
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
["Dragonslayer Vayne - Light Blue"] = "屠龍勇士 薇恩 - 淺藍色",
["SKT T1 Vayne"] = "SKT T1 薇恩",
["Arc Vayne"] = "蒼穹之光 薇恩",
["Snow Bard"] = "冰雪遊神 巴德",
["No Gap Close Enemy Spells Detected"] = "沒有檢測到敵人的突進技能",
["Lucian Ult - Enable"] = "盧錫安大招 - 使",
["     Humanizer Delay (ms)"] = "     擬人化延遲(毫秒)",
["Teleport - Enable"] = "傳送 - 使",
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
["Ravenous Hydra"] = "貪欲九頭蛇",
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
["Stick to 1"] = "鎖定壹個小兵",
["Draw LastHit Indicator (LastHit Mode)"] = "顯示尾刀指示器(尾刀模式)",
["Always Draw LastHit Indicator"] = "總是顯示尾刀指示器",
["Lasthit Indicator Style"] = "尾刀指示器樣式",
["New"] = "新",
["Old"] = "舊",
["Show Lasthit Indicator if"] = "以下情況顯示尾刀指示器",
["1 AA-Kill"] = "壹次平A擊殺",
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
["Combat keys are located in orbwalking settings"] = "戰鬥按鍵在走砍�堻]置",
-----------------------時間機器艾克--------------
["Time Machine Ekko"] = "時間機器 艾克",
["Skin Changer"] = "皮膚切換",
["Sandstorm Ekko"] = "時之砂 艾克",
["Academy Ekko"] = "任性學霸 艾克",
["Use Q combo if  mana is above"] = "如果藍量高于x使用Q連招",
["Use E combo if  mana is above"] = "如果藍量高于x使用E連招",
["Use Q Correct Dash if mana >"] = "如果藍量高于x使用E修正二段Q的方向",
["Reveal enemy in bush"] = "對草叢�堛獐臚H自動插眼",
["Use Target W in Combo"] = "在連招中有目的性的使用W",
["W if it can hit X "] = "如果能擊中X個敵人使用R",
["Use Q harass if  mana is above"] = "如果藍量高于x使用Q騷擾",
["Harass Q last hit and hit enemy"] = "騷擾中使用Q補尾刀以及擊中敵人",
["Auto-move to hit 2nd Q in Combo"] = "自動移動來使二段Q命中",
["On"] = "開",
["On and Draw"] = "打開並顯示",
["Long Range W Engage"] = "戰鬥中使用遠距離W",
["Long Range Before E Engage"] = "戰鬥中在E之前使用遠距離W",
["During E Engage"] = "戰鬥使用E的時候",
["Use W on CC or slow"] = "使用W來打控制或者群體減速",
["Don't use E in AA range unless KS"] = "敵人在平A範圍內時除了搶人頭不要使用E",
["Offensive Ultimate Settings"] = "進攻性大招設置",
["Ult Target in Combo if"] = "以下情況在連招中使用大招",
["Target health % below"] = "目標生命值低于%",
["My health % below"] = "自己生命值低于%",
["Ult if 1 enemy is killable"] = "如果有1名敵人可擊殺時使用R",
["Ult if 2 or more"] = "如果有2名或更多敵人可擊殺時使用R",
["will go below 35% health"] = "會在血量低于35%的時候觸發",
["Ult if set amount"] = "如果到達設定數值則使用R",
["will get hit"] = "即將收到攻擊",
["Offensive Ult During:"] = "以下情況使用進攻性大招",
["Combo Only"] = "只在連招�堥洏�",
["Block ult in combo mode if ult won't hit"] = "如果大招不能擊中則不在連招中使用大招",
["Defensive Ult/Zhonya Settings"] = "防禦性大招/中亞設置",
["Use if about to die"] = "瀕死時使用",
["Only Defensive Ult if my"] = "如果自身情況滿足..則使用防禦性大招",
["health is less than targets"] = "生命值低于目標生命值",
["Ult if heal % is >"] = "大招治療生命值高于%時使用R",
["Defensive Ult During:"] = "以下情況使用防禦性大招：",
["Wave Clear Settings"] = "清線設置",
["Use Q in Wave Clear"] = "使用Q清線",
["Scenario 1:"] = "方案 1：",
["Minimum lane minions to hit "] = "至少擊中的小兵數",
["Use Q if  mana is above"] = "如果藍量高于x時使用Q",
["Must hit enemy also"] = "必須同時擊中敵人",
["Scenario 2:"] = "方案 2：",
["---Jungle---"] = "---清野設置---",
["Use W in Jungle Clear"] = "使用W清野",
["Use E in Jungle Clear"] = "使用E清野",
["Escape Settings"] = "逃跑設置",
["Cast W direction you are heading"] = "向妳面朝的方向使用W",
["Draw (W) Max Reachable Range"] = "顯示能到達的W最大範圍",
["Draw (E) Range"] = "顯示E技能範圍",
["Draw (R) Range"] = "顯示R技能範圍",
["Draw Line to R Spot"] = "在R的地點畫指示線",
["Draw Passive Stack Counters"] = "顯示被動層數指示器",
["Display ult hit count"] = "顯示大招能擊中的敵人數",
["Draw Tower Ranges"] = "顯示防禦塔範圍",
["Damage Drawings"] = "顯示傷害",
["Enable Bar Drawings"] = "使血條傷害顯示",
["Separated"] = "分離的",
["Combined"] = "壹體的",
["Draw Bar Letters"] = "在血條上顯示技能字母",
["Draw Bar Shadows"] = "顯示血條陰影",
["Draw Bar Kill Text"] = "顯示血條擊殺提示",
["Draw (Q) Damage"] = "顯示Q的傷害",
["Draw (E) Damage"] = "顯示E的傷害",
["Draw (R) Damage"] = "顯示R的傷害",
["Draw (I) Ignite Damage"] = "顯示I(點燃)的傷害",
["Q Helper"] = "Q技能助手",
["Enable Q  Helper"] = "使Q技能助手",
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
["      Enable"] = "      使",
["      Health % < "] = "      生命值低于%",
------------------------Raphlol女槍小炮--------------
["Ralphlol: Miss Fortune"] = "Raphlol:女槍",
["Use W if  mana is above"] = "藍量高于x時使用W",
["Use E if  mana is above"] = "藍量高于x時使用E",
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
["Only AutoUlt if CC Nearby <="]= "如果附近的控制小于等于X使用自動大招",
["Cancel Ult if no more enemies inside"] = "如果R範圍內沒有敵人則取消大招",
["Cancel Ult when you right click"] = "當妳點擊右鍵的時候取消大招",
["Block Ult cast if it will miss"] = "如果大招打不中的話就屏蔽大招釋放",
["(Shift Override)"] = "(覆蓋Shift)",
["Clear Settings"] = "清線設置",
["Jungle Clear Settings"] = "清野設置",
["Use Q in Jungle Clear"] = "在清野中使用Q",
["Show notifications"] = "顯示提示信息",
["Show CC Counter"] = "顯示控制技能計數",
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
["Enable Danger Ultimate"] = "使危險時自動大招",
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
["X % Combo Accuracy"] = "連招精准度X%",
["X % Harass Accuracy"] = "騷擾精准度X%",
["80 % ~ Super High Accuracy"] = "80% ~ 極高精准度",
["60 % ~ High Accuracy (Recommended)"] = "60% ~ 高精准度(推薦)",
["30 % ~ Medium Accuracy"] = "30% ~ 中精准度",
["10 % ~ Low Accuracy"] = "10% ~ 低精准度",
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
["Use R If Enemies >="]	= "如果敵人數量大于等于",
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
["Use main keys from your Orbwalker"] = "使用妳的走砍按鍵設置",
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
["Swap to W/R if my HP % <="] = "如果生命值小于等于X%時使用二段W/R",
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
["Use R1 to Evade"] = "使用壹段R躲避",
["Use R2 to Evade"] = "使用二段R躲避",
["Use W To Evade"] = "使用W躲避",
["Use W1 to Evade"] = "使用壹段W躲避",
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
["Use Zhonyas if HP % <="]= "如果生命值小于%使用中亞",
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
["Ralphlol Kindred"] = "Ralphlol:千玨",
["Use Q gap-close "] = "使用Q接近敵人",
["In Combat Q Dash Method"] = "在戰鬥中Q位移的方式",
["Enable Ultimate"] = "使大招",
["Use W in Wave Clear"] = "在清線中使用W",
["Also use champ Smite"] = "自動使用懲戒",
["Draw W Duration"] = "顯示W持續時間",
["Draw R Duration"] = "顯示R持續時間",
["Assisted Ultimate Key"] = "輔助大招按鍵",
["Malphite"] = "墨菲特",
["Keybindings are in the Orbwalking Settings menu"] = "按鍵設置在走砍設置菜單��",
["Ralphlol's Utility Suite"] = "Ralphlol的工具套件",
["Missed CS Counter"] = "漏刀計數器",
["X Position"] = "X軸位置",
["Y Position"] = "Y軸位置",
["Text Size"] = "文字大小",
["Jungler"] = "打野",
["Draw Enemy Waypoints"] = "顯示敵人的行進路線",
["Draw Incoming Enemies"] = "顯示即將趕到的敵人",
["Countdowns"] = " 倒計時",
["Ward Bush/ Pink Invis"] = "自動插真眼/神諭改造反隱",
["Key Activation"] = "熱鍵",
["Max Time to check missing Enemy"] = "檢查敵人消失的最大時間",
["Draw Minions"] = "顯示小兵",
["Recall Positions"] = "回城地點",
["Print Messages"] = "顯示消息",
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
["Stop track inc. enemys after x min"] = "x分鍾後停止監視敵人",
["Allow this option"] = "允許此項設置",
["Scan Range"] = "掃描範圍",
["Draw minimap"] = "小地圖顯示",
["Use Danger Sprite"] = "使用危險標志",
["Show waypoints"] = "顯示行進路線",
["Enable Voice System"] = "使語音系統",
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
["Enable Jungle Timers!!! Finally ^^"] = "最後,使打野計時",
["[Enemies Hud]"] = "[敵人信息HUD]",
["Enable enemies hud"] = "使敵人信息HUD",
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
["[Thresh Lantern]"] = "[錘石的燈籠]",
["Use Nearest Lantern"] = "撿最近的燈籠",
["Auto Use if HP < %"] = "如果生命值小于%自動使用",
["[Anti CC]"] = "[反控制]",
["Enable AntiCC"] = "使反控制",
["[BuffTypes]"] = "[控制類型]",
["Disarm"] = "繳械",
["ForcedAction"] = "強制動作(嘲諷/魅惑)",
["Suppression"] = "壓制",
["Suspension"] = "擊飛",
["Slow"] = "減速",
["Blind"] = "致盲",
["Stun"] = "眩暈",
["Root"] = "禁錮",
["Silence"] = "沈默",
["Enable Mikael for teammates"] = "使對隊友使用坩堝",
["[TeamMates for Mikael]"] = "[對隊友使用坩堝]",
["It will use Cleanse, Dervish Blade,"] = "它會使用淨化,苦行僧之刃",
["Quicksilver Sash, Mercurial Scimitar"] = "水銀飾帶,水銀彎刀",
[" or Mikael's Crucible."] = "或者米凱爾的坩堝",
["Suppressions by Malzahar, Skarner, Urgot,"] = "解除瑪爾紮哈,斯卡納,厄加特的壓制",
["Warwick could be only removed by QSS"] = "狼人的壓制只有水銀能解",
["[Misc]"] = "[雜項]",
["Draw Exp Circle"] = "顯示經驗獲得範圍",
["Extra Awareness"] = "額外意識",
["Heal Cd's on Aram"] = "在大亂鬥模式顯示治療cd",
["LordsDecree Cooldown"] = "雷霆領主的法令冷卻時間",
["Big Fat Hev - Mark IV v. 4.001"] = "胖子意識 v. 4.001",
----------------燒傷劍聖巨魔螳螂-----------------
["Khazix Fun House 2.0"] = "燒傷合集2.0 - 卡茲克",
["Auto Harass Toggle"] = "自動騷擾開關",
["Prioritize Isolated"] = "孤立無援的目標優先",
["Back Flip Q Cast mid-jump"] = "向敵人後跳躍的空中使用Q ",
["--- Jump Logic ---"] = "--- 跳躍邏輯 ---",
["Save E in combo for KS"] = "在連招中留E搶人頭",
["E engage if target very isolated"] = "如果目標孤立無援則先使用E",
["Double Jump Enabled"] = "擊殺時使用兩次跳躍",
["DbJump to max range intead of target"] = "兩次跳躍跳到最遠距離而不跳向目標",
["Auto DoubleJump offensive self hp"] = "自動兩次跳躍的自身生命值",
["Auto DoubleJump def. enemy no"] = "自動兩次跳躍的敵人數量",
["Auto DoubleJump delay"] = "自動兩次跳躍延遲",
["Other Double Jump Positions"] = "兩次跳躍的地點",
["SmartAuto"] = "智能自動模式",
["Mouse"] = "鼠標位置",
["Ally"] = "友軍位置",
["Enemy"] = "敵人位置",
["Cast target killable with passive damage"] = "加上被動的傷害能夠擊殺時使用",
["Use Taste Their Fear (Q)"] = "使用品嘗恐懼(Q)",
["Use Leap (E)"] = "使用躍擊(E)",
["Use Void Spike (W)"] = "使用虛空突刺(W)",
["Draw Invis Time"] = "顯示隱身時間",
["Cast Ignite on Sivir"] = "對希維爾使用點燃",
["E2 Hit Chance"] = "進化E命中的機會",
["Trundle Fun House"] = "燒傷合集 - 特朗德爾",
["Force R Key (current target)"] = "強制使用R按鍵(對當前目標)",
["--- Mana Settings ---"] = "--- 藍量設置 ---",
["Minimum % Mana to use (W)"] = "使用W的最小藍量",
["Use E as anti enemy gap closers"] = "使用E反突進",
["Use E as spell interruptor"] = "使用E打斷敵人的技能",
["Use R on combo"] = "在連招中使用R",
["--- R Triggers ---"] = "--- R觸發條件 ---",
["Minimum % HP to use (R)"] = "使用R的最小生命值%",
["R priority Mode"] = "R優先級模式",
["Defensive"] = "防禦性",
["Selected Enemy"] = "選定的敵人",
["Use Chomp (Q)"] = "使用利齒撕咬(Q)",
["Use Frozen Domain (W)"] = "使用冰封領域(W)",
["Enable ks mode with R"] = "使用R搶人頭",
["Enable Spells Draws"] = "使技能線圈顯示",
["-- Extra E draw options --"] = "--- E技能額外顯示設置 ---",
["Draw E predicted position "] = "顯示E技能預判位置",
["^ E hold: draw E | E twice: cast E"] = "按住E:顯示E位置|E兩次:使用E",
["Master Yi Fun House 2.0"] = "燒傷合集2.0 - 易",
["Master Yi Fun House"] = "燒傷合集 - 易",
["Forced Q Key"] = "強制使用Q按鍵",
["Use Q always (not recommended)"] = "總是使用Q(不推薦)",
["Use Q if: Q + 3x AA = kill enemy"]= "如果Q+3次平A能夠擊殺時使用Q",
["Use Q for avoid hard CC"] = "使用Q躲避硬控技能",
["Use Q for follow enemy dashes"] = "使用Q跟進敵人的位移",
["Use Q under X hp"] = "生命值低于x使用Q",
["Self hp % "] = "自身生命值%",
["Auto use Q for kill steal"] = "自動使用Q搶人頭",
["Use W as life saver vs turret shots"] = "使用W減少防禦塔傷害",
["Use W if Q CD for lower big damage"] = "當受到成噸傷害且QCD時使用W",
["Use W as AA reset"] = "使用W重置普攻",
["Only if killable"] = "僅當能擊殺時",
["Use E on combo"] = "在連招中使用E",
["Auto R usage if we are slowed/exhausted"] = "被減速/虛弱時自動使用R",
["LaneClear Alpha Strike (Q)"] = "在清線中使用Q",
["LaneClear Wuju Style (E)"] = "在清線中使用E",
["Jungle Alpha Strike (Q)"] = "在清野中使用Q",
["Jungle Wuju Style (E)"] = "在清野中使用E",
["Cast Ignite on Malzahar"] = "對瑪爾紮哈使用點燃",
-------------------女王ADC合集--------------
["AmberCarries - Kalista"] = "女王ADC合集 - 卡莉斯塔",
["[Kalista] - Combo Settings (SBTW)"] = "[卡莉斯塔] - 連招設置",
["Combo Key"] = "連招按鍵",
["Use (Q) in combo"] = "在連招中使用Q",
["OrbWalk Minion if no Target"] = "如果沒有目標就A兵",
["[Kalista] - Harass Settings"] = "[卡莉斯塔] - 騷擾設置",
["Harass Key"] = "騷擾按鍵",
["Use (Q) in Harass"] = "在騷擾中使用Q",
["Use (E) in Harass"] = "在騷擾中使用E",
["[Kalista] - KillSteal Settings"] = "[卡莉斯塔] - 搶人頭設置",
["Use KillSteal"] = "搶人頭",
["[Kalista] - Balista Settings"] = "[卡莉斯塔] - 機器Q中釋放大招設置",
["Use Balista"] = "使用此連招",
["Min Range to Blitz for Balista"] = "使用此連招的最大距離",
["[Kalista] - Spells Settings"] = "[卡莉斯塔] - 技能設置",
["(W) Settings"] = "W技能設置",
["Auto (W) - Bush revealer"] = "自動使用W探草叢",
["Max Range"] = "最大距離",
["(E) Settings"] = "E技能設置",
["Auto (E) if Unit Executable"] = "在單位能E死的時候使用E",
["Auto (E) Minion for Slow Unit"] = "E兵來減速單位",
["Only if unit not in AA Range"] = "當對面不在妳的平A範圍時才用E",
["Force Use if Closest Unit"] = "對離妳最近的目標強制使用E",
["(R) Settings"] = "R技能設置",
["Auto (R)"] = "自動R",
["If ally HP < X %"] = "如果契約單位生命值小于X%",
["[Kalista] - Jungle Steal Settings"] = "[卡莉斯塔] - 搶野怪設置",
["Auto (E) Jungle Minion Executable"] = "能E死野怪時自動E",
["Execute Golem "] = "E假身",
["Execute Wolve "] = "E三狼",
["Execute Ghost "] = "E幽靈",
["Execute Gromp "] = "E蛤蟆",
["Execute Red Buff "] = "E紅buff",
["Execute Blue Buff "] = "E藍buff",
["Execute Crab"] = "E螃蟹",
["Execute Drake"] = "E小龍",
["Execute Nashor "] = "E大龍",
["[Kalista] - Last Hit Helper Settings"] = "[卡莉斯塔] - 尾刀助手設置",
["Auto (E) Minion Executable"] = "能E死小兵時自動E",
["if X minion Executable"] = "如果有X名小兵能E死",
["[Kalista] - Message Settings "] = "[卡莉斯塔] - 消息設置",
["Print Blitzcrank Shield"] = "顯示機器人的盾",
["Print When Exhausted"] = "顯示虛弱",
["Delay between each Message"] = "兩條消息之間的延遲",
["[Kalista] - Misc Settings "] = "[卡莉斯塔] - 雜項設置",
["(E) Dmg Offset (+/- per stacks)"] = "E傷害計算調整(增加/減少)",
["[Kalista] -  Item Settings"] = "[卡莉斯塔] - 物品設置",
["Use Bilgewater Cutlass"] = "使用比爾吉沃特彎刀",
["Use BORTK"] = "使用破敗王者之刃",
["Use Youmus"] = "使用幽夢之靈",
["Use Quicksilver Sash"] = "使用水銀飾帶",
["Use Mercurial Scimitar"] = "使用水銀彎刀",
["Humanizer Delay (ms)"] = "擬人化延遲(毫秒)",
["Bush Revealer - Trinket ( blue/green)"] = "自動探草叢(飾品)",
["[Kalista] -  Auto Buy Settings"] = "[卡莉斯塔] - 自動買裝備",
["Auto Buy Startup Item"] = "自動買出門裝",
["Doran's Blade"] = "多蘭劍",
["Health Potion"] = "血瓶",
["Blue Trinket"] = "藍色飾品",
["Green Trinket"] = "綠色飾品",
["[Kalista] - Draw Settings "] = "[卡莉斯塔] - 繪圖設置",
["Draw (Q) Range"] = "畫出Q範圍",
["Draw (E) Range"] = "畫出E範圍",
["Draw (R) Range"] = "畫出R範圍",
["Draw Sprite on Target"] = "在目標身上畫標記",
["Draw (E) Damage"] = "顯示E的傷害",
["Draw Minion/Jungle Executable"] = "顯示能E死的小兵",
["Draw Damage Jungle Minion"] = "顯示E對野怪的傷害",
["[Kalista] - OrbWalk Settings (SBTW)"] = "[卡莉斯塔] - 走砍設置",
["General-Settings"] = "常規設置",
["Orbwalker Enabled"] = "走砍生效開關",
["Stop Move when Mouse above Hero"] = "當英雄在鼠標下時停止",
["Range to Stop Move"] = "停止移動的區域",
["Focus Selected Target"] = "鎖定選中的目標",
["ExtraDelay against Cancel AA"] = "平A的額外延遲",
["Spam Attack on Target"] = "盡可能多的攻擊目標",
["Orbwalker Modus: "] = "走砍模式",
["To Mouse"] = "向鼠標移動",
["To Target"] = "向目標移動",
["Humanizer-Settings"] = "擬人化設置",
["Limit Move-Commands per Second"] = "限制每秒發送的移動指令",
["Max Move-Commands per Second"] = "每秒發送最多移動指令",
["Key-Settings"] = "按鍵設置",
["FightMode"] = "戰鬥模式",
["HarassMode"] = "騷擾模式",
["LaneClear"] = "清線",
["LastHit"] = "尾刀",
["Toggle-Settings"] = "顯示開關狀態設置",
["Make FightMode as Toggle"] = "顯示戰鬥模式開關",
["Make HarassMode as Toggle"] = "顯示騷擾模式開關",
["Make LaneClear as Toggle"] = "顯示清線開關",
["Make LastHit as Toggle"] = "顯示尾刀開關",
["Farm-Settings"] = "刷兵設置",
["Focus Farm over Harass"] = "騷擾時集中補兵",
["Extra-Delay to LastHit"] = "尾刀的額外延遲",
["Mastery-Settings"] = "天賦設置",
["Mastery: Butcher"] = "屠夫",
["Mastery: Arcane Blade"] = "雙刃劍",
["Mastery: Havoc"] = " 毀滅",
["Mastery: Devastating Strikes"] = "毀滅打擊",
["Draw-Settings"] = "顯示設置",
["Draw Own AA Range"] = "畫出自己的平A範圍",
["Draw Enemy AA Range"] = "畫出敵人的平A範圍",
["Draw LastHit-Cirlce around Minions"] = "畫出尾刀線圈",
["Draw LastHit-Line on Minions"] = "畫出尾刀指示線",
["Draw Box around MinionHpBar"] = "在小兵的血條上畫框",
["Color-Settings"] = "顏色設置",
["Color Own AA Range: "] = "自己平A線圈顏色",
["white"] = "白色",
["blue"] = "藍色",
["red"] = "紅色",
["black"] = "黑色",
["green"] = "綠色",
["orange"] = "橙色",
["Color Enemy AA Range (out of Range): "] = "敵人的平A範圍顏色(範圍之外)",
["Color Enemy AA Range (in Range): "] = "敵人的平A範圍顏色(範圍之外)",
["Color LastHit MinionCirlce: "] = "尾刀線圈顏色",
["Color LastHit MinionLine: "] = "尾刀指示線顏色",
["ColorBox: Minion is LasthitAble: "] = "當小兵可以尾刀時的顏色",
["none"] = "無",
["ColorBox: Wait with LastHit: "] = "當小兵等待被尾刀時的顏色",
["ColorBox: Can Attack Minion: "] = "可以攻擊的小兵顏色",
["TargetSelector"] = "目標選擇器",
["Priority Settings"] = "優先級設置",
["Focus Selected Target: "] = "集中選定的目標",
["never"] = "從不",
["when in AA-Range"] = "在平A範圍時",
["Always"] = "總是",
["TargetSelector Mode: "] = "目標選擇器模式",
["LowHP"] = "最低血量",
["LowHPPriority"] = "最低血量+優先級",
["LessCast"] = "使用技能最少",
["LessCastPriority"] = "使用技能最少+優先級",
["nearest myHero"] = "最近的英雄",
["nearest Mouse"] = "離鼠標最近",
["RawPriority"] = "優先級",
["Lucian"] = "盧錫安",
["Highest Priority (ADC) is Number 1!"] = "最高優先級為1",
["Debug-Settings"] = "調試設置",
["Draw Circle around own Minions"] = "在己方小兵上畫圈",
["Draw Circle around enemy Minions"] = "在地方小兵上畫圈",
["Draw Circle around jungle Minions"] = "在野怪上畫圈",
["Draw Line for MinionAttacks"] = "在小兵血條上畫平A指示線",
["Log Funcs"] = "日志功能",
["Cast (W) Exploit ( Ward Drake )"] = "用W開小龍的視野",
["Cast (W) Exploit ( Ward Nashor )"] = "用W開大龍的視野",
["Target Selector"] = "目標選擇器",
["Target Selector Mode:"] = "目標選擇模式",
["Low HP"] = "最低血量",
["Most AP"] = "AP最高",
["Most AD"] = "AD最高",
["Less Cast"] = "更少使用技能優先",
["Near Mouse"] = "離鼠標最近",
["Priority"] = "優先級",
["Low HP Priority"] = "最低血量+優先級",
["Less Cast Priority"] = "更少使用技能+優先級",
["Dead"] = "死亡的",
["Closest"] = "最近",


["AmberCarries - Quinn"] = "女王ADC合集 - 奎因",
["[Quinn] - Combo Settings (SBTW)"] = "[奎因] - 連招設置",
["Use (Q1) in combo"] = "在連招中使用Q-變身前",
["Use (Q2) in combo"] = "在連招中使用Q-變身後",
["Use (E1) in combo"] = "在連招中使用E-變身前",
["Use (E2) in combo"] = "在連招中使用E-變身後",
["Use (R1) in combo"] = "在連招中使用R-變身前",
["Use (R2) in combo"] = "在連招中使用R-變身後",
["[Quinn] - Harass Settings"] = "[奎因] - 騷擾設置",
["Use (Q1) in Harass"] = "在騷擾中使用Q-變身前",
["Use (E1) in Harass"] = "在騷擾中使用E-變身前",
["[Quinn] - Jungle Clear"] = "[奎因] - 清野設置",
["Jungle Clear Key"] = "清野按鍵",
["Use (Q1) in Jungle Clear"] = "在清野中使用Q-變身前",
["Use (E1) in Jungle Clear"] = "在清野中使用E-變身前",
["[Quinn] - Spell Settings"] = "[奎因] - 技能設置",
["(E1) Settings"] = "E-變身前設置",
["Use (E1) for:"] = "對..使用E-變身前",
["Range"] = "範圍",
["Damage"] = "傷害",
["Never Cast if Unit got Passive"] = "如果目標身上有被動就不對他釋放",
["Auto (W) when enemy go in bush "] = "當敵人進草時自動W開視野",
["(R1) Settings"] = "R-變身前 設置",
["Use (R1) if Target life < %"] = "當目標生命值小于X%時使用R-變身前",
["Maximum Enemi in Range: "] = "在範圍內最大敵人數",
["Range: "] = "範圍",
["Never Cast if my health < %"] = "如果自己生命值小于X%",
["(E2) Settings"] = "E-變身後 設置",
["Use (E2) for:"] = "對目標使用E-變身後：",
["Engage"] = "戰鬥",
["(R2) Settings"] = "R-變身後設置",
["For kill Target"] = "為了殺死目標",
["If no enemi in Range"] = "如果範圍內沒有目標",
["[Quinn] - Tower Dive Settings"] = "[奎因] - 越塔設置",
["Only if Ally is under tower"] = "僅當友軍在塔下時",
["Force use if enemy HP < % "] = "當敵方生命值小于X%強制使用",
["Use (E1) for Tower Dive"] = "使用E-變身前越塔",
["Use (R) for Tower Dive"] = "使用R越塔",
["[Quinn] - KillSteal Settings"] = "[奎因] - 搶人頭設置",
["Use (Q1) in KillSteal"] = "使用Q-變身前搶人頭",
["Use (Q2) in KillSteal"] = "使用Q-變身後搶人頭",
["Use (R2) in KillSteal"] = "使用R-變身後搶人頭",
["[Quinn] - Passive Settings"] = "[奎因] - 被動設置",
["Force Proc Passive"] = "強制觸發被動",
["[Quinn] - Wall Jump Settings"] = "[奎因] - 穿牆設置",
["Wall Jump Key"] = "穿牆按鍵",
["[Quinn] - Gap Closer Settings"] = "[奎因] - 反突進設置",
["JarvanIV - Spell: JarvanIVDragonStrike"] = "皇子 - Q技能",
["JarvanIV - Spell: JarvanIVCataclysm"] = "皇子 - E技能",
["[Quinn] - Interupte Spell Settings"] = "[奎因] - 打斷技能設置",
["[Quinn] - Draw Settings "] = "[奎因] - 顯示設置",
["Draw (Q1) Range"] = "顯示Q-變身前範圍",
["Draw (W) Range"] = "顯示W範圍",
["Draw (Q2) Range"] = "顯示Q-變身後範圍",
["Draw (E2) Range"] = "顯示E-變身後範圍",
["Draw (R2) Range"] = "顯示R-變身後範圍",
["Draw Ulti Time Remaining"] = "顯示大招倒計時",
["Draw R2 Damage"] = "顯示R-變身後的傷害",
["[Quinn] -  Item Settings"] = "[奎因] - 物品設置",
["[Quinn] -  Auto Buy Settings"] = "[奎因] - 自動購買設置",
["[Quinn] - OrbWalk Settings (SBTW)"] = "[奎因] - 走砍設置",
["AmberCarries - Kog'Maw"] = "女王ADC合集 - 大嘴",
["[KogMaw] - Combo Settings (SBTW)"] = "[大嘴] - 連招設置",
["Choose your Role"] = "選擇妳的位置",
["ADC"] = "ADC",
["AP MID"] = "AP中單",
["Use (Q)"] = "使用Q",
["Use (W)"] = "使用W",
["Use (E)"] = "使用E",
["Use (R)"] = "使用R",
["[KogMaw] - Harass Settings"] = "[大嘴] - 騷擾設置",
["[KogMaw] - KillSteal Settings"] = "[大嘴] - 搶人頭設置",
["[KogMaw] - Misc Settings"] = "[大嘴] - 雜項設置",
["Use Auto Passive"] = "自動使用被動",
["[KogMaw] - Spells Settings"] = "[大嘴] - 技能設置",
["[KogMaw] - (Q) Spells"] = "[大嘴] - Q技能",
["(Q) Max Range"] = "Q最大距離",
["(Q) Min Range"] = "Q最小距離",
["[KogMaw] - (W) Spells"] = "[大嘴] - W技能",
[" 0  Only use if Target out of range"] = "0 - 當對手不在攻擊範圍",
[" 1  Use for Increase Damage"] = "1 - 用以打出高輸出",
["Choose your (W) type"] = "選擇妳W技能的模式",
["[KogMaw] - (E) Spells"] = "[大嘴] - E技能",
["(E) Max Range"] = "E最大距離",
["(E) Min Range"] = "E最小距離",
["Only Use If Closest Enemy"] = "只對最近的敵人使用",
["Max Range: "] = "最大距離： ",
["[KogMaw] - (R) Spells"] = "[大嘴] - R技能",
["Maximum Stack"] = "最大R被動數",
["Use if Mana > X %"] = "當藍量大于X%",
["[KogMaw] -  Item Settings"] = "[大嘴] - 物品設置",
["[KogMaw] -  Auto Buy Settings"] = "[大嘴] - 自動購買設置",
["Doran's Ring"] = "多蘭戒",
["[KogMaw] - Draw Settings"] = "[大嘴] - 顯示設置",
["[KogMaw] - Prediction Settings"] = "[大嘴] - 預判設置",
["0  VPred | 1  DP"] = "0 - VP預判|1 - 神聖預判",
["-> DivinePred have a better prediction"] = "->神聖預判效果更好",
["Make sure you got it before"] = "切換神聖預判前確保妳已經擁有",
["[KogMaw] - Orbwalking Settings"] = "[大嘴] - 走砍設置",
["AmberCarries - Draven"] = "女王ADC合集 - 德萊文",
["[Draven] - Combo Settings"] = "[德萊文] - 連招設置",
["Use (W) in combo"] = "在連招中使用W",
["Use (E) in combo"] = "在連招中使用E",
["Use (R) in combo"] = "在連招中使用R",
["[Draven] - Harass Settings"] = "[德萊文] - 騷擾設置",
["Use (W) in harass"] = "在騷擾中使用W",
["[Draven] - Lane Clear Settings"] = "[德萊文] - 清線設置",
["Lane Clear Key"] = "清線按鍵",
["Use (Q) in lane clear"] = "在清線中使用Q",
["How Many Axe:"] = "斧頭的數量",
["[Draven] - Last Hit Settings"] = "[德萊文] - 尾刀設置",
["Last Hit Key"] = "尾刀按鍵",
["[Draven] - Spells Settings"] = "[德萊文] - 技能設置",
["[Draven] - (Q) Spells Settings"] = "[德萊文] - Q技能設置",
["Auto Catch Axe: "] = "自動撿斧頭",
["ToMouse"] = "向鼠標位置",
["ToHero"] = "向英雄位置",
["Dont"] = "不要撿斧頭",
["Range Area:"] = "範圍",
["If ToHero Choose"] = "如果向英雄位置選擇",
["Auto Catch Axes (ToHero)"] = "自動撿斧頭(向英雄位置)",
["Block if unit killable"] = "目標可擊殺時不自動接斧頭",
["With x AutoAttack:"] = "X次平A後",
["[Draven] - (W) Spells Settings"] = "[德萊文] - W技能設置",
["Use (W) for reach Axe: "] = "使用W去接斧頭",
["IfNeed"] = "如果必要",
["AllTime"] = "總是",
["Use (W) If closest Unit"] = "如果被突進時使用W",
["Use (W) if Unit not in range"] = "如果目標不在平A範圍內",
["[Draven] - (E) Spells Settings"] = "[德萊文] - E技能設置",
["Min Range:"] = "最小範圍",
["Mana > X%"] = "藍量大于X%",
["[Draven] - (R) Spells Settings"] = "[德萊文] - R技能設置",
["[Draven] - Gap Closer Settings"] = "[德萊文] - 反突進設置",
["[Draven] - Interupte Spell Settings"] = "[德萊文] - 打斷技能",
["[Draven] -  Item Settings"] = "[德萊文] - 物品設置",
["[Draven] -  Auto Buy Settings"] = "[德萊文] - 自動購買物品",
["[Draven] - Draw Settings"] = "[德萊文] - 顯示設置",
["Draw (Q) Area"] = "顯示Q的區域",
["Draw Axe"] = "顯示斧頭位置",
["[Draven] - OrbWalk Settings"] = "[德萊文] - 走砍設置",
["Sivir"] = "輪子媽",
["AmberCarries - Twitch"] = "女王ADC合集 -圖奇",
["[Twitch] - Combo Settings (SBTW)"] = "[圖奇] - 連招設置",
["[Twitch] - Harass Settings (SBTW)"] = "[圖奇] - 騷擾設置",
["Use (E) if X stacks"] = "當有X層被動時使用E",
["Harass if mana > X%"] = "當藍量大于X%時騷擾",
["[Twitch] - Spells Settings"] = "[圖奇] - 技能設置",
["[Twitch] - (Q) Settings"] = "[圖奇] - Q技能",
["Min Range to enemy"] = "離敵人的最小距離",
["Max Range to enemy"] = "離敵人的最大距離",
["If stealth block (W)"] = "當隱身時不釋放W",
["If stealth block (R)"] = "當隱身時不釋放R",
["[Twitch] - (W) Settings"] = "[圖奇] - W技能設置",
["Use (W) for:"] = "W技能釋放：",
["When X stacks"] = "當有X層被動",
["IF When X Stacks Need Picked"] = "當有X層被動需要被選擇",
["Stack Number"] = "被動層數",
["Auto use if X enemy hitable"] = "當X名目標可被釋放時",
["Numbers enemy"] = "敵人數量",
["If my Mana > X% "] = "如果藍量大于X%",
["HitChance"] = "擊中的可能性",
["[Twitch] - (E) Settings"] = "[圖奇] - E技能設置",
["Use (E) for:"] = "E技能釋放：",
["For Execute"] = "可以擊殺敵人時",
["When 6 Stacks"] = "6層被動時",
["If For execute Picked"] = "如果選擇的敵人可以擊殺",
["Use if X enemi executable"] = "如果X名敵人可以擊殺",
["Unit Executable Without Ultimate: "] = "單位可以不用大招擊殺",
["Unit Executable Under Ultimate: "] = "單位可以用大招擊殺",
["If When 6 Stacks Picked"] = "如果選擇的敵人有6層被動",
["When X enemy got 6 stacks"] = "當X名敵人有6層被動",
["Force Execute if unit killable"] = "如果目標可以被擊殺強制釋放",
["Keep Mana For (E)"] = "保留E技能的藍量",
["[Twitch] - (R) Settings"] = "[圖奇] - R技能設置",
["Use (R) if X enemy in range"] = "如果X名敵人在範圍內使用R",
["Enemy Max Range: "] = "敵人最大距離",
["Use (R) if X ally in range"] = "如果X名友軍在範圍內",
["Ally Max Range: "] = "友軍最大距離",
["[Twitch] - Tower Dive Settings"] = "[圖奇] - 越塔設置",
["Use (R) for dive"] = "越塔時使用R",
["Only if (E) Ready"] = "只當E技能好時",
["Target life < X% hp"] = "當目標生命值小于X%",
["[Twitch] -  Item Settings"] = "物品設置",
["[Twitch] -  Auto Buy Settings"] = "自動購買設置",
["[Twitch] - Draw Settings"] = "顯示設置",
["Draw Stealth State"] = "顯示隱身狀態",
["Draw Ulti Time left"] = "顯示R技能剩余時間",
["[Twitch] - Jungle Steal Settings"] = "[圖奇] - 搶野怪設置",
["[Twitch] - OrbWalk Settings (SBTW)"] = "[圖奇] - 走砍設置",
["AmberCarries - Lucian"] = "女王ADC合集 - 盧錫安",
["[Lucian] - Combo Settings"] = "[盧錫安] - 連招設置",
["Combo Order "] = "連招順序",
["No Order"] = "無序",
["[Lucian] - Harass Settings"] = "[盧錫安] - 騷擾設置",
["Mana > X%:"] = "藍量大于X%",
["[Lucian] - LaneClear Settings"] = "[盧錫安] - 清線設置",
["LaneClear Key"] = "清線按鍵",
["[Lucian] - Spells Settings"] = "技能設置",
["(Q) Settings"] = "Q技能設置",
["Use on Minion for hit Target"] = "當可以穿小兵擊中敵人時",
["Use if unit out range"] = "當目標在範圍外時",
["~ AND ~"] = "~ & ~",
["Unit Health < X%:"] = "目標血量小于X%",
["AutoMove"] = "自動移動",
["Use Only if ComboKey Press"] = "僅當連招按鍵按下時",
["Use E if needed"] = "如果需要的時候使用E",
["[Lucian] -  Item Settings"] = "[盧錫安] - 物品設置",
["[Lucian] -  Auto Buy Settings"] = "[盧錫安] - 自動購買設置",
["[Lucian] - Gap Closer Settings"] = "[盧錫安] - 反突進設置",
["[Lucian] - Draw Settings"] = "[盧錫安] - 顯示設置",
["Draw (E) CD"] = "顯示E技能CD",
["[Lucian] - OrbWalk Settings"] = "[盧錫安] - 走砍設置",
["Zyra"] = "婕拉",
["AmberCarries - Vayne"] = "女王ADC合集 - 薇恩",
["[Vayne] - Combo Settings (SBTW)"] = "[薇恩] - 連招設置",
["[Vayne] - Wall Tumble Settings"] = "[薇恩] - 穿牆設置",
["Wall Tumble Key"] = "穿牆按鍵",
["[Vayne] - Harass Settings"] = "[薇恩] - 騷擾設置",
["[Vayne] - Lane Clear Settings"] = "[薇恩] - 清線設置",
["If my mana > X%"] = "如果藍量大于X%",
["[Vayne] - Spell Settings"] = "[薇恩] - 技能設置",
["Use (Q) for:"] = "使用Q用以：",
["Reset AA CD"] = "重置普攻",
["When Castable"] = "當可用時",
["Proc W + Reset AA CD"] = "觸發W + 重置普攻",
["Use (Q) for Kite"] = "用Q來風箏敵人",
["Max Range to Enemy for Kite"] = "風箏敵人的最大距離",
["Force (Q) if unit not in AA Range"] = "如果目標不在普攻範圍強制Q",
["Stun"] = "眩暈",
["Reset AA & Stun"] = "重置普攻 + 眩暈",
["Stun Chance"] = "眩暈的機會",
["Auto Stun"] = "自動眩暈目標",
["Max Wall Range For Stunt"] = "眩暈時離牆的最大距離",
["Use (R) if:"] = "以下情況使用R",
["Target life < %"] = "目標生命小于X%",
["My life > %"] = "自己生命值大于X%",
["Minimum Enemi in Range: "] = "在範圍內最少有X名敵人",
["Minimum Ally in Range: "] = "在範圍內最少有X名友軍",
["Keep Invisibily"] = "保持隱身狀態",
["Only if closest enemy"] = "僅當自己被突進",
["[Vayne] - Tower Dive Settings"] = "[薇恩] - 越塔設置",
["Use (Q) for Tower Dive"] = "用Q技能來越塔",
["[Vayne] - KillSteal Settings"] = "[薇恩] - 搶人頭設置",
["Use (E) in KillSteal"] = "用E來搶人頭",
["[Vayne] - Gap Closer Settings"] = "[薇恩] - 反突進設置",
["[Vayne] - Interupte Spell Settings"] = "[薇恩] - 打斷技能",
["[Vayne] -  Item Settings"] = "[薇恩] - 物品設置",
["[Vayne] -  Auto Buy Settings"] = "[薇恩] - 自動購買物品",
["[Vayne] - Draw Settings "] = "顯示設置",
["Draw (Q) type: "] = "顯示Q的類型",
["Draw (E) Predict on unit"] = "顯示E技能的預判",
["Draw Damage"] = "顯示傷害",
["Draw WallTumble Circle"] = "顯示穿牆的圓圈",
["[Vayne] - OrbWalk Settings (SBTW)"] = "[薇恩] - 走砍設置",
["No enemy heroes were found!"] = "沒有發現敵人",
--------------------絕對妖姬--------------------------
["Leblanc's Skillshots Settings"] = "樂芙蘭技能彈道設置",
["[eSkillShot] Spell Settings"] = "[E技能彈道設置]",
["Override Minimum Hit % "] = "覆蓋最小命中率",
["Overriden Minumum Hit %"] = "被覆蓋的最小命中率",
["Prediction Cooldown (ms)"] = "預判冷卻時間(ms)",
["[wSkillShot] Spell Settings"] = "[W技能彈道設置]",
["Totally LeBlanc - Totally Legit"] = "絕對妖姬",
["Totally LeBlanc  -  Key Settings"] = "絕對妖姬 - 按鍵設置",
["Combo GapClose Key"] = "突進連招按鍵",
["Combo Chain Key"] = "幻影鎖鏈連招按鍵",
["Farm Key"] = "發育按鍵",
["Totally LeBlanc  -  Combo"] = "絕對妖姬 - 連招",
["Ethereal Chains (E)"] = "幻影鎖鏈(E)",
["Max range:"] = "最大範圍",
["Min width:"] = "最小寬度",
["Draw range"] = "顯示技能範圍",
["Perform Combo:"] = "使用的連招",
["Use AAs"] = "使用平A",
["Use W to GapClose"] = "使用W接近目標",
["Force ADC/APC"] = "強制攻擊ADC/APC",
["Totally LeBlanc  -  Settings: W"] = "絕對妖姬 - W技能設置",
["Use Optional W Settings"] = "使用自定義W技能設置",
["Return: "] = "返回: ",
["Target dead"] = "目標死亡",
["Skills used"] = "技能用完",
["Both"] = "以上兩者",
["Totally LeBlanc  -  Harass"] = "絕對妖姬 - 騷擾",
["Use Sigil of Malice (Q)"] = "使用惡意魔印(Q)",
["Use Distortion (W)"] = "使用魔影迷蹤(W)",
["Use Ethereal Chains (E)"] = "使用幻影鎖鏈(E)",
["Mana Manager %"] = "藍量控制%",
["Totally LeBlanc  -  Farming"] = "絕對妖姬 - 發育",
["Minions outside AA range only"] = "只對在平A距離外的小兵使用",
["Farm if AA is on CD"] = "在平A的間隙使用技能發育",
["Totally LeBlanc  -  Laneclear"] = "絕對妖姬 - 清線",
["Use Mimic (R)"] = "使用故技重施(R)",
["Min minions to WR"] = "使用WR的最少小兵數",
["Min minions to W and WR"] = "使用W和WR的最少小兵數",
["Totally LeBlanc  -  KillSteal"] = "絕對妖姬 - 搶人頭",
["Excecute"] = "",
["Not in Combo"] = "不在連招中使用",
["No other mode active"] = "其他模式未激活時",
["GapClose to kill enemy"] = "突進以擊殺敵人",
["Gapclose > Q + R"] = "突進優先于Q+R",
["KillSteal Enemy"] = "使用搶人頭的對象",
["Totally LeBlanc  -  Drawings"] = "絕對妖姬 - 顯示",
["Lag-Free Circles"] = "不影響延遲的線圈",
["Use Lag-Free Circles"] = "使用不影響延遲的線圈",
["Length before Snapping"] = "",
["Use Drawings"] = "使顯示",
["Draw Sigil of Malice (Q)"] = "顯示惡意魔印(Q)",
["Draw Distortion (W)"] = "顯示魔影迷蹤(W)",
["Draw Ethereal Chains (E)"] = "顯示幻影鎖鏈(E)",
["Draw Killable Text"] = "顯示可擊殺提示",
["Draw Killable Width"] = "顯示擊殺提示的寬度",
["Don't draw if spell is CD"] = "技能cd時不顯示線圈",
["Totally LeBlanc  -  Prediction"] = "絕對妖姬 - 預判",
["Prediction Type:"] = "預判類型",
["VPrediction HitChance"] = "V預判的命中率",
["DivinePred HitChance"] = "神聖預判的命中率",
["Totally LeBlanc  -  Misc"] = "絕對妖姬 - 雜項",
["Auto Level"] = "自動加點",
["Use Auto Level"] = "使用自動加點",
["What to max?"] = "哪個技能先滿級？",
["Use Summoner Ignite"] = "使用點燃",
["Zhyonas"] = "中亞",
["Use Zhonyas under % health"] = "生命值低于%時使用中亞",
["Auto Ignite Potion"] = "自動點燃血瓶",
["Drink Health Pot when Ignited"] = "被點燃時自動吃血瓶",
["Totally LeBlanc  -  OrbWalker"] = "絕對妖姬 - 走砍",
["Totally LeBlanc  -  TargetSelector Modes"] = "絕對妖姬 - 目標選擇器模式",
["License"] = "許可",
["Patch: "] = "版本",
["Farm"] = "發育",
------------------王者視圖------------------
["--------- LANGUAGE --------"] = "--------- 語言選擇 ---------",
["Language"] = "語言",
["English"] = "英語",
["German"] = "德語",
["Portuguese"] = "葡萄牙語",
["Spanish"] = "西班牙語",
["French"] = "法語",
["Italian"] = "意大利語",
["Turkish"] = "土耳其語",
["Polski"] = "波蘭語",
["------ Quick Toggles ------"] = "------ 快捷開關 ------",
["Hidden Objects"] = "隱形的單位",
["Aggro targets"] = "仇恨的目標",
["Side HUD"] = "HUD顯示",
["Waypoints"] = "行進路線",
["Minimap SS"] = "小地圖消失顯示",
["Clone revealer"] = "分身探測器",
["Clone Revealer"] = "分身探測器",
["Recall Alert"] = "回城提示",
["Tower Ranges"] = "防禦塔範圍",
["Minimap Timers"] = "小地圖計時器",
["Lasthit Helper"] = "尾刀助手",
["Notification System"] = "提醒系統",
["Spell Timer Drawings"] = "技能計時器顯示",
["Other drawings"] = "其他顯示",
["Sounds"] = "聲音",
["Use sprites on minimap"] = "在小地圖顯示圖片",
["Draw enemy team wards"] = "顯示敵人眼位",
["Draw enemy team traps"] = "顯示敵人的陷阱",
["Draw own team wards"] = "顯示己方眼位",
["Draw own team traps"] = "顯示己方陷阱",
["Draw type"] = "顯示樣式",
["Circular"] = "圓形的",
["Precise"] = "精確的",
["Circles quality"] = "線圈質量",
["Add Custom Ward Key"] = "添加習慣性眼位按鍵",
["Remove Custom Ward Key"] = "移除習慣性眼位按鍵",
["Key to hold to draw range"] = "按住顯示範圍按鍵",
["Key to toggle draw range"] = "開關顯示範圍按鍵",
["Expiring wards"] = "即將消失的眼位",
["Change expiring wards color"] = "修改即將消失的眼位的顏色",
["Expiring wards color"] = "即將消失的眼位的顏色",
["Change color below (seconds)"] = "在眼位時間小于x秒時改變顏色",
["Custom Wards"] = "習慣性眼位",
["Enemy Sight Wards"] = "敵人的假眼",
["Enemy Vision Wards"] = "敵人的真眼",
["Enemy Traps"] = "敵人的陷阱",
["Ally Sight Wards"] = "友軍的假眼",
["Ally Vision Wards"] = "友軍的真眼",
["Ally Traps"] = "友軍的陷阱",
["Circles and lines"] = "線圈和線條",
["Lines"] = "指示線",
["Width of lines and circles"] = "線圈和線條的寬度",
["Quality of circle"] = "線圈的質量",
["Side enemy HUD"] = "側邊敵人HUD顯示",
["HUD horizontal position"] = "HUD水平位置",
["HUD vertical position"] = "HUD垂直位置",
["Summ cds"] = "召喚師技能cd",
["Seconds"] = "秒",
["Game time"] = "遊戲時間",
["Scale"] = "比例",
["Cooldowns Tracker"] = "冷卻時間計時",
["Show enemy QWER cooldowns"] = "顯示敵人QWER冷卻",
["Classic"] = "經典",
["Classic R"] = "經典 R",
["Show enemy summoner cooldowns"] = "顯示敵人召喚師技能冷卻",
["Show ally QWER cooldowns"] = "顯示友軍QWER冷卻",
["Show ally summoner cooldowns"] = "顯示友軍召喚師技能冷卻",
["Show my QWER cooldowns"] = "顯示自己QWER冷卻",
["Show my summoner cooldowns"] = "顯示自己的召喚師技能冷卻",
["Cooldown"] = "冷卻時間",
["No mana to cast"] = "沒藍放技能",
["No energy to cast"] = "沒能量放技能",
["No valid targets"] = "沒有可用目標",
["CD spell/text"] = "技能CD文字",
["Unknown"] = "未知",
["Draw paths also on minimap"] = "在小地圖顯示路徑",
["Draw enemy path"] = "顯示敵軍路徑",
["Draw enemy path time"] = "顯示敵軍路徑時間",
["Draw ally path"] = "顯示友軍路徑",
["Draw ally path time"] = "顯示友軍路徑時間",
["Cross type"] = "十字交叉類型",
["Light"] = "輕量的",
["Ally cross color"] = "友軍十字交叉顏色",
["Enemy cross color"] = "敵軍十字交叉顏色",
["Ally lines color"] = "友軍指示線顏色",
["Enemy lines color"] = "敵人指示線顏色",
["Cross size (only Normal type)"] = " ",
["Cross width (only Normal type)"] = " ",
["Show missing timer"] = "顯示丟失的計時器",
["Show grey icon"] = "顯示灰色圖標",
["Draw timer after (seconds)"] = "x秒後顯示計時器",
["Text color for SS timer"] = "丟失視野計時器文字顏色",
["Autoping SS (bol broken)"] = "丟失視野自動標記(bol功能損壞)",
["Auto SS enabled"] = "使視野丟失提醒",
["Autoping SS after (seconds)"] = "丟失視野x秒後自動標記",
["Clone-able player circle color"] = "有分身的敵人線圈顏色",
["Circle quality"] = "線圈質量",
["Mark all enemy heroes"] = "標記所有敵方英雄",
["Draw recall sprite on minimap"] = "在小地圖上顯示回城圖片",
["Recall Bar color"] = "回城讀條的顏色",
["Recall Bar background color"] = "回城讀條的背景顏色",
["Teleport Bar color"] = "傳送讀條的顏色",
["Teleport Bar background color"] = "傳送讀條的背景顏色",
["Color chat messages"] = "消息框消息顏色",
["Print recall cancel"] = "顯示回城取消",
["Print teleport cancel"] = "顯示傳送取消",
["Min distance to draw range"] = "顯示範圍線圈的最小距離",
["Quality of towers ranges"] = "防禦塔範圍線圈的質量",
["Width of towers ranges"] = "防禦塔範圍線圈的寬度",
["Draw own team towers ranges"] = "顯示己方防禦塔範圍",
["Own towers range color"] = "己方防禦塔範圍顏色",
["Draw enemy towers ranges"] = "顯示敵方防禦塔範圍",
["Enemy towers ranges color"] = "敵方防禦塔範圍顏色",
["Enemy towers ranges color (danger)"] = "敵方防禦塔範圍(危險)",
["Enemy towers ranges color (aggro)"] = "敵方防禦塔範圍(被鎖定)",
["Jungle Camps timers"] = "打野計時",
["Jungle Camps text size"] = "打野計時文字大小",
["Jungle Camps text color"] = "打野計時文字顏色",
["(bol broken) Ping when big monsters respawns"] = "大型野怪複活時標記(bol功能損壞)",
["Only me"] = "只是自己",
["My team"] = "己方隊伍",
["Jungle camps to draw"] = "顯示的野怪營地",
["Wight"] = "大幽靈",
["Red and Blue"] = "紅藍buff",
["Razorbeaks"] = "鋒喙鳥",
["Murkwolves"] = "幻影狼",
["Crabs"] = "螃蟹",
["Inhibitors timers"] = "水晶計時器",
["Towers health (%)"] = "防禦塔生命值(百分比顯示)",
["Towers health (numeric)"] = "防禦塔生命值(數值顯示)",
["Inhibs/Tower Hp text size"] = "水晶/防禦塔生命值文字大小",
["Inhibs/Tower Hp text color"] = "水晶/防禦塔生命值文字顏色",
["Horizontal offset"] = "水平預設",
["Vertical offset"] = "垂直預設",
["Distance from player to draw helper"] = "顯示補刀助手時離玩家的距離",
["Healthbar color of killable minion"] = "可被擊殺的小兵血條顏色",
["Type of drawing for last hittable minions"] = "可被尾刀的小兵血條顯示樣式",
["Mark Healthbar"] = "標記血條",
["Draw circle"] = "顯示線圈",
["Force enabling"] = "強制生效",
["Max notifies at the same time"] = "同時顯示的最大提醒條目數",
["Duration of notifies"] = "提醒的持續時間",
["Color of notifies"] = "提醒的文字顏色",
["---- Events to show ----"] = "---- 事件提示 ----",
["An enemy disconnects"] = "壹個敵軍掉線",
["(bol broken) Ally ping SS"] = "(bol功能損壞)友軍標記敵軍消失",
["Red/Blue respawn"] = "紅藍buff重生",
["Dragon/Baron/Vilemaw respawn"] = "小龍/大龍/卑鄙之喉重生",
["Enemy gank incoming"] = "即將到來的敵人Gank",
["Spells casted"] = "被使用的技能",
["Rengar R"] = "獅子狗R",
["Pantheon R (1st)"] = "潘森壹段大招(墮天壹擊)",
["Pantheon R (land)"] = "潘森二段大招(著陸)",
["TwistedFate R1 (Destiny)"] = "卡牌壹段大招(命運)",
["TwistedFate R2 (Gate)"] = "卡牌二段大招(傳送)",
["Map Drawings"] = "小地圖顯示",
["--- Jungle timers ---"] = "--- 打野計時 ---",
["Camp respawn"] = "野怪營地重生",
["--- Spell timers ---"] = "--- 技能計時 ---",
["Akali Bubble"] = "阿卡麗的奧義!霞陣(W)",
["Tryndamere Ultimate"] = "泰達米爾的大招",
["Kayle Ultimate"] = "凱爾的大招",
["Pantheon Ultimate"] = "潘森的大招",
["Twisted Fate Ultimate"] = "卡牌的大招",
["Thresh Lantern"] = "錘石的燈籠",
["Gangplank Ultimate"] = "船長的大招",
["Braum Shield"] = "布隆的盾牌",
["Fiddlesticks Ultimate"] = "稻草人的大招",
["Warwick Ultimate"] = "狼人的大招",
["Wukong Decoy"] = "猴子W",
["Wukong Ultimate"] = "猴子的大招",
["Rammus Ultimate"] = "龍龜的大招",
["Nasus Ultimate"] = "狗頭的大招",
["Renekton Ultimate"] = "鱷魚的大招",
["Alistar Ultimate"] = "牛頭的大招",
["Amumu Ultimate"] = "阿木木的大招",
["Graves grenade"] = "男槍的W",
["Morgana shield"] = "莫甘娜的盾",
["Karthus Wall"] = "死歌的W",
["Blitzcrank shield"] = "機器人的被動",
["Galio Ultimate"] = "加�媔曭漱j招",
["Taric Ultimate"] = "寶石的大招",
["Anivia egg"] = "冰鳥的蛋",
["Mundo Ultimate"] = "蒙多的大招",
["Autoattack ranges"] = "平A範圍",
["--------- Enemies --------"] = "--------- 敵軍 --------",
["Full circle"] = "完整線圈",
["Perpendicular line"] = "垂直線",
["Circle section"] = "線圈部分",
["Distance from you to draw"] = "顯示時離妳的距離",
["Color of range"] = "線圈顏色",
["--------- My hero --------"] = "--------- 自己的英雄 --------",
["Distance from enemy to draw"] = "顯示時離敵軍的距離",
["Show for"] = "顯示的對象",
["Sound type"] = "聲音類型",
["Gank alert"] = "gank提示",
["Enemy Red/Blue respawn"] = "敵方紅藍buff重生",
["Ally Red/Blue respawn"] = "己方紅藍buff重生",
["Dragon/Baron respawn"] = "大龍/小龍重生",
["Dragon/Baron under attack"] = "大龍/小龍被攻擊",
["Early game ends at minute"] = "遊戲前期結束的時間",
["Store chats"] = "商店對話",
["Hide loaded message"] = "隱藏加載信息",
["Reload sprites button"] = "重新加載圖片按鈕",
["Show surrender votes"] = "顯示投降投票信息",
["Real Life Info"] = "實際生活信息",
["Show date"] = "顯示日期",
["Show time"] = "顯示時間",
["Color of infos"] = "信息的顏色",
["Show latency and FPS"] = "顯示fps和延遲",
["Horizontal position"] = "水平位置",
["Draw experience range"] = "顯示經驗獲得範圍",
["Disable after early game (see 'Other')"] = "遊戲前期之後關閉",
["Color of experience range circle"] = "經驗獲得範圍線圈的顏色",
["Quality of exp range circle"] = "經驗獲得範圍線圈的質量",
["Width of exp range circle"] = "經驗獲得範圍線圈的寬度",
["Minion Bar"] = "小兵血條",
["Missed CS"] = "漏刀計數",
["Troubleshooting"] = "疑難解答",
["Disable sprites (need reload)"] = "關閉圖片顯示(需要重新加載)",
["Disable fullscreen warning (need reload)"] = "關閉全屏警告(需要重新加載)",
["Color of timers"] = "計時器顏色",
["Silenced"] = "沈默",
["AutoAttack ranges"] = "平A範圍線圈",
--------------------------奇妙德萊文-------------------
["Fantastik Draven"] = "奇妙德萊文",
["Combo key(Space)"] = "連招按鍵(空格)",
["Farm key(X)"] = "發育按鍵(X)",
["Harass key(C)"] = "騷擾按鍵(C)",
["Min. % mana for W and E "] = "使用W和E的最小藍量",
["Laneclear Settings"] = "清線設置",
["Use Q in 'Laneclear'"] = "在清線中使用Q",
["Use W in 'Laneclear'"] = "在清線中使用W",
["Jungleclear Settings"] = "清野設置",
["Use Q in 'Jungleclear'"] = "在清野中使用Q",
["Use W in 'Jungleclear'"] = "在清野中使用W",
["Draw Killable targets with R"] = "顯示R能夠擊殺的目標",
["Misc"] = "雜項",
["KillSteal Settings"] = "搶人頭設置",
["Use Ult KS"] = "使用大招搶人頭",
["Avoid R Overkill"] = "避免",
["Ult KS range"] = "大招搶人頭的範圍",
["Use Ignite KS"] = "使用點燃搶人頭",
["Catch axe if only in mouse range"] = "只接在鼠標範圍內的斧頭",
["Farm/Harass"] = "發育/騷擾",
["Use maximum 2 Axes"] = "使用最多2個斧頭",
["Draw mouse range"] = "顯示鼠標範圍",
["Lag Free circle"] = "不影響延遲的線圈",
["Mouse Range"] = "鼠標範圍",
["Evadeee Integration(If loaded)"] = "Evadeee結合(如果加載)",
["Don't catch if axe in turret"] = "不要接在塔下的斧頭",
["Auto-Interrupt"] = "自動打斷",
["Info"] = "信息",
["Anti-Gapclosers"] = "反突進",
["Baseult settings"] = "基地大招設置",
["Health Generation prediction"] = "生命值回複預判",
["Disable R"] = "禁用R",
["Sensetive Delay(.3 def)"] = "靈敏度延遲",
["Catch Axes(Z)"] = "接斧頭(Z)",
["Use W to reach far Axes"] = "使用W接比較遠的斧頭",
["Draw Debug"] = "顯示調試",
["Enable Permabox(reload)"] = "使狀態顯示(需要重新加載)",
["Left Click target lock"] = "左鍵單擊目標鎖定",
["Orbwalker"] = "走砍",
-----------------DD2-----------------
["Riven - Broken Wings"] = "銳雯 - Broken Wings",
["Broken Wings [Main]"] = "Broken Wings [主要設置]",
["Main [Spells]"] = "主要設置 [技能]",
["Use [Q - Broken Wings]"] = "使用 [Q - 折翼之舞]",
["Use [W - Ki Burst]"] = "使用 [W - 震魂怒吼]",
["Use Youmus Ghostblade"] = "使用幽夢之靈",
["Main [Initiator]"] = "主要設置 [連招起手]",
["After E -> W"] = "E之後W",
["Force AA"] = "強制平A",
["Let Broken Wings decide"] = "由腳本決定",
["Main [Gapclose]"] = "主要設置 [突進]",
["Gapclose [Q - Broken Wings]"] = "突進 [Q - 折翼之舞]",
["In Combo"] = "在連招中",
["In Combo + Target is left-clicked"] = "在連招中且目標被左鍵單擊鎖定",
["Gapclose [E - Valor]"] = "突進 [E - 勇往直前]",
["Main [Force R]"] = "主要設置 [強制大招]",
["Cast R1 after next Animation"] = "在下個動作之後使用壹段R",
["Cast R2"] = "使用二段R",
["Force R2 -> Q3"] = "強制在二段R之後使用三段Q",
["Force R On/Off"] = "強制R 開/關",
["Broken Wings [Utility]"] = "Broken Wings [功能設置]",
["Utility [Killsteal]"] = "功能設置 [搶人頭]",
["Use [R2 - Windslash]"] = "使用 [R2 - 疾風斬]",
["Utility [Defensive]"] = "功能設置 [防禦]",
["Auto W"] = "自動W",
["Broken Wings [Flee]"] = "Broken Wings [逃跑]",
["Use [E - Valor]"] = "使用 [E - 勇往直前]",
["Broken Wings [LastHit]"] = "Broken Wings [尾刀]",
["Draw Minion Health Bar Lines"] = "在小兵血條顯示指示線",
["Last Hit Adjustment"] = "尾刀調整",
["Earlier"] = "提早",
["Later"] = "推遲",
["Last Hit Adjustment (Value)"] = "尾刀調整(數值)",
["Broken Wings [JungleClear]"] = "Broken Wings [清野]",
["Left click + Combo Key"] = "左鍵 + 連招按鍵",
["Broken Wings [Harrass]"] = "Broken Wings [騷擾]",
["Harrass Key"] = "騷擾按鍵",
["BW E Settings"] = "Broken Wings [E技能設置]",
["BW Visuals"] = "Broken Wings [顯示設置]",
["Draw Range AA"] = "顯示平A範圍",
["Draw Range Q"] = "顯示Q範圍",
["Draw Range W"] = "顯示W範圍",
["Draw Range E"] = "顯示E範圍",
["Draw Range R2"] = "顯示二段R範圍",
["Draw left-clicked Target"] = "顯示左鍵單擊的目標",
["Awareness Q"] = "Q技能冷卻顯示",
["Awareness R"] = "R技能冷卻顯示",
["Awareness left-clicked Target"] = "左鍵單擊目標意識顯示",
["BW Advanced"] = "Broken Wings [高級設置]",
["Q-AA Logic"] = "QA邏輯",
["Low Ping - Stable"] = "低延遲 - 穩定模式",
["High Ping - Predicted"] = "高延遲 - 動作預判模式",
["Cancel Animation"] = "取消動作",
["Dance"] = "跳舞",
["Laugh"] = "大笑",
["Silent"] = "無聲",
["Extra WindUpTime AA"] = "額外平A後搖時間",
["Extra WindUpTime Q-AA"] = "額外QA後搖時間",
["Core Processing"] = "核心處理",
["Section 1"] = "部分1",
["Section 2"] = "部分2",
["Cancel manual Broken Wings(Q)"] = "取消手動Q的後搖",
["Stop Move over MousePos"] = " ",
["BW Combo Key"] = "Broken Wings [連招按鍵]",
["BW Version"] = "Broken Wings [版本號]",
["No Targeted Spells Found"] = "沒有找到指向性技能",
-------------------Pew走砍----------------
["Pewalk"] = "Pew走砍",
["Keys"] = "按鍵",
["-Skills-"] = "- 技能 -",
["SKILLS: Lane Clear"] = "技能:清線",
["-Orbwalking-"] = " - 走砍 -",
["Carry (SBTW)"] = "連招",
["Mixed"] = "騷擾",
["Key"] = "按鍵",
["Toggle"] = "開關",
["Draw Attack Range"] = "顯示平A範圍",
["Target Selection"] = "目標選擇",
["Prioritize Selected Target"] = "鎖定的目標優先",
["Draw Current Target"] = "顯示當前的目標",
["Low FPS"] = "低fps線圈",
["-Priorities-"] = "- 優先級 -",
["Skill Farming"] = "技能發育",
["Reset: Broken Wings"] = "預設:Broken Wings",
["Only under turret"] = "只在塔下",
["Double Edged Sword"] = "雙刃劍",
["Opressor"] = "恃強淩弱",
["Bounty Hunter"] = "賞金獵人",
["Savagery"] = "野蠻",
["[Humanizer] Movement Interval"] = "[擬人化] 移動間隔",
["Stop Movement"] = "停止移動",
["Left Mouse Button Down"] = "左鍵按下時",
["Mouse Over Hero"] = "英雄在鼠標下時",
["Last Hit Adjustment (ms)"] = "尾刀調整(ms)",
["Support Mode"] = "輔助模式",
--------------------bigfat ez----------------------
["Big Fat Ezreal"] = "Big Fat伊澤瑞爾",
["[Mode]"] = "[模式]",
["Settings Mode:"] = "設置模式",
["Recommended"] = "推薦設置",
["Expert"] = "專家設置",
["If you want to change back to Recommended"] = "如果妳想恢複推薦設置",
["change it and press double f9"] = "改變模式後請按2下F9",
["Ignore SxOrbwalk"] = "忽略走砍",
["dont force loading big fat walk"] = "不強制讀取Big Fat走砍",
["Current Prediction: Big Fat Vanga ver.: (1.3)"] = "目前預判：Big Fat 版本1.3",
["Toggle: Q"] = "開關Q",
["Toggle: W"] = "開關W",
["Bitch plx: WE 2 Mouse"] = "WE二連到鼠標位置",
["Big Fat Ezreal v. 0.25"] = "Big Fat伊澤瑞爾 V0.25",
["obviously by Big Fat Team"] = "Big Fat團隊出品",
["[Draws]"] = "[圖形顯示]",
["Based on Range Dmg Info"] = "根據距離傷害信息",
["Draw Target Info"] = "顯示目標信息",
["[HitChance]"] = "[命中幾率]",
["[Kill Steal]"] = "[搶人頭]",
["Chance: "] = "幾率",
["R Chance: "] = "R幾率",
["[Custom Settings]"] = "[自定義設置]",
["Q: Enable Vanga Dashes"] = "Q：開啟突進",
["W: Enable Vanga Dashes"] = "W：開啟突進 ",
["[KS Options]"] = "[搶人頭選項]",
["Enable KS"] = "開啟搶人頭",
["KS with Q"] = "使用Q搶人頭",
["KS with R"] = "使用R搶人頭",
["max R Range: "] = "最大R距離",
["min R Range: "] = "最小R距離",
["Q: Use mana till :"] = "Q：魔法值限制",
["W: Use mana till :"] = "W：魔法值限制",
["Use Whitelist"] = "使用白名單",
["Whitelist Distance"] = "白名單距離",
["exception if White List Out Of Range"] = " 如果白名單超出距離除外",
["exception if do more dmg to other target"] = "如果能對其他目標造成更多傷害除外",
["enable this filter"] = "使用這個過濾器",
["[Key Binds]"] = "[按鍵綁定]",
["automaticly take binds from Orbwalk"] = "自動使用走砍設置按鍵",
-------------------------bigfat走砍------------------------
["Big Fat Orbwalker"] = "Big Fat走砍",
["Draw Prediction and Dmg"] = "顯示預判和傷害",
["Use harass in LaneClear"] = "在清線中使用騷擾",
["Draw Range"] = "顯示線圈",
["Support mode"] = "輔助模式",
["Extra WindUp Time"] = "額外後搖時間",
["Twin Shadows 1"] = "雙生暗影1",
["Twin Shadows 2"] = "雙生暗影2",
["Frost Queen's Claim"] = "冰霜女王的指令",
["Youmuu's Ghostblade"] = "幽夢之靈",
["Odyn's Veil"] = "女妖面紗",
["Muramana 2"] = "魔宗2",
["Randuin's Omen"] = "蘭頓之兆",
["Muramana 1"] = "魔宗1",
["KeyBinds"] = "按鍵",
["Big Fat Orbwalker v. 0.51"] = "Big Fat走砍 v. 0.51",
["by Big Fat Team"] = "Big Fat團隊出品",
-------------------------pew女警---------------------------
["PewCaitlyn"] = "PEW女警",
["Piltover Peacemaker"] = "和平使者(Q)",
["Use in Carry Mode"] = "連招模式使用",
["Harass in Mixed Mode"] = "騷擾模式使用",
["Harass in Clear Mode"] = "清線模式使用",
["Peacemaker Control Method"] = "和平使者使用模式",
["Calculated"] = "計算",
["Manual Control Key"] = "手動控制鍵",
["Cast HitChance [3==Highest]"]	=	 "能命中3個目標時使用（3個是最多）",
["Maximum Minion Collision"] = "最大化小兵碰撞",
["Use for Last Hits"] = "尾刀時使用",
["** Only when AA is on CD"] = "** 只在普攻冷卻時使用",
["Always Save Mana for E"] = "總是為E保留魔力",
["Draw Peacemaker Range"] = "顯示和平使者距離",
["Yordle Snap Trap"] = "約德爾誘捕器(W)",
["Cast on Target Path"] = "在目標路徑上使用",
["Trap Channel Spells"] = "引導型法術放置陷阱",
["Trap Crowd Control"] = "群控中放置",
["Trap Revives (GA / Chronoshift)"] = "放置在即將複活的敵人身邊（守護天使/時光大招）",
["Trap Teleports"] = "放置在傳送點",
["Trap on Lose Vision (Grass)"] = "放置在沒有視野的地方（草叢）",
["Draw Active Trap Timers"] = "顯示陷阱時間",
["90 Caliber Net"] = "90口徑網繩(E)",
["Net To Mouse"] = "向鼠標位置發射",
["Block Failed Wall Jumps"] = "阻止失敗的越牆",
["Do Not Block if Will Jump This Far"] = "如果跳的很遠不阻止",
["Ace in the Hole"] = "讓子彈飛(R)",
["Draw Can Kill Alert"] = "顯示可以大招擊殺提示",
["Draw Line to Killable Character"] = "用連線方式顯示妳和目標",
["Draw Health Remaining Indicator"] = "顯示剩余生命值指示",
["Kill Key"] = "擊殺鍵",
["Use Automatically"] = "自動使用",
["-Other-"] = "-其他-",
["E - Q Combo"] = "E-Q二連",
["Movement Interval"] = "移動間隔",
--------------------bigfat金克斯---------------------
["Jinx, Bombs and Bullets"] = "槍炮金克斯",
["Recall Kill Settings"] = "回城擊殺設置",
["Use On"] = "開啟",
["On - Recall Spot Only"] = "開啟-只擊殺妳視野能發現的回城",
["Additional Damage Buffer %"] = "額外傷害溢出%",
["Show recall messages"] = "顯示回城信息",
["Draw recall locations"] = "顯示回城地點",
["Use W combo if  mana is above"] = "如果魔法值在X以上使用W連招",
["Use R combo finisher"] = "使用R連招終結",
["Ward bush when they hide"] = "敵人進草插眼",
["Use QSS/Mercurial if hard CCed"] = "如果硬控很多使用水銀彎刀或水銀飾帶",
["Use W harass if  mana is above"] = "如果魔法值在X以上使用W騷擾",
["Lane Clear Key Switch to"] = "清線轉換成",
["Rocket"] = "火箭模式",
["Mini Gun"] = "機槍模式",
["Q Switch Method:"] = "Q模式轉化:",
["Switch weapon for:"] = "以下情況轉換武器模式:",
["Range & DPS"] = "距離和輸出",
["KS With W"] = "W搶人頭",
["Min W range"] = "W最小距離",
["Use Trap on CCed"] = "對被控制的敵人使用陷阱",
["Use Trap on Thresh/Blitz cast"] = "錘石和機器人施法時使用陷阱",
["Auto R max range"] = "自動最大距離R",
["Auto R frequency"] = "自動R的頻率",
["Force Ult Mode"] = "強制使用大招",
["Draw Alternate AA Range"] = "顯示AA範圍",
["Draw Auto (R) Max Range"] = "顯示自動R的最大距離",
["Draw R predicted spot"] = "顯示預計的R地點",
["Full Combo Key (SBTW)"] = "全套大招",
["Force Ult"] = "強制使用大招",
["Force Trap"] = "強制使用陷阱",
-------------------------------bigfat飛機-----------------------
["Big Fat Corki"] = "Big Fat飛機",
["Big Fat Corki v. 0.51"] = "Big Fat飛機 V0.51",
["Big One R - between minion and target:"] = "在小兵和目標之間R",
["max distance :"] = "最大距離",
["R: Enable Vanga Dashes"] = "R：使",
["R: Use mana till :"] = "R：在魔力值X時使用",
["E max Cast Distance"] = "最遠E的距離",
["E: Use mana till :"] = "E：在魔力值X時使用",
["Extra Settings"] = "其他設置",
["Force Exhaust"] = "強制虛弱",
["Heal Settings"] = "治療設置",
["--- Teammates to Heal ---"] = "---對隊友使用治療---",
["Shield'n'Heal"] = "護盾和治療",
["Item Manager"] = "物品管理",
["Mikael's Crucible"] = "米凱爾的坩堝",
["Cast it on Bard"] = "對巴德使用",
["CC + Health"] = "控制+治療",
["CC"] = "控制",
["Health"] = "治療",
["Heal: Min % to cast it"] = "治療：小于%血量使用",
["Humanizer: CC/Slow Delay (ms)"] = "擬人化延遲:控制/減速（毫秒）",
["CC: Usual debuffs"] = "控制：減益狀態",
["CC: Slow debuff"] = "控制：減速狀態",
["CC: Special cases"] = "控制：特殊情況",
["Face of the Mountain"] = "山嶽之容",
["--> Use Face of the Mountain"] = "使用山嶽之容",
["Use Locket of the Iron Solari in combat"] = "使用鋼鐵烈陽之匣",
["Use Zhonyas"] = "使用中婭",
["Use Frost Queen's Claim"] = "使用冰霜女皇的命令",
["Auto Brush Wards"] = "草叢自動插眼",
["Ward Brush when lose enemy vision"] = "當敵人進入草叢時插眼",
["Key 1"] = "按鍵1",
["Key 2"] = "按鍵2",
["Key 3"] = "按鍵3",
["Key 4"] = "按鍵4",
["Key 5"] = "按鍵5",
["Key 6"] = "按鍵6",
["Key 7"] = "按鍵7",
--------------------------funhouse---------------------------------------
["Bard Fun House"] = "燒傷輔助合集 - 巴德",
["Magical Journey"] = "神奇旅程",
["AFK Chimes"] = "AFK提示",
["Force Q Cast for slow"] = "強制使用Q減速",
["Force R with prediction"] = "強制使用有預判的R",
["--- Q Settings ---"] = "--- Q設置 ---",
["Extended Q Calculations"] = "延伸的Q計算",
["Cast Q to slow without Stun"] = "使用Q減速但不暈",
["--- W Settings ---"] = "--- W設置 ---",
["Use W for self heal"] = "使用W給自己治療",
["Maximum % Health to use (W)"] = "當血量少于%時使用W",
["Use W for allies in combat"] = "戰鬥中對友軍使用W",
["W ally only if Bard is safe"] = "只在自己安全的時候對友軍使用W",
["--- E Settings ---"] = "--- E設置 ---",
["Cast Q during escapes"] = "逃跑時使用Q",
["Use W during escapes"] = "逃跑時使用W",
["--- R Settings (BETA) ---"] = "--- R設置 ---",
["R Range Percent"] = "R距離百分比",
["Minimum % Mana to use (Q)"] = "法力高于X%時使用Q",
["Minimum % Mana to use (E)"] = "法力高于X%時使用E",
["Minimum % Mana to use (R)"] = "法力高于X%時使用R",
["--- Harass Settings ---"] = "騷擾設置",
["Use Mana Manager"] = "使用法力管理",
["Auto Chimes"] = "自動提示",
["Collect in enemy jungle"] = "在敵人野區使用",
["Behind ally + no enemies only"] = "友軍後方並且周圍沒有敵人",
["Safety distance vs enemy"] = "對敵安全距離",
["Cast Q Stun on encounter"] = "遭遇敵人使用Q暈",
["Cast W on encounter"] = "遭遇敵人使用W",
["Cast W for boost on full mana"] = "使用W加速(如果滿藍)",
["Cast E for shortcut"] = "使用E走捷徑",
["Smart R on enemies when in escape"] = " 追擊敵人智能使用R",
["Smart R on allies in danger"] = "當友軍有危險時使用R",
["Ward enemy discover location"] = "發現敵人的位置插眼",
["Anti Dash & Gapclose"] = "防突進",
["--- Anti Dash & Capclose  Settings ---"] = "--- 防突進設置 ---",
["Use Q for Dash & Gapclose"] = "使用Q防突進",
["Draw Q Extended"] = "顯示Q的延伸",
["Draw R target"] = "顯示R的目標",
["Debug Mode"] = "調試模式",
["Q2 Hit Chance"] = "Q2命中率",
["Blitzcrank"] = "機器人",
["Cast it on Janna"] = "對風女",
["Shield Manager"] = "護盾管理",
["Shield Whitelist"] = "護盾白名單",
["--- Janna ---"] = "--- 風女 ---",
["Shield options"] = "護盾選項",
["Ignore"] = "忽略",
["Shield AA & Spells"] = "護盾平A和法術",
["Shield Auto Attacks"] = "護盾自動攻擊",
["Shield Spells"] = "護盾法術",
["Shield if below % health "] = "血量低于%使用護盾",
["--- Blitzcrank ---"] = "--- 機器人 ---",
["Blitzcrank - Auto Attack"] = "自動攻擊",
["Blitzcrank - Q: RocketGrab"] = "機器人Q",
["Blitzcrank - E: PowerFistAttack"] = "機器人E",
["Blitzcrank - R: StaticField"] = "機器人R",
["Humanizer: Shield Delay (ms)"] = "擬人化：護盾延遲（毫秒）",
["Min X% Mana"] = "法力高于%使用",
["Janna Fun House"] = "燒傷輔助合集 - 風女",
["Enable Shield (Toggle)"] = "使護盾開關",
["--- Combat Settings ---"] = "戰鬥設置",
["Only use Q to interrupt"] = "只用Q打斷",
["Settings inside the Shield'n'Heal menu"] = "設置使用護盾和治療菜單的設置",
["Use Q as anti enemy gap closers"] = "用Q防突進",
["Use Q as spell interruptor"] = "用Q打斷",
["Use W for ks"] = "W搶人頭",
["Draw Insec Position"] = "顯示突進位置",
["Insec color"] = "突進顏色",
["Kayle"] = "凱爾",
["Fizz Fun House 2.0"] = "燒傷合集2.0 - 菲茲",
["Jungle Steal mode"] = "搶野怪模式",
["Instant R"] = "立刻R",
["--- Combo Logic - Q ---"] = "--- 連招邏輯設置 Q ---",
["Use Min dist to Q (default off)"] = "使用Q的最小距離（默認關閉）",
["Min distance to use Q"] = "使用Q的最小距離",
["Q minion Gapclose potential kill"] = "如果可以擊殺Q小兵突進",
["--- Combo Logic - E ---"] = "--- 連招邏輯設置 E ---",
["Force E on combo (Smart)"] = "--- 連招強制使用E（智能）---",
["Mid-air Flash finish if out-range"] = "如果超出攻擊範圍空中閃",
["--- Combo Logic - R ---"] = "--- 連招邏輯設置 R ---",
["Enable Long Range R (prediction)"] = "允許使用遠距離R（預判位置）",
["Use R below enemy hp % "] = "敵人血量小于%使用R",
["R for potential kill (dmg calc)"] = "嘗試使用R擊殺（傷害預估）",
["--- Misc ---"] = "--- 雜項 ---",
["Mana check for succesful Q+W"] = "Q+W前判斷法力值是否足夠",
["Harass and escape with Q/E :"] = "騷擾和逃跑時使用Q/E",
["Use Urchin Strike (Q)"] = "使用Q",
["E Options"] = "E選項",
["Animation Cancel all jumps"] = "取消跳躍動畫",
["Dodge spells from the list "] = "躲避列出的法術",
["Use Playful on enemy gap closers"] = "對敵人突進使用淘氣打擊",
["Jump/Back with Steal mode even if no smitable"] = "跳過去/跳回來搶怪即使沒有懲戒",
["Auto E on burst damage (40% HP of dmg)"] = "自動E爆發傷害（對敵造成40%生命傷害）",
["Jump List"] = "跳的名單",
["--- Jump At Spell Arrival ---"] = "--- 被法術攻擊時跳 ---",
["Kayle - Q: JudicatorReckoning"] = "凱爾Q",
["Kayle - W: JudicatorDevineBlessing"] = "凱爾W",
["Kayle - E: JudicatorRighteousFury"] = "凱爾E",
["Kayle - R: JudicatorIntervention"] = "凱爾R",
["R Targetting"] = "R目標",
["Cast R on Kayle"] = "對凱爾使用R",
["Use Seastone Trident (W)"] = "使用海神三叉戟W",
["Use Playful Trickster (E)"] = "使用淘氣打擊E",
["Misc Draws"] = "雜項顯示",
["Draw Jump Spots"] = "顯示跳躍的落點",
["Jump color"] = "跳躍顏色",
["Draw Double Jump Spots"] = "顯示二段跳落點",
["Double Jump color"] = "二段跳顏色",
["Cast Ignite on Kayle"] = "對凱爾使用點燃",
["Written by: burn & ikita - Fun House Team"] = "由Burn & Ikita 榮譽出品",
["Urgot Fun House 2.0"] = "燒傷合集 2.0 - 厄加特",
["Urgot Fun House"] = "燒傷厄加特",
["Auto Q1: if poisoned enemy"] = "如果敵人中毒自動Q1",
["Auto Q2: if enemy not poisoned"] = "如果敵人沒中毒自動Q2",
["Auto Q3: for ks enemy"] = "如果能擊殺自動Q3",
["Disable: Auto Q2-Q3 under enemy tower"] = "敵人塔下禁用自動Q2-Q3",
["--- Q Enemy Track System on FOW ---"] = "--- 追蹤Q迷霧中的敵人 ---",
["Auto Q poisoned enemy in FOW"] = "自動Q迷霧中中毒的敵人",
["Enable a hotkey for stop Q in FOW"] = "使用壹個熱鍵停止自動Q迷霧中的敵人",
["Hotkey for stop Auto Q in FOW"] = "熱鍵停止自動Q迷霧中的敵人",
["Use W on AA range for slow enemy"] = "普攻範圍內使用W減速敵人",
["If in AA range, delay combo for the slow"] = "如果普攻範圍內，延遲連招優先減速",
["Use W with Q locked for slow enemy"] = "對Q減速的敵人使用W",
["Use W if enemy tower focus Urgot"] = "如果塔的目標是厄加特使用W",
["Use W vs enemy gaps closers"] = "敵人突進使用W",
["Use W vs targeted spells"] = "對目標的法術使用W",
["--- Enable W on this spells: ---"] = "--- 對于以下法術使用W ---",
["--- R champions Interrupter ---"] = "--- R敵方英雄打斷 ---",
["Difference between enemy/team allies"] = "敵我人數",
["Use R as spell interrupter"] = "使用R作為打斷",
["No cast R as interrupter if:"] = "如果以下情況不使用R",
["Enemy allies > Ours, with 1 of difference"] = "敵人>我軍，人數差1",
["--- R champions Tower focus ---"] = "對塔的目標使用R",
["Enemy allies surrounding our target"] = "敵人和我軍在目標附近",
["Auto R: Make our tower focus enemy"] = "自動R：使我軍塔專注攻擊",
["No cast R as tower focus if:"] = "如果以下情況不對塔的目標使用R",
["Enemy is surrounded for 1"] = "有1個敵人在周圍",
["Our Health is lower than %"] = "我們的血量低于%",
["Health %"] = "血量%",
["Use Acid Hunter (Q)"] = "使用Q",
["Q usage mode: "] = "Q的使用模式",
["Spam mode"] = "飽和模式",
["For kill minion"] = "為擊殺小兵",
["Use Noxian Corrosive Charge (E) [jungle]"] = "對野怪使用E",
["Only if AA on cooldown"] = "只在普攻冷卻時",
["Min Mana % for E harass"] = "使用E騷擾的最低法力%",
["--- Enemy Track System ---"] = "--- 追蹤敵人 ---",
["Draw Enemy prediction on FOW"] = "顯示戰爭迷霧中敵人的預計位置",
["Show if tracker is temp. disabled"] = "如果追蹤被禁用",
["Draw Poison time on enemy"] = "顯示敵人中毒時間",
["Poison time color"] = "中毒時間顏色",
["Auto use Muramana active vs enemies"] = "對敵時自動使用魔切",
["Auto disable Muramana if no enemies"] = "沒有敵人時自動禁用魔切",
["Cast it on Blitzcrank"] = "對機器人使用",
["Blitzcrank Fun House"] = "燒傷輔助合集 - 機器人",
["Use R+Q Combo"] = "使用R+Q連招",
["Use Q Killsteal"] = "使用Q搶人頭",
["Use R Killsteal"] = "使用R搶人頭",
["Set Q Range 750-925"] = "設置Q的距離 750-925",
["Use Q on"] = "使用Q的名單",
["Use Q on Lux"] = "對拉克絲使用Q",
["--- R Settings ---"] = "--- R設置 ---",
["Use R to interrupt spells"] = "使用R打斷法術",
["X enemy targets to use R"] = "敵人數量為X時，使用R",
["Use E for Dash & Gapclose"] = "使用E突進",
["Draw Q Hook line"] = "顯示Q的彈道",
----------------Jhin----------------
["Machine Series: Jhin"] = "Machine合集：燼",
["Only if first minion kill"] = "僅當第壹個小兵能被擊殺",
["Use W: "] = "使用W：",
["Only on stunnable"] = "只用于禁錮目標",
["Use W on Shaco invis"] = "對隱身的小醜使用W",
["Min W range if not reloading"] = "W的最小範圍",
["Use Trap on channeled spells"] = "對正在引導法術的敵人使用陷阱",
["ON including own"] = "開-包括自己的控制技能",
["Cast Ult on FoW enemies"] = "對戰爭迷霧�堛獐臚H使用R",
["Additional Humanizer (ms)"] = "額外擬人化延遲(毫秒)",
["Use E in Wave Clear"] = "在清線中使用E",
["Show (R) Humanizer Timer"] = "顯示R技能擬人化延遲計時器",
["Draw AA and (Q) Range"] = "顯示平A和Q的範圍",
["Draw (R) Range Minimap"] = "在小地圖上顯示R的範圍",
["Percent"] = "百分比",
["Raw Damage"] = "顯示傷害",
["Assisted (R) Key (Hold)"] = "輔助性R按鍵(按住不放)",
["High Noon"] = "如日中天 - 燼",
----------------MMA-----------------
["Marksman's Mighty Assistant"] = "MMA走砍",
["Orbwalk [On-Hold]"] = "走砍 [按住]",
["Last Hit [On-Hold]"] = "尾刀 [按住]",
["Lane Clear [On-Hold]"] = "清線 [按住]",
["Dual Carry [On-Hold]"] = "雙重走砍 [按住]",
["Orbwalk [Toggle]"] = "走砍 [開關]",
["Last Hit [Toggle]"] = "尾刀 [開關]",
["Lane Clear [Toggle]"] = "清線 [開關]",
["Dual Carry [Toggle]"] = "雙重走砍 [開關]",
["Last-Hit Settings"] = "尾刀設置",
["Lane Freeze"] = "控線猥瑣補刀",
["Last-Hit Assistance"] = "尾刀助手",
["Dual Carry Setup"] = "雙重走砍設置",
["Orbwalk + Last-Hit"] = "走砍 + 尾刀",
["Orbwalk + Lane-Clear"] = "走砍 + 清線",
["Dual Carry mode first priority"] = "雙重走砍模式優先",
["Heroes"] = "英雄",
["Minions"] = "小兵",
["Enable HP Correction under turrets"] = "在防禦塔下時使生命值修正",
["Give priority to big jungle mobs"] = "設定大型野怪優先",
["Movement Settings"] = "移動設置",
["Distance over DPS"] = "輸出間隔中移動的距離",
["Hold-Position on mouse stop"] = "在鼠標下時停止移動",
["Orbwalk Boxes/Plants etc."] = "走砍時攻擊小醜盒子/婕拉的植物",
["Hold-Position near walls"] = "在牆邊時停止移動",
["Movement spam rate (in ms)"] = "移動指令發送頻率(毫秒)",
["Mouse detection sensitivity"] = "鼠標動作檢測敏感度",
["Active"] = "生效",
["Usage on Enemy %HP: "] = "當敵人生命值高于%時使用",
["Usage on myHero %HP: "] = "當自己生命值低于%時使用",
["Tiamat & Ravenous Hydra"] = "提亞馬特 & 貪欲九頭蛇",
["Target Mode: All[ON]/Champions[OFF]"] = "目標選擇模式: 所有目標[開]/只對英雄[關]",
["Use when enemy count more than"] = "當敵人數量多于x時使用",
["Use items in LaneClear mode"] = "在清線中使用物品",
["Use items in Dual-Carry mode"] = "在雙重走砍模式中使用物品",
["Using Infinity Edge?"] = "使用無盡之刃?",
["Display Settings"] = "顯示設置",
["Auto-Attack Range"] = "平A範圍",
["Auto-Attack Range Awareness"] = "AA範圍意識",
["Current Target Circle"] = "當前目標線圈",
["Low-FPS circles"] = "低FPS線圈",
["Auto-Attack Range Circle Color"] = "平A線圈顏色",
["Display a circle on queued minions"] = "在等待被尾刀的小兵上畫圈",
["How fast will my target die?"] = "目標死亡的速度有多快?",
["Last-Hit Circles"] = "尾刀線圈",
["Enable PermaShow for keys (Reload)"] = "使按鍵狀態顯示(需要重新加載)",
["Debugging Settings"] = "調試設置",
["Enable debug prints"] = "使調試信息顯示",
["Debug last-hit spell damage (Reload)"] = "調試尾刀技能傷害(需要重新加載)",
["Enable heros auto attacks"] = "使英雄的普通攻擊",
["Debug time between auto-attacks"] = "調試普通攻擊直接的間隔時間",
["Debug auto-attack damage"] = "調試普通攻擊的傷害",
["Debug auto-attack cancels"] = "調試取消普通攻擊",
["Debug minion HP correction"] = "調試小兵血量修正",
["Enable class initialization prints"] = "使類初始化信息顯示",
["Disable ally minion attack prediction"] = "關閉友方小兵攻擊預判",
["Debug animation strings"] = "調試動作字符串",
["Target Selector Mode"] = "目標選擇器模式",
["Lowest HP"] = "血量最低",
["Near Mouse"] = "鼠標附近",
["Most DPS"] = "輸出最高",
["Lowest HP + Most DPS"] = "血量最低+輸出最高",
["Target Selector Priorities"] = "目標選擇器優先級",
["Attack selected targets only"] = "只攻擊選定的目標",
["Target people on camera view"] = "只選擇在屏幕內的目標",
["1st Priority"] = "壹級優先",
["2nd Priority"] = "二級優先",
["3rd Priority"] = "三級優先",
["4th Priority"] = "四級優先",
["5th Priority"] = "五級優先",
["Turret Manager"] = "防禦塔管理器",
["Enemy Turrets"] = "敵方防禦塔",
["Show Range"] = "顯示防禦塔範圍",
["Opacity"] = "透明度",
["Show Aggro Colors"] = "顯示仇恨鎖定顏色",
["Distance Based Opacity"] = "取決于距離的透明度",
["Hide Distance"] = "隱藏距離",
["Ally Turrets"] = "友方防禦塔",
["Enable Dive-Awareness "] = "使越塔意識",
["Mastery Settings"] = "天賦設置",
["Buff Settings"] = "Buff設置",
["Enable auto-potions"] = "使自動藥水",
["Potion Settings"] = "自動藥水設置",
["Hunter Potion %"] = "獵人藥水 %",
["Corrupting Potion %"] = "腐敗藥水 %",
["Biscuit %"] = "餅幹 %",
["ItemCrystalFlask %"] = "魔瓶 %",
["Health Potion %"] = "血瓶 %",
["Mana Potion %"] = "藍瓶 %",
["Seraph's Embrace %"] = "熾天使之擁 %",
["Use potions when ignited"] = "被點燃時使用藥水",
["Disable Crowd-Control Detection"] = "關閉控制技能檢測",
["No spells supported for this champion"] = "",
["Auto Bushes"] = "自動探草",
["Ward bushes on toggle"] = "自動進草插眼開關",
["Maximum bush check time (in sec)"] = "進草最大時間檢測(秒)",
["Switch mode for"] = "切換模式為",
["None"] = "無",
["On-Hold"] = "按住",
["Toggle"] = "開關",
["Add key for"] = "添加按鍵為",
["Orbwalking"] = "走砍",
["Last-Hitting"] = "尾刀",
["Lane-Clearing"] = "清線",
["Dual-Carrying"] = "雙重走砍",
["Lasthitting"] = "尾刀",
["Lasthitting2"] = "尾刀2",
["Lasthitting3"] = "尾刀3",
["Laneclearing"] = "清線",
["Laneclearing2"] = "清線2",
["Laneclearing3"] = "清線3",
["Dualcarrying"] = "雙重走砍",
["Dualcarrying2"] = "雙重走砍2",
["Dualcarrying3"] = "雙重走砍3",
["Version: "] = "版本號:",
-------------------HTTF銳雯----------------
["HTTF Riven"] = "HTTF 銳雯",
["Burst Combo Toggle"] = "爆發連招開關",
["Use Flash in Burst Combo"] = "在爆發連招中使用閃現",
["Ulti"] = "大招",
["Activate R Mode"] = "觸發R模式",
["Kill Steal"] = "搶人頭",
["Combo - The number of QAA"] = "連招 - QA次數",
["Cast R Mode"] = "使用R模式",
["Save First Q before AA (T)"] = "普通攻擊之前保留第壹段Q",
["Use EQ (T)"] = "使用EQ",
["Save E before W (F)"] = "在W技能之前保留E技能",
["Use Item"] = "使用物品",
["Save First Q before AA (F)"] = "普通攻擊之前保留第壹段Q",
["Activate R"] = "觸發R",
["Cast R"] = "使用R",
["Clear"] = "清線/清野",
["Save First Q even if Last Hit (T)"] = "在尾刀中的普通攻擊之前保留第壹段Q",
["Use EQ (F)"] = "使用EQ",
["Use W Min Count"] = "使用W的最小敵人數量",
["Wall Jump"] = "翻牆",
["Use Wall Jump"] = "使用翻牆",
["Misc"] = "雜項",
["Use Animation Cancel"] = "使用動作取消後搖",
["Cancel Type"] = "取消後搖類型",
["Joke"] = "開玩笑",
["Provoke"] = "嘲諷",
["Auto Cancel Q for manual QAA (F)"] = "自動取消手動QA的Q後搖",
["Cast E even if enemy is so closed (F)"] = "即使已經很貼近目標依然使用E",
["Combo - Attack selected target (T)"] = "常規連招 - 攻擊選定的目標",
["Combo - Select range (600)"] = "常規連招 - 選擇目標範圍",
["Burst - Attack selected Target (T)"] = "爆發連招 - 攻擊選定的目標",
["Burst - Select range (1200)"] = "爆發連招 - 選擇目標範圍",
["Q Cancel time offset"] = "取消Q後搖時間預設",
["Buffer between AA dmg and Spell"] = "平A與技能之間的緩沖時間",
["Buffer between AA dmg and move"] = "平A與移動指令之間的緩沖時間",
["Moving interval"] = "移動間隔",
["Stop moving over mouse"] = "在鼠標附近時停止移動",
["Draw"] = "顯示",
["Draw Lag free circles"] = "使用不影響延遲的線圈",
["Draw Hitchance"] = "顯示命中幾率",
["Draw Combo Damage"] = "顯示連招傷害",
["Wall Jump Position"] = "翻牆地點",
["Renekton"] = "雷克頓",
["HTTF Smite (HTTF Riven)"] = "HTTF 懲戒 (HTTF 銳雯)",
["Jungle Steal Settings"] = "搶野怪設置",
["Use Smite"] = "使用懲戒",
["Use Smite Toggle"] = "使用懲戒開關",
["Always Steal Dragon"] = "總是開啟搶龍",
["KillSteal Settings"] = "搶人頭設置",
["Use Stalker's Blade"] = "使用追獵者的刀鋒",
["Draw Smite range"] = "顯示懲戒範圍",
["Draw Target"] = "顯示目標",
["Draw Attack range"] = "顯示平A範圍",
["Early casting"] = "提早上點燃",
["Save Ignite if Killable with Spells"] = "如果目標能被技能擊殺則保留點燃",
---------------------SIUsage---------------
["Summoner & Item Usage"] = "SIUsage活化劑",
["Health Potions"] = "血瓶",
["Use While Pressed"] = "當按鍵時使用",
["Use Always"] = "總是使用",
["Use if no enemies"] = "沒有敵人時使用",
["If My Health % is <"] = "如果自己的生命值低于%",
["Remove CC"] = "解除控制",
["Remove Exhaust"] = "解除虛弱",
["Removal delay (ms)"] = "解控延遲(毫秒)",
["Normal Items/Smite"] = "普通物品/懲戒",
["Use Zhonyas/Seraphs Before Death"] = "死亡之前使用中婭/熾天使",
["OFF"] = "關閉",
["Summoner Exhaust"] = "虛弱",
["Exhaust Key"] = "虛弱按鍵",
---------------Feez Jayce-------------
["Jayce"] = "Feez傑斯",
["Script version:"] = "版本號:",
["Combo active"] = "連招",
["Spells"] = "技能",
["Q1 (Hammer)"] = "Q - 錘形態",
["W1 (Hammer)"] = "W - 錘形態",
["E1 (Hammer)"] = "E - 錘形態",
["R1 (Hammer)"] = "R - 錘形態",
["Q2 (Cannon)"] = "Q - 炮形態",
["W2 (Cannon)"] = "W - 炮形態",
["E2 (Cannon)"] = "E - 炮形態",
["R2 (Cannon)"] = "R - 炮形態",
["Harass active"] = "騷擾",
["Use Cannon Q"] = "使用炮形態Q",
["Use Cannon E->Q"] = "使用炮形態EQ",
["-> Switch stance to E->Q"] = "-> 切換形態來使用EQ",
["Use Cannon W"] = "使用炮形態W",
["Only when mana above %"] = "僅當藍量高于%",
["Use Hammer Q"] = "使用錘形態Q",
["Use Hammer W"] = "使用錘形態W",
["Use Hammer E"] = "使用錘形態E",
["Orbwalk"] = "走砍",
["Orbwalker"] = "走砍",
["Interrupter"] = "技能打斷",
["Switch stance to interrupt spells"] = "切換形態來打斷技能",
["Wall Hop"] = "穿牆",
["Wall hop"] = "穿牆",
["Hit minions with Hammer E"] = "對小兵使用錘形態E",
["Reveal minions with Cannon Q"] = "使用炮形態Q獲得小兵或野怪的視野",
["Champions"] = "英雄",
["Use flash"] = "使用閃現",
["Jungle Steal"] = "搶野怪",
["Switch stance to steal"] = "切換形態來搶野怪",
["Snipe"] = "狙殺",
["Snipe mode"] = "狙殺模式",
["Automatic mechanics"] = "",
["Cannon E->Q snipe to mouse"] = "對鼠標附近的敵人使用炮形態EQ狙殺",
[" -> Enabled"] = "-> 使",
["Stack tear/manamune"] = "疊女神之淚/魔宗",
["Flee mode"] = "逃跑模式",
["PermaShow Menu"] = "狀態顯示菜單",
["Combo range"] = "連招範圍",
["Thunderlord's Decree indicator circle"] = "雷霆領主的法令指示器線圈",
["Ranges"] = "範圍",
["Hammer Q"] = "錘形態Q",
["Hammer E"] = "錘形態E",
["Cannon Q"] = "炮形態Q",
["Cannon E->Q Range"] = "炮形態EQ範圍",
["Move Left/Right"] = "左右移動",
["Move Up/Down"] = "上下移動",
["Reset"] = "恢複默認設置",
["Jayce - Prediction Manager"] = "Feez傑斯 - 預判管理器",
["Load all predictions on start"] = "開始時加載所有預判",
["Prediction:"] = "預判",
["Hit Chance:"] = "命中率",
["1: Low"] = "1: 低",
["2: High"] = "2: 高",
["3: Target too slow or close"] = "3: 目標過慢或者過近",
["4: Target immobile"] = "4: 目標太遠",
["5: Target dashing or blinking"] = "5: 目標正在使用位移技能或閃現",
["Accelerated Q"] = "加速的Q",
["No interruptable spells"] = "沒有可打斷的技能",
["Dashes and Jumps"] = "位移和跳躍",
["Interrupt Ezreal"] = "打斷伊澤瑞爾",
["Priorities"] = "優先級",
["Ezreal"] = "伊澤瑞爾",
["Loading..."] = "加載中...",
["Muramana"] = "魔切",
["Twin Shadows"] = "雙生暗影",
["Tiamat or Hydra"] = "提亞馬特/九頭蛇",
["BORK"] = "破敗王者之刃",
["Baron Nashor"] = "納什男爵",
["Snipe Ezreal"] = "狙殺伊澤瑞爾",
["Insec Ezreal"] = "Insec伊澤瑞爾",
--------------------Feez Lissandra-------------
["Lissandra - Blood Diamond"] = "Feez麗桑卓",
["Melt: Combo"] = "最大輸出連招(對目標釋放所有技能)",
["Safe-Melt: Combo"] = "開團+自保連招(E開團+R自己)",
["Flee (no 2nd E while combo)"] = "逃跑(連招時不使用二段E)",
["Smart KS"] = "智能搶人頭",
["Melt"] = "最大輸出連招",
["Use First E"] = "使用壹段E",
["Use Second E"] = "使用二段E",
["Only ult when combo killable"] = "只在能擊殺目標時使用R",
["Safe-Melt"] = "開團自保連招",
["least # of enemies to initiate"] = "開團至少能開到x個敵人",
["Use E (only first)"] = "先手使用E",
["Mana % must be > than:"] = "藍量必須大于x%",
["Minimum E minions:"] = "至少能E中的小兵數",
["Minimum Q minions:"] = "至少能Q中的小兵數",
["2nd Keybind Key"] = " ",
["2nd Keybind Enabled"] = " ",
["least # of enemies to auto W"] = "能命中x名敵人時自動W",
["Jump Spots Color:"] = "E位移終點顏色",
["Q Range"] = "Q技能範圍",
["W range"] = "W技能範圍",
["E range"] = "E技能範圍",
["R range"] = "R技能範圍",
["W Range"] = "W技能範圍",
["E Range"] = "E技能範圍",
["R Range"] = "R技能範圍",
["Color:"] = "顏色:",
["Last second E"] = "E最遠距離位移",
["Lissandra - Prediction Manager"] = "麗桑卓 - 預判管理",
["Udyr"] = "烏迪爾",
---------------------Feez安妮---------------
["Annie the UnBEARable"] = "Feez安妮",
["Use Flash when Killable"] = "當目標可被擊殺時使用閃現",
["Block AAs out of range [when spells ready]"] = "當技能可用時不平A",
["Combo Order"] = "連招順序",
["Wait for Q hit"] = "等待Q技能命中",
["^^Will combo when q hits"] = "^^將會在Q命中的時候進行連招",
["Only for Q-W-R or Q-R-W"] = "只對Q-W-R和Q-R-W生效",
["Ult"] = "大招",
["Use Ult"] = "使用大招",
["Allow KS with ult"] = "允許使用大招搶人頭",
["Ult on"] = "使用大招的目標",
["Use Stun"] = "使用自動眩暈",
["Auto Stun enemies focused by tower"] = "自動眩暈被防禦塔鎖定的敵人",
["Use W [Auto Stun]"] = "使用W(自動眩暈)",
["Use Ult [Auto Stun]"] = "使用R(自動眩暈)",
["Minimum enemies to auto stun"] = "自動眩暈的最小敵人數",
["Auto Farm"] = "自動發育",
["Auto Farm with Q"] = "自動使用Q發育",
["Auto reactivate farm mode"] = "自動開啟發育模式",
["Toggle continuous farm"] = "發育模式開啟狀態顯示",
["Stack to:"] = "自動將被動疊到",
["1 Stack"] = "1層",
["2 Stacks"] = "2層",
["3 Stacks"] = "3層",
["4 Stacks [Stun]"] = "4層[眩暈]",
["Auto Shield"] = "自動護盾",
["Turn off E stack for better results"] = "關閉E技能攢被動",
["Draw combo range"] = "顯示連招範圍",
["Draw flash + combo range"] = "顯示閃現連招範圍",
["Draw circle under TS target"] = "在選定的目標下畫圈",
["Draw killable text on target"] = "在目標身上顯示可擊殺提示",
["Draw timer of tibbers on yourself"] = "在自己身上顯示提伯斯的時間",
["Draw Tibbers target text on tibbers"] = "在提伯斯身上顯示熊鎖定的目標",
["Draw stun sprite"] = "顯示眩暈圖標",
["Text draw fix"] = "修複文字顯示",
["Auto control & orbwalk tibbers"] = "自動操縱提伯斯",
["Tibbers follow toggle"] = "提伯斯跟隨狀態顯示",
["Passive"] = "被動",
["Stack passive:"] = "自動攢被動:",
["In Spawn"] = "在泉水",
["Add Stack [*]"] = "增加被動層數[*]",
["Subtract Stack [-]"] = "減少被動層數[-]",
["Annie - Prediction Manager"] = "安妮 - 預判管理器",
-----------------Feez狐狸------------
["Ahri - Sexy Mistress"] = "Feez阿狸",
["Smart auto ignite"] = "智能自動點燃",
["Q Catch"] = "使用Q追趕",
["Use R for Q return"] = "使用R調整Q返回位置",
["Catch mode"] = "追擊模式",
["Flexible"] = "靈活的",
["Tight"] = "緊追不放的",
["Use when health % >="] = "當生命值大于等于x%時使用",
["Use to initiate"] = "用來開團",
["Use default logic"] = "使用默認邏輯",
["Randomize ult distance"] = "隨機的大招位移距離",
["Harass KeyDown"] = "騷擾按鍵",
["^Only when mana above %"] = "^僅當藍量大于%",
["Flee active"] = "逃跑模式開啟",
["Last Hit [Q]"] = "尾刀 [Q]",
["Minimum to last hit"] = "能尾刀的最少小兵數",
["Minimum laneclear with passive"] = "觸發被動清線的最少小兵數",
["^Only when health below %"] = "^僅當生命值小于%",
["Spell hit spots"] = "技能命中點",
["Passive sprite"] = "被動圖標顯示",
["Q orb"] = "Q技能彈道",
["Ahri - Prediction Manager"] = "阿狸 - 預判管理",
["Prioritize selected target"] = "優先鎖定選定的目標",
["Ult mode"] = "大招模式",
["Move to mouse"]= "移動至鼠標位置",
["NebelwolfisMoonWalker"] = "Nebelwolfi走砍",
["Harass Mode"] = "騷擾模式",
["Mouse over Hero to stop move"] = "英雄在鼠標下時停止移動",
["Melee Settings"] = "近戰設置",
["Walk/Stick to target"] = "緊跟目標",
["Sticky radius to target"] = "緊跟目標半徑",
------------------Forbidden Ahri Kassadin Twisted Fate Ryze----------------
["Challenger Ahri Reborn by Da Vinci"] = "挑戰者中單合集 - 阿狸",
["Ahri - Target Selector Settings"] = "[阿狸] - 目標選擇器設置",
["Ahri - General Settings"] = "[阿狸] - 常規設置",
["Catch the Q with Movement"] = "移動來調整Q的彈道",
["Ahri - Combo Settings"] = "[阿狸] - 連招設置",
["Catch the Q with R"] = "使用R調整Q的彈道",
["Give Priority to Catch the Q with R"] = "優先使用R調整Q的彈道",
["Use Ignite If Killable "] = "當可擊殺時使用點燃",
["Ahri - Harass Settings"] = "[阿狸] - 騷擾設置",
["Ahri - LaneClear Settings"] = "[阿狸] - 清線設置",
["Use W If Minions >= "] = "當小兵大于等于x時使用W",
["Ahri - JungleClear Settings"] = "[阿狸] - 清野設置",
["Ahri - LastHit Settings"] = "[阿狸] - 尾刀設置",
["Never"] = "從不",
["Ahri - KillSteal Settings"] = "[阿狸] - 搶人頭設置",
["Ahri - Auto Settings"] = "[阿狸] - 自動設置",
["Use E To Interrupt"] = "使用E技能打斷",
["Ahri - Draw Settings"] = "[阿狸] - 顯示設置",
["Path to Catch the Q"] = "調整Q彈道的路線",
["Line for Q Orb"] = "Q技能彈道指示線",
["Ahri - Keys Settings"] = "[阿狸] - 按鍵設置",
["Start with E (Toggle)"] = "連招E起手(開關)",

["Forbidden Kassadin by Da Vinci"] = "挑戰者中單合集 - 卡薩丁",
["Kassadin - Target Selector Settings"] = "[卡薩丁] - 目標選擇器設置",
["Kassadin - General Settings"] = "[卡薩丁] - 常規設置",
["Kassadin - Combo Settings"] = "[卡薩丁] - 連招設置",
["Kassadin - Harass Settings"] = "[卡薩丁] - 騷擾設置",
["Kassadin - LaneClear Settings"] = "[卡薩丁] - 清線設置",
["Kassadin - JungleClear Settings"] = "[卡薩丁] - 清野設置",
["Kassadin - LastHit Settings"] = "[卡薩丁] - 尾刀設置",
["Kassadin - KillSteal Settings"] = "[卡薩丁] - 搶人頭設置",
["Kassadin - Drawing Settings"] = "[卡薩丁] - 顯示設置",
["Kassadin - Keys Settings"] = "[卡薩丁] - 按鍵設置",

["Diana The Dark Eclipse by Da Vinci"] = "挑戰者中單合集 - 戴安娜",
["Diana - Target Selector Settings"] = "[戴安娜] - 目標選擇器設置",
["Range for Combo"] = "連招使用範圍",
["Diana - General Settings"] = "[戴安娜] - 常規設置",
["Diana - Combo Settings"] = "[戴安娜] - 連招設置",
["Use R On Enemies Marked"] = "對標記的敵人使用R",
["Use QR on Object To GapClose"] = "對目標使用QR以突進敵人",
["Diana - Harass Settings"] = "[戴安娜] - 騷擾設置",
["Diana - LaneClear Settings"] = "[戴安娜] - 清線設置",
["Use E If Hit >="] = "當能命中大于等于x個敵人時使用E",
["Diana - JungleClear Settings"] = "[戴安娜] - 清野設置",
["Diana - LastHit Settings"] = "[戴安娜] - 尾刀設置",
["Diana - KillSteal Settings"] = "[戴安娜] - 搶人頭設置",
["Diana - Auto Settings"] = "[戴安娜] - 自動設置",
["Diana - Draw Settings"] = "[戴安娜] - 顯示設置",
["Diana - Keys Settings"] = "[戴安娜] - 按鍵設置",

["Forbidden TwistedFate by Da Vinci"] = "挑戰者中單合集 - 崔斯特",
["TwistedFate - Target Selector Settings"] = "[戴安娜] - 目標選擇器設置",
["Range for Harass"] = "騷擾使用範圍",
["TwistedFate - General Settings"] = "[戴安娜] - 常規設置",
["Select gold card after R"] = "R技能之後自動切黃牌",
["TwistedFate - Combo Settings"] = "[戴安娜] - 連招設置",
["Use Q If Hit >="] = "當能擊中大于等于x個單位時使用Q",
["Use Gold Card"] = "使用黃牌",
["Use Blue Card If Mana Percent <= "] = "藍量小于等于x%時切藍牌",
["TwistedFate - Harass Settings"] = "[戴安娜] - 騷擾設置",
["Priorize Farm over Harass"] = "發育優先于騷擾",
["TwistedFate - LaneClear Settings"] = "[戴安娜] - 清線設置",
["Use Q If Mana Percent >= "] = "當藍量大于等于%時使用Q",
["Use Red Card If Hit >= "] = "當能擊中大于等于x個單位時使用紅牌",
["Red Card If Mana Percent >= "] = "如果藍量高于%使用紅牌",
["Use Blue"] = "使用藍牌",
["TwistedFate - JungleClear Settings"] = "[戴安娜] - 清野設置",
["Use Red"] = "使用紅牌",
["Use Red Card If Mana Percent >= "] = "如果藍量高于%使用紅牌",
["TwistedFate - LastHit Settings"] = "[戴安娜] - 尾刀設置",
["TwistedFate - KillSteal Settings"] = "[戴安娜] - 搶人頭設置",
["TwistedFate - Auto Settings"] = "[戴安娜] - 自動設置",
["Use Gold Card To Interrupt Channelings"] = "使用黃牌打斷引導型技能",
["Use Gold Card To Interrupt GapClosers"] = "使用黃牌打斷突進者",
["TwistedFate - Drawing Settings"] = "[戴安娜] - 顯示設置",
["TwistedFate - Keys Settings"] = "[戴安娜] - 按鍵設置",
["Start with Card (Toggle)"] = "切牌起手(開關)",
["Select Blue Card (Default: F1)"] = "切藍牌(默認F1)",
["Select Red Card (Default: F2)"] = "切紅牌(默認F2)",
["Select Gold Card (Default: F3)"] = "切黃牌(默認F3)",
["Extra WindUpTime"] = "額外後搖時間",
["Farm Delay"] = "發育延遲時間",

["Wizard by Da Vinci"] = " 挑戰者上單合集 - 瑞茲",
["QP Settings"] = " ",
["Ryze - Target Selector Settings"] = "[瑞茲] - 目標選擇器設置",
["Ryze - General Settings"] = "[瑞茲] - 常規設置",
["Ryze - Combo Settings"] = "[瑞茲] - 連招設置",
["Use Q no Collision"] = "使用Q時不檢查碰撞",
["Ryze - Harass Settings"] = "[瑞茲] - 騷擾設置",
["Ryze - LaneClear Settings"] = "[瑞茲] - 清線設置",
["Ryze - JungleClear Settings"] = "[瑞茲] - 清野設置",
["Ryze - KillSteal Settings"] = "[瑞茲] - 搶人頭設置",
["Ryze - Auto Settings"] = "[瑞茲] - 自動設置",
["Use W To Interrupt"] = "使用W來打斷",
["Ryze - Draw Settings"] = "[瑞茲] - 顯示設置",
["Ryze - Keys Settings"] = "[瑞茲] - 按鍵設置",
["Delay for LastHit (in ms)"] = "尾刀延遲(毫秒)",
--------------SAC-----------------------
["Stream Mode"] = "屏蔽模式",
["Green"] = "綠色",
["When In Range"] = "當在範圍內時",
["Q (Tumble)"] = "Q(閃避突襲)",
["Last Hit Only"] = "只在尾刀使用",
["R (Final Hour)"] = "R(終極時刻)",
[" Only orbwalk who I attack "] = "只輸出我正在攻擊的目標",
[" Only orbwalk my selected target "] = "只輸出我選定的目標",
[" Choose best target in scan range (set below)"] = "在壹定範圍內選擇最佳目標(在下面設定)",
[" Orbwalk who I attack if possible, otherwise selected target"] = "在可能時只輸出我正在攻擊的目標,否則攻擊選定的目標",
[" Orbwalk who I attack if possible, otherwise best in scan range"] = "在可能時只輸出我正在攻擊的目標,否則攻擊範圍內最佳目標",
[" Always "] = "總是",
[" AutoCarry mode "] = "自動連招輸出模式",
[" Any mode"] = "任何模式",
["  Last Hit Earlier  "] = "提早尾刀",
["  Last Hit Later  "] = "推遲尾刀",
["  Cancel Earlier  "] = "提早取消",
["  Cancel Later  "] = "推遲取消",
["Server Delay: 100ms"] = "服務器延遲: 100毫秒",
["Sida's Auto Carry: Vayne"] = "SAC:薇恩",
["Allowed Condemn Targets"] = "允許眩暈的目標",
["Toggle Mode (Requires Reload)"] = "開關模式(需要重新加載)",
["Auto-Condemn"] = "自動E",
["Auto-Condemn Gap Closers"] = "自動推開突進者",
["Max Condemn Distance"] = "最大推開距離",
["Only condemn Reborn target"] = "只推開SAC選定的目標",
["Condemn Adjustment:"] = "E技能調整:",
["Disable attacks during ult stealth"] = "在大招隱身的情況下不平A",
["Wall Detection Method"] = "牆體檢測方式",
["IsWall"] = "IsWall函數",
["Guess (for when IsWall breaks in BoL)"] = "猜測(當IsWall無法使用時)",
["              Sida's Auto Carry: Reborn"] = "              Sida走砍",
["No mode active"] = "無模式",
["Skill Farm"] = "技能發育",
["TARGET LOCK"] = "目標鎖定",
["Auto-Condemn"] = "自動E",
["      Active"] = "    激活",
["      "] = "    凍結",
["Move to Mouse"] = "移動至鼠標位置",
["SAC Detected"] = "檢測到SAC",
["Combat keys are connected to your SAC:R keys"] = "連招按鍵和SAC的連招按鍵綁定",
}
function translationchk(text)
    assert(type(text) == "string","<string> expected for text")
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
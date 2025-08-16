require "logic.dialog"
require "logic.selectserversdialogcell"
require "config"
require "logic.newswarndlg"
require "logic.loginwaitingdialog"
require "logic.selectserversareacell"
require "utils.commonutil"

SelectServersDialog = {}
setmetatable(SelectServersDialog, Dialog)
SelectServersDialog.__index = SelectServersDialog

SERVER_STATUS_TUIJIAN = "0"  --�ڷ����� NS�ֶ�
SERVER_STATUS_NEW = "1"    
SERVER_STATUS_BOUTH = "2"  --ͬʱ�Ƽ� �¿�

SERVER_STATUS_BAOMAN = "3" --�ڷ����� S�ֶ� ����
SERVER_STATUS_YONGDU = "1" --��æ/ӵ��

local CHECK_LOAD_DUR = 5 --second
local _serverLoadStateMap = {}

local lastServerID = -1

local threePvpServerID = "1101011999"

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SelectServersDialog.getInstance()
    if not _instance then
        _instance = SelectServersDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SelectServersDialog.getInstanceAndShow()
    if not _instance then
        _instance = SelectServersDialog:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function SelectServersDialog.getInstanceNotCreate()
    return _instance
end

function SelectServersDialog.DestroyDialog()
	if _instance then
		_serverLoadStateMap = {}
		if not _instance.m_bCloseIsHide then
            if gGetLoginManager() then 
			    gGetLoginManager():ClearConnections()
            end
			_instance:ClearAllServerCells()
			_instance:ClearAllAreaCells()
			_instance:OnClose() 
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function SelectServersDialog.ToggleOpenClose()
	if not _instance then 
		_instance = SelectServersDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function SelectServersDialog.GetLayoutFileName()
    return "selectserversnew.layout"
end

function SelectServersDialog:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_OKBtn = CEGUI.Window.toPushButton(winMgr:getWindow("selectserversnew/gotogame") )
    self.m_ReturnBtn = CEGUI.Window.toPushButton(winMgr:getWindow("selectserversnew/backtolog") )
    self.m_ServerListBack = CEGUI.Window.toScrollablePane(winMgr:getWindow("selectserversnew/back/Bot") )
	self.m_AreaListBack = CEGUI.Window.toScrollablePane(winMgr:getWindow("selectserversnew/back/xuanqu") )
    self.m_AreaListBack:EnablePageScrollMode(true)
	--self.m_AreaListBack:EnableHorzScrollBar(true)

    self:GetCloseBtn():removeEvent("Clicked")
	self:GetCloseBtn():subscribeEvent("Clicked", SelectServersDialog.HandleReturnBtnClicked, self)

    -- subscribe event
    self.m_OKBtn:subscribeEvent("Clicked",  SelectServersDialog.HandleOKBtnClicked, self) 
    self.m_ReturnBtn:subscribeEvent("Clicked", SelectServersDialog.HandleReturnBtnClicked, self)

--    self.m_SelectArea = gGetLoginManager():GetSelectArea()

	-- init settings
	self:OnInit()  --��ȡ���з�������Ϣ
	self:InitAreaList() --������
	self:ClearAllServerCells()
	self:RefreshServerCells(self.m_SelectArea)
    self:SelectCurrentAreaBtn() --������������ť
	self:DeselectOtherServerBtn()   --������������ť

end

function SelectServersDialog.setLastSelect(sid)
    lastServerID = sid
end

function SelectServersDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectServersDialog)

    return self
end

function SelectServersDialog:HandleOKBtnClicked(args)
     if self.m_AreaServersMap[self.m_SelectArea].lastSelectID == -1 then
       gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_msgtipstring(160479),
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
     end
    local roleSeq = GetServerInfo():getRoleHeadInfoByServerID(self.m_AreaServersMap[self.m_SelectArea].lastSelectID)
    if roleSeq  == -1 then
        if self.m_AreaServersMap[self.m_SelectArea].servers[tostring(self.m_AreaServersMap[self.m_SelectArea].lastSelectID)]["type"]== "1" then
            require"logic.pointcardserver.firstenterpointmsgdlg".getInstanceAndShow()
            return
        end
    end
    
    local area = self.m_AreaServersMap[self.m_SelectArea]
    local serverid = tostring(area.lastSelectID)
	local server = area.servers[serverid]
    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        local serverName = server.servername
        local pos = string.find(serverName, "-")
        if pos then
            serverName = string.sub(serverName, 1, pos - 1)
        end
        gGetGameApplication():SetGameMainWindowTitle(Config.GetGameName(server["type"]) .. "---" .. serverName)
    end

    self:SelectServerFinish()
    
    return true
end
function SelectServersDialog:SelectServerFinish()
    --�����������
    if not DeviceData:sIsNetworkConnected() then
        gGetMessageManager():AddConfirmBox(eConfirmOK, MHSD_UTILS.get_resstring(11310),	--������粻����������ȥ���һ�°ɣ�
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager
        )
        return
    end

    local area = self.m_AreaServersMap[self.m_SelectArea]
    local serverid = tostring(area.lastSelectID)
	local server = area.servers[serverid]

    if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
        local serverName = server.servername
        local pos = string.find(serverName, "-")
        if pos then
            serverName = string.sub(serverName, 1, pos - 1)
        end
        gGetGameApplication():SetGameMainWindowTitle(Config.GetGameName(server["type"]) .. "---" .. serverName)
    end

    local couldEntry = SelectServersDialog.CheckCouldEnterThreePvp(serverid)

    if couldEntry then
        local lowport = tonumber(server.port)
        local highport = lowport + tonumber(server.standby) - 1
        highport = math.max(lowport, highport)
        local port = StringCover.randBetween(lowport, highport)

        gGetLoginManager():SetSelectServerInfo(self.m_SelectArea, server.servername, server.ip, tostring(port), 0)
        gGetLoginManager():Init()

        self:DestroyDialog()
        SelectServerEntry.getInstanceAndShow()
    else
        local strMsg = MHSD_UTILS.get_msgtipstring(172039)
        gGetMessageManager():AddConfirmBox(eConfirmOK, strMsg,
            MessageManager.HandleDefaultCancelEvent, MessageManager,
            MessageManager.HandleDefaultCancelEvent, MessageManager)
    end
end

function SelectServersDialog.CheckCouldEnterThreePvp(sServerID)
    local couldEntry = false

    if sServerID == threePvpServerID then
        local account = gGetLoginManager():GetAccount()
        local pos = string.find(account, ",")
        if pos then
            account = string.sub(account, 1, pos - 1)
        end

        local tableAllId = BeanConfigManager.getInstance():GetTableByName("game.threepvpwhitemenu"):getAllID()
        for _, v in pairs(tableAllId) do
            local record = BeanConfigManager.getInstance():GetTableByName("game.threepvpwhitemenu"):getRecorder(v)
            if account and record then
                if account == record.username then
                    couldEntry = true
                    break
                end
            end
        end

    else
        couldEntry = true
    end

    return couldEntry
end


function SelectServersDialog:HandleReturnBtnClicked(args)
	SelectServersDialog.DestroyDialog()
	SelectServerEntry.getInstanceAndShow()
    return true
end

function SelectServersDialog:HandleSelectServerStateChanged(args)
	local eventargs = CEGUI.toWindowEventArgs(args)

    self.m_AreaServersMap[self.m_SelectArea].lastSelectID = eventargs.window:getID()
    lastServerID = eventargs.window:getID()

	self:DeselectOtherServerBtn()

    return true
end

function SelectServersDialog:HandleSelectAreaStateChanged(args)
	local eventargs = CEGUI.toWindowEventArgs(args)
	
	if self.m_SelectAreaID == eventargs.window:getID() then
		return true
	end
     lastServerID = -1
	self.m_SelectArea = eventargs.window:getText()
	self:ClearAllServerCells()
	self:RefreshServerCells(self.m_SelectArea)
    return true
end

function SelectServersDialog:OnInit()
    self.m_AreaServersMap = {}

    local servers = GetServerInfo():getAllServers()
    local areaIndex = 1
    local tuijianT = {}
    for index = 0, servers:size() - 1 do
        local nServerInfo = servers[index]
        local nAreaID = nServerInfo.areaID  --"I"
        local nServerid = nServerInfo.serverid   --"D"
        local nServerArea = nServerInfo.serverArea  --"A"
        local nServerName = nServerInfo.serverName --"N"
        local nServerIp = nServerInfo.serverIp --"P"
        local nServerPort = nServerInfo.serverPort --"T"
        local nServerState = nServerInfo.serverState --"S"
        local nServerStandby = nServerInfo.serverStandby --"B"   --���ö�˿�
        local nServerType = nServerInfo.serverType   --"C"
        local nServerOpenTime = nServerInfo.serverOpenTime  --"KS"
        local nServerFlag = nServerInfo.serverFlag --"NS"
        if nServerStandby == "" then
            nServerStandby = "1" 
        end

        if self.m_AreaServersMap[nServerArea] == nil then --��ʼ������
            self.m_AreaServersMap[nServerArea] = {}
            self.m_AreaServersMap[nServerArea].id = areaIndex
            self.m_AreaServersMap[nServerArea].name = nServerArea
            self.m_AreaServersMap[nServerArea].lastSelectID = -1
            self.m_AreaServersMap[nServerArea].servers = {}
            areaIndex = areaIndex + 1
        end

        local groupKey = nServerid
        local otS, otE
        otS, otE = string.find(nServerName, "-(%d+)-")
        if otS and otE then
            groupKey = string.sub(nServerName, otE+1, string.len(nServerName))
        end

        self.m_AreaServersMap[nServerArea].servers[groupKey] = {}
        self.m_AreaServersMap[nServerArea].servers[groupKey]["serverid"] = nServerid
        self.m_AreaServersMap[nServerArea].servers[groupKey]["servername"] = nServerName
        self.m_AreaServersMap[nServerArea].servers[groupKey]["ip"] = nServerIp
        self.m_AreaServersMap[nServerArea].servers[groupKey]["port"] = nServerPort
        self.m_AreaServersMap[nServerArea].servers[groupKey]["status"] = nServerState
        self.m_AreaServersMap[nServerArea].servers[groupKey]["standby"] = nServerStandby
        self.m_AreaServersMap[nServerArea].servers[groupKey]["type"] = nServerType
        self.m_AreaServersMap[nServerArea].servers[groupKey]["opentime"] = nServerOpenTime
        self.m_AreaServersMap[nServerArea].servers[groupKey]["flag"] = nServerFlag   --"0" �Ƽ�  "1"�¿�
        self.m_AreaServersMap[nServerArea].servers[groupKey]["exist"] = 0
        self.m_AreaServersMap[nServerArea].servers[groupKey]["orgid"] = groupKey  --�Ϸ�ǰid

        local stS, stE
        stS, stE = string.find(nServerName, "-%d+")
        if stS and stE then
            self.m_AreaServersMap[nServerArea].servers[groupKey]["sort"] = tonumber(string.sub(nServerName, stS + 1, stE))
        else
            self.m_AreaServersMap[nServerArea].servers[groupKey]["sort"] = 999999
        end

        if nServerFlag == SERVER_STATUS_TUIJIAN or nServerFlag == SERVER_STATUS_BOUTH then
            table.insert(tuijianT, self.m_AreaServersMap[nServerArea].servers[groupKey])
        end
    end

    --�����Ƽ����� �������з������ҵ��Ƽ�״̬��Ȼ���½������ӵ�������
    local area =  MHSD_UTILS.get_resstring(11550)
    self.m_AreaServersMap[area] = {}
    self.m_AreaServersMap[area].id = 0
    self.m_AreaServersMap[area].name = area
    self.m_AreaServersMap[area].lastSelectID = -1
    self.m_AreaServersMap[area].servers = {}
    for k, v in pairs(tuijianT) do
        self.m_AreaServersMap[area].servers[v.serverid] = v
    end
end

--������з�����cell��ʾ
function SelectServersDialog:ClearAllServerCells()
	if self.m_ArrayServerCells then
		for k,v in pairs(self.m_ArrayServerCells) do
			v:OnClose()
			v = nil
		end
	end
	self.m_ArrayServerCells = nil
end

function SelectServersDialog:ClearAllAreaCells()
	if self.m_Area then
		for k,v in pairs(self.m_Area) do
			v:OnClose()
			v = nil
		end
	end
	self.m_Area = nil
end

----/////////////////////////////////////////------
--ˢ�µ�ǰѡ�д����ķ������б�
function SelectServersDialog:RefreshServerCells(selectedAreaName)
	if self.m_AreaServersMap == nil then return end

	local selectedArea = self.m_AreaServersMap[selectedAreaName]
	if not selectedArea then
		for k,v in pairs(self.m_AreaServersMap) do
			if v.name == selectedAreaName then
				selectedArea = v
			end
		end
	end

	self:CheckServersLoad()

	if selectedArea then
		self.m_ArrayServerCells = {}

		local username = gGetLoginManager():GetAccount()
        local selectedSeverID = selectedArea.lastSelectID
		local col = 0
		local row = 0
		local index = 0

        local serversTable = {}
        local count = 1
        if selectedSeverID ~= -1 and selectedArea.servers[selectedSeverID] and selectedArea.servers[selectedSeverID].exist ~= -1 then
            selectedArea.servers[selectedSeverID].exist = 10 --������������ 
        end
        for _, v in pairs(selectedArea.servers) do
            serversTable[count] = v
            count = count + 1
        end

        table.sort(serversTable, function (a, b)
		    return a.sort < b.sort
	    end)

		for k,v in ipairs(serversTable) do
			col = index%2
			row = math.floor(index/2)
			index = index+1
            local curServerID = tonumber(v.serverid)
			self.m_ArrayServerCells[index] = SelectServersDialogCell.CreateNewDlg(self.m_ServerListBack)
			local mainFrame = self.m_ArrayServerCells[index]:GetWindow()
			local woffset = col*(mainFrame:getPixelSize().width - 15)
			local hoffset = row*(mainFrame:getPixelSize().height+1)
			mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, woffset), CEGUI.UDim(0.0, hoffset)))

            local cellServerKey = curServerID
            if v.orgid ~= v.serverid then
                cellServerKey = tonumber(v.orgid)
            end

			if index == 1 and selectedSeverID == -1 then
                if lastServerID == -1 then --û��Ĭ�ϵ�ȡ��һ��������id
                    selectedSeverID = cellServerKey
                    lastServerID = cellServerKey
                    selectedArea.lastSelectID = cellServerKey
                else
                    selectedSeverID = lastServerID 
                    selectedArea.lastSelectID = lastServerID
                end
			end

 
			self.m_ArrayServerCells[index]:SetCellInfo(cellServerKey, v, selectedSeverID, nil)

			if _serverLoadStateMap[curServerID] then
				self.m_ArrayServerCells[index]:setServerStatus(_serverLoadStateMap[curServerID].serverLoad)
			end

		end
		
		self:DeselectOtherServerBtn()
		self.m_ServerListBack:setVisible(true)

	end
end

function SelectServersDialog:DeselectOtherServerBtn()
	if self.m_SelectArea and self.m_AreaServersMap and self.m_AreaServersMap[self.m_SelectArea] then
		local selectServerID = tonumber(self.m_AreaServersMap[self.m_SelectArea].lastSelectID)
		for _,v in pairs(self.m_ArrayServerCells) do
			v:SetSelectedState(selectServerID)
		end
	end
end

function SelectServersDialog:SelectCurrentAreaBtn()
	if self.m_AreaServersMap[self.m_SelectArea] then
		local selectAreaID = tonumber(self.m_AreaServersMap[self.m_SelectArea].id)
		for k,v in pairs(self.m_Area) do
			v:SetSelectedState(selectAreaID)
		end
	end
end

function SelectServersDialog:CheckServersLoad()
	if self.m_AreaServersMap == nil then return end
	local selectedArea = self.m_AreaServersMap[self.m_SelectArea]
	if not selectedArea then
		for k,v in pairs(self.m_AreaServersMap) do
			if v.name == self.m_SelectArea then
				selectedArea = v
			end
		end
	end

	local timestamp = os.time() --second
	if selectedArea then
		for k,v in pairs(selectedArea.servers) do
			local key = tonumber(v.serverid)
			local serverLoad = _serverLoadStateMap[key]
             v.exist = GetServerInfo():getRoleHeadInfoByServerID(key)

			if not serverLoad or timestamp - serverLoad.timestamp >= CHECK_LOAD_DUR then
				gGetLoginManager():ClearConnectionByKey(key)

                local lowport = tonumber(v.port)
		        local highport = lowport + tonumber(v.standby) - 1
		        highport = math.max(lowport, highport)
		        local port = StringCover.randBetween(lowport, highport)
				local ip = v.ip

				gGetLoginManager():CheckLoad(ip, tostring(port), key)

				if not serverLoad then
					_serverLoadStateMap[key] = { serverLoad = 0 }
				end
				_serverLoadStateMap[key].timestamp = timestamp
			end

		end	
	end
end

function SelectServersDialog.SetServerLoad(serverKey, serverLoad)
	if _instance then
		if not _serverLoadStateMap[serverKey] then
			_serverLoadStateMap[serverKey] = {
				serverLoad = serverLoad,
				timestamp = os.time()
			}
		else
			_serverLoadStateMap[serverKey].serverLoad = serverLoad
		end

		if serverLoad == 1 or serverLoad == 2 or serverLoad == 3 then   --good 
			if _instance.m_ArrayServerCells then
				for k,v in pairs(_instance.m_ArrayServerCells) do
					if tonumber(v.serverid) == serverKey then
						v:setServerStatus(serverLoad)
					end
				end
			end
		elseif serverLoad == -1 then  --maintain
			if _instance.m_ArrayServerCells then
				for k,v in pairs(_instance.m_ArrayServerCells) do
					if tonumber(v.serverid) == serverKey then
						v:setServerStatus(serverLoad)
					end
				end
			end
		end

	elseif SelectServerEntry.getInstanceNotCreate() then --�����ǰ�ǿ�ݵ�¼������߼�
		SelectServerEntry.getInstance():SetServerLoad(serverKey, serverLoad)
	elseif require("logic.createroledialog"):getInstanceOrNot() then  --�����ǰ�����ﴴ��������߼�
		require("logic.createroledialog"):getInstanceOrNot():SetServerLoad(serverKey, serverLoad)
	end
end

----/////////////////////////////////////////------
--�½����ʼ�������б�
function SelectServersDialog:InitAreaList()
	LogInfo("SelectServersDialog InitAreaList")
	local AreaServerSort = {}
	local indexArea = 0
	for k,v in pairs(self.m_AreaServersMap) do  
		indexArea = indexArea + 1
		AreaServerSort[indexArea] = {}
		AreaServerSort[indexArea].id = v.id
		AreaServerSort[indexArea].name = k
	end
    --�Դ����������򣨱��⣩
	local sortFunc = function(a, b) return a.id < b.id end
	table.sort(AreaServerSort, sortFunc)

	self.m_Area = {}
	local index = 0
	for k,v in pairs(AreaServerSort)do-----��¼ѡ��
	    col = index%1
	    row = math.floor(index/1)
		index = index + 1
		self.m_Area[index] =  SelectServersAreaCell.CreateNewDlg(self.m_AreaListBack) --�������cell
		local mainFrame = self.m_Area[index]:GetWindow()
		local woffset = col*(mainFrame:getPixelSize().width - 15)
		local hoffset = row*(mainFrame:getPixelSize().height+1)
		mainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, woffset), CEGUI.UDim(0.0, hoffset)))
		self.m_Area[index]:SetCellInfo(v.id, v.name, self.m_SelectArea)
		self.m_Area[index].name = v.name
		self.m_Area[index].id = v.id
        self.m_SelectArea = v.name
	end

	self.m_AreaListBack:setVisible(true)
end



return SelectServersDialog

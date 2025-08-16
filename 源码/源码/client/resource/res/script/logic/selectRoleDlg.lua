require "logic.dialog"
require "logic.selectrolecell"

selectroledlg = {}
setmetatable(selectroledlg, Dialog)
selectroledlg.__index = selectroledlg

local _instance
function selectroledlg.getInstance()
	if not _instance then
		_instance = selectroledlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function selectroledlg.getInstanceAndShow()
	if not _instance then
		_instance = selectroledlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function selectroledlg.getInstanceNotCreate()
	return _instance
end

function selectroledlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
            if _instance.spine then
                _instance.spine:delete()
                _instance.spine = nil
            end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function selectroledlg.ToggleOpenClose()
	if not _instance then
		_instance = selectroledlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function selectroledlg.GetLayoutFileName()
	return "xuanzejuese.layout"
end

function selectroledlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, selectroledlg)
	return self
end

function selectroledlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.headImg = winMgr:getWindow("xuanzejuese/touxiang")
	self.okBtn = CEGUI.toPushButton(winMgr:getWindow("xuanzejuese/Back/OK"))
	self.list = CEGUI.toScrollablePane(winMgr:getWindow("xuanzejuese/back1//list"))
	self.roleImg2 = winMgr:getWindow("xuanzejuese/rolearea/roleimg2")
	self.spriteBg = winMgr:getWindow("xuanzejuese/Back/spritebg")
	self.roleImg1 = winMgr:getWindow("xuanzejuese/rolearea/roleimg1")
	self.roleNameText = winMgr:getWindow("xuanzejuese/back/rolename")
	self.schoolNameText = winMgr:getWindow("xuanzejuese/back/schoolname")
	self.schoolText = winMgr:getWindow("xuanzejuese/back/enSchoolName")
	self.roleNameText = winMgr:getWindow("xuanzejuese/back/enRoleName")
	self.returnBtn = CEGUI.toPushButton(winMgr:getWindow("xuanzejuese/Back/return"))
	self.spinebg = winMgr:getWindow("xuanzejuese/Back/roleback/1")
    self.spinebg:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, selectroledlg.performPostRenderFunctions))
	self.okBtn:subscribeEvent("Clicked", selectroledlg.handleOkClicked, self)
	self.returnBtn:subscribeEvent("Clicked", selectroledlg.handleReturnClicked, self)
    self.roleid = 0
    --self:initRoleList()
end

function selectroledlg:initRoleList(roleList)
    local preroleid = gGetLoginManager():GetPreLoginRoleID()
    self.roleData = {}
    self.roleList = {}
    self.roleData = roleList
	table.sort(self.roleData,function (a,b) return a.level > b.level end)
    local list = {}
    for i = 1, #roleList do
        if i <= 4 then
            list[i] = self.roleData[i]
        end
    end
    for k,v in pairs(list) do
        self.roleList[k] = selectrolecell.CreateNewDlg(self.list)
	    self.roleList[k]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0,  1 ), CEGUI.UDim(0,  (k-1)*self.roleList[k]:GetWindow():getPixelSize().height)))
	    self.roleList[k].groupButton:setID(k)
	    self.roleList[k].groupButton:EnableClickAni(false)
	    self.roleList[k].groupButton:subscribeEvent("MouseClick", selectroledlg.HandleRoleCellClicked, self)
        self.roleList[k]:setData(v.rolename, v.level, v.shape)
        if v.roleid == preroleid then
            self.roleList[k].groupButton:setSelected(true)
            self.roleNameText:setText(v.rolename)
            local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(v.school)
            self.schoolText:setText(schoolName.name)
            self:createSpineSprite(v.shape)
            self.roleid = v.roleid
        end
    end
    if self.roleid == 0 then
        self.roleid = self.roleData[1].roleid
    end
--    local roleNum = TableUtil.tablelength(roleList)
--    if roleNum <= 3 then
--        self.roleList[roleNum+1]  = selectrolecell.CreateNewDlg(self.list)
--        self.roleList[roleNum+1]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim( 0,  1 ), CEGUI.UDim(0,  roleNum*self.roleList[1]:GetWindow():getPixelSize().height)))
--	    self.roleList[roleNum+1].groupButton:EnableClickAni(false)
--	    self.roleList[roleNum+1].groupButton:subscribeEvent("MouseClick", selectroledlg.HandleCreateRoleCellClicked, self)
--    end
end

function selectroledlg:createSpineSprite(shape)
	 
	local ids = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getAllID()
	if shape>1010100 then
		shape=shape %100
	end
    local conf = BeanConfigManager.getInstance():GetTableByName("role.createroleconfig"):getRecorder(shape)
    local pos = self.spinebg:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x, pos.y)
   if self.spine then
       self.spine:delete()
       self.spine = nil
   end
    self.spine = UISpineSprite:new(conf.spine)
    self.spine:SetUILocation(loc)
    self.spine:PlayAction(eActionAttack)
end

function selectroledlg.performPostRenderFunctions(id)
	if selectroledlg:getInstance().spine then
		selectroledlg:getInstance().spine:RenderUISprite()
	end
end

--function selectroledlg:createConnection()
--    local account = gGetLoginManager():GetAccount()
--    local key = gGetLoginManager():GetPassword()
--	local servername = gGetLoginManager():GetSelectServer()
--	local area = gGetLoginManager():GetSelectArea()
--    local host = gGetLoginManager():GetHost()
--    local port = gGetLoginManager():GetPort()
--    local serverid = gGetLoginManager():getServerID()
--    local channelid = gGetLoginManager():GetChannelId();
--	gGetLoginManager():ClearConnections()
--    gGetGameApplication():CreateConnection(account, key, host, port, true, servername, area, serverid, channelid)
--    if gGetNetConnection() then
--        gGetNetConnection():setSecurityType(FireNet.enumSECURITY_ARCFOUR, FireNet.enumSECURITY_ARCFOUR)
--    end
--end

--function selectroledlg:HandleCreateRoleCellClicked(args)
--    local dlg = require "logic.createroledialog":getInstance()
--    return true
--end

function selectroledlg:HandleRoleCellClicked(e)
    local wndArgs = CEGUI.toWindowEventArgs(e)
	local id = wndArgs.window:getID()
    self.roleNameText:setText(self.roleData[id].rolename)
    local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(self.roleData[id].school)
    self.schoolText:setText(schoolName.name)
    self:createSpineSprite(self.roleData[id].shape)
    self.roleid = self.roleData[id].roleid
    return true
end

function selectroledlg:handleOkClicked(args)
    --self:createConnection()
    gGetGameApplication():BeginDrawServantIntro()
    if gGetGameApplication():GetXmlBeanReady() then
		gGetGameApplication():DrawLoginBar(20)
		tolua.cast(Nuclear.GetEngine(), "Nuclear::Engine"):Draw()
        local numMaxShowNum = SystemSettingNewDlg.GetMaxDisplayPlayerNum()
        local a = fire.pb.CEnterWorld(self.roleid, numMaxShowNum)
        gGetNetConnection():send(a)
    else
		gGetGameApplication():DrawLoginBar(10)
		tolua.cast(Nuclear.GetEngine(), "Nuclear::Engine"):Draw()
        gGetGameApplication():SetWaitToEnterWorld(true)
        gGetGameApplication():SetEnterWorldRoleID(self.roleid)
	end
    gGetGameApplication():SetWaitForEnterWorldState(true);
end

function selectroledlg:handleReturnClicked(args)
	local trd_platform = require "config".TRD_PLATFORM
	if trd_platform==1 then
		MT3.ChannelManager:ChangeUserLogin()
	else
		SelectServerEntry.getInstanceAndShow()
	end
	if gGetLoginManager() then
		gGetLoginManager():Init()
	end
    local p = require("protodef.fire.pb.cuseroffline"):new()
	LuaProtocolManager:send(p)
	self:DestroyDialog()
end

return selectroledlg
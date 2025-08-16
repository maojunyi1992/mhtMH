require "logic.dialog"

fubenEnterDlg = {}
setmetatable(fubenEnterDlg, Dialog)
fubenEnterDlg.__index = fubenEnterDlg

local _instance
local maxWaitTime = 20000
function fubenEnterDlg.getInstance()
	if not _instance then
		_instance = fubenEnterDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function fubenEnterDlg.getInstanceAndShow()
	if not _instance then
		_instance = fubenEnterDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function fubenEnterDlg.getInstanceNotCreate()
	return _instance
end

function fubenEnterDlg.DestroyDialog()
	if _instance then 
        NotificationCenter.removeObserver(Notifi_TeamListChange, fubenEnterDlg.handleEventMemberChange)
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function fubenEnterDlg.ToggleOpenClose()
	if not _instance then
		_instance = fubenEnterDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function fubenEnterDlg.GetLayoutFileName()
	return "erciqueren.layout"
end

function fubenEnterDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, fubenEnterDlg)
	return self
end

function fubenEnterDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

    self.teamInfo = {
        [1] = {},
        [2] = {},
        [3] = {},
        [4] = {},
        [5] = {}
    }

	self.btnEnsure = CEGUI.toPushButton(winMgr:getWindow("erciqueren_mtg/oK"))
    self.btnEnsure:subscribeEvent("Clicked", fubenEnterDlg.HandleEnsureClicked,self)
	self.btnCancle = CEGUI.toPushButton(winMgr:getWindow("erciqueren_mtg/Canle"))
    self.btnCancle:subscribeEvent("Clicked", fubenEnterDlg.HandleCancleClicked,self)
	self.title = winMgr:getWindow("erciqueren_mtg/biaoti")
	self.name = winMgr:getWindow("erciqueren_mtg/jiemiantips1")
    self.ensureText = winMgr:getWindow("erciqueren_mtg/yiquerentips")
    self.leaderSchdule = winMgr:getWindow("erciqueren_mtg/tishitips1")
    self.mySchdule = winMgr:getWindow("erciqueren_mtg/tishitips3")
    self.btnClose = CEGUI.toPushButton(winMgr:getWindow("erciqueren_mtg/guanbi"))
    self.btnClose:subscribeEvent("Clicked", fubenEnterDlg.HandleCloseClicked,self)
    self.txtLeaveLevel = winMgr:getWindow("erciqueren_mtg/tishitips4")
    
    self.ensureText:setVisible(false)
    self.teamInfo[1].image = winMgr:getWindow("erciqueren_mtg/touxiang1/image")
    self.teamInfo[1].stateText = winMgr:getWindow("erciqueren_mtg/querenzhuangtai1")
	self.teamInfo[1].name = winMgr:getWindow("erciqueren_mtg/juesemingcheng1")
    self.teamInfo[1].state = winMgr:getWindow("erciqueren_mtg/touxiang1/querenbiaoshi1")
    self.teamInfo[1].refuse = winMgr:getWindow("erciqueren_mtg/touxiang1/jujuebiaoshi1")
    self.teamInfo[1].leave = winMgr:getWindow("erciqueren_mtg/touxiang1/zanlibiaoshi1")
    self.teamInfo[1].offLine = winMgr:getWindow("erciqueren_mtg/touxiang1/lixianbiaoshi1")
    self.teamInfo[1].school = winMgr:getWindow("erciqueren_mtg/touxiang1/zhiyebiaoshi")
    self.teamInfo[1].back = winMgr:getWindow("erciqueren_mtg/touxiang1/back")

    self.teamInfo[2].image = winMgr:getWindow("erciqueren_mtg/touxiang2/image")
    self.teamInfo[2].stateText = winMgr:getWindow("erciqueren_mtg/querenzhuangtai2")
    self.teamInfo[2].name = winMgr:getWindow("erciqueren_mtg/juesemingcheng2")
    self.teamInfo[2].state = winMgr:getWindow("erciqueren_mtg/touxiang1/querenbiaoshi2")
    self.teamInfo[2].refuse = winMgr:getWindow("erciqueren_mtg/touxiang1/jujuebiaoshi2")
    self.teamInfo[2].leave = winMgr:getWindow("erciqueren_mtg/touxiang1/zanlibiaoshi2")
    self.teamInfo[2].offLine = winMgr:getWindow("erciqueren_mtg/touxiang2/lixianbiaoshi2")
    self.teamInfo[2].school = winMgr:getWindow("erciqueren_mtg/touxiang2/zhiyebiaoshi2")
    self.teamInfo[2].back = winMgr:getWindow("erciqueren_mtg/touxiang2/back")

	self.teamInfo[3].image = winMgr:getWindow("erciqueren_mtg/touxiang3/image")
	self.teamInfo[3].stateText = winMgr:getWindow("erciqueren_mtg/querenzhuangtai3")
    self.teamInfo[3].name = winMgr:getWindow("erciqueren_mtg/juesemingcheng3")
	self.teamInfo[3].state = winMgr:getWindow("erciqueren_mtg/touxiang1/querenbiaoshi3")
    self.teamInfo[3].refuse = winMgr:getWindow("erciqueren_mtg/touxiang1/jujuebiaoshi3") 
    self.teamInfo[3].leave = winMgr:getWindow("erciqueren_mtg/touxiang1/zanlibiaoshi3")
    self.teamInfo[3].offLine = winMgr:getWindow("erciqueren_mtg/touxiang3/lixianbiaoshi3")
    self.teamInfo[3].school = winMgr:getWindow("erciqueren_mtg/touxiang3/zhiyebiaoshi3")
    self.teamInfo[3].back = winMgr:getWindow("erciqueren_mtg/touxiang3/back")

	self.teamInfo[4].image = winMgr:getWindow("erciqueren_mtg/touxiang4/image")
	self.teamInfo[4].stateText = winMgr:getWindow("erciqueren_mtg/querenzhuangtai4")
	self.teamInfo[4].name = winMgr:getWindow("erciqueren_mtg/juesemingcheng4")
	self.teamInfo[4].state = winMgr:getWindow("erciqueren_mtg/touxiang1/querenbiaoshi4")
    self.teamInfo[4].refuse = winMgr:getWindow("erciqueren_mtg/touxiang1/jujuebiaoshi4") 
    self.teamInfo[4].leave = winMgr:getWindow("erciqueren_mtg/touxiang1/zanlibiaoshi4")
    self.teamInfo[4].offLine = winMgr:getWindow("erciqueren_mtg/touxiang4/lixianbiaoshi14")
    self.teamInfo[4].school = winMgr:getWindow("erciqueren_mtg/touxiang4/zhiyebiaoshi4")
    self.teamInfo[4].back = winMgr:getWindow("erciqueren_mtg/touxiang4/back")

	self.teamInfo[5].image = winMgr:getWindow("erciqueren_mtg/touxiang5/image")
	self.teamInfo[5].stateText = winMgr:getWindow("erciqueren_mtg/querenzhuangtai5")
	self.teamInfo[5].name = winMgr:getWindow("erciqueren_mtg/juesemingcheng5")
	self.teamInfo[5].state = winMgr:getWindow("erciqueren_mtg/touxiang1/querenbiaoshi5")
    self.teamInfo[5].refuse = winMgr:getWindow("erciqueren_mtg/touxiang1/jujuebiaoshi5")
    self.teamInfo[5].leave = winMgr:getWindow("erciqueren_mtg/touxiang1/zanlibiaoshi5")
    self.teamInfo[5].offLine = winMgr:getWindow("erciqueren_mtg/touxiang5/lixianbiaoshi15")
    self.teamInfo[5].school = winMgr:getWindow("erciqueren_mtg/touxiang5/zhiyebiaoshi5")
    self.teamInfo[5].back = winMgr:getWindow("erciqueren_mtg/touxiang5/back")
	self.leaveTime = winMgr:getWindow("erciqueren_mtg/jianglitips1") -- 剩余次数
	self.timeBar = CEGUI.toProgressBar(winMgr:getWindow("erciqueren_mtg/querendaojishi/jindutiao"))
	self.time = winMgr:getWindow("erciqueren_mtg/querendaojishi1")
    NotificationCenter.addObserver(Notifi_TeamListChange, fubenEnterDlg.handleEventMemberChange)
    for i = 1, 5 do
        self.teamInfo[i].name:setVisible(false)
        self.teamInfo[i].stateText:setVisible(false)
        self.teamInfo[i].state:setVisible(false)
        self.teamInfo[i].refuse:setVisible(false)
        self.teamInfo[i].leave:setVisible(false)
        self.teamInfo[i].offLine:setVisible(false)
        self.teamInfo[i].back:setVisible(false)
    end
    self:initData()
end

function fubenEnterDlg:handleEventMemberChange()
    GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(166057).msg)
    fubenEnterDlg.DestroyDialog()
end

--
function fubenEnterDlg:initData()
    local size = GetTeamManager():GetTeamMemberNum()
    local memberInfo
    local Shape
	local iconpath
    for i = 1, size do
        memberInfo = GetTeamManager():GetMember(i)
        Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(memberInfo.shapeID)
	    iconpath = gGetIconManager():GetImagePathByID(Shape.littleheadID)
        local schoolrecord=BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(memberInfo.eSchool)
        self.teamInfo[i].stateText:setVisible(true)
        self.teamInfo[i].name:setVisible(true)
        self.teamInfo[i].school:setVisible(true)
        self.teamInfo[i].school:setProperty("Image", schoolrecord.schooliconpath)
        self.teamInfo[i].name:setText(memberInfo.strName)
        self.teamInfo[i].image:setProperty("Image", iconpath:c_str())
        self.teamInfo[i].roleId = memberInfo.id
        if gGetDataManager():GetMainCharacterID() == memberInfo.id then
            self.teamInfo[i].back:setVisible(true)
        end
        if GetTeamManager():isAbsentByRoleid(memberInfo.id) == true then
            self.teamInfo[i].leave:setVisible(true)
            self.teamInfo[i].stateText:setVisible(false)
        end
        if GetTeamManager():isOffLineByRoleid(memberInfo.id) == true then
            self.teamInfo[i].offLine:setVisible(true)
            self.teamInfo[i].stateText:setVisible(false)
        end
   end
   self.waitTime = maxWaitTime
end
-- 初始化服务器返回的信息
function fubenEnterDlg:initConnectedData( data )
    self.leaveTime:setText(tostring(data.leaveTime))
    self.title:setText(data.name)
    self.name:setText(data.name)
    self.s_FBName=data.name
    self.insttype = data.insttype
    self.leaderSchdule:setText( data.tlstep.."/"..data.allstep)
    self.mySchdule:setText( data.mystep.."/"..data.allstep)
    local str = ""
    for k,v in pairs(data.steplist) do
        str = str..require("utils.mhsdutils").get_resstring(11581)..tostring(v)
        if k ~= TableUtil.tablelength(data.steplist) then
            str = str..","
        end
    end
     if (data.leaveTime == 0 and TableUtil.tablelength(data.steplist) == 0) or (TableUtil.tablelength(data.steplist) == 0 and data.leaveTime == 2) then
         self.txtLeaveLevel:setText(require("utils.mhsdutils").get_resstring(11596))
     else
         local strAllMsg = require("utils.mhsdutils").get_resstring(11582)
         local sb = StringBuilder.new()
         local strParam = "parameter1"
         sb:Set(strParam,str)
         strAllMsg = sb:GetString(strAllMsg)
         sb:delete()
         self.txtLeaveLevel:setText(strAllMsg)
     end

    if data.autoenter == 1 then
        self:HandleEnsureClicked(0)
    else
        self:loadLocalFBSetting()
    end
     
end

function fubenEnterDlg:loadLocalFBSetting()
    local mKey = 0
    local autoStart = 0
    local vAllTableId = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getAllID()
    for i = 1, #vAllTableId do
        local info = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(i)
         if info and info.name == self.s_FBName then
            mKey = info.enterLevel
            break
         end
    end

    if mKey ~= 0 then
        autoStart = gGetDataManager().m_fubenSettingMap[mKey]
    end

    if autoStart == 1 then
        self:HandleEnsureClicked(0)
    end
end

function fubenEnterDlg:getMemberIndexByID(roleId)
    for i = 1, 5 do
        if self.teamInfo[i].roleId == roleId then
            return i
        end
    end
    return 0
end

function fubenEnterDlg:refreshMemberInfo(roleId, answer)
    local index = self:getMemberIndexByID(roleId)
    if answer == 1 then -- 同意
        self.teamInfo[index].state:setVisible(true)
        self.teamInfo[index].stateText:setVisible(false)
        self.teamInfo[index].refuse:setVisible(false)
    elseif answer == 0 then -- 不同意
        self.teamInfo[index].state:setVisible(false)
        self.teamInfo[index].stateText:setVisible(false)
        self.teamInfo[index].refuse:setVisible(true)
    end
end

function fubenEnterDlg:HandleEnsureClicked(args)
    self:sendSelectedInfo(1)
	self.btnEnsure:setVisible(false)
    self.ensureText:setVisible(true)
end

function fubenEnterDlg:HandleCancleClicked(args)
    self:sendSelectedInfo(0)
    self.btnEnsure:setVisible(true)
    self.ensureText:setVisible(false)
end

function fubenEnterDlg:HandleCloseClicked(args)
    fubenEnterDlg.DestroyDialog()
end

function fubenEnterDlg:sendSelectedInfo( answer )
    local p = require("protodef.fire.pb.mission.caskintoinstance"):new()
    p.answer = answer
    p.insttype = self.insttype
	LuaProtocolManager:send(p)
end

function fubenEnterDlg:run(delta)
    self.waitTime = self.waitTime - delta
    if self.waitTime > 0 then
        local intTime = math.floor(self.waitTime / 1000)
        self.time:setText(tostring(intTime).."s")
        if self.timeBar then
            self.timeBar:setProgress(self.waitTime / maxWaitTime)
        end
    else
        --self:sendSelectedInfo(0)
        fubenEnterDlg.DestroyDialog()
    end
end

return fubenEnterDlg
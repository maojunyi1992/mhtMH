require "logic.dialog"

jingmaihecheng_pt1 = {}
setmetatable(jingmaihecheng_pt1, Dialog)
jingmaihecheng_pt1.__index = jingmaihecheng_pt1

local _instance
function jingmaihecheng_pt1.getInstance()
	if not _instance then
		_instance = jingmaihecheng_pt1:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_pt1.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_pt1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_pt1.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_pt1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_pt1.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_pt1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_pt1.GetLayoutFileName()
	return "jingmaihecheng_pt.layout"
end

function jingmaihecheng_pt1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_pt1)
	return self
end

function jingmaihecheng_pt1:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_pt1:OnCreate()
    LogInfo("jingmaihecheng_pt oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1pt1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt1"))
	self.m_hc1pt2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt2"))
	self.m_hc1pt3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt3"))
	self.m_hc1pt4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt4"))
	self.m_hc1pt5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt5"))
	self.m_hc1pt6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt6"))
	self.m_hc1pt7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt7"))
	self.m_hc1pt8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/pt8"))
	self.m_ptbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/ptbiaoti1"))
	self.m_ptbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/ptbiaoti2"))
	self.m_ptbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/ptbiaoti3"))
	self.m_ptbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/ptbiaoti4"))
	self.m_ptbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/ptbiaoti5"))
	self.m_ptbiaoti2:setVisible(false)
	self.m_ptbiaoti3:setVisible(false)
	self.m_ptbiaoti4:setVisible(false)
	self.m_ptbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_pt/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1pt1:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt1, self)
	self.m_hc1pt2:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt2, self)
	self.m_hc1pt3:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt3, self)
	self.m_hc1pt4:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt4, self)
	self.m_hc1pt5:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt5, self)
	self.m_hc1pt6:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt6, self)
	self.m_hc1pt7:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt7, self)
	self.m_hc1pt8:subscribeEvent("Clicked", jingmaihecheng_pt1.hc1pt8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_pt1.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1pt1 = 930487
TaskHelper.m_hc1pt2 = 930488
TaskHelper.m_hc1pt3 = 930489
TaskHelper.m_hc1pt4 = 930490
TaskHelper.m_hc1pt5 = 930491
TaskHelper.m_hc1pt6 = 930492
TaskHelper.m_hc1pt7 = 930493
TaskHelper.m_hc1pt8 = 930494

-- function jingmaihecheng_pt1:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_pt1:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_pt1:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_pt1:jingmaibeibao(args)
    LogInfo("maincontrol pack button clicked")

    -- �����˵��ر���������
    if CChatOutputDialog:getInstance() then
        CChatOutputDialog:getInstance():OnClose()
    end
	CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show()
    self.m_fAutoHideTime = 0

   local Taskuseitemdialog = require("logic.task.taskuseitemdialog")
   local useItemDlg = Taskuseitemdialog.getInstanceNotCreate()
   if useItemDlg then
      if useItemDlg.nType == Taskuseitemdialog.eUseType.chuanzhuangbei then
            Taskuseitemdialog.DestroyDialog()
      end
   end
    return true
end


function jingmaihecheng_pt1.hc1pt1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_pt1.hc1pt2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_pt1.hc1pt3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_pt1.hc1pt4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_pt1.hc1pt5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_pt1.hc1pt6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_pt1.hc1pt7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_pt1.hc1pt8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1pt8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_pt1

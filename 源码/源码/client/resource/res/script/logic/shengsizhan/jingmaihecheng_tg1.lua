require "logic.dialog"

jingmaihecheng_tg1 = {}
setmetatable(jingmaihecheng_tg1, Dialog)
jingmaihecheng_tg1.__index = jingmaihecheng_tg1

local _instance
function jingmaihecheng_tg1.getInstance()
	if not _instance then
		_instance = jingmaihecheng_tg1:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_tg1.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_tg1:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_tg1.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_tg1.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_tg1.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_tg1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_tg1.GetLayoutFileName()
	return "jingmaihecheng_tg.layout"
end

function jingmaihecheng_tg1:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_tg1)
	return self
end

function jingmaihecheng_tg1:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_tg1:OnCreate()
    LogInfo("jingmaihecheng_tg oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1tg1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg1"))
	self.m_hc1tg2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg2"))
	self.m_hc1tg3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg3"))
	self.m_hc1tg4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg4"))
	self.m_hc1tg5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg5"))
	self.m_hc1tg6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg6"))
	self.m_hc1tg7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg7"))
	self.m_hc1tg8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tg8"))
	self.m_tgbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tgbiaoti1"))
	self.m_tgbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tgbiaoti2"))
	self.m_tgbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tgbiaoti3"))
	self.m_tgbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tgbiaoti4"))
	self.m_tgbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/tgbiaoti5"))
	self.m_tgbiaoti2:setVisible(false)
	self.m_tgbiaoti3:setVisible(false)
	self.m_tgbiaoti4:setVisible(false)
	self.m_tgbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_tg/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1tg1:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg1, self)
	self.m_hc1tg2:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg2, self)
	self.m_hc1tg3:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg3, self)
	self.m_hc1tg4:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg4, self)
	self.m_hc1tg5:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg5, self)
	self.m_hc1tg6:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg6, self)
	self.m_hc1tg7:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg7, self)
	self.m_hc1tg8:subscribeEvent("Clicked", jingmaihecheng_tg1.hc1tg8, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_tg1.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1tg1 = 930519
TaskHelper.m_hc1tg2 = 930520
TaskHelper.m_hc1tg3 = 930521
TaskHelper.m_hc1tg4 = 930522
TaskHelper.m_hc1tg5 = 930523
TaskHelper.m_hc1tg6 = 930524
TaskHelper.m_hc1tg7 = 930525
TaskHelper.m_hc1tg8 = 930526

-- function jingmaihecheng_tg1:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_tg1:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_tg1:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_tg1:jingmaibeibao(args)
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


function jingmaihecheng_tg1.hc1tg1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_tg1.hc1tg2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_tg1.hc1tg3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_tg1.hc1tg4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_tg1.hc1tg5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_tg1.hc1tg6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_tg1.hc1tg7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_tg1.hc1tg8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1tg8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_tg1

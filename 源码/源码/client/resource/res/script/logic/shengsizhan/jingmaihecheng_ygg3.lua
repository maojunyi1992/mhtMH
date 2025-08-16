require "logic.dialog"

jingmaihecheng_ygg2 = {}
setmetatable(jingmaihecheng_ygg2, Dialog)
jingmaihecheng_ygg2.__index = jingmaihecheng_ygg2

local _instance
function jingmaihecheng_ygg2.getInstance()
	if not _instance then
		_instance = jingmaihecheng_ygg2:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_ygg2.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_ygg2:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_ygg2.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_ygg2.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_ygg2.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_ygg2:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_ygg2.GetLayoutFileName()
	return "jingmaihecheng_ygg12.layout"
end

function jingmaihecheng_ygg2:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_ygg2)
	return self
end

function jingmaihecheng_ygg2:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_ygg2:OnCreate()
    LogInfo("jingmaihecheng_ygg2 oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1yg1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg1"))
	self.m_hc1yg2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg2"))
	self.m_hc1yg3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg3"))
	self.m_hc1yg4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg4"))
	self.m_hc1yg5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg5"))
	self.m_hc1yg6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg6"))
	self.m_hc1yg7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg7"))
	self.m_hc1yg8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg8"))
	self.m_hc1yg9 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg9"))
	self.m_hc1yg10 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg10"))
	self.m_hc1yg11 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg11"))
	self.m_hc1yg12 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg12"))
	self.m_hc1yg13 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg13"))
	self.m_hc1yg14 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg14"))
	self.m_hc1yg15 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg15"))
	self.m_hc1yg16 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg16"))
	self.m_hc1yg17 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg17"))
	self.m_hc1yg18 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/yg18"))
	self.m_ygbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/ygbiaoti1"))
	self.m_ygbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/ygbiaoti2"))
	self.m_ygbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/ygbiaoti3"))
	self.m_ygbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/ygbiaoti4"))
	self.m_ygbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/ygbiaoti5"))
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/back"))
	self.m_ygbiaoti2:setVisible(false)
	self.m_ygbiaoti3:setVisible(false)
	self.m_ygbiaoti4:setVisible(false)
	self.m_ygbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg2/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1yg1:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg1, self)
	self.m_hc1yg2:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg2, self)
	self.m_hc1yg3:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg3, self)
	self.m_hc1yg4:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg4, self)
	self.m_hc1yg5:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg5, self)
	self.m_hc1yg6:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg6, self)
	self.m_hc1yg7:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg7, self)
	self.m_hc1yg8:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg8, self)
	self.m_hc1yg9:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg9, self)
	self.m_hc1yg10:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg10, self)
	self.m_hc1yg11:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg11, self)
	self.m_hc1yg12:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg12, self)
	self.m_hc1yg13:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg13, self)
	self.m_hc1yg14:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg14, self)
	self.m_hc1yg15:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg15, self)
	self.m_hc1yg16:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg16, self)
	self.m_hc1yg17:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg17, self)
	self.m_hc1yg18:subscribeEvent("Clicked", jingmaihecheng_ygg2.hc1yg18, self)
	self.m_btnguanbi:subscribeEvent("Clicked", jingmaihecheng_ygg2.handleQuitBtnClicked, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_ygg2.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1yg1 = 930431
TaskHelper.m_hc1yg2 = 930431
TaskHelper.m_hc1yg3 = 930431
TaskHelper.m_hc1yg4 = 930431
TaskHelper.m_hc1yg5 = 930431
TaskHelper.m_hc1yg6 = 930431
TaskHelper.m_hc1yg7 = 930431
TaskHelper.m_hc1yg8 = 930431
TaskHelper.m_hc1yg9 = 930431
TaskHelper.m_hc1yg10 = 930431
TaskHelper.m_hc1yg11 = 930431
TaskHelper.m_hc1yg12 = 930431
TaskHelper.m_hc1yg13 = 930431
TaskHelper.m_hc1yg14 = 930431
TaskHelper.m_hc1yg15 = 930431
TaskHelper.m_hc1yg16 = 930431
TaskHelper.m_hc1yg17 = 930431
TaskHelper.m_hc1yg18 = 8018018

-- function jingmaihecheng_ygg2:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_ygg2:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_ygg2:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_ygg2:jingmaibeibao(args)
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
function jingmaihecheng_ygg2:handleQuitBtnClicked(e)
if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_ygg2.hc1yg1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg9()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg9
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg10()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg10
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg11()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg11
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg12()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg12
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg13()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg13
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg14()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg14
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg15()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg15
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg16()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg16
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg17()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg17
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg2.hc1yg18()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg18
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_ygg2

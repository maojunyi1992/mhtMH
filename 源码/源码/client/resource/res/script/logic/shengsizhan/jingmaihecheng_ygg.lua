require "logic.dialog"

jingmaihecheng_ygg = {}
setmetatable(jingmaihecheng_ygg, Dialog)
jingmaihecheng_ygg.__index = jingmaihecheng_ygg

local _instance
function jingmaihecheng_ygg.getInstance()
	if not _instance then
		_instance = jingmaihecheng_ygg:new()
		_instance:OnCreate()
	end
	return _instance
end

function jingmaihecheng_ygg.getInstanceAndShow()
	if not _instance then
		_instance = jingmaihecheng_ygg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function jingmaihecheng_ygg.getInstanceNotCreate()
	return _instance
end

function jingmaihecheng_ygg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_ygg.ToggleOpenClose()
	if not _instance then
		_instance = jingmaihecheng_ygg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function jingmaihecheng_ygg.GetLayoutFileName()
	return "jingmaihecheng_ygg.layout"
end

function jingmaihecheng_ygg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, jingmaihecheng_ygg)
	return self
end

function jingmaihecheng_ygg:OnCreate()
	Dialog.OnCreate(self)
end

function jingmaihecheng_ygg:OnCreate()
    LogInfo("jingmaihecheng_ygg oncreate begin")
    Dialog.OnCreate(self)
	self:GetWindow():setRiseOnClickEnabled(false)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
 


    self.m_hc1yg1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg1"))
	self.m_hc1yg2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg2"))
	self.m_hc1yg3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg3"))
	self.m_hc1yg4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg4"))
	self.m_hc1yg5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg5"))
	self.m_hc1yg6 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg6"))
	self.m_hc1yg7 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg7"))
	self.m_hc1yg8 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg8"))
	self.m_hc1yg9 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg9"))
	self.m_hc1yg10 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg10"))
	self.m_hc1yg11 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg11"))
	self.m_hc1yg12 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg12"))
	self.m_hc1yg13 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg13"))
	self.m_hc1yg14 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg14"))
	self.m_hc1yg15 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg15"))
	self.m_hc1yg16 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg16"))
	self.m_hc1yg17 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg17"))
	self.m_hc1yg18 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/yg18"))
	self.m_ygbiaoti1 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/ygbiaoti1"))
	self.m_ygbiaoti2 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/ygbiaoti2"))
	self.m_ygbiaoti3 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/ygbiaoti3"))
	self.m_ygbiaoti4 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/ygbiaoti4"))
	self.m_ygbiaoti5 = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/ygbiaoti5"))
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/back"))
	self.m_ygbiaoti2:setVisible(false)
	self.m_ygbiaoti3:setVisible(false)
	self.m_ygbiaoti4:setVisible(false)
	self.m_ygbiaoti5:setVisible(false)

    self.m_jingmaibeibao = CEGUI.Window.toPushButton(winMgr:getWindow("jingmaihecheng_ygg/back/pack"))
   -- self.m_pKuaijieBtn:subscribeEvent("Clicked", self.HandleKuaijieBtnClicked, self)
	--self.m_pKuaijieBtn:subscribeEvent("MouseClick", PetAndUserIcon.HandleKuaijieBtnClicked, self)
	self.m_hc1yg1:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg1, self)
	self.m_hc1yg2:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg2, self)
	self.m_hc1yg3:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg3, self)
	self.m_hc1yg4:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg4, self)
	self.m_hc1yg5:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg5, self)
	self.m_hc1yg6:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg6, self)
	self.m_hc1yg7:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg7, self)
	self.m_hc1yg8:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg8, self)
	self.m_hc1yg9:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg9, self)
	self.m_hc1yg10:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg10, self)
	self.m_hc1yg11:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg11, self)
	self.m_hc1yg12:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg12, self)
	self.m_hc1yg13:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg13, self)
	self.m_hc1yg14:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg14, self)
	self.m_hc1yg15:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg15, self)
	self.m_hc1yg16:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg16, self)
	self.m_hc1yg17:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg17, self)
	self.m_hc1yg18:subscribeEvent("Clicked", jingmaihecheng_ygg.hc1yg18, self)
	self.m_btnguanbi:subscribeEvent("Clicked", jingmaihecheng_ygg.handleQuitBtnClicked, self)
	self.m_jingmaibeibao:subscribeEvent("Clicked", jingmaihecheng_ygg.jingmaibeibao, self)

	



 
    self:GetWindow():setRiseOnClickEnabled(false)
    self:GetWindow():setAlwaysOnBottom(true)
end
------------------------------------------------------

------------------------------------------------------
TaskHelper.m_hc1yg1 = 930636
TaskHelper.m_hc1yg2 = 930635
TaskHelper.m_hc1yg3 = 930634
TaskHelper.m_hc1yg4 = 930633
TaskHelper.m_hc1yg5 = 930632
TaskHelper.m_hc1yg6 = 930631
TaskHelper.m_hc1yg7 = 930630
TaskHelper.m_hc1yg8 = 930629
TaskHelper.m_hc1yg9 = 930628
TaskHelper.m_hc1yg10 = 930627
TaskHelper.m_hc1yg11 = 930626
TaskHelper.m_hc1yg12 = 930625
TaskHelper.m_hc1yg13 = 930624
TaskHelper.m_hc1yg14 = 930623
TaskHelper.m_hc1yg15 = 930622
TaskHelper.m_hc1yg16 = 930621
TaskHelper.m_hc1yg17 = 930620
TaskHelper.m_hc1yg18 = 930619

-- function jingmaihecheng_ygg:HandleKuaijieBtnClicked(args)
--     local dlg = require("script.logic.pet.jingmaihecheng").getInstanceAndShow()

-- end

-- function jingmaihecheng_ygg:HandleKuaijieBtnClicked(EventArgs)
--     require "logic.pet.jingmaihecheng".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end

-- function jingmaihecheng_ygg:HandlePetIconClick(EventArgs)
--     require "logic.pet.petlabel".Show()
--     if CChatOutputDialog:getInstance() then
--         CChatOutputDialog:getInstance():OnClose()
--     end
-- end
function jingmaihecheng_ygg:jingmaibeibao(args)
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
function jingmaihecheng_ygg:handleQuitBtnClicked(e)
if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function jingmaihecheng_ygg.hc1yg1()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg1
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg2()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg2
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg3()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg3
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg4()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg4
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg5()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg5
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg6()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg6
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg7()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg7
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg8()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg8
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg9()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg9
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg10()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg10
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg11()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg11
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg12()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg12
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg13()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg13
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg14()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg14
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg15()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg15
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg16()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg16
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg17()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg17
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end
function jingmaihecheng_ygg.hc1yg18()
	local nNpcKey = 0
	local nServiceId = TaskHelper.m_hc1yg18
	require "manager.npcservicemanager".SendNpcService(nNpcKey,nServiceId)

end


return jingmaihecheng_ygg

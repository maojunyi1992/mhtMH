------------------------------------------------------------------
-- 清包验证码
------------------------------------------------------------------
require "logic.dialog"

CleanBagyzm = {}
setmetatable(CleanBagyzm, Dialog)
CleanBagyzm.__index = CleanBagyzm

local _instance
function CleanBagyzm.getInstance()
	if not _instance then
		_instance = CleanBagyzm:new()
		_instance:OnCreate()
	end
	return _instance
end

function CleanBagyzm.getInstanceAndShow()
	if not _instance then
		_instance = CleanBagyzm:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function CleanBagyzm.getInstanceNotCreate()
	return _instance
end

function CleanBagyzm.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function CleanBagyzm.ToggleOpenClose()
	if not _instance then
		_instance = CleanBagyzm:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CleanBagyzm.GetLayoutFileName()
	return "cleanbagyzm.layout"
end

function CleanBagyzm:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CleanBagyzm)
	return self
end

function CleanBagyzm:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("cleanbagyzm/framewindow"))
	self.desText = winMgr:getWindow("cleanbagyzm/text")
	self.inputNum = winMgr:getWindow("cleanbagyzm/bg/shurukuang/inputNum")
	self.numText = winMgr:getWindow("cleanbagyzm/bg/bg2/text1")
	self.placeholder = winMgr:getWindow("cleanbagyzm/bg/shurukuang/placeholder")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("cleanbagyzm/buton1"))
	self.freeBtn = CEGUI.toPushButton(winMgr:getWindow("cleanbagyzm/buton2"))
    local str ="操作不可逆,你确定要清理背包吗？"
	self.desText:setText(str)
	self.freeBtn:subscribeEvent("Clicked", CleanBagyzm.handleFreeClicked, self)
	self.cancelBtn:subscribeEvent("Clicked", CleanBagyzm.DestroyDialog, nil)
	self.frameWindow:getCloseButton():subscribeEvent("Clicked", CleanBagyzm.DestroyDialog, nil)
	self.inputNum:subscribeEvent("MouseButtonDown", CleanBagyzm.handleInputNumClicked, self)
	
	self:randomNumber()
end

function CleanBagyzm:randomNumber()
	local t = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
	local r = {}
	
	--math.randomseed(os.time())
	for i=1, 4 do
		local idx = math.random(1, #t)
		table.insert(r, t[idx])
		table.remove(t, idx)
	end
	
	self.numText:setText(table.concat(r))
end

function CleanBagyzm:onInputChanged(num)
	self.inputNum:setText(num)
end

function CleanBagyzm:handleInputNumClicked(args)
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	self.placeholder:setVisible(false)
	local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
	if dlg then
		dlg:setTriggerBtn(self.inputNum)
		dlg:setMaxLength(4)
		dlg:setInputChangeCallFunc(CleanBagyzm.onInputChanged, self)
		self.inputNum:setText("")
		
		local p = self.inputNum:GetScreenPos()
		local s = self.inputNum:getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x+s.width*0.5, p.y-20, 0.5, 1)
	end
end

function CleanBagyzm:handleFreeClicked(args)
	if self.inputNum:getText() ~= self.numText:getText() then
		GetCTipsManager():AddMessageTipById(150075) --��֤�벻ƥ��
		return
	end
	local p = require("protodef.fire.pb.item.ccleanmainpack").Create()
	LuaProtocolManager.getInstance():send(p);
	CleanBagyzm.DestroyDialog()
end

return CleanBagyzm

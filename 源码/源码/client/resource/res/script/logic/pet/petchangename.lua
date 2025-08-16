require "logic.dialog"

petChangeName = {}
setmetatable(petChangeName, Dialog)
petChangeName.__index = petChangeName


local _instance
function petChangeName.getInstance()
	if not _instance then
		_instance = petChangeName:new()
		_instance:OnCreate()
	end
	return _instance
end

function petChangeName.getInstanceAndShow()
	if not _instance then
		_instance = petChangeName:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function petChangeName.getInstanceNotCreate()
	return _instance
end

function petChangeName.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function petChangeName.ToggleOpenClose()
	if not _instance then
		_instance = petChangeName:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function petChangeName.GetLayoutFileName()
	return "petgaiming_mtg.layout"
end

function petChangeName:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, petChangeName)
	return self
end

function petChangeName:setPetKey( petKey )
    self.petKey = petKey
end

function petChangeName:OnCreate( )
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.petChangeName = winMgr:getWindow("petgaiming_back")
	self.frameWindow = CEGUI.toFrameWindow(winMgr:getWindow("petgaiming_mtg/framewindow"))
	self.descText = winMgr:getWindow("petgaiming_mtg/text")
	self.inputBox = CEGUI.toEditbox(winMgr:getWindow("petgaiming_mtg/shurubg/editbox"))
    self.inputBox:subscribeEvent("KeyboardTargetWndChanged", petChangeName.HandleKeyboardTargetWndChanged, self)
	self.placeHolder = winMgr:getWindow("petgaiming_mtg/shurubg/textqing")
	self.cancelBtn = CEGUI.toPushButton(winMgr:getWindow("petgaiming_mtg/btnquxiao"))
	self.sureBtn = CEGUI.toPushButton(winMgr:getWindow("petgaiming_mtg/queren"))

	self.cancelBtn:subscribeEvent("Clicked", petChangeName.handleCancelClicked, self)
	self.sureBtn:subscribeEvent("Clicked", petChangeName.handleSureClicked, self)

    self.inputBox:SetNormalColourRect(0xff50321a);

    self.inputBox:SetShieldSpace(true)		--����������ո�
	self.inputBox:SetOnlyNumberMode(false,-1)
	self.inputBox:subscribeEvent("TextChanged", self.OnEditNumChange, self)
end

function petChangeName:handleCancelClicked(args)
    petChangeName.DestroyDialog()
	return true
end

function petChangeName:handleSureClicked(args)
    if MHSD_UTILS.ShiedText(self.inputBox:getText()) then
	    GetCTipsManager():AddMessageTipById(142260) --�����к��зǷ��ַ������������롣
	    return true
    end
    if self.petKey then
	    if self.petKey >0 then
            local p = require "protodef.fire.pb.pet.cmodpetname".new()
		    p.petkey = self.petKey
		    p.petname = self.inputBox:getText()
		    require "manager.luaprotocolmanager":send(p)
        end
    end
    petChangeName.DestroyDialog()
    return true
end

function petChangeName:OnEditNumChange()
    if string.len(self.inputBox:getText()) > 0 then
	    --self.placeHolder:setVisible(false)
	    self.sureBtn:setEnabled(true)
    else
	    --self.placeHolder:setVisible(true);
		self.sureBtn:setEnabled(false);
    end
end
function petChangeName:HandleKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.inputBox then
        self.placeHolder:setVisible(false)
    else
        if self.inputBox:getText() == "" then
            self.placeHolder:setVisible(true)
        end
    end
end
return petChangeName

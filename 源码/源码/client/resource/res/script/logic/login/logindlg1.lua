require "logic.dialog"

LoginQuickDialog = {}
setmetatable(LoginQuickDialog, Dialog)
LoginQuickDialog.__index = LoginQuickDialog

local _instance
function LoginQuickDialog.getInstance()
	if not _instance then
		_instance = LoginQuickDialog:new()
		_instance:OnCreate()
	end
	return _instance
end

function LoginQuickDialog.getInstanceAndShow()
	if not _instance then
		_instance = LoginQuickDialog:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function LoginQuickDialog.getInstanceNotCreate()
	return _instance
end

function LoginQuickDialog.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function LoginQuickDialog.ToggleOpenClose()
	if not _instance then
		_instance = LoginQuickDialog:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LoginQuickDialog.GetLayoutFileName()
	return "loginquickdialog.layout"
end

function LoginQuickDialog:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LoginQuickDialog)
	return self
end

function LoginQuickDialog:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pLogin = CEGUI.toPushButton(winMgr:getWindow("loginquick/LoginBtn1"))
    self.m_pLogin:subscribeEvent("MouseClick", LoginQuickDialog.HandleLoginMouseClicked, self)
	self.m_pLogin2 = CEGUI.toPushButton(winMgr:getWindow("loginquick/LoginBtn2"))
    self.m_pLogin2:subscribeEvent("MouseClick", LoginQuickDialog.HandleLogin2MouseClicked, self)
	self.m_pLogin0 = CEGUI.toPushButton(winMgr:getWindow("loginquick/LoginBtn0"))
    self.m_pLogin0:subscribeEvent("MouseClick", LoginQuickDialog.HandleLogin0MouseClicked, self)	

	local isShortcutLaunched = gGetLoginManager():isShortcutLaunched();
	if isShortcutLaunched then
		self:HandleLoginMouseClicked();
	end
end

function LoginQuickDialog:HandleLoginMouseClicked(args)
    if Config.CUR_3RD_PLATFORM == "winapp" then
        local dlg = require("logic.winlogindlg").getInstanceAndShow()
        dlg:setExecMode(ExecMode_Login)
    elseif  Config.CUR_3RD_PLATFORM == "app" then -- 除应用宝和易接之外的安卓SDK登陆改版
        gGetGameUIManager():sdkLogin()
    else
        --require "main"
        --LoginQuickDialog.DestroyDialog()
        self.m_pLogin:setVisible(false)
		self.m_pLogin0:setVisible(false)
		self.m_pLogin2:setVisible(false)
        require('logic.switchaccountdialog').getInstanceAndShow()
    end
    return true
end

function LoginQuickDialog:HandleLogin2MouseClicked(args)
 IOS_MHSD_UTILS.OpenURL("http://110.42.52.77:88/reg.php")
end
function LoginQuickDialog:HandleLogin0MouseClicked(args)
 IOS_MHSD_UTILS.OpenURL("https://docs.qq.com/doc/DUldkb2tEcEx3aWxm")
end
return LoginQuickDialog

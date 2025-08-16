require "logic.dialog"
require "logic.selectserverentry"
require "utils.commonutil"
--require "logic.logintipdlg"
debugrequire "logic.accountlistdlg"

SwitchAccountDialog = {}
setmetatable(SwitchAccountDialog, Dialog)
SwitchAccountDialog.__index = SwitchAccountDialog


------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function SwitchAccountDialog.getInstance()

    if not _instance then
        _instance = SwitchAccountDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SwitchAccountDialog:captcha()
    local one=math.random(10,20)
    local two=math.random(1,9)
    local op=math.random(1,3)
    local str=""
    if op==1 then
        self.jieguo=one+two
        str=tostring(one).."+"..tostring(two)
    elseif op==2 then
        self.jieguo=one-two
        str=tostring(one).."-"..tostring(two)
    elseif op==3 then
        self.jieguo=one*two
        str=tostring(one).."x"..tostring(two)
  
    end
    local color={}
    for i=1, 4 do
        local rnd1=math.random(180,255)
        local rnd2=math.random(180,255)
        local rnd3=math.random(180,255)
        color[i]="ff"..string.format("%x", rnd1)..string.format("%x", rnd2)..string.format("%x", rnd3)
    end
    local textColor = "fl:"..color[1].." wr:"..color[2].." yl:"..color[3].." pr:"..color[4]
    self.mRegCaptchaImg:setProperty("TextColours", textColor)
    self.mRegCaptchaImg:setText(str.."=?")

end

function SwitchAccountDialog.getInstanceAndShow()
	print("SwitchAccountDialog show")
    if not _instance then
        _instance = SwitchAccountDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function SwitchAccountDialog.getInstanceNotCreate()
    return _instance
end

function SwitchAccountDialog.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function SwitchAccountDialog.ToggleOpenClose()
	if not _instance then 
		_instance = SwitchAccountDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function SwitchAccountDialog.GetLayoutFileName()
    return "switchaccountdialog.layout"
end

function SwitchAccountDialog:OnCreate()

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    --登陆分页
    self.loginFybtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/loginFyAN"));
    self.loginFybtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleLoginAccountBtnClick, self) 
    --注册
    self.regFybtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/regFyAN"));
    self.regFybtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleRegAccountBtnClick, self) 
    

    -- self.regFybtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/register"));
    -- self.regFybtn:subscribeEvent("SelectStateChanged", SwitchAccountDialog.HandleRegisterAccountBtnClick, self) 




	self.loginFy = winMgr:getWindow("switchaccount/logi")
	self.regFy = winMgr:getWindow("switchaccount/regi")
    self.loginFy:setVisible(true)
    self.regFy:setVisible(false)

    self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:login")
    self.regFybtn:setProperty("NormalImage", "set:logindlginfo image:reg1")


    -- get 登录输入
    self.m_Account = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/accountbox"))
    self.m_KeyEdit = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/pwdbox"))
    self.m_KeyEdit:setTextMasked(true);
    self.m_KeyEdit:setMaxTextLength(self.MAX_LENGTH_PASSWORD)
    self.m_LoginBtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/login"));
    self.m_LoginBtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleLoginBtnClick, self) 


    -- get 注册输入
    self.mRegAccount = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regAccount"))
    self.mRegPassword = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPassword"))
    self.mRegPassword:setTextMasked(true);
    self.mRegPassword:setMaxTextLength(self.MAX_LENGTH_PASSWORD)
    self.mRegPasswordAgain = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPasswordAgain"))
    self.mRegPasswordAgain:setTextMasked(true);
    self.mRegPasswordAgain:setMaxTextLength(self.MAX_LENGTH_PASSWORD)

    self.mRegCaptchaImg =winMgr:getWindow("switchaccount/captchaimg")

    self.mRegInvite = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regInvite"))
    self.mRegCaptcha = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regCaptcha"))
    self.mRegbtn = CEGUI.Window.toPushButton(winMgr:getWindow("switchaccount/regBtn"));
    self.mRegbtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleRegBtnClick, self) 
	--self.expandBtn = CEGUI.toPushButton(winMgr:getWindow("switchaccount/accountbg/expandBtn"))
	--self.accountBg = winMgr:getWindow("switchaccount/accountbg")
    self.refreshbtn=CEGUI.toPushButton(winMgr:getWindow("switchaccount/regi/refresh"))
    self.refreshbtn:subscribeEvent("Clicked", SwitchAccountDialog.captcha, self) 
    -- subscribe event
	self.mRegAccount:SetNormalColourRect(0xff696969)
	self.mRegPassword:SetNormalColourRect(0xffff0000)
	self.mRegPasswordAgain:SetNormalColourRect(0xffff0000)
	self.mRegInvite:SetNormalColourRect(0xff00FF00)
	self.mRegCaptcha:SetNormalColourRect(0xffff0000)

    _instance.jieguo=0
	-- self.expandBtn:subscribeEvent("Clicked", SwitchAccountDialog.HandleExpandBtnClick, self)
    

	--self.m_Account:activate()
    self:captcha()
    --gGetGameUIManager():showGameCaptchaView()
	self:InitAccountList()
end

 

------------------- private: -----------------------------------

function SwitchAccountDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SwitchAccountDialog)

    self.MAX_LENGTH_PASSWORD = 16

    return self
end

function SwitchAccountDialog:InitAccountList()

	local strLastAccount = gGetLoginManager():GetAccount()
	--strLastAccount = strLastAccount:sub(1, -14)
    self.m_Account:setText(strLastAccount)
	self.m_Account:SetNormalColourRect(0xff000000)
	self.m_Account:setCaratIndex(#strLastAccount)
    
    local strLastPassword = gGetLoginManager():GetPassword()
    self.m_KeyEdit:setText(strLastPassword)
	self.m_KeyEdit:SetNormalColourRect(0xff000000)
    
    return true

end

--登录失败
function SwitchAccountDialog:MessageTip1()
   -- GetCTipsManager():AddMessageTipById(201071)
    GetCTipsManager():AddMessageTipById(144784)
        return true
end
--登录成功
function SwitchAccountDialog:MessageTip2()
    GetCTipsManager():AddMessageTipById(201071)
    return true
end
--注册失败
function SwitchAccountDialog:MessageTip3()
    GetCTipsManager():AddMessageTipById(201071)
    return true
end
--注册失败
function SwitchAccountDialog:MessageTip4()
    GetCTipsManager():AddMessageTipById(201071)
    return true
end


--登陆验证提示
function SwitchAccountDialog:ReturnMessageTip(msg)
    GetCTipsManager():AddMessageTipByMsg(msg)
    return true
end


function SwitchAccountDialog:HandleRegBtnClick(args)

    -- self.mRegAccount = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regAccount"))
    -- self.mRegPassword = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPassword"))
    -- self.mRegPasswordAgain = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regPasswordAgain"))
    -- self.mRegInvite = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regInvite"))
    -- self.mRegCaptcha = CEGUI.Window.toEditbox(winMgr:getWindow("switchaccount/regCaptcha"))


    local account = self.mRegAccount:getText()
    local password = self.mRegPassword:getText()
    local passwordagain = self.mRegPasswordAgain:getText()
    local invite = self.mRegInvite:getText()
    local captcha = self.mRegCaptcha:getText()

    if account == "" then
        GetCTipsManager():AddMessageTipById(198201)
        return true
    end
	print(account)
	if password == "" then
        GetCTipsManager():AddMessageTipById(191035)
        return true
    end
	print(password)
	if passwordagain == "" then
        GetCTipsManager():AddMessageTipById(198202)
        return true
    end
	print(passwordagain)
	if password ~= passwordagain then
        GetCTipsManager():AddMessageTipById(191025)
        return true
    end
	if invite == "" then
        GetCTipsManager():AddMessageTipById(198203)
        return true
    end
 
	if captcha == "" then
        GetCTipsManager():AddMessageTipById(198204)
        return true
    end
	print(captcha)
    print(self.jieguo)
    if tonumber(captcha)~=tonumber(self.jieguo) then
        self:ReturnMessageTip("验证码不正确") 
        return true
    end
    gGetLoginManager():RegisterAccount(account,password,invite,captcha)

	-- -- print(key)
    -- -- local host = gGetLoginManager():GetHost()
	-- -- print(host)
    -- -- local port = gGetLoginManager():GetPort()
	-- -- print(port)
    
    -- --gGetLoginManager():SetAccountInfo(account..",020000000000")
    -- gGetLoginManager():SetAccountInfo(account)
    -- gGetLoginManager():SetPassword(key)
	
	-- SetServerIniInfo("Account", "LastAccount", account)
	-- SetServerIniInfo("Password", "LastPassword", key)

    -- GetCTipsManager():AddMessageTipById(144784)
    --gGetGameUIManager():LoginAccount(account,key)

	 --self.DestroyDialog()
	-- SelectServerEntry.getInstanceAndShow()
end
 
function SwitchAccountDialog:HandleLoginBtnClick(args)
    self:LoginGame()
    return true
end

function SwitchAccountDialog:HandleLoginAccountBtnClick(args)
    self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:login")
    self.regFybtn:setProperty("NormalImage", "set:logindlginfo image:reg1")
    self.loginFy:setVisible(true)
    self.regFy:setVisible(false)
end

function SwitchAccountDialog:HandleRegAccountBtnClick(args)
    self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:login1")
    self.regFybtn:setProperty("NormalImage", "set:logindlginfo image:reg")
    self.regFy:setVisible(true)
    self.loginFy:setVisible(false)
end
function SwitchAccountDialog:HandleReturnBtnClick()
    print("login page info")
    --print(self.loginFybtnStatus)
    if self.loginFybtnStatus == true then 
		self.loginFybtn:setProperty("HoverImage", "set:logindlginfo image:loginbtn")
	    self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:zhuce")
	    self.loginFybtn:setProperty("PushedImage", "set:logindlginfo image:zhuce")
        self.loginFybtnStatus = false
        self.loginFy:setVisible(true)
        self.regFy:setVisible(false)
    else
		self.loginFybtn:setProperty("HoverImage", "set:logindlginfo image:zhuce")
	    self.loginFybtn:setProperty("NormalImage", "set:logindlginfo image:loginbtn")
	    self.loginFybtn:setProperty("PushedImage", "set:logindlginfo image:loginbtn")
        self.loginFybtnStatus = true
        self.loginFy:setVisible(false)
        self.regFy:setVisible(true)
    end
end
-- function SwitchAccountDialog:HandleRegisterAccountBtnClick(args)
   
--     print("reg page info")
--     self.loginFy:setVisible(false)
--     self.regFy:setVisible(true)
-- end

-- function SwitchAccountDialog:HandleKeyEditActivate(args)
--     return true
-- end

-- function SwitchAccountDialog:HandleKeyEditDeactivate(args)
--     return true
-- end

-- function SwitchAccountDialog:HandleExpandBtnClick(args)
-- 	local dlg = AccountListDlg.toggleShowHide(self.accountBg)
-- 	if dlg then
-- 		dlg:setTriggerBtn(CEGUI.toWindowEventArgs(args).window)
-- 		dlg:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, self.accountBg:getPixelSize().height+1)))
-- 	end
-- end


function SwitchAccountDialog:RegGame()

    local account = self.m_Account1:getText()
    
    if account == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

	print(account)
    local key = self.m_KeyEdit1:getText()
	if key == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

	-- print(key)
    -- local host = gGetLoginManager():GetHost()
	-- print(host)
    -- local port = gGetLoginManager():GetPort()
	-- print(port)
    
    --gGetLoginManager():SetAccountInfo(account..",020000000000")
    gGetLoginManager():SetAccountInfo(account)
    gGetLoginManager():SetPassword(key)
	
	SetServerIniInfo("Account", "LastAccount", account)
	SetServerIniInfo("Password", "LastPassword", key)

    gGetLoginManager():LoginAccount(account,key)

	 --self.DestroyDialog()
	 --SelectServerEntry.getInstanceAndShow()
	-- if  Config.CUR_3RD_PLATFORM == "app" then
	-- 	gGetGameUIManager():sdkLogin()
	-- end
    -- if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
    --     if gGetLoginManager():isFirstEnter() then
    --         windowsexplain.getInstanceAndShow()
    --     end
    -- end
--	if LoginTipDlg.getInstance() then
--		LoginTipDlg.DestroyDialog()
--	end
--	LoginTipDlg.getInstanceAndShow()

end

function SwitchAccountDialog:LoginGame()

    local account = self.m_Account:getText()
    
    if account == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

	print(account)
    local key = self.m_KeyEdit:getText()
	if key == "" then
        GetCTipsManager():AddMessageTipById(144784)
        return true
    end

	-- print(key)
    -- local host = gGetLoginManager():GetHost()
	-- print(host)
    -- local port = gGetLoginManager():GetPort()
	-- print(port)
    
    --gGetLoginManager():SetAccountInfo(account..",020000000000")
    gGetLoginManager():SetAccountInfo(account)
    gGetLoginManager():SetPassword(key)
	
	SetServerIniInfo("Account", "LastAccount", account)
	SetServerIniInfo("Password", "LastPassword", key)

    gGetLoginManager():LoginAccount(account,key)

	 --self.DestroyDialog()
	 --SelectServerEntry.getInstanceAndShow()
	-- if  Config.CUR_3RD_PLATFORM == "app" then
	-- 	gGetGameUIManager():sdkLogin()
	-- end
    -- if DeviceInfo:sGetDeviceType()==4 then --WIN7_32
    --     if gGetLoginManager():isFirstEnter() then
    --         windowsexplain.getInstanceAndShow()
    --     end
    -- end
--	if LoginTipDlg.getInstance() then
--		LoginTipDlg.DestroyDialog()
--	end
--	LoginTipDlg.getInstanceAndShow()

end

return SwitchAccountDialog

require "logic.dialog"

HornDlg = { }
setmetatable(HornDlg, Dialog)
HornDlg.__index = HornDlg

local _instance
function HornDlg.getInstance()
    if not _instance then
        _instance = HornDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function HornDlg.getInstanceAndShow(parent)
    if not _instance then
        _instance = HornDlg:new()
        _instance:OnCreate(parent)
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function HornDlg.getInstanceNotCreate()
    return _instance
end

function HornDlg.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function HornDlg.ToggleOpenClose()
    if not _instance then
        _instance = HornDlg:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function HornDlg.GetLayoutFileName()
    return "horndialog.layout"
end

function HornDlg:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, HornDlg)
    return self
end

function HornDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    --gonghuixiangqing/jiemian
    -- 关闭按钮
    self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("gonghuixiangqing/jiemian/guanbi"))
    -- 喊话内容
    self.m_text = CEGUI.toRichEditbox(winMgr:getWindow("gonghuixiangqing/jiemian/xuanyan/wenben"))
    self.m_text:setMaxTextLength(100)
    self.m_text:SetForceHideVerscroll(false)
    self.m_text:subscribeEvent("KeyboardTargetWndChanged", HornDlg.HandleIdeaKeyboardTargetWndChanged, self)
    self.m_tip = winMgr:getWindow("gonghuixiangqing/jiemian/xuanyan/tishi")
    self.m_tip:setVisible(true)
    -- 发送按钮
    self.m_sendBtn = CEGUI.toPushButton(winMgr:getWindow("gonghuixiangqing/jiemian/lianxihuizhang"))

    self.closeBtn:subscribeEvent("Clicked", HornDlg.OnClickedCloseBtn, self)
    self.m_sendBtn:subscribeEvent("Clicked", HornDlg.OnClickedSendBtn, self)
end

function HornDlg:HandleIdeaKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.m_text then
        self.m_tip:setVisible(false)
    else
        if self.m_text:GetPureText() == "" then
            self.m_tip:setVisible(true)
        end
    end
end

-- 关闭按钮回调
function HornDlg:OnClickedCloseBtn(args)
    self:DestroyDialog()
end

-- 点击发送
function HornDlg:OnClickedSendBtn(args)
    local content = self.m_text:GetPureText()
    if string.len(content) > 100 or string.len(content) == 0 then
        GetCTipsManager():AddMessageTipById(200004)
        return
    end

    local cmd = require "protodef.fire.pb.talk.chornsend":new()
    cmd.msg = self.m_text:GetPureText()
    LuaProtocolManager.getInstance():send(cmd)

    --喊话成功
    GetCTipsManager():AddMessageTipById(162025)
    self:DestroyDialog()
end

return HornDlg

require "logic.dialog"

Familyzongzhidialog = { }
setmetatable(Familyzongzhidialog, Dialog)
Familyzongzhidialog.__index = Familyzongzhidialog

local _instance
function Familyzongzhidialog.getInstance()
    if not _instance then
        _instance = Familyzongzhidialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyzongzhidialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyzongzhidialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyzongzhidialog.getInstanceNotCreate()
    return _instance
end

function Familyzongzhidialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyzongzhidialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyzongzhidialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyzongzhidialog.GetLayoutFileName()
    return "familyzongzhidialog.layout"
end

function Familyzongzhidialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyzongzhidialog)
    return self
end

function Familyzongzhidialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- ȷ��ȡ����ť
    self.m_ZongZhiText = CEGUI.toRichEditbox(winMgr:getWindow("familyzongzhidialog/shurukuang/text"))
    self.m_ZongZhiText:setMaxTextLength(50)
	self.m_ZongZhiText:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.m_ZongZhiText:getProperty("NormalTextColour")))
    self.m_CancelBtn = CEGUI.toPushButton(winMgr:getWindow("familyzongzhidialog/quxiao"))
    self.m_OKBtn = CEGUI.toPushButton(winMgr:getWindow("familyzongzhidialog/OK"))
    self.m_OKBtn:subscribeEvent("Clicked", Familyzongzhidialog.HandleOkClicked, self)
    self.m_CancelBtn:subscribeEvent("Clicked", Familyzongzhidialog.HandleCancelClicked, self)

    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familyzongzhidialog/close"))

    self.m_CloseBtnEx:subscribeEvent("Clicked", Familyzongzhidialog.OnCloseBtnEx, self)
end
-- ȷ����ť
function Familyzongzhidialog:HandleOkClicked()
    local p = require "protodef.fire.pb.clan.cchangeclanaim":new()
    p.newaim = self.m_ZongZhiText:GetPureText()
    --
    local ret = MHSD_UTILS.ShiedText(p.newaim)
    if ret then
      GetCTipsManager():AddMessageTipById(142261)
      return
    end
    local net = require "manager.luaprotocolmanager".getInstance()
    net:send(p)
    self.DestroyDialog()
end
-- ȡ����ť
function Familyzongzhidialog:HandleCancelClicked()
    self.DestroyDialog()
end
-- �����ı�
function Familyzongzhidialog:SetText(text)
    local text2 = "<T t='" .. text .. "' c='ff8c5e2a' />"
    self.m_ZongZhiText:AppendParseText(CEGUI.String(text2))
    self.m_ZongZhiText:AppendBreak()
    self.m_ZongZhiText:Refresh()
end
function Familyzongzhidialog:OnCloseBtnEx(args)
    self:DestroyDialog()
end

return Familyzongzhidialog

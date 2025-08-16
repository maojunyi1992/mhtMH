require "logic.dialog"

Familychuangjiandialog = { }
setmetatable(Familychuangjiandialog, Dialog)
Familychuangjiandialog.__index = Familychuangjiandialog

local _instance
function Familychuangjiandialog.getInstance()
    if not _instance then
        _instance = Familychuangjiandialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familychuangjiandialog.getInstanceAndShow()
    if not _instance then
        _instance = Familychuangjiandialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familychuangjiandialog.getInstanceNotCreate()
    return _instance
end

function Familychuangjiandialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            CurrencyManager.unregisterTextWidget(_instance.m_CostCreateText)
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familychuangjiandialog.ToggleOpenClose()
    if not _instance then
        _instance = Familychuangjiandialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familychuangjiandialog.GetLayoutFileName()
    return "familychuangjiandialog.layout"
end

function Familychuangjiandialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familychuangjiandialog)
    return self
end
-------------------------------------------------------------------------------------------------���д���
function Familychuangjiandialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.CancelBtn = CEGUI.toPushButton(winMgr:getWindow("familychuangjiandialog/quxiao"))
    self.CreateBtn = CEGUI.toPushButton(winMgr:getWindow("familychuangjiandialog/OK"))
    self.TexInputName = CEGUI.toRichEditbox(winMgr:getWindow("familychuangjiandialog/chuangjian/shurukuang/text"))
    self.TexInputName:subscribeEvent("KeyboardTargetWndChanged", Familychuangjiandialog.HandleNameKeyboardTargetWndChanged, self)
	self.TexInputName:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.TexInputName:getProperty("NormalTextColour")))
	self.TexInputName:setMaxTextLength(5)
    self.TexInputName:subscribeEvent("CaratMoved",  Familychuangjiandialog.HandleTextChange, self)
    self.TexInputIdea = CEGUI.toRichEditbox(winMgr:getWindow("familychuangjiandialog/zongzhi/shurukuang/text"))
    self.TexInputIdea:subscribeEvent("KeyboardTargetWndChanged", Familychuangjiandialog.HandleIdeaKeyboardTargetWndChanged, self)
    self.TexInputIdea:setMaxTextLength(150)
	self.TexInputIdea:SetColourRect(CEGUI.PropertyHelper:stringToColour(self.TexInputIdea:getProperty("NormalTextColour")))
	self.TexInputIdea:SetForceHideVerscroll(false)
    self.m_ZongZhiTip = winMgr:getWindow("familychuangjiandialog/zongzhi/shurukuang/tishi")
    self.m_ZongZhiTip:setVisible(true)
    self.m_NameTip = winMgr:getWindow("familychuangjiandialog/chuangjian/shurukuang/tishi")
    self.m_NameTip:setVisible(true)
    self.CancelBtn:subscribeEvent("Clicked", Familychuangjiandialog.CancelBtnClicked, self)
    self.CreateBtn:subscribeEvent("Clicked", Familychuangjiandialog.CreateBtnClicked, self)
    self.m_CostCreateText = winMgr:getWindow("familychuangjiandialog/feiyong/shuzi")
    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familychuangjiandialog/close"))

    self.m_CloseBtnEx:subscribeEvent("Clicked", Familychuangjiandialog.OnCloseBtnEx, self)
    -- ��ʾ���ѽ��
    self:CreateCost()
    -- �Ƿ�update
    self.m_IsUpdate = true

    self.m_pos = self.TexInputName:getCaratPos()
end
-- ��ȡ�����������ٱ�UI
function Familychuangjiandialog:CancelBtnClicked()
    -- ���ٱ�UI��ת������UI
    Familyjiarudialog.getInstanceAndShow()
    self.DestroyDialog()

end

-- ������ʹ�������
function Familychuangjiandialog:CreateBtnClicked()

    if self.m_Gou then

        local send = require "protodef.fire.pb.clan.ccreateclan":new()
        -- ������ּ
        send.clanaim = self.TexInputIdea:GetPureText()
        -- ��������
        send.clanname = self.TexInputName:GetPureText()
        LuaProtocolManager.getInstance():send(send)
        local datamanager = require "logic.faction.factiondatamanager"
        datamanager.m_IsOpenFamilyUI = 1
    else
		CurrencyManager.handleCurrencyNotEnough(self.currencyType, self.needNum)
    end
end

-- ���ô�������
function Familychuangjiandialog:CreateCost()
    self.m_Cost = GameTable.common.GetCCommonTableInstance():getRecorder(161).value --�����������,���
    self.currencyType = fire.pb.game.MoneyType.MoneyType_GoldCoin

    if IsPointCardServer() then
        self.currencyType = fire.pb.game.MoneyType.MoneyType_HearthStone
        self.m_Cost = BeanConfigManager.getInstance():GetTableByName("fushi.ccommondaypay"):getRecorder(5).value --�㿨��������������100��ʯ
        local icon = CEGUI.WindowManager:getSingleton():getWindow("familychuangjiandialog/feiyong/icon")
        icon:setProperty("Image", "set:lifeskillui image:fushi")
    end

    local text = require("logic.workshop.workshopmanager").getNumStrWithThousand(tonumber(self.m_Cost))
    self.m_CostCreateText:setText(text)
    -- �ж���ɫ ������Ϊ��ɫ
    local money = CurrencyManager.getOwnCurrencyMount(self.currencyType)
    if money < tonumber(self.m_Cost) then
		self.m_CostCreateText:setProperty("BorderColour", "ff8c5e2a")
        self.m_Gou = false
        self.needNum = tonumber(self.m_Cost) - money
    else
        self.m_CostCreateText:setProperty("BorderColour", "ff8c5e2a")
        self.m_Gou = true
    end
end
function Familychuangjiandialog:HandleNameKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.TexInputName then
        self.m_NameTip:setVisible(false)
    else
        if self.TexInputName:GetPureText() == "" then
            self.m_NameTip:setVisible(true)
        end
    end
end

function Familychuangjiandialog:HandleIdeaKeyboardTargetWndChanged(args)
    local wnd = CEGUI.toWindowEventArgs(args).window
    if wnd == self.TexInputIdea then
        self.m_ZongZhiTip:setVisible(false)
    else
        if self.TexInputIdea:GetPureText() == "" then
            self.m_ZongZhiTip:setVisible(true)
        end
    end
end
function Familychuangjiandialog:update(dt)
    if not self.m_IsUpdate then
        return
    end
--    local text1 = self.TexInputName:GetPureText()
--    local text2 = self.TexInputIdea:GetPureText()
--    self.m_NameTip:setVisible((text1 == "" and self.TexInputName:hasInputFocus()))
--    self.m_ZongZhiTip:setVisible((text2 == "" and self.TexInputIdea:hasInputFocus()))

    -- ��ʾ��ɫˢ��
    local money = CurrencyManager.getOwnCurrencyMount(self.currencyType)
    if money < tonumber(self.m_Cost) then
		self.m_CostCreateText:setProperty("BorderColour", "ff8c5e2a")
        self.m_Gou = false
        self.needNum = tonumber(self.m_Cost) - money
    else
        self.m_CostCreateText:setProperty("BorderColour", "ff8c5e2a")
        self.m_Gou = true
    end
end

function Familychuangjiandialog:OnCloseBtnEx(args)
    self.DestroyDialog()
end

function Familychuangjiandialog:HandleTextChange(args)
    local str = self.TexInputName:GetPureText()
    local splited = false
    str, splited = SliptStrByCharCount(str, 10) -- 10����10�����ֽ��ַ���5��˫�ֽں���
    if splited then
        self.TexInputName:Clear()
        self.TexInputName:AppendText(CEGUI.String(str))
        if self.m_pos then
            self.TexInputName:setCaratPos(self.m_pos)
        end
        self.TexInputName:Refresh()  
    end
    self.m_pos = self.TexInputName:getCaratPos()
end

return Familychuangjiandialog

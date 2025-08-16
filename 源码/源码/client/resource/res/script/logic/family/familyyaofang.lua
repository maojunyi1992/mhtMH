require "logic.dialog"
require "logic.family.familyyaofangcell"

Familyyaofang = { }
setmetatable(Familyyaofang, Dialog)
Familyyaofang.__index = Familyyaofang

local _instance
function Familyyaofang.getInstance()
    if not _instance then
        _instance = Familyyaofang:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyyaofang.getInstanceAndShow()
    if not _instance then
        _instance = Familyyaofang:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyyaofang.getInstanceNotCreate()
    return _instance
end

function Familyyaofang.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            -- �ر�tableview
            if _instance.m_Entrys then
                _instance.m_Entrys:destroyCells()
            end
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyyaofang.ToggleOpenClose()
    if not _instance then
        _instance = Familyyaofang:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyyaofang.GetLayoutFileName()
    return "familyyaofang.layout"
end

function Familyyaofang:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyyaofang)
    return self
end

function Familyyaofang:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_EntrysGroup = winMgr:getWindow("familyyaofang_mtg/textbg3/list2")
    self.buyView = winMgr:getWindow("familyyaofang_mtg/buyview")
    self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("familyyaofang_mtg/btnjianhao"))
    self.buyNumText = winMgr:getWindow("familyyaofang_mtg/shurukuang/buynum")
    self.addBtn = CEGUI.toPushButton(winMgr:getWindow("familyyaofang_mtg/jiahao"))
    self.priceCharText = winMgr:getWindow("familyyaofang_mtg/textxuyao")
    self.priceYinBiText = winMgr:getWindow("familyyaofang_mtg/textzong")
    self.currencyIcon1 = winMgr:getWindow("familyyaofang_mtg/textzong/yinbi1")
    self.ownYinBiText = winMgr:getWindow("familyyaofang_mtg/textdan")
    self.currencyIcon2 = winMgr:getWindow("familyyaofang_mtg/textzong/yinbi2")
    self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("familyyaofang_mtg/btngoumai"))
    self.sellView = winMgr:getWindow("familyyaofang_mtg/textbg3")
    self.priceCharText = winMgr:getWindow("familyyaofang_mtg/textgongxian")
    self.priceJinBiText = winMgr:getWindow("familyyaofang_mtg/gongxian")
    self.currencyIcon1 = winMgr:getWindow("familyyaofang_mtg/gongxian/icon")
    self.ownJinBiText = winMgr:getWindow("familyyaofang_mtg/yongyougongxian")
    self.currencyIcon2 = winMgr:getWindow("familyyaofang_mtg/yongyougongxian/icon")
    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familyyaofang_mtg/close"))
    self.m_BuildLevelText = winMgr:getWindow("familyyaofang_mtg/tishi/lev")
    self.m_CheckBox1 = CEGUI.toCheckbox(winMgr:getWindow("familyyaofang_mtg/zhengchang"))
    self.m_CheckBox2 = CEGUI.toCheckbox(winMgr:getWindow("familyyaofang_mtg/shuangbei"))
    self.m_CheckBox3 = CEGUI.toCheckbox(winMgr:getWindow("familyyaofang_mtg/sanbei"))
    self.m_CheckBox1:setID(0)
    self.m_CheckBox2:setID(1)
    self.m_CheckBox3:setID(2)
    self.buyBtn:subscribeEvent("Clicked", Familyyaofang.handleBuyClicked, self)
    self.m_CloseBtnEx:subscribeEvent("Clicked", Familyyaofang.OnCloseBtnEx, self)
 
    -- �Ӽ��Żص�
    self.minusBtn:subscribeEvent("Clicked", Familyyaofang.handleminusBtnClicked, self)
    self.addBtn:subscribeEvent("Clicked", Familyyaofang.handleaddBtnClicked, self)
    self.m_CheckBox1:subscribeEvent("MouseButtonDown", Familyyaofang.handleadCheckClicked, self)
    self.m_CheckBox2:subscribeEvent("MouseButtonDown", Familyyaofang.handleadCheckClicked, self)
    self.m_CheckBox3:subscribeEvent("MouseButtonDown", Familyyaofang.handleadCheckClicked, self)
    self.m_CheckBox1:subscribeEvent("MouseButtonUp", Familyyaofang.handleadCheckUp, self)
    self.m_CheckBox2:subscribeEvent("MouseButtonUp", Familyyaofang.handleadCheckUp, self)
    self.m_CheckBox3:subscribeEvent("MouseButtonUp", Familyyaofang.handleadCheckUp, self)
    self.m_YaoFangTips = CEGUI.toPushButton(winMgr:getWindow("familyyaofang_mtg/tishi/shuoming"))
    self.m_YaoFangTips:subscribeEvent("Clicked", Familyyaofang.onClickedYaoFangTips, self)
    -- ����
    local send = require "protodef.fire.pb.clan.copenclanmedic":new()
    require "manager.luaprotocolmanager":send(send)

    self.m_CurBuyNumber = 1
    -- ��ǰѡ������
    self.m_CurRemainNumber = 0
    -- ��ǰʣ��ҩƷ����
    self.m_SendID = 0
    -- ��ǰѡ��ID
    self.m_CurYinBi = 0
    -- ��ǰ���һ���
    self.m_CurBangGong = 0
    -- ��ǰ�ﹱ����
    self.buyBtn:setEnabled(self.m_CurReMainNumber ~= 0 and self.m_SendID ~= 0)
    self:RefrseshPosition()
end
function Familyyaofang:handleadCheckUp(args)
    if not self.m_FactionData then
        return
    end
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor and infor.id~=-1 then
        if infor.selectchanyao == 0 then
            self:ResetCheckBox()
            self:RefreshCheckBoxChecked()
            return
        end
    end
end
-- ���ҩ��tips
function Familyyaofang:onClickedYaoFangTips(args)
    self.tips1 = require "logic.workshop.tips1"
    local lv = self.m_FactionData.house[3]
    if not lv then
        return
    end
    local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiondrugstore"):getRecorder(lv)
    if not info then
        return
    end
    local strTitle = MHSD_UTILS.get_resstring(11319)
    local strContent = MHSD_UTILS.get_resstring(11320)
    -- �ȼ��滻
    strContent = string.gsub(strContent, "%$parameter1%$", tostring(lv))
    -- �滻ˢ������
    strContent = string.gsub(strContent, "%$parameter2%$", tostring(info.dragnummax))
    -- ˫����ҩ
    strContent = string.gsub(strContent, "%$parameter3%$", tostring(info.doublemoney / 10000))
    -- ������ҩ
    strContent = string.gsub(strContent, "%$parameter4%$", tostring(info.trimoney / 10000))
    self.tips1.getInstanceAndShow(strContent, strTitle)
end
function Familyyaofang:RefreshMoney()
    if (not self.ownYinBiText) or(not self.ownJinBiText) then
        return
    end
    -- ��ǰӵ������
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local money = roleItemManager:GetPackMoney()
    local strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(money)
    self.ownYinBiText:setText(tostring(strNeedMoney))
    -- ��ǰӵ�аﹱ
    local banggong = gGetDataManager():getContribution()
    strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(banggong)
    self.ownJinBiText:setText(tostring(strNeedMoney))
    local ColorTable =
    {
        [1] = "FFFF3333",
        -- ����
        [2] = "FFFFFFFF"-- ����
    }
    -- �����ж��Ƿ�
    if money >=(self.m_CurYinBi * self.m_CurBuyNumber) then
        self.ownYinBiText:setProperty("TextColours", ColorTable[2])
    else
        self.ownYinBiText:setProperty("TextColours", ColorTable[1])
    end

    -- �жϰﹱ
    if banggong >=(self.m_CurBangGong * self.m_CurBuyNumber) then
        self.ownJinBiText:setProperty("TextColours", ColorTable[2])
    else
        self.ownJinBiText:setProperty("TextColours", ColorTable[1])
    end
end
function Familyyaofang:RefreshCheckBoxChecked()

    if self.m_FactionData.m_FamilyChanYaoMode == 0 then
        self.m_CheckBox1:setSelected(true)
    elseif self.m_FactionData.m_FamilyChanYaoMode == 1 then
        self.m_CheckBox2:setSelected(true)
    elseif self.m_FactionData.m_FamilyChanYaoMode == 2 then
        self.m_CheckBox3:setSelected(true)
    end


end
-- ˢ��ѡ��Ȩ��
function Familyyaofang:RefrseshPosition()
    if self.m_FactionData then
        local position = self.m_FactionData.GetMyZhiWu()
        self.m_CheckBox1:setEnabled(position == 1 or position == 2)
        self.m_CheckBox2:setEnabled(position == 1 or position == 2)
        self.m_CheckBox3:setEnabled(position == 1 or position == 2)
    end
end

local SeletMyID = nil
function Familyyaofang:handleadCheckClicked(args)
    if not self.m_FactionData then
        return
    end
    local infor = self.m_FactionData.GetMyZhiWuInfor()
    if infor.id~=-1 then
        if infor.selectchanyao == 0 then
            self:ResetCheckBox()
            self:RefreshCheckBoxChecked()
            GetCTipsManager():AddMessageTipById(150127)
            return
        end
    end


    local btn = CEGUI.toWindowEventArgs(args).window
    local id = btn:getID()
    SeletMyID = id
    local lv = self.m_FactionData.house[3]
    local factionlevel = self.m_FactionData.factionlevel
    if not lv then
        return
    end
    if not factionlevel then
        return
    end
    lv = math.min(lv,factionlevel)
    Info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiondrugstore"):getRecorder(lv)
    if not Info then
        return
    end
    -- �����Ի���
    local text = MHSD_UTILS.get_resstring(11334)
    text = string.gsub(text, "%$parameter1%$", tostring(id + 1))
    local temp = 0
    if id + 1 == 1 then
        text = MHSD_UTILS.get_resstring(11340)
    elseif id + 1 == 2 then
        temp = Info.doublemoney/10000
        text = string.gsub(text, "%$parameter2%$", tostring(temp))
    elseif id + 1 == 3  then
        temp = Info.trimoney/10000
        text = string.gsub(text, "%$parameter2%$", tostring(temp))
    end
    gGetMessageManager():AddConfirmBox(eConfirmNormal, text, self.ClickYes, self, MessageManager.HandleDefaultCancelEvent, MessageManager)
end
function Familyyaofang:ClickYes(args)
    -- ѡ�񼸱���ҩ
    local send = require "protodef.fire.pb.clan.crequestselecttype":new()
    send.selecttype = SeletMyID
    self.m_FactionData.m_FamilyChanYaoMode = SeletMyID
    -- ѡ���ҩ
    require "manager.luaprotocolmanager":send(send)
    SeletMyID = nil
    gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)
end
function Familyyaofang:ResetCheckBox()
    self.m_CheckBox1:setSelected(false)
    self.m_CheckBox2:setSelected(false)
    self.m_CheckBox3:setSelected(false)
end
-- ˢ����Ϣ
function Familyyaofang:RefreshInfor()
    -- ��ǰ��������
    self.buyNumText:setText(tostring(self.m_CurBuyNumber))
    -- ˢ�µ�ǰ�����ȼ�
    local level = self.m_FactionData.house[3]
    self.m_BuildLevelText:setText(tostring(level))
end
-- �Ӽ��Ŵ���
function Familyyaofang:handleminusBtnClicked(args)
    GetCTipsManager():AddMessageTipById(160353)
    return
end

function Familyyaofang:handleaddBtnClicked(args)
    GetCTipsManager():AddMessageTipById(160353)
    return
end
-- ˢ���б�
function Familyyaofang:ReFreshFamilyYaoFangListView()
    if not self.m_FactionData then
        return
    end
    if not self.m_FactionData.m_FamilyYaoFangList then
        return
    end
    local len = #(self.m_FactionData.m_FamilyYaoFangList)
    -- �������
    if self.m_Entrys then

    else
        local s = self.m_EntrysGroup:getPixelSize()
        self.m_Entrys = TableView.create(self.m_EntrysGroup)

        self.m_Entrys:setViewSize(696, 600)
        self.m_Entrys:setPosition(0, 0)
        self.m_Entrys:setDataSourceFunc(self, Familyyaofang.tableViewGetCellAtIndex)
    end
    self.m_Entrys:setColumCount(1)
    self.m_Entrys:setCellCountAndSize(len, 310, 100)
    self.m_Entrys:reloadData()
end

function Familyyaofang:tableViewGetCellAtIndex(tableView, idx, cell)

    idx = idx + 1
    if not cell then
        cell = Familyyaofangcell.CreateNewDlg(tableView.container, idx)
        cell.window:subscribeEvent("MouseButtonUp", Familyyaofang.HandleCellClicked, self)
    end
    cell:SetInfor(idx)
    if cell then
        cell.window:setSelected(cell.m_ID == self.m_SendID)
    end
    return cell
end
-- ���ҩ��cell
function Familyyaofang:HandleCellClicked(args)
    if not self.m_FactionData then
        return
    end
    if not self.m_FactionData.m_FamilyYaoFangList then
        return
    end
    if not self.m_Entrys then
        return
    end

    local btn = CEGUI.toWindowEventArgs(args).window
    local id = btn:getID()
    local temp = self.m_Entrys.visibleCells[id - 1]
    if temp then
        self.m_CurYinBi = temp.m_YinBi
        self.m_CurBangGong = temp.m_BangGong
        self.m_CurReMainNumber = temp.m_Number
        local strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.m_CurYinBi * self.m_CurBuyNumber)
        self.priceYinBiText:setText(tostring(strNeedMoney))
        strNeedMoney = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.m_CurBangGong * self.m_CurBuyNumber)
        self.priceJinBiText:setText(tostring(strNeedMoney))
        self.m_SendID = temp.m_ID
        self.buyBtn:setEnabled(self.m_CurReMainNumber ~= 0 and self.m_SendID ~= 0)
    end
end
-- �������
function Familyyaofang:handleBuyClicked(args)
    local send = require "protodef.fire.pb.clan.cbuymedic":new()
    send.itemid = self.m_SendID
    -- ��ǰѡ��ID
    send.itemnum = self.m_CurBuyNumber
    -- ��ǰѡ������
    require "manager.luaprotocolmanager":send(send)
end

function Familyyaofang:OnCloseBtnEx(args)
    self:DestroyDialog()
end
-- ����ҩ������
function Familyyaofang:update(delta)
    self:RefreshMoney()
end
return Familyyaofang

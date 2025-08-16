-- ���빫�ᣨ�����б�����

require "logic.dialog"
debugrequire "logic.family.familyjiarudiacell"
debugrequire "logic.family.familychuangjiandialog"

Familyjiarudialog = { }
setmetatable(Familyjiarudialog, Dialog)
Familyjiarudialog.__index = Familyjiarudialog

local _instance

function Familyjiarudialog.getInstance()
    if not _instance then
        _instance = Familyjiarudialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyjiarudialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyjiarudialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyjiarudialog.getInstanceNotCreate()
    return _instance
end

function Familyjiarudialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyjiarudialog)
    return self
end

function Familyjiarudialog.DestroyDialog()

    if _instance then
        if not _instance.m_bCloseIsHide then
            -- �ر�tableview
            if _instance.m_Entrys then
                _instance.m_Entrys:destroyCells()
            end
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyjiarudialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyjiarudialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyjiarudialog.GetLayoutFileName()
    return "familyjiarudialog.layout"
end

function Familyjiarudialog:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_CurPage = 1
    self.m_FactionData = { }

    -- ���빫�����
    self.m_JaiRuText = winMgr:getWindow("familyjiarudialog/jiarugonghui")

    -- �����б����
    self.m_GongHuiText = winMgr:getWindow("familyjiarudialog/gonghuiliebiao")

    -- �Ƿ���������
    self.Searched = false
    -- ����ȡ����ť
    self.m_CancelInputBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/shurukuang/InputtextBox/X"))
    self.m_CancelInputBtn:setVisible(false) -- Ĭ�ϲ���ʾȡ����ť
    self.m_CancelInputBtn:subscribeEvent("Clicked", Familyjiarudialog.OnCancelInputBtnHandler, self)
    -- �������ᰴť
    self.m_SearchBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/chazhao"))
    self.m_SearchBtn:subscribeEvent("Clicked", Familyjiarudialog.OnClickSearchBtnHandler, self)
    -- �����ı��ؼ�
    self.m_IDNumberInputText = CEGUI.toEditbox(winMgr:getWindow("familyjiarudialog/shurukuang/InputtextBox"))
    self.m_IDNumberInputText:subscribeEvent("MouseButtonDown", Familyjiarudialog.IDNumberInputTextClicked, self)
    -- ID��ʾ
    self.m_IDTip = winMgr:getWindow("familyjiarudialog/shurukuang/InputtextBox/tishi")
    -- δ������������������ʾ���������
    self.m_LingSui = winMgr:getWindow("familyjiarudialog/liebiao/yindaojieguo")

--    -- ����ѧͽTips��ť
--    self.m_BtnXueTuTips = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/xuetushuoming/text"))
--    self.m_BtnXueTuTips:subscribeEvent("Clicked", Familyjiarudialog.BtnXueTuTipsClicked, self)

    -- ������ּText
    self.m_ZongZhiText = CEGUI.toRichEditbox(winMgr:getWindow("familyjiarudialog/gonghuixinxi/zongzhi"))
	self.m_ZongZhiText:SetForceHideVerscroll(true)
    self.m_OldNameText = winMgr:getWindow("familyjiarudialog/gonghuixinxi/gaiming")

--    -- һ�����밴ť
--    self.OneKeyApplyJoinBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/yijianshenqing"))
--    self.OneKeyApplyJoinBtn:subscribeEvent("MouseClick", Familyjiarudialog.OneKeyApplyJoinBtnClicked, self)

    -- ������밴ť
    self.ApplyJoinBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/shenqingjiaru"))
    self.ApplyJoinBtn:subscribeEvent("Clicked", Familyjiarudialog.ApplyJoinBtnClicked, self)

    -- �������ᰴť
    self.m_BtnCreate = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/chuangjiangonghui"))
    self.m_BtnCreate:subscribeEvent("MouseClick", Familyjiarudialog.BtnCreateClicked, self)

    -- ��ϵ�᳤��ť
    self.ConnectHostBtn = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/anniu/lianxihuizhang"))
    self.ConnectHostBtn:subscribeEvent("Clicked", Familyjiarudialog.ConnectHostBtnClicked, self)

    -- �رհ�ť
    self.m_CloseBtnEx = CEGUI.toPushButton(winMgr:getWindow("familyjiarudialog/close"))
    self.m_CloseBtnEx:subscribeEvent("Clicked", Familyjiarudialog.OnCloseBtnEx, self)

    -- ������ĿListView������
    self.m_EntryCollection = CEGUI.toMultiColumnList(winMgr:getWindow("familyjiarudialog/liebiao"))

    -- ��չ����б���Ϣ
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        datamanager.m_FamilyList.m_Curpage = 0
        datamanager.m_FamilyList.m_FactionList = { }
    end

    -- ����һ�����µĹ����б���Ϣ
    local p = require "protodef.fire.pb.clan.copenclanlist":new()
    p.currpage = 1
    require "manager.luaprotocolmanager".getInstance():send(p)

    -- ��ʼ����ǰѡ�й����б��е���Ŀ����
    self.m_CurSelectEntryIndex = 0
    self.ApplyJoinBtn:setEnabled(false)
    self.ConnectHostBtn:setEnabled(false)
    self:RefreshMode()
    SetPositionScreenCenter(self:GetWindow())
end

-- ��ǰ��ҳ
function Familyjiarudialog:HandlePrePage(args)
    self.m_CurPage = self.m_CurPage - 1
    if self.m_CurPage < 1 then
        self.m_CurPage = 1
    end
end

-- ���ҳ
function Familyjiarudialog:HandleNextPage(args)
    self.m_CurPage = self.m_CurPage + 1
    if self.m_CurPage > self.m_FactionData.m_FamilyList.m_Curpage then
        local p = require "protodef.fire.pb.clan.copenclanlist":new()
        p.currpage = self.m_CurPage
        require "manager.luaprotocolmanager".getInstance():send(p)
    end

end

-- ����رհ�ť
function Familyjiarudialog:OnCloseBtnEx(args)
    self.DestroyDialog()
end

-- ˢ����ʾģʽ
function Familyjiarudialog:RefreshMode()
    local datamanager = require "logic.faction.factiondatamanager"
    if datamanager then
        self.m_GongHuiText:setVisible(datamanager:IsHasFaction())
        self.m_JaiRuText:setVisible(not datamanager:IsHasFaction())
--        self.OneKeyApplyJoinBtn:setVisible(not datamanager:IsHasFaction()) -- һ�����밴ť
        self.ApplyJoinBtn:setVisible(not datamanager:IsHasFaction())
        self.m_BtnCreate:setVisible(not datamanager:IsHasFaction())
    end
end

-- ˢ������״̬
function Familyjiarudialog:RefreshApplyState()
    if self.m_Entrys then
        for k, v in pairs(self.m_Entrys.visibleCells) do
            if v then
                v:RefreshApplyState()
            end
        end
    end

end

-- �������ȡ����ť
function Familyjiarudialog:OnCancelInputBtnHandler(args)
    -- ɾ������
    self.m_IDNumberInputText:setText("")
    -- ����ʾȡ������x��ť
    self.m_CancelInputBtn:setVisible(false)
    -- ��ԭˢ���б�
    local datamanager = require "logic.faction.factiondatamanager"
    local len = #(datamanager.m_FamilyList.m_FactionList)
    if self.Searched then
        if datamanager.m_SearchIsNull == false then
            table.remove(datamanager.m_FamilyList.m_FactionList, 1)
        end
        self.Searched = false
    end
    self.m_FactionData.m_FamilyList.m_FactionList = datamanager.m_FamilyList.m_FactionList
    self:ReFreshFamilyListView()
end

-- ���������ť
function Familyjiarudialog:OnClickSearchBtnHandler(args)
    if self.m_CancelInputBtn:isVisible() then
        return
    end
    local text = self.m_IDNumberInputText:getText()
    if text ~= "" then
        local id = tonumber(text)

        -- �������������ID
        local p = require "protodef.fire.pb.clan.csearchclan":new()
        p.clanid = id
        require "manager.luaprotocolmanager":send(p)

        -- ��ʾȡ����ť
        self.m_CancelInputBtn:setVisible(true)
        self.Searched = false
    else
        local str = MHSD_UTILS.get_msgtipstring(160312)

        GetCTipsManager():AddMessageTip(str)
    end

end

-- ����������
function Familyjiarudialog:ApplyJoinBtnClicked(args)
    -- ���浱ǰ���������Ϣ
    local cell = self.m_Entrys:getCellAtIdx(self.m_CurSelectEntryIndex - 1)
    if cell then
        local id = cell.m_ID
        local send = require "protodef.fire.pb.clan.capplyclan":new()
        send.clanid = id
        LuaProtocolManager.getInstance():send(send)
        -- self.DestroyDialog()
    end

end

-- ������ҹ��������
function Familyjiarudialog:IDNumberInputTextClicked(args)
    if self.m_CancelInputBtn:isVisible() then
        return
    end
    NumKeyboardDlg.DestroyDialog()
    local dlg = NumKeyboardDlg.getInstanceAndShow()
    dlg:setMaxLength(13)
    SetPositionOffset(dlg:GetWindow(), 438, 625, 0.5, 1)
    dlg:setInputChangeCallFunc(Familyjiarudialog.onInputChanged, self)
end

-- ����ص�
function Familyjiarudialog:onInputChanged(args)
    self.m_IDNumberInputText:setText(args)
end

-- �����ϵ�᳤
function Familyjiarudialog:ConnectHostBtnClicked(args)
    -- to do 1.�����ϵ��(�᳤)
    -- 2.Ĭ��ѡ�л᳤
    -- FriendDialog.getInstanceAndShow()
    local Curcell = self.m_Entrys:getCellAtIdx(self.m_CurSelectEntryIndex - 1)
    if Curcell then
        local memberid = self.m_FactionData.GetFaction(Curcell.m_ID).clanmasterid
        if not memberid then
            return
        end
        if gGetFriendsManager() then
            gGetFriendsManager():RequestSetChatRoleID(memberid)
        end
        Family.DestroyDialog(true)
        self.DestroyDialog()
    end

end

-- ����������ᰴť
function Familyjiarudialog:BtnCreateClicked(args)
    Familychuangjiandialog.getInstanceAndShow()
end

-- �������пؼ�ѡ��״̬
function Familyjiarudialog:ResetSelect()
    for _, v in pairs(self.m_Entrys.visibleCells) do
        v.btn:setSelected(false)
    end
end

-- ˢ�¹����б�
function Familyjiarudialog:ReFreshFamilyListView()
    if self.m_FactionData then
        if not self.m_FactionData.m_FamilyList then
            return
        end
        if not self.m_FactionData.m_FamilyList.m_FactionList then
            return
        end
        local len = #(self.m_FactionData.m_FamilyList.m_FactionList)
        if self.m_Entrys then
        else
            local s = self.m_EntryCollection:getPixelSize()
            self.m_Entrys = TableView.create(self.m_EntryCollection)
            self.m_Entrys:setViewSize(s.width - 0, 410)
            self.m_Entrys:setPosition(0, 48)
            self.m_Entrys:setDataSourceFunc(self, Familyjiarudialog.tableViewGetCellAtIndex)
            self.m_Entrys.scroll:subscribeEvent("NextPage", Familyjiarudialog.HandleNextPage, self)
            self.m_Entrys.scroll:subscribeEvent("PrePage", Familyjiarudialog.HandlePrePage, self)

        end
        if self.m_CancelInputBtn:isVisible() and self.m_FactionData.m_LastSearchResult.clanid ~= 0 then
            self.m_Entrys:setCellCountAndSize(1, 626, 50)
        elseif self.m_CancelInputBtn:isVisible() and self.m_FactionData.m_LastSearchResult.clanid == 0 then
            self.m_Entrys:setCellCountAndSize(0, 626, 50)
        else
            self.m_Entrys:setCellCountAndSize(len, 626, 50)
        end
        self.m_Entrys:reloadData()
    end

end

-- ����tableview�е�cell��ˢ�£���tableview������ˢ��ʱ�ص�
function Familyjiarudialog:tableViewGetCellAtIndex(tableView, idx, cell)
    idx = idx + 1
    if not cell then
        if self.m_FactionData then
            cell = Familyjiarudiacell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
            cell.btn:setGroupID(20)
        end
    end
    if idx % 2 == 1 then
        cell.btn:SetStateImageExtendID(1)
    else
        cell.btn:SetStateImageExtendID(0)
    end
    cell.btn:setID(idx)
    cell:SetInfor(self.m_FactionData.m_FamilyList.m_FactionList[idx])
    cell.m_SelectBtn:setID(cell.m_ID)
    cell.btn:subscribeEvent("MouseButtonUp", Familyjiarudialog.HandleFamilyEntryCellClicked, self)
    cell.btn:subscribeEvent("MouseButtonDown", Familyjiarudialog.HandleFamilyEntryCellClickedDown, self)
    cell.m_SelectBtn:subscribeEvent("Clicked", Familyjiarudialog.HandleCancel, self)
    return cell
end


---------------------------------------------------------------

local cancelID = 0
local confirmtype = 0

-- ȡ��ȷ�ϰ�ť�Ļص�
local function acceptCancel()
    gGetMessageManager():CloseConfirmBox(confirmtype, false)
    if not cancelID then
        return
    end
    local p = require "protodef.fire.pb.clan.ccancelapplyclan":new()
    p.clanid = cancelID
    require "manager.luaprotocolmanager":send(p)
end

-- ���ȡ�����Ͱ�ť
function Familyjiarudialog:HandleCancel(args)
    local e = CEGUI.toWindowEventArgs(args)
    cancelID = e.window:getID()
    local temp = self.m_FactionData.GetFaction(cancelID)
    if temp then
        local text = MHSD_UTILS.get_resstring(11308)
        text = string.gsub(text, "%$parameter1%$", temp.clanname)

        confirmtype = MHSD_UTILS.addConfirmDialog(text, acceptCancel)
    end
end

---------------------------------------------------------------


---- ����ѧͽTips��ť
--function Familyjiarudialog:BtnXueTuTipsClicked(args)
--    -- to do ����
--    local tips1 = require "logic.workshop.tips1"
--    local strTitle = MHSD_UTILS.get_resstring(11284)
--    local strContent = MHSD_UTILS.get_resstring(11175)
--    if tips1.getInstanceNotCreate() == nil then
--        local tips1Instance = tips1.getInstanceAndShow(strContent, strTitle)
--        SetPositionScreenCenter(tips1Instance:GetWindow())
--    else
--        -- ���������ı��Ϳ�����.
--        tips1.getInstanceNotCreate():RefreshData(strContent, strTitle)
--    end
--end

-- �����б�����갴��
function Familyjiarudialog:HandleFamilyEntryCellClickedDown(args)
    self:ResetSelect()
end

-- �����б������̧��(�����˵�)
function Familyjiarudialog:HandleFamilyEntryCellClicked(args)
    local e = CEGUI.toWindowEventArgs(args)
    local id = e.window:getID()
    self.m_CurSelectEntryIndex = id
    local Curcell = self.m_Entrys:getCellAtIdx(self.m_CurSelectEntryIndex - 1)
    if Curcell then
        self.ApplyJoinBtn:setEnabled(true)
        self.ConnectHostBtn:setEnabled(true)
        local curRoleID = gGetDataManager():GetMainCharacterID()
        if self.m_FactionData:IsHasFaction() then
            if Curcell.m_ID == self.m_FactionData.factionid and self.m_FactionData.GetMyZhiWu() == 1 then
                self.ConnectHostBtn:setEnabled(false)
            end
        end

        -- ���ð�ť״̬
        Curcell.btn:setSelected(true)

        -- ����������ּ
        if Curcell then
            local p = require "protodef.fire.pb.clan.crequestclanaim":new()
            p.clanid = Curcell.m_ID
            require "manager.luaprotocolmanager":send(p)
        end
    else
        local sun = 1
    end
end

-- ˢ�¹�����ּ
function Familyjiarudialog:RefreshZongZhi(text)
    if self.m_ZongZhiText then
		self.m_ZongZhiText:Clear()
        self.m_ZongZhiText:AppendText(CEGUI.String(text), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff472b20")))
		self.m_ZongZhiText:Refresh()
        self.m_ZongZhiText:HandleTop()
    end
end

-- ˢ��������
function Familyjiarudialog:RefreshOldName(text)
    if text then
        local msg = MHSD_UTILS.get_resstring(11275)
        msg = string.gsub(msg, "%$parameter1%$", text)
        self.m_OldNameText:setText(msg)
    end
end

-- ˢ��ID��ʾ
function Familyjiarudialog:update(args)
    local text = self.m_IDNumberInputText:getText()
    self.m_IDTip:setVisible(text == "")
    if self.m_Entrys then
        if self.m_Entrys.visibleCells then
            local len = 0
            for k, v in pairs(self.m_Entrys.visibleCells) do
                if v then
                    len = len + 1
                end
            end
            if self.m_CancelInputBtn then
                self.m_LingSui:setVisible((len == 0 and self.m_CancelInputBtn:isVisible()))
            end
        end
    end

end

return Familyjiarudialog

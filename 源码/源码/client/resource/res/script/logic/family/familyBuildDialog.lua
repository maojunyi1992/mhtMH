-- ������������

require "logic.dialog"
require "logic.family.familyshengjidialogcell"

familybuilddialog = { }
setmetatable(familybuilddialog, Dialog)
familybuilddialog.__index = familybuilddialog

local _instance
function familybuilddialog.getInstance()
    if not _instance then
        _instance = familybuilddialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function familybuilddialog.getInstanceAndShow()
    if not _instance then
        _instance = familybuilddialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function familybuilddialog.getInstanceNotCreate()
    return _instance
end

function familybuilddialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, familybuilddialog)
    return self
end

function familybuilddialog.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
            if Family.getInstanceNotCreate() then
                Family.getInstanceNotCreate():RefreshFamilyInfor()
                Family.getInstanceNotCreate():RefreshFamilyManager()
            end
        else
            _instance:ToggleOpenClose()
        end
    end
end

function familybuilddialog.ToggleOpenClose()
    if not _instance then
        _instance = familybuilddialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function familybuilddialog.GetLayoutFileName()
    return "familyshengjidialog.layout"
end

function familybuilddialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.data = require "logic.faction.factiondatamanager"
    self.factionLevel = self.data.factionlevel  -- ����ȼ�
    self.bankLevel = self.data.house[2]         -- ���ȼ�
    self.dragLevel = self.data.house[3]         -- ҩ���ȼ�
    self.hotelLevel = self.data.house[4]        -- �õ�ȼ�

    -- �������
    self.m_TitleText = winMgr:getWindow("familyshengjidialog/level")

    -- Ч��
    self.m_HelpText = CEGUI.toRichEditbox(winMgr:getWindow("familyshengjidialog/diban/text"))
    self.m_HelpText:getVertScrollbar():EnbalePanGuesture(false)

    -- ��������
    self.m_ConditionText = winMgr:getWindow("familyshengjidialog/tiaojian")

    -- ��������
    self.levelUpCostBg = winMgr:getWindow("familyshengjidialog/xiaohao") 
    self.m_levelUpCostText = winMgr:getWindow("familyshengjidialog/xiaohao/dikuang/feiyong")

    -- �ʽ�����
    self.MaxNeedMoneyBg = winMgr:getWindow("familyshengjidialog/zijin")
    self.m_MaxNeedText = winMgr:getWindow("familyshengjidialog/xiaohao/dikuang/feiyong1")

    -- ӵ���ʽ�
    self.OwnedMoneyBg = winMgr:getWindow("familyshengjidialog/zijin2")
    self.m_OwnedMoneyText = winMgr:getWindow("familyshengjidialog/xiaohao/dikuang/feiyong12")

    -- �����б�
	self.m_list = winMgr:getWindow("familyshengjidialog/textbg/ss")

    -- ������ť
    self.m_OkBtn = CEGUI.toPushButton(winMgr:getWindow("familyshengjidialog/shengji"))
    self.m_OkBtn:subscribeEvent("Clicked", familybuilddialog.OkBtnClicked, self)

    -- ˢ�½����б�
    self:RefreshListView()

    -- ����������
    --self.moneyBar = CEGUI.toProgressBar(winMgr:getWindow("familyshengjidialog/zijin/jindutiao"))
    --self.moneyText = winMgr:getWindow("familyshengjidialog/zijin/jindutiao/jindu")
end

-- ˢ�½����б�
function familybuilddialog:RefreshListView()
    local listSize = self.m_list:getPixelSize()
    if not self.m_ListEntrys then
        self.m_ListEntrys = TableView.create(self.m_list)
        self.m_ListEntrys:setViewSize(listSize.width, listSize.height)
        self.m_ListEntrys:setPosition(0, 0)
        self.m_ListEntrys:setDataSourceFunc(self, familybuilddialog.tableViewGetCellAtIndex)
    end

    local len = 4
    self.m_ListEntrys:setCellCountAndSize(len, 482, 200)
    self.m_ListEntrys:reloadData()

    -- ��ǰѡ�е�һ������
    self.m_ListEntrys.visibleCells[0].m_Btn:setSelected(true)
end

-- ���õ���������Ϣ
function familybuilddialog:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end

    if not cell then
        cell = FamilyShengjiDialogCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
    end
    if idx < 4 then
        local page = idx + 1
        local imageSet = self:GetImageSet(page)
        local name = self:GetName(page)
        local level = self:GetLevel(page)
        cell:SetBuildInfo(imageSet, name, level)
        cell.m_Btn:subscribeEvent("SelectStateChanged", familybuilddialog.OnCellSelectStateChanged, self)
        cell.m_Btn:setID(page)
    end

    return cell
end

-- ��ȡ����ͼƬ
function familybuilddialog:GetImageSet(page)
    if page == 1 then
        return "set:family image:family_dating"
    elseif page == 2 then
        return "set:family image:family_jinku"
    elseif page == 3 then
        return "set:family image:family_yaofang"
    elseif page == 4 then
        return "set:family image:family_lvguan"
    else
        return ""
    end
end

-- ��ȡ��������
function familybuilddialog:GetName(page)
    if page == 1 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11243).msg
    elseif page == 2 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11244).msg
    elseif page == 3 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11245).msg
    elseif page == 4 then
        return BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11246).msg
    else
        return ""
    end
end

-- ��ȡ�����ȼ�
function familybuilddialog:GetLevel(page)
    if page == 1 then
        return self.factionLevel
    elseif page == 2 then
        return self.bankLevel
    elseif page == 3 then
        return self.dragLevel
    elseif page == 4 then
        return self.hotelLevel
    else
        return 0
    end
end

-- ����ѡ��״̬�����仯�Ļص�
function familybuilddialog:OnCellSelectStateChanged(args)
    local windowEventArgs = CEGUI.toWindowEventArgs(args)
    self.m_currectPage = windowEventArgs.window:getID()

    -- ˢ�½�������ϸ����
    self:refreshData(self.m_currectPage)
end

-- �������ȷ�ϰ�ť
function familybuilddialog:OkBtnClicked(args)
    local p = require("protodef.fire.pb.clan.crequestclanlevelup"):new()
    p.id = self.m_currectPage
    print(p.id .. "name")
    LuaProtocolManager:send(p)
end

-- ˢ�½����б���Ϣ
function familybuilddialog:RefreshListInfo()
    if not self.m_ListEntrys then
        return
    end
    for k, v in pairs(self.m_ListEntrys.visibleCells) do
        local page = v.m_Btn:getID()
        local imageSet = self:GetImageSet(page)
        local name = self:GetName(page)
        local level = self:GetLevel(page)
        v:SetBuildInfo(imageSet, name, level)
    end
end

-- ˢ�½�������ϸ����
function familybuilddialog:refreshData(page)
    local houseLevel, levelupcost, maxneedmoney, maxLevel, titleText, helpText, conditionText = self:getPageData(page)

    -- �������
    self.m_TitleText:setText(titleText)

    -- Ч��
    self.m_HelpText:Clear()
    self.m_HelpText:AppendParseText(helpText)
    self.m_HelpText:Refresh()

    -- ��������
    self.m_ConditionText:setText(conditionText)

    -- ��������
    local str = require("logic.workshop.workshopmanager").getNumStrWithThousand(levelupcost)
    self.m_levelUpCostText:setText(str)

    -- �ʽ�����
    str = require("logic.workshop.workshopmanager").getNumStrWithThousand(maxneedmoney)
    self.m_MaxNeedText:setText(str)

    -- ӵ���ʽ�
    str = require("logic.workshop.workshopmanager").getNumStrWithThousand(self.data.money)
    self.m_OwnedMoneyText:setText(str)

    if self.data.money < levelupcost or self.data.money < maxneedmoney then
        self.m_OwnedMoneyText:setProperty("TextColours", "FFFF3333")
    else
        self.m_OwnedMoneyText:setProperty("TextColours", "FF00FF00")
    end

    -- ����
    if page == 1 then
        
        local otherBuildLevel = 0
        for k, v in pairs(self.data.house) do
            otherBuildLevel = otherBuildLevel + v
        end

        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactionlobby"):getRecorder(houseLevel)

        -- ��������
        if houseLevel >= maxLevel  then
            self.m_ConditionText:setProperty("TextColours", "FF693F00")
        elseif info and otherBuildLevel < info.othersum then
            self.m_ConditionText:setProperty("TextColours", "FFFF3333")
        else
            self.m_ConditionText:setProperty("TextColours", "FF00FF00")
        end

        -- ������ť
        if (info and otherBuildLevel < info.othersum) or self.data.money < levelupcost or self.data.money < maxneedmoney then
            self.m_OkBtn:setEnabled(false)
        else
            self.m_OkBtn:setEnabled(true)
        end
    
    -- ��������
    else

        -- ��������
        if houseLevel >= maxLevel  then
            self.m_ConditionText:setProperty("TextColours", "FF693F00")
        elseif self.factionLevel <= houseLevel then
            self.m_ConditionText:setProperty("TextColours", "FFFF3333")
        else
            self.m_ConditionText:setProperty("TextColours", "FF06CC11")
        end

        -- ������ť
        if self.factionLevel <= houseLevel or self.data.money < levelupcost or self.data.money < maxneedmoney then
            self.m_OkBtn:setEnabled(false)
        else
            self.m_OkBtn:setEnabled(true)
        end

    end

    if houseLevel >= maxLevel  then
        self.levelUpCostBg:setVisible(false)
        self.MaxNeedMoneyBg:setVisible(false)
        self.OwnedMoneyBg:setVisible(false)
        self.m_OkBtn:setVisible(false)
    else
        self.MaxNeedMoneyBg:setVisible(true)
        self.levelUpCostBg:setVisible(true)
        self.OwnedMoneyBg:setVisible(true)
        self.m_OkBtn:setVisible(true)
    end
end

function familybuilddialog:getPageData(page)
    local houseLevel = 0
    local levelupcost = 0
    local maxneedmoney = self.data.costmax[page]
    local maxLevel = 0
    local titleText = ""
    local helpText = ""
    local conditionText = ""

    if page == 1 then
        houseLevel = self.factionLevel
    elseif page == 2 then
        houseLevel = self.bankLevel
    elseif page == 3 then
        houseLevel = self.dragLevel
    elseif page == 4 then
        houseLevel = self.hotelLevel
    end

    -- ����
    if page == 1 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactionlobby"):getSize()
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11239))
       
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactionlobby"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11243).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(info.othersum))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11238).msg)
                strbuilder1:delete()
            end
        end

    -- ���
    elseif page == 2 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactiongoldbank"):getSize() - 1
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11240))
        
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiongoldbank"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11244).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(houseLevel + 1))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11247).msg)
                strbuilder1:delete()
            end
        end
    
    -- ҩ��
    elseif page == 3 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactiondrugstore"):getSize() - 1
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11241))
        
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactiondrugstore"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11245).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(houseLevel + 1))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11247).msg)
                strbuilder1:delete()
            end
        end
    
    -- �ù�
    elseif page == 4 then

        maxLevel = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getSize() - 1
        helpText = CEGUI.String(MHSD_UTILS.get_resstring(11242))
        
        local info = BeanConfigManager.getInstance():GetTableByName("clan.cfactionhotel"):getRecorder(houseLevel)
        if info then
            levelupcost = info.levelupcost

            local strbuilder = StringBuilder:new()
            strbuilder:Set("parameter1", tostring(houseLevel))
            strbuilder:Set("parameter2", BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11246).msg)
            titleText = strbuilder:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11237).msg)
            strbuilder:delete()

            if houseLevel >= maxLevel then
                conditionText = MHSD_UTILS.get_resstring(11499)
            else
                local strbuilder1 = StringBuilder:new()
                strbuilder1:Set("parameter1", tostring(houseLevel + 1))
                conditionText = strbuilder1:GetString(BeanConfigManager.getInstance():GetTableByName("message.cstringres"):getRecorder(11247).msg)
                strbuilder1:delete()
            end
        end

    end

    return houseLevel, levelupcost, maxneedmoney, maxLevel, titleText, helpText, conditionText
end

-- ����ˢ�µ�ǰ��������ϸ����
function familybuilddialog.processRefreshData()
    if _instance then
        _instance.factionLevel = _instance.data.factionlevel
        _instance.bankLevel = _instance.data.house[2]
        _instance.dragLevel = _instance.data.house[3]
        _instance.hotelLevel = _instance.data.house[4]
        _instance:refreshData(_instance.m_currectPage)
        _instance:RefreshListInfo()
    end
end

return familybuilddialog

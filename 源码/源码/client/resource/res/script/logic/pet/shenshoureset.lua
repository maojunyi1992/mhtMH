require "logic.dialog"
require "logic.pet.shenshouresetcell"

ShenShouReset = {}
setmetatable(ShenShouReset, Dialog)
ShenShouReset.__index = ShenShouReset

local _instance
function ShenShouReset.getInstance()
	if not _instance then
		_instance = ShenShouReset:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShenShouReset.getInstanceAndShow()
	if not _instance then
		_instance = ShenShouReset:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShenShouReset.getInstanceNotCreate()
	return _instance
end

function ShenShouReset.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
		    gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetNumChange) -- ע���������ݱ仯���¼�
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShenShouReset.ToggleOpenClose()
	if not _instance then
		_instance = ShenShouReset:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShenShouReset.GetLayoutFileName()
	return "shenshouchongzhi.layout"
end

function ShenShouReset:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShenShouReset)
	return self
end

function ShenShouReset:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_list = CEGUI.toScrollablePane(winMgr:getWindow("shenshouchongzhi/list"))
	self.m_Btn_DuiHuan = CEGUI.toPushButton(winMgr:getWindow("shenshouchongzhi/duihuan"))
    self.m_Btn_DuiHuan:subscribeEvent("Clicked", ShenShouReset.OnResetClicked, self)

    -- �������е������б�
    self.m_ShenShouList = require("logic.pet.shenshoucommon").GetShenShouList()

    -- ˢ�������б�
    self:RefreshListView()

    -- ע��������ݱ仯���¼�
	self.eventPetNumChange = gGetDataManager().m_EventPetNumChange:InsertScriptFunctor(ShenShouReset.handleEventPetNumChange)
end

-- ˢ�������б�
function ShenShouReset:RefreshListView()
    if not self.m_ListEntrys then
        local listSize = self.m_list:getPixelSize()
        self.m_ListEntrys = TableView.create(self.m_list)
        self.m_ListEntrys:setViewSize(listSize.width - 20, listSize.height - 20)
        self.m_ListEntrys:setPosition(10, 10)
        self.m_ListEntrys:setDataSourceFunc(self, ShenShouReset.tableViewGetCellAtIndex)
    end

    local len = #self.m_ShenShouList
    self.m_ListEntrys:setCellCountAndSize(len, 811, 100)
    self.m_ListEntrys:setContentOffset(0)
    self.m_ListEntrys:reloadData()

    -- ��ǰѡ�е�һ������
    if len > 0 then
        self.m_ListEntrys.visibleCells[0].m_Btn:setSelected(true)
    end
end

-- ���õ������޵�����
function ShenShouReset:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end

    if not cell then
        cell = ShenShouResetCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
    end
    if self.m_ShenShouList and #self.m_ShenShouList > idx then
        cell:SetPetInfo(self.m_ShenShouList[idx + 1])
        cell.m_Btn:subscribeEvent("SelectStateChanged", ShenShouReset.OnCellSelectStateChanged, self)
        cell.m_Btn:setID(idx + 1)
    end
    return cell
end

-- ����ѡ��״̬�����仯�Ļص�
function ShenShouReset:OnCellSelectStateChanged(args)
    local windowEventArgs = CEGUI.toWindowEventArgs(args)
    self.m_SelectedEntryIndex = windowEventArgs.window:getID() -1
end

-- ���ø����������ù��ܡ���NPC��npckey
function ShenShouReset:SetNpcKey(npckey)
    self.m_NpcKey = npckey
end

-- ���á����������á���Ҫ�ĵ�������
function ShenShouReset:SetItemName(itemname)
    self.m_ItemName = itemname
end

-- ���������ð�ť
function ShenShouReset:OnResetClicked(args)
    if self.m_ShenShouList and #self.m_ShenShouList > self.m_SelectedEntryIndex then
        local petInfo = self.m_ShenShouList[self.m_SelectedEntryIndex + 1]

        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	    local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
        local nItemID = tonumber(strItemID)

        -- �����жһ����ߵ�����
        local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

        -- ����������Ҫ�ġ����޶һ����ߡ�������
	    local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(287).value
        local nNeedItemNum = tonumber(strNeedItemNum)

        -- �һ����߲���
        if curItemNum < nNeedItemNum then
            local parameters = {}
            table.insert(parameters, self.m_ItemName)
            ShenShouCommon.SendClientTips(162110, parameters, self.m_NpcKey, nil, nil, nil)

        -- ��������
        else
            local chooseDlg = require("logic.chosepetdialog").getInstance()
            local shenshouidlist = ShenShouCommon.GetShenShouIdListWithoutMine(petInfo.baseid)
            chooseDlg:SetSelectShenShouId(1, shenshouidlist, self.m_ItemName, self.m_NpcKey, petInfo.name, petInfo.shenshouinccount, petInfo.key)
        end
    end
end

-- �������ݱ仯�Ļص�
function ShenShouReset.handleEventPetNumChange(key)
    ShenShouReset.DestroyDialog()
--	if _instance and _instance:IsVisible() then
--        -- �������е������б�
--        _instance.m_ShenShouList = require("logic.pet.shenshoucommon").GetShenShouList()
--        -- ˢ�������б�
--        _instance:RefreshListView()
--	end
end

return ShenShouReset
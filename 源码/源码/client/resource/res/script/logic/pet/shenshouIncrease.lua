require "logic.dialog"
require "logic.pet.shenshouIncreasecell"

ShenShouIncrease = {}
setmetatable(ShenShouIncrease, Dialog)
ShenShouIncrease.__index = ShenShouIncrease

local _instance
function ShenShouIncrease.getInstance()
	if not _instance then
		_instance = ShenShouIncrease:new()
		_instance:OnCreate()
	end
	return _instance
end

function ShenShouIncrease.getInstanceAndShow()
	if not _instance then
		_instance = ShenShouIncrease:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function ShenShouIncrease.getInstanceNotCreate()
	return _instance
end

function ShenShouIncrease.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
		    gGetDataManager().m_EventPetDataChange:RemoveScriptFunctor(_instance.eventPetDataChange) -- ע���������ݱ仯���¼�
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function ShenShouIncrease.ToggleOpenClose()
	if not _instance then
		_instance = ShenShouIncrease:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShenShouIncrease.GetLayoutFileName()
	return "tishenshenshou.layout"
end

function ShenShouIncrease:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, ShenShouIncrease)
	return self
end

function ShenShouIncrease:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_list = winMgr:getWindow("tishenshenshou/diban")

	self.m_IncreaseTimes = winMgr:getWindow("tishenshenshou/tishenshu")
	self.m_RemainTimes = winMgr:getWindow("tishenshenshou/shengyushu")

	self.m_attackApt = winMgr:getWindow("tishenshenshou/gongzishu")
	self.m_attackApt_Increase = winMgr:getWindow("tishenshenshou/tishenshu21")
	self.m_defendApt = winMgr:getWindow("tishenshenshou/fangzishu")
	self.m_defendApt_Increase = winMgr:getWindow("tishenshenshou/fangzishu1")
	self.m_phyApt = winMgr:getWindow("tishenshenshou/tizishu")
	self.m_phyApt_Increase = winMgr:getWindow("tishenshenshou/tizishu1")
	self.m_magicApt = winMgr:getWindow("tishenshenshou/fazishu")
	self.m_magicApt_Increase = winMgr:getWindow("tishenshenshou/tishenshu2121")
	self.m_speedApt = winMgr:getWindow("tishenshenshou/suzishu")
	self.m_speedApt_Increase = winMgr:getWindow("tishenshenshou/tishenshu21211")
	self.m_growApt = winMgr:getWindow("tishenshenshou/chengzhangshu")
	self.m_growApt_Increase = winMgr:getWindow("tishenshenshou/chengzhangshu1")

    self.m_ItemCell = CEGUI.toItemCell(winMgr:getWindow("tishenshenshou/bg2/daoju"))
    self.m_ItemName = winMgr:getWindow("tishenshenshou/bg2/shendoudou")
    self.m_ItemNum = winMgr:getWindow("tishenshenshou/bg2/number")
    self.m_Btn_Increase = winMgr:getWindow("tishenshenshou/bg2/btnduihuan")
    self.m_Btn_Increase:subscribeEvent("Clicked", ShenShouIncrease.OnIncreaseClicked, self)

    -- �������е������б�
    self.m_ShenShouList = require("logic.pet.shenshoucommon").GetShenShouList()

    -- ˢ�������б�
    self:RefreshListView()

    -- ˢ��UI
    self:RefreshUI()

    -- ע��������ݱ仯���¼�
	self.eventPetDataChange = gGetDataManager().m_EventPetDataChange:InsertScriptFunctor(ShenShouIncrease.handleEventPetDataChange)
end

-- ˢ�������б�
function ShenShouIncrease:RefreshListView()
    local listSize = self.m_list:getPixelSize()
    if not self.m_ListEntrys then
        self.m_ListEntrys = TableView.create(self.m_list)
        self.m_ListEntrys:setViewSize(listSize.width, listSize.height - 10)
        self.m_ListEntrys:setPosition(5, 5)
        self.m_ListEntrys:setDataSourceFunc(self, ShenShouIncrease.tableViewGetCellAtIndex)
    end

    local len = #self.m_ShenShouList
    self.m_ListEntrys:setCellCountAndSize(len, 291, 100)
    self.m_ListEntrys:reloadData()

    -- ��ǰѡ�е�һ������
    if len > 0 then
        self.m_ListEntrys.visibleCells[0].m_Btn:setSelected(true)
    end
end

-- ���õ������޵�����
function ShenShouIncrease:tableViewGetCellAtIndex(tableView, idx, cell)
    if idx == nil then
        return
    end
    if tableView == nil then
        return
    end

    if not cell then
        cell = ShenShouIncreaseCell.CreateNewDlg(tableView.container, tableView:genCellPrefix())
    end
    if self.m_ShenShouList and #self.m_ShenShouList > idx then
        cell:SetPetInfo(self.m_ShenShouList[idx + 1])
        cell.m_Btn:subscribeEvent("SelectStateChanged", ShenShouIncrease.OnCellSelectStateChanged, self)
        cell.m_Btn:setID(idx + 1)
    end

    return cell
end

-- ����ѡ��״̬�����仯�Ļص�
function ShenShouIncrease:OnCellSelectStateChanged(args)
    local windowEventArgs = CEGUI.toWindowEventArgs(args)
    self.m_SelectedEntryIndex = windowEventArgs.window:getID() - 1

    -- ˢ����������
    self:RefreshShenShouInfo(self.m_SelectedEntryIndex)
end

-- �������������ť
function ShenShouIncrease:OnIncreaseClicked(args)
   local petInfo = self.m_ShenShouList[self.m_SelectedEntryIndex + 1]
   ShenShouCommon.DoIncrease(petInfo.key)
end

-- ˢ��UI
function ShenShouIncrease:RefreshUI()
    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local strItemID = GameTable.common.GetCCommonTableInstance():getRecorder(289).value
    local nItemID = tonumber(strItemID)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemID)

    -- �����С����޶һ����ߡ�������
    local curItemNum = roleItemManager:GetItemNumByBaseID(nItemID)

    -- ����������Ҫ�ġ����޶һ����ߡ�������
	local strNeedItemNum = GameTable.common.GetCCommonTableInstance():getRecorder(288).value
    local nNeedItemNum = tonumber(strNeedItemNum)

    if itemAttr then
        -- ����ͼ��
	    local image = gGetIconManager():GetItemIconByID(itemAttr.icon)
        self.m_ItemCell:SetImage(image)
        SetItemCellBoundColorByQulityItemWithId(self.m_ItemCell, nItemID)
        -- ��������
        self.m_ItemName:setText(itemAttr.name)
    end

    -- ��������
    self.m_ItemNum:setText(string.format("%d/%d", curItemNum, nNeedItemNum))

    -- ˢ����������
    self:RefreshShenShouInfo(self.m_SelectedEntryIndex)
end

-- ˢ����������
function ShenShouIncrease:RefreshShenShouInfo(idx)
    if self.m_ShenShouList and #self.m_ShenShouList > idx then
        local petInfo = self.m_ShenShouList[idx + 1]

        -- ��������������
	    local strMaxIncCnt = GameTable.common.GetCCommonTableInstance():getRecorder(305).value
        local nMaxIncCnt = tonumber(strMaxIncCnt)
        -- ��ǰ������������
        local nNowIncCnt = petInfo.shenshouinccount
	    self.m_IncreaseTimes:setText(nNowIncCnt)
        -- ��ǰ����ʣ����������
        local nRemainIncCnt = nMaxIncCnt - nNowIncCnt
        local petConf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petInfo.baseid)
        
	    self.m_RemainTimes:setText(nRemainIncCnt)

        -- ��ǰ��������
        self.m_attackApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT))
        self.m_defendApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT))
        self.m_phyApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT))
        self.m_magicApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT))
        self.m_speedApt:setText(petInfo:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT))
        self.m_growApt:setText(string.format("%0.3f", math.floor(petInfo.growrate * 1000) / 1000))

        local plus = MHSD_UTILS.get_resstring(11477)
        
        -- ��ǰ�������ʿ�����ֵ
        self.m_attackApt_Increase:setText(plus .. 0)
        self.m_defendApt_Increase:setText(plus .. 0)
        self.m_phyApt_Increase:setText(plus .. 0)
        self.m_magicApt_Increase:setText(plus .. 0)
        self.m_speedApt_Increase:setText(plus .. 0)
        self.m_growApt_Increase:setText(plus .. 0)
        if nRemainIncCnt > 0 then
            local ids = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getAllID()
            for i = 1, #ids do
	            local shenshouinc = BeanConfigManager.getInstance():GetTableByName("pet.cshenshouinc"):getRecorder(ids[i])
                if shenshouinc and shenshouinc.petid == petInfo.baseid and shenshouinc.inccount == nNowIncCnt + 1 then
                    self.m_attackApt_Increase:setText(plus .. shenshouinc.atkinc)
                    self.m_defendApt_Increase:setText(plus .. shenshouinc.definc)
                    self.m_phyApt_Increase:setText(plus .. shenshouinc.hpinc)
                    self.m_magicApt_Increase:setText(plus .. shenshouinc.mpinc)
                    self.m_speedApt_Increase:setText(plus .. shenshouinc.spdinc)
                    self.m_growApt_Increase:setText(plus .. string.format("%0.3f", shenshouinc.attinc / 1000))
                end
            end
        end
    end
end

-- �������ݱ仯�Ļص�
function ShenShouIncrease.handleEventPetDataChange(key)
	if _instance and _instance:IsVisible() then
	    _instance:RefreshUI()
	end
end

return ShenShouIncrease
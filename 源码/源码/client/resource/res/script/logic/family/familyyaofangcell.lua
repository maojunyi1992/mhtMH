Familyyaofangcell = { }

setmetatable(Familyyaofangcell, Dialog)
Familyyaofangcell.__index = Familyyaofangcell
local prefix = 0

function Familyyaofangcell.CreateNewDlg(parent)
    local newDlg = Familyyaofangcell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyyaofangcell.GetLayoutFileName()
    return "familyyaofangcell.layout"
end

function Familyyaofangcell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyyaofangcell)
    return self
end

function Familyyaofangcell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyyaofangcell_mtg"))
    self.window:EnableClickAni(false)
    self.m_Icon = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "familyyaofangcell_mtg/item"))
    self.buyNumLimit = winMgr:getWindow(prefixstr .. "familyyaofangcell_mtg/number")
    self.m_NameText = winMgr:getWindow(prefixstr .. "familyyaofangcell_mtg/name")
    self.m_YinBiText = winMgr:getWindow(prefixstr .. "familyyaofangcell_mtg/yinbjiage")
    self.m_JinBiText = winMgr:getWindow(prefixstr .. "familyyaofangcell_mtg/gongxianjiage")


end

-- ������Ϣ
function Familyyaofangcell:SetInfor(infor)
    -- ��û�������
    local datamanager = require "logic.faction.factiondatamanager"
    local data = datamanager.m_FamilyYaoFangList[infor]
    if data then

    end
    self.m_ID = data.itemid
    self.m_Index = infor
    self.m_Number = data.itemnum
    self.window:setID(self.m_Index)
    local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(self.m_ID)
    if itemAttrCfg then
        self.m_Desc = itemAttrCfg.destribe
        local netData = BeanConfigManager.getInstance():GetTableByName("clan.cfactionyaofang"):getRecorder(self.m_ID)
        if itemAttrCfg and netData then
            local temp = gGetIconManager():GetItemIconByID(itemAttrCfg.icon)
            self.m_Icon:SetImage(temp)

			SetItemCellBoundColorByQulityItem(self.m_Icon, itemAttrCfg.nquality)

            -- ����
            self.m_NameText:setText(itemAttrCfg.name)
            self.m_Name = itemAttrCfg.name
            -- ���Ҽ۸�
            self.m_YinBi = netData.money
            self.m_YinBiText:setText(require("logic.workshop.workshopmanager").getNumStrWithThousand(netData.money))
            -- �ﹱ�۸�
            self.m_BangGong = netData.banggong
            self.m_JinBiText:setText(require("logic.workshop.workshopmanager").getNumStrWithThousand(netData.banggong))
            -- �������½ǽǱ�
            self.buyNumLimit:setText(tostring(self.m_Number))
        end
    end
end

return Familyyaofangcell

Familyfuwendiacell = { }

setmetatable(Familyfuwendiacell, Dialog)
Familyfuwendiacell.__index = Familyfuwendiacell
local prefix = 0

function Familyfuwendiacell.CreateNewDlg(parent)
    local newDlg = Familyfuwendiacell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyfuwendiacell.GetLayoutFileName()
    return "familyfuwendiacell.layout"
end

function Familyfuwendiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfuwendiacell)
    return self
end

function Familyfuwendiacell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)

    self.m_width = self:GetWindow():getPixelSize().width
	self.m_height = self:GetWindow():getPixelSize().height 

    -- ͼ��
    self.m_Icon = winMgr:getWindow(prefixstr .. "familyfuwendiacell/fuwendikuang/icon")
    -- ����
    self.m_NameText = winMgr:getWindow(prefixstr .. "familyfuwendiacell/fuwenname")

    -- ѡ��Թ�������ť
    self.m_SelectBtn = CEGUI.toCheckbox(winMgr:getWindow(prefixstr .. "familyfuwendiacell/diban/gouxuan"))
    -- ����״̬ͼ��
    self.m_FuwenApplyStateImage = winMgr:getWindow(prefixstr .. "familyfuwendiacell/diban/biaoji")
    
	self.m_DescText = winMgr:getWindow(prefixstr .. "familyfuwendiacell/text")
    	
end
-- ������Ϣ
function Familyfuwendiacell:SetInfor(infor)
    if not infor then
        return
    end
 
    self.m_ID = infor.id
    -- װ��λ�ñ�
    local EquipPosTable =
    {
        [0] = { },
        -- ���� --
        [2] = { },
        -- ���� --
        [3] = { },
        -- �·� --
        [4] = { },
        -- ���� --
        [5] = { },
        -- Ь�� --
        [6] = { }
        -- ñ�� --
    }
    -- ͨ������ID��ö�Ӧ����ID
    local function GetFuwenID(attID)
        local ids = BeanConfigManager.getInstance():GetTableByName("item.cfumoeffectformula"):getAllID()
        for i = 1, #ids do
            local config = BeanConfigManager.getInstance():GetTableByName("item.cfumoeffectformula"):getRecorder(ids[i])
            if config then
                if config.npropertyid then
                    if config.npropertyid == attID then
                        return config.id
                    end
                    if config.npropertyid2 then
                        if config.npropertyid2 == attID then
                            return config.id
                        end
                    end
                end
            end
        end
        return 0
    end

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    for k, v in pairs(EquipPosTable) do
        local item = roleItemManager:GetCurrentEquip(fire.pb.item.BagTypes.EQUIP, k)
        if item then
            local baseID = item:GetBaseObject().id
            local baseObject = item:GetObject()
            local pEquipData = nil
            if baseObject then
                pEquipData = baseObject
                local mapValue = { }

                require("logic.tips.commontiphelper").getPropertyValue(pEquipData, mapValue)
                for nPropertyId, nValue in pairs(mapValue) do
                    local ID = GetFuwenID(nPropertyId)
                    if ID == self.m_ID then
                        local text = MHSD_UTILS.get_resstring(11377)
                        --  text = text .. tostring(nValue)
                        self.m_DescText:setText(text)
                    end
                end
            end
        end
    end
    -- ����ͼƬ
    self.m_Icon:setProperty("Image", gGetIconManager():GetImagePathByID(infor.icon):c_str())
    -- ��������
    self.m_NameText:setText(infor.namecc1)
    self:RefreshApplyState()

end
function Familyfuwendiacell:RefreshApplyState()
    -- ��������ͼ��
    local datamanager = require "logic.faction.factiondatamanager"
    if self.m_ID then
        self.m_FuwenApplyStateImage:setVisible(datamanager.IsInHasBeenRuneQuestList(self.m_ID))
    end
end
return Familyfuwendiacell

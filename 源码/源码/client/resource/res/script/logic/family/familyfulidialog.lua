require "logic.dialog"
require "logic.family.familyfulidiacell"
require "logic.family.familyfuwendialog"
require "logic.family.familyyaofang"

Familyfulidialog = { }
setmetatable(Familyfulidialog, Dialog)
Familyfulidialog.__index = Familyfulidialog

local _instance
function Familyfulidialog.getInstance()
    if not _instance then
        _instance = Familyfulidialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function Familyfulidialog.getInstanceAndShow()
    if not _instance then
        _instance = Familyfulidialog:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Familyfulidialog.getInstanceNotCreate()
    return _instance
end

function Familyfulidialog.DestroyDialog(IsDestroyPage)
    -- �رձ�dialog
    if IsDestroyPage == nil then
        IsDestroyPage = true
    end
    if IsDestroyPage then
        if Familylabelframe.getInstanceNotCreate() then
            Familylabelframe.getInstanceNotCreate().DestroyDialog()
        end
    end
    if _instance then
        if not _instance.m_bCloseIsHide then
            if  _instance.m_cells then
				for index in pairs( _instance.m_cells ) do
					local cell = _instance.m_cells[index]
					if cell then
						cell:OnClose()
					end
				end
			end
            _instance.m_cells = nil
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function Familyfulidialog.ToggleOpenClose()
    if not _instance then
        _instance = Familyfulidialog:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Familyfulidialog.GetLayoutFileName()
    return "familyfulidialog.layout"
end

function Familyfulidialog:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfulidialog)
    return self
end

function Familyfulidialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_EntryCollection = CEGUI.toScrollablePane(winMgr:getWindow("Familyfulidialog/diban/fuli"))
	self.m_EntryCollection:EnableHorzScrollBar(true)
    self.m_cells = {}
	self:RefreshListView()

    local p = require "protodef.fire.pb.clan.cbonusquery":new()
    require "manager.luaprotocolmanager":send(p)
    SetPositionOfWindowWithLabel(self:GetWindow())
end


function Familyfulidialog:RefreshListView()

    local len = BeanConfigManager.getInstance():GetTableByName("clan.cfactionfuli"):getSize()
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_REDPACK then
                    if v.state == 1 then
                        len = len - 1
                    end
                end
            end
        end
    end


	for i=1,len do
		local curCell =   Familyfulidiacell.CreateNewDlg(self.m_EntryCollection, i-1)
        local col  = 5;
        local row  =  math.floor((i-1) / col)
	    local x = CEGUI.UDim(0, 5 + ((i-1)%col)*(curCell.m_width+1))
        local y = CEGUI.UDim(0, 1 + row*(curCell.m_height  +1) )
		local pos = CEGUI.UVector2(x,y)
		curCell:GetWindow():setPosition(pos)

        curCell.m_OpenBtn:subscribeEvent("Clicked", Familyfulidialog.OnClickedBtn, self)
        curCell.m_LingQuBtn:subscribeEvent("Clicked", Familyfulidialog.OnClickedBtn, self)
        local infor = BeanConfigManager.getInstance():GetTableByName("clan.cfactionfuli"):getRecorder(i)
        if infor then
            curCell.m_OpenBtn:setID(i)
            curCell.m_LingQuBtn:setID(i)
            curCell:SetInfor(infor)
            local datamanager = require "logic.faction.factiondatamanager"
            curCell:SetFenHongNumber(datamanager.bonus)
        end


		table.insert(self.m_cells, curCell)
	end
	
end

-- �����Ϣ
function Familyfulidialog:OnClickedBtn(args)
    local clickID = CEGUI.toWindowEventArgs(args).window:getID()
    -- �������
    if clickID == 1 then
       Familyfuwendialog.getInstanceAndShow()
    end
    -- ���Ἴ��
    if clickID == 2 then
        if gGetDataManager():GetMainCharacterLevel() < 35 then
            local text = MHSD_UTILS.get_msgtipstring(160410)
            text = string.gsub(text, "%$parameter1%$", tostring(35))
            GetCTipsManager():AddMessageTip(text)
            return
        end

        local skillIndex = 2
        SkillLable.Show(skillIndex)
        self.DestroyDialog()
    end
    -- ����ר��
    if clickID == 3 then
        if gGetDataManager():GetMainCharacterLevel() < 45 then
            local text = MHSD_UTILS.get_msgtipstring(160409)
            text = string.gsub(text, "%$parameter1%$", tostring(45))
            GetCTipsManager():AddMessageTip(text)
            return
        end
        local skillIndex = 3
        SkillLable.Show(skillIndex)
        self.DestroyDialog()
    end
    -- ����ҩ��
    if clickID == 4 then
        local datamanager = require "logic.faction.factiondatamanager"
        local infor = datamanager.house[3]
        if infor then
            if infor == 0 then
                local strContent = MHSD_UTILS.get_msgtipstring(160318)
                GetCTipsManager():AddMessageTip(strContent)
                return
            end
        end
        Familyyaofang.getInstanceAndShow()
    end
    -- ���Ṥ��
    if clickID == 5 then
        local p = require "protodef.fire.pb.clan.cgrabbonus":new()
        require "manager.luaprotocolmanager":send(p)
        return
    end
    -- ������
    if clickID == 6 then
        require("logic.redpack.redpacklabel")
        RedPackLabel.DestroyDialog()
        RedPackLabel.getInstance():showOnly(2)
    end
end

-- ˢ�·ֺ�����
function Familyfulidialog:RefreshFenHongText(arg)
    if not self.m_cells then
        return
    end
    for k, v in pairs(self.m_cells) do
        local datamanager = require "logic.faction.factiondatamanager"
        v:SetFenHongNumber(datamanager.bonus)
    end
end

return Familyfulidialog

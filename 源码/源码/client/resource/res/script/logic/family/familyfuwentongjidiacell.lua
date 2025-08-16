Familyfuwentongjidiacell = { }

setmetatable(Familyfuwentongjidiacell, Dialog)
Familyfuwentongjidiacell.__index = Familyfuwentongjidiacell
local prefix = 0

function Familyfuwentongjidiacell.CreateNewDlg(parent)
    local newDlg = Familyfuwentongjidiacell:new()
    newDlg:OnCreate(parent)
    return newDlg
end

function Familyfuwentongjidiacell.GetLayoutFileName()
    return "familyfuwentongjidiacell.layout"
end

function Familyfuwentongjidiacell:new()
    local self = { }
    self = Dialog:new()
    setmetatable(self, Familyfuwentongjidiacell)
    return self
end

function Familyfuwentongjidiacell:OnCreate(parent)
    prefix = prefix + 1
    Dialog.OnCreate(self, parent, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    local prefixstr = tostring(prefix)
    self.m_Btn = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/diban"))
    -- ����
    self.m_Name = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/name")
    -- �ȼ�
    self.m_Level = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/lv")
    -- ְҵ
    self.m_ZhiYe = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/zhiye")
    -- ְ��
    self.m_ZhiWu = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/zhiwu")
    -- ����
    self.m_JuanZeng = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/juanzeng")
    -- ��ȡ
    self.m_ShouQi = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/shouqu")
    -- �����ȼ�
    self.m_JuanZengLevel = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/juanzengdengji")
    -- ͼ��
    self.m_Icon = winMgr:getWindow(prefixstr .. "familyfuwentongjidiacell/icon")
end
-- ������Ϣ
function Familyfuwentongjidiacell:SetInfor(infor)
    self.m_Name:setText(infor.rolename)
    self.m_Level:setText(tostring(infor.level))
    -- ְҵ
    local schoolName = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(infor.school)
    if schoolName then
        self.m_ZhiYe:setText(schoolName.name)
        self.m_Icon:setProperty("Image", schoolName.schooliconpath)
    end
    local conf = BeanConfigManager.getInstance():GetTableByName("clan.cfactionposition"):getRecorder(infor.position)
    if conf then
        self.m_ZhiWu:setText(conf.posname)
    end
    self.m_JuanZeng:setText(tostring(infor.givenum))
    self.m_ShouQi:setText(tostring(infor.acceptnum))
    self.m_JuanZengLevel:setText(tostring(infor.givelevel))
end

return Familyfuwentongjidiacell

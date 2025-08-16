require "logic.dialog"

JingMaiTipssss = {}
setmetatable(JingMaiTipssss, Dialog)
JingMaiTipssss.__index = JingMaiTipssss



local _instance
function JingMaiTipssss.getInstance()
    if not _instance then
        _instance = JingMaiTipssss:new()
        _instance:OnCreate()
    end
    return _instance
end
function JingMaiTipssss:handleQuitBtnClicked(e)
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end
function JingMaiTipssss.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiTipssss:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiTipssss.getInstanceNotCreate()
    return _instance
end

function JingMaiTipssss.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function JingMaiTipssss.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiTipssss:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiTipssss.GetLayoutFileName()
    return "rongyujieshao.layout"
end

function JingMaiTipssss:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiTipssss)
    return self
end

function JingMaiTipssss:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.text1 = winMgr:getWindow("rongyujieshao/zhiye2")
    self.text1:setText("")

    self.text2 = winMgr:getWindow("rongyujieshao/juese1")
    self.text2:setText("")
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("rongyujieshao/back"))
self.m_btnguanbi:subscribeEvent("Clicked", JingMaiTipssss.handleQuitBtnClicked, self)
end

function JingMaiTipssss:RefreshData(schoollist, classlist)
    local str1 = ""
    local str2 = ""
    for i = 1, #schoollist do
        local Shape = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(schoollist[i])

        if i == #schoollist or i >= 3 then
            str1 = str1 .. Shape.name .. "."
        else
            str1 = str1 .. Shape.name .. ","
        end

    end
    self.text2:setText(str1)

    for i = 1, #classlist do
        local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(classlist[i])

        if i == #classlist or i >= 3 then
            str2 = str2 .. school.name .. "."
        else
            str2 = str2 .. school.name .. ","
        end
    end
    self.text1:setText(str2)
end

return JingMaiTipssss
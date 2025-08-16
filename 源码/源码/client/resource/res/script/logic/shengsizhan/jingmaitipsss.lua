require "logic.dialog"

JingMaiTipsss = {}
setmetatable(JingMaiTipsss, Dialog)
JingMaiTipsss.__index = JingMaiTipsss



local _instance
function JingMaiTipsss.getInstance()
    if not _instance then
        _instance = JingMaiTipsss:new()
        _instance:OnCreate()
    end
    return _instance
end
function JingMaiTipsss:handleQuitBtnClicked(e)
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end
function JingMaiTipsss.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiTipsss:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiTipsss.getInstanceNotCreate()
    return _instance
end

function JingMaiTipsss.DestroyDialog()
    if _instance then
        if not _instance.m_bCloseIsHide then
            _instance:OnClose()
            _instance = nil
        else
            _instance:ToggleOpenClose()
        end
    end
end

function JingMaiTipsss.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiTipsss:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiTipsss.GetLayoutFileName()
    return "guanzhiyilan.layout"
end

function JingMaiTipsss:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiTipsss)
    return self
end

function JingMaiTipsss:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.text1 = winMgr:getWindow("guanzhiyilan/zhiye2")
    self.text1:setText("")

    self.text2 = winMgr:getWindow("guanzhiyilan/juese1")
    self.text2:setText("")
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("guanzhiyilan/back"))
self.m_btnguanbi:subscribeEvent("Clicked", JingMaiTipsss.handleQuitBtnClicked, self)
end

function JingMaiTipsss:RefreshData(schoollist, classlist)
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

return JingMaiTipsss
require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

JingMaiXuanZe = {}
setmetatable(JingMaiXuanZe, Dialog)
JingMaiXuanZe.__index = JingMaiXuanZe
local _instance;
--//===============================
function JingMaiXuanZe:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.zhiyeProperty = CEGUI.toScrollablePane(winMgr:getWindow("jingmaixuanze/left"))
    self.zhiyeProperty:setMousePassThroughEnabled(true)
    self.zhiyeProperty:cleanupNonAutoChildren()
    self.menpaiProperty = CEGUI.toScrollablePane(winMgr:getWindow("jingmaixuanze/jingmais"))

	--关闭按钮
	self.close = winMgr:getWindow("jingmaixuanze/x")
	self.close:subscribeEvent("Clicked", self.DestroyDialog, nil)

	self.AlphaBG1 = winMgr:getWindow("jingmaixuanze/left/bg2")
	self.AlphaBG2 = winMgr:getWindow("jingmaixuanze/left/bg21")
	self.AlphaBG1:setAlpha(0.2)
	self.AlphaBG2:setAlpha(0.2)


    self.xuanzebtn = CEGUI.toPushButton(winMgr:getWindow("jingmaixuanze/right/button"))
    self.xuanzebtn:subscribeEvent("MouseButtonUp", JingMaiXuanZe.HandleClick, self)

    self.selectzhiye=gGetDataManager():GetMainCharacterSchoolID()
    self.selectjingmai=0
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getAllID()
    local index=1
    self.zhiyes={}
    self.jingmais={}
    for k,v in pairs(tableAllId) do
        if v==gGetDataManager():GetMainCharacterSchoolID() then
            local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(v)
            local prefix = "jingmaimenpaixuanzecell"..index
            local cellmenpai = require "logic.workshop.jingmai.jingmaimenpaixuanzecell".new(self.zhiyeProperty, index - 1,prefix)

            cellmenpai.labItemName:setText(school.name)
            cellmenpai.imageBg:setProperty("Image", school.schooliconpath)
            cellmenpai.btnBg:subscribeEvent("MouseClick", JingMaiXuanZe.HandleClickedItem,self)
            cellmenpai.nzhiye=v
            self.zhiyes[v]=cellmenpai
            index=index+1
        end
    end
    for k,v in pairs(tableAllId) do
        if v~=gGetDataManager():GetMainCharacterSchoolID() then
            local school = BeanConfigManager.getInstance():GetTableByName("role.schoolinfo"):getRecorder(v)
            local prefix = "jingmaimenpaixuanzecell"..index
            local cellmenpai = require "logic.workshop.jingmai.jingmaimenpaixuanzecell".new(self.zhiyeProperty, index - 1,prefix)
            cellmenpai.labItemName:setText(school.name)
            cellmenpai.imageBg:setProperty("Image", school.schooliconpath)
            cellmenpai.btnBg:subscribeEvent("MouseClick", JingMaiXuanZe.HandleClickedItem,self)
            cellmenpai.nzhiye=v
            self.zhiyes[v]=cellmenpai
            index=index+1
        end
    end
    self.xuanzebtn:setVisible(false)
    self:RefreshMenPai()
end
function JingMaiXuanZe:HandleClickedItem(e)
    local mouseArgs = CEGUI.toMouseEventArgs(e)
    for k,v in pairs(self.zhiyes)  do
        local cellmenpai = self.zhiyes[k]
        if cellmenpai.btnBg == mouseArgs.window then
            self.selectzhiye =  cellmenpai.nzhiye
            break
        end
    end
    self:RefreshMenPaiCellSel() --self:RefreshEquipCellSel()
    self:RefreshMenPai()
    return true
end
function JingMaiXuanZe:RefreshMenPai()
    if self.selectzhiye==0 then
        return
    end
    if  self.selectzhiye~=gGetDataManager():GetMainCharacterSchoolID() then
        self.xuanzebtn:setEnabled(false)
    else
        self.xuanzebtn:setEnabled(true)
        --self.zhiyes[gGetDataManager():GetMainCharacterSchoolID()].btnBg:setSelected(true)
        self.zhiyes[gGetDataManager():GetMainCharacterSchoolID()].btnBg:setProperty("NormalImage",  "set:my_jingmai image:btnB2")
		
    end


    self.menpaiProperty:cleanupNonAutoChildren()
    local schools = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaizhanshi"):getRecorder(self.selectzhiye)
    for index=1,4 do
        local prefix = "jingmaimenzhanshi"..index
        local cellmenpai = require "logic.workshop.jingmai.jingmaizhanshi".new(self.menpaiProperty, index - 1,prefix)
        cellmenpai.LabName:setText(schools.names[index-1])
        cellmenpai.LabJieshao:setText(schools.miaoshus[index-1])
        cellmenpai.LabImage:setProperty("Image", schools.zhanshis[index-1])
        cellmenpai.njingmai=index
        self.jingmais[index]=cellmenpai
        cellmenpai.btnBg:subscribeEvent("MouseClick", JingMaiXuanZe.HandleClickedItem2,self)
    end
end
function JingMaiXuanZe:HandleClickedItem2(e)
    local mouseArgs = CEGUI.toMouseEventArgs(e)
    for k,v in pairs(self.jingmais)  do
        local cellmenpai = self.jingmais[k]
        if cellmenpai.btnBg == mouseArgs.window then
            self.selectjingmai =  cellmenpai.njingmai
            break
        end
    end
    self:RefreshMenPaiCellSel2() --self:RefreshEquipCellSel()
    return true
end
function JingMaiXuanZe:RefreshMenPaiCellSel()
    for k,v in pairs(self.zhiyes)  do
        local cellmenpai = self.zhiyes[k]
 		--self.zhiyes[k].btnBg:setProperty("NormalImage",  nil)
       if cellmenpai.nzhiye ~= self.selectzhiye then
            --cellmenpai.btnBg:setSelected(false)
		    cellmenpai.btnBg:setProperty("NormalImage",  "set:my_jingmai image:btnB1")
        else
		    cellmenpai.btnBg:setProperty("NormalImage",  "set:my_jingmai image:btnB2")
            --cellmenpai.btnBg:setSelected(true)
        end
    end
end
function JingMaiXuanZe:RefreshMenPaiCellSel2()
    for k,v in pairs(self.jingmais)  do
        local cellmenpai = self.jingmais[k]
		--self.zhiyes[k].btnBg:setProperty("NormalImage",  nil)

        if cellmenpai.njingmai ~= self.selectjingmai then
            --cellmenpai.btnBg:setSelected(false)
		    cellmenpai.btnBg:setProperty("NormalImage",  nil)
        else
		
		    cellmenpai.btnBg:setProperty("NormalImage",  "set:my_jingmai image:bgsel")

            --cellmenpai.btnBg:setSelected(true)
        end
    end
end
function JingMaiXuanZe:HandleClick(arg)
    if self.selectjingmai==0 then
        return
    end
    --local p = require "logic.workshop.jingmai.cjingmaisel":new()
    --p.idx = 2 --normal
    --p.index = self.selectjingmai
    --require "manager.luaprotocolmanager":send(p)
end
--function JingMaiXuanZe:HandleClick(arg)
--    self.DestroyDialog()
--    require "logic.item.fabao.JingMaiXuanZe1".getInstanceAndShow()
--
--end


function JingMaiXuanZe.getInstance()
    if not _instance then
        _instance = JingMaiXuanZe:new()
        _instance:OnCreate()
    end
    return _instance
end

function JingMaiXuanZe.getInstanceAndShow()
    if not _instance then
        _instance = JingMaiXuanZe:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function JingMaiXuanZe.getInstanceNotCreate()
    return _instance
end

function JingMaiXuanZe.getInstanceOrNot()
    return _instance
end

function JingMaiXuanZe.GetLayoutFileName()
    return "jingmaixuanze.layout"
end

function JingMaiXuanZe:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingMaiXuanZe)
    self:ClearData()
    return self
end

function JingMaiXuanZe.DestroyDialog()
    if not _instance then
        return
    end
    if not _instance.m_bCloseIsHide then
        _instance:OnClose()
        _instance = nil
    else
        _instance:ToggleOpenClose()
    end
end
function JingMaiXuanZe.ToggleOpenClose()
    if not _instance then
        _instance = JingMaiXuanZe:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function JingMaiXuanZe:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function JingMaiXuanZe:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function JingMaiXuanZe:ClearCellAll()
end

function JingMaiXuanZe:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return JingMaiXuanZe

require "utils.mhsdutils"
require "logic.dialog"

require "utils.commonutil"

Guaji = {}
setmetatable(Guaji, Dialog)
Guaji.__index = Guaji
local _instance;

--//===============================
function Guaji:OnCreate()
    Dialog.OnCreate(self)
    SetPositionScreenCenter(self:GetWindow())
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.mianxuanze = CEGUI.toScrollablePane(winMgr:getWindow("guaji/xuanze"))
    self.labelLeftTime = winMgr:getWindow("guaji/huodongshijian/time") --19:09 jingjichangdiglog/huodongshijian/time
    local guajis = BeanConfigManager.getInstance():GetTableByName("npc.cnpcguaji"):getAllID()
    local index = 0
    self.maps={}
    local colCount = 5
    local rowCount = math.floor(#guajis/ colCount) + 5
    self.pageId=0
    local sz = self.mianxuanze:getPixelSize()
    local wndWidth = sz.width / colCount
    local wndHeight = 60
    self.listInfo = {}
    self.exchangeNum_st = winMgr:getWindow("guaji/jiemian/zhi3/zhi")
    self.exchangeNum_st:subscribeEvent("MouseClick", Guaji.handleStoneNumClicked, self)
    for _,id in pairs(guajis) do
        local info = {}
        local sID = tostring(index+1)
        info.lyout = winMgr:loadWindowLayout("guajicell.layout",sID);
        self.mianxuanze:addChildWindow(info.lyout)

        --self.maps[id] = CEGUI.toCheckbox(winMgr:getWindow("guaji/"..id))
        local guajia = BeanConfigManager.getInstance():GetTableByName("npc.cnpcguaji"):getRecorder(index+1)
        --self.maps[id]:setText(guajia.name)
        info.pButton = CEGUI.Window.toCheckbox(winMgr:getWindow(sID.."guajicell/guaji"))
        --info.pButton = CEGUI.toCheckbox(winMgr:createWindow("TaharezLook/Checkbox", "" .. index))
        info.pButton:setID(id)
        info.pButton:setText(guajia.name)
        info.pButton:setProperty("AllowModalStateClick", "True")
        info.pButton:setProperty("AlwaysOnTop", "True")
        info.pButton:setProperty("NormalTextColour", "FF693F00")
        info.pButton:setProperty("LuaForDialog", "True")
        info.pButton:setProperty("EnableSound", "True")
        info.pButton:setProperty("Font", "simhei-14")

        self.pageId = math.floor(index / (colCount*rowCount))

        local colId = math.floor(index % colCount)
        local rowId = math.floor(index / colCount)

        local xPos = colId * wndWidth
        local yPos =(rowId % rowCount) * wndHeight +30

        xPos = xPos + self.pageId * sz.width -30

        local offsetX = info.pButton:getPixelSize().width/2;
        info.lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPos - offsetX + 40), CEGUI.UDim(0, yPos + 5)))
        table.insert(self.listInfo,info.pButton)
        index=index+1
    end


    --self.btnShowMyInfoOnly:subscribeEvent("CheckStateChanged", Guaji.clickShowMyInfoOnly, self)
    self.btnBeginPipei = CEGUI.toPushButton(winMgr:getWindow("guaji/pipei"))
    self.btnBeginPipei:subscribeEvent("MouseButtonUp", Guaji.clickBeginPipei, self)
    self.btnBeginPipei:setRiseOnClickEnabled(false)
    self.leixijng=0
    self.labelLeftTimeTitle = winMgr:getWindow("guaji/huodongshijian/tishiyu")

    self.labelBegin = winMgr:getWindow("guaji/tiaozhan")

    self.exchangeNum_st:setText(MoneyFormat(0))

    --self.a2:setText(guajis.type2)
    --self.a3:setText(guajis.type3)
    --self.a4:setText(guajis.type4)
    --self.a5:setText(guajis.type5)
    --self.a1:setProperty("Text",guajis.type1)
    --self.a2:setProperty("Text",guajis.type2)
    --self.a3:setProperty("Text",guajis.type3)
    --self.a4:setProperty("Text",guajis.type4)
    --self.a5:setProperty("Text",guajis.type5)
    self.fRefreshLeftDt = 0
    self:GetWindow():subscribeEvent("WindowUpdate", Guaji.HandleWindowUpate, self)
end
function Guaji:handleStoneNumClicked(args)
    if NumKeyboardDlg.getInstanceNotCreate() then
        NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --保持键盘在最上面
        return
    end

    local dlg = NumKeyboardDlg.getInstanceAndShow(self:GetWindow())
    if dlg then
        dlg:setTriggerBtn(self.exchangeNum_st)
        dlg:setMaxValue(tonumber(1000))
        dlg:setInputChangeCallFunc(Guaji.onNumInputChanged, self)

        local p = self.exchangeNum_st:GetScreenPos()
        SetPositionOffset(dlg:GetWindow(), p.x-self.exchangeNum_st:getPixelSize().width*0.5+400, p.y-10+200, 0.5, 1)
    end
end
function Guaji:onNumInputChanged(num)
    self.exchangeNum_st:setText(MoneyFormat(num))
end
function Guaji:HandleWindowUpate(args)
    local ue = CEGUI.toUpdateEventArgs(args)
    local fdt = ue.d_timeSinceLastFrame  --??
    local vecID = gGetDataManager():GetAllTitleID()
    local num = #vecID
    local time=0
    for i=1,num,1 do
        if 708 == vecID[i] then
            time= gGetDataManager():getTitleTime(vecID[i])
        elseif 705 == vecID[i] then
            time= gGetDataManager():getTitleTime(vecID[i])
        elseif 706 == vecID[i] then
            time= gGetDataManager():getTitleTime(vecID[i])
        elseif 707 == vecID[i] then
            time= -1
        end
    end
    local currentTimestamp = os.time()
    if time~=-1 and time-currentTimestamp>0 then
        self.labelLeftTime:setText(tostring(math.floor(time/1000)-currentTimestamp))
    elseif time==-1 then
        self.labelLeftTime:setText(tostring(88888888))
    elseif time-currentTimestamp<0 then
        self.labelLeftTime:setText(tostring(0))
    end
    --self.refreshLeftTime(time)

end

function Guaji:refreshLeftTime(disTime)
    --计算倒计时时间
    local hour = math.floor(disTime / 3600)
    local strhour = ""

    if hour < 10 then
        strhour = "0"..tostring(hour)
    else
        strhour = tostring(hour)
    end
    local min = math.floor((disTime - hour * 3600) / 60)
    local strmin = ""
    if min < 10 then
        strmin = "0"..tostring(min)
    else
        strmin = tostring(min)
    end

    local sec = math.floor((disTime - hour * 3600 -  min * 60))
    local strsec = ""
    if sec < 10 then
        strsec = "0"..tostring(sec)
    else
        strsec = tostring(sec)
    end
    self.labelLeftTime:setText(tostring(strhour..":"..strmin..":"..strsec))
end
function Guaji:sendReady(nReady,leixing)
    local p = require "logic.guaji.cguaji":new()
    p.ready = nReady
    for index=1,#leixing do
        p.leixing[index]=leixing[index]
    end
    p.cishu = tonumber(self.exchangeNum_st:getText())
    require "manager.luaprotocolmanager":send(p)
end

function Guaji:clickBeginPipei(arg)
    local guajis = BeanConfigManager.getInstance():GetTableByName("npc.cnpcguaji"):getAllID()
    local gouxuanTable = {}
    local index = 1
    for _, id in pairs(guajis) do
        if self.listInfo[id]:isSelected() then
            gouxuanTable[index]=id
            index=index+1
        end
    end

    local vecID = gGetDataManager():GetAllTitleID()
    local num = #vecID
    local panduan = 0
    for i=1,num,1 do
        if 705 == vecID[i] or 706 == vecID[i] or 707 == vecID[i] or 708 == vecID[i]  then
            panduan = 1
        end
    end
    if panduan ~= 1 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201031))
        return
    end
    local bLeader = GetMainCharacter():IsTeamLeader()
    if not bLeader then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201032))
        return
    end
    if #gouxuanTable==0 then
        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201028))
        return
    end
    --if mapid==3022 or mapid==3023 or mapid==2851 or mapid==2852 or mapid==2853 or mapid==2854 or mapid==2855 or mapid==2856 or mapid==2857 or mapid==2858 or mapid==2859 then
    --    if self.a3:isSelected()==true or self.a4:isSelected()==true or self.a5:isSelected()==true then
    --        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201030))
    --        return
    --    end
    --end
    --if mapid==2860  then
    --    if self.a1:isSelected()==true or self.a2:isSelected()==true then
    --        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201030))
    --        return
    --    end
    --end
    --if mapid==3022 or mapid==3023 or mapid==2860  then
    --    if self.a2:isSelected()==true then
    --        GetCTipsManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(201030))
    --        return
    --    end
    --end
    self:sendReady(10086,gouxuanTable)
    self.ToggleOpenClose()
    --end
end
--//=========================================
function Guaji.getInstance()
    if not _instance then
        _instance = Guaji:new()
        _instance:OnCreate()
    end
    return _instance
end

function Guaji.getInstanceAndShow()
    if not _instance then
        _instance = Guaji:new()
        _instance:OnCreate()
    else
        _instance:SetVisible(true)
    end
    return _instance
end

function Guaji.getInstanceNotCreate()
    return _instance
end

function Guaji.getInstanceOrNot()
    return _instance
end

function Guaji.GetLayoutFileName()
    return "guaji.layout"
end

function Guaji:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Guaji)
    self:ClearData()
    return self
end

function Guaji.DestroyDialog()
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
function Guaji.ToggleOpenClose()
    if not _instance then
        _instance = Guaji:new()
        _instance:OnCreate()
    else
        if _instance:IsVisible() then
            _instance:SetVisible(false)
        else
            _instance:SetVisible(true)
        end
    end
end

function Guaji:ClearData()
    self.nItemCellSelId = 0
    self.ScrollEquip = {}
    self.bLoadUI = false
    self.fRefreshLeftDt = 0
    self.vItemCellHero = {}
end

--[[
function Guaji:ClearDataInClose()
	self.nItemCellSelId = 0
	self.ScrollEquip = nil
	self.bLoadUI = false
end
--]]

function Guaji:ClearCellAll()
end

function Guaji:OnClose()
    Dialog.OnClose(self)
    _instance = nil
    --require("logic.jingji.jingjipipeidialog3").DestroyDialog()
end

return Guaji

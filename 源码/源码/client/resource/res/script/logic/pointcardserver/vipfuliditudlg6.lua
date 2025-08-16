require "logic.dialog"

vipfuliditudlg6 = {}
setmetatable(vipfuliditudlg6, Dialog)
vipfuliditudlg6.__index = vipfuliditudlg6

local _instance
local viplevel = gGetDataManager():GetVipLevel() --判断自身VIP等级
function vipfuliditudlg6.getInstance()
	if not _instance then
		_instance = vipfuliditudlg6:new()
		_instance:OnCreate()
	end
	return _instance
end

function vipfuliditudlg6.getInstanceAndShow()
	if not _instance then
		_instance = vipfuliditudlg6:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function vipfuliditudlg6.getInstanceNotCreate()
	return _instance
end

function vipfuliditudlg6.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function vipfuliditudlg6.ToggleOpenClose()
	if not _instance then
		_instance = vipfuliditudlg6:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function vipfuliditudlg6.GetLayoutFileName()
	return "vipzhuanshudiiia.layout"
end

function vipfuliditudlg6:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, vipfuliditudlg6)
	return self
end

function vipfuliditudlg6:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	

    	

    self.m_btnFanhui = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/fanhui"))
	self.m_btnVip1 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v1"))
	self.m_btnVip2 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v2"))
    self.m_btnVip3 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v3"))
    self.m_btnVip4 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v4"))
    self.m_btnVip5 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v5"))
    self.m_btnVip6 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v6"))
    self.m_btnVip7 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v7"))
    self.m_btnVip8 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v8"))
    self.m_btnVip9 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v9"))
    self.m_btnVip10 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v10"))	
    self.m_btnVip11 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v11"))	
	 self.m_btnVip12 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/v12"))	
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditua/back"))
	
	
	
    self.m_btnFanhui:subscribeEvent("Clicked", vipfuliditudlg6.handleQuitBtnClicked, self)
	  self.m_btnVip1:subscribeEvent("Clicked", vipfuliditudlg6.VIP1jinru, self)
	    self.m_btnVip2:subscribeEvent("Clicked", vipfuliditudlg6.VIP2jinru, self)
    self.m_btnVip3:subscribeEvent("Clicked", vipfuliditudlg6.VIP3jinru, self) 
    self.m_btnVip4:subscribeEvent("Clicked", vipfuliditudlg6.VIP4jinru, self)
	self.m_btnVip5:subscribeEvent("Clicked", vipfuliditudlg6.VIP5jinru, self)
	self.m_btnVip6:subscribeEvent("Clicked", vipfuliditudlg6.VIP6jinru, self)
	self.m_btnVip7:subscribeEvent("Clicked", vipfuliditudlg6.VIP7jinru, self)
	self.m_btnVip8:subscribeEvent("Clicked", vipfuliditudlg6.VIP8jinru, self)
	self.m_btnVip9:subscribeEvent("Clicked", vipfuliditudlg6.VIP9jinru, self)
	self.m_btnVip10:subscribeEvent("Clicked", vipfuliditudlg6.VIP10jinru, self)
	self.m_btnVip11:subscribeEvent("Clicked", vipfuliditudlg6.VIP11jinru, self)
	self.m_btnVip12:subscribeEvent("Clicked", vipfuliditudlg6.VIP12jinru, self)
	self.m_btnguanbi:subscribeEvent("Clicked", vipfuliditudlg6.handleQuitBtnClicked, self)

    --self:GetWindow():subscribeEvent("ZChanged", vipfuliditudlg6.handleZchange, self)
	--说明按钮
    
	
	
	
	
    self.m_text = winMgr:getWindow("vipzhuanshuditua/text")
    self.movingToFront = false
    self:refreshbtn()
end

function vipfuliditudlg6:refreshbtn()
    local funopenclosetype = require("protodef.rpcgen.fire.pb.funopenclosetype"):new()
    local manager = require "logic.pointcardserver.pointcardservermanager".getInstanceNotCreate()
    if manager then
        if manager.m_OpenFunctionList.info then
            for i,v in pairs(manager.m_OpenFunctionList.info) do
                if v.key == funopenclosetype.FUN_CHECKPOINT then
                    if v.state == 1 then
                        self.m_btnBuyOrSell:setVisible(false)
                        self.m_text:setText(MHSD_UTILS.get_resstring(11594))
                        break
                    end
                end
            end
        end
    end
end
function vipfuliditudlg6:handleZchange(e)
    if not self.movingToFront then
        self.movingToFront = true
        if self:GetWindow():getParent() then
            local drawList = self:GetWindow():getParent():getDrawList()
            if drawList:size() > 0 then
                local topWnd = drawList[drawList:size()-1]
                local wnd = tolua.cast(topWnd, "CEGUI::Window")
                if wnd:getName() == "NewsWarn" then
                    if drawList:size() > 2 then
                        local secondWnd = drawList[drawList:size()-1]
                        self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), tolua.cast(secondWnd, "CEGUI::Window"))
                    end
                else
                    self:GetWindow():getParent():bringWindowAbove(self:GetWindow(), tolua.cast(topWnd, "CEGUI::Window"))
                end
                
            end
        end
        self.movingToFront = false
    end
end
function vipfuliditudlg6:handleQuitBtnClicked(e)
if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function vipfuliditudlg6:VIP1jinru(e) --V3进入地图
 local dlg = require("logic.shengsizhan.jingmaihecheng_dt1").getInstanceAndShow()
	--local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()

end

function vipfuliditudlg6:VIP2jinru(e) --V3进入地图
local dlg = require("logic.shengsizhan.jingmaihecheng_df1").getInstanceAndShow()
	 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
 
 end

function vipfuliditudlg6:VIP3jinru(e) --V3进入地图
local dlg = require("logic.shengsizhan.jingmaihecheng_fc1").getInstanceAndShow()
		 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP4jinru(e) --V4进入地图
local dlg = require("logic.shengsizhan.jingmaihecheng_hs1").getInstanceAndShow()
		 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP5jinru(e) --V5进入地图
local dlg = require("logic.shengsizhan.jingmaihecheng_lg1").getInstanceAndShow()
		 --local dlg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP6jinru(e) --V6进入地图
local dmw = require("logic.shengsizhan.jingmaihecheng_mw1").getInstanceAndShow()
		 --local dmw = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP7jinru(e) --V7进入地图
local dne = require("logic.shengsizhan.jingmaihecheng_ne1").getInstanceAndShow()
		 --local dne = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP8jinru(e) --V8进入地图
local dpt = require("logic.shengsizhan.jingmaihecheng_pt1").getInstanceAndShow()
		 --local dpt = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP9jinru(e) --V9进入地图
local dst = require("logic.shengsizhan.jingmaihecheng_st1").getInstanceAndShow()
		 --local dst = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP10jinru(e) --V10进入地图
local dyg = require("logic.shengsizhan.jingmaihecheng_yg1").getInstanceAndShow()
		 --local dyg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
function vipfuliditudlg6:VIP11jinru(e) --V11进入地图
local dwz = require("logic.shengsizhan.jingmaihecheng_wz1").getInstanceAndShow()
		 --local dwz = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end
	 
	 function vipfuliditudlg6:VIP12jinru(e) --V11进入地图
local dtg = require("logic.shengsizhan.jingmaihecheng_tg1").getInstanceAndShow()
		 --local dtg = require("logic.pet.shenshouIncrease").getInstanceAndShow()
	 
	 end


function vipfuliditudlg6:Show()
    self:GetWindow():setVisible(true)
end
return vipfuliditudlg6
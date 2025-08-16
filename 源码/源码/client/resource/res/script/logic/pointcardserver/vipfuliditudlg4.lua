require "logic.dialog"

vipfuliditudlg4 = {}
setmetatable(vipfuliditudlg4, Dialog)
vipfuliditudlg4.__index = vipfuliditudlg4

local _instance
local viplevel = gGetDataManager():GetVipLevel() --判断自身VIP等级
function vipfuliditudlg4.getInstance()
	if not _instance then
		_instance = vipfuliditudlg4:new()
		_instance:OnCreate()
	end
	return _instance
end

function vipfuliditudlg4.getInstanceAndShow()
	if not _instance then
		_instance = vipfuliditudlg4:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function vipfuliditudlg4.getInstanceNotCreate()
	return _instance
end

function vipfuliditudlg4.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function vipfuliditudlg4.ToggleOpenClose()
	if not _instance then
		_instance = vipfuliditudlg4:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function vipfuliditudlg4.GetLayoutFileName()
	return "vipzhuanshudii.layout"
end

function vipfuliditudlg4:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, vipfuliditudlg4)
	return self
end

function vipfuliditudlg4:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.m_TipsButton = CEGUI.Window.toPushButton(winMgr:getWindow("vipzhuanshuditu/guanzhi/tips5"))
	self.m_TipsButton1 = CEGUI.Window.toPushButton(winMgr:getWindow("vipzhuanshuditu/tips4"))
	self.m_TipsButton2 = CEGUI.Window.toPushButton(winMgr:getWindow("vipzhuanshuditu/tips6"))
    	

    self.m_btnFanhui = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/fanhui"))
    self.m_btnVip3 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v3"))
    self.m_btnVip4 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v4"))
    self.m_btnVip5 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v5"))
    self.m_btnVip6 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v6"))
    self.m_btnVip7 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v7"))
    self.m_btnVip8 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v8"))
    self.m_btnVip9 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v9"))
    self.m_btnVip10 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v10"))	
    self.m_btnVip11 = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/v11"))	
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("vipzhuanshuditu/back"))
	
	
	
    self.m_btnFanhui:subscribeEvent("Clicked", vipfuliditudlg4.handleQuitBtnClicked, self)
    self.m_btnVip3:subscribeEvent("Clicked", vipfuliditudlg4.VIP3jinru, self) 
    self.m_btnVip4:subscribeEvent("Clicked", vipfuliditudlg4.VIP4jinru, self)
	self.m_btnVip5:subscribeEvent("Clicked", vipfuliditudlg4.VIP5jinru, self)
	self.m_btnVip6:subscribeEvent("Clicked", vipfuliditudlg4.VIP6jinru, self)
	self.m_btnVip7:subscribeEvent("Clicked", vipfuliditudlg4.VIP7jinru, self)
	self.m_btnVip8:subscribeEvent("Clicked", vipfuliditudlg4.VIP8jinru, self)
	self.m_btnVip9:subscribeEvent("Clicked", vipfuliditudlg4.VIP9jinru, self)
	self.m_btnVip10:subscribeEvent("Clicked", vipfuliditudlg4.VIP10jinru, self)
	self.m_btnVip11:subscribeEvent("Clicked", vipfuliditudlg4.VIP11jinru, self)
	self.m_btnguanbi:subscribeEvent("Clicked", vipfuliditudlg4.handleQuitBtnClicked, self)
	self.m_TipsButton:subscribeEvent("Clicked", vipfuliditudlg4.HandleTipsBtn, self)	
	self.m_TipsButton1:subscribeEvent("Clicked", vipfuliditudlg4.HandleTipsBtn1, self)	
	self.m_TipsButton2:subscribeEvent("Clicked", vipfuliditudlg4.HandleTipsBtn2, self)
    --self:GetWindow():subscribeEvent("ZChanged", vipfuliditudlg4.handleZchange, self)
	--说明按钮
    
	
	
	
	
    self.m_text = winMgr:getWindow("vipzhuanshuditu/text")
    self.movingToFront = false
    self:refreshbtn()
end
function vipfuliditudlg4:HandleTipsBtn()
if gGetDataManager():GetMainCharacterLevel() >= 1 then
       local dlg = require "logic.shengsizhan.jingmaitipsss".getInstance()
    else
        local msg = require "utils.mhsdutils".get_msgtipstring(150096)
        msg = string.gsub(msg, "%$parameter1%$", "1")
        GetCTipsManager():AddMessageTip(msg)
    end
end
function vipfuliditudlg4:HandleTipsBtn1()

    local dlg = require "logic.shengsizhan.jingmaitipssss".getInstance()

    if dlg then
        dlg.getInstanceAndShow()
        dlg:RefreshData(self.m_OldSchoolList, self.m_OldClassList)
    end

end
function vipfuliditudlg4:HandleTipsBtn2()
require("logic.shengsizhan.jingmaihecheng_ygg3").getInstanceAndShow()
end
function vipfuliditudlg4:refreshbtn()
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
function vipfuliditudlg4:handleZchange(e)
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
function vipfuliditudlg4:handleQuitBtnClicked(e)
if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function vipfuliditudlg4:VIP3jinru(e) --V3进入地图

   if viplevel <= 2 then--判断自身VIP等级小于等于2时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为3时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(9019, 50, 50));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP4jinru(e) --V4进入地图

   if viplevel <= 0 then---判断自身VIP等级小于等于3时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为4时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(9041, 50, 50));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP5jinru(e) --V5进入地图

   if viplevel <= 4 then--判断自身VIP等级小于等于4时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 5 then--判断自身VIP等级为5时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(6002, 50, 50));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP6jinru(e) --V6进入地图

   if viplevel <= 5 then--判断自身VIP等级小于等于5时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为6时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(9043, 33, 99));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP7jinru(e) --V7进入地图

   if viplevel <= 0 then--判断自身VIP等级小于等于6时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为7时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(9014, 101, 121));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP8jinru(e) --V8进入地图

   if viplevel <= 0 then--判断自身VIP等级小于等于7时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为8时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(9015, 50, 50));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP9jinru(e) --V9进入地图

   if viplevel <= 0 then--判断自身VIP等级小于等于8时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为9时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(9017, 50, 50));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP10jinru(e) --V10进入地图

   if viplevel <= 0 then--判断自身VIP等级小于等于9时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201079)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为10时 传送至某地图坐标----------------------家园
    gGetNetConnection():send(fire.pb.mission.CReqGoto(6666, 40, 76));
	GetChatManager():AddTipsMsg(201076)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end
function vipfuliditudlg4:VIP11jinru(e) --V11进入地图

   if viplevel <= 0 then--判断自身VIP等级小于等于10时 提示VIP等级不足
      GetChatManager():AddTipsMsg(201068)
    end
	
	if viplevel >= 0 then--判断自身VIP等级为11时 传送至某地图坐标
    gGetNetConnection():send(fire.pb.mission.CReqGoto(9018, 50, 50));
	GetChatManager():AddTipsMsg(201068)
    end
vipfuliditudlg4:handleQuitBtnClicked(e)
end


function vipfuliditudlg4:Show()
    self:GetWindow():setVisible(true)
end
return vipfuliditudlg4
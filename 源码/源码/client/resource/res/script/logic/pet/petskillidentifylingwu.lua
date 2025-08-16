------------------------------------------------------------------
-- ���﷨����֤
------------------------------------------------------------------
require "logic.dialog"
require "logic.costconfirmbox"
require "logic.pet.petskillidentifyyiwang"
PetSkillIdentifyLingWu = {}
setmetatable(PetSkillIdentifyLingWu, Dialog)
PetSkillIdentifyLingWu.__index = PetSkillIdentifyLingWu
local petDatadump
local skillneddmoney
local skillnedditem
local _instance
function PetSkillIdentifyLingWu.getInstance()
	if not _instance then
		_instance = PetSkillIdentifyLingWu:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetSkillIdentifyLingWu.getInstanceAndShow()
	if not _instance then
		_instance = PetSkillIdentifyLingWu:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetSkillIdentifyLingWu.getInstanceNotCreate()
	return _instance
end

function PetSkillIdentifyLingWu.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetSkillIdentifyLingWu.ToggleOpenClose()
	if not _instance then
		_instance = PetSkillIdentifyLingWu:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetSkillIdentifyLingWu.GetLayoutFileName()
	return "petfashurenlingwu_mtg.layout"
end

function PetSkillIdentifyLingWu:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetSkillIdentifyLingWu)
	return self
end

function PetSkillIdentifyLingWu:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self:GetWindow():setRiseOnClickEnabled(false)

	self.scroll = CEGUI.toScrollablePane(winMgr:getWindow("petfashurenzheng_mtg/bg/text2bg/scroll"))
	self.identifyBtn = CEGUI.toPushButton(winMgr:getWindow("petfashurenzheng_mtg/bg/btnxuanze"))
	self.lingwuBtn = CEGUI.toPushButton(winMgr:getWindow("petfashurenzheng_mtg/bg/lingwu"))
	self.yiwangBtn = CEGUI.toPushButton(winMgr:getWindow("petfashurenzheng_mtg/bg/yiwang"))
	self.costMoney = winMgr:getWindow("petfashurenzheng_mtg/bg/textbg/textzhi")
	self.ownMoney = winMgr:getWindow("petfashurenzheng_mtg/bg/textbg/textzhi1")
	self.needitem = CEGUI.Window.toItemCell(winMgr:getWindow("petfashurenzheng_mtg/bg/needitem")) 
	-- self.identifyText = winMgr:getWindow("petfashurenzheng_mtg/bg/textqingxuanze")
	-- self.nonIdentifyText = winMgr:getWindow("petfashurenzheng_mtg/bg/nonidentifytext")

	self.identifyBtn:subscribeEvent("Clicked", PetSkillIdentifyLingWu.handleIdentifyClicked, self)
	self.lingwuBtn:subscribeEvent("Clicked", PetSkillIdentifyLingWu.handlelingwuClicked, self)
	self.yiwangBtn:subscribeEvent("Clicked", PetSkillIdentifyLingWu.handleyiwangClicked, self)
	
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	self.ownMoney:setText(MoneyFormat(roleItemManager:GetPackMoney()))
end

function PetSkillIdentifyLingWu:setIsIdentifyViewOrNot(isIdentify)
	self.viewType = (isIdentify and 1 or 0)
	-- self.identifyText:setVisible(isIdentify)
	-- self.nonIdentifyText:setVisible(not isIdentify)
	if not isIdentify then
		self.identifyBtn:setText(MHSD_UTILS.get_resstring(11120)) --ȡ����֤
		self:GetWindow():setText(MHSD_UTILS.get_resstring(11806))
	end
end

function PetSkillIdentifyLingWu:setPetData(petData)
	petDatadump = petData
	if not petData then
		return
	end
	self.petData = petData
	self:setIsIdentifyViewOrNot( petData:getIdentifiedSkill()==nil and true or false )
	local num = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getSize()
	local lingwuallskill
	local n = 0
	for i=1, num do
		local skill = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(i)
		local cell = self:createCell(skill)
			self.scroll:addChildWindow(cell.window)
			SetPositionOffset(cell.window, 8, 5+(cell.window:getPixelSize().height+5)*n)
			if n==0 then
				self.lastSelectedBtn = cell.window
                self.lastSelectedBtn:setSelected(true)
			end
			n = n+1
	end
	-- local num = self.petData:getSkilllistlen()
	-- local n = 0
	-- for i=1, num do
	-- 	local skill = self.petData:getSkill(i)
	-- 	local upgradeConfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillupgrade"):getRecorder(skill.skillid)
	-- 	if (self.viewType == 1 and upgradeConfig.iscancertification == 1) or (self.viewType == 0 and skill.certification ~= 1) then
	-- 		local cell = self:createCell(skill)
	-- 		self.scroll:addChildWindow(cell.window)
	-- 		SetPositionOffset(cell.window, 8, 5+(cell.window:getPixelSize().height+5)*n)
	-- 		if n==0 then
	-- 			self.lastSelectedBtn = cell.window
    --             self.lastSelectedBtn:setSelected(true)
	-- 		end
	-- 		n = n+1
	-- 	end
	-- end
	
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if conf then
        local price = (self.viewType==1 and conf.certificationcost or conf.cancelcertificationcost)
	    self.costMoney:setText(MoneyFormat(0))
        if price > MoneyNumber(self.ownMoney:getText()) then
            self.costMoney:setProperty("BorderEnable", "True")
        end
    end
end
function PetSkillIdentifyLingWu:handlelingwuClicked(args)

end
function PetSkillIdentifyLingWu:handleyiwangClicked(args)
	-- local dlg = PetSkillIdentifyYiWang.getInstanceNotCreate()
	-- if not dlg or not dlg:IsVisible() then
	-- 	dlg = PetSkillIdentifyYiWang.getInstanceAndShow()
	-- 	dlg:setPetData(petDatadump)
	-- end
	-- PetSkillIdentifyLingWu.DestroyDialog()
end
function PetSkillIdentifyLingWu:createCell(skill)
	local cell = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefix = tostring(skill.skillid)
	cell.window = CEGUI.toGroupButton(winMgr:loadWindowLayout("petskillhuishoucell_mtg.layout", prefix))
	cell.skillBox = CEGUI.toSkillBox(winMgr:getWindow(prefix .. "petskillhuishoucell_mtg/item"))
	cell.name = winMgr:getWindow(prefix .. "petskillhuishoucell_mtg/name")
	cell.window:EnableClickAni(false)
	--[[local skillexpiretime = self.petData:getPetSkillExpires(skill.skillid)
	SkillBoxControl.SetSkillInfo(cell.skillBox, skill.skillid, skillexpiretime)
	cell.skillBox:SetBackgroundDynamic(true)--]]
	SetPetSkillBoxInfo(cell.skillBox, skill.skillid, self.petData)
	cell.name:setText(skill.skillname)
	
	cell.window:setID(skill.skillid)
	cell.window:setID2(skill.id)
	cell.skillBox:subscribeEvent("MouseClick", PetSkillIdentifyLingWu.handleSkillClicked, self)
	cell.window:subscribeEvent("SelectStateChanged", PetSkillIdentifyLingWu.handleCellClicked, self)
	
	return cell
end

function PetSkillIdentifyLingWu:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local wnd = CEGUI.toWindowEventArgs(args).window
	--local idx = cell:GetIndex()
	--self.needitem:SetImage(iconManager:GetItemIconByID(record.imgid))
	local tip = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local pos = cell:GetScreenPos()
	SetPositionOffset(tip:GetWindow(), pos.x+100, pos.y)
end

function PetSkillIdentifyLingWu:handleCellClicked(args)
	local wnd = CEGUI.toWindowEventArgs(args).window
	local idx = wnd:getID2()
	
	local skillitem = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).addneeditem
	local skillitemnum = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).addneeditemnum
	
    skillneddmoney = BeanConfigManager.getInstance():GetTableByName("skill.CPetSkilllw"):getRecorder(idx).addneedmoney
	local washitem = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(skillitem)
	skillnedditem = skillitemnum.."个"..washitem.name
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local curItemNum = roleItemManager:GetItemNumByBaseID(skillitem)
	local skillnedditema = curItemNum.."个"..washitem.name
	self.costMoney:setText(skillnedditem)
	self.ownMoney:setText(skillnedditema)
	local img = gGetIconManager():GetImageByID(washitem.icon)
	self.needitem:SetImage(img)
	if self.lastSelectedBtn == wnd then
		return
	end
	self.lastSelectedBtn = wnd
end

function PetSkillIdentifyLingWu:handleConfirmIdentify()
	local p = require("protodef.fire.pb.pet.cpetskillcertificationlingwu").Create()
	p.petkey = self.petData.key
	p.skillid = self.lastSelectedBtn:getID()
	p.isconfirm = self.viewType

    -- local price = MoneyNumber(self.costMoney:getText())
    -- local needMoney = price - MoneyNumber(self.ownMoney:getText())
	-- if needMoney > 0 then
	-- 	--GET MONEY
	-- 	CurrencyManager.handleCurrencyNotEnough(fire.pb.game.MoneyType.MoneyType_SilverCoin, needMoney, price, p)
	-- else
		
	-- end
	LuaProtocolManager:send(p)
	self.DestroyDialog()
end

function PetSkillIdentifyLingWu:handleIdentifyClicked(args)
	if not self.petData or not self.lastSelectedBtn or not self.viewType then
        GetCTipsManager():AddMessageTipById(150067) --��Ҫѡ��һ�����ܽ�����֤
		return
	end

    --[[if GetBattleManager():IsInBattle() then
		GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲�����
        return
    end--]]
    if GetBattleManager():IsInBattle() then    
	    if self.petData.key == gGetDataManager():GetBattlePetID() then
		    GetCTipsManager():AddMessageTipById(131451) --ս���в��ܽ��д˲���
		    return
	    end
    end
	
	local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(self.petData.baseid)
    if not conf then return end
	if self.viewType == 1 then 	--��֤
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.petData.name)
		sb:Set("parameter2", self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		sb:Set("parameter3", SkillBoxControl.GetSkillNamebyID(self.lastSelectedBtn:getID()))
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(191234))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(11709)
		local num =skillnedditem
		CostConfirmBox.show(msg, des, num, PetSkillIdentifyLingWu.handleConfirmIdentify, self, PetSkillIdentifyLingWu.DestroyDialog)

	elseif self.viewType == 0 then	--ȡ����֤
		local skill = self.petData:getIdentifiedSkill()
		local sb = StringBuilder:new()
		sb:Set("parameter1", self.petData.name)
		sb:Set("parameter2", self.petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
		sb:Set("parameter3", SkillBoxControl.GetSkillNamebyID(skill.skillid))
		sb:Set("parameter4", SkillBoxControl.GetSkillNamebyID(self.lastSelectedBtn:getID()))
		local msg = sb:GetString(MHSD_UTILS.get_msgtipstring(191234))
        sb:delete()
		local des = MHSD_UTILS.get_resstring(11710)
		local num = skillnedditem
		CostConfirmBox.show(msg, des, num, PetSkillIdentifyLingWu.handleConfirmIdentify, self, PetSkillIdentifyLingWu.DestroyDialog)
	end
	self:SetVisible(false)
end

return PetSkillIdentifyLingWu

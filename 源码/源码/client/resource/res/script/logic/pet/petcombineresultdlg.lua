------------------------------------------------------------------
-- 宠物合成结果
------------------------------------------------------------------
require "logic.dialog"

local RANDOM_ACT = {
eActionRun,
eActionAttack,
eActionMagic1
}

PetCombineResultDlg = {}
setmetatable(PetCombineResultDlg, Dialog)
PetCombineResultDlg.__index = PetCombineResultDlg

local _instance
function PetCombineResultDlg.getInstance()
	if not _instance then
		_instance = PetCombineResultDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetCombineResultDlg.getInstanceAndShow()
	if not _instance then
		_instance = PetCombineResultDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function PetCombineResultDlg.getInstanceNotCreate()
	return _instance
end

function PetCombineResultDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function PetCombineResultDlg.ToggleOpenClose()
	if not _instance then
		_instance = PetCombineResultDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetCombineResultDlg.GetLayoutFileName()
	return "petpropertyjieguo_mtg.layout"
end

function PetCombineResultDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetCombineResultDlg)
	return self
end

function PetCombineResultDlg:OnCreate()
	Dialog.OnCreate(self)
	SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self.skillScroll = CEGUI.toScrollablePane(winMgr:getWindow("petpropertyjieguo_mtg/skillScroll"))
	self.tizi = winMgr:getWindow("petpropertyjieguo_mtg/tilizhi")
	self.suzi = winMgr:getWindow("petpropertyjieguo_mtg/suduzhi")
	self.gongzi = winMgr:getWindow("petpropertyjieguo_mtg/gongjizhi")
	self.fazi = winMgr:getWindow("petpropertyjieguo_mtg/falizhi")
	self.fangzi = winMgr:getWindow("petpropertyjieguo_mtg/fangyuzhi")
	self.grow = winMgr:getWindow("petpropertyjieguo_mtg/chongwuzhi")
	self.closeBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyjieguo_mtg/text2bg/btnguanbi"))
	self.detailBtn = CEGUI.toPushButton(winMgr:getWindow("petpropertyjieguo_mtg/text2bg/btnguanbi1"))
	self.profileIcon = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/diwen/texiao")
	self.nameText = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/title3/texthechong")
	self.levelText = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/diwen/lv")
	self.scoreText = winMgr:getWindow("petpropertyjieguo_mtg/text1bg/diwen/textpingf2")
	
	self.closeBtn:subscribeEvent("Clicked", PetCombineResultDlg.DestroyDialog, self)
	self.detailBtn:subscribeEvent("Clicked", PetCombineResultDlg.handleDetailClicked, self)
	
	self.skillBoxes = {}
	for i=1,24 do
		self.skillBoxes[i] = CEGUI.toSkillBox(winMgr:getWindow("petpropertyjieguo_mtg/Skill" .. i))
		self.skillBoxes[i]:subscribeEvent("MouseClick", PetCombineResultDlg.handleSkillClicked, self)
        self.skillBoxes[i]:SetBackGroupOnTop(true)
	end
	self.skillScroll:EnableAllChildDrag(self.skillScroll)
	
end

function PetCombineResultDlg:setPetData(petData)
	self.petData = petData
	
	--profile
	local s = self.profileIcon:getPixelSize()
	self.sprite = gGetGameUIManager():AddWindowSprite(self.profileIcon, petData.shape, Nuclear.XPDIR_BOTTOMRIGHT, s.width*0.5, s.height*0.5+50, false)
	self.elapse = 0
	self.defaultActCurTimes = 0
	self.defaultActRepeatTimes = 3
	self.actType = eActionStand
	
	--base info
	self.nameText:setText(petData.name)
    --self.nameText:setProperty("TextColours", GetPetNameColour(petData.baseid))
	self.nameText:setProperty("TextColours", "ff553923")
	self.scoreText:setText(petData.score)
	self.levelText:setText(''..petData:getAttribute(fire.pb.attr.AttrType.LEVEL))
	
	--attribute
	local curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_ATTACK_APT)
	self.gongzi:setText(curVal)
	
	curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_DEFEND_APT)
	self.fangzi:setText(curVal)
	
	curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_PHYFORCE_APT)
	self.tizi:setText(curVal)
	
	curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_MAGIC_APT)
	self.fazi:setText(curVal)
	
	curVal = petData:getAttribute(fire.pb.attr.AttrType.PET_SPEED_APT)
	self.suzi:setText(curVal)
	
	curVal = math.floor(petData.growrate*1000) / 1000
	self.grow:setText(curVal)
	
    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(petData.baseid)
    if self.sprite and petAttr then
        if petData and petData.petdye1 ~= 0 then
            self.sprite:SetDyePartIndex(0,petData.petdye1)
        else
            self.sprite:SetDyePartIndex(0,petAttr.area1colour)
        end
        if petData and petData.petdye2 ~= 0 then
            self.sprite:SetDyePartIndex(1,petData.petdye2)
        else
            self.sprite:SetDyePartIndex(1,petAttr.area2colour)
        end
    end

	--skill
	local skillnum = petData:getSkilllistlen()
	for i = 1, 24 do
		self.skillBoxes[i]:Clear()
		if i <= skillnum then
			local skill = petData:getSkill(i)
			SetPetSkillBoxInfo(self.skillBoxes[i], skill.skillid, petData, true)
			
			--[[local skillexpiretime = petData:getPetSkillExpires(skill.skillid)
			SkillBoxControl.SetSkillInfo(self.skillBoxes[i], skill.skillid, skillexpiretime)
			self.skillBoxes[i]:SetBackgroundDynamic(true)
			local skillconfig = BeanConfigManager.getInstance():GetTableByName("skill.cpetskillconfig"):getRecorder(skill.skillid)
			self.skillBoxes[i]:setID(0)--]]
		end
	end
end

function PetCombineResultDlg:handleDetailClicked(args)
	PetCombineResultDlg.DestroyDialog()
	PetLabel.Show(1)
end

function PetCombineResultDlg:handleSkillClicked(args)
	local cell = CEGUI.toSkillBox(CEGUI.toWindowEventArgs(args).window)
	if cell:GetSkillID() == 0 then
		return
	end
	local dlg = PetSkillTipsDlg.ShowTip(cell:GetSkillID())
	local s = GetScreenSize()
	SetPositionOffset(dlg:GetWindow(), s.width*0.5, s.height*0.5, 1, 0.5)
end

function PetCombineResultDlg:update(dt)
	if not self.sprite then
		return
	end
	self.elapse = self.elapse+dt
	if self.elapse >= self.sprite:GetCurActDuration() then
		self.elapse = 0
		if self.actType == eActionStand then
			self.defaultActCurTimes = self.defaultActCurTimes+1
			if self.defaultActCurTimes == self.defaultActRepeatTimes then
				self.defaultActCurTimes = 0
				local idx = math.random(1, #RANDOM_ACT)
				self.actType = RANDOM_ACT[idx]
				self.sprite:PlayAction(self.actType)
			end
		else
			self.actType = eActionStand
			self.sprite:PlayAction(self.actType)
		end
	end
end

return PetCombineResultDlg

------------------------------------------------------------------
-- NPC宠物商店cell
------------------------------------------------------------------
NpcPetShopCell = {}

setmetatable(NpcPetShopCell, Dialog)
NpcPetShopCell.__index = NpcPetShopCell
local prefix = 0

function NpcPetShopCell.CreateNewDlg(parent)
	local newDlg = NpcPetShopCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function NpcPetShopCell.GetLayoutFileName()
	return "chongwushangdiancell.layout"
end

function NpcPetShopCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NpcPetShopCell)
	return self
end

function NpcPetShopCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

    self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "chongwushangdiancell/di"))
	self.nameText = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/mingchen/name")
	self.priceText = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/diwen/wenzidi/shuzikuang")
	self.cornerImg = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/diwen/xuqiu")
	self.profileBg = winMgr:getWindow(prefixstr .. "chongwushangdiancell/di/diwen/moxing")

    self.window:EnableClickAni(false)
    self.cornerImg:setVisible(false)
end

function NpcPetShopCell:setGoodsDataById(goodsid)
    local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
	if not conf then
        self.window:setID(0)
        self.nameText:setText("Error")
		return
	end

    self.window:setID(goodsid)
	self.nameText:setProperty("TextColours", "FF50321A")--宠物名字颜色
 --   self.nameText:setProperty("TextColours", "FFFFFFFF")
    self.nameText:setText(GetGoodsNameByItemId(conf.type, conf.itemId))
	self.priceText:setText(MoneyFormat(conf.prices[0]))

    local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.itemId)
    if petAttr then
        if not self.sprite then
            local s = self.profileBg:getPixelSize()
            self.sprite = gGetGameUIManager():AddWindowSprite(self.profileBg, petAttr.modelid, Nuclear.XPDIR_BOTTOMRIGHT, s.width * 0.5, s.height * 0.5 + 80, true)
        elseif self.sprite:GetModelID() ~= petAttr.modelid then
            self.sprite:SetModel(petAttr.modelid)
            self.sprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT)
        end
    end
end

return NpcPetShopCell
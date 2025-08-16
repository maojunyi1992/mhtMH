------------------------------------------------------------------
-- ��Ʒcell
------------------------------------------------------------------
GoodsCell = {
	CORNER_IMG_NEW	= 1,	--��Ʒ
	CORNER_IMG_HOT	= 2,	--����
	CORNER_IMG_EMP	= 3		--����
}

setmetatable(GoodsCell, Dialog)
GoodsCell.__index = GoodsCell
local prefix = 0

function GoodsCell.CreateNewDlg(parent)
	local newDlg = GoodsCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function GoodsCell.GetLayoutFileName()
	return "npcshopcell_mtg.layout"
end

function GoodsCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, GoodsCell)
	return self
end

function GoodsCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "npcshopcell_mtg"))
	self.itemCell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "npcshopcell_mtg/itemcell"))
	self.itemName = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textname")
	self.itemNamec = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textname1")
	self.priceText = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textnumber")
	self.currencyIcon = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/textnumber/yinbi")
	self.zhekouBg = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/imagejiangjia")
	self.zhekouValue = winMgr:getWindow(prefixstr .. "npcshopcell_mtg/imagejiangjia/text6")

	self.window:EnableClickAni(false)
end

function GoodsCell:getMallShopLimitNumByVIP()
    local vipLevel = gGetDataManager():GetVipLevel()
    local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
    if record then
        return record.limitnumber1
    end
    return 0
end

function GoodsCell:setGoodsDataById(goodsid)
	self.goodsid = goodsid
	
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
	if not conf then
		return
	end
	

	
	
	self.itemName:setText(GetGoodsNameByItemId(conf.type, conf.itemId))
	self.priceText:setText(MoneyFormat(conf.prices[0]))

	if conf.oldprices[0] and conf.oldprices[0] ~= conf.prices[0] then
		self.zhekouBg:setVisible(true)
		self.zhekouValue:setText(math.floor(conf.prices[0]/conf.oldprices[0]*100)*0.1)
	else
		self.zhekouBg:setVisible(false)
	end
	
	CurrencyManager.setCurrencyIcon(conf.currencys[0], self.currencyIcon)
	
	if conf.type == 1 then --item
		local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.itemId)
		if not item then
			return
		end
        self.itemCell:SetStyle(CEGUI.ItemCellStyle_IconInside)
		self.itemCell:SetImage( gGetIconManager():GetImageByID(item.icon))
        self.itemCell:setID(conf.itemId)
        SetItemCellBoundColorByQulityItem(self.itemCell, item.nquality, item.itemtypeid)

		local mallConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmallshop")):getRecorder(goodsid)
		if mallConf then
			local buyNum = ShopManager.goodsBuyNumLimit[goodsid]
            local maxAddNum = 0
            if conf.limitType == 2 then
                maxAddNum = self:getMallShopLimitNumByVIP()
            end
			if buyNum and conf.limitNum > 0 and buyNum >= conf.limitNum + maxAddNum then --�ۿ�
				self:setCornerImage(GoodsCell.CORNER_IMG_EMP)
		
			elseif mallConf.cuxiaotype == 1 then --��Ʒ
				self:setCornerImage(GoodsCell.CORNER_IMG_NEW)
		
			elseif mallConf.cuxiaotype == 2 then --����
				self:setCornerImage(GoodsCell.CORNER_IMG_HOT)
		
			else
				self:setCornerImage(nil)
			end
			self.itemNamec:setText(mallConf.des)
		end

	elseif conf.type == 2 then --pet
		local petAttr = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(conf.itemId)
        if petAttr then
		    local shapeData = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(petAttr.modelid)
		    local image = gGetIconManager():GetImageByID(shapeData.littleheadID)
            self.itemCell:SetStyle(CEGUI.ItemCellStyle_IconExtend)
		    self.itemCell:SetImage(image)
            SetItemCellBoundColorByQulityPet(self.itemCell, petAttr.quality)
        end
	end
end

function GoodsCell:setCornerImage(t)
	self.cornerImgType = t
	if not t then
		self.itemCell:SetCornerImageAtPos(nil, 0, 1)
	end
	if t == GoodsCell.CORNER_IMG_NEW then
		self.itemCell:SetCornerImageAtPos("shopui", "shop_xinpin", 0, 1)
	elseif t == GoodsCell.CORNER_IMG_HOT then
		self.itemCell:SetCornerImageAtPos("shopui", "shop_remai", 0, 1)
	elseif t == GoodsCell.CORNER_IMG_EMP then
		self.itemCell:SetCornerImageAtPos("shopui", "shop_shoukong", 0, 1)
	end
end

function GoodsCell:showRequireCornerImage(willShow)
	if willShow then
		self.itemCell:SetCornerImageAtPos("shopui", "shop_xuqiu", 0, 1)
	else
		self:setCornerImage(self.cornerImgType) --��ԭ
	end
end

return GoodsCell

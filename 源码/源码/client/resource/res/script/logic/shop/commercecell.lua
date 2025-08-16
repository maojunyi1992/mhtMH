------------------------------------------------------------------
-- 商会商品cell
------------------------------------------------------------------
CommerceCell = {}

setmetatable(CommerceCell, Dialog)
CommerceCell.__index = CommerceCell
local prefix = 0

function CommerceCell.CreateNewDlg(parent)
	local newDlg = CommerceCell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function CommerceCell.GetLayoutFileName()
	return "npcshopshanghuicell_mtg.layout"
end

function CommerceCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, CommerceCell)
	return self
end

function CommerceCell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)

	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)

	self.window = CEGUI.toGroupButton(winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg"))
	self.itemcell = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/item"))
	self.nameText = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/name")
	self.priceText = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/textjiage")
	self.currencyIcon = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/textjiage/yinbi")
	self.buyNumLimit = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/number")
    self.cornerImg = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/")
    self.priceFloatSign = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/add")
    self.priceFloatText = winMgr:getWindow(prefixstr .. "npcshopshanghuicell_mtg/add/lv")

    self.cornerImg:setVisible(false)
    self.priceFloatSign:setVisible(false)
    --self.priceFloatText:setVisible(false)
    self.priceFloatText:setProperty("TextColours", "FFFFFFFF")

	self.window:EnableClickAni(false)
    self.orginColor = self.buyNumLimit:getProperty("TextColours")
end

function CommerceCell:setGoodsDataById(goodsid)
	self.goodsid = goodsid
	
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsid)
	if not conf then
		return
	end
	
	self.nameText:setText(conf.name)

    local curPrice = ShopManager.goodsPrices[goodsid] or conf.prices[0]
	local prePrice = ShopManager.goodsPreviousPrices[goodsid] or conf.prices[0]

    self.priceText:setText(MoneyFormat(curPrice))
    --显示价格浮动
	if curPrice == prePrice then
		--self.priceFloatText:setVisible(false)
		self.priceFloatSign:setVisible(false)
		self.priceFloatText:setText("[colour='FF50321a']价格涨跌   -")
	else
		local floatPriceVal = curPrice / prePrice + 0.0005 --保留1位小数的百分数
        --self.priceFloatText:setVisible(true)
		self.priceFloatSign:setVisible(true)
		if curPrice > prePrice then
			self.priceFloatText:setText("[colour='ff1d953f']" .. math.max( math.floor(1000 * (floatPriceVal-1))/1000, 0.001)*100 .. "%")
			self.priceFloatSign:setProperty("Image", "set:shopui image:shop_up")
		else
			self.priceFloatText:setText("[colour='ffff0000']" .. math.max( math.floor(1000 * (1-floatPriceVal))/1000, 0.001)*100 .. "%")
			self.priceFloatSign:setProperty("Image", "set:shopui image:shop_down")
		end
	end
	
	CurrencyManager.setCurrencyIcon(conf.currencys[0], self.currencyIcon)
	
	local item = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(conf.itemId)
	if not item then
		return
	end
	
    self.itemcell:setID(conf.itemId)
	self.itemcell:SetImage(gGetIconManager():GetImageByID(item.icon))
	self.itemcell:SetTextUnit(item.level > 150 and "Lv." .. item.level or "")
	SetItemCellBoundColorByQulityItem(self.itemcell, item.nquality)
	
	local buyNum = ShopManager.goodsBuyNumLimit[goodsid]
	if buyNum then
		local vipLevel = gGetDataManager():GetVipLevel()
		local record = BeanConfigManager.getInstance():GetTableByName("fushi.cvipinfo"):getRecorder(vipLevel)
		local limitNum = conf.limitNum

		limitNum = limitNum + record.limitnumber2

		self.buyNumLimit:setText(MHSD_UTILS.get_resstring(11836) .. tostring(limitNum-buyNum)) --剩余xx
        if buyNum == limitNum then
            self.buyNumLimit:setProperty("TextColours", "FFf2d42c")
            self.cornerImg:setVisible(true)
            self.cornerImg:setProperty("Image", "set:ccui3 image:shoukong")
        else
            self.buyNumLimit:setProperty("TextColours", self.orginColor)
            self.cornerImg:setVisible(false)
        end
	else
		self.buyNumLimit:setText("")
	end
end

function CommerceCell:showRequireCornerImage(willShow)
	if willShow then
        self.cornerImg:setVisible(true)
        self.cornerImg:setProperty("Image", "set:ccui3 image:xuqiudi")
	else
		self.cornerImg:setVisible(false)
	end
end

return CommerceCell

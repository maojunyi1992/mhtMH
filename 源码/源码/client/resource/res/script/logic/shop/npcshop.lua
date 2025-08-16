------------------------------------------------------------------
-- NPC商店
------------------------------------------------------------------
require "logic.dialog"
require "logic.shop.goodscell"
require "utils.tableutil"
require "utils.typedefine"
require "manager.currencymanager"

NpcShop = {}
setmetatable(NpcShop, Dialog)
NpcShop.__index = NpcShop

local _instance
function NpcShop.getInstance()
	if not _instance then
		_instance = NpcShop:new()
		_instance:OnCreate()
	end
	return _instance
end

function NpcShop.getInstanceAndShow()
	if not _instance then
		_instance = NpcShop:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function NpcShop.getInstanceNotCreate()
	return _instance
end

function NpcShop.DestroyDialog()
	if _instance then 
        local Taskmanager = require("logic.task.taskmanager")
        Taskmanager.getInstance():setTaskOpenShopType(-1)

		CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
		if _instance.goodsTableView then
			_instance.goodsTableView:destroyCells()
		end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function NpcShop.ToggleOpenClose()
	if not _instance then
		_instance = NpcShop:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function NpcShop.GetLayoutFileName()
	return "npcshop_mtg.layout"
end

function NpcShop:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NpcShop)
	return self
end

function NpcShop:OnCreate()
	Dialog.OnCreate(self)
	SetPositionScreenCenter(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.listBg = winMgr:getWindow("npcshop_mtg/textbg")
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("npcshop_mtg/btnjianhao"))
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("npcshop_mtg/jiahao"))
	self.totalPriceText = winMgr:getWindow("npcshop_mtg/textzong")
	self.itemNameText = winMgr:getWindow("npcshop_mtg/textzong1")
	self.currencyIcon1 = winMgr:getWindow("npcshop_mtg/textzong/yinbi1")
	self.currencyIcon2 = winMgr:getWindow("npcshop_mtg/textzong/yinbi2")
	self.ownMoneyText = winMgr:getWindow("npcshop_mtg/textdan")
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("npcshop_mtg/btngoumai"))
	self.buyNumBg = winMgr:getWindow("npcshop_mtg/shurukuang")
	self.buyNumText = winMgr:getWindow("npcshop_mtg/shurukuang/numtext")
	--self.shopname1Text = winMgr:getWindow("npcshop_mtg/shopname/cc")


	self.minusBtn:subscribeEvent("Clicked", NpcShop.handleMinusBuyNumClicked, self)
	self.addBtn:subscribeEvent("Clicked", NpcShop.handleAddBuyNumClicked, self)
	self.buyBtn:subscribeEvent("Clicked", NpcShop.handleBuyClicked, self)
	self.buyNumBg:subscribeEvent("MouseClick", NpcShop.handleBuyNumClicked, self)
end

function NpcShop:selectGoodsByItemid(itemid, num)
    if not self.goodsIds then
        return
    end
    
    num = (num and math.max(num, 1) or 1)
    
    for k,v in pairs(self.goodsIds) do
        local goods = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(v)
        if goods.itemId == itemid then
            local cell = self.goodsTableView:focusCellAtIdx(k)
            if cell then
                self.selectedCellIdx = k
                self:refreshSelectedGoods()
                cell.window:setSelected(true)
                cell:showRequireCornerImage(true)
                self.requireGoodsCellIdx = k
              --  self.shopname1Text:setText(goods.name) -- 添加这一行，设置物品名称
                self.buyNumText:setText(num)
                self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0] * num))

                CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
            end
            break
        end
    end
end

function NpcShop:setShopType(shopType)
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(shopType)
	if not conf then
		return
	end
	self.saleConf = conf
	self.goodsIds = {}
	local rolelv = gGetDataManager():GetMainCharacterLevel()
	local n = 0
	for i=0, conf.goodsids:size()-1 do
		local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(conf.goodsids[i])
		if goodsConf.limitLookLv <= rolelv then --���ɼ��ȼ�����
			self.goodsIds[n] = conf.goodsids[i]
			n = n+1
		end
	end
	
	--self:GetWindow():setText(conf.shopName)
	self.itemNameText:setText(conf.shopName)
	--self:shopname1Text():setText(conf.shopName)
	
	
	CurrencyManager.setCurrencyIcon(conf.currency, self.currencyIcon1)
	CurrencyManager.setCurrencyIcon(conf.currency, self.currencyIcon2)
	CurrencyManager.registerTextWidget(conf.currency, self.ownMoneyText)
	
	self.selectedCellIdx = 0
	self.currencyType = conf.currency
	
	local s = self.listBg:getPixelSize()
	self.goodsTableView = TableView.create(self.listBg)
	self.goodsTableView:setViewSize(s.width-20, s.height-20)
	self.goodsTableView:setPosition(10, 10)
	self.goodsTableView:setColumCount(4)
    self.goodsTableView:setCellInterval(5, 5)
	self.goodsTableView:setCellCount(TableUtil.tablelength(self.goodsIds))
	self.goodsTableView:setDataSourceFunc(self, NpcShop.tableViewGetCellAtIndex)
	self.goodsTableView:reloadData()
	
	self:refreshSelectedGoods()
end

function NpcShop:tableViewGetCellAtIndex(tableView, idx, cell)
	if not cell then
		cell = GoodsCell.CreateNewDlg(tableView.container)
		cell.window:subscribeEvent("MouseClick", NpcShop.handleGoodsCellClicked, self)
        cell.itemCell:subscribeEvent("MouseClick", NpcShop.handleGoodsItemCellClicked, self)
	end
	cell:setGoodsDataById(self.goodsIds[idx])
	cell.window:setID(idx)
	cell.window:setSelected( self.selectedCellIdx == idx )
	cell:showRequireCornerImage( self.requireGoodsCellIdx == idx )
	return cell
end

function NpcShop:onNumInputChanged(num)
	if num == 0 then
		self.buyNumText:setText(1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0]))
	else
		self.buyNumText:setText(num)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0] * num))
	end

    CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
end

function NpcShop:refreshSelectedGoods()
	local goodsId = self.goodsIds[self.selectedCellIdx]
	self.curGoodsconf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(goodsId)
	if self.curGoodsconf then
		self.buyNumText:setText(1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0]))
		CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
	end
end

function NpcShop:handleGoodsCellClicked(args)
	local idx = CEGUI.toWindowEventArgs(args).window:getID()
	if self.selectedCellIdx == idx then
		self:handleAddBuyNumClicked()
	else
		self.selectedCellIdx = idx
		self:refreshSelectedGoods()
	end
end

function NpcShop:handleGoodsItemCellClicked(args)
    GameItemTable.HandleShowToolTipsWithItemID(args)

    local cell = CEGUI.toGroupButton(CEGUI.toWindowEventArgs(args).window:getParent())
    if cell then
        cell:setSelected(true)

        local idx = cell:getID()
        if self.selectedCellIdx == idx then
		    self:handleAddBuyNumClicked()
	    else
		    self.selectedCellIdx = idx
		    self:refreshSelectedGoods()
	    end
    end
end

function NpcShop:handleMinusBuyNumClicked(args)
	local num = tonumber(self.buyNumText:getText())
	if num > 1 then
		self.buyNumText:setText(num-1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0] * (num-1)))
		CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
	end
end

function NpcShop:handleAddBuyNumClicked(args)
	local num = tonumber(self.buyNumText:getText())
	if num < 99 then
		self.buyNumText:setText(num+1)
		self.totalPriceText:setText(MoneyFormat(self.curGoodsconf.prices[0] * (num+1)))
		CurrencyManager.setCompareTextWidget(self.ownMoneyText, self.totalPriceText)
	end
end

function NpcShop:handleBuyNumClicked(args)
	
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.buyNumBg)
		dlg:setMaxValue(99)
		dlg:setInputChangeCallFunc(NpcShop.onNumInputChanged, self)
		
		local p = self.buyNumBg:GetScreenPos()
		local s = self.buyNumBg:getPixelSize()
		SetPositionOffset(dlg:GetWindow(), p.x+s.width*0.5, p.y-20, 0.5, 1)
	end
end

function NpcShop:handleBuyClicked(args)
	--test
	--[[self:selectGoodsByItemid(4040411, 3)
	do return end--]]
	
	--��鹺��ȼ�
	if not CurrencyManager.checkRoleLevel(self.goodsIds[self.selectedCellIdx], true) then
		return
	end
	
	local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.goodsIds[self.selectedCellIdx])
	--��鱳������
	if not CheckBagCapacityForItem(conf.itemId, tonumber(self.buyNumText:getText())) then
		GetCTipsManager():AddMessageTipById(160062) --�����ռ䲻��
		return
	end
	
	local p = require("protodef.fire.pb.shop.cbuynpcshop").Create()
	p.shopid = self.saleConf.id
	p.goodsid = self.goodsIds[self.selectedCellIdx]
	p.num = tonumber(self.buyNumText:getText())
	p.buytype = fire.pb.shop.ShopBuyType.NORMAL_SHOP
	
	local totalprice = MoneyNumber(self.totalPriceText:getText())
	local needMoney = totalprice - MoneyNumber(self.ownMoneyText:getText())
	if needMoney > 0 then
		--GET MONEY
		CurrencyManager.handleCurrencyNotEnough(self.currencyType, needMoney, totalprice, p, self.ownMoneyText)
	else
		
		LuaProtocolManager:send(p)
		
		self:refreshSelectedGoods()
	end
end

return NpcShop

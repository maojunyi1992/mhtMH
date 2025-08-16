------------------------------------------------------------------
-- �̵����ݹ���
------------------------------------------------------------------
require "utils.tableutil"
require "utils.typedefine"
require "logic.shop.quickbuydlg"
require "logic.shop.stalldlg"
require "logic.shop.scoreexchangeshop"

ShopManager = {
	goodsPrices = {}, --��Ʒ�۸�
	goodsPreviousPrices = {}, --��Ʒ֮ǰ�ļ۸����ڼ���۸񸡶�
	isPricesRecved = false,
	
	marketThreeTable = nil	--��̯�����˵���key:itembaseid/petid, value:CMarketThreeTableTable
}

function ShopManager:init()
    self:reset()
    self:queryNumLimit()
end

function ShopManager:onGameExit()
	self:reset()
end

function ShopManager:reset()
    self.queryNumTimestamp = 0 --�����޹�/���ۼ۸�ķ�����ʱ��
	self.goodsBuyNumLimit = {} --��Ʒ�޹����� key:goodsid, val:num
	self.goodsSellNumLimit = {} --��Ʒ���۴��� key:goodsid, val:num
	self.isBuyNumRecved = false
	self.isSellNumRecved = false
    self.hefuGoodsList = nil    --�Ϸ�����ʱ��̯����

    --��ʼ����ע����
    self.attentionGoodsIds = {}
    self.attentionGoodsIds.num = {}
    self.attentionGoodsIds.num[1] = 0 --���� GROUP_BUY
	self.attentionGoodsIds.num[2] = 0 --��ʽ GROUP_SHOW
end

--�ж��Ƿ��յ��޹���������
function ShopManager:checkNumLimit()
	if DayChanged(self.queryNumTimestamp) then
		self.goodsBuyNumLimit = {}
		self.goodsSellNumLimit = {}
		self.isBuyNumRecved = false
		self.isSellNumRecved = false
		self:queryNumLimit()
		return false
	end
	return (self.isBuyNumRecved and self.isSellNumRecved)
end

--ֻ���̻����Ҫ����۸�
function ShopManager:queryGoodsPrices()
	local p = require("protodef.fire.pb.shop.crequstshopprice"):new()
	p.shopid = SHOP_TYPE.COMMERCE
	LuaProtocolManager:send(p)
end

function ShopManager:queryNumLimit()
	local buyNUmProto = require("protodef.fire.pb.shop.cquerylimit"):new() --�޹�����
	local sellNumProto = require("protodef.fire.pb.shop.cquerylimit"):new() --���۴���
	
	buyNUmProto.querytype = 1
	sellNumProto.querytype = 2
	
	local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getAllID()
	for _,id in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(id)
		if conf.limitNum > 0 then
			table.insert(buyNUmProto.goodsids, id)
			table.insert(sellNumProto.goodsids, id)
		end
	end
	
	LuaProtocolManager:send(buyNUmProto)
	LuaProtocolManager:send(sellNumProto)
	
	self.queryNumTimestamp = gGetServerTime()
end

function ShopManager:queryAttention()
    local p = require("protodef.fire.pb.shop.cmarketattentionbrowse"):new()
	p.attentype = 1 --GROUP_BUY
	LuaProtocolManager:send(p)

	if not IsPointCardServer() then
		p = require("protodef.fire.pb.shop.cmarketattentionbrowse"):new()
		p.attentype = 2 --GROUP_SHOW
		LuaProtocolManager:send(p)
	end
end

function ShopManager:convertMarketThreeTable()
	self.marketThreeTable = {}
    local dataTable = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cmarketthreetable"))
    local ids = dataTable:getAllID()
    for _,id in pairs(ids) do
        local conf = dataTable:getRecorder(id)
        if conf.cansale == 1 then
            self.marketThreeTable[conf.itemid] = conf
        end
    end
end

function ShopManager:getGoodsConfByItemID(itemid)
    if not self.marketThreeTable then
        ShopManager:convertMarketThreeTable()
    end
    return self.marketThreeTable[itemid]
end

--�Ƿ�����Ʒ
function ShopManager:isRarity(goodstype, baseid)
	if not self.marketThreeTable then
        ShopManager:convertMarketThreeTable()
    end
	if self.marketThreeTable and self.marketThreeTable[baseid] and self.marketThreeTable[baseid].israrity == 1 then
		return true
	end
	return false
end

--�Ƿ���Ҫ��ʾ��Ʒ�Ǳ꣬װ������ʾ
function ShopManager:needShowRarityIcon(goodstype, baseid)
    if goodstype == STALL_GOODS_T.ITEM then
        local conf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(baseid)
        if conf and conf.itemtypeid % 16 == eItemType_EQUIP then
            return false
        end
    end
    return ShopManager:isRarity(goodstype, baseid)
end

function ShopManager:getShopTypeByNpcKey(npcKey)
	local npc =  gGetScene():FindNpcByID(npcKey)
	local npcId = npc:GetNpcBaseID()
	local ids = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getAllID()
	for _,id in pairs(ids) do
		local conf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cnpcsale")):getRecorder(id)
		if conf.npcId == npcId then
			ids = nil
			return conf.id
		end
	end
	ids = nil
end

function ShopManager:tryQuickBuy(itemId, count)
    local quickBuyConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cquickbuy")):getRecorder(itemId)
    if not quickBuyConf then
        GetCTipsManager():AddMessageTipById(150058) --���߲���
        return
    end

	count = count or 1
    local buytype = quickBuyConf.buytype

    if buytype == QUICKBUY_T.MALL or buytype == QUICKBUY_T.COMMERCE then
		--����޹�����
		local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(quickBuyConf.goodsid)
		if goodsConf.limitNum > 0 then
			local buyNum = (ShopManager.goodsBuyNumLimit[quickBuyConf.goodsid] or 0)
			if goodsConf.limitNum - buyNum < count then
				--GetCTipsManager():AddMessageTipById(160013) --���չ���������Ѵ�����
				--GetCTipsManager():AddMessageTipById(150058) --���߲���
				if buytype == QUICKBUY_T.MALL then
					ShopLabel.showMallShop()
					MallShop.getInstance():selectGoodsByItemid(itemId)
				elseif buytype == QUICKBUY_T.COMMERCE then
					ShopLabel.showCommerce()
					CommerceDlg.getInstance():selectGoodsByItemid(itemId)
				end
				return
			end
		end

        local dlg = QuickBuyDlg.getInstanceAndShow()
        dlg:setItemBaseId(itemId, count)

    elseif buytype == QUICKBUY_T.STALL then
		require("logic.shop.stalllabel").openStallToBuy(itemId)
    
    elseif buytype == QUICKBUY_T.SCORE then
        local dlg = ScoreExchangeShop.getInstanceAndShow()
        dlg:selectGoodsByItemid(itemId)

    elseif buytype == QUICKBUY_T.OTHER then
        --give tip msg
		GetCTipsManager():AddMessageTipById(150058) --���߲���

    else
        GetCTipsManager():AddMessageTipById(150058) --���߲���
    end
end

function GetGoodsNameByItemId(goodsType, itemId, withColor)
    if withColor == nil then
        withColor = true
    end
    if goodsType == 2 then --pet
        local conf = BeanConfigManager.getInstance():GetTableByName("pet.cpetattr"):getRecorder(itemId)
        if conf then
            if withColor then
                return "[colour=\'" .. conf.colour .. "\']" .. conf.name
            end
            return conf.name
        end
    else
        local conf = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(itemId)
        if conf then
            return conf.name
        end
    end
    return ""
end

return ShopManager

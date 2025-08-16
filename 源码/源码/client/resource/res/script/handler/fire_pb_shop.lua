require "utils.commonutil"
require "logic.shop.commercedlg"
require "logic.shop.shopmanager"
require "logic.shop.mallshop"
require "logic.shop.stalldlg"
require "logic.shop.stallupshelf"
require "logic.shop.stallpetupshelf"
require "logic.shop.stallupokconfirm"
require "logic.shop.stalltradelogdlg"
require "logic.shop.scoreexchangeshop"
require "logic.shop.shoplabel"
require "logic.shop.commerceselldlg"

--�ӷ���������޹���������Ʒ���ѹ������������������
local p = require "protodef.fire.pb.shop.squerylimit"
function p:process()
	if self.querytype == 1 then  --�ѹ������
		ShopManager.isBuyNumRecved = true
		for _,v in pairs(self.goodslimits) do
			ShopManager.goodsBuyNumLimit[v.goodsid] = v.number
		end
		
		--�����̻����
		local dlg = CommerceDlg.getInstanceNotCreate()
		if dlg and dlg.tableview then
			dlg:recvBuyNumChanged(self.goodslimits)
		end
		
		--�����̳ǽ���
		dlg = MallShop.getInstanceNotCreate()
		if dlg then
			if not dlg.goodsTable then
				dlg:loadGoodsByType(gCommon.curMallGoodsType)
			else
				dlg:recvBuyNumChanged(self.goodslimits)
			end

			dlg:refreshGoodsDetail()
		end

        dlg = ScoreExchangeShop.getInstanceNotCreate()
        if dlg then
            dlg:recvBuyNumChanged()
        end
		--����ui����
	    CommerceDlg.InitIfNeed()

	elseif self.querytype == 2 then  --����������
		ShopManager.isSellNumRecved = true
		for _,v in pairs(self.goodslimits) do
			ShopManager.goodsSellNumLimit[v.goodsid] = v.number
		end

        local dlg = CommerceSellDlg.getInstanceOrNot()
        if dlg then
            dlg:onSellNumLimitChanged()
        end
	end
end

--��ȡ��Ʒ���ּ�
p = require "protodef.fire.pb.shop.sresponseshopprice"
function p:process()
	if self.shopid == SHOP_TYPE.COMMERCE then
		ShopManager.isPricesRecved = true
		ShopManager.queryPriceTimestamp = math.floor(gGetServerTime()*0.001)
		
		for _,v in pairs(self.goodslist) do
			ShopManager.goodsPrices[v.goodsid] = v.price
			ShopManager.goodsPreviousPrices[v.goodsid] = v.priorperiodprice
			--print('goods price', v.goodsid, v.price, v.priorperiodprice)
		end
		
		CommerceDlg.InitIfNeed()

		if require("logic.shop.quickbuydlg").getInstanceNotCreate() then
			require("logic.shop.quickbuydlg").getInstanceNotCreate():refreshPrice()
		end

		if require("logic.shop.commercequickselldlg").getInstanceNotCreate() then
			require("logic.shop.commercequickselldlg").getInstanceNotCreate():refreshPrice()
		end

        if require("logic.workshop.workshophcnew").getInstanceNotCreate() then
			require("logic.workshop.workshophcnew").getInstanceNotCreate():refreshShopGems()
		end
	end
end

--��ȡ�ҵ�̯λ��Ʒ
--actiontype: 1�����ע��2��ʾ��ע��3����
p = require "protodef.fire.pb.shop.smarketcontainerbrowse"
function p:process()
    if self.actiontype ~= 3 then
        for _,v in pairs(self.goodslist) do
            ShopManager.attentionGoodsIds[v.id] = true
        end
        ShopManager.attentionGoodsIds.num[self.actiontype] = #self.goodslist
    end

	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		if self.actiontype == 3 then
			dlg:refreshMyStallGoodsList(self.goodslist)
		else
			dlg:refreshAttentionContainer(self.actiontype == 1, self.goodslist)
		end
	end

    dlg = require("logic.chat.insertdlg").getInstanceNotCreate()
    if dlg then
        if self.actiontype == 3 then
            dlg:recvStallOnSellGoods(self.goodslist)
        else
            dlg:recvStallAttentionGoods(self.goodslist)
        end
    end
end

--����һ�����������˵���ȡ��̯��Ʒ
p = require "protodef.fire.pb.shop.smarketbrowse"
function p:process()
	local dlg = StallUpShelf.getInstanceNotCreate()
	if dlg then
		dlg:recvStallGoods(self)
		return
	end
	
	dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:recvStallGoods(self)
	end
end

--��Ʒ����ɹ�����
p = require "protodef.fire.pb.shop.smarketbuy"
function p:process()
	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:recvBuyStallGoodsRes(self.id, self.surplusnum)
	end
end

--�ϼܵ��Ƽ��۸�
p = require "protodef.fire.pb.shop.sgetmarketupprice"
function p:process()
	local dlg = StallUpShelf.getInstanceNotCreate()
	if dlg then
		dlg:setRecommendPrice(self.containertype, self.price, self.stallprice)
	end
end

--��Ʒ��ʾ�ɹ�
p = require "protodef.fire.pb.shop.smarketupsucc"
function p:process()
    if not IsPointCardServer() then
	    local iniMgr = IniManager("SystemSetting.ini")
	    local exist,_,_,value = iniMgr:GetValueByName("GameConfig", "shangjiashijian", "")
	    if exist then
		    local timestamp = gGetServerTime()
		    if (timestamp - tonumber(value)) / (24*60*60*1000) < 7 then
			    return
		    end
		    iniMgr:RemoveValueByName("GameConfig", "shangjiashijian")
	    end
	
	    local dlg = StallUpOkConfirm.getInstanceAndShow()
	    dlg:setViewType(self.israrity)
    end
end

--��̯���׼�¼
p = require "protodef.fire.pb.shop.smarkettradelog"
function p:process()
	local dlg = StallTradeLogDlg.getInstanceNotCreate()
	if dlg then
		dlg:setTradeLogData(self)
	end
end

--�̳ǹ���ɹ�
p = require "protodef.fire.pb.shop.snotifybuysuccess"
function p:process()
    if self.notifytype == fire.pb.shop.ShopBuyType.MALL_SHOP then
        local dlg = MallShop.getInstanceNotCreate()
        if dlg then
            dlg:recvBuySuccess(self)
        end

        local ranseDlg =  require"logic.ranse.ranselabel".getInstanceNotCreate()
        if ranseDlg then
            ranseDlg:refreshItemShow()
        end
    end
end

--��̯�������
p = require "protodef.fire.pb.shop.smarketsearchresult"
function p:process()
	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:recvSearchResult(self)
	end
end

--��ע
p = require "protodef.fire.pb.shop.sattentiongoods"
function p:process()
	if self.attentiontype == 1 then --��ע
		GetCTipsManager():AddMessageTipById(190015) --��ע�ɹ���
	elseif self.attentiontype == 2 then --ȡ����ע
		GetCTipsManager():AddMessageTipById(190016) --ȡ����ע�ɹ�
	end

    local n = (self.attentiontype == 1 and 1 or -1)
    ShopManager.attentionGoodsIds.num[self.attentype] = ShopManager.attentionGoodsIds.num[self.attentype] + n
    ShopManager.attentionGoodsIds[self.id] = (self.attentiontype == 1 and true or nil)

	local dlg = StallDlg.getInstanceNotCreate()
	if dlg then
		dlg:refreshGoodsAttention(self.attentype, self.attentiontype, self.id)
	end
end

p = require "protodef.fire.pb.shop.smarketpettips"
function p:process()
	local petData = require("logic.pet.mainpetdata"):new()
    petData:initWithLua(self.pettips)
	LuaRecvPetTipsData(petData, self.tipstype)
end

--��������еİ�̯��Ʒ
p = require "protodef.fire.pb.shop.smarketitemchatshow"
function p:process()
    StallDlg.notQueryGoods = true
    require("logic.shop.stalllabel").show()
    local dlg = StallDlg.getInstanceNotCreate()
    if dlg then
        dlg:showChatStallGoods(self)
    end
    StallDlg.notQueryGoods = nil
end

p = require "protodef.fire.pb.shop.stempmarketcontainer"
function p:process()
    ShopManager.hefuGoodsList = self.goodslist
	if #self.goodslist > 0 then
		MainControl.ShowBtnInFirstRow(MainControlBtn_HeFuBag)
	end
end

p = require "protodef.fire.pb.shop.stakebacktempmarketcontaineritem"
function p:process()
	if self.succ == 1 then
		local dlg = require("logic.shop.hefubagdlg").getInstanceNotCreate()
		if dlg then
			dlg.DestroyDialog()
		end

		MainControl.ShowBtnInFirstRow(MainControlBtn_HeFuBag, false)
	end
end

-- ��Ҷ������
p = require "protodef.fire.pb.shop.sgoldorderbrowseblackmarket"
function p:process()
	local dlg = require("logic.shop.treasurehousedlg").getInstanceNotCreate()
	if dlg then
		dlg:setGoldOrderList(self.salelist, self.buylist)
	end
end

-- ����¶���
p = require "protodef.fire.pb.shop.sgoldorderupblackmarket"
function p:process()
	local dlg = require("logic.shop.treasurehousedlg").getInstanceNotCreate()
	if dlg then
		dlg:addOrder(self.order)
	end
end

-- ���¶���״̬
p = require "protodef.fire.pb.shop.srefreshgoldorderstate"
function p:process()
	local dlg = require("logic.shop.treasurehousedlg").getInstanceNotCreate()
	if dlg then
		dlg:refreshGoldOrderState(self.pid, self.state)
	end
end

-- ɾ������
p = require "protodef.fire.pb.shop.sgoldorderdownblackmarket"
function p:process()
	local dlg = require("logic.shop.treasurehousedlg").getInstanceNotCreate()
	if dlg then
		dlg:deleteGoldOrder(self.pid)
	end
end
------------------------------------------------------------------
-- NPC�����̵�
------------------------------------------------------------------
require "logic.dialog"

XianShiDlg = {}
setmetatable(XianShiDlg, Dialog)
XianShiDlg.__index = XianShiDlg

local _instance
function XianShiDlg.getInstance()
	if not _instance then
		_instance = XianShiDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function XianShiDlg.getInstanceAndShow()
	if not _instance then
		_instance = XianShiDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function XianShiDlg.getInstanceOrNot()
	return _instance
end

function XianShiDlg.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function XianShiDlg:OnClose()
    CurrencyManager.unregisterTextWidget(_instance.ownMoneyText)
    gGetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.eventItemNumChange)
    Dialog.OnClose(_instance)
    _instance = nil
end

function XianShiDlg.ToggleOpenClose()
	if not _instance then
		_instance = XianShiDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function XianShiDlg.GetLayoutFileName()
	return "xianshi_mtg.layout"
end

function XianShiDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, XianShiDlg)
	return self
end

function XianShiDlg:OnCreate()
	Dialog.OnCreate(self)
    --SetPositionOfWindowWithLabel(self:GetWindow())
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.numText = winMgr:getWindow("xianshi/shurukuang/buynum")
	self.priceText = winMgr:getWindow("xianshi/textzong")
	self.ownMoneyText = winMgr:getWindow("xianshi/textdan")
	self.buyBtn = CEGUI.toPushButton(winMgr:getWindow("xianshi/btngoumai"))
	self.sellItemScroll = CEGUI.toScrollablePane(winMgr:getWindow("xianshi/textbg3/list2"))
	--self.sellItemTable = CEGUI.toItemTable(winMgr:getWindow("xianshi/textbg3/list2/table"))
	self.minusBtn = CEGUI.toPushButton(winMgr:getWindow("xianshi/btnjianhao"))
	self.addBtn = CEGUI.toPushButton(winMgr:getWindow("xianshi/jiahao"))
    --self.sellItemScroll:EnableAllChildDrag(self.sellItemScroll)
	self.huobi1 = winMgr:getWindow("xianshi/textzong/yinbi1")
	self.huobi2 = winMgr:getWindow("xianshi/textzong/yinbi2")
	self.m_btnguanbi = CEGUI.toPushButton(winMgr:getWindow("xianshi/back"))--关闭
	self.m_btnguanbi:subscribeEvent("Clicked", XianShiDlg.handleQuitBtnClicked, self)--关闭


	--固定道具格数组初始化
	self.m_boxItem = {}
	self.m_boxItemName = {}
	self.m_boxItemJg = {}
	self.m_boxItemJsBox = winMgr:getWindow("xianshi/js")--介绍文本



    --self.sellItemTable:subscribeEvent("TableClick", XianShiDlg.handleItemClicked, self)
	self.buyBtn:subscribeEvent("Clicked", XianShiDlg.handleBuyClicked, self)
    self.numText:subscribeEvent("MouseClick", XianShiDlg.handleNumTextClicked, self)
    self.minusBtn:subscribeEvent("Clicked", XianShiDlg.handleMinusClicked, self)
	self.addBtn:subscribeEvent("Clicked", XianShiDlg.handleAddClicked, self)

    self.eventItemNumChange = gGetRoleItemManager():InsertLuaItemNumChangeNotify(XianShiDlg.onEventItemNumChange)

   -- CurrencyManager.registerTextWidget(fire.pb.game.MoneyType.MoneyType_SilverCoin, self.ownMoneyText)
   	CurrencyManager.registerTextWidget(3, self.ownMoneyText)

   
	--界面特效
   	self.txjm = winMgr:getWindow("xianshi/txdd")
   	local flagEffect = gGetGameUIManager():AddUIEffect(self.txjm, "spine/my_spine/mhfzj", true)
	flagEffect:SetScale(1.2)
    flagEffect:SetDefaultActName("animation")

   

    self.selectedItemkey = 0
    self.selectedItemId = 0
    self.selectedGoodsId = 0
	self.pageId=0
	self.itemnum={}
	self.listInfo = {}
    --self:refreshSellGoodsList()

    --�����̻���Ʒ�µļ۸�
    local p = require("protodef.fire.pb.shop.cxianshichaxun"):new()
	LuaProtocolManager:send(p)

	--����޹���������
	--ShopManager:checkNumLimit()
end
function XianShiDlg:refreshSellGoodsList(xianshilist)
	--local os = require("os")
	local sz = #self.listInfo
	for index  = 1, sz do
		local lyout = self.listInfo[1]
		lyout.btn = nil
		lyout.item = nil
		lyout.name = nil
		lyout.num = nil
		self.sellItemScroll:removeChildWindow(lyout)
		CEGUI.WindowManager:getSingleton():destroyWindow(lyout)
		table.remove(self.listInfo,1)
	end
	self.listInfo = {}
	for x,y in pairs(xianshilist) do
		self.itemnum[x]=y
	end
	local winMgr = CEGUI.WindowManager:getSingleton()

	local current_time = os.time()
	local current_date_table = os.date("*t", current_time)
	local xianshis = BeanConfigManager.getInstance():GetTableByName("item.cxianshi"):getAllID()

	local colCount = 3
	local rowCount = math.floor(#xianshis/ colCount) + 3

	local sz = self.sellItemScroll:getPixelSize()

	local wndWidth = sz.width / colCount

	local wndHeight = 100
	local index = 0
	for _,id in pairs(xianshis) do
	

	

	
		local xianshi = BeanConfigManager.getInstance():GetTableByName("item.cxianshi"):getRecorder(id)
	-- local roledata = gGetDataManager():GetMainCharacterData()
		-- if xianshi.day==roledata.ServerOpenDays then
		if xianshi.day==current_date_table.day then
			local sID = tostring(index+1)
			
			local lyout = winMgr:loadWindowLayout("xianshicell.layout",sID);
			self.sellItemScroll:addChildWindow(lyout)
			

			--self.maps[id] = CEGUI.toCheckbox(winMgr:getWindow("guaji/"..id))
		    lyout.btn = CEGUI.toGroupButton(winMgr:getWindow(sID.."xianshicell"))
			lyout.jieshao = CEGUI.toRichEditbox(winMgr:getWindow(sID.."xianshicell/xiangou11/jieshao"))
			lyout.jieshao:setReadOnly(true)
	     	lyout.btn:setID(id)
		    lyout.btn:subscribeEvent("MouseButtonUp", XianShiDlg.handleGroupBtnClicked, self)
			--self.maps[id]:setText(guajia.name)
			lyout.item = CEGUI.toItemCell(winMgr:getWindow(sID.."xianshicell/item"))
			lyout.name = winMgr:getWindow(sID.."xianshicell/xiangou11")
			lyout.num = winMgr:getWindow(sID.."xianshicell/xiangou")
			local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(xianshi.item)
			local image = gGetIconManager():GetImageByID(itemAttr.icon)
			--lyout.jieshao:AppendText(CEGUI.String(itemAttr.destribe))
			
			lyout.jieshao:AppendText(CEGUI.String(itemAttr.destribe),CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff000000")))  --sezhi
			
			lyout.jieshao:Refresh()
			lyout.item:SetImage(image)
			lyout.name:setText(itemAttr.name)
			--lyout.num:setText(tostring(self.itemnum[xianshi.item]).."/"..tostring(xianshi.num))
			lyout.num:setText(tostring(xianshi.num-xianshilist[xianshi.item]))
	     	--info.btn:subscribeEvent("SelectStateChanged", XianShiDlg.handleGroupBtnClicked, self)
			
			---固定道具格
			self.m_boxItem[sID] = CEGUI.Window.toItemCell(winMgr:getWindow("xianshi/item"..sID))  --道具格1-3
			self.m_boxItem[sID]:SetImage(image)--设置图片
			self.m_boxItem[sID]:SetTextUnit(tostring(xianshi.num-xianshilist[xianshi.item]))--设置道具剩余数量
			
			self.m_boxItem[sID]:setID(id)--设置ID
			self.m_boxItemName[sID] = winMgr:getWindow("xianshi/item"..sID.."/name")  --道具格名字
			self.m_boxItemName[sID]:setText(itemAttr.name)
			
			self.m_boxItemJg[sID] = winMgr:getWindow("xianshi/item"..sID.."/jg")  --道具格价格
			local gaoji =BeanConfigManager.getInstance():GetTableByName(CheckTableName("item.cxianshi")):getRecorder(id)
			self.m_boxItemJg[sID]:setText(gaoji.money)
			
			self.m_boxItem[sID]:subscribeEvent("MouseButtonUp", XianShiDlg.handleGroupBtnClicked, self)
			
			self.pageId = math.floor(index / (colCount*rowCount))

			local colId = math.floor(index % colCount)
			local rowId = math.floor(index / colCount)

			local xPos = colId * wndWidth
			local yPos =(rowId % rowCount) * wndHeight

			xPos = xPos + self.pageId * sz.width

			local offsetX = lyout.btn:getPixelSize().width/2;
			lyout:setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPos - offsetX ), CEGUI.UDim(0, yPos )))
			table.insert(self.listInfo,lyout)
			index=index+1
		end

	end
	
	--默认设置中间项目 --第二格
	self.selectedItemId = self.m_boxItem[tostring(2)]:getID()
	local xianshi = BeanConfigManager.getInstance():GetTableByName("item.cxianshi"):getRecorder(self.selectedItemId)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(xianshi.item)
	self.m_boxItemJsBox:setText(itemAttr.destribe)
	--显示选中的动画
    gGetGameUIManager():AddUIEffect(self.m_boxItem[tostring(2)], "geffect/ui/MY_texiao/xianshou_ani1", true) --�ϳ���Ч ����
	self:refreshPriceAndNumLimit()

	
	
--	self:RefeshAllCellPos()
end
function XianShiDlg:handleQuitBtnClicked(e)--关闭
if _instance then 
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function XianShiDlg:handleGroupBtnClicked(args)

	
	local nSysId = CEGUI.toWindowEventArgs(args).window:getID()
	self.selectedItemId = nSysId
	
	
	 
	--设置选择的道具 展示介绍
	local xianshi = BeanConfigManager.getInstance():GetTableByName("item.cxianshi"):getRecorder(self.selectedItemId)
	local itemAttr = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(xianshi.item)
	self.m_boxItemJsBox:setText(itemAttr.destribe)


	local Btnname = CEGUI.toWindowEventArgs(args).window:getName()
	local aID = string.match(Btnname, "%d+$")
	-- GetCTipsManager():AddMessageTip(aID)
	-- GetCTipsManager():AddMessageTip(self.AAA)


	--清空选中的动画
	gGetGameUIManager():AddUIEffect(self.m_boxItem[tostring(1)], "geffect/ui/MY_texiao/xianshou_ani0", true) -- 播放动画 附着的变量、动画路径、是否循环
	gGetGameUIManager():AddUIEffect(self.m_boxItem[tostring(2)], "geffect/ui/MY_texiao/xianshou_ani0", true) -- 播放动画 附着的变量、动画路径、是否循环
	gGetGameUIManager():AddUIEffect(self.m_boxItem[tostring(3)], "geffect/ui/MY_texiao/xianshou_ani0", true) -- 播放动画 附着的变量、动画路径、是否循环
	--显示选中的动画
    gGetGameUIManager():AddUIEffect(self.m_boxItem[aID], "geffect/ui/MY_texiao/xianshou_ani1", true) --�ϳ���Ч ����
	

	self:refreshPriceAndNumLimit()
end

function XianShiDlg:refreshPriceAndNumLimit()
    self.numText:setText(1)
	--local num = RoleItemManager.getInstance():GetBagItem(self.selectedItemkey):GetNum()
	local gaoji =BeanConfigManager.getInstance():GetTableByName(CheckTableName("item.cxianshi")):getRecorder(self.selectedItemId)
	local bi=0
	if gaoji.huobi==1 then
		self.huobi1:setProperty("Image", "set:common image:common_yinb")
		self.huobi2:setProperty("Image", "set:common image:common_yinb")
		bi=1
	elseif gaoji.huobi==2 then
		self.huobi1:setProperty("Image", "set:common image:common_jinb")
		self.huobi2:setProperty("Image", "set:common image:common_jinb")
		bi=2
	elseif gaoji.huobi==3 then
		self.huobi1:setProperty("Image", "set:lifeskillui image:fushi")
		self.huobi2:setProperty("Image", "set:lifeskillui image:fushi")
		bi=3
	end
	CurrencyManager.registerTextWidget(bi, self.ownMoneyText)
    --��������

    --local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
	--if goodsConf and goodsConf.limitType ~= 0 then
	--	local sellNum = ShopManager.goodsSellNumLimit[self.selectedGoodsId]
	--	self.maxNum = sellNum and math.min(num, goodsConf.limitSaleNum-sellNum) or 0
	--else
		self.maxNum = gaoji.num-self.itemnum[gaoji.item]
	--end

    self.curPrice = gaoji.money
    --self.curPrice = math.floor(self.curPrice * 5 / 6)
    self.priceText:setText(MoneyFormat(self.curPrice))
end


function XianShiDlg:clickChushou()
    local num = tonumber(self.numText:getText())
	if num == 0 then
		return
	end

    if self.selectedItemId ~= 0 then
		local p = require("protodef.fire.pb.shop.cxianshigoumai"):new()
		p.itemkey = self.selectedItemId
		p.num = num
		LuaProtocolManager:send(p)
    end
	self.numText:setText(1)
end

function XianShiDlg:openLockSuccess()
    self:clickChushou()
end

function XianShiDlg:handleBuyClicked(args)
    self:clickChushou()
end

function XianShiDlg:handleMinusClicked(args)
	if  self.selectedItemId == 0 then
		return
	end
	local num = tonumber(self.numText:getText())
	if num > 1 then
		self.numText:setText(num-1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num-1)))
	end
end

function XianShiDlg:handleAddClicked(args)
	if self.selectedItemId == 0 then
		return
	end
	local xianshi =BeanConfigManager.getInstance():GetTableByName(CheckTableName("item.cxianshi")):getRecorder(self.selectedItemId)
	local numx = xianshi.num-self.itemnum[xianshi.item]
	local num = tonumber(self.numText:getText())
	if num < numx then
		self.numText:setText(num+1)
		self.priceText:setText(MoneyFormat(self.curPrice * (num+1)))
	end
end

function XianShiDlg:handleNumTextClicked(args)
	if self.selectedItemId == 0 then
		return
	end
	
	if NumKeyboardDlg.getInstanceNotCreate() then
		NumKeyboardDlg.getInstanceNotCreate():SetVisible(true) --���ּ�����������
		return
	end
	
	local dlg = NumKeyboardDlg.getInstanceAndShow()
	if dlg then
		dlg:setTriggerBtn(self.numText)
		dlg:setMaxValue(self.maxNum)
		dlg:setInputChangeCallFunc(XianShiDlg.onNumInputChanged, self)
		
		local p = self.numText:GetScreenPos()
		SetPositionOffset(dlg:GetWindow(), p.x-110, p.y-10, 0, 1)
	end
end

function XianShiDlg:onNumInputChanged(num)
	if num == 0 then
		self.numText:setText(1)
		self.priceText:setText(MoneyFormat(self.curPrice))
	else
		self.numText:setText(num)
		self.priceText:setText(MoneyFormat(self.curPrice * num))
	end
end

function XianShiDlg:onSellNumLimitChanged()
    if self.selectedItemkey == 0 then
        return
    end
    --��������
    local item = RoleItemManager.getInstance():GetBagItem(self.selectedItemkey)
    if not item then
        return
    end
	local num = item:GetNum()
	local gaoji =BeanConfigManager.getInstance():GetTableByName(CheckTableName("item.cgaojichushou")):getRecorder(self.selectedItemId)
    --local goodsConf = BeanConfigManager.getInstance():GetTableByName(CheckTableName("shop.cgoods")):getRecorder(self.selectedGoodsId)
	--if goodsConf and goodsConf.limitType ~= 0 then
	--	local sellNum = ShopManager.goodsSellNumLimit[self.selectedGoodsId]
	--	self.maxNum = sellNum and math.min(num, goodsConf.limitSaleNum-sellNum) or 0
	--else
		self.maxNum = num
	--end

    local curNum = tonumber(self.numText:getText())
    if curNum > 1 and curNum > self.maxNum then
        self.numText:setText(self.maxNum)
        self.priceText:setText(MoneyFormat(self.curPrice * self.maxNum))
    end
end

function XianShiDlg.onEventItemNumChange(bagid, itemkey, itembaseid)
	if not _instance or bagid ~= fire.pb.item.BagTypes.BAG then
		return
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local item = roleItemManager:GetBagItem(itemkey)
	if item and item:GetBaseObject().bCanSaleToNpc == 0 then
		return
	end

	for i=0, _instance.sellItemTable:GetCellCount()-1 do
		local cell = _instance.sellItemTable:GetCell(i)
		if not cell:isVisible() then
			break
		end
		
		if cell:getID() == itembaseid then
			local curNum = (item and item:GetNum() or 0)
			--print('item num change', itembaseid, curNum)
			if curNum == 0 then
				_instance:refreshSellGoodsList()
			elseif itemkey == _instance.selectedItemkey then
                _instance:refreshPriceAndNumLimit()
				cell:SetTextUnit(curNum > 1 and curNum or "")
			end
			return
		end
	end

	_instance:refreshSellGoodsList()
end

function XianShiDlg.onInternetReconnected()
	if _instance then
		_instance:refreshSellGoodsList() --ˢ�³�����Ʒ�б�
	end
end

return XianShiDlg
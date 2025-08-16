

local super = require "logic.singletondialog";
local _instance
local sCellNum = 12;
local index = 0;
local data =nil;
local clid =0;
JingMaiXingChenCell1 = { };
setmetatable(JingMaiXingChenCell1, super);
JingMaiXingChenCell1.__index = JingMaiXingChenCell1;

function JingMaiXingChenCell1_GetItemCellByPos(pos)
	local dlg = JingMaiXingChenCell1:getInstanceOrNot();
	if dlg then
		return dlg:GetItemCellByPos(pos);
	end
	return nil;
end

function JingMaiXingChenCell1_IsVisible()
	local dlg = JingMaiXingChenCell1:getInstanceOrNot();
	if dlg then
		return dlg:IsVisible();
	end
	return false;
end

function JingMaiXingChenCell1_GetSingleton()
	if JingMaiXingChenCell1:getInstanceOrNot() then
		return 1;
	else
		return 0;
	end
end

function JingMaiXingChenCell1:HandleConfirmGetBack(e)

	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);


	require "protodef.fire.pb.item.conekeymovetemptobag";
	local requestGetBack = COneKeyMoveTempToBag.Create();

	LuaProtocolManager.getInstance():send(requestGetBack);

	return true;
end



function JingMaiXingChenCell1:HandleGetBack(e)


	if clid~=0 then
		local p = require "logic.workshop.jingmai.cjingmaisel":new()
		p.idx = 5 --normal
		p.index = index--normal
		p.itemkey = clid--normal
		require "manager.luaprotocolmanager":send(p)
		self:DestroyDialog();
	end

	--	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(150147);
	--	if (tip.id ~= -1) then
	--		GetCTipsManager():AddMessageTip(tip.msg, false);
	--	end
	--	return true;



	return true;
end
function JingMaiXingChenCell1:HandleBack(e)
	self:DestroyDialog();
	return true;
end
function JingMaiXingChenCell1:HandleCloseBtnClick(e)
	self:DestroyDialog();
	return true;
end

function JingMaiXingChenCell1:SetVisible(bVisible)
	super.SetVisible(self, bVisible);
	if (bVisible) then
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag)
	else
		MainControl.ShowBtnInFirstRow(MainControlBtn_TmpBag, false)
	end
end

function JingMaiXingChenCell1:HandleTableClick(e)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()

	local MouseArgs = CEGUI.toMouseEventArgs(e);
	local pCell = CEGUI.toItemCell(MouseArgs.window);
	if (pCell == nil or roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP) == nil) then
		return true;
	end
	if (roleItemManager:IsBagFull()) then
		GetCTipsManager():AddMessageTipById(141413);
		return true;
	end

	if ((MouseArgs.button == CEGUI.LeftButton or MouseArgs.button == CEGUI.RightButton) and((1 == GetMainPackDlg()))) then
		local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP)
		roleItemManager:MoveItem(pItem, pItem:GetNum(), fire.pb.item.BagTypes.BAG, -1);
		return true;
	end

	return true;
end



function JingMaiXingChenCell1:HandleItemCellClickShowSel(e)
	if (self.m_pOldItemCell) then
		self.m_pOldItemCell:SetSelected(false);
	end
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);
	self.m_pOldItemCell = pCell;

	pCell:SetSelected(true);

	return true;
end

function JingMaiXingChenCell1:HandleConfirmClearPack(e)
	local windowargs = CEGUI.toWindowEventArgs(e);
	local pConfirmBoxInfo = tostConfirmBoxInfo(windowargs.window:getUserData());
	gGetMessageManager():RemoveConfirmBox(pConfirmBoxInfo);

	require "protodef.fire.pb.item.ccleantemppack";
	local clearitems = CCleanTempPack.Create();
	LuaProtocolManager.getInstance():send(clearitems);
	return true;
end

function JingMaiXingChenCell1:HandleClearPack(e)
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (roleItemManager:IsTemporyPackEmpty() == true) then
		self:DestroyDialog();
		return true;
	end

	local tip = GameTable.message.GetCMessageTipTableInstance():getRecorder(120058);
	if (tip.id ~= -1) then
		gGetMessageManager():AddConfirmBox(eConfirmCleanTempBag, tip.msg,
		JingMaiXingChenCell1.HandleConfirmGetBack, self,
		MessageManager.HandleDefaultCancelEvent, MessageManager);

	end

	return true;
end


function JingMaiXingChenCell1:HandleItemCellDoubleClick(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);
	local pCell = CEGUI.toItemCell(MouseArgs.window);

    local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	if (nil ~= roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP)) then
		local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.TEMP)
		local nItemKey = pItem:GetThisID();

		require "protodef.fire.pb.item.ctransitem"
		local p = CTransItem.Create()
		p.srckey = nItemKey;
		p.srcpackid = fire.pb.item.BagTypes.TEMP;
		p.dstpackid = fire.pb.item.BagTypes.BAG;
		p.number = -1;
		p.dstpos = -1;
		p.page = -1;
		p.npcid = -1;
		LuaProtocolManager.getInstance():send(p)

		local tipDlg = require 'logic.tips.commontipdlg'.getInstanceNotCreate();
		if (tipDlg) then
			tipDlg:DestroyDialog();
		end
	end
	return true;
end


function JingMaiXingChenCell1:GetItemCellByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return self.m_pItemCells[pos];
	end
	return nil;

end

function JingMaiXingChenCell1:GetItemTableByPos(pos)
	if (pos >= 0 and pos < sCellNum) then
		return nil;
	end
	return nil;

end

function JingMaiXingChenCell1:OnCreate()
	super.OnCreate(self);
	--self:SetCloseIsHide(true);
	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_pBtnGetBack = CEGUI.toPushButton(winMgr:getWindow("jingmaixingchencell1/btnyi"));
	self.m_pBtnGetBack:subscribeEvent(CEGUI.PushButton.EventClicked, JingMaiXingChenCell1.HandleGetBack, self);
	self.editbox = CEGUI.toRichEditbox(winMgr:getWindow("jingmaixingchencell1/xiantips"))
	self.pane = CEGUI.toScrollablePane(winMgr:getWindow("jingmaixingchencell1/scrolllabelpane"));
	self.m_table = CEGUI.toItemTable(winMgr:getWindow("jingmaixingchencell1/table"));
	self.m_table:subscribeEvent(CEGUI.ItemTable.EventTableDoubleClick, JingMaiXingChenCell1.HandleItemCellDoubleClick, self);
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local baginfo=roleItemManager:GetBagInfo()
	local list={}
	local list2={}
	if baginfo then
		list= baginfo[1]
	end
	for k, v in pairs(list) do
		if 758==v:GetItemTypeID() then
			list2[k]=v
		end
	end
	local column = self.m_table:GetColCount()
	self.m_table:setVisible(true)
	local row = math.ceil(40 / column)
	self.m_table:SetRowCount(row)
	local h = self.m_table:GetCellHeight()
	local spaceY = self.m_table:GetSpaceY()
	self.m_table:setHeight(CEGUI.UDim(0, (h+spaceY)*row))
	self.pane:EnableAllChildDrag(self.pane)

	local i=1
	local ss = "jingmaixingchencell1/table_ItemCell_" .. 0;
	self.m_pItemCells[i] = CEGUI.toItemCell(winMgr:getWindow(ss));
	self.m_pItemCells[i]:SetCellTypeMask(1);
	self.m_pItemCells[i]:SetHaveSelectedState(true);
	self.m_pItemCells[i]:setID(0)
	self.m_pItemCells[i]:subscribeEvent(CEGUI.Window.EventMouseClick, JingMaiXingChenCell1.HandleShowTootips, self);

	self.m_pItemCells[i]:SetImage("huobanui", "huoban_jiahao")

    local i=1
	for k, v in pairs(list2) do
		local ss = "jingmaixingchencell1/table_ItemCell_" .. i;
		self.m_pItemCells[i] = CEGUI.toItemCell(winMgr:getWindow(ss));
		self.m_pItemCells[i]:SetCellTypeMask(1);
		self.m_pItemCells[i]:SetHaveSelectedState(true);
		local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(v:GetBaseObject().id)
		if needItemCfg then
			self.m_pItemCells[i]:SetImage(gGetIconManager():GetItemIconByID(needItemCfg.icon))
			SetItemCellBoundColorByQulityItemWithId(self.m_pItemCells[i],needItemCfg.id)
			self.m_pItemCells[i]:setID(k)
			--self.m_pItemCells[i]:setID(needItemCfg.id)
		end
		--self.m_pItemCells[i]:subscribeEvent("TableClick", JingMaiXingChenCell1.HandleClickItemCell, self)
		--self.m_pItemCells[i]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, JingMaiXingChenCell1.HandleTableClick, self);
		self.m_pItemCells[i]:subscribeEvent(CEGUI.ItemCell.EventCellClick, JingMaiXingChenCell1.HandleItemCellClickShowSel, self);
		self.m_pItemCells[i]:subscribeEvent(CEGUI.Window.EventMouseClick, JingMaiXingChenCell1.HandleShowTootips, self);
		i=i+1
	end


	roleItemManager:InitBagItem(fire.pb.item.BagTypes.TEMP);
end
function JingMaiXingChenCell1:HandleShowTootips(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);
	local pCell = CEGUI.toItemCell(MouseArgs.window);
	if pCell:getID()==0 then
		local e = CEGUI.toMouseEventArgs(e)
		local touchPos = e.position
		--�ǳ��ᾧ��ȡ;��
		local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(629).value))
		if not itemAttrCfg then
			return
		end
		local nPosX = touchPos.x
		local nPosY = touchPos.y
		local Commontipdlg = require "logic.tips.commontipdlg"
		local commontipdlg = Commontipdlg.getInstanceAndShow()
		local nType = Commontipdlg.eType.eComeFrom
		--nType = Commontipdlg.eType.eNormal

		commontipdlg:RefreshItem(nType,tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(629).value),nPosX,nPosY)
		commontipdlg.nComeFromItemId = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(629).value)
		return
	end
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local pItem = roleItemManager:FindItemByBagAndThisID(pCell:getID(),1)
	----if nil ~= roleItemManager:getItem(pCell:getID(), 1) then
	--	local Pos = pCell:GetScreenPos();
	--	--local pItem = roleItemManager:getItem(pCell:getID(), 1)
	--	--local bLuaHandleSuccess = false;
	--
	--	local nPosX = Pos.x;
	--	local nPosY = Pos.y;
	--	--local nItemKey = pItem:GetThisID();
	--	--local nBagId = pItem:GetLocation().tableType;
	--
	--	local screenSize = GetScreenSize();
	--	if (nPosX > screenSize.width / 2) then
	--		nPosX = screenSize.width / 8;
	--	else
	--		nPosX = screenSize.width - screenSize.width / 8;
	--	end
	--	local Commontipdlg = require "logic.tips.commontipdlg"
	--	local commontipdlg = Commontipdlg.getInstanceAndShow()
	--	local nType = Commontipdlg.eType.eNormal
	--
    --	commontipdlg:RefreshItem(nType,pItem:GetBaseObject().id,nPosX,nPosY,pItem:GetObject())

	self.editbox:Clear()
	local needItemCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(pItem:GetBaseObject().id)
	self.editbox:AppendText(CEGUI.String(needItemCfg.name), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffbdc47")))
	self.editbox:AppendBreak()
	self.editbox:AppendText(CEGUI.String("  "), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffbdc47")))
	self.editbox:AppendBreak()
	-- self.editbox:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11000).."  "..pItem:GetObject().xingchennaijiu), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffbdc47")))
	-- self.editbox:AppendBreak()
	-- self.editbox:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(1456)..pItem:GetObject().xingchenpinzhi), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("fffbdc47")))
	-- self.editbox:AppendBreak()

	local tableAllId = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaixiaoguo"):getAllID()
	for k,v in pairs(tableAllId) do
		local xiaoguos = BeanConfigManager.getInstance():GetTableByName("skill.cjingmaixiaoguo"):getRecorder(v)
		if xiaoguos.zhiye==gGetDataManager():GetMainCharacterSchoolID() and xiaoguos.jingmaiid==data.fangan then
			if xiaoguos.xingchens[index-1]~=0 then
				local skill2 = BeanConfigManager.getInstance():GetTableByName("skill.cequipskill"):getRecorder(xiaoguos.xingchens[index-1])
				self.editbox:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(11929)), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff87cefa"))) --????
				self.editbox:AppendBreak()

				-- local sb = StringBuilder:new()
				-- sb:Set("parameter1", skill2.jingmaizhi*pItem:GetObject().xingchenpinzhi/100)
				-- local strMsg = sb:GetString(skill2.describe)
				-- sb:delete()
				-- self.editbox:AppendText(CEGUI.String(strMsg), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("ff7fff00"))) --????

				-- self.editbox:AppendBreak()
			end
		end
	end


	self.editbox:Refresh()




	   clid=pCell:getID()
		--local ret = LuaShowItemTip(nBagId, nItemKey, nPosX, nPosY);
		--if (ret == 1) then
		--	bLuaHandleSuccess = true;
		--end

	--end

	return true;
end
--function Commontiphelper.appendText(richBox,strChat)
--
--	local nIndex = string.find(strChat, "<T")
--	if nIndex then
--		richBox:AppendParseText(CEGUI.String(strChat))
--	else
--		local defaultColor = nil
--		local colorStr = richBox:GetColourString():c_str()
--		if colorStr == "FFFFFFFF" then
--			--fff2df
--			defaultColor = Commontiphelper.defaultColor()
--		else
--			defaultColor = CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colorStr))
--		end
--		richBox:AppendText(CEGUI.String(strChat),defaultColor)
--	end
--end
function Workshopmanager:HandleClickItemCell(args)

	local e = CEGUI.toWindowEventArgs(args)
	local nItemId = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position

	local itemAttrCfg = BeanConfigManager.getInstance():GetTableByName("item.citemattr"):getRecorder(nItemId)
	if not itemAttrCfg then
		return
	end
	local nPosX = touchPos.x
	local nPosY = touchPos.y

end
function JingMaiXingChenCell1:GetLayoutFileName()
	return "jingmaixingchencell1.layout";
end
function JingMaiXingChenCell1.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end
function JingMaiXingChenCell1.ToggleOpenClose()
	if not _instance then
		_instance = JingMaiXingChenCell1:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
--function JingMaiXingChenCell1:OnClose()
--	if (self.m_pMainFrame) then
--		self.m_pMainFrame:setVisible(false);
--
--		if (gGetMessageManager()) then
--			gGetMessageManager():CloseConfirmBox(eConfirmCleanTempBag);
--		end
--
--	end
--
--end

function JingMaiXingChenCell1.new()
	local obj = { };
	setmetatable(obj, JingMaiXingChenCell1);

    obj.m_eDialogType = obj.m_eDialogType or {};
	obj.m_eDialogType[DialogTypeTable.eDialogType_InScreenCenter] = 1;

	obj.m_pItemCells = { };
	for i = 0, sCellNum - 1 do
		obj.m_pItemCells[i] = nil;
	end

	return obj;
end

function JingMaiXingChenCell1:getInstance(xindex,xdata)
	index=xindex
	data=xdata
	if not _instance then
		_instance = JingMaiXingChenCell1.new();
		_instance:OnCreate();
	end
	return _instance;
end

function JingMaiXingChenCell1:GetSingletonDialogAndShowIt(xindex,xdata)
	index=xindex
	data=xdata
	if not _instance then
		_instance = JingMaiXingChenCell1.new();
		_instance:OnCreate();
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true);
	end
	return _instance;
end


return JingMaiXingChenCell1;

local EQUIPNUM = 27;

CEquipDialog =
{
	m_pEquipCell = { }
};
CEquipDialog.__index = CEquipDialog;

function CEquipDialog:GetWindow()
	return self.m_pParentWindow;
end

function CEquipDialog:SetSelectID(nID)
	self.m_nSelectCellID = nID;
end

function CEquipDialog:GetSelectID()
	return self.m_nSelectCellID;
end

function CEquipDialog:removeEventMapChangeFunctor()
	if (gGetScene() and self.mEventMapChangeFunctor) then
		gGetScene().EventMapChange:RemoveScriptFunctor(self.mEventMapChangeFunctor);
		self.mEventMapChangeFunctor = nil;
	end
end

function CEquipDialog:GetItemTableByPos(pos)
	return nil;
end

function CEquipDialog:showEffectOnEquipCell(nSecondType, nEffectId)
	if (nSecondType >= eEquipType_MAXTYPE) then
		return;
	end

	local pEquipCell = m_pEquipCell[nSecondType];
	if (not pEquipCell) then
		return;
	end
	local bCycle = false;

	local strEffectName = MHSD_UTILS.get_effectpath(nEffectId);
	gGetGameUIManager():AddUIEffect(pEquipCell, strEffectName, bCycle);

end

function CEquipDialog:HandleWindowPosChange(e)
	local pt = self.m_pSpriteBack:GetScreenPosOfCenter();
	local wndHeight = self.m_pSpriteBack:getPixelSize().height;
	local xPos =(pt.x);
	local yPos =(pt.y + wndHeight / 3.0);

	if (self.m_pEquipUISprite) then
		self.m_pEquipUISprite:SetUILocation(Nuclear.NuclearPoint(xPos, yPos));
	end
	return true;
end

function CEquipDialog:UpdataModel()
	if (self.m_pEquipUISprite) then
        -- self.m_pEquipUISprite:SetUIDirection(Nuclear.XPDIR_BOTTOMRIGHT);
        -- local info = GetMainCharacter():GetComponentInfo();
        -- self.m_pEquipUISprite:RefreshSpriteComponent(info);
    local pA = GetMainCharacter():GetSpriteComponent(eSprite_DyePartA)
    local pB = GetMainCharacter():GetSpriteComponent(eSprite_DyePartB)
    self.m_pEquipUISprite:SetDyePartIndex(0, pA)
    self.m_pEquipUISprite:SetDyePartIndex(1, pB)
        -- local zuoqi = GetMainCharacter():GetSpriteComponent(eSprite_Horse)
        local wuqi = GetMainCharacter():GetSpriteComponent(eSprite_Weapon)
        self.m_pEquipUISprite:SetSpriteComponent(eSprite_Weapon,wuqi)
        -- self.m_pEquipUISprite:SetSpriteComponent(eSprite_Horse,zuoqi)


    end
end

function CEquipDialog:GetEquipTabBackImage(loc)
	if (loc == eEquipType_CUFF) then
		return "Cuff";
	elseif loc == eEquipType_ADORN then
		return "Accessories";
	elseif loc == eEquipType_LORICAE then
		return "Armour";
	elseif loc == eEquipType_ARMS then
		return "Weapon";
	elseif loc == eEquipType_TIRE then
		return "Head";
	elseif loc == eEquipType_BOOT then
		return "Shoe";
	elseif loc == eEquipType_WAISTBAND then
		return "Belt";
	elseif loc == eEquipType_EYEPATCH then
	elseif loc == eEquipType_RESPIRATOR then
	elseif loc == eEquipType_VEIL then
	elseif loc == eEquipType_CLOAK then
		return "Mask";
	elseif loc == eEquipType_FASHION then
		return "Fashion";
	else
	end
	return "";
end

--[[
function CEquipDialog:HandleShiftClickItem(pItem)
	if (GetChatManager() and pItem and pItem:GetObject()) then
		local ItemColor = CEGUI.colour(pItem:GetLinkTipsColor());
		local bind = pItem:GetObject().data.flags;
		local loseeffecttime = pItem:GetObject().data.loseeffecttime;
		GetChatManager():AddObjectTipsLinkToCurInputBox(pItem:GetName(), gGetDataManager():GetMainCharacterID(), fire.pb.talk.ShowInfo.SHOW_ITEM, pItem:GetThisID(), pItem:GetBaseObject().id, 0, fire.pb.item.BagTypes.EQUIP, true, bind, loseeffecttime, ItemColor);
	end
	return true;
end
--]]

function CEquipDialog:HandleDrawSprite()
	if (self.m_pEquipUISprite) then
		self.m_pEquipUISprite:RenderUISprite();
	end
end

function CEquipDialog:HandleTableDoubleClick(e)
	local MouseArgs = CEGUI.toMouseEventArgs(e);

	local pCell = CEGUI.toItemCell(MouseArgs.window);
	if (pCell == nil) then
		return false;
	end

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.EQUIP)
	if (pItem == nil) then
		return false;
	end

	self:Unequip(pItem);

	local dlg = require 'logic.tips.commontipdlg'.getInstanceNotCreate();
	if dlg then
		dlg:DestroyDialog();
	end

	return true;
end

function CEquipDialog:Unequip(item)
	local desPos = CMainPackDlg:GetSingleton():GetFirstEmptyCell();
	if (desPos == -1) then
		if (GetChatManager()) then
			GetChatManager():AddTipsMsg(120059);
		end
	else
		if (item:GetObject() ~= nil) then
			local roleItemManager = require("logic.item.roleitemmanager").getInstance()
            roleItemManager:UnEquipItem(item:GetThisID(), desPos);
		end
	end
end

function CEquipDialog:UpdateTotalScore()
	local roleScore = gGetDataManager():GetMainCharacterData().roleScore;
	local stream = "";
	local viplevel = gGetDataManager():GetVipLevel()
	stream =  MHSD_UTILS.get_resstring(1637) .. roleScore;
	self.m_TotalScore:setText(stream, 0xFF5E3F25);
	self.m_TotalVipScore:setText("SVIP-"..tostring(viplevel));
end

function CEquipDialog:UpdateEquipTotalScore()
	local score = 0;
	local jewelryScore = 0;
	for i = 0, EQUIPNUM - 1 do
		local pCell = self.m_pEquipCell[i];
		if (pCell ~= nil) then
	        local roleItemManager = require("logic.item.roleitemmanager").getInstance()
            local pItem = roleItemManager:getItem(pCell:getID2(), fire.pb.item.BagTypes.EQUIP)
			if (pItem) then
				if (pItem:GetObject() and pItem:GetObject().bNeedRequireData) then
		            require "protodef.fire.pb.item.cgetitemtips"
		            local send = CGetItemTips.Create()
					send.packid = fire.pb.item.BagTypes.EQUIP
					send.keyinpack = pItem:GetThisID()
					LuaProtocolManager.getInstance():send(send)
				end
				if (pItem:GetSecondType() == 6) then
					jewelryScore = jewelryScore + GetEquipScore(pItem:GetLocation().tableType, pItem:GetThisID()) -- pItem:GetEquipScore();
				else
					score = score + GetEquipScore(pItem:GetLocation().tableType, pItem:GetThisID()) -- pItem:GetEquipScore();
				end
			end
		end
	end
	local stream = "";
	stream = stream .. MHSD_UTILS.get_resstring(1637);
	stream = stream .. score;
	self.m_TotalScore:setText(stream);
	stream = "";
	stream = stream .. MHSD_UTILS.get_resstring(3000);
	stream = stream .. jewelryscore;
	self.m_TotalJewelryScore:setText(stream, 0xFF5E3F25);

	local total = jewelryScore + score;
	stream = "";
	stream = MHSD_UTILS.get_resstring(1637) .. total;
	self.m_TotalScore:setText(stream, 0xFF5E3F25);
end

function CEquipDialog:GetItemCellByPos(pos)
	--if (pos == eEquipType_VEIL) then
	--	return self.m_pEquipCell[eEquipType_EYEPATCH];
	--end

	return self.m_pEquipCell[pos];
end

function CEquipDialog:addEquipEffect(effectId)
	self.m_pPackEquipEffect = self.m_pEquipUISprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(effectId), false);
    self.m_pPackEquipEffect:SetScale(2,2)
end

function CEquipDialog:removeEquipEffect()
	if (self.m_pEquipUISprite) then
		if (self.m_pPackEquipEffect) then
			self.m_pEquipUISprite:RemoveEngineSpriteDurativeEffect(self.m_pPackEquipEffect);
			self.m_pPackEquipEffect = nil;
		end
	end
end

function CEquipDialog:InitEquipEffect()
	if (self.m_pEquipUISprite) then
		local roleItemManager = require("logic.item.roleitemmanager").getInstance()
        local effectId = roleItemManager:getEquipEffectId();
		if (self.m_pPackEquipEffect == nil) then
			self.m_pPackEquipEffect = self.m_pEquipUISprite:SetEngineSpriteDurativeEffect(MHSD_UTILS.get_effectpath(effectId), false);
            if self.m_pPackEquipEffect then
                self.m_pPackEquipEffect:SetScale(2,2)
            end
		end
	end
end

function CEquipDialog:InitSpriteModel()
	local shapeid = gGetDataManager():GetMainCharacterShape();
    shapeid = shapeid
	if (self.m_pEquipUISprite) then
		if (self.m_pEquipUISprite:GetModelID() ~= shapeid) then
			self.m_pEquipUISprite:SetModel(shapeid);
		end
	else
		self.m_pEquipUISprite = UISprite:new(shapeid);
	end

	local pt = self.m_pSpriteBack:GetScreenPosOfCenter();
	local wndHeight = self.m_pSpriteBack:getPixelSize().height;
	local xPos =(pt.x);
	local yPos =(pt.y + wndHeight / 3.0);
	self.m_pEquipUISprite:SetUILocation(Nuclear.NuclearPoint(xPos, yPos));
	--self.m_pEquipUISprite:SetUIScale(1.5)

	self:UpdataModel();
end

function CEquipDialog:SetFootprint(id)
	if (id == self.m_footprint) then
		return;
	end
	self.m_footprint = id;
	if (self.m_pFootprintEffect) then
		gGetGameUIManager():RemoveUIEffect(self.m_pFootprintEffect);
		self.m_pFootprintEffect = nil;
	end
end
function CEquipDialog:GetMBagOffset()
	return GetBagOffset()
end
function CEquipDialog.GetSingleton()
	return CEquipDialog:getInstance();
end
function CEquipDialog:getInstance()
	if not self._instance then
		self._instance = CEquipDialog.new();
		self._instance:OnCreate();
	end
	return self._instance;
end
function CEquipDialog:OnCreate()
	self.mEventMapChangeFunctor = gGetScene().EventMapChange:InsertScriptFunctor( function()
		self:OnMapChange();
	end );

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pSpriteBack = CEGUI.toWindow(winMgr:getWindow("EquipDialog/spriteBack"));
	self.m_pEquipWindowBack = CEGUI.toWindow(winMgr:getWindow("EquipDialog/Back/Pattern"));
	self.m_pEquipWindowBack:setMousePassThroughEnabled(true);

	self.m_pSpriteBack:setAlwaysOnTop(true);


	self.m_TotalScore = CEGUI.toWindow(winMgr:getWindow("EquipDialog/point"));
	self.m_TotalJewelryScore = CEGUI.toWindow(winMgr:getWindow("EquipDialog/ring"));
	
	self.clearequip = CEGUI.toPushButton(winMgr:getWindow("EquipDialog/Back/Pattern/clearequip"));
	self.clearequip:subscribeEvent(CEGUI.PushButton.EventClicked, CEquipDialog.HandleClearEquipBtnClick, self);
	local tabCtrl = { id = 0, selectedIdx = 0 }
	tabCtrl.button0 = CEGUI.toGroupButton(winMgr:getWindow("MainPackDlg/equip"))
	tabCtrl.button1 = CEGUI.toGroupButton(winMgr:getWindow("MainPackDlg/lingshi"))
	tabCtrl.button2 = CEGUI.toGroupButton(winMgr:getWindow("MainPackDlg/fabao"))
	tabCtrl.button3 = CEGUI.toGroupButton(winMgr:getWindow("MainPackDlg/shizhuang"))
	tabCtrl.pane0 = CEGUI.toScrollablePane(winMgr:getWindow("EquipDialog/Back/Pattern/equip"));
	tabCtrl.pane1 = CEGUI.toScrollablePane(winMgr:getWindow("EquipDialog/Back/Pattern/lingshi"));
	tabCtrl.pane2 = CEGUI.toScrollablePane(winMgr:getWindow("EquipDialog/Back/Pattern/fabao"));
	tabCtrl.pane3 = CEGUI.toScrollablePane(winMgr:getWindow("EquipDialog/Back/Pattern/fashion"));
	tabCtrl.pane0:setVisible(true)
	function tabCtrl:handleGroupButtonClicked(args)
		local btn = CEGUI.toWindowEventArgs(args).window
		self.pane0:setVisible( btn == self.button0 )
		self.pane1:setVisible( btn == self.button1 )
		self.pane2:setVisible( btn == self.button2 )
		self.pane3:setVisible( btn == self.button3 )
		if(btn == self.button0)then
			self.selectedIdx = 0;
		elseif(btn == self.button1)then
			self.selectedIdx = 1;
		elseif(btn == self.button2)then
			self.selectedIdx = 2;
		elseif(btn == self.button3)then
			self.selectedIdx = 3;
		end
        CMainPackDlg.GetSingleton():SetMBagOffset()
	end
	tabCtrl.button0:subscribeEvent("SelectStateChanged", tabCtrl.handleGroupButtonClicked, tabCtrl)
	tabCtrl.button1:subscribeEvent("SelectStateChanged", tabCtrl.handleGroupButtonClicked, tabCtrl)
	tabCtrl.button2:subscribeEvent("SelectStateChanged", tabCtrl.handleGroupButtonClicked, tabCtrl)
	tabCtrl.button3:subscribeEvent("SelectStateChanged", tabCtrl.handleGroupButtonClicked, tabCtrl)
	self.fashionplane = CEGUI.toWindow(winMgr:getWindow("EquipDialog/Back/Pattern/fashion"));
	
    self.m_TotalVipScore = CEGUI.toWindow(winMgr:getWindow("EquipDialog/vippoint"));
	self.m_pEquipCell[eEquipType_CUFF] = nil --CEGUI.toItemCell(winMgr:getWindow("EquipDialog/cuff"));
	self.m_pEquipCell[eEquipType_ADORN] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/adorn"));
	self.m_pEquipCell[eEquipType_LORICAE] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/loricae"));
	self.m_pEquipCell[eEquipType_ARMS] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/arms"));
	self.m_pEquipCell[eEquipType_TIRE] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/tire"));
	self.m_pEquipCell[eEquipType_CLOAK] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/cloak11"));---星环
	self.m_pEquipCell[eEquipType_BOOT] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/boot"));---不知道是啥
	self.m_pEquipCell[eEquipType_WAISTBAND] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/waistband"));
	self.m_pEquipCell[eEquipType_EYEPATCH] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern01"));---经脉1
	self.m_pEquipCell[eEquipType_RESPIRATOR] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern02"));---宠物法宝
	self.m_pEquipCell[eEquipType_VEIL] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern03"));--装备经脉
	self.m_pEquipCell[eEquipType_FASHION] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/extern04"));--装备经脉
	self.m_pEquipCell[eEquipType_FASHION1] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion1"));---法宝2---金甲
	self.m_pEquipCell[eEquipType_FASHION2] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion2"));---法宝4---风袋
	self.m_pEquipCell[eEquipType_FASHION3] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion3"));---法宝3----斗篷
	self.m_pEquipCell[eEquipType_FASHION4] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/fashion4"));---法宝1---飞剑之类的
	self.m_pEquipCell[eEquipType_FASHION5] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/cloak1"));---坐骑
	self.m_pEquipCell[eEquipType_new1] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new1"));--装备经脉
	self.m_pEquipCell[eEquipType_new2] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new2"));--装备经脉
	self.m_pEquipCell[eEquipType_new3] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new3"));--装备经脉
	self.m_pEquipCell[eEquipType_new4] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new4"));--装备经脉
	self.m_pEquipCell[eEquipType_new5] = CEGUI.toItemCell(winMgr:getWindow("EquipDialog/new5"));--装备经脉

	self.xingpan=CEGUI.toItemCell(winMgr:getWindow("EquipDialog/cloak"))
	self.xingpan:subscribeEvent(CEGUI.ItemCell.EventCellClick, CEquipDialog.HandleXingPanClick, self);
	self.xingpan:SetBackGroundImage("ccui1", "xingying2");
	self.xingpan:SetImage("ccui1", "xingying2");

	self.m_ItemTable = GameItemTable:new(fire.pb.item.BagTypes.EQUIP);

	for index = 0, EQUIPNUM - 1 do
		if (self.m_pEquipCell[index]) then
			self.m_pEquipCell[index]:SetIndex(index);
			self.m_pEquipCell[index]:SetHaveSelectedState(true);
			self.m_pEquipCell[index]:SetCellTypeMask(1);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, GameItemTable.HandleShowToolTips, self.m_ItemTable);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellClick, CMainPackDlg.HandleShowSelect, self);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, CEquipDialog.HandleTableDoubleClick, self);
			self.m_pEquipCell[index]:subscribeEvent(CEGUI.ItemCell.EventCellDoubleClick, CMainPackDlg.HandleShowSelect, CMainPackDlg:getInstanceOrNot());
		end
	end

	--self.m_pEquipCell[eEquipType_CUFF]:SetBackGroundImage("common_pack", "kuang96");
	self.m_pEquipCell[eEquipType_ADORN]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_ADORN]:SetImage("ccui1", "shipin");--项链
	self.m_pEquipCell[eEquipType_LORICAE]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_LORICAE]:SetImage("ccui1", "yifu");--衣服
	self.m_pEquipCell[eEquipType_ARMS]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_ARMS]:SetImage("ccui1", "wuqi");--武器
	self.m_pEquipCell[eEquipType_TIRE]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_TIRE]:SetImage("ccui1", "toubu");--头盔
	self.m_pEquipCell[eEquipType_CLOAK]:SetBackGroundImage("chongwuui2", "sucai18");---师门法宝--改为星环
	self.m_pEquipCell[eEquipType_CLOAK]:SetImage("chongwuui2", "sucai18");
	self.m_pEquipCell[eEquipType_BOOT]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_BOOT]:SetImage("ccui1", "jiao");--鞋子
	self.m_pEquipCell[eEquipType_WAISTBAND]:SetBackGroundImage("ccui1", "kuang2");
	self.m_pEquipCell[eEquipType_WAISTBAND]:SetImage("ccui1", "yaodai");--腰带
	self.m_pEquipCell[eEquipType_EYEPATCH]:SetBackGroundImage("ccui1", "jmkuang1");----经脉1
	self.m_pEquipCell[eEquipType_EYEPATCH]:SetImage("ccui1", "xinghuang");
	self.m_pEquipCell[eEquipType_RESPIRATOR]:SetBackGroundImage("ccui1", "jmkuang2");---经脉2
	self.m_pEquipCell[eEquipType_RESPIRATOR]:SetImage("ccui1", "xinghuang");
	self.m_pEquipCell[eEquipType_VEIL]:SetBackGroundImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_VEIL]:SetImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_FASHION]:SetBackGroundImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_FASHION]:SetImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_FASHION1]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION1]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION2]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION2]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION3]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION3]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION4]:SetBackGroundImage("ccui1", "fabaokuang");---法宝
	self.m_pEquipCell[eEquipType_FASHION4]:SetImage("ccui1", "fabao");
	self.m_pEquipCell[eEquipType_FASHION5]:SetBackGroundImage("ccui1", "kuang2");---坐骑
	self.m_pEquipCell[eEquipType_FASHION5]:SetImage("ccui1", "zuoqi");---坐骑
	self.m_pEquipCell[eEquipType_new1]:SetBackGroundImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new1]:SetImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new2]:SetBackGroundImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new2]:SetImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new3]:SetBackGroundImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new3]:SetImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new4]:SetBackGroundImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new4]:SetImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new5]:SetBackGroundImage("chongwuui2", "sucai18");---装备经脉
	self.m_pEquipCell[eEquipType_new5]:SetImage("chongwuui2", "sucai18");---装备经脉

	self.m_pEquipStarEffect = CEGUI.toGUISheet(winMgr:getWindow("EquipDialog/Back/SpriteEffectTop"));
	self.m_pEquipStarEffect:setMousePassThroughEnabled(true);
	local pEffect = GameUImanager:createXPRenderEffect(0, function(id)
		local pMainPackDlg = CMainPackDlg:getInstanceOrNot();
		if (pMainPackDlg) then
			pMainPackDlg:HandleDrawSprite();
		end
	end );
	self.m_pSpriteBack:getGeometryBuffer():setRenderEffect(pEffect);
	gGetGameUIManager():AddUIEffect(CEGUI.toWindow(winMgr:getWindow("EquipDialog/point1")), MHSD_UTILS.get_effectpath(10242), true);

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    roleItemManager:InitBagItem(fire.pb.item.BagTypes.EQUIP);

	self:InitSpriteModel();
	self:UpdataModel();

	self:UpdateTotalScore();

	self:InitEquipEffect();

	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
    local pItem = roleItemManager:getItem(self.m_pEquipCell[eEquipType_EYEPATCH]:getID2(), fire.pb.item.BagTypes.EQUIP)
	--if pItem then
	--	if (pItem:GetSecondType() == eEquipType_VEIL) then
	--		self.m_pEquipCell[eEquipType_RESPIRATOR]:SetBackGroundImage("ccui1", "kuang2");
	--	end
	--end
end
function CEquipDialog:HandleXingPanClick()
	 require "logic.xingpan.xingpandlg".getInstanceAndShow()
end
function CEquipDialog:OnMapChange()
end
function CEquipDialog:HandleJinmaiBtnClick()
	if self.m_pPackEquipEffect or self.m_pEquipUISprite or self.m_pFootprintEffect then
		self:DestroyDialog()
		self.botton:setText(tostring("主角"))
		self.fashionplane:setVisible(true)
	else
		self:InitSpriteModel()
		self:InitEquipEffect();
		self.botton:setText(tostring("时装"))
		self.fashionplane:setVisible(false)
	end
end
function CEquipDialog:HandleClearEquipBtnClick()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local bagInfo = roleItemManager:GetBagInfo()
	local list = bagInfo[fire.pb.item.BagTypes.EQUIP]
	if not list then 
		return
	end
   local p =require "protodef.fire.pb.item.coffallequip":new()
   LuaProtocolManager.getInstance():send(p)
end

function CEquipDialog:DestroyDialog()
	if (self.m_pPackEquipEffect) then
		self.m_pEquipUISprite:RemoveEngineSpriteDurativeEffect(self.m_pPackEquipEffect);
		self.m_pPackEquipEffect = nil;
	end
	if (self.m_pEquipUISprite) then
		self.m_pEquipUISprite:delete();
		self.m_pEquipUISprite = nil;
	end
	if (self.m_pFootprintEffect) then
		gGetGameUIManager():RemoveUIEffect(m_pFootprintEffect);
		m_pFootprintEffect = nil;
	end
	self:removeEventMapChangeFunctor();
end

function CEquipDialog:delete()
	self:removeEventMapChangeFunctor();
end

function CEquipDialog.new(parent)
	local obj = { };
	setmetatable(obj, CEquipDialog);

	obj.m_pEquipUISprite = nil;
	obj.m_footprint = 0;
	obj.m_pFootprintEffect = nil;
	obj.m_pPackEquipEffect = nil;
	obj.m_pParentWindow = parent;
	obj.mEventMapChangeFunctor = nil;

	return obj;
end

return CEquipDialog;

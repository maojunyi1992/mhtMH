require "logic.dialog"
debugrequire "logic.mapchose.mapchosedlg"


WorldMapdlg1 = {};
setmetatable(WorldMapdlg1, Dialog);
WorldMapdlg1.__index = WorldMapdlg1;

-----------------------------public:------------------------------------
----------------////////////singleton------------------------------
local  _instance;
function WorldMapdlg1.GetSingleton()
	return _instance;
end

function WorldMapdlg1.GetSingletonDialog()
	if not _instance then
		_instance = WorldMapdlg1:new();
		_instance:OnCreate();
	end
	
	return _instance;
end

function WorldMapdlg1.GetSingletonDialogAndShowIt()
    print("切换成功")
	if not _instance then
		_instance = WorldMapdlg1:new();
		_instance:OnCreate();
	else 
		_instance:SetVisible(true);
	end
end

function WorldMapdlg1.DestroyDialog()
	if _instance then 
		_instance:CloseDialog();
	end
end

function WorldMapdlg1.SigleUpdateUseFlyFlagState()
	_instance:UpdateUseFlyFlagState();
end

function WorldMapdlg1:CloseDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function WorldMapdlg1.ToggleOpenClose()
	if not _instance then 
		_instance = WorldMapdlg1:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


----------//////////////////////////---------------------------
function WorldMapdlg1:new()
	local self = {};
	self = Dialog:new();
	setmetatable(self, WorldMapdlg1);
	self:init();
	return self;
end

function WorldMapdlg1:init( )
	self.m_bFlyRuneMode = false;
	self.m_FlyRuneItemID = -1;
end

function WorldMapdlg1.GetLayoutFileName()
	return "worldmap1.layout";
end

function WorldMapdlg1:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_CloseButton = winMgr:getWindow("WorldMap/CloseButton")
	self.m_CloseButton:subscribeEvent("Clicked", self.HandleCloseClick, self)
	self.qiehuan1 = winMgr:getWindow("WorldMap/qiehuanditu1")
	self.qiehuan1:subscribeEvent("Clicked", self.Handleqiehuan1, self)
	self.qiehuan2 = winMgr:getWindow("WorldMap/qiehuanditu11")
	self.qiehuan2:subscribeEvent("Clicked", self.Handleqiehuan2, self)
	self.m_MapImage = winMgr:getWindow("WorldMap/MapImage")
	self.m_MapImage:setAlwaysOnTop(true)
	--self.m_MapImage:subscribeEvent("Clicked", self.HandleCloseClick, self);
	--self.m_MapImage:subscribeEvent("MouseButtonUp", self.SetHighLightDisable, self);
	self.m_MapImage:setMousePassThroughEnabled(false);

	self.m_HighLight = winMgr:getWindow("WorldMap/MapImage/highlight");
	self.m_HighLight:subscribeEvent("MouseButtonUp", self.SetHighLightDisable, self)
	self.m_MapImage:setAlwaysOnTop(true)
	self.m_MapImage:setMousePassThroughEnabled(false)
	
	--跳转按钮（回小地图）
	self.m_JumpButton = CEGUI.toPushButton(winMgr:getWindow("WorldMap/MapImage/btn"))
	self.m_JumpButton:setAlwaysOnTop(true)
	self.m_JumpButton:setMousePassThroughEnabled(false)--MouseButtonDown,MouseButtonDown
	self.m_JumpButton:subscribeEvent("Clicked", self.HandleJumpClick, self)
	
	--////////////////////
	---/// 设置地图关卡按钮
	self.m_MapButtonMap = {}
	self.m_MapHighLight = {}

    self:initBtnAndData()

	self.m_PlayerPosImage = winMgr:getWindow("WorldMap/MapImage/PlayerPosImage")
	self.m_PlayerPosImage:setAlwaysOnTop(true)
	self.m_PlayerPosImage:setMousePassThroughEnabled(true)


	self.m_pSubFlyFlag = CEGUI.toCheckbox(winMgr:getWindow("WorldMap/MapImage/fly"))
	self.m_pSubFlyFlag:subscribeEvent("CheckStateChanged", self.HandleUseFlyFlagChange, self)

	--地图跳转延迟
	self.delayTime = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(199).value) * 1000
	self.Time = tonumber(GameTable.common.GetCCommonTableInstance():getRecorder(199).value) * 1000

	if self.delayTime == nil or self.Time == nil then
		self.delayTime = 0.5
		self.Time = 0.5
	end

	self.mapId = -1
	self.bGoto = false

	self:UpdateButtonPos()
	self:SetPlayerMapPos()


	self:UpdateUseFlyFlagState()

end


function WorldMapdlg1:initBtnAndData()
    self.map_icon_index = {}
    self.fuben = {}
	local num = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getAllID()
    for _, v in pairs(num) do
	    local record = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(v)
        if record.bShowInWorld2 then
            table.insert(self.map_icon_index, record.id)
            if string.find(record.sonmapid, ",") then
                local strIds = self.GetMapIDByString(record.sonmapid)
                table.insert(self.fuben, strIds)
            end
        end
    end
    local winMgr = CEGUI.WindowManager:getSingleton()
    for k,v in pairs(self.map_icon_index) do
		self.m_MapButtonMap[v] = CEGUI.toPushButton(winMgr:getWindow("WorldMap/" .. tostring(v)))
		self.m_MapButtonMap[v]:subscribeEvent("MouseButtonDown", WorldMapdlg1.HandleMapBtnDown, self)
		self.m_MapButtonMap[v]:subscribeEvent("MouseButtonUp", WorldMapdlg1.HandleMapBtnUp, self)
		self.m_MapButtonMap[v]:setID(v)
		self.m_MapHighLight[v] = winMgr:getWindow("WorldMap/MapImage/" .. tostring(v))
		self.m_MapHighLight[v]:setVisible(false)
	end
    --//GameTable.map.GetCWorldMapConfigTableInstance():ReleaseData()
end

-- 检测地图上是否由此索引的地图图标
function WorldMapdlg1.isMapIdInMap(id)
	for k,v in pairs(self.map_icon_index) do 
		if v == id then
			return true;
		end
	end
	return false;
end
function WorldMapdlg1:initMapBtnStatus()
	for k,v in pairs(self.map_icon_index) do
		self.m_MapButtonMap[v]:setVisible(true)
		self.m_MapHighLight[v]:setVisible(false)
	end
end
function WorldMapdlg1:SetHighLightDisable(e)
	for k,v in pairs(self.m_MapHighLight) do 
		v:setVisible(false)
	end
end

--点击地图块
function WorldMapdlg1:HandleMapBtnDown(e)

	if self.bGoto then
		return true
	end

	local mouseArgs = CEGUI.toMouseEventArgs(e);
	local mapId = mouseArgs.window:getID();
	print("MapID: " .. mapId)

	if mapId < 0 then
		return true;
	end

	local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId);

	if mapRecord == nil then
		return true
	end

	self.mapId = mapId

	self.m_MapHighLight[mapId]:setVisible(true)
end

function WorldMapdlg1:HandleMapBtnUp(e)

	if self.bGoto then
		return true
	end

	print("WorldMapdlg1:HandleMapButtonClick")
	local mouseArgs = CEGUI.toMouseEventArgs(e);
	local mapId = mouseArgs.window:getID();
	print("MapID: " .. mapId)

	if mapId < 0 then
		return true;
	end

	local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId);

	if mapRecord == nil then
		return true
	end

    if GetIsInFamilyFight() then
         local function ClickYes2(self, args)
            if self.mapId == mapId then
		        self.bGoto = true
	        else
		        self:SetHighLightDisable(e)
	        end 
            gGetMessageManager():CloseConfirmBox(eConfirmNormal, false)   
        end
        local msg = MHSD_UTILS.get_msgtipstring(410053)
        gGetMessageManager():AddConfirmBox(eConfirmNormal,msg,ClickYes2,self,MessageManager.HandleDefaultCancelEvent,MessageManager)
    else
        if self.mapId == mapId then
		    self.bGoto = true
	    else
		    self:SetHighLightDisable(e)
	    end    
    end

end

function WorldMapdlg1:update(delta)

	if self.bGoto then

		self.delayTime = self.delayTime - delta

		if self.delayTime > 0 then
			return true
		end

		self:SetHighLightDisable(e)

		if GetTeamManager() and not GetTeamManager():CanIMove() then--处于组队状态，无法传送

			GetChatManager():AddTipsMsg(150030) 

			self.bGoto = false
			self.delayTime = self.Time

			return true
		end

		local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(self.mapId);

		if mapRecord.maptype == 1 or mapRecord.maptype == 2 then
		
			local randX = mapRecord.bottomx - mapRecord.topx;
			randX = mapRecord.topx + math.random(0, randX);

			local randY = mapRecord.bottomy - mapRecord.topy;
			randY = mapRecord.topy + math.random(0, randY);
		
			require("logic.fuben.fubenmanager").getInstance():checkForSendExitFuben()
		
			gGetNetConnection():send(fire.pb.mission.CReqGoto(self.mapId, randX, randY));
		
			GetMainCharacter():RemoveAutoWalkingEffect()
            if gGetScene()  then
			    gGetScene():EnableJumpMapForAutoBattle(false);
		    end
			WorldMapdlg1.DestroyDialog();

		elseif mapRecord.maptype == 3 and mapRecord.sonmapid ~= "0" then

			MapChoseDlg.getInstanceAndShow();
			if MapChoseDlg.getInstanceNotCreate() then
				MapChoseDlg.getInstanceNotCreate().SetMapID(self.mapId)
				WorldMapdlg1.DestroyDialog();
			end
		else

		end

	else

		
	end

end

function WorldMapdlg1:HandleJumpClick(e)
    local mapID = gGetScene():GetMapID()
    local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapID)
    if not mapCfg or not mapCfg.smallmapRes or mapCfg.smallmapRes == "" then
        GetCTipsManager():AddMessageTipById(160140) --该场景没有小地图
        return
    end

    WorldMapdlg1.DestroyDialog()
    if not SmallMapDlg.getInstanceNotCreate() then
        SmallMapDlg.getInstanceAndShow()
	end
end

function WorldMapdlg1:HandleCloseClick(e)

	if self.bGoto then
		return true
	end

	local mouseArgs = CEGUI.toMouseEventArgs(e);
	if mouseArgs.window == self.m_MapImage then
		if mouseArgs.button ~= CEGUI.RightButton then
			return true;
		end
	end

	WorldMapdlg1.DestroyDialog();
	return true;
end
function WorldMapdlg1:Handleqiehuan1(e)
	WorldMapdlg1.DestroyDialog();
	require "logic.worldmap.worldmapdlg".GetSingletonDialogAndShowIt();
	
	return true;
end
function WorldMapdlg1:Handleqiehuan2(e)
	WorldMapdlg1.DestroyDialog();
	require "logic.worldmap.worldmapdlg".GetSingletonDialogAndShowIt();

	
	return true;
end

function WorldMapdlg1:HandleUseFlyFlagChange(e)
	if self.bGoto then
		return true
	end

	local bUse = self.m_pSubFlyFlag:isSelected();
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	roleItemManager:EnableUseFlyFlagToFly(bUse);
end

function WorldMapdlg1:UpdateButtonPos()
--	for i, v in ipairs(self.m_MapButtonMap) do
--		v:setProperty("UnifiedAreaRect", self.RectToStringAbsolute(self.m_IconMap[i]));
--	end
end

function WorldMapdlg1.RectToStringAbsolute( rect )
	local iss = "{{" .. "0" .. "," .. rect.d_left .. "},{" ..
						"0" .. "," .. rect.d_top .. "},{" ..
						"0" .. "," .. rect.d_right .. "},{" ..
						"0" .. "," .. rect.d_bottom .. "}}";
	return iss;
end

function WorldMapdlg1:SetPlayerMapPos()
	--副本部分的头像处理
	local mapid = gGetScene():GetMapID();
    local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapid)

    if mapCfg and mapCfg.bShowInWorld2 == false then
        for mm, nn in pairs(self.fuben) do 
            for m,n in pairs(nn) do 
                if mapid == tonumber(n) then
                    mapid = tonumber(self.fuben[mm][1])
                end
            end
        end
    end

	if not self.m_MapButtonMap[mapid] then
		self.m_PlayerPosImage:setVisible(false);
		return;
	end
	local  mapconfig = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(mapid);

	if mapconfig.playerPosX >= 0 and mapconfig.playerPosY >= 0 then
		local shape = BeanConfigManager.getInstance():GetTableByName("map.cworldmapsmallheadconfig"):getRecorder(gGetDataManager():GetMainCharacterShape());
        local shapeId = shape.wordmaphead
		local iconpath = gGetIconManager():GetImagePathByID(tonumber(shapeId)):c_str();
		self.m_PlayerPosImage:setVisible(true);
		self.m_PlayerPosImage:setProperty("Image", iconpath);

	
		local p = self.m_MapButtonMap[mapid]:getPosition()
		local s = self.m_MapButtonMap[mapid]:getPixelSize()
		local iconSize = self.m_PlayerPosImage:getPixelSize()
		p.x.offset = p.x.offset + s.width*0.5 - iconSize.width*0.5
		p.y.offset = p.y.offset + s.height*0.5 - iconSize.height
		self.m_PlayerPosImage:setPosition(p)

	else
		self.m_PlayerPosImage:setVisible(false);
--[[		gGetGameUIManager():RemoveUIEffect(self.m_Effect);
		self.m_Effect = nil;--]]
	end

end

function WorldMapdlg1.GetMapIDByString(strSubMaps)
	local sub_str_tab = {};
	local str = strSubMaps;
	while (true) do 
		local pos = string.find(str, ",");
		if not pos then
			sub_str_tab[#sub_str_tab + 1] = str;
			break;
		end
		local sub_str = string.sub(str, 1, pos - 1);
		sub_str_tab[#sub_str_tab + 1] = sub_str;
		str = string.sub(str, pos + 1, #str);
	end
	return sub_str_tab;
end

function WorldMapdlg1:UpdateUseFlyFlagState()
	local roleItemManager = require("logic.item.roleitemmanager").getInstance()
	local bUse = roleItemManager:isUseFlyFlagToFly();
	--self.m_pSubFlyFlag:setSelected(bUse);
end
return WorldMapdlg1;

require"logic.task.taskhelper"

--� cell    wjf create 

HuodongCellPay = {}

setmetatable(HuodongCellPay, Dialog)
HuodongCellPay.__index = HuodongCellPay

local prefix = 0

local canjiaid1 = 1 --1����NPC��Npcid��
local canjiaid2 = 2 --2���򿪽������ͣ�����id���֣�
local canjiaid3 = 3 --3�������Ʒ���ͣ���Ʒid��
local canjiaid4 = 4 --4����ȡ��������ID��
local canjiaid5 = 5 --5��ȼ�վ�����ת��ͼ
local canjiaid6 = 6 --6����ְҵʦ��
local canjiaid7 = 7 --7�����ճ�����������NPC���ж�����Ƿ���ӡ��ǣ�����ˣ���NPC;��û��ӣ�����ӽ���
local canjiaid8 = 8 --8���ҹ���������NPC���ж��Ƿ��й��ᡣ�ǣ��й��ᣬ��NPC;��û���ᣬ�򿪹������
local canjiaid9 = 9
local canjiaid10 = 10
local canjiaid11 = 11 
local canjiaid12 = 12
function HuodongCellPay.CreateNewDlg(parent, index)
	local newDlg = HuodongCellPay:new()
	newDlg:OnCreate(parent, index)
	return newDlg
end

function HuodongCellPay.GetLayoutFileName()
	return "huodongcell-dianka.layout"
end
function HuodongCellPay:creatData()
	self.m_id = 0
	self.m_txtTime = ""
    --��ʾʱ�䣿
	self.m_hasTime = false
    --��û�к��
	self.hasHongdian = false
    --����
    self.m_sort = 0
    --����  �ճ�����ʱ����������
    self.m_type = 0
end
function HuodongCellPay:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HuodongCellPay)
	return self
end

function HuodongCellPay:OnCreate(parent, index)
	LogInfo("enter HuodongCell")
	prefix = index
	Dialog.OnCreate(self, parent, index)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	self.m_width = self:GetWindow():getPixelSize().width
	self.m_height = self:GetWindow():getPixelSize().height
	HuodongCell:creatData()
	--��ʼ��ui
	self.m_txtName = winMgr:getWindow(prefixstr .. "huodongcell/di/mingzi")
	self.m_txtName:setEnabled(false)
	self.m_txtNum = winMgr:getWindow(prefixstr .. "huodongcell/di2/wenben")
	self.m_txtNum:setEnabled(false)
	self.m_itemWupin = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr .. "huodongcell/wupin"))
	self.m_itemWupin:subscribeEvent("MouseClick",HuodongCellPay.HandleBgItemClicked,self)
	self.m_textbgBg = winMgr:getWindow(prefixstr .. "huodongcell")
	self.m_itemMark = winMgr:getWindow(prefixstr .. "huodongcell/tuijian")
	self.m_txtCanjia = winMgr:getWindow(prefixstr .. "huodongcell/wenben2")
	self.m_imgCanjia = winMgr:getWindow(prefixstr .. "huodongcell/tubiao")
	self.m_btnCanjia = winMgr:getWindow(prefixstr .. "huodongcell/cangjia")
	self.m_imgHongdian = winMgr:getWindow(prefixstr .. "huodongcell/hongdian")
	self.m_imgWancheng = winMgr:getWindow(prefixstr .. "huodongcell/wancheng")
    self.m_imgEnd = winMgr:getWindow(prefixstr .. "huodongcell/yijieshu")
	
	self.m_btnCanjia:subscribeEvent("MouseClick",HuodongCellPay.HandleItemClicked,self)
    self.m_OutTime = false
    self.m_tuijian = 0
    self.m_Open = 0
end


function HuodongCellPay:RefreshShow( )
	
	LogInfo("enter HuodongCellPay RefreshShow")
	--�����
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end

    local xianshiType = 2

    if IsPointCardServer() then
        xianshiType = 3
    end
    local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(self.m_id)
	self.m_txtName:setText(record.name)
	local activities = HuoDongManager.getInstanceNotCreate().m_activities
	local huodongmanager = HuoDongManager.getInstanceNotCreate()
	local activitynum = 0
	self.m_tuijian = 0
    self.m_Open = 0
	self.m_imgHongdian:setVisible(false)
    self.m_imgEnd:setVisible(false)
    local strTable = StringBuilder.Split(record.actid, ",")
	--����
    for _,v in pairs(strTable) do
	    if activities[tonumber(v)] ~= nil then
		    activitynum = activitynum + activities[tonumber(v)].num
	    end
    end
    self.m_txtNum:setText(tostring(activitynum))
	local iconManager = gGetIconManager()
	--��Ʒ
	self.m_itemWupin:SetImage(iconManager:GetItemIconByID(record.imgid))
	self.m_itemWupin:setID(record.imgid)
    --�Ƽ�ͼ��
	if record.starttuijian == HuoDongManager.getInstanceNotCreate().m_recommend then
		self.m_itemMark:setVisible(true)
		self.m_itemMark:setProperty("Image", record.markid)
        self.m_tuijian = 1
	else
		self.m_itemMark:setVisible(false)
	end
	
	--��õȼ�
	local data = gGetDataManager():GetMainCharacterData()
	local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
	--�Ƿ�������
	local blnnum = false
	if activitynum >= record.maxnum then
		blnnum = true
	end
	if record.maxnum  <= 0 then
		blnnum = false
	end
	--�����ĵȼ������Լ��ȼ� ���� �μӻ���������ڵ���������� �����Բμ�
	if record.level > nLvl or blnnum or record.link == 0 then
		self.m_imgCanjia:setVisible(true)
		self.m_txtCanjia:setVisible(true)
		self.m_btnCanjia:setVisible(false)
		self.m_imgHongdian:setVisible(false)
		self.hasHongdian = false

        if record.level > nLvl  then
            self.m_txtCanjia:setText(record.unleveltext)
            self.m_imgCanjia:setVisible(false)
        else
            --�ȼ�����
            if record.link == 0 then
                self.m_txtCanjia:setText(record.protext)
            else
                self.m_txtCanjia:setText(self.m_txtTime..record.protext)
            end
            
        end
		
		self.m_imgWancheng:setVisible(false)
		--��ʾ���
		if blnnum and  record.maxnum > 0 then
			self.m_imgWancheng:setVisible(true)
			self.m_txtCanjia:setVisible(false)
            self.m_imgCanjia:setVisible(false)
		end
		
		
	else
		--ʱ��û�� �����Բμ�
        if self.m_hasTime then
        	self.m_imgCanjia:setVisible(false)
			self.m_txtCanjia:setVisible(false)
			self.m_btnCanjia:setVisible(true)
			self.m_imgWancheng:setVisible(false)
			self.m_btnCanjia:setID(record.link)
            self.m_Open = 1

		else
			self.m_imgCanjia:setVisible(true)
			self.m_txtCanjia:setVisible(true)
			self.m_btnCanjia:setVisible(false)
			self.m_imgHongdian:setVisible(false)
			self.hasHongdian = false
			self.m_imgWancheng:setVisible(false)
            if record.link == 0 or  record.link == 12 then
                self.m_txtCanjia:setText(record.protext)
            else
                self.m_txtCanjia:setText(self.m_txtTime..record.protext)
            end
            if self.m_OutTime then
                self.m_btnCanjia:setVisible(false)
                self.m_txtCanjia:setVisible(false)
                self.m_imgCanjia:setVisible(false)
                self.m_imgWancheng:setVisible(false)
                self.m_imgEnd:setVisible(true)
            end
		end
	end
end


function HuodongCellPay:HandleItemClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
    local tableName = ""
    if IsPointCardServer() then
        tableName = "mission.cactivitynewpay"
    else
        tableName = "mission.cactivitynew"
    end
    local record = BeanConfigManager.getInstance():GetTableByName(tableName):getRecorder(self.m_id)
    local huodongManager = HuoDongManager.getInstanceNotCreate()
    if huodongManager.m_RedpackDis[self.m_id] then
        huodongManager.m_RedpackDis[self.m_id] = 1
    end
    --ÿһ�����͵Ĳ��� �ļ���������ע��
	if id == canjiaid1 then
		Taskhelpergoto.flyToNpc(record.linkid1)
	elseif id == canjiaid2 then
		if record.linkid1 == 1 then
			require('logic.team.teammatchdlg').getInstanceAndShow()
        else
            local nUIId = record.linkid1
            local Openui = require("logic.openui")
            if nUIId == Openui.eUIId.anyemaxituan_62 then
                local taskManager = require("logic.task.taskmanager").getInstance()
                if taskManager:isAnyeNeedToGotoNpc() == true then
                    --require("logic.task.taskhelper").gotoNpc(160509)

--                     local flyWalkData = {}
--	                require("logic.task.taskhelpergoto").GetInitedFlyWalkData(flyWalkData)
--	                --//-======================================
--	                flyWalkData.nTaskTypeId = 1 --anye goto npc type
--	                flyWalkData.nNpcId = 160509
	                --//-======================================
	                require("logic.task.taskhelpergoto").flyToNpc(160509)

                else
                    require("logic.openui").OpenUI(nUIId) 
                end
            else
                require("logic.openui").OpenUI(nUIId)  
            end
                       
		end
	elseif id == canjiaid3 then
		local userID = gGetDataManager():GetMainCharacterID()
		local p = fire.pb.item.SaddItem(record.linkid1, 0, userID)
		gGetNetConnection():send(p)
	elseif id == canjiaid4 then
        NpcServiceManager.SendNpcService(0, record.linkid1)
	elseif id == canjiaid5 then
		local ids = std.vector_int_()
		local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.cactivitymaplist"):getAllID()
		local data = gGetDataManager():GetMainCharacterData()
		local nLvl = data:GetValue(fire.pb.attr.AttrType.LEVEL)
		local mapId =  0
        for _, v in pairs(tableAllId) do
        	local record1 = BeanConfigManager.getInstance():GetTableByName("mission.cactivitymaplist"):getRecorder(v)
			if nLvl >= record1.levelmin and nLvl <= record1.levelmax then
				mapId = record1.mapid
				break
			end
        end
		
		if mapId < 0 then
			return true;
		end
		
		if mapId == 1240 or mapId == 1250 then
			if GetChatManager() then
				GetChatManager():AddTipsMsg(144858);
			end
			return true;
		end
		
		local  mapRecord = BeanConfigManager.getInstance():GetTableByName("map.cworldmapconfig"):getRecorder(mapId);
		if mapRecord == nil then
			return true
		end
		
		if GetTeamManager() and not GetTeamManager():CanIMove() then
			if GetChatManager() then GetChatManager():AddTipsMsg(150030) end --�������״̬���޷�����
			return true
		end
		
		local randX = mapRecord.bottomx - mapRecord.topx;
		randX = mapRecord.topx + math.random(0, randX);
		
		local randY = mapRecord.bottomy - mapRecord.topy;
		randY = mapRecord.topy + math.random(0, randY);
		gGetNetConnection():send(fire.pb.mission.CReqGoto(mapId, randX, randY));
		if gGetScene()  then
			gGetScene():EnableJumpMapForAutoBattle(false);
		end
		GetMainCharacter():RemoveAutoWalkingEffect()
	elseif id == canjiaid6 then
		local schoolID = gGetDataManager():GetMainCharacterSchoolID()
		local schoolRecord = BeanConfigManager.getInstance():GetTableByName("role.schoolmasterskillinfo"):getRecorder(schoolID)
		if schoolRecord == nil then
			return false
		end
		TaskHelper.gotoNpc(schoolRecord.masterid)
		
	elseif id == canjiaid7 then
		if GetTeamManager() and GetTeamManager():IsOnTeam() then
			TaskHelper.gotoNpc(record.linkid1)
		else
			local team = require('logic.team.teammatchdlg').getInstanceAndShow()
			team:SelecteItem(record.linkid2)
			
		end
    elseif id == canjiaid8 then
        local datamanager = require "logic.faction.factiondatamanager"
        if datamanager:IsHasFaction() then
            TaskHelper.gotoNpc(record.linkid1)
        else
            Familyjiarudialog.getInstanceAndShow()
        end

    elseif id == canjiaid9 then
        local p = require("protodef.fire.pb.npc.crequestactivityanswerquestion"):new()
	    LuaProtocolManager:send(p)
    elseif id == canjiaid10 then
        local p = require("protodef.fire.pb.npc.capplyimpexam"):new()
        p.impexamtype = 1
        p.operate = 0
	    LuaProtocolManager:send(p)
    elseif id == canjiaid11 then
        local p = require("protodef.fire.pb.npc.capplyimpexam"):new()
        p.impexamtype = 2
        p.operate = 0
	    LuaProtocolManager:send(p)
    elseif id ==canjiaid12 then
        TaskHelper.gotoNpc(record.linkid1)
    end
    getHuodongDlg().HasOpenActicity()
    huodongManager:getHasActivity()
	local huodong = getHuodongDlg()
	huodong.DestroyDialog()

end

--��ʾtips
function HuodongCellPay:HandleBgItemClicked(args)
	local adlg = require "logic.tips.activitytips"
	if not adlg.getInstanceNotCreate() then
		local acttipdlg = adlg.getInstanceAndShow()
		acttipdlg.m_id = self.m_id
		acttipdlg:RefreshTips()
	end
end


return HuodongCellPay

require"logic.task.taskhelper"

--� cell    wjf create 

HuodongCell = {}

setmetatable(HuodongCell, Dialog)
HuodongCell.__index = HuodongCell

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
function HuodongCell.CreateNewDlg(parent, index)
	local newDlg = HuodongCell:new()
	newDlg:OnCreate(parent, index)
	return newDlg
end

function HuodongCell.GetLayoutFileName()
	return "huodongcell.layout"
end
function HuodongCell:creatData()
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
function HuodongCell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HuodongCell)
	return self
end

function HuodongCell:OnCreate(parent, index)
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
	self.m_txtAct = winMgr:getWindow(prefixstr .. "huodongcell/di3/wenben")
	self.m_txtAct:setEnabled(false)
	self.m_itemWupin = CEGUI.Window.toItemCell(winMgr:getWindow(prefixstr .. "huodongcell/wupin"))
	self.m_itemWupin:subscribeEvent("MouseClick",HuodongCell.HandleBgItemClicked,self)
	self.m_textbgBg = winMgr:getWindow(prefixstr .. "huodongcell")
	self.m_itemMark = winMgr:getWindow(prefixstr .. "huodongcell/tuijian")
	self.m_txtCanjia = winMgr:getWindow(prefixstr .. "huodongcell/wenben2")
	self.m_imgCanjia = winMgr:getWindow(prefixstr .. "huodongcell/tubiao")
	self.m_btnCanjia = winMgr:getWindow(prefixstr .. "huodongcell/cangjia")
	self.m_imgHongdian = winMgr:getWindow(prefixstr .. "huodongcell/hongdian")
	self.m_imgWancheng = winMgr:getWindow(prefixstr .. "huodongcell/wancheng")
    self.m_imgEnd = winMgr:getWindow(prefixstr .. "huodongcell/yijieshu")
	
	self.m_btnCanjia:subscribeEvent("MouseClick",HuodongCell.HandleItemClicked,self)
    self.m_OutTime = false
    self.m_tuijian = 0
    self.m_Open = 0
end


function HuodongCell:RefreshShow( )
	
	LogInfo("enter HuodongCell RefreshShow")
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
	local activityact = 0
    local activitynum2 = 0
	self.m_tuijian = 0
    self.m_Open = 0
	self.m_imgHongdian:setVisible(false)
    self.m_imgEnd:setVisible(false)
	if activities[record.id] ~= nil then
		activitynum = activities[record.id].num
		activityact = activities[record.id].activevalue
        activitynum2 = activities[record.id].num2
	end
	if activitynum == nil then
		activitynum = 0
	end
    if activitynum2 == nil then
		activitynum2 = 0
	end
	if activityact == nil then
		activityact = 0
	end
	--����

    if IsPointCardServer() and record.type == 2 then
        local strTable = StringBuilder.Split(record.actid, ",")
	    --����
        activitynum = 0
        for _,v in pairs(strTable) do
	        if activities[tonumber(v)] ~= nil then
		        activitynum = activitynum + activities[tonumber(v)].num
	        end
        end
		if record.isshowmaxnum == 0 then 
			self.m_txtNum:setText(tostring(activitynum))
		else
			self.m_txtNum:setText(tostring(activitynum).."/"..tostring(record.maxnum))
		end 
    else
	    
		 if record.maxnum <= 0 then
            if record.infinitenum == 1 then
                if activitynum > 0 then
                    if record.isshowmaxnum == 0 then 
                        self.m_txtNum:setText(tostring(activitynum))
                    else
                        self.m_txtNum:setText(tostring(activitynum).."/-")
                    end
                end
            else
                if record.isshowmaxnum == 0 then 
                     self.m_txtNum:setText(tostring(0))
                end
            end
	    else
            if record.isshowmaxnum == 0 then 
                self.m_txtNum:setText(tostring(activitynum))
            else
                self.m_txtNum:setText(tostring(activitynum).."/"..tostring(record.maxnum))
            end  
	    end 
        if record.id == 208 then
			if record.isshowmaxnum == 0 then
				self.m_txtNum:setText(tostring(activitynum2))
			else
				self.m_txtNum:setText(tostring(activitynum2).."/"..tostring(activitynum))
			end 
        end
    end




	--��Ծ��
	if record.maxact <= 0 then
	else
		--����Ƽ� �ӱ�
		if record.starttuijian == HuoDongManager.getInstanceNotCreate().m_recommend then
			self.m_txtAct:setText(tostring(activityact).."/"..tostring(record.maxact * 2))
		else
			self.m_txtAct:setText(tostring(activityact).."/"..tostring(record.maxact))
		end
	end
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
    
    if self.m_id == 119 then
        local huodongmanager = require"logic.huodong.huodongmanager".getInstance()
        if huodongmanager.m_bingfengwangzuoFinish  then
			self.m_imgWancheng:setVisible(true)
			self.m_txtCanjia:setVisible(false)
            self.m_imgCanjia:setVisible(false)
            return
        end

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
            local linkOnece = true
            if huodongmanager.m_RedpackDis[record.id] then
                if huodongmanager.m_RedpackDis[record.id] == 1 then
                    linkOnece =false
                end
            end
            if activitynum ~= record.maxnum and linkOnece then
                if self.m_type == xianshiType then --��ʱ�
            	    self.m_imgHongdian:setVisible(true)
			        self.hasHongdian = true
                end

		    end

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
    
    --Ӣ��������������
    if self.m_id == 103 and nLvl >=record.level then
        
        if huodongmanager then
            if huodongmanager.m_HeroTrial == 1 then
                self.m_btnCanjia:setVisible(true)
                self.m_btnCanjia:setEnabled(false)
                self.m_btnCanjia:setID(record.link)
                self.m_imgWancheng:setVisible(false)
            elseif huodongmanager.m_HeroTrial == 0 then
                self.m_btnCanjia:setVisible(true)
                self.m_btnCanjia:setEnabled(true)
                self.m_btnCanjia:setID(record.link)
                self.m_imgWancheng:setVisible(false)
            end
        end
    end
	
end


function HuodongCell:HandleItemClicked(args)
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
		local isHave = false
		local questid = 1040000

		if  IsPointCardServer() then
			if record.id == 104 then
				questid = 1910000
			elseif record.id == 107 then
				questid = 1920000
			end
		end

		local specialquests = GetTaskManager():GetSpecailQuestForLua()
		local specialquestnum = specialquests:size()
		for i = 0, specialquestnum - 1 do
			local specialquest = specialquests[i]
			if specialquest.questid == questid and specialquest.queststate ~= 5 then
				isHave = true
				break
			end
		end

		if isHave then
			local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(questid)
			if questinfo and questinfo.Tipsid ~= 0 and GetTeamManager():IsOnTeam() then
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(questinfo.Tipsid).msg,false)
				return true;
			end
			gGetGameUIManager():setCurrentItemId(-1)
			local taskHelper = require "logic.task.taskhelper"
			taskHelper.OnClickCellGoto(questid)
		else
			Taskhelpergoto.flyToNpcForHuoDong(record.linkid1)
		end


	elseif id == canjiaid2 then
		if record.linkid1 == 1 then
			require('logic.team.teammatchdlg').getInstanceAndShow()
        else
            local nUIId = record.linkid1
            local Openui = require("logic.openui")
            if nUIId == Openui.eUIId.anyemaxituan_62 then
                local taskManager = require("logic.task.taskmanager").getInstance()
                local nCurDay = taskManager:getServerOpenCurDay()
             --   if nCurDay <=7 then
             --       taskManager:showTip(nCurDay)
             --       return
             --   end

                
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
		local isHave = false
		local specialquests = GetTaskManager():GetSpecailQuestForLua()
		local specialquestnum = specialquests:size()
		for i = 0, specialquestnum - 1 do
			local specialquest = specialquests[i]
			if specialquest.questid == 1010000 and specialquest.queststate ~= 5 then
				isHave = true
				break
			end
		end

		if isHave then
			local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(1010000)
			if questinfo and questinfo.Tipsid ~= 0 and GetTeamManager():IsOnTeam() then
			GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(questinfo.Tipsid).msg,false)
				return true;
			end
			gGetGameUIManager():setCurrentItemId(-1)
			local taskHelper = require "logic.task.taskhelper"
			taskHelper.OnClickCellGoto(1010000)
		else
			local schoolID = gGetDataManager():GetMainCharacterSchoolID()
			local schoolRecord = BeanConfigManager.getInstance():GetTableByName("role.schoolmasterskillinfo"):getRecorder(schoolID)
			if schoolRecord == nil then
				return false
			end
			Taskhelpergoto.flyToNpcForHuoDong(schoolRecord.masterid)
			--TaskHelper.gotoNpc(schoolRecord.masterid)
		end
		
	elseif id == canjiaid7 then
		local isHave = false
		local specialquests = GetTaskManager():GetSpecailQuestForLua()
		local specialquestnum = specialquests:size()
		for i = 0, specialquestnum - 1 do
			local specialquest = specialquests[i]
			if specialquest.questid == 1030000 and specialquest.queststate ~= 5 then
				isHave = true
				break
			end
		end

		if GetTeamManager() and GetTeamManager():IsOnTeam() then
			if isHave then
				local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(1030000)
				if questinfo and questinfo.Tipsid ~= 0 and GetTeamManager():IsOnTeam() then
				GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(questinfo.Tipsid).msg,false)
					return true;
				end
				gGetGameUIManager():setCurrentItemId(-1)
				local taskHelper = require "logic.task.taskhelper"
				taskHelper.OnClickCellGoto(1030000)
			else
				Taskhelpergoto.flyToNpcForHuoDong(record.linkid1)
				--TaskHelper.gotoNpc(record.linkid1)
			end
		else
			local team = require('logic.team.teammatchdlg').getInstanceAndShow()
			team:SelecteItem(record.linkid2)
			
		end
    elseif id == canjiaid8 then
		local isHave = false
		local specialquests = GetTaskManager():GetSpecailQuestForLua()
		local specialquestnum = specialquests:size()
		for i = 0, specialquestnum - 1 do
			local specialquest = specialquests[i]
			if specialquest.questid == 1060000 and specialquest.queststate ~= 5 then
				isHave = true
				break
			end
		end
        local datamanager = require "logic.faction.factiondatamanager"
        if datamanager:IsHasFaction() then
			if isHave then
				local questinfo = GameTable.mission.GetCMainMissionInfoTableInstance():getRecorder(1060000)
				if questinfo and questinfo.Tipsid ~= 0 and GetTeamManager():IsOnTeam() then
				GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(questinfo.Tipsid).msg,false)
					return true;
				end
				gGetGameUIManager():setCurrentItemId(-1)
				local taskHelper = require "logic.task.taskhelper"
				taskHelper.OnClickCellGoto(1060000)
			else
				Taskhelpergoto.flyToNpcForHuoDong(record.linkid1)
				--TaskHelper.gotoNpc(record.linkid1)
			end
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
function HuodongCell:HandleBgItemClicked(args)
	local adlg = require "logic.tips.activitytips"
	if not adlg.getInstanceNotCreate() then
		local acttipdlg = adlg.getInstanceAndShow()
		acttipdlg.m_id = self.m_id
		acttipdlg:RefreshTips()
	end
end


return HuodongCell

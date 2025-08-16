
Taskhelperrepeat = {}



	
--[[

enum {
		CircTask_Mail = 1, // ����
		CircTask_ItemUse = 2, // ��������
		CircTask_ItemCollect = 3, // �����ռ�
		CircTask_ItemFind = 4, // Ѱ�ҵ���
		CircTask_PetCatch = 5, // �������
		CircTask_Patrol = 6, // Ѳ��
		CircTask_CatchIt = 7, // ׽��
		CircTask_KillMonster = 8, // ɱ�ּ���
		CircTask_ChallengeNpc = 9, // ��սnpc
	};
	

	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Mail or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemUse or 
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemCollect or  
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol or 
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		
	end
--]]


function Taskhelperrepeat.GoToRepeatTask(nTaskTypeId)
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return 
	end
	local nTaskDetailId = pQuest.questtype
	local nNpcId = Taskhelperschool.GetSchoolTaskNpcId(nTaskTypeId) -- pQuest.dstnpcid
	local nRandX = 0
	local nRandY = 0
	local repeatCfg = BeanConfigManager.getInstance():GetTableByName("circletask.crepeattask"):getRecorder(nTaskDetailId)
	if repeatCfg.nflytype==1 then --��ʼ��
	elseif repeatCfg.nflytype==2 then --��ͼ����� 
		nRandX = pQuest.dstx
		nRandY = pQuest.dsty
	end
	local flyWalkData = {}
	Taskhelpergoto.GetInitedFlyWalkData(flyWalkData)
	--//-======================================
	flyWalkData.nTaskTypeId = nTaskTypeId --nTaskTypeId
		flyWalkData.nNpcId = nNpcId
		flyWalkData.nRandX = nRandX
		flyWalkData.nRandY = nRandY
	--//-======================================
	Taskhelpergoto.FlyOrWalkTo(flyWalkData)
end
--[[

	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Mail or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemUse or 
         nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemCollect or  
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_Patrol or 
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind or
		 nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_PetCatch then
		return true
	end
	
--]]

function Taskhelperrepeat.IsRepeatTaskHaveBuff(nTaskTypeId)
	LogInfo("Taskhelperrepeat.IsRepeatTaskHaveBuff(nTaskTypeId)")
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return false
	end
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind and 
		pQuest.dstitemidnum2 > 0 --//have buff
	then
		
		local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
		local buffManager = require("manager.buffmanager").getInstance()
		local buffData = buffManager:getBuffDataWithId(nChuanShuoBuffId)
		if not buffData then
			LogInfo("Taskhelperrepeat.IsRepeatTaskHaveBuff=not buffData=return false")
			return false
		end
		return true
		
	end
	return false
	
end

--[[
	self.time = 0
	self.count = 0
	self.tipargs = {}
--]]

--[[

--1237 %d��%d��%d�� 
--1238 %dʱ%d��%d��
--1239 %d��%d��
--1240 %dСʱ%d����
--1241 %d����
--1242 %dСʱ


11031	����:
11032	����:
11033	Ҫ��:
11034	��Чʱ��:
11035	����ʱ��:
11036	�����ѹ���
11037	��Ƕ:
11038	��Ч:
11039	Ʒ��:
11040	����:
11041	�ȼ�:
11042	��̯����
11043	����
11044	����

--]]

function Taskhelperrepeat.GetTimeStringWithSecond(nSecond)
	local nMin = math.floor( nSecond /60)
	local strLeftTime = require("utils.mhsdutils").get_resstring(1241)
	strLeftTime = string.format(strLeftTime,nMin)
	return strLeftTime
	--local curTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
end

function Taskhelperrepeat.GetRepeatTaskBuffString(nTaskTypeId)
	LogInfo("Taskhelperrepeat.GetRepeatTaskBuffString(nTaskTypeId)")
	local strResult = ""
	local pQuest = GetTaskManager():GetSpecialQuest(nTaskTypeId)
	if not pQuest then
		return strResult
	end
	local nTaskDetailId = pQuest.questtype
	local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
	
	if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
		local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
		local buffManager = require("manager.buffmanager").getInstance()
		local buffData = buffManager:getBuffDataWithId(nChuanShuoBuffId)
		if not buffData then
			return strResult
		end
		local nTimeEnd = buffData.time
		LogInfo("Taskhelperrepeat.=nTimeEnd="..nTimeEnd)
		local nLeftSecond  = nTimeEnd --math.floor( nTimeEnd /1000)
		
		--<T t="��" c="ff6b4226"></T><T t="$MapName$" c="ff00ff00"></T><T t="��ɱ�����и��ʻ��������Ʒ��ʣ��ʱ��Ϊ" c="ff6b4226"></T><T t="$time$" c="ff6b4226"></T>
		
		local nMapId = require("logic.mapchose.hookmanger").getInstance():GetLevelMapID()
		LogInfo("nMapId="..nMapId)
		local mapCfg = BeanConfigManager.getInstance():GetTableByName("map.cmapconfig"):getRecorder(nMapId)
		local strMapName = mapCfg.mapName
		
		local strTime = Taskhelperrepeat.GetTimeStringWithSecond(nLeftSecond)
		
		
		
		local strBuff = require("utils.mhsdutils").get_resstring(11202)   --11202
		local sb = StringBuilder.new()
		sb:Set("MapName", strMapName)
		sb:Set("time", strTime)
		local strContent = sb:GetString(strBuff)
		sb:delete()
		
		--//===============
		--//===============
		
		strResult = strContent
		LogInfo("Taskhelperrepeat=strResult="..strResult)
		return strResult
		
	end
	return strResult
end

--[[
function Taskhelperrepeat.GetTaskTypeWithBuffId(nBuffId)
	LogInfo("Taskhelperrepeat.GetTaskTypeWithBuffId(nBuffId)")
	local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
	
	if nBuffId == nChuanShuoBuffId then
		return fire.pb.circletask.CircTaskClass.CircTask_ItemFind
	end
	return -1
end
--]]

function Taskhelperrepeat.RefreshTaskBuffChuanShuo(nBuffId)
	LogInfo("Taskhelperrepeat.RefreshTaskBuffChuanShuo(nBuffId)")
	local tracingDlg = require("logic.task.renwulistdialog").getSingleton()
	if not tracingDlg then
		return 
	end
	
	for nIndex = 1, #tracingDlg.m_mapCells do
		local unitCell = tracingDlg.m_mapCells[nIndex]		
		local nCellId = unitCell.id
		local pQuest = GetTaskManager():GetSpecialQuest(nCellId)
		if pQuest then
			local nTaskDetailId = pQuest.questtype
			local nTaskDetailType = TaskHelper.GetSpecialQuestType2(nTaskDetailId)
			local nTaskTypeId = pQuest.questid
			if nTaskDetailType == fire.pb.circletask.CircTaskClass.CircTask_ItemFind then
				tracingDlg:RefreshCellContentForBuffWithId(nTaskTypeId)
			end			
		end
	end
	
end

function Taskhelperrepeat.addBuff(addedbuffs)
	LogInfo("Taskhelperrepeat.addBuff(addedbuffs)")
	local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
	
	for nBuffId,v in pairs(addedbuffs) do 
		LogInfo("buffid="..nBuffId)
		if nBuffId==nChuanShuoBuffId then
			
			local taskManager = require("logic.task.taskmanager").getInstance()
			taskManager:addBuff(nBuffId)
		end
	end
end

function Taskhelperrepeat.deleteBuff(deletedBuffs)
	LogInfo("Taskhelperrepeat.deleteBuff(deletedBuffs)")
	local nChuanShuoBuffId = require("logic.task.taskhelper").ITEM_FIND_LEGEND_BUFF
	
	for k,nBuffId in pairs(deletedBuffs) do 
		LogInfo("buffid="..nBuffId)
		if nBuffId==nChuanShuoBuffId then
			
			local taskManager = require("logic.task.taskmanager").getInstance()
			taskManager:deleteBuff(nBuffId)
		end
	end
end
	
return Taskhelperrepeat


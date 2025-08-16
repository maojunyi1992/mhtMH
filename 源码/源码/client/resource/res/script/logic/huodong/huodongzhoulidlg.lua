require "logic.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "logic.huodong.huodongzhoulicell"
require "logic.huodong.huodongzhoulinowcell"
HuodongZhouLiDlg = {}
setmetatable(HuodongZhouLiDlg, Dialog)
HuodongZhouLiDlg.__index = HuodongZhouLiDlg

local _instance
--���������� wjf

function HuodongZhouLiDlg.getInstance()
	if not _instance then
		_instance = HuodongZhouLiDlg:new()
		_instance:OnCreate()
	end
	return _instance
end

function HuodongZhouLiDlg.getInstanceAndShow()
	
	if not _instance then
		_instance = HuodongZhouLiDlg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function HuodongZhouLiDlg.getInstanceNotCreate()
	return _instance
end

function HuodongZhouLiDlg.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
            for index in pairs( _instance.m_cells ) do
		        local cell = _instance.m_cells[index]
		        if cell then
			        cell:OnClose()
		        end
	        end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function HuodongZhouLiDlg.ToggleOpenClose()
	if not _instance then
		_instance = HuodongZhouLiDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function HuodongZhouLiDlg.GetLayoutFileName()
	return "huodongzhouli.layout"
end

function HuodongZhouLiDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, HuodongZhouLiDlg)
	return self
end



function HuodongZhouLiDlg:OnCreate()
	LogInfo("enter HuodongDlg OnCreate")
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pMain = winMgr:getWindow("huodongzhouli/liebiao/di")
	self.m_numItemCount = 40
	self.m_arrayItemComponent = {}
	self.m_cells = {}
	local time = StringCover.getTimeStruct(gGetServerTime() / 1000)
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end
	for i=1, self.m_numItemCount do
		--����ǽ��������
		if (i -1) / 5 >= curWeekDay and (i -1) / 5 < (curWeekDay + 1) then
			local cellWnd = huodongzhoulinowcell.CreateNewDlg(self.m_pMain)
			self.m_arrayItemComponent[i] = cellWnd
			table.insert(self.m_cells, cellWnd)
			huodongzhoulicell.addIndex()
		else
			local cellWnd = huodongzhoulicell.CreateNewDlg(self.m_pMain)
			self.m_arrayItemComponent[i] = cellWnd
			table.insert(self.m_cells, cellWnd)
			huodongzhoulinowcell.addIndex()
		end
		
		
	end
	
	self.col = 8;
	self.row = 5;
	self:refreshlist()
end
function HuodongZhouLiDlg:HandleItemClicked(args)
	local e = CEGUI.toMouseEventArgs(args)
	local touchPos = e.position
	
	
end
function HuodongZhouLiDlg:DisplayItem()
	
end
function HuodongZhouLiDlg:refreshlist()
	local arrayIndex = 0;
	
	local height = self.m_arrayItemComponent[1].m_pMainFrame:getHeight()
	local width = self.m_arrayItemComponent[1].m_pMainFrame:getWidth()
	local xO = 0
	local yO = 0
	local newPos = CEGUI.UVector2( CEGUI.UDim(0, xO), CEGUI.UDim(0, yO) )
	for colIndex = 1  ,  self.col do
		for rowIndex = 1, self.row do
			arrayIndex = arrayIndex + 1;
			local tempCom = self.m_arrayItemComponent[arrayIndex]
			local offsetX = xO+(colIndex-1)*width.offset
			local offsetY = yO+(rowIndex-1)*height.offset
			local tempPos = CEGUI.UVector2(CEGUI.UDim(0, offsetX), CEGUI.UDim(0, offsetY ) )
			tempCom.m_pMainFrame:setPosition(tempPos)
		end
	end
	
    local tableAllId = BeanConfigManager.getInstance():GetTableByName("mission.cweeklist"):getAllID()
	arrayIndex = 0
	
	arrayIndex = arrayIndex + 1;
	local recordtime = BeanConfigManager.getInstance():GetTableByName("mission.cweeklist"):getRecorder(tableAllId[1])
	local tempCom = self.m_arrayItemComponent[arrayIndex]
	tempCom:RefreshItem(1, "", recordtime.text1)
	arrayIndex = arrayIndex + 1;
	tempCom = self.m_arrayItemComponent[arrayIndex]
	tempCom:RefreshItem(1, "", recordtime.text2)
	arrayIndex = arrayIndex + 1;
	tempCom = self.m_arrayItemComponent[arrayIndex]
	tempCom:RefreshItem(1, "", recordtime.text3)
	arrayIndex = arrayIndex + 1;
	tempCom = self.m_arrayItemComponent[arrayIndex]
	tempCom:RefreshItem(1, "", recordtime.text4)
	arrayIndex = arrayIndex + 1;
	tempCom = self.m_arrayItemComponent[arrayIndex]
	tempCom:RefreshItem(1, "", recordtime.text5)
	for _, v in pairs(tableAllId) do
		local record = BeanConfigManager.getInstance():GetTableByName("mission.cweeklist"):getRecorder(v)
		arrayIndex = arrayIndex + 1;
		local tempCom = self.m_arrayItemComponent[arrayIndex]
		tempCom:RefreshItem(2, record.time1, "")
		arrayIndex = arrayIndex + 1;
		local tempCom = self.m_arrayItemComponent[arrayIndex]
		tempCom:RefreshItem(2, record.time2, "")
		arrayIndex = arrayIndex + 1;
		local tempCom = self.m_arrayItemComponent[arrayIndex]
		tempCom:RefreshItem(2, record.time3, "")
		arrayIndex = arrayIndex + 1;
		local tempCom = self.m_arrayItemComponent[arrayIndex]
		tempCom:RefreshItem(2, record.time4, "")
		arrayIndex = arrayIndex + 1;
		local tempCom = self.m_arrayItemComponent[arrayIndex]
		tempCom:RefreshItem(2, record.time5, "")
    end
end
function HuodongZhouLiDlg:HandleClick(args)
	
	return true
end


return HuodongZhouLiDlg

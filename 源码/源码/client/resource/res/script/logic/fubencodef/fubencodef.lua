require "logic.dialog"
require "logic.fubencodef.fubencodefcell"

fubencodef = {}
setmetatable(fubencodef, Dialog)
fubencodef.__index = fubencodef

local _instance
function fubencodef.getInstance()
	if not _instance then
		_instance = fubencodef:new()
		_instance:OnCreate()
	end
	return _instance
end

function fubencodef.getInstanceAndShow()
	if not _instance then
		_instance = fubencodef:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function fubencodef.getInstanceNotCreate()
	return _instance
end

function fubencodef.DestroyDialog()
	if _instance then 
		if not _instance.m_bCloseIsHide then
			for index in pairs( _instance.cell ) do
				local cell = _instance.cell[index]
				if cell then
					cell:OnClose(false, false)
					cell = nil
				end
			end
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function fubencodef.ToggleOpenClose()
	if not _instance then
		_instance = fubencodef:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function fubencodef.GetLayoutFileName()
	return "moshouchuanqi_mtg.layout"
end

function fubencodef:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, fubencodef)
	return self
end

function fubencodef:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pane = CEGUI.toScrollablePane(winMgr:getWindow("moshouchuanqi_mtg/bg/list"))
	self.back = CEGUI.toPushButton(winMgr:getWindow("moshouchuanqi_mtg/zuofanye"))
	self.forward = CEGUI.toPushButton(winMgr:getWindow("moshouchuanqi_mtg/youfanye"))
    
    self.m_pane:subscribeEvent("ScrollPageChanged", fubencodef.HandleScrollChange,self)
	self.back:subscribeEvent("Clicked", fubencodef.HandleBackClicked,self)
	self.forward:subscribeEvent("Clicked", fubencodef.HandleForwardClicked,self)

	self.index = 0
	self.m_pane:EnableHorzScrollBar(true)
	self.m_pane:EnablePageScrollMode(true)
	self:initPageInfo()
end
-- ≥ı ºªØcell
function fubencodef:initPageInfo()
    local dataInfo = require "logic.fubencodef.fubencodefmanager":getDataInfo()
	self.cell = {}
    local vAllTableId = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getAllID()
	local num = #vAllTableId
	self.maxIndex = num
	local index = 0
	local scrollPos = 0
	for i = 1, num do
		local info = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(i)
 		self.cell[i] = fubencodescell.CreateNewDlg( self.m_pane )
		self.cell[i]:loadServerData(dataInfo[info.fubenId])
		self.cell[i].btnFight:setID(info.fubenId)
		self.cell[i].btnFight:subscribeEvent("Clicked", fubencodef.HandleFightClicked,self)
		self.cell[i]:refreshData(info)
		self.m_pane:addChildWindow(self.cell[i].window)
		local cellWidth = self.cell[i].m_pMainFrame:getPixelSize().width
		local xGap = self.m_pane:getPixelSize().width
		local yPos = 1
		local xPos = xGap*index
		index = index  + 1
		self.cell[i].m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0, xPos), CEGUI.UDim(0.0, yPos)))
		SetHorizontalScrollCellRight(self.m_pane,self.cell[i].m_pMainFrame)
		if dataInfo[info.fubenId].state == 2 and i+1 <= num then
			local nextInfo = BeanConfigManager.getInstance():GetTableByName("mission.cshiguangzhixueconfig"):getRecorder(i+1)
			if gGetDataManager():GetMainCharacterLevel() >= nextInfo.enterLevel then
				scrollPos = scrollPos + 1
			end
		end
	end
	self.index = self.index + scrollPos
	self.m_pane:setHorizontalScrollPosition(1/num*scrollPos)
	self.m_panePos = self.m_pane:getHorizontalScrollPosition()
end

function fubencodef:HandleScrollChange( args )

	if self.m_panePos then
		local  dPos=  self.m_pane:getHorizontalScrollPosition() 
		local  dW = 1.00/self.maxIndex 
		for i = 1 , self.maxIndex  do
            local pos = dW * (i - 1)		
			if pos -dW*0 < dPos and pos + dW*0 > dPos then
				self.index = i -1
				break
			end	
		end 
		if self.index < 0  then
			self.index = 0
		elseif  self.index  > self.maxIndex -1 then 
			self.index = self.maxIndex -1
		end
		self.m_panePos =  dPos
	end 
end

function fubencodef:HandleBackClicked( args )
	if self.index >	0 then
		self.m_pane:setHorizontalScrollPosition(self.m_pane:getHorizontalScrollPosition() - 1 / self.maxIndex)
		self.index = self.index - 1
	else
     	self.index = 0
	end
end

function fubencodef:HandleForwardClicked( args )
	if self.index >= 0 and self.index < self.maxIndex -1 then
		self.m_pane:setHorizontalScrollPosition(self.m_pane:getHorizontalScrollPosition() + 1 / self.maxIndex)		
		self.index = self.index + 1
	else
       	self.index = self.maxIndex-1
	end
end

function fubencodef:HandleFightClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local p = require "protodef.fire.pb.mission.creqlinetask":new()
	p.taskid = id
	require "manager.luaprotocolmanager":send(p)
	fubencodef.DestroyDialog()
end

return fubencodef

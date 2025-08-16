require "logic.bingfengwangzuo.bingfengwangzuoTips"
bingfengwangzuocell = {}

setmetatable(bingfengwangzuocell, Dialog)
bingfengwangzuocell.__index = bingfengwangzuocell
local prefix = 0
local height = 93
local width = 55
function bingfengwangzuocell.CreateNewDlg(parent)
	local newDlg = bingfengwangzuocell:new()
	newDlg:OnCreate(parent)
	return newDlg
end

function bingfengwangzuocell.GetLayoutFileName()
	return "bingfengwangzuocell_mtg.layout"
end

function bingfengwangzuocell:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, bingfengwangzuocell)
	return self
end

function bingfengwangzuocell:OnCreate(parent)
	prefix = prefix + 1
	Dialog.OnCreate(self, parent, prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local prefixstr = tostring(prefix)
	

	self.btnCell = {}
	self.cellName = {}
	self.di = {}
	self.touxiang = {}
	self.touxiangText = {}
	self.pageCellNum = 5
	for i=1,5 do
		self.btnCell[i] = CEGUI.toItemCell(winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/btn"..i))
		if self.btnCell[i] then
			self.btnCell[i]:setVisible(false)
		end
		self.cellName[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/text"..i)
		self.di[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/di"..i)
		self.di[i]:setVisible(false)
		self.touxiang[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/touxiang"..i)
		self.touxiang[i]:setVisible(false)
		self.touxiangText[i] = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/touxiang"..tostring(i).."/text"..tostring(i))
	end
	self.imageBoss = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg/boss")
	self.imageBoss:setVisible(false)
	self.bg = winMgr:getWindow(prefixstr .. "bingfengwangzuocell_mtg")
end

function bingfengwangzuocell:setParent( parent )
	self.m_Parent = parent:GetWindow()
end

function bingfengwangzuocell:setCellVisible( page, index, enemyNum, stage ,yesterdaystage)
	local num = index - 1
	self.page = page
	self.stage = stage
    self.yesterdaystage = yesterdaystage
    local level = 1
	for i=num*5+1, num*5+5 do
		if i > enemyNum then
			break
		end
		if self.btnCell[level] then
			local info = BeanConfigManager.getInstance():GetTableByName("instance.cenchoulunewconfig"):getRecorder(page*100 + i - 1)
			local npcConfig = BeanConfigManager.getInstance():GetTableByName("npc.cnpcconfig"):getRecorder(info.FocusNpc)
            if npcConfig then
			    local shapeID = npcConfig.modelID
			    local shapeTable = BeanConfigManager.getInstance():GetTableByName("npc.cnpcshape"):getRecorder(shapeID)
			    local imageId
			    if i > stage then
				    imageId = shapeTable.mapheadcID + 1
			    else
				    imageId = shapeTable.mapheadcID
			    end
--------秘境降妖修改
          	    local image = gGetIconManager():GetImageByID(imageId)
          	    self.cellName[level]:setVisible(true)
          	    self.di[level]:setVisible(true)
          	    self.touxiang[level]:setVisible(true)
   			    self.touxiangText[level]:setText(info.state + 1)
                gGetGameUIManager():RemoveUIEffect(self.btnCell[level])
   			    if stage + 1 == i then -- 当前关卡设置特效
   				    self:addEffectToCell(self.btnCell[level])
   			    end
         	    self.cellName[level]:setText(info.describe)
                self.btnCell[level]:setPosition(CEGUI.UVector2(CEGUI.UDim(0, info.posX), CEGUI.UDim(0, info.posY)))
         	    local pos = self.btnCell[level]:getPosition()
			    local y = CEGUI.UDim(0, height)
			    local x = CEGUI.UDim(0, width)
			    local posOff = CEGUI.UVector2(pos.x - x, y + pos.y)
         	    self.di[level]:setPosition(posOff)
         	    self.touxiang[level]:setPosition(CEGUI.UVector2(pos.x - CEGUI.UDim(0, width), CEGUI.UDim(0, height - 1) + pos.y))
			    self.btnCell[level]:subscribeEvent("MouseClick", bingfengwangzuocell.HandleShowEnemyInfo, self)
			    self.btnCell[level]:setID(page*100 + i - 1)
			    self.btnCell[level]:setID2(i-1)
			    self.btnCell[level]:SetImage(image)
			    self.btnCell[level]:setVisible(true)
			    if info.boss == 1 then
				    self.btnCell[level]:SetBackGroundImage("cc25414", "c2")
				    self.imageBoss:setVisible(true)
				    local bossPos = CEGUI.UVector2(pos.x - CEGUI.UDim(0, width - 96), CEGUI.UDim(0, height + 10) + pos.y)
				    self.imageBoss:setPosition(bossPos)
			    end
            end
		end
        level = level + 1
	end
end

function bingfengwangzuocell:addEffectToCell( cell )
	if cell then
        local strEffectPath = require ("utils.mhsdutils").get_effectpath(10068)
        local bCycle = true
        local nPosX = 0
        local nPosY = 0
        local bClicp = true
        local bBounds = true
		gGetGameUIManager():AddParticalEffect(cell,strEffectPath,bCycle,nPosX,nPosY,bClicp,bBounds)
	end
end

function bingfengwangzuocell:HandleShowEnemyInfo( args )
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local id2 = e.window:getID2()
	local stage = id2
	if id2 > self.stage and self.yesterdaystage < id2 then
		-- 添加未开启提示
	else
		if self.m_Parent then
			local dlg = bingfengwangzuoTips.getInstanceAndShow(self.m_Parent)
			dlg:initData(id)
			dlg:initPageInfo(self.page, stage)
			self:sendGuanQiaInfo(id2)
		end
	end
end

function bingfengwangzuocell:sendGuanQiaInfo( stage )
  	local p = require "protodef.fire.pb.instancezone.bingfeng.cgetbingfengdetail".new()
	p.landid = self.page
	p.stage = stage
	require "manager.luaprotocolmanager":send(p)
end

return bingfengwangzuocell

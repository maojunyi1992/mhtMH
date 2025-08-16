require "utils.mhsdutils"
--require "logic.dialog"



JingMais = 
{
}

--setmetatable(JingMais, Dialog)
JingMais.__index = JingMais


function JingMais.GetLayoutFileName()
   -- return "workshopdzpreviewcell.layout"
end


function JingMais.new(parent, posindex,prefix)
	local newcell = {}
	setmetatable(newcell, JingMais)
	newcell.__index = JingMais
	
	newcell:OnCreate(parent,prefix)
	
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	
	return newcell
end

function JingMais:OnCreate(parent, prefix)
	
	if prefix then
		print("JingMais=prefix="..prefix)
	else
		print("JingMais=prefix=nil")
		prefix = ""
	end
	self.parent = parent
	local layoutName = prefix..".layout"
	local winMgr = CEGUI.WindowManager:getSingleton()
	--print("JingMais=prefix="..prefix)
	self.m_pMainFrame = winMgr:loadWindowLayout(layoutName,prefix)
	self.items={}
	self.itemTX={}
	
	
	
	for index=1,16 do
		self.items[index]= CEGUI.toItemCell(winMgr:getWindow(prefix..(prefix.."/cell/item"..index)));
		self.items[index]:SetIndex(index)
		self.items[index]:SetBackGroundImage("my_qng", "18")

		
		local AAName = prefix.."/cell/AAitem"..tostring(index)
		self.itemTX[index] = winMgr:createWindow("TaharezLook/StaticImage",AAName)
	    self.m_pMainFrame:addChildWindow(self.itemTX[index])
		
		local AAnameW = self.items[index]:getPixelSize().width
		local AAnameH = self.items[index]:getPixelSize().height
		self.itemTX[index]:setSize(CEGUI.UVector2(CEGUI.UDim(0, AAnameW), CEGUI.UDim(0, AAnameH)))
		
		
		local AAnameX = self.items[index]:GetScreenPos().x - (AAnameW / 2)
		local AAnameY = self.items[index]:GetScreenPos().y -- (AAnameH / 2)
		self.itemTX[index]:setPosition(CEGUI.UVector2(CEGUI.UDim(0, AAnameX),CEGUI.UDim(0, AAnameY)))
		
		--self.itemTX[index]:setProperty("Image",  "set:my_jingmai image:fd")
		self.itemTX[index]:setVisible(true)
		                -- corner:setProperty("Image",  cfg.borderpic[cShapeId-1])



	end

	if parent then
	    parent:addChildWindow(self.m_pMainFrame)
    end
	
	
	--经脉点特效

	--背景特效
	--GetCTipsManager():AddMessageTip("恭喜获得"..prefix) --jingmai111/diban/tuteng
	self.bgeff = winMgr:getWindow(prefix..(prefix.."/tuteng"));
	moveControl(self.bgeff, 0.5, 0,0.5, 0)--居中

	local zhiye=gGetDataManager():GetMainCharacterSchoolID()
	local bgtxANi = gGetGameUIManager():AddUIEffect(self.bgeff, "spine/my_spine/jinmai/my_jinmai_"..zhiye, true) --�ϳ���Ч ����
	
	local effid = string.match(prefix,"%d+$")
	
	bgtxANi:SetDefaultActName(effid)
	bgtxANi:SetScale(0.7)
	
end

function moveControl(controlName, xRatio, xOffset, yRatio, yOffset)--移动控件子函数 从居中位置来算
    --local control = CEGUI.WindowManager:getSingleton():getWindow(controlName)--可以用名字的方式取控件
    local parent = controlName:getParent() --获取待移动的控件的父级

    local parentWidth = parent:getPixelSize().width
    local parentHeight = parent:getPixelSize().height

    local xPosition = (parentWidth * xRatio) + xOffset - (controlName:getPixelSize().width/2)
    local yPosition = (parentHeight * yRatio) + yOffset - (controlName:getPixelSize().height/2)

    controlName:setPosition(CEGUI.UVector2(CEGUI.UDim(0, xPosition), CEGUI.UDim(0, yPosition)))
end

--function JingMais:RefreshProperty(strName,strProperty1,strProperty2,strProperty3)
--	if strName then
--		self.LabName:setText(strName)
--	end
--
--	if strProperty1 then
--		self.labelProperty1:setText(strProperty1)
--	end
--
--	if strProperty2 then
--		self.labelProperty2:setText(strProperty2)
--	end
--
--    if strProperty3 then
--		self.labelProperty3:setText(strProperty3)
--	end
--end

function JingMais:DestroyDialog()
	self:OnClose()
end

function JingMais:OnClose()
	if self.parent then
		self.parent:removeChildWindow(self.m_pMainFrame)
	end
	CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
end


return JingMais

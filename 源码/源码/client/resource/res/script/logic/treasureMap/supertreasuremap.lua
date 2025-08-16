require "logic.dialog"

supertreasuremap = {}
setmetatable(supertreasuremap, Dialog)
supertreasuremap.__index = supertreasuremap

local _instance
function supertreasuremap.getInstance()
	if not _instance then
		_instance = supertreasuremap:new()
		_instance:OnCreate()
	end
	return _instance
end

function supertreasuremap.getInstanceAndShow(x, y)
	if not _instance then
		_instance = supertreasuremap:new()
		_instance:OnCreate()
		_instance:destination(x, y)
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function supertreasuremap.getInstanceNotCreate()
	return _instance
end

function supertreasuremap.DestroyDialog()
	if _instance then
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function supertreasuremap.ToggleOpenClose()
	if not _instance then
		_instance = supertreasuremap:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function supertreasuremap.GetLayoutFileName()
	return "gaojiwabao.layout"
end

function supertreasuremap:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, supertreasuremap)
	return self
end

function supertreasuremap:HandleBtnCloseClicked(args)
	supertreasuremap.DestroyDialog()
end

function supertreasuremap:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.arrows = winMgr:getWindow("gaojiwabao/jiantou")
	self.close = CEGUI.toPushButton(winMgr:getWindow("gaojiwabao/close"))
	self.close:subscribeEvent("Clicked", supertreasuremap.HandleBtnCloseClicked , self)
	self.elapse = 0
	
	local nWidth = self.arrows:getPixelSize().width
	local nHeight = self.arrows:getPixelSize().height
    local anchorPos =  CEGUI.Vector3(nWidth * 0.5, nHeight * 0.75, 0)
    self.arrows:setGeomPivot(anchorPos)
end
-- ������Ŀ���
function supertreasuremap:destination(x, y)
	self._x = x
	self._y = y 
end

function supertreasuremap:update(delta)
	self.elapse = self.elapse + delta
	if self.elapse > 300 then --1s
		self.elapse = 0
		self:arrivalAngele()
	end
end
-- �������ﵱǰ������Ŀ������ĽǶȲ����ü�ͷ
function supertreasuremap:arrivalAngele()
	-- x1, y1 Ϊ���Ｔʹ����
	-- x2, y2 ΪĿ�ĵ�����
	local y1 = GetMainCharacter():GetGridLocation().y
	local y2 = self._y
	local x1 = GetMainCharacter():GetGridLocation().x
	local x2 = self._x
	local lenY = y2 - y1
	local lenX = x2 - x1
	if math.abs(lenY) < 10 and math.abs(lenX) < 10 then  -- �ڱ��ط�Χ��
        GetCTipsManager():AddMessageTip(GameTable.message.GetCMessageTipTableInstance():getRecorder(170002).msg)
		self:closeSelfAndShowTips()
	end
	angel = math.atan(math.abs(lenY)/math.abs(lenX))*180/math.pi
	if lenY <= 0 and lenX >= 0 then       -- ��һ����
		angel = 90 - angel
	elseif  lenY <= 0 and lenX <= 0 then  -- �ڶ�����
		angel = -(90 - angel)
	elseif lenY >= 0 and lenX <= 0 then   -- ��������
		angel = -(90 + angel)
	elseif lenY >= 0 and lenX >= 0 then   -- ��������
		angel = 90 + angel
	end
	self.arrows:setGeomRotation(CEGUI.Vector3(0, 0, angel))
end
-- ��ʾtips���ڲ��ر��Լ�
function supertreasuremap:closeSelfAndShowTips()
	local itemId = 331301
	local key = GetMainCharacter():GetCurItemkey()
	Taskuseitemdialog.getInstanceAndLoadData( itemId, key )
	supertreasuremap.DestroyDialog()
end

return supertreasuremap
